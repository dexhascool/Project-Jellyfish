--// Variables
local successSupported, supportedGames = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/thelonious-jaha/Project-Lono/main/games-list"))()
end)
if not successSupported then
	supportedGames = {}
	warn("Failed to load supported games list.")
end

local successKane, Kane = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/thelonious-jaha/Kane-UI-Library/main/source.lua"))()
end)
if not successKane then
	error("Failed to load Kane UI Library.")
end

local Window = Kane:MakeWindow({ Name = "Project Lono" })
getgenv().ProjectLonoWindow = Window
local HomeTab = Window:MakeTab({ Name = "Home" })

--// Functions
local function loadGameScript(gameInfo)
	print("Loading script for", gameInfo.name)
	local successHttp, response = pcall(function()
		return game:HttpGet(gameInfo.github)
	end)
	if not successHttp then
		warn("Failed to fetch script for", gameInfo.name)
		HomeTab:AddLabel({
			Name = "FetchError",
			Text = "Error: Failed to fetch script for " .. gameInfo.name,
			Size = UDim2.new(1, 0, 0, 25),
			TextColor = Color3.fromRGB(255, 0, 0),
			TextSize = 14
		})
		return
	end
    
	local loadedScript, compileError = loadstring(response)
	if not loadedScript then
		warn("Failed to compile script for", gameInfo.name, compileError)
		HomeTab:AddLabel({
			Name = "CompileError",
			Text = "Error: Failed to compile script for " .. gameInfo.name,
			Size = UDim2.new(1, 0, 0, 25),
			TextColor = Color3.fromRGB(255, 0, 0),
			TextSize = 14
		})
		return
	end
    
	local successRun, runError = pcall(loadedScript)
	if not successRun then
		warn("Error running script for", gameInfo.name, runError)
		HomeTab:AddLabel({
			Name = "RunError",
			Text = "Error: Running script for " .. gameInfo.name,
			Size = UDim2.new(1, 0, 0, 25),
			TextColor = Color3.fromRGB(255, 0, 0),
			TextSize = 14
		})
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
			Text = "Current Game: " .. gameInfo.name,
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
		Text = "Current Game: Not Detected",
		Size = UDim2.new(1, 0, 0, 25),
		TextColor = Color3.fromRGB(255, 0, 0),
		TextSize = 14
	})
end
