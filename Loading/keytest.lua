local function loadRemoteScript(url)
    local success, content = pcall(function()
        return game:HttpGetAsync(url)
    end)
    return success and content or nil
end

local function validateKey(key, keyList)
    for _, validKey in ipairs(keyList) do
        if key == validKey then
            return true
        end
    end
    return false
end

local keyListUrl = "https://raw.githubusercontent.com/NittarPP/PhotonScript/main/key.lua"
local keyListContent = loadRemoteScript(keyListUrl)

if not keyListContent then
    warn("Failed to retrieve key list. Please report to Discord.")
    return
end

local keyList = loadstring(keyListContent)()
if type(keyList) ~= "table" then
    warn("Invalid key list format. Please report to Discord.")
    return
end

local playerKey = _G.key
if not validateKey(playerKey, keyList) then
    game.Players.LocalPlayer:Kick("\n [ Photon Hub ] \n Key not valid")
    return
end

local gameScriptUrl = "https://raw.githubusercontent.com/NittarPP/PhotonScript/main/Src/" .. game.PlaceId .. ".lua"
local gameScriptContent = loadRemoteScript(gameScriptUrl)

if not gameScriptContent then
    game.Players.LocalPlayer:Kick("\n [ Photon Hub ] \n Game not supported")
    return
end

local scriptSuccess, scriptError = pcall(loadstring(gameScriptContent))
if not scriptSuccess then
    warn("Failed to execute game script: " .. scriptError)
    game.Players.LocalPlayer:Kick("\n [ Photon Hub ] \n Script execution error")
    return
end

-- Script executed successfully
