if game.PlaceId ~= 10272636261 then return end
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local keyCollectEnabled = false
local attractEnabled = false
local speedEnabled = false
local godModeEnabled = false
local noclipEnabled = false
local jumpEnabled = false
local antiAFKEnabled = false
local autoBuyEnabled = false
local collectorEnabled = false
local flyEnabled = false
local flySpeed = 50
local collectorDelay = 5
local speedValue = 100
local isFolded = false

local function startAntiAFK()
    spawn(function()
        while antiAFKEnabled do
            wait(30)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(500, 400))
            end)
        end
    end)
end

local function collectKeys()
    spawn(function()
        while keyCollectEnabled do
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then wait(1) continue end
            local keyFolder = workspace:FindFirstChild("KeyFolder")
            if not keyFolder then wait(2) continue end
            local startPos = hrp.CFrame
            for _, key in pairs(keyFolder:GetChildren()) do
                if not keyCollectEnabled then break end
                if not key:IsA("BasePart") then continue end
                local click = key:FindFirstChild("ClickDetector")
                if not click then continue end
                hrp.CFrame = CFrame.new(key.Position + Vector3.new(0, 2, 0))
                wait(0.15)
                pcall(function() click:Click() end)
                wait(0.15)
                hrp.CFrame = startPos
                wait(0.15)
            end
            wait(1)
        end
    end)
end

local function startAttract()
    spawn(function()
        while attractEnabled do
            wait(0.1)
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then break end
            local crateFolder = workspace:FindFirstChild("CrateFolder")
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
    end)
end

local function startAutoBuy()
    spawn(function()
        while autoBuyEnabled do
            wait(0.3)
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local allButtons = workspace:FindFirstChild("AllButtons")
            if not allButtons then continue end
            for _, part in pairs(allButtons:GetChildren()) do
                if part:IsA("BasePart") then
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 0.5, 0))
                    wait(0.15)
                end
            end
        end
    end)
end

local function teleportToCollector()
    pcall(function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local startPos = hrp.CFrame
        local zoneNames = {"BlackZone", "BlueZone", "GreenZone", "OrangeZone", "RedZone", "YellowZone"}
        local collected = false
        local zones = workspace:FindFirstChild("Zones")
        if zones then
            for _, zoneName in pairs(zoneNames) do
                local zone = zones:FindFirstChild(zoneName)
                if zone then
                    local allModels = zone:FindFirstChild("AllModels")
                    if allModels then
                        local cashGiver = allModels:FindFirstChild("CashGiver")
                        if cashGiver and cashGiver:IsA("Model") then
                            local targetPart = nil
                            for _, child in pairs(cashGiver:GetDescendants()) do
                                if child:IsA("BasePart") and child:FindFirstChild("TouchInterest") then
                                    targetPart = child
                                    break
                                end
                            end
                            if not targetPart then
                                for _, child in pairs(cashGiver:GetDescendants()) do
                                    if child:IsA("BasePart") and child:FindFirstChild("ClickDetector") then
                                        targetPart = child
                                        break
                                    end
                                end
                            end
                            if not targetPart then
                                for _, child in pairs(cashGiver:GetDescendants()) do
                                    if child:IsA("BasePart") and not child.Name:lower():find("gui") and not child.Name:lower():find("text") then
                                        targetPart = child
                                        break
                                    end
                                end
                            end
                            if targetPart then
                                local pos = targetPart.Position
                                hrp.CFrame = CFrame.new(pos + Vector3.new(-1.5, 0.5, 0))
                                wait(0.15)
                                hrp.CFrame = startPos
                                wait(0.15)
                                collected = true
                                break
                            end
                        end
                    end
                end
            end
        end
        if not collected then
            local cashGiver = workspace:FindFirstChild("Zones")
            if cashGiver then
                cashGiver = cashGiver:FindFirstChild("BlueZone")
                if cashGiver then
                    cashGiver = cashGiver:FindFirstChild("AllModels")
                    if cashGiver then
                        cashGiver = cashGiver:FindFirstChild("CashGiver")
                    end
                end
            end
            if cashGiver and cashGiver:IsA("Model") then
                local targetPart = nil
                for _, child in pairs(cashGiver:GetDescendants()) do
                    if child:IsA("BasePart") and child:FindFirstChild("TouchInterest") then
                        targetPart = child
                        break
                    end
                end
                if targetPart then
                    local pos = targetPart.Position
                    hrp.CFrame = CFrame.new(pos + Vector3.new(-1.5, 0.5, 0))
                    wait(0.15)
                    hrp.CFrame = startPos
                end
            end
        end
    end)
