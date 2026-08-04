-- ClickerServer.lua
-- Main server script for the clicker game

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Data stores
local playerDataStore = DataStoreService:GetDataStore("PlayerDataV1")

-- Remote Events
local ClickEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClickEvent")
local PurchaseUpgradeEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PurchaseUpgradeEvent")
local PrestigeEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PrestigeEvent")

-- Game configuration
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

-- Player data structure
local function createDefaultPlayerData()
	return {
		Coins = 0,
		ClickPower = 1,
		PassiveIncome = 0,
		Upgrades = {
			ClickLevel = 0,
			PassiveLevel = 0,
			AutoClickerLevel = 0
		},
		Prestige = {
			Level = 0,
			Points = 0
		},
		LastOnline = os.time(),
		TotalClicks = 0
	}
end

-- Load player data
local function loadPlayerData(player)
	local userId = tostring(player.UserId)
	local success, data = pcall(function()
		return playerDataStore:GetAsync(userId)
	end)

	if success and data then
		return data
	else
		warn("Failed to load data for player:", player.Name, "using default data")
		return createDefaultPlayerData()
	end
end

-- Save player data
local function savePlayerData(player, data)
	local userId = tostring(player.UserId)
	local success, err = pcall(function()
		playerDataStore:SetAsync(userId, data)
	end)

	if not success then
		warn("Failed to save data for player:", player.Name, "Error:", err)
	end
end

-- Handle player joining
local function onPlayerAdded(player)
	print("Player joined:", player.Name)

	-- Load player data
	local playerData = loadPlayerData(player)

	-- Store data in a folder for easy access
	local dataFolder = Instance.new("Folder")
	dataFolder.Name = player.Name .. "_Data"
	dataFolder.Parent = ServerStorage

	-- Create value objects for each data field
	for key, value in pairs(playerData) do
		if typeof(value) == "number" then
			local valueObj = Instance.new("NumberValue")
			valueObj.Name = key
			valueObj.Value = value
			valueObj.Parent = dataFolder
		elseif typeof(value) == "table" then
			-- Handle tables separately if needed
			local folder = Instance.new("Folder")
			folder.Name = key
			folder.Parent = dataFolder

			for subKey, subValue in pairs(value) do
				if typeof(subValue) == "number" then
					local valueObj = Instance.new("NumberValue")
					valueObj.Name = subKey
					valueObj.Value = subValue
					valueObj.Parent = folder
				end
			end
		end
	end

	-- Set up leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = playerData.Coins
	coins.Parent = leaderstats

	local prestige = Instance.new("IntValue")
	prestige.Name = "Prestige"
	prestige.Value = playerData.Prestige.Level
	prestige.Parent = leaderstats

	-- Connect to player leaving
	player.AncestryChanged:connect(function(_, parent)
		if not parent then
			onPlayerRemoving(player)
		end
	end)
end

-- Handle player leaving
local function onPlayerRemoving(player)
	print("Player left:", player.Name)

	-- Find the data folder
	local dataFolder = ServerStorage:FindFirstChild(player.Name .. "_Data")
	if dataFolder then
		-- Collect data from value objects
		local playerData = {}

		for _, child in ipairs(dataFolder:GetChildren()) do
			if child:IsA("NumberValue") then
				playerData[child.Name] = child.Value
			elseif child:IsA("Folder") then
				-- Handle nested folders (like Upgrades, Prestige)
				local subData = {}
				for _, grandChild in ipairs(child:GetChildren()) do
					if grandChild:IsA("NumberValue") then
						subData[grandChild.Name] = grandChild.Value
					end
				end
				playerData[child.Name] = subData
			end
		PlayerData.LastOnline = os.time()

		-- Save data
		savePlayerData(player, playerData)

		-- Clean up
		dataFolder:Destroy()
	end
end

