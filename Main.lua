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

menu:AddTab("Scripts")
menu:AddTab("Misc")

menu:Notify({
    Title = "Zrzocks Hub",
    Description = "Welcome!",
    Duration = 3,
})

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

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = game:GetService("CoreGui")

local espEnabled = false
local espShowName = true
local espBoxSize = 3
local espColor = Color3.fromRGB(255, 0, 0)

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

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "Box"
    box.Size = Vector3.new(espBoxSize, espBoxSize * 2, espBoxSize)
    box.Color3 = espColor
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.Adornee = player.Character
    box.Parent = holder

    if espShowName then
        local nameTag = Instance.new("BillboardGui")
        nameTag.Name = "NameTag"
        nameTag.Size = UDim2.new(0, 200, 0, 50)
        nameTag.AlwaysOnTop = true
        nameTag.StudsOffset = Vector3.new(0, espBoxSize + 1, 0)
        nameTag.Adornee = player.Character:FindFirstChild("Head")
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

local function updateESP()
    if not espEnabled then return end
    for _, player in ipairs(game.Players:GetPlayers()) do
        createESP(player)
    end
end

local function clearESP()
    ESPFolder:ClearAllChildren()
end

local yMisc = 5

menu:AddLabel("Misc", "ESP", yMisc)
yMisc = yMisc + 20

local espBtn = menu:AddButton("Misc", {
    Y = yMisc,
    Text = "ESP (OFF)",
    Callback = function()
        espEnabled = not espEnabled
        espBtn.Text = espEnabled and "ESP (ON)" or "ESP (OFF)"
        espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(30, 30, 50)
        if espEnabled then updateESP() else clearESP() end
    end,
})
yMisc = yMisc + 30

menu:AddLabel("Misc", "Show Name", yMisc)
yMisc = yMisc + 20

local nameBtn = menu:AddButton("Misc", {
    Y = yMisc,
    Text = "NAME (ON)",
    Color = Color3.fromRGB(50, 120, 50),
    Callback = function()
        espShowName = not espShowName
        nameBtn.Text = espShowName and "NAME (ON)" or "NAME (OFF)"
        nameBtn.BackgroundColor3 = espShowName and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(50, 50, 80)
        if espEnabled then updateESP() end
    end,
})
yMisc = yMisc + 30

menu:AddLabel("Misc", "Box Size", yMisc)
yMisc = yMisc + 20

menu:AddTextBox("Misc", {
    Y = yMisc,
    Text = "3",
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            espBoxSize = num
            if espEnabled then updateESP() end
        end
    end,
})
yMisc = yMisc + 26

menu:AddLabel("Misc", "Speed", yMisc)
yMisc = yMisc + 20

menu:AddTextBox("Misc", {
    Y = yMisc,
    Text = "100",
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            pcall(function()
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = num
            end)
        end
    end,
})
yMisc = yMisc + 26

menu:AddLabel("Misc", "Jump Power", yMisc)
yMisc = yMisc + 20

menu:AddTextBox("Misc", {
    Y = yMisc,
    Text = "50",
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            pcall(function()
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = num
            end)
        end
    end,
})
yMisc = yMisc + 26

local noclipEnabled = false
local noclipBtn = menu:AddButton("Misc", {
    Y = yMisc,
    Text = "NOCLIP (OFF)",
    Callback = function()
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
    end,
})
yMisc = yMisc + 30

menu.containers["Misc"].CanvasSize = UDim2.new(0, 0, 0, yMisc + 20)

task.spawn(function()
    while true do
        task.wait(0.5)
        if espEnabled then updateESP() end
    end
end)
