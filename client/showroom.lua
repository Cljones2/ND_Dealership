local showroom = {
    rooms = {},
    vehicles = {},
    pointsCreated = false,
    slots = {}
}

function showroom.deleteVehicles(vehicles)
    if not vehicles then return end
    Target:removeLocalEntity(vehicles, {"nd_dealership:showroomTestDrive", "nd_dealership:showroomSwitchVeh", "nd_dealership:showroomPurchase"})

    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) then
            print("Deleting vehicle:", vehicle)  -- Debug print
            DeleteEntity(vehicle)
        end
    end

    -- Clear the slots and vehicles list
    showroom.slots = {}
    showroom.vehicles = {}
end


function showroom.getSlotFromEntity(entity)
    for slot, slotEntity in ipairs(showroom.slots) do
        if DoesEntityExist(slotEntity) and slotEntity == entity then
            return slot
        end
    end
end

function showroom.getVehicleData(entity)
    for dealer, vehicles in pairs(showroom.rooms) do
        for i=1, #vehicles do
            local info = vehicles[i]
            if info and info.vehicle == entity then
                return info, dealer
            end
        end
    end
end

local function setTargetPerms(vehicle, groups, vehicleTargets)
    if groups then        
        if HasPermissionGroup("switch", groups) then
            vehicleTargets.switch[#vehicleTargets.switch+1] = vehicle
        end
        if HasPermissionGroup("testdrive", groups) then
            vehicleTargets.testdrive[#vehicleTargets.testdrive+1] = vehicle
        end
        if HasPermissionGroup("purchase", groups) then
            vehicleTargets.purchase[#vehicleTargets.purchase+1] = vehicle
        end
    else
        vehicleTargets.switch[#vehicleTargets.switch+1] = vehicle
        vehicleTargets.testdrive[#vehicleTargets.testdrive+1] = vehicle
        vehicleTargets.purchase[#vehicleTargets.purchase+1] = vehicle
    end
end

function showroom.spawnVehicles(dealer, sr)
    local vehiclesCreated = {}
    local dealerProperties = {}
    local vehicleTargets = {
        switch = {},
        testdrive = {},
        purchase = {}
    }

    for i=1, #sr do
        local info = sr[i]
        local loc = info.location
        ClearAreaOfVehicles(loc.x, loc.y, loc.z, 10.0, false, false, false, false, false)
        lib.requestModel(info.model)

        local vehicle = CreateVehicle(info.model, loc.x, loc.y, loc.z, loc.w, false, false)
        vehiclesCreated[#vehiclesCreated+1] = vehicle
        showroom.slots[#showroom.slots+1] = vehicle

        setTargetPerms(vehicle, info.groups, vehicleTargets)
        SetVehicleDoorsLocked(vehicle, 2)
        SetVehicleOnGroundProperly(vehicle)
        FreezeEntityPosition(vehicle, true)

        info.vehicle = vehicle
        local props = info.properties
        if props then
            lib.setVehicleProperties(vehicle, json.decode(props))
        else
            info.properties = json.encode(lib.getVehicleProperties(vehicle))
            dealerProperties[i] = info.properties
        end
    end
    showroom.vehicles[dealer] = vehiclesCreated
    TriggerEvent("ND_Dealership:createVehicleTargets", vehicleTargets, dealer)
    return dealerProperties
end

local function replaceCreatedVehicle(dealer, oldVehicle, newVehicle)
    local vehiclesCreated = showroom.vehicles[dealer]
    for i=1, #vehiclesCreated do
        local veh = vehiclesCreated[i]
        if veh == oldVehicle then
            vehiclesCreated[i] = newVehicle
            return
        end
    end
    vehiclesCreated[#vehiclesCreated+1] = newVehicle
end

function showroom.createVehicle(selectedVehicle, dealer, index, vehicleInfo)
    showroom.switchInProgress = true

    local sr = showroom.rooms[dealer]
    local vehicleTargets = {
        switch = {},
        testdrive = {},
        purchase = {}
    }

    local oldVehicle = sr[selectedVehicle] and sr[selectedVehicle].vehicle
    if oldVehicle and DoesEntityExist(oldVehicle) then
        print("Deleting old vehicle:", oldVehicle)  -- Debug print
        DeleteEntity(oldVehicle)
    end

    vehicleInfo.groups = sr[selectedVehicle] and sr[selectedVehicle].groups
    sr[selectedVehicle] = vehicleInfo
    local info = sr[selectedVehicle]

    local loc = info.location
    print(("Spawning new vehicle at coordinates: x: %f, y: %f, z: %f, w: %f"):format(loc.x, loc.y, loc.z, loc.w))

    lib.requestModel(info.model)
    while not HasModelLoaded(info.model) do
        Wait(100)
    end

    local vehicle = CreateVehicle(info.model, loc.x, loc.y, loc.z, loc.w, false, false)

    if DoesEntityExist(vehicle) then
        print("New vehicle created successfully:", vehicle)  -- Debug print
    else
        print("^1Error: New vehicle creation failed.")  -- Debug print
        showroom.switchInProgress = false
        return
    end

    -- Clean the vehicle (repair and wash)
    SetVehicleFixed(vehicle)           -- Fully repair the vehicle
    SetVehicleDirtLevel(vehicle, 0.0)  -- Set dirt level to 0 (completely clean)

    showroom.vehicles[dealer][selectedVehicle] = vehicle
    showroom.slots[selectedVehicle] = vehicle

    setTargetPerms(vehicle, info.groups, vehicleTargets)
    SetVehicleDoorsLocked(vehicle, 2)
    SetVehicleOnGroundProperly(vehicle)
    FreezeEntityPosition(vehicle, true)
    FreezeEntityPosition(vehicle, false)

    info.vehicle = vehicle
    lib.setVehicleProperties(vehicle, json.decode(info.properties))

    showroom.switchInProgress = false

    TriggerEvent("ND_Dealership:createVehicleTargets", vehicleTargets, dealer)
end



function showroom.createPoints()
    showroom.pointsCreated = true
    for dealer, sr in pairs(showroom.rooms) do
        local location = sr[1].location
        local point = lib.points.new({
            coords = location,
            distance = 30
        })

        function point:onEnter()
            SetTimeout(500, function()
                print("Entering showroom area for dealer:", dealer)  -- Debug print
                -- Clear any existing vehicles before spawning new ones
                showroom.deleteVehicles(showroom.vehicles[dealer])
                showroom.vehicles[dealer] = {}
                showroom.slots = {}
                
                local dealerProperties = showroom.spawnVehicles(dealer, sr)
                if next(dealerProperties) then
                    TriggerServerEvent("ND_Dealership:updateDealerProperties", dealer, dealerProperties)
                end
            end)
        end

        function point:onExit()
            print("Exiting showroom area for dealer:", dealer)  -- Debug print
            showroom.deleteVehicles(showroom.vehicles[dealer])
            showroom.vehicles[dealer] = {}
            showroom.slots = {}
        end
    end
end


function showroom.createShowrooms(rooms)
    showroom.rooms = rooms
    if not showroom.pointsCreated then
        showroom.createPoints()
    end
end



return showroom