-- Handle click event
ClickEvent.OnServerEvent:Connect(function(player)
	local dataFolder = ServerStorage:FindFirstChild(player.Name .. "_Data")
	if dataFolder then
		local clickPowerObj = dataFolder:FindFirstChild("ClickPower")
		local totalClicksObj = dataFolder:FindFirstChild("TotalClicks")
		local coinsObj = dataFolder:FindFirstChild("Coins")

		if clickPowerObj and totalClicksObj and coinsObj then
			-- Award coins based on click power
			local coinsToAdd = clickPowerObj.Value
			coinsObj.Value = coinsObj.Value + coinsToAdd
			totalClicksObj.Value = totalClicksObj.Value + 1

			-- Update leaderstats
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local leaderCoins = leaderstats:FindFirstChild("Coins")
				if leaderCoins then
					leaderCoins.Value = coinsObj.Value
				end
			end

			-- Visual/audio feedback could be sent to client here
			-- ClickEvent:FireClient(player, coinsToAdd)
		end
	end
end)

-- Handle upgrade purchase
PurchaseUpgradeEvent.OnServerEvent:Connect(function(player, upgradeType)
	local dataFolder = ServerStorage:FindFirstChild(player.Name .. "_Data")
	if dataFolder then
		local coinsObj = dataFolder:FindFirstChild("Coins")
		local upgradeLevelObj = nil

		if upgradeType == "Click" then
			upgradeLevelObj = dataFolder:FindFirstChild("Upgrades"):FindFirstChild("ClickLevel")
		elseif upgradeType == "Passive" then
			upgradeLevelObj = dataFolder:FindFirstChild("Upgrades"):FindFirstChild("PassiveLevel")
		elseif upgradeType == "AutoClicker" then
			upgradeLevelObj = dataFolder:FindFirstChild("Upgrades"):FindFirstChild("AutoClickerLevel")
		end

		if coinsObj and upgradeLevelObj then
			local currentLevel = upgradeLevelObj.Value
			local upgradeCost = Config.GetUpgradeCost(upgradeType, currentLevel)

			if coinsObj.Value >= upgradeCost then
				-- Apply upgrade
				coinsObj.Value = coinsObj.Value - upgradeCost
				upgradeLevelObj.Value = currentLevel + 1

				-- Update stats based on upgrade
				if upgradeType == "Click" then
					local clickPowerObj = dataFolder:FindFirstChild("ClickPower")
					if clickPowerObj then
						clickPowerObj.Value = 1 + (upgradeLevelObj.Value * Config.CLICK_POWER_PER_LEVEL)
					end
				elseif upgradeType == "Passive" then
					local passiveIncomeObj = dataFolder:FindFirstChild("PassiveIncome")
					if passiveIncomeObj then
						passiveIncomeObj.Value = upgradeLevelObj.Value * Config.PASSIVE_INCOME_PER_LEVEL
					end
				end

				-- Update leaderstats
				local leaderstats = player:FindFirstChild("leaderstats")
				if leaderstats then
					local leaderCoins = leaderstats:FindFirstChild("Coins")
					if leaderCoins then
						leaderCoins.Value = coinsObj.Value
					end
				end

				-- Notify client of successful purchase
				PurchaseUpgradeEvent:FireClient(player, true, upgradeType, upgradeLevelObj.Value)
			else
				-- Not enough coins
				PurchaseUpgradeEvent:FireClient(player, false, upgradeType, "Not enough coins")
			end
		end
	end
end)

