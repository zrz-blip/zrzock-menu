if game.PlaceId ~= 10697845123 then return end

local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function getBackpack()
    return player:FindFirstChild("Backpack")
end

-- Config

local CONFIG = {
    CaveEntrance = nil,
    CaveInside = nil,
    Speaker = nil,
    Collectors = {},
    Crystals = {},
    PickaxeSlot = 2,
    ClickDelay = 0.05,
    CrystalTimeout = 5,
    DepositDelay = 0.5,
    AntiPlayerEnabled = false,
    PlayerCheckDistance = 1200,
    WarningCooldown = 10,
	AntiSpectatorEnabled = false,
    Container = nil,
    ContainerCenter = nil,
    WalkSpeed = 16,
    JumpPower = 50,
    ESPEnabled = false,
    AutoResumeFarm = true,
    CandyFarmEnabled = false,
    CandyFolder = nil,
    Candies = {},
    CandyMode = "both",
}

-- Crystal priority

local CRYSTAL_PRIORITY = {
    golden = 1,
    yellow = 1,
    purple = 2,
    red = 3,
    green = 4,
    blue = 5,
}

local function getCrystalPriority(name)
    local lower = name:lower()
    for key, priority in pairs(CRYSTAL_PRIORITY) do
        if lower:find(key) then
            return priority
        end
    end
    return 999
end

-- Find objects

local function findObjects()
    pcall(function()
        local map = workspace:FindFirstChild("map")
        if map then
            local loadedMap = map:FindFirstChild("loadedMap")
            if loadedMap then
                local modelCFS = loadedMap:FindFirstChild("modelCFS")
                if modelCFS then
                    CONFIG.CaveEntrance = modelCFS:FindFirstChild("CaveEntrance")
                end
            end
        end
    end)

    pcall(function()
        local map = workspace:FindFirstChild("map")
        if map then
            local oob = map:FindFirstChild("oob")
            if oob then
                local cave = oob:FindFirstChild("cave")
                if cave then
                    CONFIG.Speaker = cave:FindFirstChild("speaker")
                    CONFIG.CaveInside = cave
                    CONFIG.Container = cave:FindFirstChild("container")
                    if CONFIG.Container then
                        CONFIG.ContainerCenter = CONFIG.Container:FindFirstChild("center")
                    end
                    CONFIG.Collectors = {}
                    for _, child in ipairs(cave:GetChildren()) do
                        if child:IsA("Model") and child:FindFirstChild("d") then
                            local d = child:FindFirstChild("d")
                            if d and d:FindFirstChild("ProximityPrompt") then
                                table.insert(CONFIG.Collectors, child)
                            end
                        end
                    end
                end
            end
        end
    end)

    pcall(function()
        local folder = workspace:FindFirstChild("spawnedScrystals")
        if folder then
            local crystals = folder:GetChildren()
            table.sort(crystals, function(a, b)
                return getCrystalPriority(a.Name) < getCrystalPriority(b.Name)
            end)
            CONFIG.Crystals = crystals
        end
    end)
end

-- Find sword candies

local function findSwordCandies()
    pcall(function()
        local storage = workspace:FindFirstChild("workspaceAbilityStorage")
        if storage then
            local candyFolder = storage:FindFirstChild("spawnedCandy")
            if candyFolder then
                CONFIG.CandyFolder = candyFolder
                CONFIG.Candies = candyFolder:GetChildren()
            end
        end
    end)
end

-- Teleport

local function getPos(obj)
    local pos = nil
    pcall(function()
        if obj:IsA("BasePart") then
            pos = obj.Position
        elseif obj:IsA("Model") and obj.PrimaryPart then
            pos = obj.PrimaryPart.Position
        elseif obj:IsA("Model") then
            pos = obj:GetPivot().Position
        end
    end)
    return pos
end

local function teleportTo(obj, offset)
    if not obj then return end
    local root = getHRP()
    if not root then return end
    local pos = getPos(obj)
    if pos then
        offset = offset or Vector3.new(0, 3, 0)
        root.CFrame = CFrame.new(pos + offset)
    end
end

-- Click

local function virtualClick()
    if not VirtualUser then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)
    task.wait(0.02)
    pcall(function()
        if VirtualUser.ReleaseButton1 then
            VirtualUser:ReleaseButton1()
        end
    end)
