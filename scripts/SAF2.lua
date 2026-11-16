-- ============================================
-- SANS AUs FIGHTER 2 + HALLOWEEN MAP — TABBED HUB (FIXED)
-- ============================================
print("=== TABBED HUB START ===")

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- ============================================
-- GUI (Стиль Sans, с Вкладками)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SansTabbedHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 340)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "SANS HUB"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.Code
Title.TextSize = 20
Title.Parent = MainFrame

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 35)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -80)
ContentFrame.Position = UDim2.new(0, 10, 0, 70)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local tabs = {}
local tabContents = {}

local function createTab(name, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -5, 1, 0)
    btn.Position = UDim2.new((index-1) * 0.33, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(100, 100, 100)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.Parent = TabBar

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = ContentFrame

    tabs[name] = btn
    tabContents[name] = content

    btn.MouseButton1Click:Connect(function()
        for tabName, tabBtn in pairs(tabs) do
            tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            tabContents[tabName].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        content.Visible = true
    end)

    return content
end

local dummyContent = createTab("Dummy Farm", 1)
local halloweenContent = createTab("Halloween", 2)
local miscContent = createTab("Misc", 3)

tabs["Dummy Farm"].BackgroundColor3 = Color3.fromRGB(150, 0, 0)
tabs["Dummy Farm"].TextColor3 = Color3.fromRGB(255, 255, 255)
dummyContent.Visible = true

local function createToggle(parent, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.Parent = parent
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 30)
        if callback then callback(state) end
    end)
    return btn
end

-- ============================================
-- ВКЛАДКА 1: DUMMY FARM
-- ============================================
local selectedSkills = {} -- Список выбранных абилок (например: ["Gaster Blaster"] = true)
local autoSkillsEnabled = false
local spamThread = nil
local function useSelectedSkills()
	local char = player.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local backpack = player:FindFirstChild("Backpack")
	if not (hum and backpack) then return end

	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") and selectedSkills[item.Name] then
			pcall(function()
				hum:EquipTool(item)
				task.wait(0.05)
				item:Activate()
			end)
		end
	end
end

local function toggleSkillSpam(state)
	autoSkillsEnabled = state
	if spamThread then
		task.cancel(spamThread)
		spamThread = nil
	end
	if state then
		spamThread = task.spawn(function()
			while autoSkillsEnabled do
				useSelectedSkills()
				task.wait(0.15)
			end
		end)
	end
end 

local autoFarmNPCEnabled = false
createToggle(dummyContent, " SPAM SELECTED SKILLS", 0, toggleSkillSpam)
createToggle(dummyContent, " AUTO FARM DUMMY", 40, function(state)
	autoFarmNPCEnabled = state
end)
local skillY = 85

local function scanSkills()
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return end
	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") and selectedSkills[item.Name] == nil then
			selectedSkills[item.Name] = false
			createToggle(dummyContent, " SKILL: " .. item.Name, skillY, function(state)
				selectedSkills[item.Name] = state
			end)
			skillY = skillY + 38
		end
	end
end
scanSkills()
-- КОНЕЦ ВСТАВКИ
-- ============================================
-- ВКЛАДКА 2: HALLOWEEN
-- ============================================
local candyFarmEnabled = false

createToggle(halloweenContent, "AUTO COLLECT CANDIES", 0, function(state) 
    candyFarmEnabled = state
    if state then
        task.spawn(function()
            while candyFarmEnabled do
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local halloweenMap = workspace:FindFirstChild("HalloweenMap")
                
                if hrp and halloweenMap then
                    local activeFolder = halloweenMap:FindFirstChild("ActiveCandies")
                    if activeFolder and #activeFolder:GetChildren() > 0 then
                        local originalCFrame = hrp.CFrame
                        for _, candy in ipairs(activeFolder:GetChildren()) do
                            if candy and candy.Parent then
                                local pos = nil
                                if candy:IsA("BasePart") then
                                    pos = candy.Position
                                elseif candy:IsA("Model") then
                                    local mainPart = candy.PrimaryPart or candy:FindFirstChildWhichIsA("BasePart")
                                    if mainPart then pos = mainPart.Position end
                                end
                                if pos then
                                    hrp.CFrame = CFrame.new(pos)
                                    task.wait(0.6)
                                end
                            end
                        end
                        hrp.CFrame = originalCFrame
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

-- ============================================
-- ВКЛАДКА 3: MISC (ANTI-AFK БЕЗ ДУБЛЕЙ)
-- ============================================
local antiAFKEnabled = false

createToggle(miscContent, " ANTI-AFK", 0, function(state)
	antiAFKEnabled = state
end)

player.Idled:Connect(function()
	if antiAFKEnabled then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new(500, 400))
		end)
	end
end)

-- ============================================
-- ЛОГИКА РАБОТЫ
-- ============================================
RunService.Heartbeat:Connect(function()
    -- Фарм Dummy
    if autoFarmNPCEnabled then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local playersFolder = workspace:FindFirstChild("Players")
            if playersFolder then
                for _, dummy in ipairs(playersFolder:GetChildren()) do
                    if dummy.Name:find("Dummy") and dummy:FindFirstChild("Humanoid") and dummy.Humanoid.Health > 0 then
                        local dummyRoot = dummy:FindFirstChild("HumanoidRootPart") or dummy:FindFirstChild("Head")
                        if dummyRoot then
                            hrp.CFrame = CFrame.new(dummyRoot.Position + Vector3.new(0, 3, 0))
                            -- Обычный удар по думми
                            for _, tool in ipairs(char:GetChildren()) do
                                if tool:IsA("Tool") then pcall(function() tool:Activate() end) end
                            end
                            pcall(function()
                                VirtualUser:CaptureController()
                                VirtualUser:ClickButton1(Vector2.new(500, 500))
                            end)
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- СПАМ ВСЕХ АБИЛОК
task.spawn(function()
    while true do
        task.wait(0.1) -- Задержка между кругами спама
        if autoSkillsEnabled then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        pcall(function()
                            local char = player.Character
                            if char and char:FindFirstChild("Humanoid") then
                                char.Humanoid:EquipTool(item)
                                task.wait(0.05)
                                item:Activate()
                            end
                        end)
                    end
                end
            end
        end
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("=== TABBED HUB READY ===")
