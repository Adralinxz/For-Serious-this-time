-- DataManager.lua
-- Handles player data persistence using DataStoreService

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local PLAYER_DATA_STORE = DataStoreService:GetDataStore("PlayerDataStore_V1")
local SAVE_INTERVAL = 300 -- 5 minutes

local DataManager = {}

-- Save player data to DataStore
function DataManager:SavePlayerData(player, data)
	local success, errorMessage = pcall(function()
		PLAYER_DATA_STORE:SetAsync(tostring(player.UserId), data)
	end)

	if not success then
		warn("Failed to save data for player " .. player.Name .. ": " .. errorMessage)
		return false
	end

	return true
end

-- Load player data from DataStore
function DataManager:LoadPlayerData(player)
	local success, data = pcall(function()
		return PLAYER_DATA_STORE:GetAsync(tostring(player.UserId))
	end)

	if success and data ~= nil then
		return data
	else
		warn("Failed to load data for player " .. player.Name .. ": " .. tostring(data))
		return nil
	end
end

-- Create default player data structure
function DataManager:GetDefaultData()
	return {
		Coins = 0,
		ClickPower = 1,
		PassiveIncome = 0,
		Prestige = {
			Level = 0,
			Points = 0
		},
		Upgrades = {
			ClickLevel = 0,
			PassiveLevel = 0,
			AutoClickerLevel = 0
		},
		LastOnline = os.time(),
		TotalPlaytime = 0,
		Achievements = {}
	}
end

-- Apply data to player's ValueObjects in ServerStorage
function DataManager:ApplyDataToPlayer(player, data)
	-- Create or get player's data folder in ServerStorage
	local dataFolder = ServerStorage:FindFirstChild(player.Name .. "_Data")
	if not dataFolder then
		dataFolder = Instance.new("Folder")
		dataFolder.Name = player.Name .. "_Data"
		dataFolder.Parent = ServerStorage
	end

	-- Clear existing values
	for _, child in ipairs(dataFolder:GetChildren()) do
		child:Destroy()
	end

	-- Function to recursively create ValueObjects from data table
	local function createValuesFromTable(parent, tableData)
		for key, value in pairs(tableData) do
			if type(value) == "table" then
				-- Create a folder for nested tables
				local folder = Instance.new("Folder")
				folder.Name = tostring(key)
				folder.Parent = parent
				createValuesFromTable(folder, value)
			elseif type(value) == "number" then
				-- Create a NumberValue for numeric values
				local valueObj = Instance.new("NumberValue")
				valueObj.Name = tostring(key)
				valueObj.Value = value
				valueObj.Parent = parent
			end
		end
	end

	createValuesFromTable(dataFolder, data)
end

-- Update DataStore with current ValueObjects
function DataManager:UpdateDataFromPlayer(player)
	local dataFolder = ServerStorage:FindFirstChild(player.Name .. "_Data")
	if not dataFolder then
		return self:GetDefaultData()
	end

	-- Collect data from ValueObjects
	local function collectValuesFromTable(parent)
		local result = {}
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("Folder") then
				result[child.Name] = collectValuesFromTable(child)
			elseif child:IsA("NumberValue") then
				result[child.Name] = child.Value
			end
		end
		return result
	end

	local data = collectValuesFromTable(dataFolder)
	data.LastCollected = os.time()
	return data
end

return DataManager