--========================================================--
--        NOVA COMBAT SYSTEM - ALL IN ONE
--        Blox Fruits-style combat controller
--        LocalScript
--        StarterPlayer > StarterPlayerScripts
--========================================================--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
	AimLock = false,
	SkillAim = false,
	ESP = false,
	FOV = 120,
	MaxDistance = 500,
	TargetPart = "HumanoidRootPart",
	TargetMode = "Nearest",
	Combo = {
		{action = "M1", delay = 0.10},
		{action = "Z", delay = 0.15},
		{action = "X", delay = 0.20},
		{action = "C", delay = 0.25},
	}
}

local MacroRunning = false
local SelectedTarget = nil

local Gui = Instance.new("ScreenGui")
Gui.Name = "NovaCombat"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = LP:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(340, 455)
Main.Position = UDim2.new(0.5, -170, 0.5, -227)
Main.BackgroundColor3 = Color3.fromRGB(17, 18, 22)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 57, 65)
MainStroke.Thickness = 1
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.fromOffset(17, 0)
Title.BackgroundTransparency = 1
Title.Text = "NOVA  •  COMBAT"
Title.TextColor3 = Color3.fromRGB(245, 245, 248)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(38, 38)
Minimize.Position = UDim2.new(1, -48, 0, 8)
Minimize.BackgroundColor3 = Color3.fromRGB(28, 29, 35)
Minimize.Text = "—"
Minimize.TextColor3 = Color3.fromRGB(220, 220, 225)
Minimize.TextSize = 19
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 10)
MinCorner.Parent = Minimize

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -18, 1, -65)
Content.Position = UDim2.fromOffset(9, 58)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.CanvasSize = UDim2.new()
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

local function label(text, height)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -8, 0, height or 25)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(175, 178, 188)
	l.TextSize = 12
	l.Font = Enum.Font.GothamBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = Content
	return l
end

local function toggle(text, callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -8, 0, 42)
	Button.BackgroundColor3 = Color3.fromRGB(26, 27, 33)
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.Parent = Content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = Button

	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.new(1, -75, 1, 0)
	Text.Position = UDim2.fromOffset(13, 0)
	Text.BackgroundTransparency = 1
	Text.Text = text
	Text.TextColor3 = Color3.fromRGB(230, 231, 236)
	Text.TextSize = 13
	Text.Font = Enum.Font.GothamMedium
	Text.TextXAlignment = Enum.TextXAlignment.Left
	Text.Parent = Button

	local State = Instance.new("TextLabel")
	State.Size = UDim2.fromOffset(45, 25)
	State.Position = UDim2.new(1, -57, 0.5, -12)
	State.BackgroundColor3 = Color3.fromRGB(48, 49, 57)
	State.Text = "OFF"
	State.TextColor3 = Color3.fromRGB(175, 177, 185)
	State.TextSize = 10
	State.Font = Enum.Font.GothamBold
	State.Parent = Button

	local stateCorner = Instance.new("UICorner")
	stateCorner.CornerRadius = UDim.new(1, 0)
	stateCorner.Parent = State

	local enabled = false
	Button.Activated:Connect(function()
		enabled = not enabled
		if enabled then
			State.Text = "ON"
			State.BackgroundColor3 = Color3.fromRGB(70, 125, 235)
			State.TextColor3 = Color3.fromRGB(255,255,255)
		else
			State.Text = "OFF"
			State.BackgroundColor3 = Color3.fromRGB(48,49,57)
			State.TextColor3 = Color3.fromRGB(175,177,185)
		end
		callback(enabled)
	end)
	return Button
end

label("AIM", 25)

toggle("Aim Lock", function(v)
	Config.AimLock = v
end)

toggle("Skill Aim", function(v)
	Config.SkillAim = v
end)

local FOVFrame = Instance.new("Frame")
FOVFrame.Size = UDim2.new(1, -8, 0, 65)
FOVFrame.BackgroundColor3 = Color3.fromRGB(26,27,33)
FOVFrame.BorderSizePixel = 0
FOVFrame.Parent = Content

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(0,10)
FOVCorner.Parent = FOVFrame

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, -25, 0, 25)
FOVLabel.Position = UDim2.fromOffset(13, 5)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV     120°"
FOVLabel.TextColor3 = Color3.fromRGB(225,226,232)
FOVLabel.TextSize = 13
FOVLabel.Font = Enum.Font.GothamMedium
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Parent = FOVFrame

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(1, -28, 0, 7)
Slider.Position = UDim2.fromOffset(14, 44)
Slider.BackgroundColor3 = Color3.fromRGB(48,49,57)
Slider.BorderSizePixel = 0
Slider.Text = ""
Slider.Parent = FOVFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1,0)
SliderCorner.Parent = Slider

