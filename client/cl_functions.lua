local config = require ('config.cl_config')
local sConfig = require ('config.sh_config')
local timer = 999

setupCrate = function(model, coords)
    local crate = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    FreezeEntityPosition(crate, true)

    return crate
end

drawText = function(msg, coords)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z + 1)

    if onScreen then
        SetTextScale(0.4, 0.4)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(msg)
        DrawText(_x, _y)
    end
end

startMinigame = function() -- if you want to incorporate a different minigame, ensure it returns 'true' to pass
    local success = lib.skillCheck({'easy', 'medium', 'hard'}, {'w', 'a', 's', 'd'})

    return success 
end

setupTeleporterBlips = function() -- Feel free to change
    local teleportTo = AddBlipForCoord(config['teleporterStart'])
    SetBlipSprite(teleportTo, 36)
    SetBlipDisplay(teleportTo, 4)
    SetBlipScale(teleportTo, 0.7)
    SetBlipColour(teleportTo, 2)
    SetBlipAsShortRange(teleportTo, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Teleport to Cayo Perico')
    EndTextCommandSetBlipName(teleportTo)

    local teleportFrom = AddBlipForCoord(config['teleportFinish'])
    SetBlipSprite(teleportFrom, 36)
    SetBlipDisplay(teleportFrom, 4)
    SetBlipScale(teleportFrom, 0.7)
    SetBlipColour(teleportFrom, 2)
    SetBlipAsShortRange(teleportFrom, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Teleport to Main Island')
    EndTextCommandSetBlipName(teleportFrom)
end

startCountdownTimer = function(caseCoords)
    timer = sConfig['timerLength'] * 1000
    while true do
        Wait(0)
        timer = timer - 1

        if timer == 0 or timer < 0 then 
            TriggerServerEvent('corrupt-cases:openCase', caseCoords)
            break 
        end

        local pCoords = GetEntityCoords(PlayerPedId())
        if #(pCoords - caseCoords) < 10 then 
            drawText('~r~' .. math.floor(timer / 1000) .. '~w~ seconds left till crate opens', caseCoords)
        end

    end
end 

RegisterNetEvent('corrupt-cayo:startTimerClient', function(caseLocation)
    startCountdownTimer(caseLocation)
end)
