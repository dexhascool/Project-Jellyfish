--// Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UILib = getgenv().ProjectLonoWindow or loadstring(game:HttpGet("https://raw.githubusercontent.com/thelonious-jaha/Kane-UI-Library/main/source.lua"))()
local Window = UILib:MakeWindow({ Name = "Project Lono" })
local AutoFarmTab = Window:MakeTab({ Name = "AutoFarm" })
local ModsTab = Window:MakeTab({ Name = "Mods" })
local RacesTab = Window:MakeTab({ Name = "Races" })

getgenv().LegendsOfSpeed = {
    EnableOrbAutofarm = false,
    EnableHoopAutofarm = false,
    EnableAutoRebirth = false,
    AutoJoinRace = false,
    AutoFinishRace = false,
}

local orbConnection
local hoopConnection
local rebirthConnection

--// AutoFarm
local orbToggle = AutoFarmTab:AddToggle({
    Name = "Enable Orb Autofarm",
    Default = getgenv().LegendsOfSpeed.EnableOrbAutofarm,
    Callback = function(state)
        getgenv().LegendsOfSpeed.EnableOrbAutofarm = state
        print("Orb Autofarm Enabled:", state)
        if state then
            orbConnection = RunService.RenderStepped:Connect(function()
                if getgenv().LegendsOfSpeed.EnableOrbAutofarm then
                    ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb", "Orange Orb", "City")
                    ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
                    ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb", "Red Orb", "City")
                    ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb", "Blue Orb", "City")
                end
            end)
        else
            if orbConnection then
                orbConnection:Disconnect()
                orbConnection = nil
            end
        end
    end,
})

local hoopToggle = AutoFarmTab:AddToggle({
    Name = "Enable Hoop Autofarm",
    Default = getgenv().LegendsOfSpeed.EnableHoopAutofarm,
    Callback = function(state)
        getgenv().LegendsOfSpeed.EnableHoopAutofarm = state
        print("Hoop Autofarm Enabled:", state)
        if state then
            hoopConnection = RunService.RenderStepped:Connect(function()
                if getgenv().LegendsOfSpeed.EnableHoopAutofarm 
                and LocalPlayer.Character 
                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, hoop in ipairs(workspace.Hoops:GetChildren()) do
                        if hoop:IsA("BasePart") then
                            firetouchinterest(hoop, LocalPlayer.Character.HumanoidRootPart, 0)
                            firetouchinterest(hoop, LocalPlayer.Character.HumanoidRootPart, 1)
                        end
                    end
                end
            end)
        else
            if hoopConnection then
                hoopConnection:Disconnect()
                hoopConnection = nil
            end
        end
    end,
})

local rebirthToggle = AutoFarmTab:AddToggle({
    Name = "Enable Auto Rebirth",
    Default = getgenv().LegendsOfSpeed.EnableAutoRebirth,
    Callback = function(state)
        getgenv().LegendsOfSpeed.EnableAutoRebirth = state
        print("Auto Rebirth Enabled:", state)
        if state then
            delay(2, function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local gameGui = playerGui:WaitForChild("gameGui")
                local statsFrame = gameGui:WaitForChild("statsFrame")
                local currentLevelLabel = statsFrame:WaitForChild("levelLabel")
                if currentLevelLabel then
                    print("Current level label found:", currentLevelLabel.Name)
                    rebirthConnection = currentLevelLabel:GetPropertyChangedSignal("Text"):Connect(function()
                        ReplicatedStorage.rEvents.rebirthEvent:FireServer("rebirthRequest")
                    end)
                else
                    warn("levelLabel not found.")
                end
            end)
        else
            if rebirthConnection then
                rebirthConnection:Disconnect()
                rebirthConnection = nil
            end
        end
    end,
})

local autoJoinRaceToggle = RacesTab:AddToggle({
    Name = "Auto Join Race",
    Default = false,
    Callback = function(state)
        getgenv().LegendsOfSpeed.AutoJoinRace = state
        print("Auto Join Race Enabled:", state)
    end,
})

local autoFinishRaceToggle = RacesTab:AddToggle({
    Name = "Auto Finish Race",
    Default = false,
    Callback = function(state)
        getgenv().LegendsOfSpeed.AutoFinishRace = state
        print("Auto Finish Race Enabled:", state)
    end,
})

ReplicatedStorage.raceInProgress.Changed:Connect(function()
    if getgenv().LegendsOfSpeed.AutoJoinRace and ReplicatedStorage.raceInProgress.Value then
        ReplicatedStorage.rEvents.raceEvent:FireServer("joinRace")
    end
end)

ReplicatedStorage.raceStarted.Changed:Connect(function()
    if getgenv().LegendsOfSpeed.AutoFinishRace and ReplicatedStorage.raceStarted.Value then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, map in ipairs(workspace.raceMaps:GetChildren()) do
                if map:FindFirstChild("finishPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local oldFinishPos = map.finishPart.CFrame
                    map.finishPart.CFrame = hrp.CFrame
                    task.wait()
                    map.finishPart.CFrame = oldFinishPos
                end
            end
        end
    end
end)
