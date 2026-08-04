-- UIManager.lua
-- Manages UI updates based on server data

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Remote Events (these should already exist from ClickerClient)
local UpdatePlayerDataEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdatePlayerData")
local UpdateLeaderboardEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdateLeaderboard")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- UI References
local ScreenGui = nil
local MainFrame = nil
local CoinLabel = nil
local ClickPowerLabel = nil
local PassiveIncomeLabel = nil
local PrestigeLabel = nil

-- Initialize UI
local function initializeUI()
	-- Check if UI already exists (avoid duplicates)
	if PlayerGui:FindFirstChild("ClickerGui") then
		PlayerGui:FindFirstChild("ClickerGui"):Destroy()
	end

	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ClickerGui"
	ScreenGui.Parent = PlayerGui

	-- Main Frame
	MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 300, 0, 400)
	MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
	MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	MainFrame.BorderSizePixel = 2
	MainFrame.Parent = ScreenGui

	-- Title
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "TitleLabel"
	TitleLabel.Size = UDim2.new(1, 0, 0, 50)
	TitleLabel.Position = UDim2.new(0, 0, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.SourceSansBold
	TitleLabel.TextSize = 24
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.Text = "Clicker Game"
	TitleLabel.Parent = MainFrame

	-- Coin Display
	CoinLabel = Instance.new("TextLabel")
	CoinLabel.Name = "CoinLabel"
	CoinLabel.Size = UDim2.new(1, 0, 0, 40)
	CoinLabel.Position = UDim2.new(0, 0, 0, 50)
	CoinLabel.BackgroundTransparency = 1
	CoinLabel.Font = Enum.Font.SourceSansBold
	CoinLabel.TextSize = 20
	CoinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	CoinLabel.Text = "Coins: 0"
	CoinLabel.Parent = MainFrame

	-- Click Power Display
	ClickPowerLabel = Instance.new("TextLabel")
	ClickPowerLabel.Name = "ClickPowerLabel"
	ClickPowerLabel.Size = UDim2.new(1, 0, 0, 30)
	ClickPowerLabel.Position = UDim2.new(0, 0, 0, 90)
	ClickPowerLabel.BackgroundTransparency = 1
	ClickPowerLabel.Font = Enum.Font.SourceSans
	ClickPowerLabel.TextSize = 16
	ClickPowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	ClickPowerLabel.Text = "Click Power: 1"
	ClickPowerLabel.Parent = MainFrame

	-- Passive Income Display
	PassiveIncomeLabel = Instance.new("TextLabel")
	PassiveIncomeLabel.Name = "PassiveIncomeLabel"
	PassiveIncomeLabel.Size = UDim2.new(1, 0, 0, 30)
	PassiveIncomeLabel.Position = UDim2.new(0, 0, 0, 120)
	PassiveIncomeLabel.BackgroundTransparency = 1
	PassiveIncomeLabel.Font = Enum.Font.SourceSans
	PassiveIncomeLabel.TextSize = 16
	PassiveIncomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	PassiveIncomeLabel.Text = "Passive Income: 0/sec"
	PassiveIncomeLabel.Parent = MainFrame

	-- Prestige Display
	PrestigeLabel = Instance.new("TextLabel")
	PrestigeLabel.Name = "PrestigeLabel"
	PrestigeLabel.Size = UDim2.new(1, 0, 0, 30)
	PrestigeLabel.Position = UDim2.new(0, 0, 0, 150)
	PrestigeLabel.BackgroundTransparency = 1
	PrestigeLabel.Font = Enum.Font.SourceSans
	PrestigeLabel.TextSize = 16
	PrestigeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
	PrestigeLabel.Text = "Prestige: 0"
	PrestigeLabel.Parent = MainFrame

	-- Buttons (simplified)
	local ClickButton = Instance.new("TextButton")
	ClickButton.Name = "ClickButton"
	ClickButton.Size = UDim2.new(0.8, 0, 0.3, 0)
	ClickButton.Position = UDim2.new(0.1, 0, 0.35, 0)
	ClickButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	ClickButton.Font = Enum.Font.SourceSansBold
	ClickButton.TextSize = 24
	ClickButton.Text = "CLICK ME!"
	ClickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ClickButton.Parent = MainFrame

	local UpgradeButton = Instance.new("TextButton")
	UpgradeButton.Name = "UpgradeButton"
	UpgradeButton.Size = UDim2.new(0.8, 0, 0.1, 0)
	UpgradeButton.Position = UDim2.new(0.1, 0, 0.7, 0)
	UpgradeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	UpgradeButton.Font = Enum.Font.SourceSans
	UpgradeButton.TextSize = 18
	UpgradeButton.Text = "Upgrades"
	UpgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	UpgradeButton.Parent = MainFrame

	local PrestigeButton = Instance.new("TextButton")
	PrestigeButton.Name = "PrestigeButton"
	PrestigeButton.Size = UDim2.new(0.8, 0, 0.1, 0)
	PrestigeButton.Position = UDim2.new(0.1, 0, 0.82, 0)
	PrestigeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
	PrestigeButton.Font = Enum.Font.SourceSans
	PrestigeButton.TextSize = 18
	PrestigeButton.Text = "Prestige"
	PrestigeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	PrestigeButton.Parent = MainFrame
end

-- Update UI with new data
local function updateUI(Data)
	if CoinLabel then
		CoinLabel.Text = "Coins: " .. tostring(math.floor(Data.Coins or 0))
	end

	if ClickPowerLabel then
		ClickPowerLabel.Text = "Click Power: " .. tostring(Data.ClickPower or 1)
	end

	if PassiveIncomeLabel then
		PassiveIncomeLabel.Text = "Passive Income: " .. tostring((Data.PassiveIncome or 0) .. "/sec")
	end

	if PrestigeLabel then
		PrestigeLabel.Text = "Prestige: " .. tostring((Data.Prestige and Data.Prestige.Level) or 0)
	end
end

-- Event Connections
local function setupConnections()
	UpdatePlayerDataEvent.OnClientEvent:Connect(function(Data)
		updateUI(Data)
	end)

	-- Button click handlers would go here, but they're handled in ClickerClient.lua
	-- This module focuses purely on UI updates from server data
end

-- Initialize
local function init()
	initializeUI()
	setupConnections()
end

init()

return {
	updateUI = updateUI,
	initializeUI = initializeUI
}