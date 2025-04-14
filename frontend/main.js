const { app, BrowserWindow } = require("electron");
const path = require("path");
const isDev = process.env.NODE_ENV === "development";

let mainWindow;

app.on("ready", () => {
    mainWindow = new BrowserWindow({
        width: 1920,
        height: 1080,
        webPreferences: {
            contextIsolation: true,
            enableRemoteModule: false,
            preload: path.join(__dirname, "preload.js"), // Preload script
        },
        autoHideMenuBar: true, // Menyembunyikan menu bar
    });

    const startUrl = isDev
        ? "http://localhost:3000" // URL saat development
        : `file://${path.join(__dirname, "build", "index.html")}`; // File build saat production

    mainWindow.loadURL(startUrl);

    // Menangani jalur file statis di Electron
    mainWindow.webContents.on('will-navigate', (event, url) => {
        if (!url.startsWith('file://')) {
            event.preventDefault();
            const staticPath = path.join(__dirname, 'build', url.replace('http://localhost:3000/', ''));
            mainWindow.webContents.loadFile(staticPath);
        }
    });
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
        mainWindow = new BrowserWindow({
            width: 800,
            height: 600,
            webPreferences: {
                contextIsolation: true,
                enableRemoteModule: false,
                preload: path.join(__dirname, "preload.js"), // Preload script
            },
            autoHideMenuBar: true, // Menyembunyikan menu bar
        });

        const startUrl = isDev
            ? "http://localhost:3000" // URL saat development
            : `file://${path.join(__dirname, "build", "index.html")}`; // File build saat production

        mainWindow.loadURL(startUrl);
    }
});
