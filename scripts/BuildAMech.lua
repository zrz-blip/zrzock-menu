local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local player = LocalPlayer

local parentContainer
local ok, hui = pcall(gethui)
if ok and hui then parentContainer = hui
else parentContainer = game:GetService("CoreGui") end

local function randomString(len)
    local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    local res = ""
    for _ = 1, len do res = res .. string.sub(chars, math.random(1, #chars), math.random(1, #chars)) end
    return res
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomString(12)
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentContainer

pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
    if protectgui then protectgui(ScreenGui) end
end)

getgenv().__OverwriteLoaded = ScreenGui

local THEME = {
    BgGlass    = Color3.fromRGB(10, 10, 12),
    BgSide     = Color3.fromRGB(16, 16, 20),
    BgElem     = Color3.fromRGB(24, 24, 28),
    BgHover    = Color3.fromRGB(36, 36, 42),
    Accent     = Color3.fromRGB(225, 25, 45),
    Accent2    = Color3.fromRGB(245, 245, 250),
    AccentGlow = Color3.fromRGB(255, 60, 80),
    Danger     = Color3.fromRGB(200, 20, 40),
    Success    = Color3.fromRGB(235, 235, 240),
    TextMain   = Color3.fromRGB(245, 245, 248),
    TextSub    = Color3.fromRGB(140, 140, 150),
    Stroke     = Color3.fromRGB(55, 55, 65),
}

local Config = {
    WalkSpeed = 16, JumpPower = 50, FlySpeed = 50, FOV = 70,
    Noclip = false, Fullbright = false, AntiAFK = false, CustomStatus = "OVERWRITE",
    Fly = false, MechFarm = false
}
local ConfigPath = "Overwrite_Config.json"

local function SaveConfig()
    pcall(function()
        local saveData = {}
        for k, v in pairs(Config) do
            if k ~= "Fly" and k ~= "MechFarm" then saveData[k] = v end
        end
        if writefile then writefile(ConfigPath, HttpService:JSONEncode(saveData)) end
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and isfile(ConfigPath) and readfile then
            local data = readfile(ConfigPath)
            if data and data ~= "" then
                local decoded = HttpService:JSONDecode(data)
                for k, v in pairs(decoded) do Config[k] = v end
            end
        end
        Config.Fly = false
        Config.MechFarm = false
    end)
end
LoadConfig()

local Connections = {}
local function AddConnection(conn) table.insert(Connections, conn) end
local function DisconnectAll()
    for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
    Connections = {}
end

local NotifyHolder = Instance.new("Frame", ScreenGui)
NotifyHolder.Name = randomString(8)
NotifyHolder.Size = UDim2.new(0, 300, 1, 0)
NotifyHolder.Position = UDim2.new(1, -310, 0, 20)
NotifyHolder.BackgroundTransparency = 1
local notifyLayout = Instance.new("UIListLayout", NotifyHolder)
notifyLayout.Padding = UDim.new(0, 8)
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function Notify(title, message, kind)
    kind = kind or "info"
    local color = (kind == "success" and THEME.Success) or (kind == "danger" and THEME.Danger) or THEME.Accent
    local frame = Instance.new("Frame", NotifyHolder)
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = THEME.BgGlass
    frame.BackgroundTransparency = 0.1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke", frame); stroke.Color = color; stroke.Thickness = 1.5; stroke.Transparency = 0.3
    local bar = Instance.new("Frame", frame); bar.Size = UDim2.new(0, 4, 1, -12); bar.Position = UDim2.new(0, 6, 0, 6); bar.BackgroundColor3 = color
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local t = Instance.new("TextLabel", frame); t.Size = UDim2.new(1, -30, 0, 20); t.Position = UDim2.new(0, 18, 0, 8); t.BackgroundTransparency = 1; t.Text = title; t.TextColor3 = THEME.TextMain; t.Font = Enum.Font.Code; t.TextSize = 14; t.TextXAlignment = Enum.TextXAlignment.Left
    local m = Instance.new("TextLabel", frame); m.Size = UDim2.new(1, -30, 0, 20); m.Position = UDim2.new(0, 18, 0, 28); m.BackgroundTransparency = 1; m.Text = message; m.TextColor3 = THEME.TextSub; m.Font = Enum.Font.Code; m.TextSize = 12; m.TextXAlignment = Enum.TextXAlignment.Left

    frame.Position = UDim2.new(1, 0, 0, 0)
    TweenService:Create(frame, TweenInfo.new(0.15), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(4, function()
        if frame.Parent then
            TweenService:Create(frame, TweenInfo.new(0.15), {Position = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(0.2)
            if frame.Parent then frame:Destroy() end
        end
    end)
end

local isExpanded = false
local isFullyHidden = false
local ToggleKey = Enum.KeyCode.RightControl

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 340, 0, 46)
MainFrame.Position = UDim2.new(0.5, -170, 0, 16)
MainFrame.BackgroundColor3 = THEME.BgGlass
MainFrame.BackgroundTransparency = 0.05
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
local gradMain = Instance.new("UIGradient", MainStroke)
gradMain.Rotation = 45
gradMain.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, THEME.Accent2),
    ColorSequenceKeypoint.new(1, THEME.Accent)
})

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 46)
TopBar.BackgroundTransparency = 1