end

-- Prompt

local function firePrompt(prompt)
    if not prompt then return end
    if fireproximityprompt then
        pcall(function() fireproximityprompt(prompt) end)
    end
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.1)
        prompt:InputHoldEnd()
    end)
end

-- Slot

local function selectSlot(slot)
    local keyCodes = {
        Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three,
        Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six,
        Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine,
        Enum.KeyCode.Zero,
    }
    local key = keyCodes[slot]
    if key then
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end
end

-- Speed / Jump

local function setWalkSpeed(val)
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = val
        end
    end
end

local function setJumpPower(val)
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = val
        end
    end
end

-- ESP

local espFolder = nil
local nameFolder = nil

local function isRealCharacter(plr)
    if not plr or not plr.Character then return false end
    local char = plr.Character
    if char.Parent ~= workspace then return false end
    if char.Name ~= plr.Name then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if hum.Health <= 0 then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local owner = game.Players:GetPlayerFromCharacter(char)
    if owner ~= plr then return false end
    return true
end

local function createESP(plr)
    if not isRealCharacter(plr) then return end

    if not espFolder then
        espFolder = Instance.new("Folder")
        espFolder.Name = "ZrzocksESP"
        espFolder.Parent = game:GetService("CoreGui")
    end

    if not nameFolder then
        nameFolder = Instance.new("Folder")
        nameFolder.Name = "ZrzocksNames"
        nameFolder.Parent = game:GetService("CoreGui")
    end

    local char = plr.Character

    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local boxName = plr.Name .. "_" .. part.Name
            if not espFolder:FindFirstChild(boxName) then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = boxName
                box.Adornee = part
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Size = part.Size
                box.Transparency = 0.2
                box.Color3 = Color3.fromRGB(255, 0, 0)
                box.Parent = espFolder
            end
        end
    end

    local head = char:FindFirstChild("Head")
    if head and not nameFolder:FindFirstChild(plr.Name) then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = plr.Name
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 100, 0, 25)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = nameFolder

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = plr.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextScaled = false
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
    end
end

local function clearESP()
    if espFolder then
        espFolder:ClearAllChildren()
    end
    if nameFolder then
        nameFolder:ClearAllChildren()
    end
end

local function updateESP()
    if not CONFIG.ESPEnabled then return end

    if espFolder then
        for _, box in ipairs(espFolder:GetChildren()) do
            local plrName = box.Name:match("^(.+)_")
            if plrName then
                local plr = game.Players:FindFirstChild(plrName)
                if not isRealCharacter(plr) then
                    box:Destroy()
                end
                if box.Adornee then
                    local owner = game.Players:GetPlayerFromCharacter(box.Adornee.Parent)
                    if owner ~= plr then
                        box:Destroy()
                    end
                end
            end
        end
    end

    if nameFolder then
        for _, tag in ipairs(nameFolder:GetChildren()) do
            local plr = game.Players:FindFirstChild(tag.Name)
            if not isRealCharacter(plr) then
                tag:Destroy()
            end
            if tag.Adornee then
                local owner = game.Players:GetPlayerFromCharacter(tag.Adornee.Parent)
                if owner ~= plr then
                    tag:Destroy()
                end
            end
        end
    end

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and isRealCharacter(plr) then
            createESP(plr)
        end
    end
end

-- Pickaxe

local function hasPickaxe()
    local backpack = getBackpack()
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then return true end
        end
    end
    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then return true end
        end
    end
    return false
end

local function findPickaxe()
    local backpack = getBackpack()
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then return tool end
        end
    end
    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then return tool end
        end
    end
    return nil
end

local function equipPickaxe()
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then
        return true
    end

    local backpack = getBackpack()
    if not backpack then return false end

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            hum:EquipTool(tool)
            return true
        end
    end

    return false
end

local function attackCrystal()
    equipPickaxe()
    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
    end
    virtualClick()
end

-- Sword candy collect

