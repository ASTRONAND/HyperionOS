local args={...}
if #args>0 then
    load(args[1])(table.unpack(args, 2))
else
    local sys = require("system")
    local evhook = sys.addEventHook("keyTyped", function()
        
    end)
    local term = sys.getParentTermObject()
end