local dragging, dragStart, startPos
AddConnection(TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end))
AddConnection(TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end))
AddConnection(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

local PulseDot = Instance.new("Frame", TopBar)
PulseDot.Size = UDim2.new(0, 10, 0, 10)
PulseDot.Position = UDim2.new(0, 18, 0.5, -5)
PulseDot.BackgroundColor3 = THEME.Accent
Instance.new("UICorner", PulseDot).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    while PulseDot.Parent do
        TweenService:Create(PulseDot, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {BackgroundColor3 = THEME.Accent2, Size = UDim2.new(0, 12, 0, 12)}):Play()
        task.wait(0.1)
        if not PulseDot.Parent then break end
        TweenService:Create(PulseDot, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {BackgroundColor3 = THEME.Accent, Size = UDim2.new(0, 10, 0, 10)}):Play()
        task.wait(0.8)
    end
end)

local DockTitle = Instance.new("TextLabel", TopBar)
DockTitle.Size = UDim2.new(0, 200, 1, 0); DockTitle.Position = UDim2.new(0, 38, 0, 0)
DockTitle.BackgroundTransparency = 1; DockTitle.Text = Config.CustomStatus
DockTitle.TextColor3 = THEME.TextMain; DockTitle.Font = Enum.Font.Code; DockTitle.TextSize = 15
DockTitle.TextXAlignment = Enum.TextXAlignment.Left

local FpsLabel = Instance.new("TextLabel", TopBar)
FpsLabel.Size = UDim2.new(0, 80, 1, 0); FpsLabel.Position = UDim2.new(0, 155, 0, 0)
FpsLabel.BackgroundTransparency = 1; FpsLabel.Text = "0 FPS"
FpsLabel.TextColor3 = THEME.TextSub; FpsLabel.Font = Enum.Font.Code; FpsLabel.TextSize = 12
FpsLabel.TextXAlignment = Enum.TextXAlignment.Left

local ExpandBtn = Instance.new("TextButton", TopBar)
ExpandBtn.Size = UDim2.new(0, 70, 0, 28); ExpandBtn.Position = UDim2.new(1, -80, 0.5, -14)
ExpandBtn.BackgroundColor3 = THEME.Accent; ExpandBtn.Text = "OPEN"
ExpandBtn.TextColor3 = THEME.Accent2; ExpandBtn.Font = Enum.Font.Code; ExpandBtn.TextSize = 13; ExpandBtn.AutoButtonColor = false
Instance.new("UICorner", ExpandBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = THEME.Danger; CloseBtn.Text = "✕"
CloseBtn.TextColor3 = THEME.Accent2; CloseBtn.Font = Enum.Font.Code; CloseBtn.TextSize = 14; CloseBtn.Visible = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local BodyContainer = Instance.new("Frame", MainFrame)
BodyContainer.Size = UDim2.new(1, -16, 1, -58); BodyContainer.Position = UDim2.new(0, 8, 0, 52)
BodyContainer.BackgroundTransparency = 1; BodyContainer.Visible = false

local Sidebar = Instance.new("Frame", BodyContainer)
Sidebar.Size = UDim2.new(0, 130, 1, 0); Sidebar.BackgroundColor3 = THEME.BgSide; Sidebar.BackgroundTransparency = 0.1
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

local avatarFrame = Instance.new("Frame", Sidebar)
avatarFrame.Size = UDim2.new(0, 80, 0, 80)
avatarFrame.Position = UDim2.new(0.5, -40, 0, 10)
avatarFrame.BackgroundColor3 = THEME.BgElem
avatarFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(0, 4)

local avatarStroke = Instance.new("UIStroke", avatarFrame)
avatarStroke.Color = THEME.Accent; avatarStroke.Thickness = 1.5

local avatarImage = Instance.new("ImageLabel", avatarFrame)
avatarImage.Size = UDim2.new(1, -4, 1, -4)
avatarImage.Position = UDim2.new(0, 2, 0, 2)
avatarImage.BackgroundTransparency = 1
Instance.new("UICorner", avatarImage).CornerRadius = UDim.new(0, 3)

pcall(function()
    local thumb = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    avatarImage.Image = thumb
end)

local TabList = Instance.new("Frame", Sidebar)
TabList.Size = UDim2.new(1, -12, 1, -100)
TabList.Position = UDim2.new(0, 6, 0, 98)
TabList.BackgroundTransparency = 1
Instance.new("UIListLayout", TabList).Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame", BodyContainer)
ContentArea.Size = UDim2.new(1, -138, 1, 0); ContentArea.Position = UDim2.new(0, 138, 0, 0)
ContentArea.BackgroundTransparency = 1

local function ToggleDockState(forceState)
    if forceState ~= nil then isExpanded = forceState else isExpanded = not isExpanded end
    if isExpanded then
        ExpandBtn.Text = "HIDE"
        TweenService:Create(ExpandBtn, TweenInfo.new(0.15), {Position = UDim2.new(1, -110, 0.5, -14), BackgroundColor3 = THEME.BgElem, TextColor3 = THEME.TextMain}):Play()
        CloseBtn.Visible = true; BodyContainer.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 560, 0, 400),
            Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset - 110, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset),
        }):Play()
    else
        ExpandBtn.Text = "OPEN"
        TweenService:Create(ExpandBtn, TweenInfo.new(0.15), {Position = UDim2.new(1, -80, 0.5, -14), BackgroundColor3 = THEME.Accent, TextColor3 = THEME.Accent2}):Play()
        CloseBtn.Visible = false
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 340, 0, 46),
            Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + 110, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset),
        })
        tw:Play()
        AddConnection(tw.Completed:Connect(function() if not isExpanded then BodyContainer.Visible = false end end))
    end
