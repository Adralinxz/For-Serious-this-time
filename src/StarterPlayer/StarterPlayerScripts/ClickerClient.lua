-- ClickerClient.lua
-- Client-side script for handling UI and player interactions

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- Local player
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- UI references
local screenGui = nil
local mainFrame = nil
local upgradeFrame = nil
local prestigeFrame = nil

-- Remote Events
local ClickEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClickEvent")
local PurchaseUpgradeEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PurchaseUpgradeEvent")
local PrestigeEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PrestigeEvent")

-- UI Creation
local function createUI()
	-- Create ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ClickerGui"
	screenGui.Parent = player:WaitForChild("PlayerGui")

	-- Main Click Frame
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 300, 0, 400)
	mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
	mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	mainFrame.BorderSizePixel = 2
	mainFrame.Parent = screenGui

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 24
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Text = "Clicker Game"
	titleLabel.Parent = mainFrame

	-- Coin Display
	local coinLabel = Instance.new("TextLabel")
	coinLabel.Name = "CoinLabel"
	coinLabel.Size = UDim2.new(1, 0, 0, 40)
	coinLabel.Position = UDim2.new(0, 0, 0, 50)
	coinLabel.BackgroundTransparency = 1
	coinLabel.Font = Enum.Font.SourceSansBold
	coinLabel.TextSize = 20
	coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	coinLabel.Text = "Coins: 0"
	coinLabel.Parent = mainFrame

	-- Click Power Display
	local clickPowerLabel = Instance.new("TextLabel")
	clickPowerLabel.Name = "ClickPowerLabel"
	clickPowerLabel.Size = UDim2.new(1, 0, 0, 30)
	clickPowerLabel.Position = UDim2.new(0, 0, 0, 90)
	clickPowerLabel.BackgroundTransparency = 1
	clickPowerLabel.Font = Enum.Font.SourceSans
	clickPowerLabel.TextSize = 16
	clickPowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	clickPowerLabel.Text = "Click Power: 1"
	clickPowerLabel.Parent = mainFrame

	-- Passive Income Display
	local passiveIncomeLabel = Instance.new("TextLabel")
	passiveIncomeLabel.Name = "PassiveIncomeLabel"
	passiveIncomeLabel.Size = UDim2.new(1, 0, 0, 30)
	passiveIncomeLabel.Position = UDim2.new(0, 0, 0, 120)
	passiveIncomeLabel.BackgroundTransparency = 1
	passiveIncomeLabel.Font = Enum.Font.SourceSans
	passiveIncomeLabel.TextSize = 16
	passiveIncomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	passiveIncomeLabel.Text = "Passive Income: 0/sec"
	passiveIncomeLabel.Parent = mainFrame

	-- Main Click Button
	local clickButton = Instance.new("TextButton")
	clickButton.Name = "ClickButton"
	clickButton.Size = UDim2.new(0.8, 0, 0.3, 0)
	clickButton.Position = UDim2.new(0.1, 0, 0.35, 0)
	clickButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	clickButton.Font = Enum.Font.SourceSansBold
	clickButton.TextSize = 24
	clickButton.Text = "CLICK ME!"
	clickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	clickButton.Parent = mainFrame

	-- Upgrade Button
	local upgradeButton = Instance.new("TextButton")
	upgradeButton.Name = "UpgradeButton"
	upgradeButton.Size = UDim2.new(0.8, 0, 0.1, 0)
	upgradeButton.Position = UDim2.new(0.1, 0, 0.7, 0)
	upgradeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	upgradeButton.Font = Enum.Font.SourceSans
	upgradeButton.TextSize = 18
	upgradeButton.Text = "Upgrades"
	upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	upgradeButton.Parent = mainFrame

	-- Prestige Button
	local prestigeButton = Instance.new("TextButton")
	prestigeButton.Name = "PrestigeButton"
	prestigeButton.Size = UDim2.new(0.8, 0, 0.1, 0)
	prestigeButton.Position = UDim2.new(0.1, 0, 0.82, 0)
	prestigeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
	prestigeButton.Font = Enum.Font.SourceSans
	prestigeButton.TextSize = 18
	prestigeButton.Text = "Prestige"
	prestigeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	prestigeButton.Parent = mainFrame

	-- Upgrade Frame
	upgradeFrame = Instance.new("Frame")
	upgradeFrame.Name = "UpgradeFrame"
	upgradeFrame.Size = UDim2.new(0, 300, 0, 400)
	upgradeFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
	upgradeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	upgradeFrame.BorderSizePixel = 2
	upgradeFrame.Visible = false
	upgradeFrame.Parent = screenGui

	-- Upgrade Title
	local upgradeTitle = Instance.new("TextLabel")
	upgradeTitle.Name = "UpgradeTitle"
	upgradeTitle.Size = UDim2.new(1, 0, 0, 50)
	upgradeTitle.Position = UDim2.new(0, 0, 0, 0)
	upgradeTitle.BackgroundTransparency = 1
	upgradeTitle.Font = Enum.Font.SourceSansBold
	upgradeTitle.TextSize = 24
	upgradeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	upgradeTitle.Text = "Upgrades"
	upgradeTitle.Parent = upgradeFrame

	-- Close Button for Upgrade Frame
	local closeUpgradeBtn = Instance.new("TextButton")
	closeUpgradeBtn.Name = "CloseUpgradeButton"
	closeUpgradeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeUpgradeBtn.Position = UDim2.new(1, -35, 0, 5)
	closeUpgradeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeUpgradeBtn.Font = Enum.Font.SourceSansBold
	closeUpgradeBtn.TextSize = 18
	closeUpgradeBtn.Text = "X"
	closeUpgradeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeUpgradeBtn.Parent = upgradeFrame

	-- Upgrade Buttons (will be populated dynamically)
	local upgradeContainer = Instance.new("Frame")
	upgradeContainer.Name = "UpgradeContainer"
	upgradeContainer.Size = UDim2.new(0.9, 0, 0.7, 0)
	upgradeContainer.Position = UDim2.new(0.05, 0, 0.2, 0)
	upgradeContainer.BackgroundTransparency = 1
	upgradeContainer.Parent = upgradeFrame

	-- Prestige Frame (similar structure)
	prestigeFrame = Instance.new("Frame")
	prestigeFrame.Name = "PrestigeFrame"
	prestigeFrame.Size = UDim2.new(0, 300, 0, 400)
	prestigeFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
	prestigeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60))
	prestigeFrame.BorderSizePixel = 2
	prestigeFrame.Visible = false
	prestigeFrame.Parent = screenGui

	local prestigeTitle = Instance.new("TextLabel")
	prestigeTitle.Name = "PrestigeTitle"
	prestigeTitle.Size = UDim2.new(1, 0, 0, 50)
	prestigeTitle.Position = UDim2.new(0, 0, 0, 0)
	prestigeTitle.BackgroundTransparency = 1
	prestigeTitle.Font = Enum.Font.SourceSansBold
	prestigeTitle.TextSize = 24
	prestigeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	prestigeTitle.Text = "Prestige"
	prestigeTitle.Parent = prestigeFrame

	local closePrestigeBtn = Instance.new("TextButton")
	closePrestigeBtn.Name = "ClosePrestigeButton"
	closePrestigeBtn.Size = UDim2.new(0, 30, 0, 30)
	closePrestigeBtn.Position = UDim2.new(1, -35, 0, 5)
	closePrestigeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closePrestigeBtn.Font = Enum.Font.SourceSansBold
	closePrestigeBtn.TextSize = 18
	closePrestigeBtn.Text = "X"
	closePrestigeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closePrestigeBtn.Parent = prestigeFrame

	local prestigeContainer = Instance.new("Frame")
	prestigeContainer.Name = "PrestigeContainer"
	prestigeContainer.Size = UDim2.new(0.9, 0, 0.7, 0)
	prestigeContainer.Position = UDim2.new(0.05, 0, 0.2, 0)
	prestigeContainer.BackgroundTransparency = 1
	prestigeContainer.Parent = prestigeFrame
