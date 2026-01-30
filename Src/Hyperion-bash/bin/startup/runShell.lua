local fs = require("sys.fs")
local bashStr = fs.readAllText("/bin/bash")
local bashFun = load(bashStr)
syscall.spawn(bashFun, "bash")