local menu = {}

-- Function to sort table by keys
local function pairsByKeys(t, f)
    local sortedKeys = {}
    for key in pairs(t) do
        table.insert(sortedKeys, key)
    end
    table.sort(sortedKeys, f)
    
    local i = 0
    return function()
        i = i + 1
        local key = sortedKeys[i]
        if key then
            return key, t[key]
        end
    end
end

-- Function to sort vehicles by category
local function sort(tableToSort)
    local sortedTable = {}
    for category, vehicles in pairsByKeys(tableToSort) do
        table.insert(sortedTable, {
            category = category,
            vehicles = vehicles
        })
    end
    return sortedTable
end

-- Function to get the vehicle label (make + model)
local function getVehicleLabel(model)
    local make = GetLabelText(GetMakeNameFromVehicleModel(model))
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if make == "NULL" then
        return name
    elseif name == "NULL" then
        return make
    end
    return string.format("%s %s", make, name)
end

-- Function to get dealer vehicles
local function getDealerVehicles(categoryVehicles)
    local values = {}
    for i = 1, #categoryVehicles do
        local vehicleInfo = categoryVehicles[i]
        local model = vehicleInfo.model

        -- Check if the model exists in the game
        if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
            print(string.format("^3Vehicle model '%s' wasn't found. It might not exist or isn't a valid vehicle model.", model))
        else
            local label = vehicleInfo.menuLabel or vehicleInfo.label or getVehicleLabel(model)
            if vehicleInfo.label then
                AddTextEntryByHash(model, vehicleInfo.label)
            end
            table.insert(values, label)
        end
    end
    return values
end

-- Function to create dealer menu options
local function getDealerMenu(categories)
    local options = {}
    local categoryVehicles = {}

    -- Populate category vehicles
    for _, category in pairs(categories) do
        categoryVehicles[category] = Data.vehicles[category]
    end

    local sortedVehicles = sort(categoryVehicles)

    for _, vehicleInfo in ipairs(sortedVehicles) do
        table.insert(options, {
            icon = 'car',
            label = vehicleInfo.category,
            values = getDealerVehicles(vehicleInfo.vehicles),
            args = { category = vehicleInfo.category }
        })
    end

    return options
end

-- Register menus for each dealership
for dealership, dealerInfo in pairs(Data.dealerships) do
    local info = {
        id = string.format("ND_Dealership:%s", dealership),
        title = dealership,
        position = "top-right",
        options = getDealerMenu(dealerInfo.categories)
    }

    lib.registerMenu(info, function(_, scrollIndex, args)
    local category = args.category
    local categoryVehicles = Data.vehicles[category]

    if categoryVehicles and categoryVehicles[scrollIndex] then
        lib.hideMenu()
        local vehicleInfo = categoryVehicles[scrollIndex]

        print("Selected vehicle:", vehicleInfo.model)
        
        TriggerEvent("ND_Dealership:menuItemSelected", {
            dealership = dealership,
            category = category,
            index = scrollIndex,
            price = vehicleInfo.price,
            model = vehicleInfo.model,
            info = vehicleInfo,
            menuType = menu.menuShowType
        })

        -- Delay to allow vehicle creation and target assignment to complete
        Wait(1000)
        lib.showMenu(string.format("ND_Dealership:%s", dealership))
    else
        print("^1Error: Invalid category or vehicle index.")
    end
end)
end

-- Function to show the menu
function menu.show(dealer, showType)
    menu.menuShowType = showType
    local dealerMenu = string.format("ND_Dealership:%s", dealer)
    lib.showMenu(dealerMenu)
end

return menu