end

local function startCollector()
    spawn(function()
        while collectorEnabled do
            teleportToCollector()
            wait(collectorDelay)
        end
    end)
end

local function startGodMode()
    spawn(function()
        while godModeEnabled do
            wait(0.1)
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = 9e9
                    humanoid.Health = 9e9
                end
            end
        end
    end)
end

local flyThread = nil
local flyConnections = {}
local flyControl = {f = 0, b = 0, l = 0, r = 0}

local function startFly()
    if flyThread then return end
    local plr = player
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animate = char:FindFirstChild("Animate")
    if animate then animate.Disabled = true end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return end
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    bg.Parent = torso
    local bv = Instance.new("BodyVelocity")
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = torso
    hum.PlatformStand = true
    local speed = 0
    local maxspeed = flySpeed
    flyThread = game:GetService("RunService").Heartbeat:Connect(function()
        if not flyEnabled or not plr.Character or not torso or not torso.Parent then
            return
        end
        if flyControl.l + flyControl.r ~= 0 or flyControl.f + flyControl.b ~= 0 then
            speed = speed + 0.5 + (speed / maxspeed)
            if speed > maxspeed then speed = maxspeed end
        elseif not (flyControl.l + flyControl.r ~= 0 or flyControl.f + flyControl.b ~= 0) and speed ~= 0 then
            speed = speed - 1
            if speed < 0 then speed = 0 end
        end
        local cam = workspace.CurrentCamera
        if (flyControl.l + flyControl.r) ~= 0 or (flyControl.f + flyControl.b) ~= 0 then
            bv.velocity = ((cam.CFrame.LookVector * (flyControl.f + flyControl.b)) + 
                ((cam.CFrame * CFrame.new(flyControl.l + flyControl.r, (flyControl.f + flyControl.b) * 0.2, 0).p) - cam.CFrame.p)) * speed
        else
            bv.velocity = Vector3.new(0, 0, 0)
        end
        bg.cframe = cam.CFrame * CFrame.Angles(-math.rad((flyControl.f + flyControl.b) * 50 * speed / maxspeed), 0, 0)
    end)
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode
            if key == Enum.KeyCode.W then flyControl.f = 1
            elseif key == Enum.KeyCode.S then flyControl.b = -1
            elseif key == Enum.KeyCode.A then flyControl.l = -1
            elseif key == Enum.KeyCode.D then flyControl.r = 1 end
        end
    end
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode
            if key == Enum.KeyCode.W then flyControl.f = 0
            elseif key == Enum.KeyCode.S then flyControl.b = 0
            elseif key == Enum.KeyCode.A then flyControl.l = 0
            elseif key == Enum.KeyCode.D then flyControl.r = 0 end
        end
    end
    local conn1 = UserInputService.InputBegan:Connect(onInputBegan)
    local conn2 = UserInputService.InputEnded:Connect(onInputEnded)
    flyConnections = {conn1, conn2}
end

local function stopFly()
    if flyThread then
        flyThread:Disconnect()
        flyThread = nil
    end
    for _, conn in pairs(flyConnections) do
        if conn then conn:Disconnect() end
    end
    flyConnections = {}
    flyControl = {f = 0, b = 0, l = 0, r = 0}
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        local animate = char:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                obj:Destroy()
            end
        end
    end
end

local function toggleFly()
    if flyEnabled then startFly() else stopFly() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "ZrzocksHub"
