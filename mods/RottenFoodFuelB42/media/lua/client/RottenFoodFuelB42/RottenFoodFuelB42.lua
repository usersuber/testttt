require "Camping/ISUI/ISCampingMenu"

RottenFoodFuelB42 = RottenFoodFuelB42 or {}

RottenFoodFuelB42.MIN_FUEL_MINUTES = 5
-- Keep very heavy rotten food from producing excessive burn times.
RottenFoodFuelB42.MAX_FUEL_MINUTES = 90
RottenFoodFuelB42.MINUTES_PER_WEIGHT = 15
RottenFoodFuelB42.ONE_MINUTE_IN_HOURS = 1 / 60

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function isInstanceOf(item, className)
    return type(instanceof) == "function" and instanceof(item, className)
end

local function isNonEmptyContainer(item)
    return isInstanceOf(item, "InventoryContainer") and item:getInventory() and not item:getInventory():isEmpty()
end

function RottenFoodFuelB42.isRottenFood(item)
    if not item then
        return false
    end

    local isFood = isInstanceOf(item, "Food")
    if not isFood and type(item.IsFood) == "function" then
        isFood = item:IsFood()
    end
    if not isFood then
        return false
    end

    if type(item.isRotten) == "function" then
        return item:isRotten()
    end
    if type(item.IsRotten) == "function" then
        return item:IsRotten()
    end
    return false
end

function RottenFoodFuelB42.getFuelMinutes(item)
    local weight = 0
    if item and type(item.getWeight) == "function" then
        weight = item:getWeight() or 0
    end

    local minutes = clamp(weight * RottenFoodFuelB42.MINUTES_PER_WEIGHT, RottenFoodFuelB42.MIN_FUEL_MINUTES, RottenFoodFuelB42.MAX_FUEL_MINUTES)
    return math.floor(minutes + 0.5)
end

local function registerRottenFoodType(item)
    if not campingFuelType or not RottenFoodFuelB42.isRottenFood(item) then
        return
    end

    local itemType = type(item.getType) == "function" and item:getType() or nil
    if not itemType or itemType == "" then
        return
    end

    if campingFuelType[itemType] == nil or campingFuelType[itemType] <= 0 then
        campingFuelType[itemType] = RottenFoodFuelB42.ONE_MINUTE_IN_HOURS
    end
end

local function canUseAsFuel(item)
    if not RottenFoodFuelB42.isRottenFood(item) then
        return false
    end
    if type(item.isFavorite) == "function" and item:isFavorite() then
        return false
    end
    if isNonEmptyContainer(item) then
        return false
    end

    registerRottenFoodType(item)
    return true
end

local function installCampingFuelPatch()
    if RottenFoodFuelB42._installed or not ISCampingMenu or type(ISCampingMenu.isValidFuel) ~= "function" then
        return
    end

    RottenFoodFuelB42._installed = true

    local originalIsValidFuel = ISCampingMenu.isValidFuel
    local originalGetFuelDurationForItem = ISCampingMenu.getFuelDurationForItem

    function ISCampingMenu.isValidFuel(item)
        return originalIsValidFuel(item) or canUseAsFuel(item)
    end

    function ISCampingMenu.getFuelDurationForItem(item)
        if canUseAsFuel(item) then
            return RottenFoodFuelB42.getFuelMinutes(item)
        end
        return originalGetFuelDurationForItem(item)
    end
end

installCampingFuelPatch()

if Events and Events.OnGameBoot then
    Events.OnGameBoot.Add(installCampingFuelPatch)
end
