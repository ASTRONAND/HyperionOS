-- Copyright (C) 2025 ASTRONAND
local args = {...}
local os = require("system")
local fs=require("filesystem")
local term = os.getEnvar("term")

if args[1] == "help" or args[1] == "-h" then
    term.print("SPM V1.0.0")
    term.print("Usage:")
    term.print("    install <package>     : searches for package and installs it")
    term.print("    add-repo <URL>        : adds repo to search list appends package to end of URL")
    term.print("    download <URL>        : downloads package from URL")
    term.print("    local <dir>           : downloads package from file")
    term.print("    get <dir>             : executes commands from list")
end

local function install(package)
    
end

local function addRepo(url)
    
end

local function download(url)
    
end

local function localPackage(dir)
    
end

local function run(command)
    local list = string.split(command, " ")
    if list[1] == "install" then
        install(list[2])
    elseif list[1] == "add-repo" then
        
    end
end

if args[1] == "get" then
    local list=string.split(fs.readAllText(args[2]), "\n")
    for i, v in ipairs(list) do
        
    end
else run(args) end