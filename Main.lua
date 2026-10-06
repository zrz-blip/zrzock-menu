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
    },
}

local function matchPlace(placeId, universeId)
    for _, entry in ipairs(CATALOG) do
        if entry.Universe and entry.Universe == universeId then
            return entry
        end
    end
    for _, entry in ipairs(CATALOG) do
        for _, id in ipairs(entry.Places) do
            if id == placeId then
                return entry
            end
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

local supported = matchPlace(game.PlaceId, game.GameId)

if supported then
    local ok, err = launch(supported)
    if not ok then
        warn("Zrzocks Hub: " .. tostring(err))
    end
    return
end

local UI_URL = BASE_URL .. "ui/ZrzocksUI.lua"
local ZrzocksUI = loadstring(game:HttpGet(UI_URL), "@ZrzocksUI")()

local menu = ZrzocksUI:CreateMenu({
    Name = "Zrzocks Hub",
    Subtitle = "script loader",
    Icon = "⚡",
    Size = UDim2.fromOffset(600, 450),
    ToggleKey = Enum.KeyCode.LeftControl,
})

menu:Notify({
    Title = "Zrzocks Hub",
    Description = "Игра не поддерживается",
    Duration = 5,
})

for _, entry in ipairs(CATALOG) do
    if entry.Listed then
        menu:AddCard({
            Name = entry.Name,
            Icon = "🎮",
            Description = "Place ID: " .. tostring(entry.Places[1]),
            Tone = entry.Tone,
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