gui.Parent = game:GetService("CoreGui")
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 550, 0, 430)
frame.Position = UDim2.new(0.5, -275, 0.5, -215)
frame.BackgroundColor3 = Color3.fromRGB(34, 22, 17)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 130, 1, 0)
leftPanel.BackgroundColor3 = Color3.fromRGB(25, 16, 12)
leftPanel.BackgroundTransparency = 0.15
leftPanel.BorderSizePixel = 0
leftPanel.Parent = frame
Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 12)

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, -20, 0, 22)
logoText.Position = UDim2.new(0, 10, 0, 6)
logoText.BackgroundTransparency = 1
logoText.Text = "Zrzocks Hub"
logoText.TextColor3 = Color3.fromRGB(230, 200, 170)
logoText.TextScaled = true
logoText.Font = Enum.Font.GothamBold
logoText.TextXAlignment = Enum.TextXAlignment.Left
logoText.Parent = leftPanel

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.8, 0, 0, 1)
divider.Position = UDim2.new(0.1, 0, 0, 34)
divider.BackgroundColor3 = Color3.fromRGB(50, 35, 28)
divider.BorderSizePixel = 0
divider.Parent = leftPanel

local tabs = {"Main", "Extras", "Guide", "Combat", "Credits"}
local tabButtons = {}
local containers = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Position = UDim2.new(0, 0, 0, 42 + (i-1) * 31)
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(50, 35, 28) or Color3.fromRGB(25, 16, 12)
    btn.BackgroundTransparency = (i == 1) and 0.3 or 0.8
    btn.BorderSizePixel = 0
    btn.Text = "  " .. tabName
    btn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 150, 140)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = leftPanel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local icons = {Main="🏠", Extras="⚡", Guide="📖", Combat="⚔️", Credits="📜"}
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 18, 1, 0)
    icon.Position = UDim2.new(0, 4, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = icons[tabName] or "•"
    icon.TextColor3 = Color3.fromRGB(200, 170, 150)
    icon.TextScaled = true
    icon.Font = Enum.Font.Gotham
    icon.Parent = btn
    tabButtons[tabName] = btn
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -140, 1, -15)
    container.Position = UDim2.new(0, 135, 0, 8)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 100)
    container.Visible = (i == 1)
    container.Parent = frame
    containers[tabName] = container
    btn.MouseButton1Click:Connect(function()
        for _, tn in ipairs(tabs) do
            local isSelected = (tn == tabName)
            tabButtons[tn].BackgroundColor3 = isSelected and Color3.fromRGB(50, 35, 28) or Color3.fromRGB(25, 16, 12)
            tabButtons[tn].BackgroundTransparency = isSelected and 0.3 or 0.8
            tabButtons[tn].TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 150, 140)
            containers[tn].Visible = isSelected
        end
    end)
end

local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(1, 0, 0, 50)
profileFrame.Position = UDim2.new(0, 0, 1, -53)
profileFrame.BackgroundColor3 = Color3.fromRGB(20, 13, 10)
profileFrame.BackgroundTransparency = 0.5
profileFrame.BorderSizePixel = 0
profileFrame.Parent = leftPanel
Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0, 6)

local avatarFrame = Instance.new("ImageLabel")
avatarFrame.Size = UDim2.new(0, 32, 0, 32)
avatarFrame.Position = UDim2.new(0, 8, 0.5, -16)
avatarFrame.BackgroundColor3 = Color3.fromRGB(60, 40, 30)
avatarFrame.BackgroundTransparency = 0
avatarFrame.BorderSizePixel = 0
avatarFrame.Parent = profileFrame
Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)
local userId = player.UserId
avatarFrame.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"

local displayName = Instance.new("TextLabel")
displayName.Size = UDim2.new(0.5, 0, 0, 14)
displayName.Position = UDim2.new(0, 48, 0, 6)
displayName.BackgroundTransparency = 1
displayName.Text = player.Name
displayName.TextColor3 = Color3.fromRGB(230, 210, 190)
displayName.TextScaled = true
displayName.Font = Enum.Font.GothamBold
displayName.TextXAlignment = Enum.TextXAlignment.Left
displayName.Parent = profileFrame

