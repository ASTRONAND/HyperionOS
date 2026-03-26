local cloptions = {
    a    = false,
    h    = false,
    l    = false,
    help = false,
}
local inpArgs = { ... }
local args    = {}

for _, v in pairs(inpArgs) do
    if v:sub(1, 2) == "--" then
        local opt = v:sub(3)
        if cloptions[opt] == nil then
            print("spm: unrecognized option '" .. v .. "'.")
            print("try 'spm --help' for more information.")
            return
        end
        cloptions[opt] = true
    elseif v:sub(1, 1) == "-" then
        for i = 2, #v do
            local opt = v:sub(i, i)
            if cloptions[opt] == nil then
                print("spm: invalid option '-" .. opt .. "'.")
                print("try 'spm --help' for more information.")
                return
            end
            cloptions[opt] = true
        end
    else
        table.insert(args, v)
    end
end

local http=http or require("http")
local json=json or require("json")
local xz  =xz   or require("xz")

if cloptions.help then
    print("Usage: spm [COMMAND] [OPTION] [packages]")
    print("The Simple package Mannager.")
    print("")
    print("Commands:")
    print("  remove          Remove package(s)")
    print("  update          Updates package(s)")
    print("  install         Install package(s)")
    print("  sync            Syncs local registry with servers")
    print("")
    print("Options:")
    print("  --help      display this help and exit")
    return
end

local function getustar()
    
end