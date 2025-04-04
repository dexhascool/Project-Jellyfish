--// Variables
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dexhascool/Squid-UI-Library/main/source.lua"))()
local Window = getgenv().ProjectJellyfishWindow or UILib:MakeWindow({ Name = "Project Jellyfish" })
getgenv().ProjectJellyfishWindow = Window
local SettingsTab = Window:MakeTab({ Name = "Treasure AutoFarm" })

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

getgenv().TreasureAutoFarm = {
    Enabled = false,        -- Toggle the auto farm on/off
    Teleport = 3.40,        -- Delay between each teleport in a run (TP Cooldown)
    TimeBetweenRuns = 6     -- Cooldown between runs (Run Cooldown)
}

--// UI Elements
SettingsTab:AddLabel({
    Name = "Note",
    Text = "Note: Disabling the auto farm will wait until the current run is finished.",
    Size = UDim2.new(1, 0, 0, 25),
    TextColor = Color3.fromRGB(255, 0, 0),
    TextSize = 14
})

local section = SettingsTab:MakeSection({Name = "Gold AutoFarm"})

section:AddSlider({
    Name = "TP Cooldown",
    Min = 0.5,
    Max = 10,
    Default = getgenv().TreasureAutoFarm.Teleport,
    Increment = 0.1,
    ValueName = " seconds",
    Callback = function(value)
        getgenv().TreasureAutoFarm.Teleport = value
        print("TP Cooldown set to:", value)
    end
})

section:AddSlider({
    Name = "Run Cooldown",
    Min = 1,
    Max = 10,
    Default = getgenv().TreasureAutoFarm.TimeBetweenRuns,
    Increment = 0.5,
    ValueName = " seconds",
    Callback = function(value)
        getgenv().TreasureAutoFarm.TimeBetweenRuns = value
        print("Run Cooldown set to:", value)
    end
})

section:AddToggle({
    Name = "Enable AutoFarm",
    Default = getgenv().TreasureAutoFarm.Enabled,
    Callback = function(state)
        getgenv().TreasureAutoFarm.Enabled = state
        print("AutoFarm Enabled:", state)
    end
})

--// AutoFarm
local function autoFarm(currentRun)
    local Character = LocalPlayer.Character
    local NormalStages = Workspace.BoatStages.NormalStages

    for i = 1, 10 do
        local Stage = NormalStages["CaveStage" .. i]
        local DarknessPart = Stage:FindFirstChild("DarknessPart")
        if DarknessPart then
            print("Teleporting to stage " .. i)
            Character.HumanoidRootPart.CFrame = DarknessPart.CFrame
            local tempPart = Instance.new("Part", Character)
            tempPart.Anchored = true
            tempPart.Position = Character.HumanoidRootPart.Position - Vector3.new(0, 6, 0)
            wait(getgenv().TreasureAutoFarm.Teleport)
            tempPart:Destroy()
        end
    end

    print("Teleporting to the end")
    repeat wait() 
        Character.HumanoidRootPart.CFrame = NormalStages.TheEnd.GoldenChest.Trigger.CFrame
    until Lighting.ClockTime ~= 35

    local Respawned = false
    local Connection = LocalPlayer.CharacterAdded:Connect(function()
        Respawned = true
        Connection:Disconnect()
    end)
    repeat wait() until Respawned
    wait(getgenv().TreasureAutoFarm.TimeBetweenRuns)
    print("AutoFarm Run " .. currentRun .. " finished")
end

spawn(function()
    local autoFarmRun = 1
    while wait() do
        if getgenv().TreasureAutoFarm.Enabled then
            print("Starting AutoFarm Run " .. autoFarmRun)
            autoFarm(autoFarmRun)
            autoFarmRun = autoFarmRun + 1
        end
    end
end)