-- Handle prestige
PrestigeEvent.OnServerEvent:Connect(function(player)
	local dataFolder = ServerStorage:FindFirstChild(player.Name .. "_Data")
	if dataFolder then
		local coinsObj = dataFolder:FindFirstChild("Coins")
		local prestigeLevelObj = dataFolder:FindFirstChild("Prestige"):FindFirstChild("Level")
		local prestigePointsObj = dataFolder:FindFirstChild("Prestige"):FindFirstChild("Points")

		if coinsObj and prestigeLevelObj and prestigePointsObj then
			local prestigeRequirement = Config.GetPrestigeRequirement(prestigeLevelObj.Value)

			if coinsObj.Value >= prestigeRequirement then
				-- Apply prestige
				local prestigePointsEarned = math.floor(coinsObj.Value / 1000) -- Example formula
				prestigePointsObj.Value = prestigePointsObj.Value + prestigePointsEarned
				prestigeLevelObj.Value = prestigeLevelObj.Value + 1

				-- Reset progress but keep prestige benefits
				coinsObj.Value = 0
				dataFolder:FindFirstChild("Upgrades"):FindFirstChild("ClickLevel").Value = 0
				dataFolder:FindFirstChild("Upgrades"):FindFirstChild("PassiveLevel").Value = 0
				dataFolder:FindFirstChild("Upgrades"):FindFirstChild("AutoClickerLevel").Value = 0
				dataFolder:FindFirstChild("ClickPower").Value = 1 + (prestigeLevelObj.Value * Config.PRESTIGE_CLICK_BONUS)
				dataFolder:FindFirstChild("PassiveIncome").Value = prestigeLevelObj.Value * Config.PRESTIGE_PASSIVE_BONUS

				-- Update leaderstats
				local leaderstats = player:FindFirstChild("leaderstats")
				if leaderstats then
					local leaderCoins = leaderstats:FindFirstChild("Coins")
					local leaderPrestige = leaderstats:FindFirstChild("Prestige")
					if leaderCoins then
						leaderCoins.Value = coinsObj.Value
					end
					if leaderPrestige then
						leaderPrestige.Value = prestigeLevelObj.Value
					end
				end

				-- Notify client
				PrestigeEvent:FireClient(player, true, prestigeLevelObj.Value, prestigePointsObj.Value)
			else
				-- Not enough coins for prestige
				PrestigeEvent:FireClient(player, false, prestigeLevelObj.Value, "Not enough coins for prestige")
			end
		end
	end
end)

-- Passive income loop
spawn(function()
	while true do
		wait(1) -- Every second

		for _, player in ipairs(Players:GetPlayers()) do
			local dataFolder = ServerStorage:FindFirstChild(player.Name .. "_Data")
			if dataFolder then
				local coinsObj = dataFolder:FindFirstChild("Coins")
				local passiveIncomeObj = dataFolder:FindFirstChild("PassiveIncome")
				local autoClickerLevelObj = dataFolder:FindFirstChild("Upgrades"):FindFirstChild("AutoClickerLevel")

				if coinsObj and passiveIncomeObj then
					-- Base passive income
					local coinsToAdd = passiveIncomeObj.Value

					-- Auto-clicker bonus
					if autoClickerLevelObj then
						local autoClickerRate = autoClickerLevelObj.Value * 0.5 -- 0.5 clicks per second per level
						coinsToAdd = coinsToAdd + (autoClickerRate * (dataFolder:FindFirstChild("ClickPower").Value or 1))
					end

					if coinsToAdd > 0 then
						coinsObj.Value = coinsObj.Value + coinsToAdd

						-- Update leaderstats
						local leaderstats = player:FindFirstChild("leaderstats")
						if leaderstats then
							local leaderCoins = leaderstats:FindFirstChild("Coins")
							if leaderCoins then
								leaderCoins.Value = coinsObj.Value
							end
						end
					end
				end
			end
		end
	end
end)

-- Auto-save every 5 minutes
spawn(function()
	while true do
		wait(300) -- 5 minutes

		for _, player in ipairs(Players:GetPlayers()) do
			local dataFolder = ServerStorage:FindFirstChild(player.Name .. "_Data")
			if dataFolder then
				-- Collect data from value objects
				local playerData = {}

				for _, child in ipairs(dataFolder:GetChildren()) do
					if child:IsA("NumberValue") then
						playerData[child.Name] = child.Value
					elseif child:IsA("Folder") then
						local subData = {}
						for _, grandChild in ipairs(child:GetChildren()) do
							if grandChild:IsA("NumberValue") then
								subData[grandChild.Name] = grandChild.Value
							end
						end
						playerData[child.Name] = subData
					end
				end
				playerData.LastOnline = os.time()

				-- Save data
				savePlayerData(player, playerData)
			end
		end
	end
end)

-- Connect player events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Load existing players (in case of server start)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

print("Clicker server initialized")