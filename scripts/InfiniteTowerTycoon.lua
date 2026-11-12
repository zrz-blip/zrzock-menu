local UI_URL = "https://raw.githubusercontent.com/zrz-blip/zrzock-menu/refs/heads/main/ZrzocksUI.lua"
local ZrzocksUI = loadstring(game:HttpGet(UI_URL))()

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
local leafTeleportEnabled = false
local flySpeed = 50
local collectorDelay = 5
local speedValue = 100

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
                            pcall(function() obj.Velocity = (hrp.Position - obj.Position).Unit * 120 end)
                            if dist > 50 then
                                pcall(function() obj.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2, 0)) end)
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
            local blueZone = zones and zones:FindFirstChild("BlueZone")
            if blueZone then
                local allModels = blueZone:FindFirstChild("AllModels")
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
                        if targetPart then
                            local pos = targetPart.Position
                            hrp.CFrame = CFrame.new(pos + Vector3.new(-1.5, 0.5, 0))
                            wait(0.15)
                            hrp.CFrame = startPos
                        end
                    end
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
    local char = player.Character
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
        if not flyEnabled or not player.Character or not torso or not torso.Parent then return end
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

local function teleportToLeaf()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local folder = workspace:FindFirstChild("BoneFolder")
    if not folder then return end
    local nearest = nil
    local minDist = math.huge
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("MeshPart") and obj.Name == "bone" then
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

local menu = ZrzocksUI:CreateMenu({ Name = "zrzocks menu" })

local mainTab = menu:AddTab("Main")
menu:AddSection("Main", "Crate Attractor")
menu:AddToggle("Main", {
    Text = "ATTRACT",
    Default = false,
    Callback = function(state)
        attractEnabled = state
        if state then startAttract() end
    end
})

menu:AddSection("Main", "Key Collector")
menu:AddToggle("Main", {
    Text = "COLLECT KEYS",
    Default = false,
    Callback = function(state)
        keyCollectEnabled = state
        if state then collectKeys() end
    end
})

menu:AddSection("Main", "Auto Buy")
menu:AddToggle("Main", {
    Text = "AUTO BUY",
    Default = false,
    Callback = function(state)
        autoBuyEnabled = state
        if state then startAutoBuy() end
    end
})

menu:AddSection("Main", "Auto Collector")
menu:AddSlider("Main", {
    Text = "Delay",
    Min = 1,
    Max = 20,
    Default = 5,
    Callback = function(val) collectorDelay = val end
})

menu:AddToggle("Main", {
    Text = "COLLECTOR",
    Default = false,
    Callback = function(state)
        collectorEnabled = state
        if state then startCollector() end
    end
})

menu:AddSection("Main", "Leaf Teleport")
menu:AddToggle("Main", {
    Text = "LEAF TELEPORT",
    Default = false,
    Callback = function(state)
        leafTeleportEnabled = state
        if state then startLeafTeleport() end
    end
})

local extrasTab = menu:AddTab("Extras")
menu:AddSection("Extras", "Speed")
menu:AddSlider("Extras", {
    Text = "Speed",
    Min = 16,
    Max = 300,
    Default = 100,
    Callback = function(val)
        speedValue = val
        if speedEnabled and player.Character then
            pcall(function() player.Character.Humanoid.WalkSpeed = speedValue end)
        end
    end
})

menu:AddToggle("Extras", {
    Text = "ENABLE SPEED",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if speedEnabled then
            pcall(function() player.Character.Humanoid.WalkSpeed = speedValue end)
        else
            pcall(function() player.Character.Humanoid.WalkSpeed = 16 end)
        end
    end
})

menu:AddSection("Extras", "Fly")
menu:AddSlider("Extras", {
    Text = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(val) flySpeed = val end
})

menu:AddToggle("Extras", {
    Text = "FLY",
    Default = false,
    Callback = function(state)
        flyEnabled = state
        toggleFly()
    end
})

menu:AddSection("Extras", "Utility")
menu:AddToggle("Extras", {
    Text = "ANTI-AFK",
    Default = false,
    Callback = function(state)
        antiAFKEnabled = state
        if state then startAntiAFK() end
    end
})

menu:AddToggle("Extras", {
    Text = "GOD MODE",
    Default = false,
    Callback = function(state)
        godModeEnabled = state
        if state then startGodMode() end
    end
})

menu:AddToggle("Extras", {
    Text = "NOCLIP",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        if state then
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
    end
})

menu:AddToggle("Extras", {
    Text = "INF JUMP",
    Default = false,
    Callback = function(state)
        jumpEnabled = state
        if state then
            UserInputService.JumpRequest:Connect(function()
                if jumpEnabled and player.Character then
                    pcall(function() player.Character.Humanoid:ChangeState("Jumping") end)
                end
            end)
        end
    end
})

local creditsTab = menu:AddTab("Credits")
menu:AddLabel("Credits", "Idea Maker: zrzock")
menu:AddLabel("Credits", "Creator: zrzock")
menu:AddLabel("Credits", "Thanks for using!")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        if menu.Gui then menu.Gui.Enabled = not menu.Gui.Enabled end
    end
end)