local function fireSwordCandyTouch(swordCandy)
    local root = getHRP()
    if not root then return end
    if not swordCandy or not swordCandy.Parent then return end

    local touch = swordCandy:FindFirstChild("TouchInterest")
    if not touch then
        for _, child in ipairs(swordCandy:GetDescendants()) do
            if child:IsA("TouchInterest") then
                touch = child
                break
            end
        end
    end

    if touch then
        pcall(function()
            firetouchinterest(root, swordCandy, 0)
            task.wait(0.02)
            firetouchinterest(root, swordCandy, 1)
        end)
    end
end

local function pullSwordCandy(swordCandy)
    local root = getHRP()
    if not root then return end
    if not swordCandy or not swordCandy.Parent then return end

    pcall(function()
        if swordCandy:IsA("BasePart") then
            swordCandy.CFrame = root.CFrame
        elseif swordCandy:IsA("Model") then
            if swordCandy.PrimaryPart then
                swordCandy:PivotTo(root.CFrame)
            else
                for _, part in ipairs(swordCandy:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CFrame = root.CFrame
                        break
                    end
                end
            end
        end
    end)
end

local function collectSwordCandy(swordCandy)
    if CONFIG.CandyMode == "touch" then
        fireSwordCandyTouch(swordCandy)
    elseif CONFIG.CandyMode == "pull" then
        pullSwordCandy(swordCandy)
        task.wait(0.05)
        fireSwordCandyTouch(swordCandy)
    elseif CONFIG.CandyMode == "both" then
        fireSwordCandyTouch(swordCandy)
        pullSwordCandy(swordCandy)
        task.wait(0.05)
        fireSwordCandyTouch(swordCandy)
    end
end

-- Anti-player

local function getPlayersInCave()
    local players = {}
    local myRoot = getHRP()
    if not myRoot then return players end

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - myRoot.Position).Magnitude
                    if dist <= CONFIG.PlayerCheckDistance then
                        table.insert(players, plr)
                    end
                end
            end
        end
    end
    return players
end

-- Anti-spectator

local function hasSpectator(plr)
    if not plr then return false, nil end

    local backpack = plr:FindFirstChild("Backpack")
    if backpack then
        local spec = backpack:FindFirstChild("spectator")
        if spec then
            return true, "Backpack"
        end
    end

    local char = plr.Character
    if char then
        local spec = char:FindFirstChild("spectator")
        if spec then
            return true, "Character"
        end
    end

    return false, nil
end

local function getSpectators()
    local players = {}

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local hasSpec, where = hasSpectator(plr)
            if hasSpec then
                table.insert(players, {player = plr, where = where})
            end
        end
    end
    return players
end

local function teleportToCenter()
    if not CONFIG.ContainerCenter then
        if CONFIG.Container then
            teleportTo(CONFIG.Container, Vector3.new(0, 5, 0))
        end
        return
    end
    teleportTo(CONFIG.ContainerCenter, Vector3.new(0, 5, 0))
end

-- Warning GUI

local warningGui = nil

local function showWarning(playerName)
    if warningGui then warningGui:Destroy() end

    warningGui = Instance.new("ScreenGui")
    warningGui.Name = "ZrzocksWarning"
    warningGui.ResetOnSpawn = false
    warningGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 120)
    frame.Position = UDim2.new(0.5, -200, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = warningGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 80, 0, 80)
    icon.Position = UDim2.new(0, 20, 0.5, -40)
    icon.BackgroundTransparency = 1
    icon.Text = "!"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBold
    icon.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 0, 30)
    title.Position = UDim2.new(0, 110, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "PLAYER DETECTED!"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -120, 0, 60)
    desc.Position = UDim2.new(0, 110, 0, 45)
    desc.BackgroundTransparency = 1
    desc.Text = playerName .. " is nearby!\nAuto farm stopped. Teleported to center."
    desc.TextColor3 = Color3.fromRGB(255, 230, 230)
    desc.TextScaled = true
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextWrapped = true
    desc.Parent = frame

    task.delay(5, function()
        if warningGui then
            warningGui:Destroy()
            warningGui = nil
        end
    end)
end

-- Farm state

local startBtn = nil
local statusText = nil
local running = false

local function setFarmState(state)
    running = state
    if startBtn then
        if running then
            startBtn.Text = "STOP AUTO CRYSTALS"
            startBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        else
            startBtn.Text = "START AUTO CRYSTALS"
            startBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
        end
    end
end

-- Anti-player loop

