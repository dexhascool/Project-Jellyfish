getgenv().ProjectJellyfish = getgenv().ProjectJellyfish or {}

local supportedGames = loadstring(game:HttpGet("https://raw.githubusercontent.com/dexhascool/Project-Jellyfish/main/supported.lua"))()
local Squid = loadstring(game:HttpGet("https://raw.githubusercontent.com/dexhascool/Squid-UI-Library/main/source.lua"))()
getgenv().ProjectJellyfishWindow = Squid:MakeWindow({ Name = "Project Jellyfish" })
local homeTab = getgenv().ProjectJellyfishWindow:MakeTab({ Name = "Home" })

local function loadGameScript(gameInfo)
    print("Loading script for " .. gameInfo.name)
    local scriptCode = game:HttpGet(gameInfo.github)
    loadstring(scriptCode)()
end

local currentPlaceId = game.PlaceId
local gameFound = false

for _, gameInfo in ipairs(supportedGames) do
    if currentPlaceId == gameInfo.placeId then
        gameFound = true
        print("Current Game: " .. gameInfo.name)
        homeTab:AddLabel({
            Name = "GameDetected",
            Text = "Current Game: " .. gameInfo.name,
        })
        loadGameScript(gameInfo)
        break
    end
end

if not gameFound then
    homeTab:AddLabel({
        Name = "NoSupportedGame",
        Text = "Current Game: Not Detected",
    })
end
