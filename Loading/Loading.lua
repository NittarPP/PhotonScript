local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = Library:CreateWindow{
    Title = "Photon | Key System",
    SubTitle = "by Kokie",
    TabWidth = 160,
    Size = UDim2.fromOffset(1350, 650),
    Resize = true,
    MinSize = Vector2.new(1350, 700),
    Acrylic = true,
    Theme = "Viow Mars",
    MinimizeKey = Enum.KeyCode.RightControl
}

local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "phosphor-users-bold"
    },
    Settings = Window:CreateTab{
        Title = "Key Save",
        Icon = "settings"
    }
}

local Options = Library.Options
_G.keycode = ""

function keytest()
    local success, KeyList = pcall(function()
        return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/NittarPP/PhotonScript/refs/heads/main/key.lua"))()
    end)
    
    if not success or type(KeyList) ~= "table" then
        Library:Notify{
            Title = "Key System",
            Content = "Failed to retrieve key list. Please report to Discord.",
            Duration = 5
        }
        return
    end
    
    for _, validKey in ipairs(KeyList) do
        if _G.keycode == validKey then
            Library:Notify{
                Title = "Key Accepted",
                Content = "Access Granted",
                Duration = 5
            }
            
            if not game:GetService("Stats"):FindFirstChild("Accepted") then
                local kd = Instance.new("RemoteEvent")
                kd.Name = "Accepted"
                kd.Parent = game:GetService("Stats")
            end
            
            local scriptSuccess, scriptContent = pcall(function()
                return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/NittarPP/PhotonScript/refs/heads/main/Src/" .. game.PlaceId .. ".lua"))()
            end)
            
            if scriptSuccess and scriptContent and scriptContent ~= "" then
                Library:Notify{
                    Title = "Photon",
                    Content = "Loading Script Now (save you key for auto loading and fast)",
                    Duration = 5
                }
				wait(5)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/NittarPP/PhotonScript/refs/heads/main/Src/" .. game.PlaceId .. ".lua"))()
            else
                Library:Notify{
                    Title = "Photon Not Supported",
                    Content = "Unsupported Game",
                    Duration = 5
                }
            end
            return
        end
    end
    
    Library:Notify{
        Title = "Invalid Key",
        Content = "Incorrect Key, Try Again",
        Duration = 5
    }
end

local Key = Tabs.Main:CreateInput("Key", {
    Title = "Key",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        _G.keycode = Value
        keytest()
    end
})

if LocalPlayer.Name == "NOOBFDAB" then
    Tabs.Main:CreateButton{
        Title = "Enter",
        Callback = function()
            keytest()
        end
    }

    Tabs.Main:CreateButton{
        Title = "Generate Key",
        Callback = function()
            local charset = "abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            local function randomSegment(length)
                local segment = ""
                for _ = 1, length do
                    local randIndex = math.random(1, #charset)
                    segment = segment .. charset:sub(randIndex, randIndex)
                end
                return segment
            end
            
            local keys = {}
            for i = 1, 1000 do
                keys[i] = "Photon-" .. randomSegment(10) .. "-" .. randomSegment(10)
            end
            
            setclipboard(table.concat(keys, ",\n"))
        end
    }
end

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("PhotonScript")
SaveManager:SetFolder("PhotonScript/Key")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
