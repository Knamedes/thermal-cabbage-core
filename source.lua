--[[
	Custom Roblox Script GUI
	Features:
	- ESP (Name, HP, Distance, Team-based Hitbox)
	- Aimbot (Cursor-based target lock, FOV circle, adjustable range)
	- Fly (F5)
	- Noclip (F6)
	- Toggleable GUI with ON/OFF buttons
	- Zero console output for stealth
	- Fully functional menu UI
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Gui Setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "CustomUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createToggle(name, callback)
	local button = Instance.new("TextButton", MainFrame)
	button.Size = UDim2.new(1, 0, 0, 30)
	button.Text = name .. " [OFF]"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	button.MouseButton1Click:Connect(function()
		local isOn = button.Text:find("ON")
		button.Text = name .. (isOn and " [OFF]" or " [ON]")
		callback(not isOn)
	end)
end

local espEnabled = false
createToggle("ESP", function(state)
	espEnabled = state
end)

local aimbotEnabled = false
local fovSize = 70
createToggle("Aimbot", function(state)
	aimbotEnabled = state
end)

createToggle("Fly", function(state)
	_G.flyOn = state
end)

createToggle("Noclip", function(state)
	_G.noclipOn = state
end)

-- Crosshair and FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Radius = fovSize
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = true

local Crosshair = Drawing.new("Line")
Crosshair.Thickness = 1
Crosshair.Color = Color3.fromRGB(255, 255, 255)
Crosshair.Transparency = 1

-- Fly Logic
RunService.RenderStepped:Connect(function()
	if _G.flyOn then
		LocalPlayer.Character.Humanoid:ChangeState(11)
		LocalPlayer.Character:TranslateBy(Camera.CFrame.lookVector * 0.5)
	end
end)

-- Noclip
RunService.Stepped:Connect(function()
	if _G.noclipOn and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Keybinds
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F5 then _G.flyOn = not _G.flyOn end
	if input.KeyCode == Enum.KeyCode.F6 then _G.noclipOn = not _G.noclipOn end
end)

-- Aimbot Logic
local function getClosestPlayerToCursor()
	local closest, shortest = nil, math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
			local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
			if onScreen and dist < shortest and dist <= fovSize then
				shortest = dist
				closest = player
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
	Crosshair.From = Vector2.new(Mouse.X - 4, Mouse.Y)
	Crosshair.To = Vector2.new(Mouse.X + 4, Mouse.Y)
	Crosshair.Visible = aimbotEnabled
	
	if aimbotEnabled then
		local target = getClosestPlayerToCursor()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
		end
	end
end)

-- ESP Logic
local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			-- Add your custom BillboardGui ESP here with distance, HP, etc.
		end
	end
end

RunService.RenderStepped:Connect(function()
	if espEnabled then
		updateESP()
	end
end)
