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

local lastJumpTime = 0
local JUMP_COOLDOWN = 0.3 -- faster cooldown
local MAX_JUMP_HEIGHT = 4
local MOVE_ACCELERATION = 80 -- speed multiplier

local function followPlayer(player)
	local kokie = Players:FindFirstChild("Kokie_Cx")
	if not kokie or not kokie.Character then return end

	following = true

	if followConnection then followConnection:Disconnect() end

	followConnection = RunService.Heartbeat:Connect(function(delta)
		local char = player.Character
		local humanoid = char and char:FindFirstChild("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local kokieChar = kokie.Character
		local targetHRP = kokieChar and kokieChar:FindFirstChild("HumanoidRootPart")

		if not (char and humanoid and hrp and targetHRP and following) then return end

		local targetPos = targetHRP.Position
		local distance = (targetPos - hrp.Position).Magnitude

		if distance > 2 then
			local direction = (targetPos - hrp.Position).Unit

			-- Raycast at chest height for obstacles
			local rayOrigin = hrp.Position + Vector3.new(0, 1.5, 0)
			local rayDirection = direction * 4

			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = {char}
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist

			local result = Workspace:Raycast(rayOrigin, rayDirection, rayParams)

			if result then
				local heightDiff = result.Position.Y - hrp.Position.Y
				local now = tick()
				if heightDiff > 0 and heightDiff < MAX_JUMP_HEIGHT and (now - lastJumpTime) > JUMP_COOLDOWN then
					humanoid.Jump = true
					lastJumpTime = now
				end
			end

			-- Use Move instead of MoveTo for instant direction updates
			humanoid:Move(direction * MOVE_ACCELERATION)
		else
			humanoid:Move(Vector3.zero)
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
        wait(5)
        chatMessage("Hi Kokie")
    end
end
Players.PlayerAdded:Connect(function(player)
    if player.Name:lower() == "kokie_cx" then
        wait(5)
        chatMessage("Hi Kokie")
    end
end)
