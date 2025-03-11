--// Variables
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer

local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/thelonious-jaha/Kane-UI-Library/main/source.lua"))()
local Window = getgenv().ProjectLonoWindow or UILib:MakeWindow({ Name = "Project Lono" })
local AutoFarmTab = Window:MakeTab({ Name = "AutoFarm" })
local ModsTab = Window:MakeTab({ Name = "Mods" })

getgenv().NDS = {
    RemoveFallDamage = false,
    NotifyDisaster = false,
}

local fallDamageConnections = {}
local notifyDisasterConnection = nil

--// Functions
local function noFallDamage(character)
    local hrp = character:WaitForChild("HumanoidRootPart")
    if hrp then
        local connection = RunService.Heartbeat:Connect(function()
            if not hrp.Parent then
                connection:Disconnect()
                fallDamageConnections[character] = nil
                return
            end
            local oldVel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            RunService.RenderStepped:Wait()
            hrp.AssemblyLinearVelocity = oldVel
        end)
        fallDamageConnections[character] = connection
    end
end

--// UI Elements
local removeFallToggle = ModsTab:AddToggle({
    Name = "Remove Fall Damage",
    Default = getgenv().NDS.RemoveFallDamage,
    Callback = function(state)
        getgenv().NDS.RemoveFallDamage = state
        if state then
            if LocalPlayer.Character then
                noFallDamage(LocalPlayer.Character)
            end
            LocalPlayer.CharacterAdded:Connect(function(character)
                if getgenv().NDS.RemoveFallDamage then
                    noFallDamage(character)
                end
            end)
        else
            for character, conn in pairs(fallDamageConnections) do
                if conn then
                    conn:Disconnect()
                end
            end
            fallDamageConnections = {}
        end
    end,
})

local notifyDisasterToggle = ModsTab:AddToggle({
    Name = "Notify Disaster",
    Default = getgenv().NDS.NotifyDisaster,
    Callback = function(state)
        getgenv().NDS.NotifyDisaster = state
        print("Notify Disaster Enabled:", state)
        if state then
            if LocalPlayer.Character then
                if notifyDisasterConnection then notifyDisasterConnection:Disconnect() end
                notifyDisasterConnection = LocalPlayer.Character.ChildAdded:Connect(function(child)
                    if child.Name == "SurvivalTag" then
                        UILib:MakeNotification({
                            Title = "Auto Disaster",
                            Text = "Auto Disaster: " .. tostring(child.Value),
                            Duration = 5,
                        })
                    end
                end)
            end
            LocalPlayer.CharacterAdded:Connect(function(character)
                if getgenv().NDS.NotifyDisaster then
                    if notifyDisasterConnection then notifyDisasterConnection:Disconnect() end
                    notifyDisasterConnection = character.ChildAdded:Connect(function(child)
                        if child.Name == "SurvivalTag" then
                            UILib:MakeNotification({
                                Title = "Auto Disaster",
                                Text = "Auto Disaster: " .. tostring(child.Value),
                                Duration = 5,
                            })
                        end
                    end)
                end
            end)
        else
            if notifyDisasterConnection then
                notifyDisasterConnection:Disconnect()
                notifyDisasterConnection = nil
            end
        end
    end,
})

local stealBalloonButton = ModsTab:AddButton({
    Name = "Steal Green Balloon",
    Callback = function()
        local balloon = workspace:FindFirstChild("GreenBalloon", true)
        if balloon then
            local balloonClone = balloon:Clone()
            balloonClone.Parent = LocalPlayer.Backpack
            UILib:MakeNotification({
                Title = "Success",
                Text = "Balloon Successfully Stolen!",
                Icon = "rbxassetid://1234567890",
                Duration = 3,
            })
        else
            UILib:MakeNotification({
                Title = "No Balloon",
                Text = "No one is holding a balloon in the server!",
                Duration = 5,
            })
        end
    end,
})
