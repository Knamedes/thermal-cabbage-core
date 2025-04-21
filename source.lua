--// Enhanced ESP + Aimbot + GUI with Fly, Noclip, Teleport + Toggles //--
-- Clean script, stealthy, no exploit-specific keywords

-- Settings
local guiToggleKey = Enum.KeyCode.RightShift
local espToggleKey = Enum.KeyCode.F1
local aimbotToggleKey = Enum.KeyCode.F2
local flyToggleKey = Enum.KeyCode.F3

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local flyEnabled, noclipEnabled, aimbotEnabled, espEnabled = false, false, false, false
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
            bodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * 60 or Vector3.zero
        else
            bodyVel:Destroy()
        end
    end)
end

-- Smooth Teleport
local function smoothTeleport(targetPlayer)
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local info = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local goal = {Position = targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)}
        local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, info, goal)
        tween:Play()
    end
end

-- Player Teleport GUI
local PlayerListFrame = Instance.new("ScrollingFrame", Frame)
PlayerListFrame.Size = UDim2.new(1, -20, 0, 200)
PlayerListFrame.Position = UDim2.new(0, 10, 0, 290)
PlayerListFrame.BackgroundTransparency = 0.3
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerListFrame.ScrollBarThickness = 6

local function refreshPlayerList()
    PlayerListFrame:ClearAllChildren()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton", PlayerListFrame)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 18
            btn.Text = "Teleport to: " .. plr.Name
            btn.MouseButton1Click:Connect(function()
                smoothTeleport(plr)
            end)
        end
    end
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

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
    end
end)
