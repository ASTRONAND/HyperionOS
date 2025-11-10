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