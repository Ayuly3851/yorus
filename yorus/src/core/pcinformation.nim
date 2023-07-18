import strutils, json
from httpclient import newHttpClient, getContent
from osproc import execCmdEx
from os import getenv

type PcInformation* = object

# --- SYSTEM INFORMAITON --- #
proc hwid*(self: PcInformation): string =
    let output = execCmdEx("wmic csproduct get uuid")
    result = output.output.split("\n")[2].strip()

proc userName*(self: PcInformation): string =
    let username = getEnv("USERNAME")
    result = username

# --- IP Information --- #
proc ipData*(self: PcInformation): JsonNode =
    var client = newHttpClient()
    var ipDataRaw = client.getContent("http://ipinfo.io/json")
    var ipDataJson = ipDataRaw.parseJson()
    result = ipDataJson
