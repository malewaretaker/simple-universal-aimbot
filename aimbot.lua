-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Camlock Settings
local Camlock = {
    Enabled = true,
    Keybind = Enum.KeyCode.E,
    AimPart = "Head",
}

-- Variables
local target = nil
local aiming = false

-- Utility Functions
local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Camlock.AimPart) then
            local partPosition = player.Character[Camlock.AimPart].Position
            local screenPoint = Camera:WorldToScreenPoint(partPosition)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude
            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end

    return closestPlayer
end

local function camlock()
    while aiming do
        local targetPart = target and target.Character and target.Character:FindFirstChild(Camlock.AimPart)
        if targetPart then
            local targetPos = targetPart.Position
            local camPos = Camera.CFrame.p
            local direction = (targetPos - camPos).unit
            local lookAt = CFrame.new(camPos, camPos + direction)
            Camera.CFrame = lookAt
        else
            aiming = false
        end
        RunService.RenderStepped:Wait()
    end
end

-- Keybind Handling
UserInputService.InputBegan:Connect(function(input, isProcessed)
    if not isProcessed and input.KeyCode == Camlock.Keybind then
        if Camlock.Enabled then
            target = getClosestPlayerToMouse()
            if target then
                aiming = true
                camlock()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Camlock.Keybind then
        aiming = false
    end
end)
