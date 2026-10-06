if game.PlaceId ~= 10272636261 then return end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local Config = {
    Flags = {
        KeyCollect = false,
        Attract = false,
        AutoBuy = false,
        Collector = false,
        Fly = false,
        Speed = false,
        GodMode = false,
        Noclip = false,
        InfJump = false,
        AntiAFK = false,
        LeafTeleport = false,
    },
    Settings = {
        FlySpeed = 50,
        CollectorDelay = 5,
        SpeedValue = 100,
    },
    Theme = {
        Background = Color3.fromRGB(34, 22, 17),
        Panel = Color3.fromRGB(25, 16, 12),
        Card = Color3.fromRGB(28, 18, 14),
        Text = Color3.fromRGB(230, 200, 170),
        TextDim = Color3.fromRGB(170, 150, 140),
        Accent = Color3.fromRGB(255, 200, 100),
        Success = Color3.fromRGB(50, 120, 50),
        Danger = Color3.fromRGB(200, 50, 50),
        Idle = Color3.fromRGB(30, 30, 50),
    },
    Threads = {},
    Connections = {},
}

function Config:RegisterThread(name, thread)
    if self.Threads[name] then
        pcall(function() task.cancel(self.Threads[name]) end)
    end
    self.Threads[name] = thread
end

function Config:StopThread(name)
    if self.Threads[name] then
        pcall(function() task.cancel(self.Threads[name]) end)
        self.Threads[name] = nil
    end
end

function Config:RegisterConnection(name, conn)
    if self.Connections[name] then
        pcall(function() self.Connections[name]:Disconnect() end)
    end
    self.Connections[name] = conn
end

function Config:StopConnection(name)
    if self.Connections[name] then
        pcall(function() self.Connections[name]:Disconnect() end)
        self.Connections[name] = nil
    end
end

function Config:StopAll()
    for name, thread in pairs(self.Threads) do
        pcall(function() task.cancel(thread) end)
    end
    for name, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Threads = {}
    self.Connections = {}
end

local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function safeFind(name)
    return workspace:FindFirstChild(name)
end

local Features = {}

function Features:StartAntiAFK()
    if Config.Threads.AntiAFK then return end
    Config:RegisterThread("AntiAFK", task.spawn(function()
        while Config.Flags.AntiAFK do
            task.wait(30)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(500, 400))
            end)
        end
    end))
end

function Features:StartKeyCollect()
    if Config.Threads.KeyCollect then return end
    Config:RegisterThread("KeyCollect", task.spawn(function()
        while Config.Flags.KeyCollect do
            local hrp = getHRP()
            if not hrp then task.wait(1) continue end
            local keyFolder = safeFind("KeyFolder")
            if not keyFolder then task.wait(2) continue end
            local startPos = hrp.CFrame
            for _, key in pairs(keyFolder:GetChildren()) do
                if not Config.Flags.KeyCollect then break end
                if not key:IsA("BasePart") then continue end
                local click = key:FindFirstChild("ClickDetector")
                if not click then continue end
                hrp.CFrame = CFrame.new(key.Position + Vector3.new(0, 2, 0))
                task.wait(0.15)
                pcall(function() click:Click() end)
                task.wait(0.15)
                hrp.CFrame = startPos
                task.wait(0.15)
            end
            task.wait(1)
        end
    end))
end

function Features:StartAttract()
    if Config.Threads.Attract then return end
    Config:RegisterThread("Attract", task.spawn(function()
        while Config.Flags.Attract do
            task.wait(0.1)
            local hrp = getHRP()
            if not hrp then break end
            local crateFolder = safeFind("CrateFolder")
            if crateFolder then
                for _, obj in pairs(crateFolder:GetChildren()) do
                    if obj:IsA("BasePart") and obj.Name:lower():find("crate") then
                        local dist = (obj.Position - hrp.Position).Magnitude
                        if dist > 2 and dist < 1000 then
                            pcall(function()
                                obj.Velocity = (hrp.Position - obj.Position).Unit * 120
                            end)
                            if dist > 50 then
                                pcall(function()
                                    obj.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2, 0))
                                end)
                            end
                        end
                    end
                end
            end
        end
    end))
