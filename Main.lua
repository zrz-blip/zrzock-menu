local GITHUB_USER = "zrz-blip"
local GITHUB_REPO = "zrzock-menu"
local GITHUB_BRANCH = "main"

local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/", GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)

local CATALOG = {
    {
        Key = "infinite_tower_tycoon",
        Name = "Infinite Tower Tycoon",
        Places = { 10272636261 },
        Script = "scripts/InfiniteTowerTycoon.lua",
        Tone = Color3.fromRGB(255, 180, 80),
        Image = "rbxassetid://106109636799806",
    },
    {
        Key = "silly_sword_game",
        Name = "Silly Sword Game",
        Places = { 10697845123 },
        Script = "scripts/SillySwordGame.lua",
        Tone = Color3.fromRGB(255, 100, 100),
        Image = "rbxassetid://0",
    },
}

local function launch(entry)
    local url = BASE_URL .. entry.Script
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url), "@" .. entry.Key)()
    end)
    return ok, result
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZrzocksHub"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(34, 22, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 16, 12)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Zrzocks Hub"
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -45)
Sidebar.Position = UDim2.new(0, 5, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 16, 12)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local Tabs = {}
local ActiveTab = nil
local Containers = {}

local function CreateTab(name, icon)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(34, 22, 17)
    Btn.BackgroundTransparency = 0.8
    Btn.BorderSizePixel = 0
    Btn.Text = "  " .. icon .. "  " .. name
    Btn.TextColor3 = Color3.fromRGB(170, 150, 140)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Sidebar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -155, 1, -45)
    Container.Position = UDim2.new(0, 150, 0, 40)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 6
    Container.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 100)
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.Visible = false
    Container.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = Container
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.PaddingBottom = UDim.new(0, 10)
    Padding.Parent = Container

    Containers[name] = Container

    Btn.MouseButton1Click:Connect(function()
        if ActiveTab == name then return end
        ActiveTab = name
        for tName, tBtn in pairs(Tabs) do
            tBtn.BackgroundTransparency = 0.8
            tBtn.TextColor3 = Color3.fromRGB(170, 150, 140)
            Containers[tName].Visible = false
        end
        Btn.BackgroundTransparency = 0.3
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Container.Visible = true
    end)

    Tabs[name] = Btn
    
    if not ActiveTab then
        ActiveTab = name
        Btn.BackgroundTransparency = 0.3
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Container.Visible = true
    end

    return Container
end

local ScriptsTab = CreateTab("Scripts", "📜")
local MiscTab = CreateTab("Misc", "⚙️")
local CreditsTab = CreateTab("Credits", "👑")

local function CreateButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = color or Color3.fromRGB(45, 30, 25)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function() if callback then callback() end end)
end

local function CreateToggle(parent, text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(45, 30, 25)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 40, 0, 20)
    Switch.Position = UDim2.new(1, -50, 0.5, -10)
    Switch.BackgroundColor3 = Color3.fromRGB(34, 22, 17)
    Switch.BorderSizePixel = 0
    Switch.Parent = Frame
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = UDim2.new(0, 2, 0.5, -8)
    Dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Dot.BorderSizePixel = 0
    Dot.Parent = Switch
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Frame

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        local TweenService = game:GetService("TweenService")
        if state then
            TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 200, 100)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(34, 22, 17)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        if callback then callback(state) end
    end)
end

for _, entry in ipairs(CATALOG) do
    CreateButton(ScriptsTab, "Run: " .. entry.Name, entry.Tone, function()
        local ok, err = launch(entry)
        if not ok then
            print("Error: " .. tostring(err))
        end
    end)
end

CreateToggle(MiscTab, "Anti-AFK", function(state)
    if state then
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end
end)

CreateToggle(MiscTab, "Dark Mode", function(state)
    if state then
        MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    else
        MainFrame.BackgroundColor3 = Color3.fromRGB(34, 22, 17)
        Sidebar.BackgroundColor3 = Color3.fromRGB(25, 16, 12)
        TopBar.BackgroundColor3 = Color3.fromRGB(25, 16, 12)
    end
end)

local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1, 0, 0, 45)
ProfileFrame.Position = UDim2.new(0, 0, 1, -50)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(20, 13, 10)
ProfileFrame.BackgroundTransparency = 0.5
ProfileFrame.BorderSizePixel = 0
ProfileFrame.Parent = Sidebar
Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 6)

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 30, 0, 30)
Avatar.Position = UDim2.new(0, 8, 0.5, -15)
Avatar.BackgroundColor3 = Color3.fromRGB(60, 40, 30)
Avatar.Parent = ProfileFrame
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. game.Players.LocalPlayer.UserId .. "&width=150&height=150&format=png"

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(0.6, 0, 0, 14)
NameLabel.Position = UDim2.new(0, 45, 0, 8)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = game.Players.LocalPlayer.DisplayName
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 12
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Parent = ProfileFrame

local UserLabel = Instance.new("TextLabel")
UserLabel.Size = UDim2.new(0.6, 0, 0, 12)
UserLabel.Position = UDim2.new(0, 45, 0, 24)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = "@" .. game.Players.LocalPlayer.Name
UserLabel.TextColor3 = Color3.fromRGB(150, 130, 120)
UserLabel.Font = Enum.Font.Gotham
UserLabel.TextSize = 11
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.Parent = ProfileFrame

local CredLabel = Instance.new("TextLabel")
CredLabel.Size = UDim2.new(1, -10, 0, 50)
CredLabel.Position = UDim2.new(0, 5, 0, 10)
CredLabel.BackgroundTransparency = 1
CredLabel.Text = "Zrzocks Hub\nCreated by zrzock"
CredLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CredLabel.Font = Enum.Font.GothamBold
CredLabel.TextSize = 14
CredLabel.Parent = CreditsTab