local username = Instance.new("TextLabel")
username.Size = UDim2.new(0.5, 0, 0, 12)
username.Position = UDim2.new(0, 48, 0, 24)
username.BackgroundTransparency = 1
username.Text = "@" .. player.Name
username.TextColor3 = Color3.fromRGB(150, 130, 120)
username.TextScaled = true
username.Font = Enum.Font.Gotham
username.TextXAlignment = Enum.TextXAlignment.Left
username.Parent = profileFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local foldBtn = Instance.new("TextButton")
foldBtn.Size = UDim2.new(0, 24, 0, 24)
foldBtn.Position = UDim2.new(1, -60, 0, 5)
foldBtn.BackgroundTransparency = 1
foldBtn.Text = "─"
foldBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
foldBtn.TextScaled = true
foldBtn.Font = Enum.Font.GothamBold
foldBtn.Parent = frame

local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(0, 38, 0, 38)
iconBtn.Position = UDim2.new(1, -48, 1, -48)
iconBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 35)
iconBtn.BorderSizePixel = 0
iconBtn.Text = "Z"
iconBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
iconBtn.TextScaled = true
iconBtn.Font = Enum.Font.GothamBold
iconBtn.Visible = false
iconBtn.Active = true
iconBtn.Draggable = true
iconBtn.Parent = gui
Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(1, 0)

foldBtn.MouseButton1Click:Connect(function()
    isFolded = not isFolded
    if isFolded then
        frame.Visible = false
        iconBtn.Visible = true
    else
        frame.Visible = true
        iconBtn.Visible = false
    end
end)

iconBtn.MouseButton1Click:Connect(function()
    isFolded = false
    frame.Visible = true
    iconBtn.Visible = false
end)

local function createLabel(parent, text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createGuideTitle(parent, text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 18)
    lbl.Position = UDim2.new(0, 5, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 220, 150)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createGuideText(parent, text, y, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 14)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(200, 190, 180)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Parent = parent
    return lbl
end

local mainContainer = containers["Main"]
local yMain = 5

createLabel(mainContainer, "Crate Attractor", yMain)
yMain = yMain + 20

local attractBtn = Instance.new("TextButton")
attractBtn.Size = UDim2.new(0.9, 0, 0, 26)
attractBtn.Position = UDim2.new(0.05, 0, 0, yMain)
attractBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
attractBtn.BackgroundTransparency = 0
attractBtn.BorderSizePixel = 0
attractBtn.Text = "ATTRACT (OFF)"
attractBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
attractBtn.TextScaled = true
attractBtn.Font = Enum.Font.GothamBold
attractBtn.Parent = mainContainer
Instance.new("UICorner", attractBtn).CornerRadius = UDim.new(0, 5)
attractBtn.MouseButton1Click:Connect(function()
    attractEnabled = not attractEnabled
    attractBtn.Text = attractEnabled and "ATTRACT (ON)" or "ATTRACT (OFF)"
    attractBtn.BackgroundColor3 = attractEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if attractEnabled then startAttract() end
end)
yMain = yMain + 30

createLabel(mainContainer, "Key Collector (Return)", yMain)
yMain = yMain + 20

local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0.9, 0, 0, 26)
keyBtn.Position = UDim2.new(0.05, 0, 0, yMain)
keyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
keyBtn.BackgroundTransparency = 0
keyBtn.BorderSizePixel = 0
keyBtn.Text = "COLLECT KEYS (OFF)"
keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBtn.TextScaled = true
keyBtn.Font = Enum.Font.GothamBold
keyBtn.Parent = mainContainer
Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 5)
keyBtn.MouseButton1Click:Connect(function()
    keyCollectEnabled = not keyCollectEnabled
    keyBtn.Text = keyCollectEnabled and "COLLECT KEYS (ON)" or "COLLECT KEYS (OFF)"
    keyBtn.BackgroundColor3 = keyCollectEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if keyCollectEnabled then collectKeys() end
end)
yMain = yMain + 30

