const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1920,
        height: 1080,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            nodeIntegration: false,
            contextIsolation: true
        },
    });

    // Remove the default menu bar
    Menu.setApplicationMenu(null);

    // Load the app
    mainWindow.loadFile(path.join(__dirname, 'build', 'index.html'));

    // ✅ Tampilkan DevTools dengan variabel yang benar
    mainWindow.webContents.openDevTools();

    // Event jika halaman berhasil dimuat
    mainWindow.webContents.on('did-finish-load', () => {
        console.log("Page loaded successfully");
    });

    // Event jika halaman gagal dimuat
    mainWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
        console.error("Failed to load page:", errorDescription);
    });

    // Handle window ditutup
    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

// App ready
app.on('ready', () => {
    console.log("Electron main process started");
    createWindow();
});

// Tutup semua window (kecuali Mac)
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

// Buka lagi window saat di-click di dock (Mac)
app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});
