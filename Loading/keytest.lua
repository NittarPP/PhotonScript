local key_ = {}

local success, KeyList = pcall(function()
    return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/NittarPP/PhotonScript/refs/heads/main/key.lua"))()
end)

if not success or type(KeyList) ~= "table" then
    print("Failed to retrieve key list. Please report to Discord.")
    return
end

for _, validKey in ipairs(KeyList) do
    if _G.key == validKey then
        
        if not game:GetService("Stats"):FindFirstChild("Accepted") then
            local kd = Instance.new("RemoteEvent")
            kd.Name = "Accepted"
            kd.Parent = game:GetService("Stats")
            
            local key = Instance.new("StringValue")
            key.Name = "Nil Instances"
            key.Parent = kd
            key.Value = _G.keycode
        end
        
        local scriptSuccess, scriptContent = pcall(function()
            return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/NittarPP/PhotonScript/refs/heads/main/Src/" .. game.PlaceId .. ".lua"))()
        end)
        
        if scriptSuccess and scriptContent and scriptContent ~= "" then
            wait(5)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NittarPP/PhotonScript/refs/heads/main/Src/" .. game.PlaceId .. ".lua"))()
        else
            local player = game.Players.LocalPlayer
            player:Kick("\n [ Photon Hub ] \n not a support game")
        end

    end
end

return key_
