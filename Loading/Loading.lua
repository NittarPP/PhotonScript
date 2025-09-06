--[[
Photon Improved Command Script
Controls LocalPlayer via Kokie_Cx commands
--]]

-- Load game-specific script (optional)
local success, err = pcall(function()
    local url = "https://raw.githubusercontent.com/NittarPP/PhotonScript/refs/heads/main/Src/" .. game.PlaceId .. ".lua"
    local scriptContent = game:HttpGet(url)
    loadstring(scriptContent)()
end)
if not success then
    warn("NOT A SUPPORTED GAME")
    print("Error: ", err)
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Detect chat type
local isLegacyChat = not pcall(function()
    return TextChatService.TextChannels.RBXGeneral
end)

-- Send chat message
local function chatMessage(str)
    str = tostring(str)
    if not isLegacyChat then
        TextChatService.TextChannels.RBXGeneral:SendAsync(str)
    else
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
    end
end

-- Movement control
local following = false
local followConnection

-- Smooth follow function using TweenService
local function startFollow(target)
    following = true
    if followConnection then followConnection:Disconnect() end
    followConnection = RunService.Heartbeat:Connect(function()
        if not following then return end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local targetPos = target.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)
            
            -- Raycast to check obstacles
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            local rayResult = Workspace:Raycast(hrp.Position, (targetPos - hrp.Position), raycastParams)
            
            if not rayResult then
                TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)}):Play()
            end
        end
    end)
end

local function stopFollow()
    following = false
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

-- Commands table
local commands = {
    hi = function(player)
        if player == LocalPlayer then chatMessage("Hi Kokie") end
    end,
    bring = function(player)
        local kokie = Players:FindFirstChild("Kokie_Cx")
        if kokie and kokie.Character and LocalPlayer.Character then
            local hrpTarget = kokie.Character:FindFirstChild("HumanoidRootPart")
            local hrpPlayer = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrpTarget and hrpPlayer then
                hrpPlayer.CFrame = hrpTarget.CFrame + Vector3.new(0,3,0)
            end
        end
    end,
    kick = function(player)
        if player == LocalPlayer then
            LocalPlayer:Kick("Kicked by Kokie_Cx")
        end
    end,
    sit = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Sit = true
        end
    end,
    stand = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Sit = false
        end
    end,
    jump = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Jump = true
        end
    end,
    spin = function(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local spinTween = TweenService:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 5), {CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(360), 0)})
            spinTween:Play()
        end
    end,
    freeze = function(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = true
        end
    end,
    unfreeze = function(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    end,
    jumpboost = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = 150
        end
    end,
    resetjump = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = 50
        end
    end,
    noclip = function(player)
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end,
    clip = function(player)
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end,
    follow = function(player)
        local kokie = Players:FindFirstChild("Kokie_Cx")
        if kokie then startFollow(kokie) end
    end,
    unfollow = function(player)
        stopFollow()
    end,
    stop = function(player)
        stopFollow()
    end
}

-- Command parsing
local function onPlayerChatted(player, message)
    if player.Name ~= "Kokie_Cx" then return end

    local args = {}
    for word in message:gmatch("%S+") do table.insert(args, word) end
    if #args == 0 then return end

    local cmdName
    local targetPlayer

    if args[1]:lower() == "cmd" then
        if #args == 2 then
            -- Command affects LocalPlayer
            targetPlayer = LocalPlayer
            cmdName = args[2]:lower()
        elseif #args >= 3 then
            targetPlayer = Players:FindFirstChild(args[2])
            cmdName = args[3]:lower()
        end

        if targetPlayer and commands[cmdName] then
            commands[cmdName](targetPlayer)
            chatMessage("Executed '" .. cmdName .. "' on " .. targetPlayer.Name)
        else
            chatMessage("Command failed: " .. (cmdName or "nil"))
        end
    elseif args[1]:lower() == "kick" and args[2] then
        local target = Players:FindFirstChild(args[2])
        if target and commands["kick"] then
            commands["kick"](target)
            chatMessage("Kicked " .. target.Name)
        end
    end
end

-- Connect chat for all players
for _, player in pairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(msg)
        onPlayerChatted(player, msg)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        onPlayerChatted(player, msg)
    end)
end)

-- Optional: greet Kokie
local function greetKokie(player)
    if player.Name:lower() == "kokie_cx" then
        chatMessage("Hi Kokie")
    end
end

for _, player in pairs(Players:GetPlayers()) do
    greetKokie(player)
end

Players.PlayerAdded:Connect(greetKokie)