end
AddConnection(ExpandBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainStroke, TweenInfo.new(0.05), {Transparency = 0}):Play()
    task.wait(0.05)
    TweenService:Create(MainStroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
    ToggleDockState()
end))

local pages, tabBtns = {}, {}

local function CreateTab(name)
    local btn = Instance.new("TextButton", TabList)
    btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundColor3 = THEME.BgElem; btn.BackgroundTransparency = 0.2
    btn.Text = "  " .. name; btn.TextColor3 = THEME.TextSub; btn.Font = Enum.Font.Code; btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.ScrollBarThickness = 2; page.ScrollBarImageColor3 = THEME.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.Visible = false
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 6)

    AddConnection(btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, b in pairs(tabBtns) do TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = THEME.BgElem, TextColor3 = THEME.TextSub}):Play() end
        page.Visible = true
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.Accent, TextColor3 = THEME.Accent2}):Play()
    end))
    table.insert(pages, page); table.insert(tabBtns, btn)
    if #pages == 1 then page.Visible = true; btn.BackgroundColor3 = THEME.Accent; btn.TextColor3 = THEME.Accent2 end
    return page
end

local function AddLabel(page, text)
    local lbl = Instance.new("TextLabel", page); lbl.Size = UDim2.new(1, -8, 0, 20); lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.TextColor3 = THEME.TextSub; lbl.Font = Enum.Font.Code; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddSection(page, text)
    local lbl = Instance.new("TextLabel", page); lbl.Size = UDim2.new(1, -8, 0, 18); lbl.BackgroundTransparency = 1; lbl.Text = "-- " .. text .. " --"
    lbl.TextColor3 = THEME.Accent; lbl.Font = Enum.Font.Code; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddToggle(page, text, configKey, callback)
    local state = Config[configKey] or false
    local holder = Instance.new("TextButton", page)
    holder.Size = UDim2.new(1, -8, 0, 38); holder.BackgroundColor3 = THEME.BgElem; holder.BackgroundTransparency = 0.1
    holder.Text = "   " .. text; holder.TextColor3 = THEME.TextMain; holder.Font = Enum.Font.Code; holder.TextSize = 13
    holder.TextXAlignment = Enum.TextXAlignment.Left; holder.AutoButtonColor = false
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 4)
    
    local hStroke = Instance.new("UIStroke", holder); hStroke.Color = THEME.Stroke; hStroke.Thickness = 1
    local pill = Instance.new("Frame", holder); pill.Size = UDim2.new(0, 36, 0, 18); pill.Position = UDim2.new(1, -46, 0.5, -9)
    pill.BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(45, 45, 50)
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 2)

    local knob = Instance.new("Frame", pill); knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = THEME.Accent2
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 1)

    local function update()
        TweenService:Create(pill, TweenInfo.new(0.1), {BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(45, 45, 50)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.1), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        TweenService:Create(hStroke, TweenInfo.new(0.1), {Color = state and THEME.Accent or THEME.Stroke}):Play()
    end

    AddConnection(holder.MouseButton1Click:Connect(function()
        state = not state; Config[configKey] = state; update()
        if callback then callback(state) end
    end))
    if callback then task.spawn(function() callback(state) end) end
end

local function AddSlider(page, text, min, max, configKey, callback)
    local default = Config[configKey] or min
    local frame = Instance.new("Frame", page); frame.Size = UDim2.new(1, -8, 0, 50); frame.BackgroundColor3 = THEME.BgElem; frame.BackgroundTransparency = 0.1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    local fStroke = Instance.new("UIStroke", frame); fStroke.Color = THEME.Stroke; fStroke.Thickness = 1

    local lbl = Instance.new("TextLabel", frame); lbl.Size = UDim2.new(1, -20, 0, 24); lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1; lbl.Text = text .. ": " .. default; lbl.TextColor3 = THEME.TextMain; lbl.Font = Enum.Font.Code; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("TextButton", frame); bar.Size = UDim2.new(1, -20, 0, 6); bar.Position = UDim2.new(0, 10, 0, 34)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 46); bar.Text = ""; bar.AutoButtonColor = false
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 1)
    
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = THEME.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 1)
    local grad = Instance.new("UIGradient", fill); grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, THEME.Accent2), ColorSequenceKeypoint.new(1, THEME.Accent)})

    local dragging = false
    local function update(input)
        local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pct)
        fill.Size = UDim2.new(pct, 0, 1, 0); lbl.Text = text .. ": " .. val
        Config[configKey] = val
        if callback then callback(val) end
    end
    AddConnection(bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i) end end))
    AddConnection(UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
    AddConnection(UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end))
    if callback then task.spawn(function() callback(default) end) end
