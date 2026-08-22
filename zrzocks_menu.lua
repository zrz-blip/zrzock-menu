-- SWILL — zrzocks menu (FULL VERSION + AUTO BUY)
local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- ---- VARIABLES ----
local keyCollectEnabled = false
local attractEnabled = false
local speedEnabled = false
local godModeEnabled = false
local noclipEnabled = false
local jumpEnabled = false
local antiAFKEnabled = false
local autoBuyEnabled = false  -- НОВАЯ ПЕРЕМЕННАЯ
local speedValue = 100
local isFolded = false

-- ---- ANTI-AFK ----
local function startAntiAFK()
    spawn(function()
        while antiAFKEnabled do
            wait(30)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(500, 400))
                print("[Anti-AFK] Clicked")
            end)
        end
    end)
end

-- ---- KEY COLLECTOR ----
local function collectKeys()
    spawn(function()
        while keyCollectEnabled do
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then
                wait(1)
                continue
            end

            local keyFolder = workspace:FindFirstChild("KeyFolder")
            if not keyFolder then
                print("KeyFolder not found")
                wait(2)
                continue
            end

            local startPos = hrp.CFrame

            for _, key in pairs(keyFolder:GetChildren()) do
                if not keyCollectEnabled then break end
                if not key:IsA("BasePart") then continue end

                local click = key:FindFirstChild("ClickDetector")
                if not click then continue end

                hrp.CFrame = CFrame.new(key.Position + Vector3.new(0, 2, 0))
                wait(0.15)

                pcall(function()
                    click:Click()
                end)

                wait(0.15)
                hrp.CFrame = startPos
                wait(0.15)
            end

            wait(1)
        end
    end)
end

-- ---- CRATE ATTRACTOR ----
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

-- ---- AUTO BUY (ТЕЛЕПОРТ НА ВСЕ КНОПКИ) ----
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

-- ---- GOD MODE ----
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

-- ---- GUI ----
local gui = Instance.new("ScreenGui")
gui.Name = "zrzocks_menu"
gui.Parent = game:GetService("CoreGui")
gui.ResetOnSpawn = false

-- ---- MAIN FRAME ----
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 560) -- УВЕЛИЧЕНО, ЧТОБЫ ВМЕСТИТЬ ВКЛАДКУ
frame.Position = UDim2.new(0.5, -210, 0.5, -280)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 25)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

-- ---- HEADER ----
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
header.BorderSizePixel = 0
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "zrzocks menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local foldBtn = Instance.new("TextButton")
foldBtn.Size = UDim2.new(0, 28, 0, 28)
foldBtn.Position = UDim2.new(1, -62, 0, 6)
foldBtn.BackgroundTransparency = 1
foldBtn.Text = "─"
foldBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
foldBtn.TextScaled = true
foldBtn.Font = Enum.Font.GothamBold
foldBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 6)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ---- FOLD ICON ----
local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(0, 50, 0, 50)
iconBtn.Position = UDim2.new(1, -60, 1, -70)
iconBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 35)
iconBtn.BorderSizePixel = 0
iconBtn.Text = "z"
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

-- ---- TABS ----
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -10, 0, 36)
tabFrame.Position = UDim2.new(0, 5, 0, 40)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = frame

-- ДОБАВЛЕНА ВКЛАДКА "Farm"
local tabs = {
    {name = "Main", color = Color3.fromRGB(45, 45, 70)},
    {name = "Farm", color = Color3.fromRGB(30, 30, 55)},
    {name = "Extras", color = Color3.fromRGB(30, 30, 55)},
    {name = "Credits", color = Color3.fromRGB(30, 30, 55)}
}

local tabButtons = {}
local containers = {}

for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
    btn.BackgroundColor3 = tab.color
    btn.BorderSizePixel = 0
    btn.Text = tab.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabFrame
    tabButtons[i] = btn

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -100)
    container.Position = UDim2.new(0, 10, 0, 85)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 4
    container.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 100)
    container.Visible = (i == 1)
    container.Parent = frame
    containers[i] = container

    btn.MouseButton1Click:Connect(function()
        for j, b in ipairs(tabButtons) do
            b.BackgroundColor3 = (j == i) and Color3.fromRGB(45, 45, 70) or Color3.fromRGB(30, 30, 55)
            containers[j].Visible = (j == i)
        end
    end)