local lastWarningTime = 0
local waitingForClear = false

task.spawn(function()
    while true do
        task.wait(1)

        if CONFIG.AntiSpectatorEnabled and tick() - lastSpectatorWarning > CONFIG.WarningCooldown then
            local spectators = getSpectators()

            if #spectators > 0 then
                lastSpectatorWarning = tick()
                local data = spectators[1]
                local plr = data.player

                showWarning(plr.Name .. " (Spectator)")

                if running then
                    setFarmState(false)
                    waitingForClear = true
                end

                if CONFIG.CandyFarmEnabled then
                    CONFIG.CandyFarmEnabled = false
                end

                if statusText then
                    statusText.Text = "Status: Spectator detected!"
                end
            end
        end
    end
end)

-- Anti-spectator loop

local lastSpectatorWarning = 0

task.spawn(function()
    while true do
        task.wait(1)

        if CONFIG.AntiSpectatorEnabled and tick() - lastSpectatorWarning > CONFIG.WarningCooldown then
            local spectators = getSpectators()

            if #spectators > 0 then
                lastSpectatorWarning = tick()
                local data = spectators[1]
                local plr = data.player

                showWarning(plr.Name .. " (Spectator)")

                if running then
                    setFarmState(false)
                    waitingForClear = true
                end

                if CONFIG.CandyFarmEnabled then
                    CONFIG.CandyFarmEnabled = false
                end

                teleportToCenter()

                if statusText then
                    statusText.Text = "Status: Spectator detected!"
                end
            end
        end
    end
end)

-- ESP loop

task.spawn(function()
    while true do
        task.wait(0.5)
        if CONFIG.ESPEnabled then
            updateESP()
        else
            clearESP()
        end
    end
end)

-- Candy farm loop

task.spawn(function()
    while true do
        task.wait(0.5)
        if CONFIG.CandyFarmEnabled then
            findSwordCandies()
            for _, swordCandy in ipairs(CONFIG.Candies) do
                if not CONFIG.CandyFarmEnabled then break end
                if not swordCandy.Parent then continue end
                collectSwordCandy(swordCandy)
                task.wait(0.1)
            end
        end
    end
end)

-- ESP instant update

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if CONFIG.ESPEnabled then
            createESP(plr)
        end
    end)
end)

-- Auto farm loop

local function startFarm()
    setFarmState(true)

    task.spawn(function()
        while running do
            findObjects()

            if not hasPickaxe() then
                if statusText then statusText.Text = "Status: Getting pickaxe" end
                if CONFIG.Speaker then
                    teleportTo(CONFIG.Speaker, Vector3.new(0, 3, 5))
                    task.wait(0.3)

                    local prompt = nil
                    pcall(function()
                        for _, child in ipairs(CONFIG.Speaker:GetDescendants()) do
                            if child:IsA("ProximityPrompt") then
                                prompt = child
                                break
                            end
                        end
                    end)
                    if prompt then
                        firePrompt(prompt)
                        task.wait(1.5)
                    end
                end
                task.wait(0.3)
            end

            equipPickaxe()
            task.wait(0.1)

            if statusText then statusText.Text = "Status: Mining crystals" end
            findObjects()
            for _, crystal in ipairs(CONFIG.Crystals) do
                if not running then break end
                if not crystal.Parent then continue end

                if statusText then statusText.Text = "Status: Mining " .. crystal.Name end
                teleportTo(crystal)
                task.wait(0.1)

                local timeout = 0
                while crystal.Parent and timeout < CONFIG.CrystalTimeout and running do
                    equipPickaxe()
                    attackCrystal()
                    task.wait(CONFIG.ClickDelay)
                    timeout = timeout + CONFIG.ClickDelay
                end
            end

            if running and #CONFIG.Collectors > 0 then
                if statusText then statusText.Text = "Status: Depositing" end
                local collector = CONFIG.Collectors[1]
                teleportTo(collector, Vector3.new(0, 3, 8))
                task.wait(CONFIG.DepositDelay)

                local prompt = nil
                pcall(function()
                    local d = collector:FindFirstChild("d")
                    if d then
                        prompt = d:FindFirstChild("ProximityPrompt")
                    end
                end)
                if prompt then
                    firePrompt(prompt)
                    task.wait(CONFIG.DepositDelay)
                end
            end

            task.wait(0.5)
        end
    end)