end

local function AddButton(page, text, callback)
    local btn = Instance.new("TextButton", page); btn.Size = UDim2.new(1, -8, 0, 36); btn.BackgroundColor3 = THEME.BgElem; btn.BackgroundTransparency = 0.1
    btn.Text = text; btn.TextColor3 = THEME.TextMain; btn.Font = Enum.Font.Code; btn.TextSize = 13; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke", btn); bStroke.Color = THEME.Stroke; bStroke.Thickness = 1

    AddConnection(btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.BgHover}):Play(); TweenService:Create(bStroke, TweenInfo.new(0.1), {Color = THEME.Accent}):Play() end))
    AddConnection(btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.BgElem}):Play(); TweenService:Create(bStroke, TweenInfo.new(0.1), {Color = THEME.Stroke}):Play() end))
    AddConnection(btn.MouseButton1Click:Connect(function() if callback then callback() end end))
    return btn
end

local function AddKeybind(page, text, defaultKey, callback)
    local holder = Instance.new("Frame", page); holder.Size = UDim2.new(1, -8, 0, 38); holder.BackgroundColor3 = THEME.BgElem; holder.BackgroundTransparency = 0.1
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 4)
    local label = Instance.new("TextLabel", holder); label.Size = UDim2.new(1, -100, 1, 0); label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = THEME.TextMain; label.Font = Enum.Font.Code; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyBtn = Instance.new("TextButton", holder); keyBtn.Size = UDim2.new(0, 80, 0, 26); keyBtn.Position = UDim2.new(1, -88, 0.5, -13)
    keyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40); keyBtn.Text = tostring(defaultKey):gsub("Enum.KeyCode.", "")
    keyBtn.TextColor3 = THEME.Accent; keyBtn.Font = Enum.Font.Code; keyBtn.TextSize = 12; keyBtn.AutoButtonColor = false
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 4)

    local currentKey = defaultKey
    local isListening = false
    local tempConn

    AddConnection(keyBtn.MouseButton1Click:Connect(function()
        isListening = true; keyBtn.Text = "..."
        if tempConn then tempConn:Disconnect() end
        tempConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp or not isListening then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyBtn.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
                isListening = false
                if callback then callback(currentKey) end
                tempConn:Disconnect()
            end
        end)
        AddConnection(tempConn)
    end))
end