end

-- ---- MAIN TAB (БЕЗ ИЗМЕНЕНИЙ) ----
local yMain = 5

local attractLabel = Instance.new("TextLabel")
attractLabel.Size = UDim2.new(1, 0, 0, 25)
attractLabel.Position = UDim2.new(0, 0, 0, yMain)
attractLabel.BackgroundTransparency = 1
attractLabel.Text = "Crate Attractor"
attractLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
attractLabel.TextScaled = true
attractLabel.Font = Enum.Font.GothamBold
attractLabel.TextXAlignment = Enum.TextXAlignment.Left
attractLabel.Parent = containers[1]
yMain = yMain + 30

local attractBtn = Instance.new("TextButton")
attractBtn.Size = UDim2.new(0.9, 0, 0, 35)
attractBtn.Position = UDim2.new(0.05, 0, 0, yMain)
attractBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
attractBtn.BackgroundTransparency = 0
attractBtn.BorderSizePixel = 0
attractBtn.Text = "ATTRACT (OFF)"
attractBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
attractBtn.TextScaled = true
attractBtn.Font = Enum.Font.GothamBold
attractBtn.Parent = containers[1]
Instance.new("UICorner", attractBtn).CornerRadius = UDim.new(0, 6)

attractBtn.MouseButton1Click:Connect(function()
    attractEnabled = not attractEnabled
    attractBtn.Text = attractEnabled and "ATTRACT (ON)" or "ATTRACT (OFF)"
    attractBtn.BackgroundColor3 = attractEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if attractEnabled then startAttract() end
end)

yMain = yMain + 42

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, 0, 0, 25)
keyLabel.Position = UDim2.new(0, 0, 0, yMain)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Key Collector (Teleport + Click)"
keyLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
keyLabel.TextScaled = true
keyLabel.Font = Enum.Font.GothamBold
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = containers[1]
yMain = yMain + 30

local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0.9, 0, 0, 35)
keyBtn.Position = UDim2.new(0.05, 0, 0, yMain)
keyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
keyBtn.BackgroundTransparency = 0
keyBtn.BorderSizePixel = 0
keyBtn.Text = "COLLECT KEYS (OFF)"
keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBtn.TextScaled = true
keyBtn.Font = Enum.Font.GothamBold
keyBtn.Parent = containers[1]
Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)

keyBtn.MouseButton1Click:Connect(function()
    keyCollectEnabled = not keyCollectEnabled
    keyBtn.Text = keyCollectEnabled and "COLLECT KEYS (ON)" or "COLLECT KEYS (OFF)"
    keyBtn.BackgroundColor3 = keyCollectEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if keyCollectEnabled then collectKeys() end
end)

yMain = yMain + 42
containers[1].CanvasSize = UDim2.new(0, 0, 0, yMain + 20)

-- ---- FARM TAB (НОВАЯ ВКЛАДКА) ----
local yFarm = 5

local autoBuyLabel = Instance.new("TextLabel")
autoBuyLabel.Size = UDim2.new(1, 0, 0, 25)
autoBuyLabel.Position = UDim2.new(0, 0, 0, yFarm)
autoBuyLabel.BackgroundTransparency = 1
autoBuyLabel.Text = "Auto Buy Buttons"
autoBuyLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
autoBuyLabel.TextScaled = true
autoBuyLabel.Font = Enum.Font.GothamBold
autoBuyLabel.TextXAlignment = Enum.TextXAlignment.Left
autoBuyLabel.Parent = containers[2]
yFarm = yFarm + 30