end

local function stopFarm()
    setFarmState(false)
end

-- GUI

local gui = Instance.new("ScreenGui")
gui.Name = "ZrzocksHub_SillySword"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 600, 0, 450)
frame.Position = UDim2.new(0.5, -300, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(34, 22, 17)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 150, 1, 0)
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

local tabs = {"Farm", "Teleports", "Misc", "Guide", "Credits"}
local tabButtons = {}
local containers = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, 42 + (i-1) * 33)
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
    tabButtons[tabName] = btn

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -165, 1, -15)
    container.Position = UDim2.new(0, 160, 0, 8)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 6
    container.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 100)
    container.ScrollingDirection = Enum.ScrollingDirection.Y
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

-- Profile

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
avatarFrame.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"

local displayName = Instance.new("TextLabel")
displayName.Size = UDim2.new(0.6, 0, 0, 14)
displayName.Position = UDim2.new(0, 48, 0, 6)
displayName.BackgroundTransparency = 1
displayName.Text = player.Name
displayName.TextColor3 = Color3.fromRGB(230, 210, 190)
displayName.TextScaled = true
displayName.Font = Enum.Font.GothamBold
displayName.TextXAlignment = Enum.TextXAlignment.Left
displayName.Parent = profileFrame

local username = Instance.new("TextLabel")
username.Size = UDim2.new(0.6, 0, 0, 12)
username.Position = UDim2.new(0, 48, 0, 24)
username.BackgroundTransparency = 1
username.Text = "@" .. player.Name
username.TextColor3 = Color3.fromRGB(150, 130, 120)
username.TextScaled = true
username.Font = Enum.Font.Gotham
username.TextXAlignment = Enum.TextXAlignment.Left
username.Parent = profileFrame

-- Close / Fold

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    stopFarm()
    if warningGui then warningGui:Destroy() end
    clearESP()
    gui:Destroy()
end)

local foldBtn = Instance.new("TextButton")
foldBtn.Size = UDim2.new(0, 24, 0, 24)
foldBtn.Position = UDim2.new(1, -60, 0, 5)
foldBtn.BackgroundTransparency = 1
foldBtn.Text = "-"
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
    frame.Visible = false
    iconBtn.Visible = true
end)

iconBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    iconBtn.Visible = false
end)

-- Helpers