local function AddTextBox(page, text, default, callback)
    local holder = Instance.new("Frame", page); holder.Size = UDim2.new(1, -8, 0, 38); holder.BackgroundColor3 = THEME.BgElem; holder.BackgroundTransparency = 0.1
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 4)
    local hStroke = Instance.new("UIStroke", holder); hStroke.Color = THEME.Stroke; hStroke.Thickness = 1
    
    local label = Instance.new("TextLabel", holder); label.Size = UDim2.new(0, 90, 1, 0); label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1; label.Text = text .. ":"; label.TextColor3 = THEME.TextSub; label.Font = Enum.Font.Code; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox", holder); box.Size = UDim2.new(1, -110, 1, -8); box.Position = UDim2.new(0, 102, 0, 4)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 40); box.BackgroundTransparency = 0.2; box.Text = default or ""
    box.PlaceholderText = "..."; box.PlaceholderColor3 = THEME.TextSub; box.TextColor3 = THEME.TextMain
    box.Font = Enum.Font.Code; box.TextSize = 12; box.TextXAlignment = Enum.TextXAlignment.Left; box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 2)
    local pad = Instance.new("UIPadding", box); pad.PaddingLeft = UDim.new(0, 6)

    AddConnection(box.Focused:Connect(function() TweenService:Create(hStroke, TweenInfo.new(0.1), {Color = THEME.Accent}):Play() end))
    AddConnection(box.FocusLost:Connect(function() TweenService:Create(hStroke, TweenInfo.new(0.1), {Color = THEME.Stroke}):Play(); if callback then callback(box.Text) end end))
end

local Universal = { Noclip = false, AntiAFK = false, Fly = false, MechFarm = false }
local originalLighting = {}
local flyConnection
local flyParts = {}