-- КНОПКА С ПРЕДУПРЕЖДЕНИЕМ
local autoBuyBtn = Instance.new("TextButton")
autoBuyBtn.Size = UDim2.new(0.9, 0, 0, 50)
autoBuyBtn.Position = UDim2.new(0.05, 0, 0, yFarm)
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
autoBuyBtn.BackgroundTransparency = 0
autoBuyBtn.BorderSizePixel = 0
autoBuyBtn.Text = "⚠ PRIVATE SERVER ONLY\nAUTO BUY (OFF)"
autoBuyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBuyBtn.TextScaled = true
autoBuyBtn.Font = Enum.Font.GothamBold
autoBuyBtn.Parent = containers[2]
Instance.new("UICorner", autoBuyBtn).CornerRadius = UDim.new(0, 6)

autoBuyBtn.MouseButton1Click:Connect(function()
    autoBuyEnabled = not autoBuyEnabled
    if autoBuyEnabled then
        autoBuyBtn.Text = "⚠ PRIVATE SERVER ONLY\nAUTO BUY (ON)"
        autoBuyBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
    else
        autoBuyBtn.Text = "⚠ PRIVATE SERVER ONLY\nAUTO BUY (OFF)"
        autoBuyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    end
    if autoBuyEnabled then startAutoBuy() end
end)

yFarm = yFarm + 55
containers[2].CanvasSize = UDim2.new(0, 0, 0, yFarm + 20)

-- ---- EXTRAS TAB (БЕЗ ИЗМЕНЕНИЙ) ----
local yExtra = 10

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.6, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0, yExtra)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = containers[3]

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.25, 0, 0, 28)
speedInput.Position = UDim2.new(0.65, 0, 0, yExtra)
speedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Text = "100"
speedInput.TextScaled = true
speedInput.Font = Enum.Font.GothamBold
speedInput.Parent = containers[3]
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 6)
speedInput.FocusLost:Connect(function()
    local val = tonumber(speedInput.Text)
    if val and val > 0 then
        speedValue = val
        if speedEnabled then
            pcall(function() player.Character.Humanoid.WalkSpeed = speedValue end)
        end
    else
        speedInput.Text = tostring(speedValue)
    end
end)

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 28)
speedBtn.Position = UDim2.new(0.05, 0, 0, yExtra + 33)
speedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
speedBtn.BackgroundTransparency = 0
speedBtn.BorderSizePixel = 0
speedBtn.Text = "ENABLE"
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.TextScaled = true
speedBtn.Font = Enum.Font.GothamBold
speedBtn.Parent = containers[3]
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 6)

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

yExtra = yExtra + 70

local antiAFKBtn = Instance.new("TextButton")
antiAFKBtn.Size = UDim2.new(0.9, 0, 0, 35)
antiAFKBtn.Position = UDim2.new(0.05, 0, 0, yExtra)
antiAFKBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
antiAFKBtn.BackgroundTransparency = 0
antiAFKBtn.BorderSizePixel = 0
antiAFKBtn.Text = "ANTI-AFK (OFF)"
antiAFKBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
antiAFKBtn.TextScaled = true
antiAFKBtn.Font = Enum.Font.GothamBold
antiAFKBtn.Parent = containers[3]
Instance.new("UICorner", antiAFKBtn).CornerRadius = UDim.new(0, 6)

antiAFKBtn.MouseButton1Click:Connect(function()
    antiAFKEnabled = not antiAFKEnabled
    antiAFKBtn.Text = antiAFKEnabled and "ANTI-AFK (ON)" or "ANTI-AFK (OFF)"
    antiAFKBtn.BackgroundColor3 = antiAFKEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if antiAFKEnabled then startAntiAFK() end
end)

yExtra = yExtra + 42

local godBtn = Instance.new("TextButton")
godBtn.Size = UDim2.new(0.9, 0, 0, 35)
godBtn.Position = UDim2.new(0.05, 0, 0, yExtra)
godBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
godBtn.BackgroundTransparency = 0
godBtn.BorderSizePixel = 0
godBtn.Text = "GOD MODE (OFF)"
godBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
godBtn.TextScaled = true
godBtn.Font = Enum.Font.GothamBold
godBtn.Parent = containers[3]
Instance.new("UICorner", godBtn).CornerRadius = UDim.new(0, 6)

