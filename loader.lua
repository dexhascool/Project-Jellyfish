--// Loading Screen Set-up
local LoadingScreen = Instance.new("ScreenGui")
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
LoadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = LoadingScreen
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 125)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 1

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.BorderSizePixel = 0
TitleLabel.Size = UDim2.new(1, 0, 0.3, 0)
TitleLabel.Font = Enum.Font.SourceSans
TitleLabel.Text = "Kū Loader"
TitleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.TextSize = 20
TitleLabel.TextYAlignment = Enum.TextYAlignment.Bottom

local LoadBar = Instance.new("Frame")
LoadBar.Name = "LoadBar"
LoadBar.Parent = MainFrame
LoadBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadBar.Position = UDim2.new(0, 10, 1, -75)
LoadBar.Size = UDim2.new(1, -20, 0.2, 0)

local FillBar = Instance.new("Frame")
FillBar.Name = "FillBar"
FillBar.Parent = LoadBar
FillBar.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
FillBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
FillBar.BorderSizePixel = 0
FillBar.Size = UDim2.new(0, 0, 1, 0)  -- starts empty

local LoadLabel = Instance.new("TextLabel")
LoadLabel.Name = "LoadLabel"
LoadLabel.Parent = MainFrame
LoadLabel.AnchorPoint = Vector2.new(0.5, 0)
LoadLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadLabel.BorderSizePixel = 0
LoadLabel.Position = UDim2.new(0.5, 0, 1, -45)
LoadLabel.Size = UDim2.new(0, 150, 0, 20)
LoadLabel.Font = Enum.Font.SourceSans
LoadLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
LoadLabel.TextSize = 14

local progress = 0
while progress < 1 do
	local increment = math.random() * 0.05
	progress = math.clamp(progress + increment, 0, 1)
	FillBar.Size = UDim2.new(progress, 0, 1, 0)
	LoadLabel.Text = "Loading... " .. math.floor(progress * 100) .. "%"
	wait(math.random(0.3, 0.8))
end

LoadingScreen:Destroy()

--// Loader Set-up
local successSupported, supportedGames = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/thelonious-jaha/Project-Lono/main/supported.lua"))()
end)
if not successSupported then
	supportedGames = {}
	warn("Failed to load supported games list.")
end

local successKane, Kane = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/thelonious-jaha/Kane-UI-Library/main/source.lua"))()
end)
if not successKane then
	error("Failed to load Kane UI Library. Check your URL or internet connection.")
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
