local fs = require("sys.fs")
local bashStr = fs.readAllText("/bin/bash")
local bashFun = load(bashStr)
syscall.HPV_spawn(bashFun, "bash")