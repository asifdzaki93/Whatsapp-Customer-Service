const messages = {
    en: {
        translations: {
            signup: {
                title: "Daftar",
                toasts: {
                    success: "Pengguna berhasil dibuat! Silakan masuk!",
                    fail: "Gagal membuat pengguna. Periksa data yang dilaporkan.",
                },
                form: {
                    name: "Nama",
                    email: "Email",
                    password: "Kata Sandi",
                },
                buttons: {
                    submit: "Daftar",
                    login: "Sudah punya akun? Masuk!",
                },
            },
            login: {
                title: "Masuk",
                form: {
                    email: "Email",
                    password: "Kata Sandi",
                },
                buttons: {
                    submit: "Masuk",
                    register: "Belum punya akun? Daftar!",
                },
            },
            plans: {
                form: {
                    name: "Nama",
                    users: "Pengguna",
                    connections: "Koneksi",
                    campaigns: "Kampanye",
                    schedules: "Jadwal",
                    enabled: "Diaktifkan",
                    disabled: "Dinonaktifkan",
                    clear: "Batal",
                    delete: "Hapus",
                    save: "Simpan",
                    yes: "Ya",
                    no: "Tidak",
                    money: "Rp",
                },
            },
            companies: {
                title: "Daftar Perusahaan",
                form: {
                    name: "Nama Perusahaan",
                    plan: "Paket",
                    token: "Token",
                    submit: "Daftar",
                    success: "Perusahaan berhasil dibuat!",
                },
            },
            auth: {
                toasts: {
                    success: "Berhasil masuk!",
                },
                token: "Token",
            },
            dashboard: {
                charts: {
                    perDay: {
                        title: "Tiket hari ini: ",
                    },
                },
            },
            connections: {
                title: "Koneksi",
                toasts: {
                    deleted: "Koneksi WhatsApp berhasil dihapus!",
                },
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteMessage: "Anda yakin? Tindakan ini tidak dapat dibatalkan.",
                    disconnectTitle: "Putuskan",
                    disconnectMessage: "Anda yakin? Anda perlu membaca QR Code lagi.",
                },
                buttons: {
                    add: "Tambah WhatsApp",
                    disconnect: "Putuskan",
                    tryAgain: "Coba Lagi",
                    qrcode: "QR CODE",
                    newQr: "QR CODE Baru",
                    connecting: "Menghubungkan",
                },
                toolTips: {
                    disconnected: {
                        title: "Gagal memulai sesi WhatsApp",
                        content: "Pastikan ponsel Anda terhubung ke internet dan coba lagi, atau minta QR Code baru",
                    },
                    qrcode: {
                        title: "Menunggu pembacaan QR Code",
                        content: "Klik tombol 'QR CODE' dan baca QR Code dengan ponsel Anda untuk memulai sesi",
                    },
                    connected: {
                        title: "Koneksi berhasil!",
                    },
                    timeout: {
                        title: "Koneksi dengan ponsel terputus",
                        content: "Pastikan ponsel Anda terhubung ke internet dan WhatsApp terbuka, atau klik tombol 'Putuskan' untuk mendapatkan QR Code baru",
                    },
                },
                table: {
                    name: "Nama",
                    status: "Status",
                    lastUpdate: "Pembaruan Terakhir",
                    default: "Default",
                    actions: "Tindakan",
                    session: "Sesi",
                },
            },
            whatsappModal: {
                title: {
                    add: "Tambah WhatsApp",
                    edit: "Edit WhatsApp",
                },
                form: {
                    name: "Nama",
                    default: "Default",
                    sendIdQueue: "Antrian",
                    timeSendQueue: "Alihkan ke antrian dalam X menit",
                    queueRedirection: "Pengalihan Antrian",
                    queueRedirectionDesc: "Pilih antrian untuk kontak yang tidak memiliki antrian untuk dialihkan",
                    prompt: "Prompt",
                    maxUseBotQueues: "Kirim bot x kali",
                    timeUseBotQueues: "Interval dalam menit antara pengiriman bot",
                    expiresTicket: "Tutup chat terbuka setelah x menit",
                    expiresInactiveMessage: "Pesan penutupan karena tidak aktif",
                },
                buttons: {
                    okAdd: "Tambah",
                    okEdit: "Simpan",
                    cancel: "Batal",
                },
                success: "WhatsApp berhasil disimpan.",
            },
            qrCode: {
                message: "Baca QR Code untuk memulai sesi",
            },
            contacts: {
                title: "Kontak",
                toasts: {
                    deleted: "Kontak berhasil dihapus!",
                },
                searchPlaceholder: "Cari...",
                confirmationModal: {
                    deleteTitle: "Hapus",
                    importTitlte: "Impor kontak",
                    deleteMessage: "Anda yakin ingin menghapus kontak ini? Semua tiket terkait akan hilang.",
                    importMessage: "Apakah Anda ingin mengimpor semua kontak dari ponsel?",
                },
                buttons: {
                    import: "Impor Kontak",
                    add: "Tambah",
                },
                table: {
                    name: "Nama",
                    whatsapp: "WhatsApp",
                    email: "Email",
                    actions: "Tindakan",
                },
            },
            queueIntegrationModal: {
                title: {
                    add: "Tambah Proyek",
                    edit: "Edit Proyek",
                },
                form: {
                    id: "ID",
                    type: "Tipe",
                    name: "Nama",
                    projectName: "Nama Proyek",
                    language: "Bahasa",
                    jsonContent: "Konten Json",
                    urlN8N: "URL",
                    typebotSlug: "Typebot - Slug",
                    typebotExpires: "Waktu kedaluwarsa percakapan (menit)",
                    typebotKeywordFinish: "Kata kunci untuk mengakhiri tiket",
                    typebotKeywordRestart: "Kata kunci untuk memulai ulang",
                    typebotRestartMessage: "Pesan saat memulai ulang percakapan",
                    typebotUnknownMessage: "Pesan opsi tidak valid",
                    typebotDelayMessage: "Jeda antar pesan (ms)",
                },
                buttons: {
                    okAdd: "Tambah",
                    okEdit: "Simpan",
                    cancel: "Batal",
                    test: "Tes Bot",
                },
                messages: {
                    testSuccess: "Integrasi berhasil diuji!",
                    addSuccess: "Integrasi berhasil ditambahkan.",
                    editSuccess: "Integrasi berhasil diperbarui.",
                },
            },
            promptModal: {
                form: {
                    name: "Nama",
                    prompt: "Prompt",
                    voice: "Suara",
                    max_tokens: "Maksimum Token dalam jawaban",
                    temperature: "Temperatur",
                    apikey: "API Key",
                    max_messages: "Maksimum Pesan dalam Riwayat",
                    voiceKey: "Kunci API Suara",
                    voiceRegion: "Region Suara",
                },
                success: "Prompt berhasil disimpan!",
                title: {
                    add: "Tambah Prompt",
                    edit: "Edit Prompt",
                },
                buttons: {
                    okAdd: "Tambah",
                    okEdit: "Simpan",
                    cancel: "Batal",
                },
            },
            prompts: {
                title: "Prompt",
                table: {
                    name: "Nama",
                    queue: "Sektor/Antrian",
                    max_tokens: "Maksimum Token Jawaban",
                    actions: "Tindakan",
                },
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteMessage: "Anda yakin? Tindakan ini tidak dapat dibatalkan!",
                },
                buttons: {
                    add: "Tambah Prompt",
                },
            },
            contactModal: {
                title: {
                    add: "Tambah",
                    edit: "Edit Kontak",
                },
                form: {
                    mainInfo: "Detail Kontak",
                    extraInfo: "Informasi Tambahan",
                    name: "Nama",
                    number: "Nomor WhatsApp",
                    email: "Email",
                    extraName: "Nama Field",
                    extraValue: "Nilai",
                    whatsapp: "Koneksi Asal: ",
                    ignore: "Abaikan pesan: ",
                },
                buttons: {
                    addExtraInfo: "Tambah Informasi",
                    okAdd: "Tambah",
                    okEdit: "Simpan",
                    cancel: "Batal",
                },
                success: "Kontak berhasil disimpan.",
            },
            queueModal: {
                title: {
                    add: "Tambah Antrian",
                    edit: "Edit Antrian",
                },
                form: {
                    name: "Nama",
                    color: "Warna",
                    greetingMessage: "Pesan Sambutan",
                    complationMessage: "Pesan Selesai",
                    outOfHoursMessage: "Pesan Di Luar Jam Kerja",
                    ratingMessage: "Pesan Penilaian",
                    token: "Token",
                    orderQueue: "Urutan Antrian (Bot)",
                    integrationId: "Integrasi",
                },
                buttons: {
                    okAdd: "Tambah",
                    okEdit: "Simpan",
                    cancel: "Batal",
                },
            },
            userModal: {
                title: {
                    add: "Tambah Pengguna",
                    edit: "Edit Pengguna",
                },
                form: {
                    name: "Nama",
                    email: "Email",
                    password: "Kata Sandi",
                    profile: "Profil",
                    whatsapp: "Koneksi Default",
                },
                buttons: {
                    okAdd: "Tambah",
                    okEdit: "Simpan",
                    cancel: "Batal",
                },
                success: "Pengguna berhasil disimpan.",
            },
            scheduleModal: {
                title: {
                    add: "Jadwal Baru",
                    edit: "Edit Jadwal",
                },
                form: {
                    body: "Pesan",
                    contact: "Kontak",
                    sendAt: "Tanggal Jadwal",
                    sentAt: "Tanggal Kirim",
                },
                buttons: {
                    okAdd: "Tambah",
                    okEdit: "Simpan",
                    cancel: "Batal",
                },
                success: "Jadwal berhasil disimpan.",
            },
            tagModal: {
                title: {
                    add: "Tag Baru",
                    edit: "Edit Tag",
                },
                form: {
                    name: "Nama",
                    color: "Warna",
                },
                buttons: {
                    okAdd: "Tambah",
                    okEdit: "Simpan",
                    cancel: "Batal",
                },
                success: "Tag berhasil disimpan.",
            },
            chat: {
                noTicketMessage: "Pilih tiket untuk memulai percakapan.",
            },
            uploads: {
                titles: {
                    titleUploadMsgDragDrop: "SERET DAN LEPAS FILE DI AREA INI",
                    titleFileList: "Daftar File",
                },
            },
            ticketsManager: {
                buttons: {
                    newTicket: "Baru",
                },
            },
            ticketsQueueSelect: {
                placeholder: "Antrian",
            },
            tickets: {
                toasts: {
                    deleted: "Tiket yang Anda tangani telah dihapus.",
                },
                notification: {
                    message: "Pesan dari",
                },
                tabs: {
                    open: { title: "Terbuka" },
                    closed: { title: "Selesai" },
                    search: { title: "Cari" },
                },
                search: {
                    placeholder: "Cari tiket & pesan",
                },
                buttons: {
                    showAll: "Semua",
                },
            },
            transferTicketModal: {
                title: "Transfer Tiket",
                fieldLabel: "Ketik untuk mencari pengguna",
                fieldQueueLabel: "Transfer ke antrian",
                fieldQueuePlaceholder: "Pilih antrian",
                noOptions: "Tidak ada pengguna ditemukan dengan nama tersebut",
                buttons: {
                    ok: "Transfer",
                    cancel: "Batal",
                },
            },
            ticketsList: {
                pendingHeader: "Menunggu",
                assignedHeader: "Dilayani",
                noTicketsTitle: "Tidak Ada!",
                noTicketsMessage: "Tidak ada tiket ditemukan dengan status atau kata kunci Cari ini.",
                buttons: {
                    accept: "Terima",
                    closed: "Selesai",
                    reopen: "Buka Kembali",
                },
            },
            newTicketModal: {
                title: "Buat Tiket",
                fieldLabel: "Ketik untuk mencari kontak",
                add: "Tambah",
                buttons: {
                    ok: "Simpan",
                    cancel: "Batal",
                },
            },
            mainDrawer: {
                listItems: {
                    dashboard: "Dasbor",
                    connections: "Koneksi",
                    tickets: "Tiket",
                    quickMessages: "Pesan Cepat",
                    contacts: "Kontak",
                    queues: "Antrian & Chatbot",
                    tags: "Tag",
                    administration: "Administrasi",
                    users: "Pengguna",
                    settings: "Pengaturan",
                    helps: "Bantuan",
                    messagesAPI: "API",
                    schedules: "Jadwal",
                    campaigns: "Kampanye",
                    annoucements: "Pengumuman",
                    chats: "Chat Internal",
                    financeiro: "Keuangan",
                    files: "Daftar File",
                    prompts: "Open.Ai",
                    queueIntegration: "Integrasi",
                },
                appBar: {
                    user: {
                        profile: "Profil",
                        logout: "Keluar",
                        notRegister: "No messages registered",
                    },
                },
            },            
            queueIntegration: {
                title: "Integrasi",
                table: {
                    id: "ID",
                    type: "Tipe",
                    name: "Nama",
                    projectName: "Nama Proyek",
                    language: "Bahasa",
                    lastUpdate: "Pembaruan Terakhir",
                    actions: "Tindakan",
                },
                buttons: {
                    add: "Tambah Proyek",
                },
                searchPlaceholder: "Cari...",
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteMessage: "Anda yakin? Tindakan ini tidak dapat dibatalkan! dan akan dihapus dari antrian dan koneksi terkait",
                },
            },
            files: {
                title: "Daftar File",
                table: {
                    name: "Nama",
                    contacts: "Kontak",
                    actions: "Tindakan",
                },
                toasts: {
                    deleted: "Daftar berhasil dihapus!",
                    deletedAll: "Semua daftar berhasil dihapus!",
                },
                buttons: {
                    add: "Tambah",
                    deleteAll: "Hapus Semua",
                },
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteAllTitle: "Hapus Semua",
                    deleteMessage: "Anda yakin ingin menghapus daftar ini?",
                    deleteAllMessage: "Anda yakin ingin menghapus semua daftar?",
                },
            },
            messagesAPI: {
                title: "API",
                textMessage: {
                    number: "Nomor",
                    body: "Pesan",
                    token: "Token terdaftar",
                },
                mediaMessage: {
                    number: "Nomor",
                    body: "Nama File",
                    media: "File",
                    token: "Token terdaftar",
                },
            },
            notifications: {
                noTickets: "Tidak ada notifikasi.",
            },
            quickMessages: {
                title: "Pesan Cepat",
                searchPlaceholder: "Cari...",
                noAttachment: "Tidak ada lampiran",
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteMessage: "Tindakan ini tidak dapat dibatalkan! Lanjutkan?",
                },
                buttons: {
                    add: "Tambah",
                    attach: "Lampirkan File",
                    cancel: "Batal",
                    edit: "Edit",
                },
                toasts: {
                    success: "Shortcut berhasil ditambahkan!",
                    deleted: "Shortcut berhasil dihapus!",
                },
                dialog: {
                    title: "Pesan Cepat",
                    shortcode: "Shortcut",
                    message: "Pesan",
                    save: "Simpan",
                    cancel: "Batal",
                    geral: "Izinkan edit",
                    add: "Tambah",
                    edit: "Edit",
                    visao: "Izinkan lihat",
                },
                table: {
                    shortcode: "Shortcut",
                    message: "Pesan",
                    actions: "Tindakan",
                    mediaName: "Nama File",
                    status: "Status",
                },
            },
            messageVariablesPicker: {
                label: "Variabel yang Tersedia",
                vars: {
                    contactFirstName: "Nama Depan",
                    contactName: "Nama Lengkap",
                    greeting: "Salam",
                    protocolNumber: "Nomor Protokol",
                    date: "Tanggal",
                    hour: "Jam",
                },
            },
            contactLists: {
                title: "Daftar Kontak",
                table: {
                    name: "Nama",
                    contacts: "Kontak",
                    actions: "Tindakan",
                },
                buttons: {
                    add: "Daftar Baru",
                },
                dialog: {
                    name: "Nama",
                    company: "Perusahaan",
                    okEdit: "Edit",
                    okAdd: "Tambah",
                    add: "Tambah",
                    edit: "Edit",
                    cancel: "Batal",
                },
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteMessage: "Tindakan ini tidak dapat dibatalkan.",
                },
                toasts: {
                    deleted: "Data berhasil dihapus",
                },
            },
            contactListItems: {
                title: "Kontak",
                searchPlaceholder: "Cari",
                buttons: {
                    add: "Baru",
                    lists: "Daftar",
                    import: "Impor",
                },
                dialog: {
                    name: "Nama",
                    number: "Nomor",
                    whatsapp: "WhatsApp",
                    email: "Email",
                    okEdit: "Edit",
                    okAdd: "Tambah",
                    add: "Tambah",
                    edit: "Edit",
                    cancel: "Batal",
                },
                table: {
                    name: "Nama",
                    number: "Nomor",
                    whatsapp: "WhatsApp",
                    email: "Email",
                    actions: "Tindakan",
                },
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteMessage: "Tindakan ini tidak dapat dibatalkan.",
                    importMessage: "Apakah Anda ingin mengimpor kontak dari spreadsheet ini?",
                    importTitlte: "Impor",
                },
                toasts: {
                    deleted: "Data berhasil dihapus",
                },
            },
            campaigns: {
                title: "Kampanye",
                searchPlaceholder: "Cari",
                buttons: {
                    add: "Kampanye Baru",
                    contactLists: "Daftar Kontak",
                },
                table: {
                    name: "Nama",
                    whatsapp: "WhatsApp",
                    contactList: "Daftar Kontak",
                    status: "Status",
                    scheduledAt: "Dijadwalkan",
                    completedAt: "Selesai",
                    confirmation: "Konfirmasi",
                    actions: "Tindakan",
                },
                dialog: {
                    new: "Kampanye Baru",
                    update: "Edit Kampanye",
                    readonly: "Hanya Lihat",
                    form: {
                        name: "Nama",
                        message1: "Pesan 1",
                        message2: "Pesan 2",
                        message3: "Pesan 3",
                        message4: "Pesan 4",
                        message5: "Pesan 5",
                        confirmationMessage1: "Pesan Konfirmasi 1",
                        confirmationMessage2: "Pesan Konfirmasi 2",
                        confirmationMessage3: "Pesan Konfirmasi 3",
                        confirmationMessage4: "Pesan Konfirmasi 4",
                        confirmationMessage5: "Pesan Konfirmasi 5",
                        messagePlaceholder: "Isi pesan",
                        whatsapp: "WhatsApp",
                        status: "Status",
                        scheduledAt: "Jadwal",
                        confirmation: "Konfirmasi",
                        contactList: "Daftar Kontak",
                        tagList: "Daftar Tag",
                        fileList: "Daftar File",
                    },
                    buttons: {
                        add: "Tambah",
                        edit: "Edit",
                        okadd: "Ok",
                        cancel: "Batal Kirim",
                        restart: "Mulai Ulang",
                        close: "Tutup",
                        attach: "Lampirkan File",
                    },
                },
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteMessage: "Tindakan ini tidak dapat dibatalkan.",
                },
                toasts: {
                    success: "Operasi berhasil dilakukan",
                    cancel: "Kampanye dibatalkan",
                    restart: "Kampanye dimulai ulang",
                    deleted: "Data berhasil dihapus",
                },
            },
            announcements: {
                active: "Aktif",
                inactive: "Tidak Aktif",
                title: "Pengumuman",
                searchPlaceholder: "Cari",
                buttons: {
                    add: "Buat",
                    contactLists: "Daftar Pengumuman",
                },
                table: {
                    priority: "Prioritas",
                    title: "Judul",
                    text: "Teks",
                    mediaName: "File",
                    status: "Status",
                    actions: "Tindakan",
                },
                dialog: {
                    edit: "Edit Pengumuman",
                    add: "Buat",
                    update: "Perbarui Pengumuman",
                    readonly: "Hanya Lihat",
                    form: {
                        priority: "Prioritas",
                        title: "Judul",
                        text: "Teks",
                        mediaPath: "File",
                        status: "Status",
                    },
                    buttons: {
                        add: "Tambah",
                        edit: "Perbarui",
                        okadd: "Ok",
                        cancel: "Batal",
                        close: "Tutup",
                        attach: "Lampirkan File",
                    },
                },
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteMessage: "Tindakan ini tidak dapat dibatalkan.",
                },
                toasts: {
                    success: "Operasi berhasil dilakukan",
                    deleted: "Data berhasil dihapus",
                },
            },
            campaignsConfig: {
                title: "Pengaturan Kampanye",
            },
            queues: {
                title: "Antrian & Chatbot",
                table: {
                    name: "Nama",
                    color: "Warna",
                    greeting: "Pesan sambutan",
                    actions: "Tindakan",
                    orderQueue: "Urutan antrian (bot)",
                },
                buttons: {
                    add: "Tambah antrian",
                },
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteMessage: "Anda yakin? Tindakan ini tidak dapat dibatalkan! Tiket dalam antrian ini akan tetap ada, tetapi tidak akan memiliki antrian yang ditetapkan.",
                },
            },
            queueSelect: {
                inputLabel: "Antrian",
            },
            users: {
                title: "Pengguna",
                table: {
                    name: "Nama",
                    email: "Email",
                    profile: "Profil",
                    actions: "Tindakan",
                },
                buttons: {
                    add: "Tambah Pengguna",
                },
                toasts: {
                    deleted: "Pengguna berhasil dihapus.",
                },
                confirmationModal: {
                    deleteTitle: "Hapus",
                    deleteMessage: "Semua data pengguna akan hilang. Tiket terbuka dari pengguna ini akan dipindahkan ke antrian.",
                },
            },
            helps: {
                title: "Pusat Bantuan",
            },
            schedules: {
                title: "Jadwal",
                confirmationModal: {
                    deleteTitle: "Anda yakin ingin menghapus Jadwal ini?",
                    deleteMessage: "Tindakan ini tidak dapat dibatalkan.",
                },
                table: {
                    contact: "Kontak",
                    body: "Pesan",
                    sendAt: "Tanggal Jadwal",
                    sentAt: "Tanggal Kirim",
                    status: "Status",
                    actions: "Tindakan",
                },
                buttons: {
                    add: "Jadwal Baru",
                },
                toasts: {
                    deleted: "Jadwal berhasil dihapus.",
                },
            },
            tags: {
                title: "Tag",
                confirmationModal: {
                    deleteTitle: "Anda yakin ingin menghapus Tag ini?",
                    deleteMessage: "Tindakan ini tidak dapat dibatalkan.",
                },
                table: {
                    name: "Nama",
                    color: "Warna",
                    tickets: "Tiket Ditandai",
                    actions: "Tindakan",
                },
                buttons: {
                    add: "Tag Baru",
                },
                toasts: {
                    deleted: "Tag berhasil dihapus.",
                },
            },
            settings: {
                success: "Pengaturan berhasil disimpan.",
                title: "Pengaturan",
                settings: {
                    userCreation: {
                        name: "Pembuatan pengguna",
                        options: {
                            enabled: "Aktif",
                            disabled: "Nonaktif",
                        },
                    },
                },
            },
            messagesList: {
                header: {
                    assignedTo: "Ditugaskan kepada:",
                    buttons: {
                        return: "Kembali",
                        resolve: "Selesaikan",
                        reopen: "Buka Kembali",
                        accept: "Terima",
                    },
                },
            },
            messagesInput: {
                placeholderOpen: "Ketik pesan",
                placeholderClosed: "Buka kembali atau terima tiket ini untuk mengirim pesan.",
                signMessage: "Tanda tangan",
            },
            contactDrawer: {
                header: "Data Kontak",
                buttons: {
                    edit: "Edit kontak",
                },
                extraInfo: "Informasi lainnya",
            },
            fileModal: {
                title: {
                    add: "Tambah daftar file",
                    edit: "Edit daftar file",
                },
                buttons: {
                    okAdd: "Simpan",
                    okEdit: "Edit",
                    cancel: "Batal",
                    fileOptions: "Tambah file",
                },
                form: {
                    name: "Nama daftar file",
                    message: "Detail daftar",
                    fileOptions: "Daftar file",
                    extraName: "Pesan untuk dikirim dengan file",
                    extraValue: "Nilai opsi",
                },
                success: "Daftar file berhasil disimpan!",
            },
            ticketOptionsMenu: {
                schedule: "Jadwal",
                delete: "Hapus",
                transfer: "Transfer",
                registerAppointment: "Catatan Kontak",
                appointmentsModal: {
                    title: "Catatan Kontak",
                    textarea: "Catatan",
                    placeholder: "Masukkan informasi yang ingin Anda catat di sini",
                },
                confirmationModal: {
                    title: "Hapus tiket kontak",
                    message: "Perhatian! Semua pesan terkait tiket akan hilang.",
                },
                buttons: {
                    delete: "Hapus",
                    cancel: "Batal",
                },
            },
            confirmationModal: {
                buttons: {
                    confirm: "Ya",
                    cancel: "Batal",
                },
            },
            messageOptionsMenu: {
                delete: "Hapus",
                reply: "Balas",
                confirmationModal: {
                    title: "Hapus pesan?",
                    message: "Tindakan ini tidak dapat dibatalkan.",
                },
            },
            backendErrors: {
                ERR_NO_OTHER_WHATSAPP: "Harus ada setidaknya satu WhatsApp default.",
                ERR_NO_DEF_WAPP_FOUND: "Tidak ditemukan WhatsApp default. Periksa halaman koneksi.",
                ERR_WAPP_NOT_INITIALIZED: "Sesi WhatsApp ini belum diinisialisasi. Periksa halaman koneksi.",
                ERR_WAPP_CHECK_CONTACT: "Tidak dapat memeriksa kontak WhatsApp. Periksa halaman koneksi.",
                ERR_WAPP_INVALID_CONTACT: "Ini bukan nomor WhatsApp yang valid.",
                ERR_WAPP_DOWNLOAD_MEDIA: "Tidak dapat mengunduh media dari WhatsApp. Periksa halaman koneksi.",
                ERR_INVALID_CREDENTIALS: "Error autentikasi. Silakan coba lagi.",
                ERR_SENDING_WAPP_MSG: "Error mengirim pesan WhatsApp. Periksa halaman koneksi.",
                ERR_DELETE_WAPP_MSG: "Tidak dapat menghapus pesan WhatsApp.",
                ERR_OTHER_OPEN_TICKET: "Sudah ada tiket terbuka untuk kontak ini.",
                ERR_SESSION_EXPIRED: "Sesi berakhir. Silakan masuk.",
                ERR_USER_CREATION_DISABLED: "Pembuatan pengguna dinonaktifkan oleh administrator.",
                ERR_NO_PERMISSION: "Anda tidak memiliki izin untuk mengakses resource ini.",
                ERR_DUPLICATED_CONTACT: "Sudah ada kontak dengan nomor ini.",
                ERR_NO_SETTING_FOUND: "Tidak ditemukan pengaturan dengan ID ini.",
                ERR_NO_CONTACT_FOUND: "Tidak ditemukan kontak dengan ID ini.",
                ERR_NO_TICKET_FOUND: "Tidak ditemukan tiket dengan ID ini.",
                ERR_NO_USER_FOUND: "Tidak ditemukan pengguna dengan ID ini.",
                ERR_NO_WAPP_FOUND: "Tidak ditemukan WhatsApp dengan ID ini.",
                ERR_CREATING_MESSAGE: "Error membuat pesan di database.",
                ERR_CREATING_TICKET: "Error membuat tiket di database.",
                ERR_FETCH_WAPP_MSG: "Error mengambil pesan di WhatsApp, mungkin terlalu lama.",
                ERR_QUEUE_COLOR_ALREADY_EXISTS: "Warna ini sudah digunakan, pilih warna lain.",
                ERR_WAPP_GREETING_REQUIRED: "Pesan sambutan wajib ada jika terdapat lebih dari satu antrian.",
            },
        },
    },
};

export { messages };