createLabel(mainContainer, "Auto Buy (Private Server)", yMain)
yMain = yMain + 20

local autoBuyBtn = Instance.new("TextButton")
autoBuyBtn.Size = UDim2.new(0.9, 0, 0, 26)
autoBuyBtn.Position = UDim2.new(0.05, 0, 0, yMain)
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
autoBuyBtn.BackgroundTransparency = 0
autoBuyBtn.BorderSizePixel = 0
autoBuyBtn.Text = "AUTO BUY (OFF)"
autoBuyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBuyBtn.TextScaled = true
autoBuyBtn.Font = Enum.Font.GothamBold
autoBuyBtn.Parent = mainContainer
Instance.new("UICorner", autoBuyBtn).CornerRadius = UDim.new(0, 5)
autoBuyBtn.MouseButton1Click:Connect(function()
    autoBuyEnabled = not autoBuyEnabled
    if autoBuyEnabled then
        autoBuyBtn.Text = "AUTO BUY (ON)"
        autoBuyBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
    else
        autoBuyBtn.Text = "AUTO BUY (OFF)"
        autoBuyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    end
    if autoBuyEnabled then startAutoBuy() end
end)
yMain = yMain + 30

createLabel(mainContainer, "Auto Collector (All Zones)", yMain)
yMain = yMain + 20

local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(0.35, 0, 0, 16)
delayLabel.Position = UDim2.new(0.05, 0, 0, yMain)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Delay:"
delayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
delayLabel.TextScaled = true
delayLabel.Font = Enum.Font.GothamBold
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = mainContainer

local delayInput = Instance.new("TextBox")
delayInput.Size = UDim2.new(0.15, 0, 0, 18)
delayInput.Position = UDim2.new(0.4, 0, 0, yMain)
delayInput.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
delayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
delayInput.Text = "5"
delayInput.TextScaled = true
delayInput.Font = Enum.Font.GothamBold
delayInput.Parent = mainContainer
Instance.new("UICorner", delayInput).CornerRadius = UDim.new(0, 4)
delayInput.FocusLost:Connect(function()
    local val = tonumber(delayInput.Text)
    if val and val > 0 then collectorDelay = val else delayInput.Text = tostring(collectorDelay) end
end)

yMain = yMain + 22

local collectorBtn = Instance.new("TextButton")
collectorBtn.Size = UDim2.new(0.9, 0, 0, 26)
collectorBtn.Position = UDim2.new(0.05, 0, 0, yMain)
collectorBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
collectorBtn.BackgroundTransparency = 0
collectorBtn.BorderSizePixel = 0
collectorBtn.Text = "COLLECTOR (OFF)"
collectorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
collectorBtn.TextScaled = true
collectorBtn.Font = Enum.Font.GothamBold
collectorBtn.Parent = mainContainer
Instance.new("UICorner", collectorBtn).CornerRadius = UDim.new(0, 5)
collectorBtn.MouseButton1Click:Connect(function()
    collectorEnabled = not collectorEnabled
    if collectorEnabled then
        collectorBtn.Text = "COLLECTOR (ON)"
        collectorBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
    else
        collectorBtn.Text = "COLLECTOR (OFF)"
        collectorBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    end
    if collectorEnabled then startCollector() end
end)
yMain = yMain + 30

-- ============================================================
-- ➤ LEAF TELEPORT (AUTO) — ДОБАВЛЕНАЯ КНОПКА
-- ============================================================
local leafTeleportEnabled = false
local leafLoop = nil

local function teleportToLeaf()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local folder = workspace:FindFirstChild("FallLeavesFolder")
    if not folder then return end

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

local function startLeafTeleport()
    spawn(function()
        while leafTeleportEnabled do
            teleportToLeaf()
            wait(0.3)
        end
    end)
end

createLabel(mainContainer, "Leaf Teleport (Auto)", yMain)
yMain = yMain + 20