end

function Features:StartAutoBuy()
    if Config.Threads.AutoBuy then return end
    Config:RegisterThread("AutoBuy", task.spawn(function()
        while Config.Flags.AutoBuy do
            task.wait(0.3)
            local hrp = getHRP()
            if not hrp then continue end
            local allButtons = safeFind("AllButtons")
            if not allButtons then continue end
            for _, part in pairs(allButtons:GetChildren()) do
                if part:IsA("BasePart") then
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 0.5, 0))
                    task.wait(0.15)
                end
            end
        end
    end))
end

function Features:StartCollector()
    if Config.Threads.Collector then return end
    Config:RegisterThread("Collector", task.spawn(function()
        while Config.Flags.Collector do
            local hrp = getHRP()
            if hrp then
                local zones = safeFind("Zones")
                if zones then
                    for _, zone in pairs(zones:GetChildren()) do
                        if zone:IsA("Folder") then
                            local allModels = zone:FindFirstChild("AllModels")
                            if allModels then
                                local cashGiver = allModels:FindFirstChild("CashGiver")
                                if cashGiver then
                                    local target = nil
                                    for _, child in pairs(cashGiver:GetDescendants()) do
                                        if child:IsA("BasePart") and child:FindFirstChild("TouchInterest") then
                                            target = child
                                            break
                                        end
                                    end
                                    if target then
                                        local saved = hrp.CFrame
                                        hrp.CFrame = CFrame.new(target.Position + Vector3.new(-1.5, 0.5, 0))
                                        task.wait(0.15)
                                        hrp.CFrame = saved
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(Config.Settings.CollectorDelay)
        end
    end))
end

function Features:StartGodMode()
    if Config.Threads.GodMode then return end
    Config:RegisterThread("GodMode", task.spawn(function()
        while Config.Flags.GodMode do
            task.wait(0.1)
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    if not Config._origHealth then
                        Config._origHealth = humanoid.MaxHealth
                    end
                    humanoid.MaxHealth = 9e9
                    humanoid.Health = 9e9
                end
            end
        end
    end))
end

function Features:StopGodMode()
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            local orig = Config._origHealth or 100
            humanoid.MaxHealth = orig
            humanoid.Health = orig
            Config._origHealth = nil
        end
    end
end

function Features:StartNoclip()
    if Config.Threads.Noclip then return end
    Config:RegisterThread("Noclip", task.spawn(function()
        while Config.Flags.Noclip do
            task.wait(0.1)
            if player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end))
end

function Features:StopNoclip()
    if player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function Features:StartFly()
    if Config.Threads.Fly then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animate = char:FindFirstChild("Animate")
    if animate then animate.Disabled = true end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return end

    if torso:FindFirstChild("FlyGyro") then torso.FlyGyro:Destroy() end
    if torso:FindFirstChild("FlyVelocity") then torso.FlyVelocity:Destroy() end

    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    bg.Parent = torso

    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyVelocity"
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = torso

    hum.PlatformStand = true

    local flyControl = {f = 0, b = 0, l = 0, r = 0}
    local speed = 0

    local conn1 = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode
            if key == Enum.KeyCode.W then flyControl.f = 1
            elseif key == Enum.KeyCode.S then flyControl.b = -1
            elseif key == Enum.KeyCode.A then flyControl.l = -1
            elseif key == Enum.KeyCode.D then flyControl.r = 1 end
        end
    end)

    local conn2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode
            if key == Enum.KeyCode.W then flyControl.f = 0
            elseif key == Enum.KeyCode.S then flyControl.b = 0
            elseif key == Enum.KeyCode.A then flyControl.l = 0
            elseif key == Enum.KeyCode.D then flyControl.r = 0 end
        end
    end)

    local heartbeat = RunService.Heartbeat:Connect(function()
        if not Config.Flags.Fly or not player.Character or not torso or not torso.Parent then
            return
        end
        if flyControl.l + flyControl.r ~= 0 or flyControl.f + flyControl.b ~= 0 then
            speed = speed + 0.5 + (speed / Config.Settings.FlySpeed)
            if speed > Config.Settings.FlySpeed then speed = Config.Settings.FlySpeed end
        else
            if speed ~= 0 then
                speed = speed - 1
                if speed < 0 then speed = 0 end
            end
        end
        local cam = workspace.CurrentCamera
        if (flyControl.l + flyControl.r) ~= 0 or (flyControl.f + flyControl.b) ~= 0 then
            bv.velocity = ((cam.CFrame.LookVector * (flyControl.f + flyControl.b)) +
                ((cam.CFrame * CFrame.new(flyControl.l + flyControl.r, (flyControl.f + flyControl.b) * 0.2, 0).p) - cam.CFrame.p)) * speed
        else
            bv.velocity = Vector3.new(0, 0, 0)
        end
        bg.cframe = cam.CFrame * CFrame.Angles(-math.rad((flyControl.f + flyControl.b) * 50 * speed / Config.Settings.FlySpeed), 0, 0)
    end)

    Config:RegisterConnection("FlyConn1", conn1)
    Config:RegisterConnection("FlyConn2", conn2)
    Config:RegisterConnection("FlyHeartbeat", heartbeat)
    Config:RegisterThread("Fly", task.spawn(function()
        while Config.Flags.Fly do
            task.wait(0.1)
        end
        if heartbeat then heartbeat:Disconnect() end
        if conn1 then conn1:Disconnect() end
        if conn2 then conn2:Disconnect() end
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        if hum and hum.Parent then hum.PlatformStand = false end
        if animate and animate.Parent then animate.Disabled = false end
    end))
