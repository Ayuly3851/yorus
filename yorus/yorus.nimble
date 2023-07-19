# Package

version       = "0.1.0"
author        = "Ayuly3851"
description   = "Discord C2 write in nim"
license       = "MIT"
srcDir        = "src"
bin           = @["yorus"]


# Dependencies

requires "nim >= 1.6.14"

task run_release, "":
    exec "nim --app:gui -d:ssl -d:release --opt:size -d:danger --stackTrace:off --lineTrace:off --passL:-static -o=build/yorus.exe c src/yorus.nim"
    exec "strip -s build/yorus.exe"
    exec "build/yorus.exe"

task build_release, "build release":
    exec "nim --app:gui -d:ssl -d:release --opt:size -d:danger --stackTrace:off --lineTrace:off --passL:-static -o=build/yorus.exe c src/yorus.nim"
    exec "strip -s build/yorus.exe"
    exec "upx --ultra-brute --strip-relocs=0 src/yorus.exe"

task run_debug, "build & run debug":
    exec "nim -d:ssl -d:release --opt:size -d:danger --stackTrace:off --lineTrace:off --passL:-static -o=build/yorus.exe c src/yorus.nim"
    exec "strip -s build/yorus.exe"
    exec "build/yorus.exe"

task build_debug, "build debug":
    exec "nim -d:ssl -d:release --opt:size -d:danger --stackTrace:off --lineTrace:off --passL:-static -o=build/yorus.exe c src/yorus.nim"
    exec "strip -s build/yorus.exe"
    # exec "upx --ultra-brute --strip-relocs=0 src/yorus.exe"