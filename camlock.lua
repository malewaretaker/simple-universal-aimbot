local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
-- rewritten slightly
getgenv().CamlockSettings = {
    ["IntroSettings"] = {
        ["Intro"] = ,
        ["IntroID"] = "" 
    }, -- no id made yet 

    ["Combat"] = {
        ["Enabled"] = true,
        ["Keybind"] = "E",
        ["AimPart"] = "Head",
        ["Prediction"] = 0.1,
        ["FOV"] = 250,
        ["MaxDistance"] = 1000
    },

    ["Smoothness"] = {
        ["Amount"] = 0.2,
    }
}

local target = nil
local aiming = false

local function playIntro()
    if getgenv().CamlockSettings.IntroSettings.Intro then
        local introGui = Instance.new("ScreenGui")
        introGui.Name = "IntroGui"
        introGui.Parent = game:GetService("CoreGui")
        
        local introImage = Instance.new("ImageLabel")
        introImage.Size = UDim2.new(0, 300, 0, 300)
        introImage.Position = UDim2.new(0.5, -150, 0.5, -150)
        introImage.AnchorPoint = Vector2.new(0.5, 0.5)
        introImage.Image = getgenv().CamlockSettings.IntroSettings.IntroID
        introImage.BackgroundTransparency = 1
        introImage.Parent = introGui
        
        local fadeIn = TweenService:Create(introImage, TweenInfo.new(1), {ImageTransparency = 0})
        local fadeOut = TweenService:Create(introImage, TweenInfo.new(1), {ImageTransparency = 1})
        
        fadeIn:Play()
        fadeIn.Completed:Wait()
        wait(1.5)
        fadeOut:Play()
        fadeOut.Completed:Wait()
        
        introGui:Destroy()
    end
end

playIntro()

local function isWithinFOV(position)
    local screenPoint = Camera:WorldToScreenPoint(position)
    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
    return distance <= getgenv().CamlockSettings.Combat.FOV
end

local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local aimPart = player.Character:FindFirstChild(getgenv().CamlockSettings.Combat.AimPart)
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

            if aimPart and humanoidRootPart then
                local distanceToPlayer = (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distanceToPlayer <= getgenv().CamlockSettings.Combat.MaxDistance and isWithinFOV(aimPart.Position) then
                    local screenPoint = Camera:WorldToScreenPoint(aimPart.Position)
                    local cursorDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if cursorDistance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = cursorDistance
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function camlock()
    while aiming and target and target.Character and target.Character:FindFirstChild(getgenv().CamlockSettings.Combat.AimPart) do
        local targetPart = target.Character[getgenv().CamlockSettings.Combat.AimPart]
        local targetPos = targetPart.Position + (targetPart.Velocity * getgenv().CamlockSettings.Combat.Prediction)
        local currentPos = Camera.CFrame.Position
        local direction = (targetPos - currentPos).Unit
        local smoothDirection = currentPos:Lerp(targetPos, getgenv().CamlockSettings.Smoothness.Amount)
        Camera.CFrame = CFrame.new(currentPos, smoothDirection)
        
        RunService.RenderStepped:Wait()
    end
    aiming = false
end

UserInputService.InputBegan:Connect(function(input, isProcessed)
    if not isProcessed and input.KeyCode == Enum.KeyCode[getgenv().CamlockSettings.Combat.Keybind:upper()] and getgenv().CamlockSettings.Combat.Enabled then
        target = getClosestPlayerToMouse()
        if target then
            aiming = true
            camlock()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[getgenv().CamlockSettings.Combat.Keybind:upper()] then
        aiming = false
    end
end)
