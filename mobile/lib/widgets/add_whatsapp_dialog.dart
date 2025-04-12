import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddWhatsAppDialog extends StatefulWidget {
  final Function(String) onAdd;

  const AddWhatsAppDialog({super.key, required this.onAdd});

  @override
  State<AddWhatsAppDialog> createState() => _AddWhatsAppDialogState();
}

class _AddWhatsAppDialogState extends State<AddWhatsAppDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tambah Koneksi WhatsApp',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Koneksi',
                  hintText: 'Masukkan nama koneksi',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama koneksi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onAdd(_nameController.text);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