AddConnection(LocalPlayer.Idled:Connect(function()
    if Universal.AntiAFK then
        pcall(function() local vu = game:GetService("VirtualUser"); vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
    end
end))

AddConnection(RunService.Stepped:Connect(function()
    if Universal.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

local function ToggleNoclip(state)
    Universal.Noclip = state
    if not state and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local function SetFullbright(state)
    pcall(function()
        if state then
            originalLighting.Brightness = Lighting.Brightness; originalLighting.ClockTime = Lighting.ClockTime; originalLighting.FogEnd = Lighting.FogEnd; originalLighting.GlobalShadows = Lighting.GlobalShadows; originalLighting.Ambient = Lighting.Ambient
            Lighting.Brightness = 2; Lighting.ClockTime = 12; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            if originalLighting.Brightness then
                Lighting.Brightness = originalLighting.Brightness; Lighting.ClockTime = originalLighting.ClockTime; Lighting.FogEnd = originalLighting.FogEnd; Lighting.GlobalShadows = originalLighting.GlobalShadows; Lighting.Ambient = originalLighting.Ambient
            end
        end
    end)
end

local function SetSpeed(val) pcall(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end end) end
local function SetJump(val) pcall(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = val end end) end

local function ToggleFly(state)
    Universal.Fly = state
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if state then
        hum.PlatformStand = true
        local att = Instance.new("Attachment", hrp)
        local ao = Instance.new("AlignOrientation", hrp); ao.Attachment0 = att; ao.Mode = Enum.OrientationAlignmentMode.OneAttachment; ao.MaxTorque = 9e9; ao.Responsiveness = 200; ao.Name = "OverwriteFlyAO"
        local lv = Instance.new("LinearVelocity", hrp); lv.Attachment0 = att; lv.MaxForce = 9e9; lv.VectorVelocity = Vector3.new(0,0,0); lv.Name = "OverwriteFlyLV"
        flyParts = {att = att, ao = ao, lv = lv}

        flyConnection = RunService.RenderStepped:Connect(function()
            if not Universal.Fly or not hrp.Parent then return end
            local cam = workspace.CurrentCamera
            local move = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end
            lv.VectorVelocity = move * Config.FlySpeed
            ao.CFrame = cam.CFrame
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        hum.PlatformStand = false
        for _, v in pairs(flyParts) do pcall(function() v:Destroy() end) end
        flyParts = {}
    end
end

AddConnection(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    SetSpeed(Config.WalkSpeed)
    SetJump(Config.JumpPower)
    if Universal.Fly then ToggleFly(false); task.wait(0.2); ToggleFly(true) end
end))

AddConnection(RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            if hum.WalkSpeed ~= Config.WalkSpeed then hum.WalkSpeed = Config.WalkSpeed end
            if hum.JumpPower ~= Config.JumpPower and hum.UseJumpPower then hum.JumpPower = Config.JumpPower end
        end
    end
end))

local selectedArenaMode = "AUTO"
local ARENA_LIST = {
    "AUTO", "Level1_ScrapYard", "Level2_RustyRails", "Level3_MesaPeaks", "Level3_SkylineHeights",
    "Level4_ToxicBog", "Level5_OutpostZero", "Level6_FrostPeak", "Level7_MagmaCore", "Level8_CyberGrid",
    "Level9_KaijuBay", "Level10_EmpireCity", "Level11_StarfallRock"
}
local arenaIndex = 1
local METAL_TYPES = {"Scrap", "Light", "Medium", "Heavy", "Colossal", "Titan"}
local enabledMetals = { scrap = true, light = true, medium = true, heavy = true, colossal = true, titan = true }

local function getMyDropZone()
    local plots = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        local signBoard = plot:FindFirstChild("OwnerSignBoard")
        local plotSign = signBoard and signBoard:FindFirstChild("PlotSign")
        local ownerSign = plotSign and plotSign:FindFirstChild("OwnerSign")
        local label = ownerSign and (ownerSign:IsA("TextLabel") and ownerSign or ownerSign:FindFirstChildWhichIsA("TextLabel", true))
        if label and label.Text:find(player.DisplayName, 1, true) then
            return plot:FindFirstChild("DropZone", true) or plot:FindFirstChild("Pad", true)
        end
    end
    return nil
end

local function getCargoDetails()
    local pg = player:FindFirstChild("PlayerGui")
    local hud = pg and pg:FindFirstChild("MechHud")
    local cargoHold = hud and hud:FindFirstChild("CargoHold")
    local isTotalFull = false
    local isLowHealth = false
    local currentTotal = 0
    local fullCategories = {}
    if cargoHold then
        local cargoLabel = cargoHold:FindFirstChild("TextLabel")
        if cargoLabel then
            local cur, max = cargoLabel.Text:match("(%d+)%s*/%s*(%d+)")
            cur, max = tonumber(cur), tonumber(max)
            if cur and max and max > 0 then
                currentTotal = cur
                if cur >= max then isTotalFull = true end
            end
        end
        local healthFrame = cargoHold:FindFirstChild("Health")
        local healthLabel = healthFrame and healthFrame:FindFirstChild("TextLabel")
        if healthLabel then
            local curHp, maxHp = healthLabel.Text:match("(%d+)%s*/%s*(%d+)")
            curHp, maxHp = tonumber(curHp), tonumber(maxHp)
            if curHp and maxHp and maxHp > 0 then
                if (curHp / maxHp) <= 0.3 then isLowHealth = true end
            end
        end
        local contents = cargoHold:FindFirstChild("Contents")
        if contents then
            for _, itemFrame in ipairs(contents:GetChildren()) do
                if itemFrame:IsA("GuiObject") and itemFrame.Visible then
                    for _, lbl in ipairs(itemFrame:GetChildren()) do
                        if lbl:IsA("TextLabel") then
                            local c, m = lbl.Text:match("(%d+)%s*/%s*(%d+)")
                            c, m = tonumber(c), tonumber(m)
                            if c and m and m > 0 and c >= m then fullCategories[itemFrame.Name:lower()] = true end
                        end
                    end
                end
            end
        end
    end
    return isTotalFull, isLowHealth, currentTotal, fullCategories
end

local function getActiveMechData()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Sit and hum.SeatPart then
        local seat = hum.SeatPart
        local current = seat.Parent
        while current and current ~= workspace do
            if current:IsA("Model") and current.Parent == workspace then
                local root = current.PrimaryPart or current:FindFirstChild("Root") or current:FindFirstChild("HumanoidRootPart") or current:FindFirstChild("Chassis") or seat
                return root, current
            end
            current = current.Parent
        end
    end
    return nil, nil
end

local function moveMechTo(mechRoot, mechModel, targetPos, extraOffset)
    if not mechRoot or not mechModel then return end
    local yOffset = extraOffset or 3.5
    for _, part in ipairs(mechModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
        end
    end
    mechRoot.CFrame = CFrame.new(targetPos + Vector3.new(0, yOffset, 0))
end

local function detectPileMetalKey(pile)
    local attrs = pile:GetAttributes()
    for _, v in pairs(attrs) do
        local strVal = tostring(v):lower()
        for _, mType in ipairs(METAL_TYPES) do
            local mLower = mType:lower()
            if strVal == mLower or strVal:find(mLower, 1, true) then return mLower end
        end
    end
    local lowerName = pile.Name:lower()
    for _, mType in ipairs(METAL_TYPES) do
        local mLower = mType:lower()
        if lowerName:find(mLower, 1, true) then return mLower end
    end
    for _, desc in ipairs(pile:GetDescendants()) do
        if desc:IsA("TextLabel") then
            local txt = desc.Text:lower()
            for _, mType in ipairs(METAL_TYPES) do
                local mLower = mType:lower()
                if txt:find(mLower, 1, true) then return mLower end
            end
        end
    end
    return ""
end

local function getPileTargetPosition(pile)
    local pileCenter = pile:FindFirstChild("PileCenter")
    if pileCenter and pileCenter:IsA("BasePart") then return pileCenter.Position end
    if pile:IsA("Model") then
        local cf, _ = pile:GetBoundingBox()
        return cf.Position
    end
    local anyPart = pile:FindFirstChildWhichIsA("BasePart", true)
    return anyPart and anyPart.Position or nil
end

local function getTargetArenaPiles(mechPos, fullCats)
    local arenas = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Arenas")
    if not arenas then return nil end
    if selectedArenaMode ~= "AUTO" then
        local specificArena = arenas:FindFirstChild(selectedArenaMode)
        return specificArena and specificArena:FindFirstChild("PartPiles")
    end
    local bestMatchingPiles = nil
    local bestMatchingScore = -1
    local nearestAnyPiles = nil
    local minDist = math.huge
    for _, arena in ipairs(arenas:GetChildren()) do
        local piles = arena:FindFirstChild("PartPiles")
        local children = piles and piles:GetChildren()
        if children and #children > 0 then
            local matchingCount = 0
            local samplePos = nil
            for _, p in ipairs(children) do
                if not samplePos then samplePos = getPileTargetPosition(p) end
                local k = detectPileMetalKey(p)
                local cnt = p:GetAttribute("Count")
                local isEmpty = (cnt ~= nil and tonumber(cnt) <= 0)
                local isCatFull = (k ~= "" and fullCats and fullCats[k] == true)
                local isWanted = (k == "" or enabledMetals[k] == true)
                if isWanted and not isEmpty and not isCatFull then matchingCount = matchingCount + 1 end
            end
            if matchingCount > bestMatchingScore then
                bestMatchingScore = matchingCount
                bestMatchingPiles = piles
            end
            if samplePos then
                local dist = (samplePos - mechPos).Magnitude
                if dist < minDist then minDist = dist; nearestAnyPiles = piles end
            end
        end
    end
    if bestMatchingScore > 0 and bestMatchingPiles then return bestMatchingPiles end
    return nearestAnyPiles
end

local function returnToDropOff()
    local dropZone = getMyDropZone()
    if not dropZone then return end
    local startWait = os.clock()
    while Universal.MechFarm and (os.clock() - startWait < 6) do
        local mechRoot, mechModel = getActiveMechData()
        if not mechRoot then break end
        moveMechTo(mechRoot, mechModel, dropZone.Position, 4.5)
        local _, _, curCargo = getCargoDetails()
        if curCargo == 0 then break end
        task.wait(0.25)
    end
end

local function startMechFarmLoop()
    while Universal.MechFarm do
        local mechRoot, mechModel = getActiveMechData()
        if not mechRoot then
            task.wait(0.5)
        else
            local isFull, isLowHp, _, fullCats = getCargoDetails()
            if isFull or isLowHp then
                returnToDropOff()
            else
                local partPiles = getTargetArenaPiles(mechRoot.Position, fullCats)
                if partPiles then
                    local children = partPiles:GetChildren()
                    local collectedAny = false
                    for _, pile in ipairs(children) do
                        if not Universal.MechFarm then break end
                        mechRoot, mechModel = getActiveMechData()
                        if not mechRoot then break end
                        local fullNow, lowHpNow, _, catsNow = getCargoDetails()
                        if fullNow or lowHpNow then returnToDropOff(); collectedAny = true; break end
                        local kindKey = detectPileMetalKey(pile)
                        local count = pile:GetAttribute("Count")
                        local isSelected = (kindKey == "" or enabledMetals[kindKey] == true)
                        local isCategoryFull = (kindKey ~= "" and catsNow[kindKey] == true)
                        local isPileEmpty = (count ~= nil and tonumber(count) <= 0)
                        if isSelected and not isCategoryFull and not isPileEmpty then
                            local targetPos = getPileTargetPosition(pile)
                            if targetPos then
                                moveMechTo(mechRoot, mechModel, targetPos, 3.5)
                                collectedAny = true
                                task.wait(0.25)
                            end
                        end
                    end
                    if not collectedAny then
                        local _, _, curTotal = getCargoDetails()
                        if curTotal > 0 then returnToDropOff() else task.wait(0.5) end
                    end
                else
                    task.wait(0.5)
                end
            end
        end
        task.wait(0.15)
    end
end

local tabMovement = CreateTab("Movement")
local tabMech = CreateTab("Mech Farm")
local tabVisuals = CreateTab("Visuals")
local tabMisc = CreateTab("Misc")
local tabSettings = CreateTab("Settings")

AddSection(tabMovement, "CHARACTER")
AddSlider(tabMovement, "WalkSpeed", 16, 300, "WalkSpeed", SetSpeed)
AddSlider(tabMovement, "JumpPower", 50, 300, "JumpPower", SetJump)
AddToggle(tabMovement, "Fly", "Fly", ToggleFly)
AddSlider(tabMovement, "Fly Speed", 10, 200, "FlySpeed", function() end)
AddToggle(tabMovement, "Noclip", "Noclip", ToggleNoclip)

AddSection(tabMech, "AUTO FARM")
AddToggle(tabMech, "Enable Mech Farm", "MechFarm", function(s)
    Universal.MechFarm = s
    if s then task.spawn(startMechFarmLoop) end
end)

local arenaBtnRef = AddButton(tabMech, "Arena: AUTO", function()
    arenaIndex = (arenaIndex % #ARENA_LIST) + 1
    selectedArenaMode = ARENA_LIST[arenaIndex]
    if arenaBtnRef then
        arenaBtnRef.Text = "Arena: " .. (selectedArenaMode == "AUTO" and "AUTO" or selectedArenaMode)
    end
end)

AddButton(tabMech, "Teleport to Base", function()
    local dropZone = getMyDropZone()
    if not dropZone then return end
    local mechRoot, mechModel = getActiveMechData()
    if mechRoot then
        moveMechTo(mechRoot, mechModel, dropZone.Position, 4.5)
    else
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(dropZone.Position + Vector3.new(0, 4, 0))
        end
    end
end)

AddSection(tabMech, "METAL FILTER")
for _, metalName in ipairs(METAL_TYPES) do
    local key = metalName:lower()
    AddToggle(tabMech, metalName, key, function(s) enabledMetals[key] = s end)
end

AddSection(tabVisuals, "LIGHTING")
AddToggle(tabVisuals, "Fullbright", "Fullbright", SetFullbright)
AddSection(tabVisuals, "CAMERA")
AddSlider(tabVisuals, "FOV", 70, 120, "FOV", function(v) pcall(function() workspace.CurrentCamera.FieldOfView = v end) end)

AddSection(tabMisc, "UTILITY")
AddToggle(tabMisc, "Anti-AFK", "AntiAFK", function(s) Universal.AntiAFK = s end)
AddButton(tabMisc, "Rejoin Server", function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end) end)
AddButton(tabMisc, "Server Hop", function()
    pcall(function()
        local Http = game:GetService("HttpService"); local Teleport = game:GetService("TeleportService")
        local servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, srv in ipairs(servers.data) do
            if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then Teleport:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer); return end
        end
    end)
end)

AddSection(tabSettings, "CONFIG")
AddKeybind(tabSettings, "Toggle Menu", ToggleKey, function(key) ToggleKey = key; Notify("Keybind", "Menu set to " .. tostring(key):gsub("Enum.KeyCode.", ""), "info") end)
AddTextBox(tabSettings, "Custom Status", Config.CustomStatus, function(text) Config.CustomStatus = text; DockTitle.Text = text ~= "" and text or "OVERWRITE" end)
AddButton(tabSettings, "Save Config", function() SaveConfig(); Notify("Config", "Settings saved", "success") end)
AddLabel(tabSettings, "OVERWRITE v8.0 — Mech Farm Edition")

local lastTime = os.clock()
local frameCount = 0
AddConnection(RunService.RenderStepped:Connect(function()
    frameCount += 1
    if os.clock() - lastTime >= 1 then FpsLabel.Text = frameCount .. " FPS"; frameCount = 0; lastTime = os.clock() end
end))

AddConnection(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == ToggleKey then isFullyHidden = not isFullyHidden; MainFrame.Visible = not isFullyHidden end
end))

AddConnection(CloseBtn.MouseButton1Click:Connect(function()
    if Universal.Fly then ToggleFly(false) end
    if Universal.Noclip then ToggleNoclip(false) end
    if Config.Fullbright then SetFullbright(false) end
    Universal.MechFarm = false
    DisconnectAll(); ScreenGui:Destroy()
end))

Notify("OVERWRITE", "Loaded. RightControl to hide.", "success")
print("=== OVERWRITE HUB READY ===")