local Knob = Instance.new("Frame")
Knob.Size = UDim2.fromOffset(14,14)
Knob.BackgroundColor3 = Color3.fromRGB(85,135,240)
Knob.BorderSizePixel = 0
Knob.Parent = Slider

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1,0)
KnobCorner.Parent = Knob

local function setFOV(x)
	local percent = math.clamp(
		(x - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X,
		0, 1
	)
	Config.FOV = math.floor(30 + percent * 330)
	FOVLabel.Text = "FOV     " .. Config.FOV .. "°"
	Knob.Position = UDim2.new(percent, -7, 0.5, -7)
end

Slider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		setFOV(input.Position.X)
	end
end)

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.Position = UDim2.fromScale(0.5,0.5)
FOVCircle.Size = UDim2.fromOffset(Config.FOV * 2, Config.FOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = Gui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1,0)
CircleCorner.Parent = FOVCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(90,145,255)
CircleStroke.Transparency = 0.45
CircleStroke.Thickness = 1
CircleStroke.Parent = FOVCircle

label("ESP",25)

toggle("Player ESP",function(v)
	Config.ESP = v
end)

local ESPObjects = {}

local function clearESP(player)
	if ESPObjects[player] then
		ESPObjects[player]:Destroy()
		ESPObjects[player] = nil
	end
end

local function setupESP(player)
	if player == LP or ESPObjects[player] then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "NovaESP"
	highlight.FillTransparency = 0.82
	highlight.OutlineTransparency = 0.2
	highlight.FillColor = Color3.fromRGB(75,120,255)
	highlight.OutlineColor = Color3.fromRGB(120,160,255)
	highlight.Parent = workspace
	ESPObjects[player] = highlight

	RunService.RenderStepped:Connect(function()
		if not Config.ESP then
			highlight.Adornee = nil
		elseif player.Character then
			highlight.Adornee = player.Character
		else
			highlight.Adornee = nil
		end
	end)
end

for _,player in ipairs(Players:GetPlayers()) do
	setupESP(player)
end

Players.PlayerAdded:Connect(setupESP)
Players.PlayerRemoving:Connect(clearESP)

local function getTarget()
	local closest = nil
	local closestDistance = math.huge

	local center = Vector2.new(
		Camera.ViewportSize.X / 2,
		Camera.ViewportSize.Y / 2
	)

	for _,player in ipairs(Players:GetPlayers()) do
		if player ~= LP then
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				local root = character:FindFirstChild(Config.TargetPart)

				if humanoid and root and humanoid.Health > 0 then
					local distance = (root.Position - Camera.CFrame.Position).Magnitude

					if distance <= Config.MaxDistance then
						local screen, visible = Camera:WorldToViewportPoint(root.Position)

						if visible then
							local screenDistance = (
								Vector2.new(screen.X, screen.Y) - center
							).Magnitude

							if screenDistance <= Config.FOV
								and screenDistance < closestDistance then
								closestDistance = screenDistance
								closest = root
							end
						end
					end
				end
			end
		end
	end

	return closest
end

RunService.RenderStepped:Connect(function()
	FOVCircle.Size = UDim2.fromOffset(Config.FOV * 2, Config.FOV * 2)
	FOVCircle.Visible = Config.AimLock or Config.SkillAim

	if not Config.AimLock then
		SelectedTarget = nil
		return
	end

	local target = getTarget()
	SelectedTarget = target

	if target then
		Camera.CFrame = CFrame.lookAt(
			Camera.CFrame.Position,
			target.Position
		)
	end
end)

local function getSkillDirection()
	if Config.SkillAim and SelectedTarget then
		return (SelectedTarget.Position - Camera.CFrame.Position).Unit
	end
	return Camera.CFrame.LookVector
end

label("MACRO • COMBO EDITOR",25)

local ComboFrame = Instance.new("Frame")
ComboFrame.Size = UDim2.new(1,-8,0,200)
ComboFrame.BackgroundColor3 = Color3.fromRGB(26,27,33)
ComboFrame.BorderSizePixel = 0
ComboFrame.Parent = Content

local ComboCorner = Instance.new("UICorner")
ComboCorner.CornerRadius = UDim.new(0,10)
ComboCorner.Parent = ComboFrame

local ComboLayout = Instance.new("UIListLayout")
ComboLayout.Padding = UDim.new(0,4)
ComboLayout.Parent = ComboFrame

local ComboPadding = Instance.new("UIPadding")
ComboPadding.PaddingTop = UDim.new(0,8)
ComboPadding.PaddingLeft = UDim.new(0,8)
ComboPadding.PaddingRight = UDim.new(0,8)
ComboPadding.Parent = ComboFrame

local function refreshCombo()
	for _,child in ipairs(ComboFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for index,data in ipairs(Config.Combo) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1,0,0,30)
		button.BackgroundColor3 = Color3.fromRGB(34,35,42)
		button.BorderSizePixel = 0
		button.Text = string.format(
			"%02d   %-5s   %.2fs",
			index, data.action, data.delay
		)
		button.TextColor3 = Color3.fromRGB(220,221,228)
		button.TextSize = 11
		button.Font = Enum.Font.GothamMedium
		button.Parent = ComboFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0,7)
		corner.Parent = button

		button.Activated:Connect(function()
			table.remove(Config.Combo, index)
			refreshCombo()
		end)
	end