end

-- Update UI with player data
local function updateUI(data)
	if not screenGui or not screenGui.Parent then return end

	-- Update main frame values
	if mainFrame then
		local coinLabel = mainFrame:FindFirstChild("CoinLabel")
		if coinLabel and data.Coins then
			coinLabel.Text = "Coins: " .. tostring(math.floor(data.Coins))
		end

		local clickPowerLabel = mainFrame:FindFirstChild("ClickPowerLabel")
		if clickPowerLabel and data.ClickPower then
			clickPowerLabel.Text = "Click Power: " .. tostring(data.ClickPower)
		end

		local passiveIncomeLabel = mainFrame:FindFirstChild("PassiveIncomeLabel")
		if passiveIncomeLabel and data.PassiveIncome then
			passiveIncomeLabel.Text = "Passive Income: " .. tostring(data.PassiveIncome) .. "/sec"
		end
	end
end

-- Show/Hide frames
local function showUpgradeFrame(show)
	if upgradeFrame then
		upgradeFrame.Visible = show
	end
	if mainFrame then
		mainFrame.Visible = not show
	end
	if prestigeFrame then
		prestigeFrame.Visible = false
	end
end

local function showPrestigeFrame(show)
	if prestigeFrame then
		prestigeFrame.Visible = show
	end
	if mainFrame then
		mainFrame.Visible = not show
	end
	if upgradeFrame then
		upgradeFrame.Visible = false
	end
