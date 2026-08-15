local args={...}
local bootstrap=""
if args[1]=="cct" then
    print("installing cct")
    local function get(url)
        local resp=http.get(url)
        return resp.readAll()
    end
    bootstrap=get("https://git.astronand.dev/Hyperion/HyperionOS/raw/branch/main/bootstrap/cct-bootstrap.lua")
else
    error("Unsupported architecture")
end

local func=load(bootstrap,"@Bootstrap", "t", _G)
func()