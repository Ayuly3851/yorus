import strutils, json, sysinfo
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

proc systemInfo*(self: PcInformation): JsonNode =
    var sysinfo = %* {
            "MachineModel": getMachineModel(),
            "MachineName": getMachineName(),
            "OsName": getOsName(),
            "OsVersion": getOsVersion(),
            "CpuName": getCpuName(),
            "CpuGhz": getCpuGhz(),
            "CpuManufacturer": getCpuManufacturer(),
            "NumCpus": getNumCpus(),
            "NumTotalCores": getNumTotalCores(),
            "TotalMemory": getTotalMemory().float / 1024 / 1024 / 1024,
            "FreeMemory": getFreeMemory().float / 1024 / 1024 / 1024,
            "GpuName": getGpuName(),
            "GpuDriverVersion": getGpuDriverVersion(),
            "GpuMaxFPS": getGpuMaxFPS()
        }
    result = sysinfo

# --- IP Information --- #
proc ipData*(self: PcInformation): JsonNode =
    var client = newHttpClient()
    var ipDataRaw = client.getContent("http://ipinfo.io/json")
    var ipDataJson = ipDataRaw.parseJson()
    result = ipDataJson
