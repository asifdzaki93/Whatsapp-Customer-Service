const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 800,
        height: 600,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
        },
    });

    // Remove the default menu bar
    Menu.setApplicationMenu(null);

    mainWindow.loadFile(path.join(__dirname, 'build', 'index.html'));

    mainWindow.webContents.on('did-finish-load', () => {
        console.log("Page loaded successfully");
    });
    mainWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
        console.error("Failed to load page:", errorDescription);
    });

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

app.on('ready', () => {
    console.log("Electron main process started");
    createWindow();
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});