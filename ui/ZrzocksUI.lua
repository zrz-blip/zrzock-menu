local ZrzocksUI = {}
ZrzocksUI.__index = ZrzocksUI

function ZrzocksUI:CreateMenu(config)
    local self = setmetatable({}, ZrzocksUI)
    self.config = config or {}
    self.cards = {}
    self.tabs = {}
    self.containers = {}

    local gui = Instance.new("ScreenGui")
    gui.Name = "ZrzocksHub"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")
    self.gui = gui

    local frame = Instance.new("Frame")
    frame.Size = config.Size or UDim2.fromOffset(600, 420)
    frame.Position = UDim2.new(0.5, -300, 0.5, -210)
    frame.BackgroundColor3 = Color3.fromRGB(34, 22, 17)
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    self.frame = frame

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = Color3.fromRGB(25, 16, 12)
    header.BorderSizePixel = 0
    header.Parent = frame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = (config.Icon or "⚡") .. " " .. (config.Name or "Zrzocks Hub")
    title.TextColor3 = Color3.fromRGB(230, 200, 170)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -28, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 120, 1, -42)
    leftPanel.Position = UDim2.new(0, 0, 0, 42)
    leftPanel.BackgroundColor3 = Color3.fromRGB(25, 16, 12)
    leftPanel.BackgroundTransparency = 0.3
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = frame
    self.leftPanel = leftPanel

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -130, 1, -50)
    content.Position = UDim2.new(0, 125, 0, 42)
    content.BackgroundTransparency = 1
    content.Parent = frame
    self.content = content

    local notifContainer = Instance.new("Frame")
    notifContainer.Size = UDim2.new(0, 280, 1, 0)
    notifContainer.Position = UDim2.new(1, 10, 0, 0)
    notifContainer.BackgroundTransparency = 1
    notifContainer.Parent = gui
    self.notifContainer = notifContainer

    if config.ToggleKey then
        game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == config.ToggleKey then
                frame.Visible = not frame.Visible
            end
        end)
    end

    return self
end

function ZrzocksUI:AddTab(tabName)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1, -10, 0, 26)
    tab.Position = UDim2.new(0, 5, 0, 8 + (#self.tabs * 30))
    tab.BackgroundColor3 = Color3.fromRGB(25, 16, 12)
    tab.BackgroundTransparency = 0.8
    tab.BorderSizePixel = 0
    tab.Text = "  " .. tabName
    tab.TextColor3 = Color3.fromRGB(170, 150, 140)
    tab.TextScaled = true
    tab.Font = Enum.Font.GothamBold
    tab.TextXAlignment = Enum.TextXAlignment.Left
    tab.Parent = self.leftPanel
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 5)

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 100)
    container.Visible = false
    container.Parent = self.content
    self.containers[tabName] = container

    tab.MouseButton1Click:Connect(function()
        for _, otherTab in ipairs(self.tabs) do
            otherTab.tab.BackgroundColor3 = Color3.fromRGB(25, 16, 12)
            otherTab.tab.BackgroundTransparency = 0.8
            otherTab.tab.TextColor3 = Color3.fromRGB(170, 150, 140)
            self.containers[otherTab.name].Visible = false
        end
        tab.BackgroundColor3 = Color3.fromRGB(50, 35, 28)
        tab.BackgroundTransparency = 0.3
        tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        container.Visible = true
    end)

    table.insert(self.tabs, {tab = tab, name = tabName})

    if #self.tabs == 1 then
        tab.BackgroundColor3 = Color3.fromRGB(50, 35, 28)
        tab.BackgroundTransparency = 0.3
        tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        container.Visible = true
    end

    return container
end

