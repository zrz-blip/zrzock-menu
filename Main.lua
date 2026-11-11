-- ============================================
-- ZRZOCKS HUB (Main)
-- ============================================
local GITHUB_USER = "zrz-blip"
local GITHUB_REPO = "zrzock-menu"
local GITHUB_BRANCH = "main"

local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/", GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)

local CATALOG = {
    {
        Key = "infinite_tower_tycoon",
        Name = "Infinite Tower Tycoon",
        Places = { 10272636261 },
        Script = "scripts/InfiniteTowerTycoon.lua",
        Listed = true,
        Tone = Color3.fromRGB(225, 25, 45),
        Image = "rbxassetid://106109636799806",
    },
    {
        Key = "silly_sword_game",
        Name = "Silly Sword Game",
        Places = { 10697845123 },
        Script = "scripts/SillySwordGame.lua",
        Listed = true,
        Tone = Color3.fromRGB(225, 25, 45),
        Image = "rbxassetid://0",
    },
}

local function launch(entry)
    local url = BASE_URL .. entry.Script
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url), "@" .. entry.Key)()
    end)
    return ok, result
end

-- Загрузка библиотеки
local UI_URL = BASE_URL .. "ui/ZrzocksUI.lua"
local ok, ZrzocksUI = pcall(function()
    return loadstring(game:HttpGet(UI_URL), "@ZrzocksUI")()
end)
if not ok then
    error("[Zrzocks Hub] UI library failed to load: " .. tostring(ZrzocksUI))
end

local menu = ZrzocksUI:CreateMenu({
    Name = "Overwrite Hub",
    Icon = "✖",
    Size = UDim2.fromOffset(600, 420),
    ToggleKey = Enum.KeyCode.RightControl,
})

local scriptsTab = menu:AddTab("Scripts")
local miscTab = menu:AddTab("Misc")

menu:Notify({
    Title = "OVERWRITE",
    Description = "Loaded successfully.",
    Duration = 3,
})

-- Заполнение каталога
for _, entry in ipairs(CATALOG) do
    if entry.Listed then
        menu:AddCard({
            Name = entry.Name,
            Image = entry.Image,
            Tone = entry.Tone,
            PlaceId = entry.Places[1],
            ButtonText = "RUN",
            Callback = function()
                menu:Notify({
                    Title = "OVERWRITE",
                    Description = "Starting " .. entry.Name,
                    Duration = 3,
                })
                task.spawn(function()
                    local success, err = launch(entry)
                    if not success then
                        menu:Notify({
                            Title = "Error",
                            Description = tostring(err),
                            Duration = 8,
                        })
                    end
                end)
            end,
        })
    end
end

-- ============================================
-- ESP (Misc)
-- ============================================
local espEnabled = false
local espColor = Color3.fromRGB(225, 25, 45)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Overwrite_ESP"
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
        tag.Font = Enum.Font.Code
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

-- ============================================
-- UI Elements (Misc)
-- ============================================
menu:AddLabel("Misc", "--- ESP ---")

local espBtn = menu:AddButton("Misc", {
    Text = "ESP: OFF",
    Callback = function(btn)
        if espEnabled then
            disableESP()
            btn.Text = "ESP: OFF"
            btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
        else
            enableESP()
            btn.Text = "ESP: ON"
            btn.BackgroundColor3 = Color3.fromRGB(225, 25, 45)
        end
    end,
})

menu:AddLabel("Misc", "--- SPEED ---")
menu:AddTextBox("Misc", {
    Label = "Speed",
    Text = "16",
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            pcall(function()
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = num
            end)
        end
    end,
})

menu:AddLabel("Misc", "--- JUMP ---")
menu:AddTextBox("Misc", {
    Label = "Jump",
    Text = "50",
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            pcall(function()
                game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = num
            end)
        end
    end,
})

menu:AddLabel("Misc", "--- NOCLIP ---")
local noclipEnabled = false
menu:AddButton("Misc", {
    Text = "Noclip: OFF",
    Callback = function(btn)
        noclipEnabled = not noclipEnabled
        btn.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"
        btn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(225, 25, 45) or Color3.fromRGB(24, 24, 28)
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
    end,
})
