--[[
    ================================================================================
    ECCO HUB V3 — OFFICIAL GATEWAY (https://eccohub.xyz)
    ================================================================================
    Official Hub : https://eccohub.xyz
    Community    : https://discord.gg/hN9QpA3HA
    TikTok       : https://www.tiktok.com/@_ecc00_?is_from_webapp=1&sender_device=pc
    ================================================================================
--]]
local success, code = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/loader_obfuscated.lua")
end)

if success and typeof(code) == "string" and #code > 500 and not code:find("404: Not Found") then
    local fn, err = loadstring(code, "ecco_loader_obfuscated")
    if fn then
        return fn()
    end
end

-- Fallback to direct raw loader if obfuscated fetch fails
local ok2, code2 = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/loader.lua")
end)
if ok2 and typeof(code2) == "string" and #code2 > 500 then
    local fn2, err2 = loadstring(code2, "ecco_loader_raw")
    if fn2 then
        return fn2()
    end
end

-- Fallback to localhost HTTP server if developing
local ok3, code3 = pcall(function()
    return game:HttpGet("http://127.0.0.1:8999/loader_obfuscated.lua")
end)
if ok3 and typeof(code3) == "string" and #code3 > 500 then
    local fn3, err3 = loadstring(code3, "ecco_loader_local")
    if fn3 then
        return fn3()
    end
end