local function createSectionLabel(parent, text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
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

local function createSettingRow(parent, labelText, valueText, y, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 0, 20)
    lbl.Position = UDim2.new(0, 5, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.2, 0, 0, 20)
    box.Position = UDim2.new(0.45, 0, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = tostring(valueText)
    box.TextScaled = true
    box.Font = Enum.Font.GothamBold
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then
            callback(val)
        else
            box.Text = tostring(valueText)
        end
    end)
    return box
end

local function createToggleButton(parent, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

local function createActionButton(parent, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 80, 120)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Farm tab

local farmContainer = containers["Farm"]
local yFarm = 5

createSectionLabel(farmContainer, "Candy Farm", yFarm)
yFarm = yFarm + 22

createToggleButton(farmContainer, "CANDY FARM (OFF)", yFarm, function(btn)
    CONFIG.CandyFarmEnabled = not CONFIG.CandyFarmEnabled
    btn.Text = CONFIG.CandyFarmEnabled and "CANDY FARM (ON)" or "CANDY FARM (OFF)"
    btn.BackgroundColor3 = CONFIG.CandyFarmEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(50, 50, 80)
end)
yFarm = yFarm + 32

createToggleButton(farmContainer, "CANDY MODE: BOTH", yFarm, function(btn)
    if CONFIG.CandyMode == "both" then
        CONFIG.CandyMode = "touch"
    elseif CONFIG.CandyMode == "touch" then
        CONFIG.CandyMode = "pull"
    else
        CONFIG.CandyMode = "both"
    end
    btn.Text = "CANDY MODE: " .. CONFIG.CandyMode:upper()
end)
yFarm = yFarm + 38

createSectionLabel(farmContainer, "Auto Crystals", yFarm)
yFarm = yFarm + 22

createSettingRow(farmContainer, "Click Delay:", CONFIG.ClickDelay, yFarm, function(val)
    if val >= 0 then CONFIG.ClickDelay = val end
end)
yFarm = yFarm + 24

createSettingRow(farmContainer, "Sec per Teleport:", CONFIG.CrystalTimeout, yFarm, function(val)
    if val > 0 then CONFIG.CrystalTimeout = val end
end)
yFarm = yFarm + 24

createSettingRow(farmContainer, "Deposit Delay:", CONFIG.DepositDelay, yFarm, function(val)
    if val > 0 then CONFIG.DepositDelay = val end
end)
yFarm = yFarm + 24

createToggleButton(farmContainer, "PICKAXE SLOT: 2", yFarm, function(btn)
    CONFIG.PickaxeSlot = CONFIG.PickaxeSlot + 1
    if CONFIG.PickaxeSlot > 9 then CONFIG.PickaxeSlot = 1 end
    btn.Text = "PICKAXE SLOT: " .. CONFIG.PickaxeSlot
end)
yFarm = yFarm + 34

startBtn = createToggleButton(farmContainer, "START AUTO CRYSTALS", yFarm, function(btn)
    if running then
        stopFarm()
        if statusText then statusText.Text = "Status: Stopped" end
    else
        startFarm()
        if statusText then statusText.Text = "Status: Farming..." end
    end
end)
yFarm = yFarm + 40

farmContainer.CanvasSize = UDim2.new(0, 0, 0, yFarm + 20)

-- Teleports tab

local tpContainer = containers["Teleports"]
local yTp = 5

createSectionLabel(tpContainer, "Teleports", yTp)
yTp = yTp + 22

createActionButton(tpContainer, "TELEPORT TO CAVE", yTp, function()
    findObjects()
    teleportTo(CONFIG.CaveEntrance)
    task.wait(0.8)
    if CONFIG.CaveInside then
        teleportTo(CONFIG.CaveInside, Vector3.new(0, 5, 0))
    end
    if statusText then statusText.Text = "Status: Teleported" end
end)
yTp = yTp + 34

createActionButton(tpContainer, "GET PICKAXE", yTp, function()
    findObjects()
    if CONFIG.Speaker then
        teleportTo(CONFIG.Speaker, Vector3.new(0, 3, 5))
        task.wait(0.3)
        local prompt = nil
        pcall(function()
            for _, child in ipairs(CONFIG.Speaker:GetDescendants()) do
                if child:IsA("ProximityPrompt") then
                    prompt = child
                    break
                end
            end
        end)
        if prompt then
            firePrompt(prompt)
            task.wait(1.2)
        end
    end
    equipPickaxe()
    if statusText then statusText.Text = "Status: Got pickaxe" end
end)
yTp = yTp + 34

createActionButton(tpContainer, "DEPOSIT CRYSTALS", yTp, function()
    findObjects()
    if #CONFIG.Collectors > 0 then
        local collector = CONFIG.Collectors[1]
        teleportTo(collector, Vector3.new(0, 3, 8))
        task.wait(0.5)
        local prompt = nil
        pcall(function()
            local d = collector:FindFirstChild("d")
            if d then prompt = d:FindFirstChild("ProximityPrompt") end
        end)
        if prompt then
            firePrompt(prompt)
            task.wait(0.5)
        end
    end
    if statusText then statusText.Text = "Status: Deposited" end
end)
yTp = yTp + 34

tpContainer.CanvasSize = UDim2.new(0, 0, 0, yTp + 20)

-- Misc tab

local miscContainer = containers["Misc"]
local yMisc = 5

createSectionLabel(miscContainer, "Visual", yMisc)
yMisc = yMisc + 22

createToggleButton(miscContainer, "ESP (OFF)", yMisc, function(btn)
    CONFIG.ESPEnabled = not CONFIG.ESPEnabled
    btn.Text = CONFIG.ESPEnabled and "ESP (ON)" or "ESP (OFF)"
    btn.BackgroundColor3 = CONFIG.ESPEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(50, 50, 80)
    if not CONFIG.ESPEnabled then clearESP() end
end)
yMisc = yMisc + 34

createSectionLabel(miscContainer, "Anti-Player", yMisc)
yMisc = yMisc + 22

createToggleButton(miscContainer, "ANTI-PLAYER (OFF)", yMisc, function(btn)
    CONFIG.AntiPlayerEnabled = not CONFIG.AntiPlayerEnabled
    btn.Text = CONFIG.AntiPlayerEnabled and "ANTI-PLAYER (ON)" or "ANTI-PLAYER (OFF)"
    btn.BackgroundColor3 = CONFIG.AntiPlayerEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(50, 50, 80)
end)
yMisc = yMisc + 34

createSettingRow(miscContainer, "Check Dist:", CONFIG.PlayerCheckDistance, yMisc, function(val)
    if val > 0 then CONFIG.PlayerCheckDistance = val end
end)
yMisc = yMisc + 24

createSettingRow(miscContainer, "Warning Cooldown:", CONFIG.WarningCooldown, yMisc, function(val)
    if val > 0 then CONFIG.WarningCooldown = val end
end)
yMisc = yMisc + 28

createSectionLabel(miscContainer, "Anti-Spectator", yMisc)
yMisc = yMisc + 22

createToggleButton(miscContainer, "ANTI-SPECTATOR (OFF)", yMisc, function(btn)
    CONFIG.AntiSpectatorEnabled = not CONFIG.AntiSpectatorEnabled
    btn.Text = CONFIG.AntiSpectatorEnabled and "ANTI-SPECTATOR (ON)" or "ANTI-SPECTATOR (OFF)"
    btn.BackgroundColor3 = CONFIG.AntiSpectatorEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(50, 50, 80)
end)
yMisc = yMisc + 34


createSectionLabel(miscContainer, "Movement", yMisc)
yMisc = yMisc + 22

createSettingRow(miscContainer, "WalkSpeed:", CONFIG.WalkSpeed, yMisc, function(val)
    if val > 0 then
        CONFIG.WalkSpeed = val
        setWalkSpeed(val)
    end
end)
yMisc = yMisc + 24

createSettingRow(miscContainer, "JumpPower:", CONFIG.JumpPower, yMisc, function(val)
    if val > 0 then
        CONFIG.JumpPower = val
        setJumpPower(val)
    end
end)
yMisc = yMisc + 30

miscContainer.CanvasSize = UDim2.new(0, 0, 0, yMisc + 20)

-- Guide tab

local guideContainer = containers["Guide"]
local yGuide = 5

local function createGuideTitle(parent, text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 16)
    lbl.Position = UDim2.new(0, 5, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 220, 150)
    lbl.TextScaled = false
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createGuideText(parent, text, y, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 12)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(200, 190, 180)
    lbl.TextScaled = false
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Parent = parent
    return lbl
end

local function createGuideButton(parent, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 0, 22)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 80, 120)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = false
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Thief Guide

createGuideTitle(guideContainer, "THIEF GUIDE", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "Click teleport below and click E, then wait.", yGuide)
yGuide = yGuide + 18

createGuideButton(guideContainer, "TELEPORT TO SWORD", yGuide, function()
    local sword = workspace:FindFirstChild("FX")
    if sword then
        sword = sword:FindFirstChild("sw")
        if sword then
            sword = sword:FindFirstChild("sword")
        end
    end
    if sword then
        teleportTo(sword, Vector3.new(0, 3, 0))
        if statusText then statusText.Text = "Status: Teleported to sword" end
    else
        if statusText then statusText.Text = "Status: Sword not found" end
    end
end)
yGuide = yGuide + 32

-- Void Guide

createGuideTitle(guideContainer, "VOID GUIDE", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "Just click teleport and you got it.", yGuide)
yGuide = yGuide + 18

createGuideButton(guideContainer, "TELEPORT TO VOID", yGuide, function()
    local map = workspace:FindFirstChild("map")
    local part = nil
    if map then
        local oob = map:FindFirstChild("oob")
        if oob then
            local brazil = oob:FindFirstChild("brazilLocations")
            if brazil then
                part = brazil:FindFirstChild("part that gives you void lol")
            end
        end
    end
    if part then
        teleportTo(part, Vector3.new(0, 3, 0))
        if statusText then statusText.Text = "Status: Teleported to void" end
    else
        if statusText then statusText.Text = "Status: Void part not found" end
    end
end)
yGuide = yGuide + 32

-- Tree Guide

createGuideTitle(guideContainer, "TREE GUIDE", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "Just click teleport button.", yGuide)
yGuide = yGuide + 18

createGuideButton(guideContainer, "TELEPORT TO TREE", yGuide, function()
    local map = workspace:FindFirstChild("map")
    local part = nil
    if map then
        local loadedMap = map:FindFirstChild("loadedMap")
        if loadedMap then
            local treeIsland = loadedMap:FindFirstChild("tree island")
            if treeIsland then
                local destructable = treeIsland:FindFirstChild("destructable")
                if destructable then
                    local bigTree = destructable:FindFirstChild("big tree")
                    if bigTree then
                        local children = bigTree:GetChildren()
                        if children[52] then
                            part = children[52]
                        end
                    end
                end
            end
        end
    end
    if part then
        teleportTo(part, Vector3.new(0, 3, 0))
        if statusText then statusText.Text = "Status: Teleported to tree" end
    else
        if statusText then statusText.Text = "Status: Tree part not found" end
    end
end)
yGuide = yGuide + 32

-- Jelly Guide

createGuideTitle(guideContainer, "JELLY GUIDE", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "Click teleport.", yGuide)
yGuide = yGuide + 18

createGuideButton(guideContainer, "TELEPORT TO JELLY", yGuide, function()
    local map = workspace:FindFirstChild("map")
    local part = nil
    if map then
        local oob = map:FindFirstChild("oob")
        if oob then
            local cave = oob:FindFirstChild("cave")
            if cave then
                local children = cave:GetChildren()
                if children[50] then
                    part = children[50]
                end
            end
        end
    end
    if part then
        teleportTo(part, Vector3.new(0, 3, 0))
        if statusText then statusText.Text = "Status: Teleported to jelly" end
    else
        if statusText then statusText.Text = "Status: Jelly part not found" end
    end
end)
yGuide = yGuide + 32

-- Accident Guide

createGuideTitle(guideContainer, "ACCIDENT GUIDE", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "Click teleport.", yGuide)
yGuide = yGuide + 18

createGuideButton(guideContainer, "TELEPORT TO ACCIDENT", yGuide, function()
    local map = workspace:FindFirstChild("map")
    local part = nil
    if map then
        local oob = map:FindFirstChild("oob")
        if oob then
            local cave = oob:FindFirstChild("cave")
            if cave then
                part = cave:FindFirstChild("launchspot")
            end
        end
    end
    if part then
        teleportTo(part, Vector3.new(0, 3, 0))
        if statusText then statusText.Text = "Status: Teleported to accident" end
    else
        if statusText then statusText.Text = "Status: Accident part not found" end
    end
end)
yGuide = yGuide + 32

-- A Mimir Guide

createGuideTitle(guideContainer, "A MIMIR GUIDE", yGuide)
yGuide = yGuide + 18
createGuideText(guideContainer, "Click teleport.", yGuide)
yGuide = yGuide + 18

createGuideButton(guideContainer, "TELEPORT TO MIMIR", yGuide, function()
    local map = workspace:FindFirstChild("map")
    local part = nil
    if map then
        local oob = map:FindFirstChild("oob")
        if oob then
            local house = oob:FindFirstChild("robert's house")
            if house then
                part = house:FindFirstChild("leaveroberthome")
            end
        end
    end
    if part then
        teleportTo(part, Vector3.new(0, 3, 0))
        if statusText then statusText.Text = "Status: Teleported to mimir" end
    else
        if statusText then statusText.Text = "Status: Mimir part not found" end
    end
end)
yGuide = yGuide + 32

guideContainer.CanvasSize = UDim2.new(0, 0, 0, yGuide + 20)

-- Credits tab

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
yCredits = yCredits + 40

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

addCredit("Idea Maker: zrzock", yCredits)
yCredits = yCredits + 30
addCredit("Creator: zrzock", yCredits)
yCredits = yCredits + 30
addCredit("Thanks for using!", yCredits, Color3.fromRGB(150, 150, 200))
yCredits = yCredits + 30

creditsContainer.CanvasSize = UDim2.new(0, 0, 0, yCredits + 20)

-- RightAlt toggle

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        gui.Enabled = not gui.Enabled
    end
end)