end

function Features:StartSpeed()
    if Config.Threads.Speed then return end
    Config:RegisterThread("Speed", task.spawn(function()
        while Config.Flags.Speed do
            task.wait(0.1)
            if player.Character then
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = Config.Settings.SpeedValue
                end
            end
        end
    end))
end

function Features:StopSpeed()
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end

function Features:StartInfJump()
    if Config.Connections.InfJump then return end
    local conn = UserInputService.JumpRequest:Connect(function()
        if Config.Flags.InfJump and player.Character then
            pcall(function()
                player.Character.Humanoid:ChangeState("Jumping")
            end)
        end
    end)
    Config:RegisterConnection("InfJump", conn)
end

function Features:StartLeafTeleport()
    if Config.Threads.LeafTeleport then return end
    Config:RegisterThread("LeafTeleport", task.spawn(function()
        while Config.Flags.LeafTeleport do
            local hrp = getHRP()
            if hrp then
                local folder = safeFind("FallLeavesFolder")
                if folder then
                    local nearest = nil
                    local minDist = math.huge
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj:IsA("MeshPart") and obj.Name == "MapleLeaf" then
                            local dist = (obj.Position - hrp.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                nearest = obj
                            end
                        end
                    end
                    if nearest then
                        hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 2, 0))
                    end
                end
            end
            task.wait(0.3)
        end
    end))
end

local Theme = {}
function Theme:CreateFrame(parent, config)
    local frame = Instance.new("Frame")
    frame.Size = config.Size or UDim2.new(0, 100, 0, 100)
    frame.Position = config.Position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = config.Color or Config.Theme.Background
    frame.BackgroundTransparency = config.Transparency or 0.08
    frame.BorderSizePixel = 0
    frame.Parent = parent
    if config.Corner then
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, config.Corner)
    end
    return frame
end

function Theme:CreateButton(parent, config)
    local btn = Instance.new("TextButton")
    btn.Size = config.Size or UDim2.new(0, 100, 0, 26)
    btn.Position = config.Position or UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = config.Color or Config.Theme.Idle
    btn.BorderSizePixel = 0
    btn.Text = config.Text or "Button"
    btn.TextColor3 = config.TextColor or Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, config.Corner or 5)
    return btn
end

function Theme:CreateLabel(parent, config)
    local lbl = Instance.new("TextLabel")
    lbl.Size = config.Size or UDim2.new(1, 0, 0, 16)
    lbl.Position = config.Position or UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = config.Text or "Label"
    lbl.TextColor3 = config.Color or Config.Theme.Text
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = config.Align or Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

