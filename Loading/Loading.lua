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
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer

-- Detect chat type
local isLegacyChat = not pcall(function()
    return TextChatService.TextChannels.RBXGeneral
end)

-- Chat function
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

-- Follow helper function using Humanoid:MoveTo and Pathfinding
local function followPlayer(player)
    local kokie = Players:FindFirstChild("Kokie_Cx")
    if not kokie or not kokie.Character or not kokie.Character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    following = true

    if followConnection then followConnection:Disconnect() end

    followConnection = RunService.Heartbeat:Connect(function(delta)
        if not following then return end
        if not (player.Character and humanoid and hrp and kokie.Character and kokie.Character:FindFirstChild("HumanoidRootPart")) then return end

        local targetPos = kokie.Character.HumanoidRootPart.Position
        local distance = (targetPos - hrp.Position).Magnitude

        if distance > 3 then
            -- Direction vector
            local dir = (targetPos - hrp.Position).Unit
            local rayOrigin = hrp.Position
            local rayDirection = dir * 4
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {player.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

            local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)

            if raycastResult then
                local hitPart = raycastResult.Instance
                local hitPos = raycastResult.Position
                local heightDiff = hitPos.Y - hrp.Position.Y

                -- Jump if obstacle is small enough
                if heightDiff > 0 and heightDiff < 4 then
                    humanoid.Jump = true
                end
            end

            -- Move toward target using current WalkSpeed
            local moveSpeed = humanoid.WalkSpeed
            local moveVector = dir * math.min(moveSpeed * delta, distance)
            local newPos = hrp.Position + moveVector
            humanoid:MoveTo(newPos)
        else
            humanoid:MoveTo(hrp.Position) -- stop near Kokie
        end
    end)
end


-- Commands table
local commands = {
    ["hi"] = function(player)
        if player == LocalPlayer then
            chatMessage("Hi Kokie")
        end
    end,
    ["bring"] = function(player)
        local kokie = Players:FindFirstChild("Kokie_Cx")
        if kokie and kokie.Character and player.Character and kokie.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = kokie.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
        end
    end,
    ["kick"] = function(player)
        if player == LocalPlayer then
            LocalPlayer:Kick("Kicked by Kokie_Cx")
        end
    end,
    ["sit"] = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Sit = true
        end
    end,
    ["stand"] = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Sit = false
        end
    end,
    ["jump"] = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Jump = true
        end
    end,
    ["spin"] = function(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local spinTween = TweenService:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 5), {CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(360), 0)})
            spinTween:Play()
        end
    end,
    ["freeze"] = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = true
        end
    end,
    ["unfreeze"] = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
    end,
    ["jumpboost"] = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = 150
        end
    end,
    ["resetjump"] = function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = 50
        end
    end,
    ["noclip"] = function(player)
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end,
    ["clip"] = function(player)
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end,
    ["follow"] = followPlayer,
    ["unfollow"] = function(player)
        following = false
        if followConnection then followConnection:Disconnect() end
    end,
    ["stop"] = function(player)
        following = false
        if followConnection then followConnection:Disconnect() end
    end
}

-- Chat handler
local function onPlayerChatted(player, message)
    local msg = message:lower():gsub("^%s*(.-)%s*$", "%1") -- trim and lowercase

    -- Only respond to Kokie
    if player.Name ~= "Kokie_Cx" then return end

    if commands[msg] then
        pcall(function() commands[msg](LocalPlayer) end)
        return
    end

    -- Command with "cmd" prefix
    local splitMsg = message:split(" ")
    if splitMsg[1]:lower() == "!" and splitMsg[2] and splitMsg[3] then
        local targetPlayer = Players:FindFirstChild(splitMsg[2])
        local cmdName = splitMsg[3]:lower()
        if targetPlayer and commands[cmdName] then
            pcall(function() commands[cmdName](targetPlayer) end)
        end
    end
end

-- Connect existing players
for _, player in pairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(msg)
        onPlayerChatted(player, msg)
    end)
end

-- Connect new players
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        onPlayerChatted(player, msg)
    end)
end)

-- Optional: greet Kokie
for _, player in pairs(Players:GetPlayers()) do
    if player.Name:lower() == "kokie_cx" then
        chatMessage("Hi Kokie")
    end
end
Players.PlayerAdded:Connect(function(player)
    if player.Name:lower() == "kokie_cx" then
        chatMessage("Hi Kokie")
    end
end)