local leafBtn = Instance.new("TextButton")
leafBtn.Size = UDim2.new(0.9, 0, 0, 26)
leafBtn.Position = UDim2.new(0.05, 0, 0, yMain)
leafBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
leafBtn.BackgroundTransparency = 0
leafBtn.BorderSizePixel = 0
leafBtn.Text = "LEAF TELEPORT (OFF)"
leafBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
leafBtn.TextScaled = true
leafBtn.Font = Enum.Font.GothamBold
leafBtn.Parent = mainContainer
Instance.new("UICorner", leafBtn).CornerRadius = UDim.new(0, 5)

leafBtn.MouseButton1Click:Connect(function()
    leafTeleportEnabled = not leafTeleportEnabled
    if leafTeleportEnabled then
        leafBtn.Text = "LEAF TELEPORT (ON)"
        leafBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
        startLeafTeleport()
    else
        leafBtn.Text = "LEAF TELEPORT (OFF)"
        leafBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    end
end)
-- ============================================================

yMain = yMain + 30
mainContainer.CanvasSize = UDim2.new(0, 0, 0, yMain + 20)

local extrasContainer = containers["Extras"]
local yExtra = 5

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.35, 0, 0, 16)
speedLabel.Position = UDim2.new(0.05, 0, 0, yExtra)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = extrasContainer

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.15, 0, 0, 18)
speedInput.Position = UDim2.new(0.4, 0, 0, yExtra)
speedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Text = "100"
speedInput.TextScaled = true
speedInput.Font = Enum.Font.GothamBold
speedInput.Parent = extrasContainer
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 4)
speedInput.FocusLost:Connect(function()
    local val = tonumber(speedInput.Text)
    if val and val > 0 then speedValue = val else speedInput.Text = tostring(speedValue) end
end)

yExtra = yExtra + 22

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 26)
speedBtn.Position = UDim2.new(0.05, 0, 0, yExtra)
speedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
speedBtn.BackgroundTransparency = 0
speedBtn.BorderSizePixel = 0
speedBtn.Text = "ENABLE"
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.TextScaled = true
speedBtn.Font = Enum.Font.GothamBold
speedBtn.Parent = extrasContainer
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 5)
speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedBtn.Text = speedEnabled and "DISABLE" or "ENABLE"
    speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(30, 30, 50)
    if speedEnabled then
        pcall(function() player.Character.Humanoid.WalkSpeed = speedValue end)
    else
        pcall(function() player.Character.Humanoid.WalkSpeed = 16 end)
    end
end)
yExtra = yExtra + 30

local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(0.35, 0, 0, 16)
flySpeedLabel.Position = UDim2.new(0.05, 0, 0, yExtra)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "Fly Speed:"
flySpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedLabel.TextScaled = true
flySpeedLabel.Font = Enum.Font.GothamBold
flySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
flySpeedLabel.Parent = extrasContainer

local flySpeedInput = Instance.new("TextBox")
flySpeedInput.Size = UDim2.new(0.15, 0, 0, 18)
flySpeedInput.Position = UDim2.new(0.4, 0, 0, yExtra)
flySpeedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
flySpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedInput.Text = "50"
flySpeedInput.TextScaled = true
flySpeedInput.Font = Enum.Font.GothamBold
flySpeedInput.Parent = extrasContainer
Instance.new("UICorner", flySpeedInput).CornerRadius = UDim.new(0, 4)
flySpeedInput.FocusLost:Connect(function()
    local val = tonumber(flySpeedInput.Text)
    if val and val > 0 then flySpeed = val else flySpeedInput.Text = tostring(flySpeed) end
end)

yExtra = yExtra + 22

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.9, 0, 0, 26)
flyBtn.Position = UDim2.new(0.05, 0, 0, yExtra)
flyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 90)
flyBtn.BackgroundTransparency = 0
flyBtn.BorderSizePixel = 0
flyBtn.Text = "FLY (OFF)"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.TextScaled = true
flyBtn.Font = Enum.Font.GothamBold
flyBtn.Parent = extrasContainer
Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 5)
flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = flyEnabled and "FLY (ON)" or "FLY (OFF)"
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(40, 40, 90)
    toggleFly()