function Theme:CreateTextBox(parent, config)
    local box = Instance.new("TextBox")
    box.Size = config.Size or UDim2.new(0, 60, 0, 22)
    box.Position = config.Position or UDim2.new(0, 0, 0, 0)
    box.BackgroundColor3 = Config.Theme.Idle
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = config.Text or ""
    box.TextScaled = true
    box.Font = Enum.Font.GothamBold
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    return box
end

local UI = {}
UI.__index = UI

function UI:Create()
    local self = setmetatable({}, UI)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZrzocksHub"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")
    self.gui = gui

    local frame = Theme:CreateFrame(gui, {
        Size = UDim2.new(0, 550, 0, 430),
        Position = UDim2.new(0.5, -275, 0.5, -215),
        Corner = 12,
    })
    self.frame = frame

    local leftPanel = Theme:CreateFrame(frame, {
        Size = UDim2.new(0, 130, 1, 0),
        Color = Config.Theme.Panel,
        Transparency = 0.15,
        Corner = 12,
    })
    self.leftPanel = leftPanel

    Theme:CreateLabel(leftPanel, {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 10, 0, 6),
        Text = "Zrzocks Hub",
        Color = Config.Theme.Text,
    })

    local closeBtn = Theme:CreateButton(frame, {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -32, 0, 5),
        Color = Color3.fromRGB(50, 30, 30),
        Text = "✕",
        TextColor = Color3.fromRGB(255, 100, 100),
        Corner = 4,
    })
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    self.tabs = {}
    self.containers = {}
    self.tabY = 42

    return self
end

function UI:AddTab(name)
    local btn = Theme:CreateButton(self.leftPanel, {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 0, self.tabY),
        Color = Config.Theme.Panel,
        Text = "  " .. name,
    })
    btn.BackgroundTransparency = 0.8
    btn.TextColor3 = Config.Theme.TextDim
    btn.TextXAlignment = Enum.TextXAlignment.Left
    self.tabY = self.tabY + 31

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -140, 1, -15)
    container.Position = UDim2.new(0, 135, 0, 8)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = Config.Theme.Accent
    container.Visible = false
    container.Parent = self.frame

    self.tabs[name] = btn
    self.containers[name] = container

    btn.MouseButton1Click:Connect(function()
        for tn, tb in pairs(self.tabs) do
            local selected = (tn == name)
            tb.BackgroundColor3 = selected and Color3.fromRGB(50, 35, 28) or Config.Theme.Panel
            tb.BackgroundTransparency = selected and 0.3 or 0.8
            tb.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or Config.Theme.TextDim
            self.containers[tn].Visible = selected
        end
    end)

    if #self.tabs == 1 then
        btn.BackgroundColor3 = Color3.fromRGB(50, 35, 28)
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        container.Visible = true
    end

    return container
end

function UI:AddButton(parent, config)
    local btn = Theme:CreateButton(parent, {
        Size = config.Size or UDim2.new(0.9, 0, 0, 26),
        Position = config.Position or UDim2.new(0.05, 0, 0, 0),
        Color = config.Color or Config.Theme.Idle,
        Text = config.Text or "Button",
    })
    if config.Callback then
        btn.MouseButton1Click:Connect(config.Callback)
    end
    return btn
end

function UI:AddLabel(parent, text, y)
    return Theme:CreateLabel(parent, {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, y),
        Text = text,
        Color = Config.Theme.Accent,
    })
end

function UI:AddTextBox(parent, config)
    return Theme:CreateTextBox(parent, config)
end

local ui = UI:Create()

local mainTab = ui:AddTab("Main")
local extrasTab = ui:AddTab("Extras")

local yMain = 5

ui:AddLabel(mainTab, "Crate Attractor", yMain)
yMain = yMain + 20
local attractBtn = ui:AddButton(mainTab, {
    Position = UDim2.new(0.05, 0, 0, yMain),
    Text = "ATTRACT (OFF)",
    Callback = function()
        Config.Flags.Attract = not Config.Flags.Attract
        attractBtn.Text = Config.Flags.Attract and "ATTRACT (ON)" or "ATTRACT (OFF)"
        attractBtn.BackgroundColor3 = Config.Flags.Attract and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.Attract then Features:StartAttract() else Config:StopThread("Attract") end
    end,
})
yMain = yMain + 30

