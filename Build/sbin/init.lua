local kernel=...
local fs=require("sys.fs")
syscall.TTY_bind("tty0")

local files = fs.list("/bin/startup")
if not files then error("Failed to list /bin/startup") end
for i,v in ipairs(files) do
    if v:sub(-4) == ".lua" then
        local filepath = "/bin/startup/" .. v
        kernel.log("Executing startup script: " .. filepath, "INFO")
        local startupFunc, err = load(fs.readAllText(filepath), "@" .. filepath)
        if not startupFunc then
            kernel.log("Error loading startup script '" .. filepath .. "': " .. err, "ERROR")
        else
            kernel.hpv.spawn(function()
                local status, err = pcall(startupFunc)
                if not status then
                    kernel.log("Error executing startup script '" .. filepath .. "': " .. err, "ERROR")
                else
                    kernel.log("Successfully executed startup script: " .. filepath, "INFO")
                end
            end, "startup:" .. v)
        end
    end
end

local function serialize(table, seen)
    seen = seen or {}
    if seen[tostring(table)] then
        return "\"<circular reference>\""
    end
    seen[tostring(table)] = true
    local output = "{"
    for i,v in pairs(table) do
        local coma=true
        if type(i) == "string" then
            output=output.."[\""..i.."\"]="
        elseif type(i) == "number" then
            output=output.."["..tostring(i).."]="
        end
        if type(v) == "table" then
            if v == table then
                output=string.sub(output,1,#output-(#i+1))
                coma=false
            else
                output=output..serialize(v, seen)
            end
        elseif type(v) == "string" then
            output=output.."[=["..v.."]=]"
        elseif type(v) == "number" then
            output=output..tostring(v)
        elseif type(v) == "boolean" then
            if v == true then
                output=output.."true"
            else
                output=output.."false"
            end
        elseif type(v) == "function" then
            output=output..tostring(v)
        elseif type(v) == "userdata" then
            output=output..tostring(v)
        elseif type(v) == "thread" then
            output=output..tostring(v)
        else
            error("serialization of type \""..type(v).."\" is not supported")
        end
        if coma then
            output=output..","
        end
    end
    if #table>0 or string.sub(output,#output,#output) == "," then
        output=string.sub(output,1,#output-1)
    end
    output=output.."}"
    return output
end

while true do
    --print(serialize(kernel.tasks))
    kernel.saveLog()
    sleep(1000)
end