end)
yExtra = yExtra + 30

local antiBtn = Instance.new("TextButton")
antiBtn.Size = UDim2.new(0.9, 0, 0, 26)
antiBtn.Position = UDim2.new(0.05, 0, 0, yExtra)
antiBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
antiBtn.BackgroundTransparency = 0
antiBtn.BorderSizePixel = 0
antiBtn.Text = "ANTI-AFK (OFF)"
antiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
antiBtn.TextScaled = true
antiBtn.Font = Enum.Font.GothamBold
antiBtn.Parent = extrasContainer
Instance.new("UICorner", antiBtn).CornerRadius = UDim.new(0, 5)
antiBtn.MouseButton1Click:Connect(function()
    antiAFKEnabled = not antiAFKEnabled
    antiBtn.Text = antiAFKEnabled and "ANTI-AFK (ON)" or "ANTI-AFK (OFF)"
    antiBtn.BackgroundColor3 = antiAFKEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if antiAFKEnabled then startAntiAFK() end
end)
yExtra = yExtra + 30

local godBtn = Instance.new("TextButton")
godBtn.Size = UDim2.new(0.9, 0, 0, 26)
godBtn.Position = UDim2.new(0.05, 0, 0, yExtra)
godBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
godBtn.BackgroundTransparency = 0
godBtn.BorderSizePixel = 0
godBtn.Text = "GOD MODE (OFF)"
godBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
godBtn.TextScaled = true
godBtn.Font = Enum.Font.GothamBold
godBtn.Parent = extrasContainer
Instance.new("UICorner", godBtn).CornerRadius = UDim.new(0, 5)
godBtn.MouseButton1Click:Connect(function()
    godModeEnabled = not godModeEnabled
    godBtn.Text = godModeEnabled and "GOD MODE (ON)" or "GOD MODE (OFF)"
    godBtn.BackgroundColor3 = godModeEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if godModeEnabled then startGodMode() end
end)
yExtra = yExtra + 30

local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(0.9, 0, 0, 26)
noclipBtn.Position = UDim2.new(0.05, 0, 0, yExtra)
noclipBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
noclipBtn.BackgroundTransparency = 0
noclipBtn.BorderSizePixel = 0
noclipBtn.Text = "NOCLIP (OFF)"
noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.TextScaled = true
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.Parent = extrasContainer
Instance.new("UICorner", noclipBtn).CornerRadius = UDim.new(0, 5)
noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "NOCLIP (ON)" or "NOCLIP (OFF)"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if noclipEnabled then
        spawn(function()
            while noclipEnabled do
                wait(0.1)
                if player.Character then
                    for _, part in pairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    else
        if player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)
yExtra = yExtra + 30

local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0.9, 0, 0, 26)
jumpBtn.Position = UDim2.new(0.05, 0, 0, yExtra)
jumpBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
jumpBtn.BackgroundTransparency = 0
jumpBtn.BorderSizePixel = 0
jumpBtn.Text = "INF JUMP (OFF)"
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.TextScaled = true
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.Parent = extrasContainer
Instance.new("UICorner", jumpBtn).CornerRadius = UDim.new(0, 5)
jumpBtn.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    jumpBtn.Text = jumpEnabled and "INF JUMP (ON)" or "INF JUMP (OFF)"
    jumpBtn.BackgroundColor3 = jumpEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if jumpEnabled then
        UserInputService.JumpRequest:Connect(function()
            if jumpEnabled and player.Character then
                pcall(function() player.Character.Humanoid:ChangeState("Jumping") end)
            end
        end)
    end
end)
yExtra = yExtra + 30
extrasContainer.CanvasSize = UDim2.new(0, 0, 0, yExtra + 20)

local guideContainer = containers["Guide"]
local yGuide = 5