end

-- Initialize UI components
local function initializeUpgradeFrame()
	if not upgradeFrame then return end

	-- Clear existing content
	for _, child in ipairs(upgradeFrame:FindFirstChild("UpgradeContainer") or {}):GetChildren() do
		if not (child.Name == "CloseUpgradeButton") then
			child:Destroy()
		end
	end

	local container = upgradeFrame:FindFirstChild("UpgradeContainer")
	if not container then return end

	-- Sample upgrade buttons (in a real game, these would come from config/data)
	local upgrades = {
		{Name = "Click Power", Type = "Click", Cost = 50, Level = 0},
		{Name = "Passive Income", Type = "Passive", Cost = 75, Level = 0},
		{Name = "Auto-Clicker", Type = "AutoClicker", Cost = 200, Level = 0}
	}

	local yOffset = 0
	for i, upgrade in ipairs(upgrades) do
		local upgradeFrame = Instance.new("Frame")
		upgradeFrame.Size = UDim2.new(1, 0, 0, 60)
		upgradeFrame.Position = UDim2.new(0, 0, 0, yOffset)
		upgradeFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		upgradeFrame.BorderSizePixel = 1
		upgradeFrame.Parent = container

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
		nameLabel.Position = UDim2.new(0, 10, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.TextSize = 16
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Text = upgrade.Name
		nameLabel.Parent = upgradeFrame

		local levelLabel = Instance.new("TextLabel")
		levelLabel.Size = UDim2.new(0.2, 0, 1, 0)
		levelLabel.Position = UDim2.new(0.45, 0, 0, 0)
		levelLabel.BackgroundTransparency = 1
		levelLabel.Font = Enum.Font.SourceSans
		levelLabel.TextSize = 16
		levelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		levelLabel.Text = "Lv: " .. upgrade.Level
		levelLabel.Name = "LevelLabel_" .. upgrade.Type
		levelLabel.Parent = upgradeFrame

		local costLabel = Instance.new("TextLabel")
		costLabel.Size = UDim2.new(0.2, 0, 1, 0)
		costLabel.Position = UDim2.new(0.65, 0, 0, 0)
		costLabel.BackgroundTransparency = 1
		costLabel.Font = Enum.Font.SourceSans
		costLabel.TextSize = 16
		costLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		costLabel.Text = "Cost: " .. upgrade.Cost
		costLabel.Name = "CostLabel_" .. upgrade.Type
		costLabel.Parent = upgradeFrame

		local buyButton = Instance.new("TextButton")
		buyButton.Size = UDim2.new(0.15, 0, 0.8, 0)
		buyButton.Position = UDim2.new(0.85, 0, 0.1, 0)
		buyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		buyButton.Font = Enum.Font.SourceSansBold
		buyButton.TextSize = 16
		buyButton.Text = "Buy"
		buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyButton.Name = "BuyButton_" .. upgrade.Type
		buyButton.Parent = upgradeFrame

		-- Store upgrade data for button click
		buyButton:SetAttribute("UpgradeType", upgrade.Type)
		yOffset = yOffset + 70
	end
end

local function initializePrestigeFrame()
	if not prestigeFrame then return end

	-- Clear existing content (except close button)
	for _, child in ipairs(prestigeFrame:FindFirstChild("PrestigeContainer") or {}):GetChildren() do
		if not (child.Name == "ClosePrestigeButton") then
			child:Destroy()
		end
	end

	local container = prestigeFrame:FindFirstChild("PrestigeContainer")
	if not container then return end

	-- Prestige info
	local prestigeInfo = Instance.new("Frame")
	prestigeInfo.Size = UDim2.new(1, 0, 0, 100)
	prestigeInfo.Position = UDim2.new(0, 0, 0, 0)
	prestigeInfo.BackgroundTransparency = 1
	prestigeInfo.Parent = container

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(1, 0, 0, 40)
	levelLabel.Position = UDim2.new(0, 0, 0, 0)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Font = Enum.Font.SourceSansBold
	levelLabel.TextSize = 20
	levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	levelLabel.Text = "Prestige Level: 0"
	levelLabel.Name = "PrestigeLevelLabel"
	levelLabel.Parent = prestigeInfo

	local pointsLabel = Instance.new("TextLabel")
	pointsLabel.Size = UDim2.new(1, 0, 0, 40)
	pointsLabel.Position = UDim2.new(0, 0, 0, 40)
	pointsLabel.BackgroundTransparency = 1
	pointsLabel.Font = Enum.Font.SourceSans
	pointsLabel.TextSize = 16
	pointsLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
	pointsLabel.Text = "Prestige Points: 0"
	pointsLabel.Name = "PrestigePointsLabel"
	pointsLabel.Parent = prestigeInfo

	local requirementLabel = Instance.new("TextLabel")
	requirementLabel.Size = UDim2.new(1, 0, 0, 40)
	requirementLabel.Position = UDim2.new(0, 0, 0, 80)
	requirementLabel.BackgroundTransparency = 1
	requirementLabel.Font = Enum.Font.SourceSans
	requirementLabel.TextSize = 16
	requirementLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
	requirementLabel.Text = "Next Prestige at: 10,000 coins"
	requirementLabel.Name = "PrestigeRequirementLabel"
	requirementLabel.Parent = prestigeInfo

	local prestigeButton = Instance.new("TextButton")
	prestigeButton.Size = UDim2.new(0.8, 0, 0.15, 0)
	prestigeButton.Position = UDim2.new(0.1, 0, 0.6, 0)
	prestigeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
	prestigeButton.Font = Enum.Font.SourceSansBold
	prestigeButton.TextSize = 18
	prestigeButton.Text = "PRESTIGE"
	prestigeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	prestigeButton.Name = "PrestigeButton"
	prestigeButton.Parent = prestigeFrame
end

-- Event handlers
local function setupEventHandlers()
	-- Click button
	if mainFrame then
		local clickButton = mainFrame:FindFirstChild("ClickButton")
		if clickButton then
			clickButton.MouseButton1Click:Connect(function()
				ClickEvent:FireServer()
			end)

			-- Visual feedback when clicked
			clickButton.MouseButton1Down:Connect(function()
				clickButton.Size = UDim2.new(0.78, 0, 0.28, 0)
				clickButton.Position = UDim2.new(0.11, 0, 0.36, 0)
			end)

			clickButton.MouseButton1Up:Connect(function()
				clickButton.Size = UDim2.new(0.8, 0, 0.3, 0)
				clickButton.Position = UDim2.new(0.1, 0, 0.35, 0)
			end)
		end
	end

	-- Upgrade button
	if mainFrame then
		local upgradeButton = mainFrame:FindFirstChild("UpgradeButton")
		if upgradeButton then
			upgradeButton.MouseButton1Click:Connect(function()
				showUpgradeFrame(true)
				initializeUpgradeFrame()
			end)
		end
	end

	-- Prestige button
	if mainFrame then
		local prestigeButton = mainFrame:FindFirstChild("PrestigeButton")
		if prestigeButton then
			prestigeButton.MouseButton1Click:Connect(function()
				showPrestigeFrame(true)
				initializePrestigeFrame()
			end)
		end
	end

	-- Close buttons
	if upgradeFrame then
		local closeUpgradeBtn = upgradeFrame:FindFirstChild("CloseUpgradeButton")
		if closeUpgradeBtn then
			closeUpgradeBtn.MouseButton1Click:Connect(function()
				showUpgradeFrame(false)
			end)
		end
	end

	if prestigeFrame then
		local closePrestigeBtn = prestigeFrame:FindFirstChild("ClosePrestigeButton")
		if closePrestigeBtn then
			closePrestigeBtn.MouseButton1Click:Connect(function()
				showPrestigeFrame(false)
			end)
		end
	end

	-- Upgrade purchase buttons (dynamic)
	upgradeFrame.DescendantAdded:Connect(function(descendant)
		if descendant.Name:match("BuyButton_") then
			descendant.MouseButton1Click:Connect(function()
				local upgradeType = descendant:GetAttribute("UpgradeType")
				if upgradeType then
					PurchaseUpgradeEvent:FireServer(upgradeType)
				end
			end)
		end
	end)

	-- Prestige button
	if prestigeFrame then
		local prestigeButton = prestigeFrame:FindFirstChild("PrestigeButton")
		if prestigeButton then
			prestigeButton.MouseButton1Click:Connect(function()
				PrestigeEvent:FireServer()
			end)
		end
	end
end

-- Remote event handlers
local function setupRemoteHandlers()
	-- Update UI when player data changes
	PlayerDataChanged = Instance.new("BindableEvent")
	PlayerDataChanged.Event:Connect(function(data)
		updateUI(data)
		-- Update dynamic UI elements
		if upgradeFrame and upgradeFrame.Visible then
			initializeUpgradeFrame()
		end
		if prestigeFrame and prestigeFrame.Visible then
			initializePrestigeFrame()
		end
	end)

	-- Listen for data updates from server (we'll need to implement this in the server)
	-- For now, we'll rely on periodic updates or specific event triggers

	-- Handle purchase results
	PurchaseUpgradeEvent.OnClientEvent:Connect(function(success, upgradeType, message)
		if success then
			-- Update button text or show confirmation
			print("Successfully purchased:", upgradeType)
			-- Could show a temporary green flash or notification
		else
			-- Show error
			print("Purchase failed:", message)
			-- Could show a red flash or error message
		end
	end)

	-- Handle prestige results
	PrestigeEvent.OnClientEvent:Connect(function(success, prestigeLevel, points, message)
		if success then
			print("Presige successful! New level:", prestigeLevel, "Points:", points)
			-- Show celebration effect
		else
			print("Prestige failed:", message)
			-- Show error message
		end
	end)
end

-- Main initialization
local function init()
	createUI()
	setupEventHandlers()
	setupRemoteHandlers()

	-- Initial update (will be updated when we get data from server)
	updateUI({
		Coins = 0,
		ClickPower = 1,
		PassiveIncome = 0
	})

	print("Clicker client initialized")
end

-- Start the script
init()

-- Keep the script running
while true do
	wait(1)
	-- Could add periodic updates here if needed
end