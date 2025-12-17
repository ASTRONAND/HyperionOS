local lua = {
    coroutine = true,
    debug = true,
    _HOST = true,
    _VERSION = true,
    assert = true,
    collectgarbage = true,
    error = true,
    gcinfo = true,
    getfenv = true,
    getmetatable = true,
    ipairs = true,
    __inext = true,
    load = true,
    math = true,
    next = true,
    pairs = true,
    pcall = true,
    rawequal = true,
    rawget = true,
    rawlen = true,
    rawset = true,
    select = true,
    setfenv = true,
    setmetatable = true,
    string = true,
    table = true,
    tonumber = true,
    tostring = true,
    type = true,
    xpcall = true,
    _G=true
}

for i,v in pairs(_G) do
    if not lua[i] or lua[i]==nil then
        apis[i]=v
        _G[i]=nil
    end
end