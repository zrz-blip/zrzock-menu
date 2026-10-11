local GITHUB_USER = "zrz-blip"
local GITHUB_REPO = "zrzock-menu"
local GITHUB_BRANCH = "main"

local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/", GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)

local CATALOG = {
    {
        Key = "infinite_tower_tycoon",
        Name = "Infinite Tower Tycoon",
        Places = { 10272636261 },
        Universe = nil,
        Script = "scripts/InfiniteTowerTycoon.lua",
        Listed = true,
        Tone = Color3.fromRGB(255, 180, 80),
        Image = "rbxassetid://106109636799806",
    },
}

local function matchPlace(placeId, universeId)
    for _, entry in ipairs(CATALOG) do
        if entry.Universe and entry.Universe == universeId then return entry end
    end
    for _, entry in ipairs(CATALOG) do
        for _, id in ipairs(entry.Places) do
            if id == placeId then return entry end
        end
    end
    return nil
end

local function launch(entry)
    local url = BASE_URL .. entry.Script
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url), "@" .. entry.Key)()
    end)
    return ok, result
end

local UI_URL = BASE_URL .. "ui/ZrzocksUI.lua"
local ZrzocksUI = loadstring(game:HttpGet(UI_URL), "@ZrzocksUI")()

local menu = ZrzocksUI:CreateMenu({
    Name = "Zrzocks Hub",
    Icon = "⚡",
    Size = UDim2.fromOffset(600, 420),
    ToggleKey = Enum.KeyCode.LeftControl,
})

local scriptsTab = menu:AddTab("Scripts")
local miscTab = menu:AddTab("Misc")

menu:Notify({
    Title = "Zrzocks Hub",
    Description = "Welcome!",
    Duration = 3,
})

-- ============================================
-- SCRIPTS TAB
-- ============================================

for _, entry in ipairs(CATALOG) do
    if entry.Listed then
        menu:AddCard({
            Name = entry.Name,
            Image = entry.Image,
            Tone = entry.Tone,
            PlaceId = entry.Places[1],
            ButtonText = "Run",
            Callback = function()
                menu:Notify({
                    Title = "Zrzocks Hub",
                    Description = "Starting " .. entry.Name,
                    Duration = 3,
                })
                task.spawn(function()
                    local ok, err = launch(entry)
                    if not ok then
                        menu:Notify({
                            Title = "Error",
                            Description = tostring(err),
                            Tone = "Danger",
                            Duration = 8,
                        })
                    end
                end)
            end,
        })
    end
end

-- ============================================
-- MISC TAB
-- ============================================

local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function createESP(player)
    if player == game.Players.LocalPlayer then return end
    if not player.Character then return end
    local holder = ESPFolder:FindFirstChild(player.Name)
    if not holder then
        holder = Instance.new("Folder")
        holder.Name = player.Name
        holder.Parent = ESPFolder
    end
    holder:ClearAllChildren()

    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.Adornee = player.Character
    highlight.FillColor = espColor
    highlight.OutlineColor = espColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = holder

    local head = player.Character:FindFirstChild("Head")
    if head then
        local nameTag = Instance.new("BillboardGui")
        nameTag.Name = "NameTag"
        nameTag.Size = UDim2.new(0, 200, 0, 50)
        nameTag.AlwaysOnTop = true
        nameTag.StudsOffset = Vector3.new(0, 3, 0)
        nameTag.Adornee = head
        nameTag.Parent = holder

        local tag = Instance.new("TextLabel")
        tag.BackgroundTransparency = 1
        tag.Size = UDim2.new(1, 0, 0, 20)
        tag.TextSize = 14
        tag.TextColor3 = espColor
        tag.TextStrokeColor3 = Color3.new(0, 0, 0)
        tag.TextStrokeTransparency = 0.4
        tag.Text = player.Name
        tag.Font = Enum.Font.SourceSansBold
        tag.Parent = nameTag
    end
end

local function enableESP()
    espEnabled = true
    for _, player in ipairs(game.Players:GetPlayers()) do
        createESP(player)
    end
end

local function disableESP()
    espEnabled = false
    ESPFolder:ClearAllChildren()
end

game:GetService("Players").PlayerAdded:Connect(function(player)
    if espEnabled then createESP(player) end
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if espEnabled then createESP(player) end
    end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    local holder = ESPFolder:FindFirstChild(player.Name)
    if holder then holder:Destroy() end
end)

local yMisc = 5

local function addLabel(text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = miscTab
    return lbl
end

local function addBtn(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 26)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = miscTab
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function addBox(text, y, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.9, 0, 0, 22)
    box.Position = UDim2.new(0.05, 0, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = text
    box.TextScaled = true
    box.Font = Enum.Font.GothamBold
    box.Parent = miscTab
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    box.FocusLost:Connect(function()
        callback(box.Text)
    end)
    return box
end

addLabel("ESP", yMisc)
yMisc = yMisc + 20

local espBtn = addBtn("ESP (OFF)", yMisc, function()
    if espEnabled then
        disableESP()
        espBtn.Text = "ESP (OFF)"
        espBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    else
        enableESP()
        espBtn.Text = "ESP (ON)"
        espBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
    end
end)
yMisc = yMisc + 30

addLabel("Speed", yMisc)
yMisc = yMisc + 20

addBox("100", yMisc, function(val)
    local num = tonumber(val)
    if num and num > 0 then
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = num
        end)
    end
end)
yMisc = yMisc + 26

addLabel("Jump Power", yMisc)
yMisc = yMisc + 20

addBox("50", yMisc, function(val)
    local num = tonumber(val)
    if num and num > 0 then
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = num
        end)
    end
end)
yMisc = yMisc + 26

local noclipEnabled = false
local noclipBtn = addBtn("NOCLIP (OFF)", yMisc, function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "NOCLIP (ON)" or "NOCLIP (OFF)"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
    if noclipEnabled then
        task.spawn(function()
            while noclipEnabled do
                task.wait(0.1)
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    end
end)
yMisc = yMisc + 30

miscTab.CanvasSize = UDim2.new(0, 0, 0, yMisc + 20)
