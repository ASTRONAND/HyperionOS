-- Copyright (C) 2025 ASTRONAND
function string.hasSuffix(str, suffix)
    return string.sub(str, #suffix+1) == suffix
end

function string.hasPrefix(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

function string.getSuffix(str, prefix)
    return string.sub(str, #prefix+1)
end

function string.getPrefix(str, suffix)
    return string.sub(str, 1, #suffix)
end

function string.join(str, ...)
    return table.concat(table.pack(str, ...))
end

function string.delim(str, ...)
    return table.concat(table.pack(...), str)
end

function string.split(str, delim, maxResultCountOrNil)
    assert(#delim == 1, "only delim len 1 supported for now")
    maxResultCountOrNil = (maxResultCountOrNil or 0)-1
    local rv = {}
    local buf = ""
    for i = 1, #str do
        local c = string.sub(str,i,i)
        if #rv ~= maxResultCountOrNil and c == delim then
            table.insert(rv, buf)
            buf = ""
        else
            buf = buf..c
        end
    end
    table.insert(rv, buf)
    return rv
end

function string.replace(str, search, replacement)
    local rv = ""
    local consumedLen = 1
    local i = 1
    while i<#str do
        if string.sub(str, i, i+#search-1) == search then
            rv = rv .. string.sub(str, consumedLen, i-1) .. replacement
            i=i+#search
            consumedLen = i
        end
        i=i+1
    end
    return rv .. string.sub(str, consumedLen)
end