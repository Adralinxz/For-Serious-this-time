-- Config.lua
-- Game configuration and balancing

local Config = {}

-- Click power settings
Config.BASE_CLICK_POWER = 1
Config.CLICK_POWER_PER_LEVEL = 1

-- Passive income settings
Config.BASE_PASSIVE_INCOME = 0
Config.PASSIVE_INCOME_PER_LEVEL = 2

-- Auto-clicker settings
-- (Handled through passive income in this simple version)

-- Prestige bonuses
Config.PRESTIGE_CLICK_BONUS = 2
Config.PRESTIGE_PASSIVE_BONUS = 5

-- Upgrade costs (exponential growth)
function Config.GetUpgradeCost(upgradeType, currentLevel)
	local baseCost = 100
	local multiplier = 1.5

	if upgradeType == "Click" then
		baseCost = 50
	elseif upgradeType == "Passive" then
		baseCost = 75
	elseif upgradeType == "AutoClicker" then
		baseCost = 200
	end

	return math.floor(baseCost * (multiplier ^ currentLevel))
end

-- Prestige requirements (exponential growth)
function Config.GetPrestigeRequirement(currentPrestigeLevel)
	local baseRequirement = 10000
	local growthFactor = 2

	return math.floor(baseRequirement * (growthFactor ^ currentPrestigeLevel))
end

-- Prestige points earned on prestige
function Config.GetPrestigePointsEarned(currentCoins, currentPrestigeLevel)
	-- Simple formula: 1 point per 1000 coins, reduced by prestige level to prevent inflation
	local basePoints = math.floor(currentCoins / 1000)
	local prestigePenalty = 1 + (currentPrestigeLevel * 0.1) -- Increases cost slightly each prestige
	return math.floor(basePoints / prestigePenalty)
end

return Config