local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
 
local Window = Library:CreateWindow{
    Title = "E.R.P.O (In game)",
    SubTitle = "by 21xp Team",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
}
local Tabs = {
    Main = Window:CreateTab{
        Title = "Visual",
        Icon = "eye"
    }
}
Tabs.Main:CreateParagraph("Aligned Paragraph", {
    Title = "We not support in Lobby",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})
Library:Notify{
    Title = "Bruh",
    Content = "We didn't make script in Lobby",
    SubContent = "Go run in game",
    Duration = 10
}

-[[
E.R.P.O script
]]