ui:AddLabel(mainTab, "Key Collector", yMain)
yMain = yMain + 20
local keyBtn = ui:AddButton(mainTab, {
    Position = UDim2.new(0.05, 0, 0, yMain),
    Text = "COLLECT KEYS (OFF)",
    Callback = function()
        Config.Flags.KeyCollect = not Config.Flags.KeyCollect
        keyBtn.Text = Config.Flags.KeyCollect and "COLLECT KEYS (ON)" or "COLLECT KEYS (OFF)"
        keyBtn.BackgroundColor3 = Config.Flags.KeyCollect and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.KeyCollect then Features:StartKeyCollect() else Config:StopThread("KeyCollect") end
    end,
})
yMain = yMain + 30

ui:AddLabel(mainTab, "Auto Buy", yMain)
yMain = yMain + 20
local autoBuyBtn = ui:AddButton(mainTab, {
    Position = UDim2.new(0.05, 0, 0, yMain),
    Text = "AUTO BUY (OFF)",
    Callback = function()
        Config.Flags.AutoBuy = not Config.Flags.AutoBuy
        autoBuyBtn.Text = Config.Flags.AutoBuy and "AUTO BUY (ON)" or "AUTO BUY (OFF)"
        autoBuyBtn.BackgroundColor3 = Config.Flags.AutoBuy and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.AutoBuy then Features:StartAutoBuy() else Config:StopThread("AutoBuy") end
    end,
})
yMain = yMain + 30

ui:AddLabel(mainTab, "Auto Collector", yMain)
yMain = yMain + 20
local collectorBtn = ui:AddButton(mainTab, {
    Position = UDim2.new(0.05, 0, 0, yMain),
    Text = "COLLECTOR (OFF)",
    Callback = function()
        Config.Flags.Collector = not Config.Flags.Collector
        collectorBtn.Text = Config.Flags.Collector and "COLLECTOR (ON)" or "COLLECTOR (OFF)"
        collectorBtn.BackgroundColor3 = Config.Flags.Collector and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.Collector then Features:StartCollector() else Config:StopThread("Collector") end
    end,
})
yMain = yMain + 30

ui:AddLabel(mainTab, "Leaf Teleport", yMain)
yMain = yMain + 20
local leafBtn = ui:AddButton(mainTab, {
    Position = UDim2.new(0.05, 0, 0, yMain),
    Text = "LEAF TELEPORT (OFF)",
    Callback = function()
        Config.Flags.LeafTeleport = not Config.Flags.LeafTeleport
        leafBtn.Text = Config.Flags.LeafTeleport and "LEAF TELEPORT (ON)" or "LEAF TELEPORT (OFF)"
        leafBtn.BackgroundColor3 = Config.Flags.LeafTeleport and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.LeafTeleport then Features:StartLeafTeleport() else Config:StopThread("LeafTeleport") end
    end,
})
yMain = yMain + 30

mainTab.CanvasSize = UDim2.new(0, 0, 0, yMain + 20)

local yExtra = 5

ui:AddLabel(extrasTab, "Speed", yExtra)
yExtra = yExtra + 20
local speedBtn = ui:AddButton(extrasTab, {
    Position = UDim2.new(0.05, 0, 0, yExtra),
    Text = "SPEED (OFF)",
    Callback = function()
        Config.Flags.Speed = not Config.Flags.Speed
        speedBtn.Text = Config.Flags.Speed and "SPEED (ON)" or "SPEED (OFF)"
        speedBtn.BackgroundColor3 = Config.Flags.Speed and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.Speed then Features:StartSpeed() else Features:StopSpeed() Config:StopThread("Speed") end
    end,
})
yExtra = yExtra + 30

