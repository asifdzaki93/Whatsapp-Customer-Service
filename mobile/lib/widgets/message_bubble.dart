import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/message.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../providers/chat_provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:video_compress/video_compress.dart';
import 'dart:async';
import 'dart:io';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final bool _isHighResLoaded = false;
  int _totalPages = 0;
  bool _isDownloaded = false;
  String? _localFilePath;
  String? _cachedThumbnailPath;

  @override
  bool shouldRebuild(covariant _MessageBubbleState oldWidget) {
    return oldWidget.widget.message != widget.message ||
        oldWidget.widget.isMe != widget.isMe ||
        _isDownloaded != oldWidget._isDownloaded ||
        _localFilePath != oldWidget._localFilePath;
  }

  // Optimasi untuk widget statis
  static const _defaultIconSize = 20.0;
  static const _defaultContainerSize = 36.0;
  static const _defaultBorderRadius = 8.0;
  static const _defaultPadding = 8.0;
  static const _defaultSpacing = 4.0;

  // Optimasi untuk warna
  static const _defaultBubbleColor = Color(0xFFDCF8C6);
  static const _defaultTextColor = Color(0xFF000000);
  static const _defaultGreyColor = Color(0xFF90A4AE);
  static const _defaultWhiteColor = Color(0xFFFFFFFF);

  // Optimasi untuk animasi
  static const _defaultAnimationDuration = Duration(milliseconds: 300);
  static const _defaultScaleBegin = 1.0;
  static const _defaultScaleEnd = 1.05;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _defaultAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: _defaultScaleBegin,
      end: _defaultScaleEnd,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _checkDownloadStatus();
    _cleanupCache();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: PhotoView(
                imageProvider: CachedNetworkImageProvider(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                initialScale: PhotoViewComputedScale.contained,
                backgroundDecoration: BoxDecoration(color: Colors.black),
              ),
            ),
      ),
    );
  }

  void _showMessageActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.reply),
                  title: Text('Reply'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement reply
                  },
                ),
                ListTile(
                  leading: Icon(Icons.forward),
                  title: Text('Forward'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement forward
                  },
                ),
                if (widget.message.fromMe) ...[
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement edit
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement delete
                    },
                  ),
                ],
                ListTile(
                  leading: Icon(
                    widget.message.isPinned
                        ? Icons.push_pin
                        : Icons.push_pin_outlined,
                  ),
                  title: Text(widget.message.isPinned ? 'Unpin' : 'Pin'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement pin/unpin
                  },
                ),
                ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy'),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.message.body != null) {
                      Clipboard.setData(
                        ClipboardData(text: widget.message.body!),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Message copied to clipboard')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Reaction',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                  ),
                  itemCount: _reactions.length,
                  itemBuilder: (context, index) {
                    final reaction = _reactions[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement add reaction
                      },
                      child: Center(
                        child: Text(
                          reaction,
                          style: TextStyle(fontSize: 24.sp),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showPdfPreview(BuildContext context, String url) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text('PDF Preview'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () {
                      // TODO: Implement download functionality
                    },
                  ),
                ],
              ),
              body: PDFView(
                filePath: url,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: true,
                onRender: (pages) {
                  setState(() {
                    _totalPages = pages!;
                  });
                },
                onError: (error) {
                  print(error.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error loading PDF: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                onPageError: (page, error) {
                  print('$page: ${error.toString()}');
                },
              ),
            ),
      ),
    );
  }

  Future<void> _checkDownloadStatus() async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return;

      final downloadDir = Directory('${dir.path}/Downloads');
      if (!await downloadDir.exists()) return;

      final fileName = widget.message.mediaName ?? '';
      if (fileName.isEmpty) return;

      final filePath = path.join(downloadDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        setState(() {
          _isDownloaded = true;
          _localFilePath = filePath;
        });
      }
    } catch (e) {
      print('DEBUG: Error checking download status: $e');
    }
  }

  Future<String> _getCachePath(String fileName) async {
    try {
      final dir = await getTemporaryDirectory();
      // Pastikan fileName tidak kosong dan valid
      if (fileName.isEmpty) {
        throw Exception('Nama file tidak valid');
      }
      // Bersihkan nama file dari karakter yang tidak valid
      final cleanFileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      return path.join(dir.path, cleanFileName);
    } catch (e) {
      print('DEBUG: Error getting cache path: $e');
      rethrow;
    }
  }

  Future<void> _handleDocumentAction(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    try {
      print('DEBUG: Memulai penanganan dokumen');
      print('DEBUG: URL: $url');
      print('DEBUG: Nama file: $fileName');

      // Jika fileName kosong, ekstrak dari URL
      if (fileName.isEmpty && url.isNotEmpty) {
        fileName = url.split('/').last;
        print('DEBUG: Mengekstrak nama file dari URL: $fileName');
      }

      if (fileName.isEmpty) {
        throw Exception('Nama file tidak valid');
      }

      // Cek cache terlebih dahulu
      final cachePath = await _getCachePath(fileName);
      final cachedFile = File(cachePath);

      if (await cachedFile.exists()) {
        print('DEBUG: Menggunakan file dari cache');
        final result = await OpenFile.open(cachePath);
        if (result.type != ResultType.done) {
          throw Exception('Tidak dapat membuka file: ${result.message}');
        }
        return;
      }

      // Jika tidak ada di cache, download
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        throw Exception('Tidak dapat mengakses penyimpanan');
      }

      final downloadDir = Directory('${dir.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final filePath = path.join(downloadDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        print('DEBUG: File sudah ada, membuka file');
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          throw Exception('Tidak dapat membuka file: ${result.message}');
        }
      } else {
        print('DEBUG: File belum ada, memulai download');
        final dio = Dio();

        // Tampilkan progress dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: Text('Mengunduh File'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text('Mengunduh: $fileName'),
                  ],
                ),
              ),
        );

        try {
          // Download ke cache terlebih dahulu
          await dio.download(
            url,
            cachePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = (received / total * 100).toStringAsFixed(0);
                print('DEBUG: Progress download: $progress%');
              }
            },
          );

          // Copy ke folder Downloads
          await cachedFile.copy(filePath);

          // Update state
          setState(() {
            _isDownloaded = true;
            _localFilePath = filePath;
          });

          // Tutup dialog
          Navigator.pop(context);

          // Tampilkan snackbar sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File berhasil diunduh'),
              action: SnackBarAction(
                label: 'Buka',
                onPressed: () async {
                  final result = await OpenFile.open(filePath);
                  if (result.type != ResultType.done) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tidak dapat membuka file: ${result.message}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } catch (e) {
          print('DEBUG: Error saat download: $e');
          Navigator.pop(context);
          throw Exception('Gagal mengunduh file: $e');
        }
      }
    } catch (e) {
      print('DEBUG: Error dalam penanganan dokumen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Tambahkan method untuk preload video
  void _preloadVideo(String videoUrl) {
    if (videoUrl.isEmpty) return;

    try {
      // Cek apakah URL menggunakan HTTP
      if (videoUrl.startsWith('http://')) {
        // Coba konversi ke HTTPS
        final httpsUrl = videoUrl.replaceFirst('http://', 'https://');
        try {
          final videoPlayerController = VideoPlayerController.network(
            httpsUrl,
            httpHeaders: {'Accept': '*/*', 'User-Agent': 'Mozilla/5.0'},
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
              allowBackgroundPlayback: false,
            ),
          );

          videoPlayerController
              .initialize()
              .then((_) {
                videoPlayerController.dispose();
              })
              .catchError((error) {
                print('Error preloading video with HTTPS: $error');
                // Jika HTTPS gagal, coba dengan HTTP
                _preloadVideoWithHttp(videoUrl);
              });
        } catch (e) {
          print('Error initializing HTTPS video controller: $e');
          _preloadVideoWithHttp(videoUrl);
        }
      } else {
        _preloadVideoWithHttp(videoUrl);
      }
    } catch (e) {
      print('Error in preloadVideo: $e');
    }
  }

  void _preloadVideoWithHttp(String videoUrl) {
    final videoPlayerController = VideoPlayerController.network(
      videoUrl,
      httpHeaders: {'Accept': '*/*', 'User-Agent': 'Mozilla/5.0'},
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
    );

    videoPlayerController
        .initialize()
        .then((_) {
          videoPlayerController.dispose();
        })
        .catchError((error) {
          print('Error preloading video with HTTP: $error');
        });
  }

  // Tambahkan method untuk mendapatkan path cache video
  Future<String> _getCachedVideoPath(String videoUrl) async {
    final dir = await getTemporaryDirectory();
    final fileName = path.basename(videoUrl);
    return path.join(dir.path, fileName);
  }

  // Tambahkan method untuk mengecek format video yang didukung
  bool _isSupportedVideoFormat(String url) {
    final supportedFormats = ['.mp4', '.webm', '.mov', '.avi', '.mkv'];
    return supportedFormats.any((format) => url.toLowerCase().endsWith(format));
  }

  // Tambahkan method untuk mendapatkan thumbnail path
  Future<String> _getThumbnailPath(String videoUrl) async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = path.basename(videoUrl);
      final thumbnailName = 'thumb_${fileName.split('.').first}.jpg';
      return path.join(dir.path, thumbnailName);
    } catch (e) {
      print('DEBUG: Error getting thumbnail path: $e');
      rethrow;
    }
  }

  // Update method generate thumbnail
  Future<String?> _generateThumbnail(String videoUrl) async {
    try {
      print('DEBUG: Memulai generate thumbnail untuk: $videoUrl');

      final thumbnailPath = await _getThumbnailPath(videoUrl);
      final thumbnailFile = File(thumbnailPath);

      // Cek apakah thumbnail sudah ada di cache
      if (await thumbnailFile.exists()) {
        print('DEBUG: Thumbnail sudah ada di cache');
        return thumbnailPath;
      }

      // Download video ke cache terlebih dahulu
      final cachedPath = await _getCachePath(path.basename(videoUrl));
      final cachedFile = File(cachedPath);

      if (!await cachedFile.exists()) {
        print('DEBUG: Download video untuk generate thumbnail');
        final dio = Dio();
        await dio.download(
          videoUrl,
          cachedPath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = (received / total * 100).toStringAsFixed(0);
              print('DEBUG: Progress download: $progress%');
            }
          },
        );
      }

      // Generate thumbnail menggunakan video_compress
      final thumbnailData = await VideoCompress.getByteThumbnail(
        cachedPath,
        quality: 50,
        position: -1, // -1 means get thumbnail from first frame
      );

      if (thumbnailData != null) {
        // Simpan thumbnail ke file
        await thumbnailFile.writeAsBytes(thumbnailData);
        print('DEBUG: Thumbnail berhasil disimpan ke: $thumbnailPath');
      }

      // Hapus file video dari cache setelah generate thumbnail
      await cachedFile.delete();

      return thumbnailPath;
    } catch (e) {
      print('DEBUG: Error generating thumbnail: $e');
      return null;
    }
  }

  // Modifikasi _buildVideoThumbnail untuk menggunakan thumbnail yang di-cache
  Widget _buildVideoThumbnail(
    BuildContext context,
    String? thumbnailUrl,
    String? mediaUrl,
  ) {
    if (mediaUrl != null) {
      // Preload video
      _preloadVideo(mediaUrl);

      // Generate thumbnail jika belum ada
      if (_cachedThumbnailPath == null) {
        _generateThumbnail(mediaUrl).then((path) {
          if (path != null && mounted) {
            setState(() {
              _cachedThumbnailPath = path;
            });
          }
        });
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(_defaultBorderRadius.r),
      child: Stack(
        children: [
          Container(
            width: 250.w,
            height: 250.w,
            color: Colors.grey[200],
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_cachedThumbnailPath != null)
                  Image.file(
                    File(_cachedThumbnailPath!),
                    fit: BoxFit.cover,
                    width: 250.w,
                    height: 250.w,
                    errorBuilder: (context, error, stackTrace) {
                      print('DEBUG: Error loading cached thumbnail: $error');
                      return _buildFallbackThumbnail(context);
                    },
                  )
                else if (thumbnailUrl != null)
                  CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 250,
                    memCacheHeight: 250,
                    maxWidthDiskCache: 250,
                    maxHeightDiskCache: 250,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    placeholder:
                        (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) {
                      return _buildFallbackThumbnail(context);
                    },
                  )
                else
                  _buildFallbackThumbnail(context),
              ],
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: _buildIcon(icon: Icons.play_arrow, size: 32.w),
              ),
            ),
          ),
          if (widget.message.mediaDuration != null &&
              widget.message.mediaDuration!.isNotEmpty)
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: _buildText(
                  text: _formatDuration(widget.message.mediaDuration!),
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
              ),
            ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: _buildIcon(icon: Icons.fullscreen, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Future<VideoPlayerController> _initializeVideoController(
    String videoUrl,
  ) async {
    try {
      // Cek apakah URL menggunakan HTTP
      if (videoUrl.startsWith('http://')) {
        // Coba konversi ke HTTPS
        final httpsUrl = videoUrl.replaceFirst('http://', 'https://');
        try {
          final controller = VideoPlayerController.network(
            httpsUrl,
            httpHeaders: {'Accept': '*/*', 'User-Agent': 'Mozilla/5.0'},
          );
          await controller.initialize();
          return controller;
        } catch (e) {
          print('DEBUG: Gagal menggunakan HTTPS, mencoba HTTP: $e');
        }
      }

      // Gunakan URL asli jika HTTPS gagal atau sudah HTTP
      final controller = VideoPlayerController.network(
        videoUrl,
        httpHeaders: {'Accept': '*/*', 'User-Agent': 'Mozilla/5.0'},
      );
      await controller.initialize();
      return controller;
    } catch (e) {
      print('DEBUG: Error initializing video controller: $e');
      rethrow;
    }
  }

  Widget _buildFallbackThumbnail(BuildContext context) {
    return Container(
      width: 250.w,
      height: 250.w,
      color: Colors.grey[200],
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.video_library, color: Colors.grey[400], size: 48.w),
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow, color: Colors.white, size: 32.w),
          ),
        ],
      ),
    );
  }

  final List<String> _reactions = [
    '👍',
    '👎',
    '❤️',
    '😂',
    '😮',
    '😢',
    '😡',
    '🙏',
    '👋',
    '🎉',
    '💪',
    '🤔',
    '😴',
    '🤮',
    '🤢',
    '🤡',
    '👻',
    '💀',
    '🤖',
    '👽',
    '👾',
    '🤖',
    '🤖',
    '🤖',
    '🤖',
    '🤖',
    '🤖',
    '🤖',
    '🤖',
    '🤖',
    '🤖',
    '🤖',
  ];

  Widget _buildMessageText(String text) {
    if (text.isEmpty) return SizedBox.shrink();

    List<TextSpan> spans = [];
    int currentIndex = 0;

    // Style dasar
    final baseStyle = TextStyle(
      fontSize: 14.sp,
      color: Colors.black87,
      height: 1.3,
      fontFamily: 'Noto Color Emoji',
    );

    // Regex untuk mendeteksi emoji
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F000}-\u{1F02F}\u{1F0A0}-\u{1F0FF}\u{1F100}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F900}-\u{1F9FF}]',
      unicode: true,
    );

    // Regex untuk mendeteksi mention
    final mentionRegex = RegExp(r'@(\w+)');

    // Regex untuk mendeteksi URL
    final urlRegex = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
    );

    while (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);

      // Cek format WhatsApp
      if (remainingText.startsWith('*')) {
        final boldEnd = remainingText.indexOf('*', 1);
        if (boldEnd != -1) {
          spans.add(
            TextSpan(
              text: remainingText.substring(1, boldEnd),
              style: baseStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          );
          currentIndex += boldEnd + 1;
          continue;
        }
      }

      if (remainingText.startsWith('_')) {
        final italicEnd = remainingText.indexOf('_', 1);
        if (italicEnd != -1) {
          spans.add(
            TextSpan(
              text: remainingText.substring(1, italicEnd),
              style: baseStyle.copyWith(fontStyle: FontStyle.italic),
            ),
          );
          currentIndex += italicEnd + 1;
          continue;
        }
      }

      if (remainingText.startsWith('~')) {
        final strikethroughEnd = remainingText.indexOf('~', 1);
        if (strikethroughEnd != -1) {
          spans.add(
            TextSpan(
              text: remainingText.substring(1, strikethroughEnd),
              style: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
            ),
          );
          currentIndex += strikethroughEnd + 1;
          continue;
        }
      }

      if (remainingText.startsWith('`')) {
        final codeEnd = remainingText.indexOf('`', 1);
        if (codeEnd != -1) {
          spans.add(
            TextSpan(
              text: remainingText.substring(1, codeEnd),
              style: baseStyle.copyWith(
                fontFamily: 'monospace',
                backgroundColor: Colors.grey[200],
                fontSize: 12.sp,
              ),
            ),
          );
          currentIndex += codeEnd + 1;
          continue;
        }
      }

      // Cek mention
      final mentionMatch = mentionRegex.firstMatch(remainingText);
      if (mentionMatch != null && mentionMatch.start == 0) {
        final mention = mentionMatch.group(1)!;
        spans.add(
          TextSpan(
            text: '@$mention',
            style: baseStyle.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        currentIndex += mentionMatch.end;
        continue;
      }

      // Cek URL
      final urlMatch = urlRegex.firstMatch(remainingText);
      if (urlMatch != null && urlMatch.start == 0) {
        final url = urlMatch.group(1)!;
        spans.add(
          TextSpan(
            text: url,
            style: baseStyle.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse(url));
                  },
          ),
        );
        currentIndex += urlMatch.end;
        continue;
      }

      // Cek emoji
      final emojiMatch = emojiRegex.firstMatch(remainingText);
      if (emojiMatch != null && emojiMatch.start == 0) {
        spans.add(
          TextSpan(
            text: emojiMatch.group(0),
            style: baseStyle.copyWith(
              fontSize: 16.sp,
              fontFamily: 'Noto Color Emoji',
            ),
          ),
        );
        currentIndex += emojiMatch.end;
        continue;
      }

      // Jika tidak ada format, tambahkan teks biasa
      spans.add(TextSpan(text: remainingText[0], style: baseStyle));
      currentIndex++;
    }

    return RichText(
      text: TextSpan(children: spans),
      overflow: TextOverflow.visible,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final myBubbleColor = widget.isMe ? Color(0xFFDCF8C6) : Colors.white;
    final myTextColor = Colors.black87;

    return GestureDetector(
      onLongPress: () => _showMessageActions(context),
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          constraints: BoxConstraints(maxWidth: 0.75.sw),
          child: Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!widget.isMe && widget.message.fromMe == false)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h, left: 8.w),
                  child: Text(
                    widget.message.contact?.name ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: myBubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    topRight: Radius.circular(8.r),
                    bottomLeft: Radius.circular(widget.isMe ? 8.r : 0),
                    bottomRight: Radius.circular(widget.isMe ? 0 : 8.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Jika ini adalah pesan teks biasa
                    if (widget.message.messageType == 'conversation' ||
                        widget.message.messageType ==
                            'extendedTextMessage') ...[
                      if (widget.message.body != null &&
                          widget.message.body!.isNotEmpty)
                        _buildMessageText(widget.message.body!),
                      if (widget.message.linkPreview != null)
                        _buildLinkPreview(widget.message.linkPreview!),
                    ] else if (widget.message.voiceMessage != null) ...[
                      _buildVoiceMessage(widget.message.voiceMessage!),
                    ] else if (widget.message.poll != null) ...[
                      _buildPoll(widget.message.poll!),
                    ] else ...[
                      // Untuk tipe pesan lainnya
                      if (widget.message.mediaType != null) ...[
                        _buildMediaContent(context),
                        if (widget.message.body != null &&
                            widget.message.body!.isNotEmpty)
                          SizedBox(height: 8.h),
                      ],
                      if (widget.message.body != null &&
                          widget.message.body!.isNotEmpty)
                        _buildMessageText(widget.message.body!),
                    ],
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.message.createdAt != null)
                          Text(
                            DateFormat(
                              'HH:mm',
                            ).format(widget.message.createdAt!),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black54,
                            ),
                          ),
                        if (widget.isMe) ...[
                          SizedBox(width: 4.w),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: Icon(
                              key: ValueKey(widget.message.status),
                              widget.message.status == 'READ'
                                  ? Icons.done_all
                                  : widget.message.status == 'DELIVERED'
                                  ? Icons.done_all
                                  : widget.message.status == 'SENT'
                                  ? Icons.done
                                  : Icons.schedule,
                              size: 16.sp,
                              color:
                                  widget.message.status == 'READ'
                                      ? Colors.blue
                                      : widget.message.status == 'DELIVERED'
                                      ? Colors.grey[600]
                                      : widget.message.status == 'SENT'
                                      ? Colors.black54
                                      : Colors.grey[400],
                            ),
                          ),
                        ],
                        if (widget.message.reactions != null &&
                            widget.message.reactions!.isNotEmpty) ...[
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: () => _showReactionPicker(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...widget.message.reactions!
                                      .map(
                                        (r) => Text(
                                          r.emoji,
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      )
                                      .toList(),
                                  if (widget.message.reactions!.length > 1)
                                    Text(
                                      ' ${widget.message.reactions!.length}',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDocumentTypeText(String fileName) {
    print('DEBUG: Memulai _getDocumentTypeText dengan fileName: $fileName');

    // Jika fileName kosong, coba ekstrak dari URL
    if (fileName.isEmpty && widget.message.mediaUrl != null) {
      fileName = widget.message.mediaUrl!.split('/').last;
      print('DEBUG: Mengekstrak nama file dari URL: $fileName');
    }

    if (fileName.isEmpty) {
      print('DEBUG: fileName kosong, mengembalikan "Dokumen"');
      return 'Dokumen';
    }

    // Cek ekstensi file dari URL jika tersedia
    String extension = '';
    if (widget.message.mediaUrl != null) {
      extension = widget.message.mediaUrl!.split('.').last.toLowerCase();
      print('DEBUG: Ekstensi dari URL: $extension');
    }

    // Jika tidak ada ekstensi dari URL, cek dari nama file
    if (extension.isEmpty) {
      extension = fileName.split('.').last.toLowerCase();
      print('DEBUG: Ekstensi dari nama file: $extension');
    }

    print('DEBUG: Ekstensi file yang digunakan: $extension');

    String result;
    switch (extension) {
      case 'pdf':
        result = 'PDF Document';
        break;
      case 'doc':
      case 'docx':
        result = 'Word Document';
        break;
      case 'xls':
      case 'xlsx':
        result = 'Excel Spreadsheet';
        break;
      case 'ppt':
      case 'pptx':
        result = 'PowerPoint Presentation';
        break;
      case 'txt':
      case 'md':
      case 'markdown':
      case 'rtf':
        result = 'Text Document';
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
      case 'svg':
        result = 'Image File';
        break;
      case 'mp3':
      case 'wav':
      case 'ogg':
      case 'm4a':
      case 'aac':
        result = 'Audio File';
        break;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
      case 'webm':
        result = 'Video File';
        break;
      case 'zip':
      case 'rar':
      case '7z':
        result = 'Archive File';
        break;
      default:
        result = 'Document';
    }

    print('DEBUG: Mengembalikan tipe dokumen: $result');
    return result;
  }

  Widget _buildMediaContent(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = widget.message.fromMe ?? false;

    // Jika ini adalah dokumen PDF
    if (widget.message.messageType == 'documentMessage' ||
        (widget.message.mediaType == 'application' &&
            widget.message.mediaUrl?.toLowerCase().endsWith('.pdf') == true)) {
      return GestureDetector(
        onTap:
            _isDownloaded && _localFilePath != null
                ? () async {
                  final result = await OpenFile.open(_localFilePath!);
                  if (result.type != ResultType.done) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tidak dapat membuka file: ${result.message}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                : null,
        child: Container(
          width: 250.w,
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: widget.message.fromMe ? Color(0xFFDCF8C6) : Colors.white,
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(
              color:
                  widget.message.fromMe ? Color(0xFFDCF8C6) : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getDocumentIcon(widget.message.mediaName ?? ''),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.mediaName ?? '',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _getDocumentTypeText(widget.message.mediaName ?? ''),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isDownloaded)
                    IconButton(
                      icon: Icon(Icons.download, size: 20.w),
                      onPressed:
                          () => _handleDocumentAction(
                            context,
                            widget.message.mediaUrl!,
                            widget.message.mediaName!,
                          ),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.open_in_new, size: 20.w),
                      onPressed: () async {
                        final result = await OpenFile.open(_localFilePath!);
                        if (result.type != ResultType.done) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tidak dapat membuka file: ${result.message}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (widget.message.mediaType == null || widget.message.mediaType!.isEmpty) {
      return SizedBox.shrink();
    }

    switch (widget.message.mediaType!.toLowerCase()) {
      case 'image':
        return GestureDetector(
          onTap: () {
            if (widget.message.mediaUrl != null) {
              _showImagePreview(context, widget.message.mediaUrl!);
            }
          },
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Stack(
              children: [
                // Low resolution image (blur-up)
                if (widget.message.thumbnailUrl != null)
                  CachedNetworkImage(
                    imageUrl: widget.message.thumbnailUrl!,
                    width: 250.w,
                    height: 250.w,
                    fit: BoxFit.cover,
                    memCacheWidth: 100,
                    memCacheHeight: 100,
                    maxWidthDiskCache: 100,
                    maxHeightDiskCache: 100,
                    fadeInDuration: Duration(milliseconds: 0),
                    fadeOutDuration: Duration(milliseconds: 0),
                    imageBuilder:
                        (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                  ),
                // High resolution image
                CachedNetworkImage(
                  imageUrl: widget.message.mediaUrl ?? '',
                  width: 250.w,
                  height: 250.w,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  memCacheHeight: 800,
                  maxWidthDiskCache: 800,
                  maxHeightDiskCache: 800,
                  fadeInDuration: Duration(milliseconds: 300),
                  fadeOutDuration: Duration(milliseconds: 300),
                  placeholder:
                      (context, url) => Container(
                        width: 250.w,
                        height: 250.w,
                        color: Colors.grey[200],
                        child: Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        width: 250.w,
                        height: 250.w,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 32.w,
                        ),
                      ),
                  imageBuilder:
                      (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 'video':
        return GestureDetector(
          onTap: () {
            if (widget.message.mediaUrl != null) {
              _showVideoPlayer(context, widget.message.mediaUrl!);
            }
          },
          child: _buildVideoThumbnail(
            context,
            widget.message.thumbnailUrl,
            widget.message.mediaUrl,
          ),
        );
      case 'audio':
        return Container(
          width: 250.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isMe ? Color(0xFFE8F5E9) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isMe ? theme.colorScheme.primary : Colors.grey[600],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 20.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.mediaDuration != null &&
                        widget.message.mediaDuration!.isNotEmpty)
                      Text(
                        widget.message.mediaDuration!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color:
                              isMe
                                  ? theme.colorScheme.primary
                                  : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    SizedBox(height: 4.h),
                    LinearProgressIndicator(
                      value: 0.5,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isMe ? theme.colorScheme.primary : Colors.grey[600]!,
                      ),
                      minHeight: 2.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'document':
        final fileName = widget.message.mediaName ?? '';
        final mediaUrl = widget.message.mediaUrl ?? '';

        // Debug print untuk memeriksa informasi file
        print('DEBUG: Menampilkan dokumen');
        print('DEBUG: Nama file: $fileName');
        print('DEBUG: Media URL: $mediaUrl');
        print('DEBUG: Media Type: ${widget.message.mediaType}');
        print('DEBUG: Message Type: ${widget.message.messageType}');
        print('DEBUG: Data JSON: ${widget.message.dataJson}');

        return GestureDetector(
          onTap:
              _isDownloaded && _localFilePath != null
                  ? () async {
                    final result = await OpenFile.open(_localFilePath!);
                    if (result.type != ResultType.done) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tidak dapat membuka file: ${result.message}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                  : null,
          child: Container(
            width: 250.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: widget.message.fromMe ? Color(0xFFDCF8C6) : Colors.white,
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(
                color:
                    widget.message.fromMe
                        ? Color(0xFFDCF8C6)
                        : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getDocumentIcon(fileName),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _getDocumentTypeText(fileName),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isDownloaded)
                      IconButton(
                        icon: Icon(Icons.download, size: 20.w),
                        onPressed:
                            () => _handleDocumentAction(
                              context,
                              mediaUrl,
                              fileName,
                            ),
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.open_in_new, size: 20.w),
                        onPressed: () async {
                          final result = await OpenFile.open(_localFilePath!);
                          if (result.type != ResultType.done) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Tidak dapat membuka file: ${result.message}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      case 'location':
        return GestureDetector(
          onTap: () {
            // TODO: Implement location preview
          },
          child: Container(
            width: 250.w,
            height: 150.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Stack(
              children: [
                // TODO: Implement map preview
                Center(
                  child: Icon(Icons.map, color: Colors.grey[400], size: 48.w),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 20.w),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.message.locationName != null &&
                                  widget.message.locationName!.isNotEmpty)
                                Text(
                                  widget.message.locationName!,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (widget.message.latitude != null &&
                                  widget.message.longitude != null)
                                Text(
                                  '${widget.message.latitude}, ${widget.message.longitude}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 'contact':
        return Container(
          width: 250.w,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isMe ? Color(0xFFE8F5E9) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              if (widget.message.contact?.profilePicUrl != null)
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: NetworkImage(
                    widget.message.contact!.profilePicUrl!,
                  ),
                )
              else
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor:
                      isMe ? theme.colorScheme.primary : Colors.grey[600],
                  child: Text(
                    widget.message.contact?.name
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        '?',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.contact?.name != null &&
                        widget.message.contact!.name!.isNotEmpty)
                      Text(
                        widget.message.contact!.name!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color:
                              isMe
                                  ? theme.colorScheme.primary
                                  : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (widget.message.contact?.number != null &&
                        widget.message.contact!.number!.isNotEmpty)
                      Text(
                        widget.message.contact!.number!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color:
                              isMe
                                  ? theme.colorScheme.primary.withOpacity(0.7)
                                  : Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _getDocumentIcon(String fileName) {
    // Debug print untuk memeriksa informasi file
    print('DEBUG: Memeriksa file: $fileName');
    print('DEBUG: Media URL: ${widget.message.mediaUrl}');
    print('DEBUG: Media Type: ${widget.message.mediaType}');

    // Jika nama file kosong, coba ekstrak dari URL
    if (fileName.isEmpty && widget.message.mediaUrl != null) {
      fileName = widget.message.mediaUrl!.split('/').last;
      print('DEBUG: Mengekstrak nama file dari URL: $fileName');
    }

    if (fileName.isEmpty) {
      print('DEBUG: Nama file kosong, menggunakan icon default');
      return Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Color(0xFF90A4AE),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.insert_drive_file, color: Colors.white, size: 20.w),
      );
    }

    // Cek ekstensi file dari URL jika tersedia
    String extension = '';
    if (widget.message.mediaUrl != null) {
      extension = widget.message.mediaUrl!.split('.').last.toLowerCase();
      print('DEBUG: Ekstensi dari URL: $extension');
    }

    // Jika tidak ada ekstensi dari URL, cek dari nama file
    if (extension.isEmpty) {
      extension = fileName.split('.').last.toLowerCase();
      print('DEBUG: Ekstensi dari nama file: $extension');
    }

    print('DEBUG: Ekstensi file yang digunakan: $extension');

    // Container untuk ikon dengan warna latar belakang yang sesuai
    Widget getIconContainer(IconData icon, Color color) {
      return Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20.w),
      );
    }

    // Khusus untuk PDF
    if (extension == 'pdf') {
      print('DEBUG: Menggunakan icon PDF');
      return getIconContainer(Icons.picture_as_pdf, Color(0xFFE57373));
    }

    // Khusus untuk dokumen Office
    if (['doc', 'docx'].contains(extension)) {
      print('DEBUG: Menggunakan icon Word');
      return getIconContainer(Icons.description, Color(0xFF64B5F6));
    }
    if (['xls', 'xlsx'].contains(extension)) {
      print('DEBUG: Menggunakan icon Excel');
      return getIconContainer(Icons.table_chart, Color(0xFF81C784));
    }
    if (['ppt', 'pptx'].contains(extension)) {
      print('DEBUG: Menggunakan icon PowerPoint');
      return getIconContainer(Icons.slideshow, Color(0xFFFFB74D));
    }

    // Khusus untuk file teks
    if (['txt', 'md', 'markdown', 'rtf'].contains(extension)) {
      print('DEBUG: Menggunakan icon Text');
      return getIconContainer(Icons.text_snippet, Color(0xFF90A4AE));
    }

    // Khusus untuk file gambar
    if ([
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'svg',
    ].contains(extension)) {
      print('DEBUG: Menggunakan icon Image');
      return getIconContainer(Icons.image, Color(0xFF4DB6AC));
    }

    // Khusus untuk file audio
    if (['mp3', 'wav', 'ogg', 'm4a', 'aac'].contains(extension)) {
      print('DEBUG: Menggunakan icon Audio');
      return getIconContainer(Icons.audio_file, Color(0xFF7986CB));
    }

    // Khusus untuk file video
    if (['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(extension)) {
      print('DEBUG: Menggunakan icon Video');
      return getIconContainer(Icons.video_file, Color(0xFFF06292));
    }

    // Khusus untuk file arsip
    if (['zip', 'rar', '7z'].contains(extension)) {
      print('DEBUG: Menggunakan icon Archive');
      return getIconContainer(Icons.folder_zip, Color(0xFFBA68C8));
    }

    print('DEBUG: Menggunakan icon default untuk ekstensi: $extension');
    return getIconContainer(Icons.insert_drive_file, Color(0xFF90A4AE));
  }

  Widget _buildLinkPreview(LinkPreview preview) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (preview.image != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              child: CachedNetworkImage(
                imageUrl: preview.image!,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (preview.title != null)
                  Text(
                    preview.title!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (preview.description != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    preview.description!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 4.h),
                Text(
                  preview.url!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(VoiceMessage voiceMessage) {
    return Container(
      width: 250.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: widget.message.fromMe ? Color(0xFFE8F5E9) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color:
                  widget.message.fromMe
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow, color: Colors.white, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${voiceMessage.duration.toStringAsFixed(1)}s',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color:
                        widget.message.fromMe
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  height: 20.h,
                  child: CustomPaint(
                    painter: WaveformPainter(
                      waveform: voiceMessage.waveform,
                      color:
                          widget.message.fromMe
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600]!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoll(Poll poll) {
    return Container(
      width: 250.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: widget.message.fromMe ? Color(0xFFE8F5E9) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          ...poll.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final votes =
                poll.votes.where((v) => v.optionIndex == index).length;
            final totalVotes = poll.votes.length;
            final percentage =
                totalVotes > 0 ? (votes / totalVotes) * 100 : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(option, style: TextStyle(fontSize: 13.sp)),
                    ),
                    Text(
                      '$votes votes',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.message.fromMe
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600]!,
                  ),
                  minHeight: 4.h,
                ),
                SizedBox(height: 8.h),
              ],
            );
          }).toList(),
          Text(
            '${poll.votes.length} votes • Ends ${DateFormat('MMM d, y').format(poll.endDate)}',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatDuration(String duration) {
    try {
      // Konversi durasi dari detik ke format MM:SS
      final seconds = int.parse(duration);
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error formatting duration: $e');
      return duration; // Return original duration if parsing fails
    }
  }

  void _showVideoPlayer(BuildContext context, String videoUrl) {
    print('DEBUG: Memulai _showVideoPlayer dengan URL: $videoUrl');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WillPopScope(
              onWillPop: () async {
                print('DEBUG: WillPopScope dipanggil');
                return true;
              },
              child: Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  automaticallyImplyLeading: false,
                ),
                body: Center(
                  child: FutureBuilder(
                    future: _initializeVideoPlayer(videoUrl),
                    builder: (context, snapshot) {
                      print(
                        'DEBUG: FutureBuilder state: ${snapshot.connectionState}',
                      );
                      print(
                        'DEBUG: FutureBuilder hasData: ${snapshot.hasData}',
                      );
                      print(
                        'DEBUG: FutureBuilder hasError: ${snapshot.hasError}',
                      );
                      if (snapshot.hasError) {
                        print(
                          'DEBUG: Error dalam FutureBuilder: ${snapshot.error}',
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        print(
                          'DEBUG: Menampilkan loading indicator - ConnectionState.waiting',
                        );
                        return CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        print('DEBUG: Menampilkan error state');
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48.w,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Error loading video',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Please check your internet connection',
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () {
                                print('DEBUG: Tombol retry ditekan');
                                Navigator.pop(context);
                                _showVideoPlayer(context, videoUrl);
                              },
                              child: Text('Retry'),
                            ),
                          ],
                        );
                      }

                      if (snapshot.data == null) {
                        print(
                          'DEBUG: Menampilkan loading indicator - data null',
                        );
                        return CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        );
                      }

                      print('DEBUG: Video player berhasil diinisialisasi');
                      final chewieController = snapshot.data!;

                      // Tambahkan listener untuk mendeteksi ketika video selesai
                      chewieController.videoPlayerController.addListener(() {
                        final value =
                            chewieController.videoPlayerController.value;
                        if (value.position >= value.duration &&
                            value.duration > Duration.zero &&
                            !value.isPlaying &&
                            value.isInitialized) {
                          print('DEBUG: Video selesai, menutup player');
                          // Dispose controller sebelum menutup
                          chewieController.dispose();
                          Navigator.pop(context);
                        }
                      });

                      return Stack(
                        children: [
                          Chewie(controller: chewieController),
                          // Tombol close di overlay
                          Positioned(
                            top: 16.h,
                            right: 16.w,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                print('DEBUG: Tombol close ditekan');
                                chewieController.dispose();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Future<ChewieController> _initializeVideoPlayer(String videoUrl) async {
    print('DEBUG: Memulai inisialisasi video player');
    try {
      if (!_isSupportedVideoFormat(videoUrl)) {
        throw Exception('Format video tidak didukung');
      }

      final cachedPath = await _getCachePath(path.basename(videoUrl));
      final file = File(cachedPath);

      VideoPlayerController videoPlayerController;

      if (await file.exists()) {
        print('DEBUG: Menggunakan video dari cache');
        videoPlayerController = VideoPlayerController.file(file);
      } else {
        print('DEBUG: Download video baru');
        videoPlayerController = VideoPlayerController.network(
          videoUrl,
          httpHeaders: {
            'Accept': '*/*',
            'User-Agent': 'Mozilla/5.0',
            'Range': 'bytes=0-',
          },
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );

        // Download dengan progress
        final dio = Dio();
        await dio.download(
          videoUrl,
          cachedPath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = (received / total * 100).toStringAsFixed(0);
              print('DEBUG: Progress download: $progress%');
            }
          },
        );
      }

      // Inisialisasi controller dengan timeout
      await videoPlayerController.initialize().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Video initialization timeout');
        },
      );

      final aspectRatio = videoPlayerController.value.aspectRatio;

      return ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showOptions: true,
        allowPlaybackSpeedChanging: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48.w),
                SizedBox(height: 16.h),
                Text(
                  'Error: $errorMessage',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showVideoPlayer(context, videoUrl);
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('DEBUG: Error fatal dalam _initializeVideoPlayer: $e');
      throw Exception('Failed to initialize video player: $e');
    }
  }

  // Tambahkan method untuk mengecek dan membersihkan cache
  Future<void> _cleanupCache() async {
    try {
      final dir = await getTemporaryDirectory();
      final cacheDir = Directory(dir.path);
      if (await cacheDir.exists()) {
        final files = await cacheDir.list().toList();
        final now = DateTime.now();

        for (var file in files) {
          if (file is File) {
            final stat = await file.stat();
            final age = now.difference(stat.modified);
            // Hapus file yang lebih tua dari 7 hari
            if (age.inDays > 7) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      print('DEBUG: Error cleaning cache: $e');
    }
  }

  // Optimasi untuk gambar
  Widget _buildOptimizedImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 250.w,
      height: 250.w,
      fit: BoxFit.cover,
      memCacheWidth: 800,
      memCacheHeight: 800,
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 800,
      fadeInDuration: Duration(milliseconds: 300),
      fadeOutDuration: Duration(milliseconds: 300),
      placeholder:
          (context, url) => Container(
            width: 250.w,
            height: 250.w,
            color: Colors.grey[200],
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
      errorWidget:
          (context, url, error) => Container(
            width: 250.w,
            height: 250.w,
            color: Colors.grey[200],
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: 32.w,
            ),
          ),
      imageBuilder:
          (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
    );
  }

  // Helper method untuk membangun icon
  Widget _buildIcon({
    required IconData icon,
    required double size,
    Color? color,
  }) {
    return Icon(icon, color: color ?? Colors.white, size: size);
  }

  // Helper method untuk membangun text
  Widget _buildText({required String text, required TextStyle style}) {
    return Text(text, style: style);
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final Color color;

  WaveformPainter({required this.waveform, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    final barWidth = width / waveform.length;
    final maxAmplitude = waveform.reduce((a, b) => a > b ? a : b);

    for (var i = 0; i < waveform.length; i++) {
      final amplitude = waveform[i];
      final barHeight = (amplitude / maxAmplitude) * height;
      final x = i * barWidth;
      final y = (height - barHeight) / 2;

      canvas.drawLine(Offset(x, y), Offset(x, y + barHeight), paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveform != waveform || oldDelegate.color != color;
  }
}
