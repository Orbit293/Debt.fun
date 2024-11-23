local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurations
local AimlockEnabled = false
local ShakeAmount = 0
local GroundPrediction = 0.132
local AirPrediction = 0.132
local GroundPart = "LowerTorso"
local AirPart = "UpperTorso"
local FOVRadius = 100

-- Variables
local Target = nil
local FOVCircle

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false  -- Keeps GUI on death
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 50)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "OTF"
ToggleButton.TextScaled = true
ToggleButton.Parent = ScreenGui

local uiCorner = Instance.new("UICorner", ToggleButton)
uiCorner.CornerRadius = UDim.new(0, 8)
local uiStroke = Instance.new("UIStroke", ToggleButton)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(0, 0, 0)

-- FOV Circle Setup
FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(0, 0, 0)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = true
FOVCircle.Radius = FOVRadius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Button Dragging Functionality
local dragging = false
local dragStart = nil
local startPos = nil

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Toggle Aimlock
ToggleButton.MouseButton1Click:Connect(function()
    AimlockEnabled = not AimlockEnabled
    Target = nil -- Reset target when toggling
    ToggleButton.Text = AimlockEnabled and "OTF" or "OTF"
    ToggleButton.BackgroundColor3 = AimlockEnabled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(255, 255, 255)
end)

-- Get Closest Target in FOV
local function getClosestTarget()
    local closestPlayer, shortestDistance = nil, FOVRadius
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPosition = character:FindFirstChild("HumanoidRootPart").Position
            local screenPoint = Camera:WorldToViewportPoint(rootPosition)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude

            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    return closestPlayer
end

-- Detect Airborne State
local function isTargetAirborne(target)
    local humanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and not humanoid:GetState().Name:match("Ground")
end

-- Chat Commands
LocalPlayer.Chatted:Connect(function(message)
    local args = message:split(" ")
    if args[1] == "$pred" and tonumber(args[2]) then
        local newPrediction = tonumber(args[2])
        GroundPrediction = newPrediction
        AirPrediction = newPrediction
        print("Prediction set to:", newPrediction)
    elseif args[1] == "$fov" and tonumber(args[2]) then
        local newFOV = tonumber(args[2])
        FOVRadius = newFOV
        FOVCircle.Radius = newFOV
        print("FOV set to:", newFOV)
    end
end)

-- Main Lock-on Logic
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if AimlockEnabled then
        if not Target or (Target and Target.Character and Target.Character:FindFirstChild("Humanoid") and Target.Character.Humanoid.Health <= 0) then
            Target = getClosestTarget()
        end

        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character.Humanoid.Health > 0 then
            local isAirborne = isTargetAirborne(Target)
            local prediction = isAirborne and AirPrediction or GroundPrediction
            local aimPartName = isAirborne and AirPart or GroundPart
            local aimPart = Target.Character:FindFirstChild(aimPartName) or Target.Character:FindFirstChild("HumanoidRootPart")

            if aimPart then
                local targetPos = aimPart.Position
                local targetVelocity = Target.Character.HumanoidRootPart.Velocity
                local predictedPosition = targetPos + (targetVelocity * prediction)

                -- Apply Camera Lock with Shake
                local shakeOffset = Vector3.new(
                    (math.random() * 2 - 1) * ShakeAmount,
                    (math.random() * 2 - 1) * ShakeAmount,
                    (math.random() * 2 - 1) * ShakeAmount
                )

                Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition + shakeOffset)
            end
        else
            Target = nil -- Reset target if KO'd or out of range
        end
    end
end)local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurations
local AimlockEnabled = false
local ShakeAmount = 0
local GroundPrediction = 0.132
local AirPrediction = 0.132
local GroundPart = "LowerTorso"
local AirPart = "UpperTorso"
local FOVRadius = 100

-- Variables
local Target = nil
local FOVCircle

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false  -- Keeps GUI on death
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 50)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "OTF"
ToggleButton.TextScaled = true
ToggleButton.Parent = ScreenGui

local uiCorner = Instance.new("UICorner", ToggleButton)
uiCorner.CornerRadius = UDim.new(0, 8)
local uiStroke = Instance.new("UIStroke", ToggleButton)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(0, 0, 0)

-- FOV Circle Setup
FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(0, 0, 0)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = true
FOVCircle.Radius = FOVRadius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Button Dragging Functionality
local dragging = false
local dragStart = nil
local startPos = nil

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Toggle Aimlock
ToggleButton.MouseButton1Click:Connect(function()
    AimlockEnabled = not AimlockEnabled
    Target = nil -- Reset target when toggling
    ToggleButton.Text = AimlockEnabled and "OTF" or "OTF"
    ToggleButton.BackgroundColor3 = AimlockEnabled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(255, 255, 255)
end)

-- Get Closest Target in FOV
local function getClosestTarget()
    local closestPlayer, shortestDistance = nil, FOVRadius
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPosition = character:FindFirstChild("HumanoidRootPart").Position
            local screenPoint = Camera:WorldToViewportPoint(rootPosition)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude

            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    return closestPlayer
end

-- Detect Airborne State
local function isTargetAirborne(target)
    local humanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and not humanoid:GetState().Name:match("Ground")
end

-- Chat Commands
LocalPlayer.Chatted:Connect(function(message)
    local args = message:split(" ")
    if args[1] == "$pred" and tonumber(args[2]) then
        local newPrediction = tonumber(args[2])
        GroundPrediction = newPrediction
        AirPrediction = newPrediction
        print("Prediction set to:", newPrediction)
    elseif args[1] == "$fov" and tonumber(args[2]) then
        local newFOV = tonumber(args[2])
        FOVRadius = newFOV
        FOVCircle.Radius = newFOV
        print("FOV set to:", newFOV)
    end
end)

-- Main Lock-on Logic
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if AimlockEnabled then
        if not Target or (Target and Target.Character and Target.Character:FindFirstChild("Humanoid") and Target.Character.Humanoid.Health <= 0) then
            Target = getClosestTarget()
        end

        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character.Humanoid.Health > 0 then
            local isAirborne = isTargetAirborne(Target)
            local prediction = isAirborne and AirPrediction or GroundPrediction
            local aimPartName = isAirborne and AirPart or GroundPart
            local aimPart = Target.Character:FindFirstChild(aimPartName) or Target.Character:FindFirstChild("HumanoidRootPart")

            if aimPart then
                local targetPos = aimPart.Position
                local targetVelocity = Target.Character.HumanoidRootPart.Velocity
                local predictedPosition = targetPos + (targetVelocity * prediction)

                -- Apply Camera Lock with Shake
                local shakeOffset = Vector3.new(
                    (math.random() * 2 - 1) * ShakeAmount,
                    (math.random() * 2 - 1) * ShakeAmount,
                    (math.random() * 2 - 1) * ShakeAmount
                )

                Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition + shakeOffset)
            end
        else
            Target = nil -- Reset target if KO'd or out of range
        end
    end
end)
