local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local CONFIG = {
	offset = CFrame.new(0, -0.35, -0.25),
	moveTime = 0.25,
	waitTime = 2
}

local function getHand(char)
	return char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
end

local function createUI()
	local gui = Instance.new("ScreenGui")
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(75, 75)
	button.Position = UDim2.new(0, 10, 0, 100)
	button.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	button.Text = ""
	button.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button

	return button
end

-- 💨 fumée (LOCAL seulement)
local function smokeMouth(head)
	local att = Instance.new("Attachment")
	att.Position = Vector3.new(0, -0.15, -0.2)
	att.Parent = head

	local smoke = Instance.new("ParticleEmitter")
	smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
	smoke.Rate = 180
	smoke.Lifetime = NumberRange.new(1.2, 2.5)
	smoke.Speed = NumberRange.new(3, 6)
	smoke.Parent = att

	task.delay(2.5, function()
		smoke.Enabled = false
		task.wait(1)
		att:Destroy()
	end)
end

-- 🚬 puff
local function createVape()
	local model = Instance.new("Model")

	local body = Instance.new("Part")
	body.Size = Vector3.new(0.5, 1.3, 0.4)
	body.Material = Enum.Material.SmoothPlastic
	body.Color = Color3.fromRGB(120, 0, 0)
	body.CanCollide = false
	body.Massless = true
	body.Parent = model

	local tip = Instance.new("Part")
	tip.Size = Vector3.new(0.35, 0.3, 0.35)
	tip.Material = Enum.Material.Glass
	tip.Transparency = 0.3
	tip.Color = Color3.fromRGB(255, 100, 100)
	tip.CanCollide = false
	tip.Massless = true
	tip.Parent = model

	tip.CFrame = body.CFrame * CFrame.new(0, 0.8, 0)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = body
	weld.Part1 = tip
	weld.Parent = body

	model.PrimaryPart = body
	return model
end

local function setup(char)
	local hand = getHand(char)
	local head = char:WaitForChild("Head")
	local root = char:WaitForChild("HumanoidRootPart")

	if not hand then return end

	local vape = createVape()
	vape.Parent = char

	local main = vape.PrimaryPart
	main.CFrame = hand.CFrame * CONFIG.offset

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hand
	weld.Part1 = main
	weld.Parent = main

	local button = createUI()

	local busy = false

	button.MouseButton1Click:Connect(function()
		if busy then return end
		busy = true

		button.BackgroundColor3 = Color3.fromRGB(0,170,255)

		root.Anchored = true

		local startCF = hand.CFrame * CONFIG.offset

		local gyro = Instance.new("BodyGyro")
		gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
		gyro.P = 5000
		gyro.CFrame = hand.CFrame
		gyro.Parent = hand

		-- ❌ BUG FIX 1 : weld désactivé correctement
		weld.Enabled = false
		main.Anchored = true

		local target = head.CFrame
			* CFrame.new(0, -0.1, -0.3)
			* CFrame.Angles(math.rad(-25), 0, 0)

		gyro.CFrame = CFrame.new(hand.Position, head.Position)

		local go = TweenService:Create(main, TweenInfo.new(CONFIG.moveTime), {
			CFrame = target
		})

		go:Play()
		go.Completed:Wait()

		task.wait(CONFIG.waitTime)

		smokeMouth(head)

		local back = TweenService:Create(main, TweenInfo.new(CONFIG.moveTime), {
			CFrame = startCF
		})

		back:Play()
		back.Completed:Wait()

		-- ❌ BUG FIX 2 : ordre propre reset
		gyro:Destroy()

		weld.Enabled = true
		main.Anchored = false

		root.Anchored = false

		button.BackgroundColor3 = Color3.fromRGB(255,60,60)
		busy = false
	end)
end

if player.Character then
	setup(player.Character)
end

player.CharacterAdded:Connect(function(char)
	task.wait(1)
	setup(char)
end)
