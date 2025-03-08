local supportedGames = loadstring(game:HttpGet("https://raw.githubusercontent.com/thelonious-jaha/Project-Lono/main/list"))()

local Kane = loadstring(game:HttpGet("https://raw.githubusercontent.com/thelonious-jaha/Kane-UI-Library/main/source.lua"))()
local Window = Kane:MakeWindow({ Name = "Project Lono Loader" })
getgenv().ProjectLonoWindow = Window  -- Store the window globally for use in other scripts
local HomeTab = Window:MakeTab({ Name = "Home" })

--// Functions
local function loadGameScript(gameInfo)
    print("Loading script for", gameInfo.name)
    local response = game:HttpGet(gameInfo.github)
    local loadedScript = loadstring(response)
    if loadedScript then
        loadedScript()
    else
        warn("Failed to load script for", gameInfo.name)
    end
end

--// Loader
local currentPlaceId = game.PlaceId
local gameFound = false

for i, gameInfo in ipairs(supportedGames) do
    if currentPlaceId == gameInfo.placeId then
        gameFound = true
        HomeTab:AddLabel({
            Name = "GameDetected",
            Text = "Supported game detected: " .. gameInfo.name .. ". Loading script...",
            Size = UDim2.new(1, 0, 0, 25),
            TextColor = Color3.fromRGB(0, 255, 0),
            TextSize = 14
        })
        loadGameScript(gameInfo)
        break
    end
end

if not gameFound then
    HomeTab:AddLabel({
        Name = "NoSupportedGame",
        Text = "No supported game detected. Project Lono supports multiple games; please check the GitHub for supported titles.",
        Size = UDim2.new(1, 0, 0, 25),
        TextColor = Color3.fromRGB(255, 0, 0),
        TextSize = 14
    })
end
