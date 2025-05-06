local config = require ('config.cl_config')
local sConfig = require ('config.sh_config')

local crate
local caseLocation
local crateBlip
local vehicle

RegisterNetEvent('corrupt-cases:spawnCase', function()
    caseLocation = lib.callback.await('corrupt-cases:getCaseLocation')
    crate = setupCrate(config['crate_model'], caseLocation)

    crateBlip = AddBlipForCoord(caseLocation)
    SetBlipSprite(crateBlip, 161)
    SetBlipDisplay(crateBlip, 4)
    SetBlipScale(crateBlip, 1.0)
    SetBlipColour(crateBlip, 2)
    SetBlipAsShortRange(crateBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Cayo Crate')
    EndTextCommandSetBlipName(crateBlip)

    while true do 
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        if #(playerCoords - caseLocation) < 5 then 
            drawText('[~r~E~w~] To open crate', caseLocation)

            if IsControlJustPressed(0, 38) then
                local skillcheck = startMinigame()
                if skillcheck then  
                    lib.notify({
                        title = 'Crate',
                        description = 'You have successfully started the crate timer',
                        type = 'success'
                    })
                    if sConfig['timer'] == false then
                        TriggerServerEvent('corrupt-cases:openCase')
                    else 
                        TriggerServerEvent('corrupt-cases:startCountdownTimer', caseLocation)
                        break
                    end
                else 
                    lib.notify({
                        title = 'Crate',
                        description = 'You have failed to open the crate',
                        type = 'error'
                    })
                end
            end
        end

        if not caseLocation or caseLocation == nil then 
            break 
        end
    end
end)

RegisterNetEvent('corrupt-cases:cleanupCase', function()
    -- one of these work...
    DeleteEntity(crate)
    DeleteObject(crate)
    -- delete da blip
    RemoveBlip(crateBlip)
    caseLocation = nil
end)

if config['enableTeleporter'] == true then 
    CreateThread(function()

        setupTeleporterBlips()

        while true do
            Wait(0)

            local playerCoords = GetEntityCoords(PlayerPedId())

            if #(playerCoords - config['teleporterStart']) < 5 then 
                drawText('[~r~E~w~] To Teleport to Cayo Perico', config['teleporterStart'])
                DrawMarker(
                    config['teleportMarker'].Type,
                    config['teleporterStart'].x,
                    config['teleporterStart'].y,
                    config['teleporterStart'].z,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    config['teleportMarker'].Size,
                    config['teleportMarker'].Size,
                    config['teleportMarker'].Size,
                    config['teleportMarker'].Color.Red,
                    config['teleportMarker'].Color.Green,
                    config['teleportMarker'].Color.Blue,
                    config['teleportMarker'].Color.Alpha,
                    false,
                    true,
                    2,
                    nil,
                    nil,
                    nil,
                    false
                )

                if IsControlJustReleased(0, 38) then 
                    DoScreenFadeOut(1000)
                    Wait(1000)
                    SetEntityCoords(PlayerPedId(), config['teleportFinish'].x, config['teleportFinish'].y, config['teleportFinish'].z)
                    DoScreenFadeIn(5000)
                end

            elseif #(playerCoords - config['teleportFinish']) < 5 then
                drawText('[~r~E~w~] To Teleport back to the Island', config['teleportFinish'])
                DrawMarker(
                    config['teleportMarker'].Type,
                    config['teleporterStart'].x,
                    config['teleporterStart'].y,
                    config['teleporterStart'].z,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    config['teleportMarker'].Size,
                    config['teleportMarker'].Size,
                    config['teleportMarker'].Size,
                    config['teleportMarker'].Color.Red,
                    config['teleportMarker'].Color.Green,
                    config['teleportMarker'].Color.Blue,
                    config['teleportMarker'].Color.Alpha,
                    false,
                    true,
                    2,
                    nil,
                    nil,
                    nil,
                    false
                )

                if IsControlJustReleased(0, 38) then 
                    DoScreenFadeOut(1000)
                    Wait(1000)
                    SetEntityCoords(PlayerPedId(), config['teleporterStart'].x, config['teleporterStart'].y, config['teleporterStart'].z)
                    DoScreenFadeIn(1000)
                end
            else 
                Wait(1500)
            end
        end
    end)
end

if sConfig['vehicle'].enabled then
    CreateThread(function() 
        while true do
            Wait(0)

            local playerCoords = GetEntityCoords(PlayerPedId())

            if #(playerCoords - sConfig['vehicle'].textCoords) < 5 then 
                drawText('[~r~E~w~] To spawn a vehicle', sConfig['vehicle'].textCoords)

                if IsControlJustReleased(0, 38) then 
                    if sConfig['vehicle'].costs == true then 
                        local costSuccess = lib.callback.await('corrupt-cases:removeDeposit')

                        if costSuccess then 
                            if vehicle ~= nil then 
                                DeleteVehicle(vehicle)
                            end
        
                            local ModelHash = sConfig['vehicle'].model
                            if not IsModelInCdimage(ModelHash) then return end
                
                            RequestModel(ModelHash) -- Request the model
                            while not HasModelLoaded(ModelHash) do -- Waits for the model to load
                                Wait(0)
                            end
        
                            vehicle = CreateVehicle(ModelHash, sConfig['vehicle'].spawnCoords.x, sConfig['vehicle'].spawnCoords.y, sConfig['vehicle'].spawnCoords.z, sConfig['vehicle'].spawnCoords.h, true, false)
        
                            SetModelAsNoLongerNeeded(ModelHash)
                            SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                            Wait(5000)
                        end
                    else 
                        if vehicle ~= nil then 
                            DeleteVehicle(vehicle)
                        end
    
                        local ModelHash = sConfig['vehicle'].model
                        if not IsModelInCdimage(ModelHash) then return end
            
                        RequestModel(ModelHash) -- Request the model
                        while not HasModelLoaded(ModelHash) do -- Waits for the model to load
                            Wait(0)
                        end
    
                        vehicle = CreateVehicle(ModelHash, sConfig['vehicle'].spawnCoords.x, sConfig['vehicle'].spawnCoords.y, sConfig['vehicle'].spawnCoords.z, sConfig['vehicle'].spawnCoords.h, true, false)
    
                        SetModelAsNoLongerNeeded(ModelHash)
                        SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                        Wait(5000)
                    end
                end
            elseif #(playerCoords - sConfig['vehicle'].deleteVehicleCoord) < 7 and IsPedInAnyVehicle(PlayerPedId()) then 
                drawText('[~r~E~w~] To delete vehicle', sConfig['vehicle'].deleteVehicleCoord)

                if IsControlJustPressed(0, 38) then 
                    local removalVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    DeleteEntity(removalVehicle)
                end

            else 
                Wait(1500)
            end
        end
    end) 
end

if sConfig['greenZone'] then 
    CreateThread(function()
        lib.zones.box({
            coords = config['teleportFinish'],
            size = vec3(sConfig['greenZoneRadius'], sConfig['greenZoneRadius'], sConfig['greenZoneRadius']),
            onEnter = function()
                SetEntityInvincible(PlayerPedId(), true)
            end,
            onExit = function()
                SetEntityInvincible(PlayerPedId(), false)
            end,
            debug = false
        })
    end)
end