ui:AddLabel(extrasTab, "Fly", yExtra)
yExtra = yExtra + 20
local flyBtn = ui:AddButton(extrasTab, {
    Position = UDim2.new(0.05, 0, 0, yExtra),
    Text = "FLY (OFF)",
    Callback = function()
        Config.Flags.Fly = not Config.Flags.Fly
        flyBtn.Text = Config.Flags.Fly and "FLY (ON)" or "FLY (OFF)"
        flyBtn.BackgroundColor3 = Config.Flags.Fly and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.Fly then Features:StartFly() else Config:StopThread("Fly") end
    end,
})
yExtra = yExtra + 30

ui:AddLabel(extrasTab, "Anti-AFK", yExtra)
yExtra = yExtra + 20
local afkBtn = ui:AddButton(extrasTab, {
    Position = UDim2.new(0.05, 0, 0, yExtra),
    Text = "ANTI-AFK (OFF)",
    Callback = function()
        Config.Flags.AntiAFK = not Config.Flags.AntiAFK
        afkBtn.Text = Config.Flags.AntiAFK and "ANTI-AFK (ON)" or "ANTI-AFK (OFF)"
        afkBtn.BackgroundColor3 = Config.Flags.AntiAFK and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.AntiAFK then Features:StartAntiAFK() else Config:StopThread("AntiAFK") end
    end,
})
yExtra = yExtra + 30

ui:AddLabel(extrasTab, "God Mode", yExtra)
yExtra = yExtra + 20
local godBtn = ui:AddButton(extrasTab, {
    Position = UDim2.new(0.05, 0, 0, yExtra),
    Text = "GOD MODE (OFF)",
    Callback = function()
        Config.Flags.GodMode = not Config.Flags.GodMode
        godBtn.Text = Config.Flags.GodMode and "GOD MODE (ON)" or "GOD MODE (OFF)"
        godBtn.BackgroundColor3 = Config.Flags.GodMode and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.GodMode then Features:StartGodMode() else Features:StopGodMode() Config:StopThread("GodMode") end
    end,
})
yExtra = yExtra + 30

ui:AddLabel(extrasTab, "Noclip", yExtra)
yExtra = yExtra + 20
local noclipBtn = ui:AddButton(extrasTab, {
    Position = UDim2.new(0.05, 0, 0, yExtra),
    Text = "NOCLIP (OFF)",
    Callback = function()
        Config.Flags.Noclip = not Config.Flags.Noclip
        noclipBtn.Text = Config.Flags.Noclip and "NOCLIP (ON)" or "NOCLIP (OFF)"
        noclipBtn.BackgroundColor3 = Config.Flags.Noclip and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.Noclip then Features:StartNoclip() else Features:StopNoclip() Config:StopThread("Noclip") end
    end,
})
yExtra = yExtra + 30

ui:AddLabel(extrasTab, "Inf Jump", yExtra)
yExtra = yExtra + 20
local jumpBtn = ui:AddButton(extrasTab, {
    Position = UDim2.new(0.05, 0, 0, yExtra),
    Text = "INF JUMP (OFF)",
    Callback = function()
        Config.Flags.InfJump = not Config.Flags.InfJump
        jumpBtn.Text = Config.Flags.InfJump and "INF JUMP (ON)" or "INF JUMP (OFF)"
        jumpBtn.BackgroundColor3 = Config.Flags.InfJump and Config.Theme.Success or Config.Theme.Idle
        if Config.Flags.InfJump then Features:StartInfJump() else Config:StopConnection("InfJump") end
    end,
})
yExtra = yExtra + 30

extrasTab.CanvasSize = UDim2.new(0, 0, 0, yExtra + 20)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if Config.Flags.Fly then
        Config:StopThread("Fly")
        Config:StopConnection("FlyConn1")
        Config:StopConnection("FlyConn2")
        Config:StopConnection("FlyHeartbeat")
        Features:StartFly()
    end
    if Config.Flags.Noclip then
        Config:StopThread("Noclip")
        Features:StartNoclip()
    end
    if Config.Flags.GodMode then
        Config:StopThread("GodMode")
        Features:StartGodMode()
    end
    if Config.Flags.Speed then
        Config:StopThread("Speed")
        Features:StartSpeed()
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        ui.gui.Enabled = not ui.gui.Enabled
    end
end)