createGuideTitle(guideContainer, "■ Crate Attractor", yGuide)
yGuide = yGuide + 22
createGuideText(guideContainer, "• You need stay on grass, if you stay very high then it dont collect any crates", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "• Good combine with auto collector bc you teleport to collect from cash giver and you also collect crates", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "• Works fine but not perfect", yGuide, Color3.fromRGB(255, 200, 100))
yGuide = yGuide + 22

createGuideTitle(guideContainer, "■ Auto Buy", yGuide)
yGuide = yGuide + 22
createGuideText(guideContainer, "• Some bugs with this button, you need be close to buttons, or it just dont work", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "• Game auto remove from allbuttons file buttons that dont in your close enough distance", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "• I cant fix it, its game mechanic", yGuide, Color3.fromRGB(255, 200, 100))
yGuide = yGuide + 18
createGuideText(guideContainer, "• High reccomend use it in private server because it work on every zone buttons", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "• I cant just do it only on your zone sorry", yGuide, Color3.fromRGB(255, 150, 150))
yGuide = yGuide + 22

createGuideTitle(guideContainer, "■ Auto Collector", yGuide)
yGuide = yGuide + 22
createGuideText(guideContainer, "• Reccomend use in private server because it works on every zones in game", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "• Again problem i cant just place only your, it was hard to make", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "• But i think i try do it later", yGuide, Color3.fromRGB(255, 200, 100))
yGuide = yGuide + 22

createGuideTitle(guideContainer, "■ Speed and Fly", yGuide)
yGuide = yGuide + 22
createGuideText(guideContainer, "• You can change speed number and fly speed", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "• Flying looks like strange bc maked by me", yGuide, Color3.fromRGB(255, 200, 100))
yGuide = yGuide + 22

createGuideTitle(guideContainer, "■ God Mode", yGuide)
yGuide = yGuide + 22
createGuideText(guideContainer, "• Dont work, just visual", yGuide, Color3.fromRGB(255, 150, 150))
yGuide = yGuide + 22

createGuideTitle(guideContainer, "■ Combat", yGuide)
yGuide = yGuide + 22
createGuideText(guideContainer, "• Coming Soon...", yGuide, Color3.fromRGB(255, 200, 100))
yGuide = yGuide + 22

guideContainer.CanvasSize = UDim2.new(0, 0, 0, yGuide + 20)

local combatContainer = containers["Combat"]
local placeholder = Instance.new("TextLabel")
placeholder.Size = UDim2.new(1, 0, 1, 0)
placeholder.BackgroundTransparency = 1
placeholder.Text = "⚔️ Combat Tab\n\nComing Soon..."
placeholder.TextColor3 = Color3.fromRGB(200, 180, 170)
placeholder.TextScaled = true
placeholder.Font = Enum.Font.GothamBold
placeholder.Parent = combatContainer

local creditsContainer = containers["Credits"]
local yCredits = 12

local creditsTitle = Instance.new("TextLabel")
creditsTitle.Size = UDim2.new(1, 0, 0, 30)
creditsTitle.Position = UDim2.new(0, 0, 0, yCredits)
creditsTitle.BackgroundTransparency = 1
creditsTitle.Text = "CREDITS"
creditsTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
creditsTitle.TextScaled = true
creditsTitle.Font = Enum.Font.GothamBold
creditsTitle.TextXAlignment = Enum.TextXAlignment.Center
creditsTitle.Parent = creditsContainer
yCredits = yCredits + 35

local function addCredit(text, y, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = creditsContainer
    return lbl
end

addCredit("Idea Maker: zrzock", yCredits, Color3.fromRGB(255, 255, 255))
yCredits = yCredits + 26
addCredit("Creator: zrzock", yCredits, Color3.fromRGB(255, 255, 255))
yCredits = yCredits + 26
addCredit("Thanks for using!", yCredits, Color3.fromRGB(150, 150, 200))
yCredits = yCredits + 26
creditsContainer.CanvasSize = UDim2.new(0, 0, 0, yCredits + 20)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        gui.Enabled = not gui.Enabled
    end
end)
