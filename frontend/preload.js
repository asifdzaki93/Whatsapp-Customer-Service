const { contextBridge } = require("electron");
const path = require("path");

contextBridge.exposeInMainWorld("electron", {
    getBasePath: () => path.join(__dirname, "build"),
});