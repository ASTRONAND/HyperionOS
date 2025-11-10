-- Copyright (C) 2025 ASTRONAND
function table.deepcopy(orig, copies)
    copies = copies or {}

    if type(orig) ~= 'table' then
        return orig
    elseif copies[orig] then
        return copies[orig]
    end

    local copy = {}
    copies[orig] = copy

    for k, v in next, orig, nil do
        local copied_key = table.deepcopy(k, copies)
        local copied_val = table.deepcopy(v, copies)
        copy[copied_key] = copied_val
    end

    return copy
end

function table.hasKey(tabl, query)
    for i,v in pairs(tabl) do
        if i==query then
            return true
        end
    end
    return false
end

function table.hasVal(tabl, query)
    for i,v in pairs(tabl) do
        if v==query then
            return true
        end
    end
    return false
end

local function serialize(table)
    local output = "{"
    for i,v in pairs(table) do
        local coma=true
        if type(i) == "string" then
            output=output.."[\""..i.."\"]="
        end
        if type(v) == "table" then
            if v == table then
                output=string.sub(output,1,#output-(#i+1))
                coma=false
            else
                output=output..serialize(v)
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
            output=output.."function() end"
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

table.serialize=serialize