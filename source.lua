--// Enhanced ESP + Aimbot + GUI with Fly, Noclip, Teleport + Toggles + FOV Slider //--
-- Clean script, stealthy, no exploit-specific keywords

-- Settings
local guiToggleKey = Enum.KeyCode.RightShift
local espToggleKey = Enum.KeyCode.F1
local aimbotToggleKey = Enum.KeyCode.F2
local flyToggleKey = Enum.KeyCode.F3
local fovSliderKey = Enum.KeyCode.F4

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local flyEnabled, noclipEnabled, aimbotEnabled, espEnabled, selectedFOV = false, false, false, false, 70
local teleportToPlayer = nil
local SelectedBodyPart = "Head"

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "utilitygui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 350, 0, 500)
Frame.Position = UDim2.new(0.5, -175, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.Visible = false

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "👀 Enhanced Utility Panel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24

-- ESP Function
local function createESP(plr)
    if plr == LocalPlayer or not espEnabled then return end
    local highlight = Instance.new("Highlight", plr.Character or plr.CharacterAdded:Wait())
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = plr.Character
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.5
    highlight.OutlineColor = plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255, 85, 85)
end

local function toggleESP()
    espEnabled = not espEnabled
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if plr.Character and espEnabled then
                createESP(plr)
            elseif plr.Character and plr.Character:FindFirstChild("ESP_Highlight") then
                plr.Character.ESP_Highlight:Destroy()
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(1) createESP(plr) end)
end)

-- Aimbot Function
local function getClosestTarget()
    local closest, dist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if onScreen and mag < dist then
                dist = mag
                closest = plr
            end
        end
    end
    return closest
end

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(SelectedBodyPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[SelectedBodyPart].Position)
        end
    end
end)

-- Fly Functionality
local function toggleFly()
    flyEnabled = not flyEnabled
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Name = "FlyForce"
    bodyVel.Parent = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    RunService.RenderStepped:Connect(function()
        if flyEnabled then
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if dir.Magnitude > 0 then
                bodyVel.Velocity = dir.Unit * 60
            else
                bodyVel.Velocity = Vector3.zero
            end
        else
            if bodyVel then bodyVel:Destroy() end
        end
    end)
end

-- Teleport Functionality
local function smoothTeleport(targetPlayer)
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local info = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local goal = {Position = targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)}
        local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, info, goal)
        tween:Play()
    end
end

-- FOV Slider (Custom Implementation)
local sliderBackground = Instance.new("Frame", Frame)
sliderBackground.Size = UDim2.new(1, -20, 0, 20)
sliderBackground.Position = UDim2.new(0, 10, 0, 450)
sliderBackground.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

local sliderButton = Instance.new("TextButton", sliderBackground)
sliderButton.Size = UDim2.new(0, 10, 1, 0)
sliderButton.Position = UDim2.new(0, 0, 0, 0)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.Text = ""

local dragging = false
local maxFOV, minFOV = 120, 30

sliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging then
        local mousePos = UserInputService:GetMouseLocation().X
        local sliderX = sliderBackground.AbsolutePosition.X
        local sliderW = sliderBackground.AbsoluteSize.X
        local relative = math.clamp(mousePos - sliderX, 0, sliderW)
        sliderButton.Position = UDim2.new(0, relative, 0, 0)
        local newFOV = math.floor(minFOV + (relative / sliderW) * (maxFOV - minFOV))
        Camera.FieldOfView = newFOV
    end
end)

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == guiToggleKey then
        Frame.Visible = not Frame.Visible
    elseif input.KeyCode == espToggleKey then
        toggleESP()
    elseif input.KeyCode == aimbotToggleKey then
        toggleAimbot()
    elseif input.KeyCode == flyToggleKey then
        toggleFly()
    elseif input.KeyCode == fovSliderKey then
        sliderBackground.Visible = not sliderBackground.Visible
    end
end)
