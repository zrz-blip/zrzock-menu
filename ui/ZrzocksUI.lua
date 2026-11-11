-- ============================================
-- ZRZOCKS UI (OVERWRITE Style)
-- ============================================
local ZrzocksUI = {}
ZrzocksUI.__index = ZrzocksUI

-- Палитра Cross Style
local THEME = {
    BgGlass    = Color3.fromRGB(10, 10, 12),
    BgSide     = Color3.fromRGB(16, 16, 20),
    BgElem     = Color3.fromRGB(24, 24, 28),
    BgHover    = Color3.fromRGB(36, 36, 42),
    Accent     = Color3.fromRGB(225, 25, 45),
    Accent2    = Color3.fromRGB(245, 245, 250),
    TextMain   = Color3.fromRGB(245, 245, 248),
    TextSub    = Color3.fromRGB(140, 140, 150),
    Stroke     = Color3.fromRGB(55, 55, 65),
}

function ZrzocksUI:CreateMenu(config)
    local self = setmetatable({}, ZrzocksUI)
    self.config = config or {}
    self.tabs = {}
    self.containers = {}
    self.connections = {}

    local gui = Instance.new("ScreenGui")
    gui.Name = "ZrzocksHub_" .. tostring(math.random(1, 9999))
    gui.ResetOnSpawn = false
    -- Безопасная инициализация для Xeno
    local ok, hui = pcall(gethui)
    if ok and hui then gui.Parent = hui
    else gui.Parent = game:GetService("CoreGui") end
    self.gui = gui

    -- Главная рамка
    local frame = Instance.new("Frame")
    frame.Size = config.Size or UDim2.fromOffset(600, 420)
    frame.Position = UDim2.new(0.5, -300, 0.5, -210)
    frame.BackgroundColor3 = THEME.BgGlass
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    self.frame = frame

    -- Диагональный градиент на обводке
    local mainStroke = Instance.new("UIStroke", frame)
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.2
    local grad = Instance.new("UIGradient", mainStroke)
    grad.Rotation = 45
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.Accent2),
        ColorSequenceKeypoint.new(1, THEME.Accent)
    })

    -- Заголовок
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = THEME.BgSide
    header.BorderSizePixel = 0
    header.Parent = frame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = (config.Icon or "") .. " " .. (config.Name or "Zrzocks Hub")
    title.TextColor3 = THEME.TextMain
    title.Font = Enum.Font.Code
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
    closeBtn.BackgroundColor3 = THEME.Accent
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = THEME.Accent2
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 14
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

    -- Кастомный Drag (только за Header)
    local dragging, dragStart, startPos
    self.connections[#self.connections+1] = header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    self.connections[#self.connections+1] = game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    self.connections[#self.connections+1] = game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Левая панель (Сайдбар)
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 130, 1, -50)
    leftPanel.Position = UDim2.new(0, 8, 0, 46)
    leftPanel.BackgroundColor3 = THEME.BgSide
    leftPanel.BackgroundTransparency = 0.1
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = frame
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 6)
    self.leftPanel = leftPanel

    -- Портрет Аватара
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 80, 0, 80)
    avatarFrame.Position = UDim2.new(0.5, -40, 0, 10)
    avatarFrame.BackgroundColor3 = THEME.BgElem
    avatarFrame.BackgroundTransparency = 0.2
    avatarFrame.Parent = leftPanel
    Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(0, 4)
    local avStroke = Instance.new("UIStroke", avatarFrame); avStroke.Color = THEME.Accent; avStroke.Thickness = 1.5

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, -4, 1, -4)
    avatarImage.Position = UDim2.new(0, 2, 0, 2)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Parent = avatarFrame
    Instance.new("UICorner", avatarImage).CornerRadius = UDim.new(0, 3)
    pcall(function()
        local thumb = game.Players:GetUserThumbnailAsync(game.Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        avatarImage.Image = thumb
    end)

    -- Список вкладок (UIListLayout)
    local tabList = Instance.new("Frame")
    tabList.Size = UDim2.new(1, -16, 1, -110)
    tabList.Position = UDim2.new(0, 8, 0, 98)
    tabList.BackgroundTransparency = 1
    tabList.Parent = leftPanel
    local listLayout = Instance.new("UIListLayout", tabList)
    listLayout.Padding = UDim.new(0, 4)
    self.tabList = tabList

    -- Контентная область
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -150, 1, -58)
    content.Position = UDim2.new(0, 142, 0, 46)
    content.BackgroundTransparency = 1
    content.Parent = frame
    self.content = content

    -- Контейнер уведомлений
    local notifContainer = Instance.new("Frame")
    notifContainer.Size = UDim2.new(0, 280, 1, 0)
    notifContainer.Position = UDim2.new(1, 10, 0, 0)
    notifContainer.BackgroundTransparency = 1
    notifContainer.Parent = gui
    self.notifContainer = notifContainer

    closeBtn.MouseButton1Click:Connect(function()
        for _, conn in ipairs(self.connections) do pcall(function() conn:Disconnect() end) end
        gui:Destroy()
    end)

    if config.ToggleKey then
        self.connections[#self.connections+1] = game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == config.ToggleKey then
                frame.Visible = not frame.Visible
            end
        end)
    end

    return self
end

