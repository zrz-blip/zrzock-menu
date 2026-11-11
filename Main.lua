-- ============================================
-- ZRZOCKS HUB (Main)
-- ============================================
local GITHUB_USER = "zrz-blip"
local GITHUB_REPO = "zrzock-menu"
local GITHUB_BRANCH = "main"
local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/", GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Безопасная загрузка UI
local UI_URL = BASE_URL .. "ui/ZrzocksUI.lua"
local ok, ZrzocksUI = pcall(function() return loadstring(game:HttpGet(UI_URL), "@ZrzocksUI")() end)
if not ok then error("[Zrzocks Hub] UI failed: " .. tostring(ZrzocksUI)) end

local CATALOG = {
    { Key = "infinite_tower_tycoon", Name = "Infinite Tower Tycoon", Places = { 10272636261 }, Script = "scripts/InfiniteTowerTycoon.lua", Listed = true, Tone = Color3.fromRGB(225, 25, 45), Image = "rbxassetid://106109636799806" },
    { Key = "silly_sword_game", Name = "Silly Sword Game", Places = { 10697845123 }, Script = "scripts/SillySwordGame.lua", Listed = true, Tone = Color3.fromRGB(225, 25, 45), Image = "rbxassetid://0" },
}

local function launch(entry)
    local url = BASE_URL .. entry.Script
    local success, result = pcall(function() return loadstring(game:HttpGet(url), "@" .. entry.Key)() end)
    return success, result
end

local menu = ZrzocksUI:CreateMenu({
    Name = "Overwrite Hub",
    Icon = "✖",
    Size = UDim2.fromOffset(340, 46), -- Начальный компактный размер
    ToggleKey = Enum.KeyCode.RightControl,
})

local scriptsTab = menu:AddTab("Scripts")
local miscTab = menu:AddTab("Misc")

menu:Notify({ Title = "OVERWRITE", Description = "Loaded successfully.", Duration = 3 })

-- Заполнение каталога
for _, entry in ipairs(CATALOG) do
    if entry.Listed then
        menu:AddCard({
            Name = entry.Name, Image = entry.Image, Tone = entry.Tone, PlaceId = entry.Places[1], ButtonText = "RUN",
            Callback = function()
                menu:Notify({ Title = "OVERWRITE", Description = "Starting " .. entry.Name, Duration = 3 })
                task.spawn(function()
                    local success, err = launch(entry)
                    if not success then menu:Notify({ Title = "Error", Description = tostring(err), Duration = 8 }) end
                end)
            end,
        })
    end
end

-- ============================================
-- ESP
-- ============================================
local espEnabled = false
local espColor = Color3.fromRGB(225, 25, 45)

-- Безопасное создание папки (фоллбэк на PlayerGui для Xeno)
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Overwrite_ESP"
local okHui, hui = pcall(gethui)
if okHui and hui then
    ESPFolder.Parent = hui
else
    local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if pg then ESPFolder.Parent = pg else ESPFolder.Parent = CoreGui end
end

local function createESP(player)
    if player == Players.LocalPlayer or not player.Character then return end
    local holder = ESPFolder:FindFirstChild(player.Name) or Instance.new("Folder", ESPFolder)
    holder.Name = player.Name
    holder:ClearAllChildren()

    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = espColor
    highlight.OutlineColor = espColor
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = holder

    local head = player.Character:FindFirstChild("Head")
    if head then
        local nameTag = Instance.new("BillboardGui", holder)
        nameTag.Size = UDim2.new(0, 200, 0, 50)
        nameTag.AlwaysOnTop = true
        nameTag.StudsOffset = Vector3.new(0, 3, 0)
        nameTag.Adornee = head

        local tag = Instance.new("TextLabel", nameTag)
        tag.BackgroundTransparency = 1
        tag.Size = UDim2.new(1, 0, 0, 20)
        tag.TextSize = 14
        tag.TextColor3 = espColor
        tag.TextStrokeColor3 = Color3.new(0, 0, 0)
        tag.TextStrokeTransparency = 0.4
        tag.Text = player.Name
        tag.Font = Enum.Font.Code
    end
end

local function enableESP() espEnabled = true; for _, p in ipairs(Players:GetPlayers()) do createESP(p) end end
local function disableESP() espEnabled = false; ESPFolder:ClearAllChildren() end

Players.PlayerAdded:Connect(function(player)
    if espEnabled then createESP(player) end
    player.CharacterAdded:Connect(function() task.wait(1); if espEnabled then createESP(player) end end)
end)
Players.PlayerRemoving:Connect(function(player)
    local holder = ESPFolder:FindFirstChild(player.Name)
    if holder then holder:Destroy() end
end)

-- ============================================
-- Misc Elements (ИСПРАВЛЕНО: btn передается)
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
    Label = "Speed", Text = "16",
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then pcall(function() Players.LocalPlayer.Character.Humanoid.WalkSpeed = num end) end
    end,
})

menu:AddLabel("Misc", "--- JUMP ---")
menu:AddTextBox("Misc", {
    Label = "Jump", Text = "50",
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then pcall(function() Players.LocalPlayer.Character.Humanoid.UseJumpPower = true; Players.LocalPlayer.Character.Humanoid.JumpPower = num end) end
    end,
})

menu:AddLabel("Misc", "--- NOCLIP ---")
local noclipEnabled = false
menu:AddButton("Misc", {
    Text = "Noclip: OFF",
    Callback = function(btn) -- ИСПРАВЛЕНО: btn приходит
        noclipEnabled = not noclipEnabled
        btn.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"
        btn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(225, 25, 45) or Color3.fromRGB(24, 24, 28)
        if noclipEnabled then
            task.spawn(function()
                while noclipEnabled do
                    task.wait(0.1)
                    local char = Players.LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetChildren()) do
                            if part:IsA("BasePart") then part.CollisionGroup = "NoclipGroup" end
                        end
                    end
                end
            end)
        end
    end,
})
