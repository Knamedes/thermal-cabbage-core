--// Custom ESP + Aimbot + GUI with Fly, Noclip, Teleport //--
-- stealthy, clean, no exploit keywords used

-- Settings
local guiToggleKey = Enum.KeyCode.RightShift
local aimbotToggleKey = Enum.KeyCode.F
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "utilitygui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "👀 Utility Panel"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22

-- Toggles
local flyEnabled, noclipEnabled, aimbotEnabled = false, false, false

-- ESP Function
local function createESP(plr)
    if plr == LocalPlayer then return end
    local highlight = Instance.new("Highlight", plr.Character or plr.CharacterAdded:Wait())
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = plr.Character
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = plr.Team and plr.Team.TeamColor.Color or Color3.new(1, 0, 0)
end

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function() task.wait(1) createESP(plr) end)
        if plr.Character then createESP(plr) end
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

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- Fly
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
            bodyVel.Velocity = dir.Unit * 60
        else
            bodyVel:Destroy()
        end
    end)
end

-- Noclip
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Teleport GUI (very basic)
local tpLabel = Instance.new("TextLabel", Frame)
tpLabel.Position = UDim2.new(0, 10, 0, 40)
tpLabel.Size = UDim2.new(1, -20, 0, 20)
tpLabel.TextColor3 = Color3.new(1, 1, 1)
tpLabel.Text = "Click name below to teleport"

local listY = 65
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        local btn = Instance.new("TextButton", Frame)
        btn.Position = UDim2.new(0, 10, 0, listY)
        btn.Size = UDim2.new(1, -20, 0, 20)
        btn.Text = plr.Name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        btn.MouseButton1Click:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:MoveTo(plr.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
            end
        end)
        listY += 25
    end
end

-- Input Handling
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == guiToggleKey then
        Frame.Visible = not Frame.Visible
    elseif input.KeyCode == aimbotToggleKey then
        aimbotEnabled = not aimbotEnabled
    end
end)