godBtn.MouseButton1Click:Connect(function()
    godModeEnabled = not godModeEnabled
    godBtn.Text = godModeEnabled and "GOD MODE (ON)" or "GOD MODE (OFF)"
    godBtn.BackgroundColor3 = godModeEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if godModeEnabled then startGodMode() end
end)

yExtra = yExtra + 42

local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(0.9, 0, 0, 35)
noclipBtn.Position = UDim2.new(0.05, 0, 0, yExtra)
noclipBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
noclipBtn.BackgroundTransparency = 0
noclipBtn.BorderSizePixel = 0
noclipBtn.Text = "NOCLIP (OFF)"
noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.TextScaled = true
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.Parent = containers[3]
Instance.new("UICorner", noclipBtn).CornerRadius = UDim.new(0, 6)

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

yExtra = yExtra + 42

local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0.9, 0, 0, 35)
jumpBtn.Position = UDim2.new(0.05, 0, 0, yExtra)
jumpBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
jumpBtn.BackgroundTransparency = 0
jumpBtn.BorderSizePixel = 0
jumpBtn.Text = "INF JUMP (OFF)"
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.TextScaled = true
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.Parent = containers[3]
Instance.new("UICorner", jumpBtn).CornerRadius = UDim.new(0, 6)

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

yExtra = yExtra + 42
containers[3].CanvasSize = UDim2.new(0, 0, 0, yExtra + 20)

-- ---- CREDITS TAB (БЕЗ ИЗМЕНЕНИЙ) ----
local yCredits = 20

local creditsTitle = Instance.new("TextLabel")
creditsTitle.Size = UDim2.new(1, 0, 0, 40)
creditsTitle.Position = UDim2.new(0, 0, 0, yCredits)
creditsTitle.BackgroundTransparency = 1
creditsTitle.Text = "CREDITS"
creditsTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
creditsTitle.TextScaled = true
creditsTitle.Font = Enum.Font.GothamBold
creditsTitle.TextXAlignment = Enum.TextXAlignment.Center
creditsTitle.Parent = containers[4]
yCredits = yCredits + 50

local line1 = Instance.new("TextLabel")
line1.Size = UDim2.new(1, 0, 0, 30)
line1.Position = UDim2.new(0, 0, 0, yCredits)
line1.BackgroundTransparency = 1
line1.Text = "Idea Maker: zrzockspq"
line1.TextColor3 = Color3.fromRGB(255, 255, 255)
line1.TextScaled = true
line1.Font = Enum.Font.GothamBold
line1.TextXAlignment = Enum.TextXAlignment.Center
line1.Parent = containers[4]
yCredits = yCredits + 40

local line2 = Instance.new("TextLabel")
line2.Size = UDim2.new(1, 0, 0, 30)
line2.Position = UDim2.new(0, 0, 0, yCredits)
line2.BackgroundTransparency = 1
line2.Text = "Creator: DeepSeek"
line2.TextColor3 = Color3.fromRGB(255, 255, 255)
line2.TextScaled = true
line2.Font = Enum.Font.GothamBold
line2.TextXAlignment = Enum.TextXAlignment.Center
line2.Parent = containers[4]
yCredits = yCredits + 40

local thanks = Instance.new("TextLabel")
thanks.Size = UDim2.new(1, 0, 0, 30)
thanks.Position = UDim2.new(0, 0, 0, yCredits)
thanks.BackgroundTransparency = 1
thanks.Text = "Thanks for using!"
thanks.TextColor3 = Color3.fromRGB(150, 150, 200)
thanks.TextScaled = true
thanks.Font = Enum.Font.Gotham
thanks.TextXAlignment = Enum.TextXAlignment.Center
thanks.Parent = containers[4]
yCredits = yCredits + 40

containers[4].CanvasSize = UDim2.new(0, 0, 0, yCredits + 20)

print("zrzocks menu loaded (with Auto Buy)")
