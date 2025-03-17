-- Lol why you dont add build a boat script



--[[
    Script by Jacob
    Auto farm by Jacob
    
    Hoho don't skid gay
--]]

print("working")

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- skibidi function
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

if game.PlaceId ~= 537413528 then
    return
end

print("working")

local Library = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "Build a Boat for Treasure",
    SubTitle = "by Nova",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true, 
    MinSize = Vector2.new(470, 380),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl 
}

local Tabs = {
    Main = Window:CreateTab{ Title = "Farm", Icon = "chevrons-up" },
    Settings = Window:CreateTab{ Title = "UI Settings", Icon = "settings" }
}

local Options = Library.Options
local Toggle = Tabs.Main:CreateToggle("MyToggle", {Title = "Auto Farm", Default = false })

getgenv().AF = false

Toggle:OnChanged(function()
    getgenv().AF = Options.MyToggle.Value
    if getgenv().AF then 
        Library:Notify{ Title = "Photon", Content = "dont move you will die!", Duration = 12 }
        startAutoFarm()
    else
    end
end)

function startAutoFarm()
    if not getgenv().AF then return end

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local newPart = Instance.new("Part")
    newPart.Size = Vector3.new(5, 1, 5)
    newPart.Transparency = 1
    newPart.CanCollide = true
    newPart.Anchored = true
    newPart.Parent = Workspace

    for i = 1, 10 do
        if not getgenv().AF then break end

        humanoidRootPart.CFrame = CFrame.new(-51, 65, 984 + (i - 1) * 770)

  
        newPart.Position = humanoidRootPart.Position - Vector3.new(0, 2, 0)

        task.wait(2.3)
        Workspace.ClaimRiverResultsGold:FireServer()
    end

    newPart:Destroy()
end

player.CharacterAdded:Connect(function()
    if getgenv().AF then
        task.wait(1)
        startAutoFarm()
    end
end)

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

print("stop")