end

refreshCombo()

local Actions = {"M1","Z","X","C","V","F","Dash"}
local actionIndex = 1
local currentDelay = 0.15

local AddAction = Instance.new("TextButton")
AddAction.Size = UDim2.new(1,-8,0,40)
AddAction.BackgroundColor3 = Color3.fromRGB(32,33,40)
AddAction.BorderSizePixel = 0
AddAction.Text = "+  ADD M1"
AddAction.TextColor3 = Color3.fromRGB(150,180,255)
AddAction.TextSize = 12
AddAction.Font = Enum.Font.GothamBold
AddAction.Parent = Content

local AddCorner = Instance.new("UICorner")
AddCorner.CornerRadius = UDim.new(0,9)
AddCorner.Parent = AddAction

AddAction.Activated:Connect(function()
	table.insert(Config.Combo, {
		action = Actions[actionIndex],
		delay = currentDelay
	})
	refreshCombo()
end)

local NextAction = Instance.new("TextButton")
NextAction.Size = UDim2.new(1,-8,0,35)
NextAction.BackgroundColor3 = Color3.fromRGB(28,29,35)
NextAction.BorderSizePixel = 0
NextAction.Text = "CHANGE ACTION  •  M1"
NextAction.TextColor3 = Color3.fromRGB(210,212,220)
NextAction.TextSize = 11
NextAction.Font = Enum.Font.GothamMedium
NextAction.Parent = Content

local NextCorner = Instance.new("UICorner")
NextCorner.CornerRadius = UDim.new(0,9)
NextCorner.Parent = NextAction

NextAction.Activated:Connect(function()
	actionIndex += 1

	if actionIndex > #Actions then
		actionIndex = 1
	end

	NextAction.Text = "CHANGE ACTION  •  " .. Actions[actionIndex]
	AddAction.Text = "+  ADD " .. Actions[actionIndex]
end)

local function performAction(action)
	-- Connect these actions to your own game's
	-- server-validated combat system.
	local direction = getSkillDirection()

	if action == "M1" then
		print("M1", direction)
	elseif action == "Z" then
		print("Z", direction)
	elseif action == "X" then
		print("X", direction)
	elseif action == "C" then
		print("C", direction)
	elseif action == "V" then
		print("V", direction)
	elseif action == "F" then
		print("F", direction)
	elseif action == "Dash" then
		print("Dash")
	end
end

local RunCombo = Instance.new("TextButton")
RunCombo.Size = UDim2.new(1,-8,0,43)
RunCombo.BackgroundColor3 = Color3.fromRGB(72,118,230)
RunCombo.BorderSizePixel = 0
RunCombo.Text = "▶  RUN COMBO"
RunCombo.TextColor3 = Color3.fromRGB(255,255,255)
RunCombo.TextSize = 12
RunCombo.Font = Enum.Font.GothamBold
RunCombo.Parent = Content

local RunCorner = Instance.new("UICorner")
RunCorner.CornerRadius = UDim.new(0,10)
RunCorner.Parent = RunCombo

RunCombo.Activated:Connect(function()
	if MacroRunning then
		return
	end

	MacroRunning = true

	task.spawn(function()
		for _,data in ipairs(Config.Combo) do
			if not MacroRunning then
				break
			end

			performAction(data.action)
			task.wait(math.max(data.delay, 0.01))
		end

		MacroRunning = false
	end)
end)

local StopCombo = Instance.new("TextButton")
StopCombo.Size = UDim2.new(1,-8,0,38)
StopCombo.BackgroundColor3 = Color3.fromRGB(32,33,40)
StopCombo.BorderSizePixel = 0
StopCombo.Text = "■  STOP COMBO"
StopCombo.TextColor3 = Color3.fromRGB(220,221,228)
StopCombo.TextSize = 11
StopCombo.Font = Enum.Font.GothamBold
StopCombo.Parent = Content

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0,9)
StopCorner.Parent = StopCombo

StopCombo.Activated:Connect(function()
	MacroRunning = false
end)

local minimized = false

Minimize.Activated:Connect(function()
	minimized = not minimized

	if minimized then
		Content.Visible = false

		TweenService:Create(
			Main,
			TweenInfo.new(0.2),
			{Size = UDim2.fromOffset(340,55)}
		):Play()
	else
		TweenService:Create(
			Main,
			TweenInfo.new(0.2),
			{Size = UDim2.fromOffset(340,455)}
		):Play()

		task.wait(0.2)
		Content.Visible = true
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		Main.Visible = not Main.Visible
	end
end)

print("NOVA Combat System loaded.")
