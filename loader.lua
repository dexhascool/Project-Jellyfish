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
getgenv().ProjectLono = getgenv().ProjectLono or {}

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

--// Other Tabs
local HumanoidTab = Window:MakeTab({ Name = "Humanoid" })
local MiscTab = Window:MakeTab({ Name = "Misc" })


local superhumanToggle = HumanoidTab:AddToggle({
    Name = "Superhuman",
    Default = false,
    Callback = function(state)
        getgenv().ProjectLono.Superhuman = state
        print("Superhuman Enabled:", state)
        if not state then
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                    humanoid.JumpPower = 50
                end
            end
        end
    end,
})

HumanoidTab:AddSlider({
    Name = "WalkSpeed",
    Min = 0,
    Max = 100,
    Default = 16,
    Increment = 1,
    ValueName = " WS",
    Callback = function(value)
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if getgenv().ProjectLono.Superhuman then
                    humanoid.WalkSpeed = value
                else
                    humanoid.WalkSpeed = 16
                end
            end
        end
    end,
})

HumanoidTab:AddSlider({
    Name = "Jump Power",
    Min = 0,
    Max = 200,
    Default = 50,
    Increment = 1,
    ValueName = " JP",
    Callback = function(value)
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if getgenv().ProjectLono.Superhuman then
                    humanoid.JumpPower = value
                else
                    humanoid.JumpPower = 50
                end
            end
        end
    end,
})

local function enableAntiAFK()
    local GC = getconnections or get_signal_cons
    if GC then
        for _, conn in pairs(GC(LocalPlayer.Idled)) do
            if conn.Disable then
                conn:Disable()
            elseif conn.Disconnect then
                conn:Disconnect()
            end
        end
    else
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

MiscTab:AddToggle({
    Name = "Anti-AFK",
    Default = false,
    Callback = function(state)
        if state then
            enableAntiAFK()
            print("Anti-AFK Enabled")
        else
            print("Anti-AFK Disabled")
            --[[
                Note: Re-enabling idling connections isn't as straightforward as flipping a switch back on.
                Eventually I might make it manually recreate the connections that detect idleness, but right now, disabling the Anti-AFK toggle doesn't do anything.
            ]]
        end
    end,
})

local antiFlingConnection = nil
MiscTab:AddToggle({
    Name = "Anti-Fling",
    Default = false,
    Callback = function(state)
        if state then
            if antiFlingConnection then antiFlingConnection:Disconnect() end
            antiFlingConnection = RunService.Stepped:Connect(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
            print("Anti-Fling Enabled")
        else
            if antiFlingConnection then
                antiFlingConnection:Disconnect()
                antiFlingConnection = nil
            end
            print("Anti-Fling Disabled")
        end
    end,
})