function ZrzocksUI:AddCard(cardConfig)
    local scroll = self.containers["Scripts"]
    if not scroll then return end

    local grid = scroll:FindFirstChildOfClass("UIGridLayout")
    if not grid then
        grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0, 220, 0, 200)
        grid.CellPadding = UDim2.new(0, 8, 0, 8)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = scroll
    end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 220, 0, 200)
    card.BackgroundColor3 = Color3.fromRGB(28, 18, 14)
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local image = Instance.new("ImageLabel")
    image.Size = UDim2.new(1, -8, 0, 110)
    image.Position = UDim2.new(0, 4, 0, 4)
    image.BackgroundColor3 = cardConfig.Tone or Color3.fromRGB(50, 50, 50)
    image.BackgroundTransparency = 1
    image.Image = cardConfig.Image or ""
    image.ScaleType = Enum.ScaleType.Crop
    image.BorderSizePixel = 0
    image.Parent = card
    Instance.new("UICorner", image).CornerRadius = UDim.new(0, 6)

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -8, 0, 18)
    name.Position = UDim2.new(0, 4, 0, 118)
    name.BackgroundTransparency = 1
    name.Text = cardConfig.Name or "Unknown"
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextScaled = true
    name.Font = Enum.Font.GothamBold
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = card

    local placeId = Instance.new("TextLabel")
    placeId.Size = UDim2.new(1, -8, 0, 14)
    placeId.Position = UDim2.new(0, 4, 0, 138)
    placeId.BackgroundTransparency = 1
    placeId.Text = "Place: " .. tostring(cardConfig.PlaceId or "N/A")
    placeId.TextColor3 = Color3.fromRGB(180, 160, 150)
    placeId.TextScaled = true
    placeId.Font = Enum.Font.Gotham
    placeId.TextXAlignment = Enum.TextXAlignment.Left
    placeId.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 26)
    btn.Position = UDim2.new(0, 4, 1, -30)
    btn.BackgroundColor3 = cardConfig.Tone or Color3.fromRGB(50, 120, 50)
    btn.BorderSizePixel = 0
    btn.Text = cardConfig.ButtonText or "Run"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if cardConfig.Callback then
            cardConfig.Callback()
        end
    end)
end

function ZrzocksUI:AddButton(tabName, config)
    local container = self.containers[tabName]
    if not container then return end

    local btn = Instance.new("TextButton")
    btn.Size = config.Size or UDim2.new(0.9, 0, 0, 26)
    btn.Position = config.Position or UDim2.new(0.05, 0, 0, config.Y or 0)
    btn.BackgroundColor3 = config.Color or Color3.fromRGB(30, 30, 50)
    btn.BorderSizePixel = 0
    btn.Text = config.Text or "Button"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    if config.Callback then
        btn.MouseButton1Click:Connect(config.Callback)
    end
    return btn
end

function ZrzocksUI:AddLabel(tabName, text, y)
    local container = self.containers[tabName]
    if not container then return end

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container
    return lbl
end

function ZrzocksUI:AddTextBox(tabName, config)
    local container = self.containers[tabName]
    if not container then return end

    local box = Instance.new("TextBox")
    box.Size = config.Size or UDim2.new(0.9, 0, 0, 22)
    box.Position = config.Position or UDim2.new(0.05, 0, 0, config.Y or 0)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = config.Text or ""
    box.TextScaled = true
    box.Font = Enum.Font.GothamBold
    box.Parent = container
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

    if config.Callback then
        box.FocusLost:Connect(function()
            config.Callback(box.Text)
        end)
    end
    return box
end

function ZrzocksUI:Notify(config)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, -10, 0, 60)
    notif.Position = UDim2.new(0, 5, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(28, 18, 14)
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    notif.Parent = self.notifContainer
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Zrzocks Hub"
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notif

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -20, 0, 20)
    desc.Position = UDim2.new(0, 10, 0, 32)
    desc.BackgroundTransparency = 1
    desc.Text = config.Description or ""
    desc.TextColor3 = Color3.fromRGB(220, 200, 190)
    desc.TextScaled = true
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = notif

    task.delay(config.Duration or 5, function()
        notif:Destroy()
    end)
end

return ZrzocksUI