function ZrzocksUI:AddTab(tabName)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = self.content
    self.containers[tabName] = container

    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1, 0, 0, 32)
    tab.BackgroundColor3 = THEME.BgElem
    tab.BackgroundTransparency = 0.2
    tab.Text = "  " .. tabName
    tab.TextColor3 = THEME.TextSub
    tab.Font = Enum.Font.Code
    tab.TextSize = 13
    tab.TextXAlignment = Enum.TextXAlignment.Left
    tab.Parent = self.tabList
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 4)

    tab.MouseButton1Click:Connect(function()
        for _, other in ipairs(self.tabs) do
            other.tab.BackgroundColor3 = THEME.BgElem
            other.tab.TextColor3 = THEME.TextSub
            self.containers[other.name].Visible = false
        end
        tab.BackgroundColor3 = THEME.Accent
        tab.TextColor3 = THEME.Accent2
        container.Visible = true
    end)

    table.insert(self.tabs, {tab = tab, name = tabName})
    if #self.tabs == 1 then
        tab.BackgroundColor3 = THEME.Accent
        tab.TextColor3 = THEME.Accent2
        container.Visible = true
    end
    return container
end

function ZrzocksUI:AddCard(config)
    local scroll = self.containers["Scripts"]
    if not scroll then return end

    -- Используем UIListLayout для автоматического выстраивания
    local hasLayout = scroll:FindFirstChildOfClass("UIListLayout")
    if not hasLayout then
        local l = Instance.new("UIListLayout", scroll)
        l.Padding = UDim.new(0, 6)
    end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -8, 0, 65)
    card.BackgroundColor3 = THEME.BgElem
    card.BackgroundTransparency = 0.1
    card.Parent = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

    local image = Instance.new("ImageLabel")
    image.Size = UDim2.new(0, 45, 0, 45)
    image.Position = UDim2.new(0, 10, 0.5, -22.5)
    image.BackgroundColor3 = config.Tone or THEME.BgElem
    image.BackgroundTransparency = 0.5
    image.Image = config.Image or ""
    image.Parent = card
    Instance.new("UICorner", image).CornerRadius = UDim.new(0, 4)

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -130, 0, 20)
    name.Position = UDim2.new(0, 65, 0, 12)
    name.BackgroundTransparency = 1
    name.Text = config.Name or "Unknown"
    name.TextColor3 = THEME.TextMain
    name.Font = Enum.Font.Code
    name.TextSize = 14
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = card

    local placeId = Instance.new("TextLabel")
    placeId.Size = UDim2.new(1, -130, 0, 15)
    placeId.Position = UDim2.new(0, 65, 0, 34)
    placeId.BackgroundTransparency = 1
    placeId.Text = "Place: " .. tostring(config.PlaceId or "N/A")
    placeId.TextColor3 = THEME.TextSub
    placeId.Font = Enum.Font.Code
    placeId.TextSize = 11
    placeId.TextXAlignment = Enum.TextXAlignment.Left
    placeId.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 30)
    btn.Position = UDim2.new(1, -70, 0.5, -15)
    btn.BackgroundColor3 = THEME.Accent
    btn.Text = config.ButtonText or "Run"
    btn.TextColor3 = THEME.Accent2
    btn.Font = Enum.Font.Code
    btn.TextSize = 13
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)
end

function ZrzocksUI:AddButton(tabName, config)
    local container = self.containers[tabName]
    if not container then return end

    local hasLayout = container:FindFirstChildOfClass("UIListLayout")
    if not hasLayout then
        local l = Instance.new("UIListLayout", container)
        l.Padding = UDim.new(0, 6)
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 36)
    btn.BackgroundColor3 = THEME.BgElem
    btn.BackgroundTransparency = 0.1
    btn.Text = config.Text or "Button"
    btn.TextColor3 = THEME.TextMain
    btn.Font = Enum.Font.Code
    btn.TextSize = 13
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    if config.Callback then
        btn.MouseButton1Click:Connect(config.Callback)
    end
    return btn
end

function ZrzocksUI:AddLabel(tabName, text)
    local container = self.containers[tabName]
    if not container then return end

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = THEME.TextSub
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container
    return lbl
end

function ZrzocksUI:AddTextBox(tabName, config)
    local container = self.containers[tabName]
    if not container then return end

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -8, 0, 38)
    holder.BackgroundColor3 = THEME.BgElem
    holder.BackgroundTransparency = 0.1
    holder.Parent = container
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 4)
    local hStroke = Instance.new("UIStroke", holder); hStroke.Color = THEME.Stroke; hStroke.Thickness = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 90, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (config.Label or "") .. ":"
    label.TextColor3 = THEME.TextSub
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -110, 1, -8)
    box.Position = UDim2.new(0, 102, 0, 4)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    box.Text = config.Text or ""
    box.TextColor3 = THEME.TextMain
    box.Font = Enum.Font.Code
    box.TextSize = 12
    box.ClearTextOnFocus = false
    box.Parent = holder
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 2)

    box.Focused:Connect(function() TweenService:Create(hStroke, TweenInfo.new(0.1), {Color = THEME.Accent}):Play() end)
    box.FocusLost:Connect(function()
        TweenService:Create(hStroke, TweenInfo.new(0.1), {Color = THEME.Stroke}):Play()
        if config.Callback then config.Callback(box.Text) end
    end)
    return box
end

function ZrzocksUI:Notify(config)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, -10, 0, 60)
    notif.Position = UDim2.new(0, 5, 0, 0)
    notif.BackgroundColor3 = THEME.BgGlass
    notif.BackgroundTransparency = 0.1
    notif.Parent = self.notifContainer
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 4)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Zrzocks Hub"
    title.TextColor3 = THEME.TextMain
    title.Font = Enum.Font.Code
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notif

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -20, 0, 20)
    desc.Position = UDim2.new(0, 12, 0, 32)
    desc.BackgroundTransparency = 1
    desc.Text = config.Description or ""
    desc.TextColor3 = THEME.TextSub
    desc.Font = Enum.Font.Code
    desc.TextSize = 12
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = notif

    task.delay(config.Duration or 5, function()
        notif:Destroy()
    end)
end

return ZrzocksUI
