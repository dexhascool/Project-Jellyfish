--// Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Kane = loadstring(game:HttpGet("https://raw.githubusercontent.com/thelonious-jaha/Kane-UI-Library/main/source.lua"))()
local Window = getgenv().ProjectLonoWindow or UILib:MakeWindow({ Name = "Project Lono" })
local ZombieTab = Window:MakeTab({ Name = "Zombie AutoFarm" })

getgenv().ZombieAttack = {
    EnableAutoFarm = false,
}

--// UI Elements
local autoFarmToggle = ZombieTab:AddToggle({
    Name = "Enable Zombie AutoFarm",
    Default = getgenv().ZombieAttack.EnableAutoFarm,
    Callback = function(state)
        getgenv().ZombieAttack.EnableAutoFarm = state
        print("Zombie AutoFarm Enabled:", state)
    end,
})

--// Functions
local function getNearestZombie()
    local nearestZombie = nil
    local shortestDistance = math.huge
    local playerChar = LocalPlayer.Character
    if not playerChar or not playerChar:FindFirstChild("Head") then
        return nil
    end

    local playerHead = playerChar.Head

    local function checkFolder(folder)
        for _, enemy in pairs(folder:GetChildren()) do
            if enemy:FindFirstChild("Head") and enemy:FindFirstChild("HumanoidRootPart") then
                local dist = (playerHead.Position - enemy.Head.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearestZombie = enemy
                end
            end
        end
    end

    if workspace:FindFirstChild("BossFolder") then
        checkFolder(workspace.BossFolder)
    end

    if workspace:FindFirstChild("enemies") then
        checkFolder(workspace.enemies)
    end

    return nearestZombie
end

local groundOffset = 8

--// Main AutoFarm
spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().ZombieAttack.EnableAutoFarm 
        and LocalPlayer.Character 
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target = getNearestZombie()
            if target 
            and target:FindFirstChild("Head") 
            and target:FindFirstChild("HumanoidRootPart") then
                local cam = workspace.CurrentCamera
                cam.CFrame = CFrame.new(cam.CFrame.Position, target.Head.Position)
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, groundOffset, 9)
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    ReplicatedStorage.Gun:FireServer({
                        Normal = Vector3.new(0, 0, 0),
                        Direction = target.Head.Position,
                        Name = tool.Name,
                        Hit = target.Head,
                        Origin = target.Head.Position,
                        Pos = target.Head.Position,
                    })
                    task.wait()
                end
            end
        end
    end
end)

spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().ZombieAttack.EnableAutoFarm 
        and LocalPlayer.Character 
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            local torso = LocalPlayer.Character:FindFirstChild("Torso") 
                        or LocalPlayer.Character:FindFirstChild("UpperTorso")
            if torso then
                torso.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)
