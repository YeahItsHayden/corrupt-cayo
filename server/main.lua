local config = require 'config/sv_config'
local sConfig = require ('config.sh_config')

local cases = {}

table.contains = function(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- This is a ChatGPT function
-- I am bad at math so im not sure what it really does tbh
getRandomRewards = function()
    local results = {}
    local weightedPool = {}

    -- Build weighted list
    for _, reward in ipairs(config.rewards) do
        for i = 1, reward.chance do
            table.insert(weightedPool, reward)
        end
    end

    -- Pick up to 5 unique rewards
    local selectedItems = {}
    while #results < 5 and #weightedPool > 0 do
        local index = math.random(1, #weightedPool)
        local picked = weightedPool[index]

        -- Ensure uniqueness
        if not selectedItems[picked.item] then
            local count = math.random(picked.min, picked.max)
            table.insert(results, { item = picked.item, count = count })
            selectedItems[picked.item] = true
        end

        -- Remove all entries for this item from pool to avoid duplicates
        for i = #weightedPool, 1, -1 do
            if weightedPool[i].item == picked.item then
                table.remove(weightedPool, i)
            end
        end
    end

    -- Fallback if nothing selected
    if #results == 0 then
        local fallback = config.rewards[math.random(1, #config.rewards)]
        local count = math.random(fallback.min, fallback.max)
        table.insert(results, { item = fallback.item, count = count })
    end

    return results
end

-- return case location n stuff
lib.callback.register('corrupt-cases:getCaseLocation', function(source)
    math.randomseed(os.time())
    local indexTable = math.random(1, #config['crate_spawns'])
    local caseLocation = config['crate_spawns'][indexTable]

    return caseLocation
end)

-- TODO: Add distance check here
RegisterNetEvent('corrupt-cases:openCase', function(caseCoords)
    if cases[1] then
        math.randomseed(os.time())
        if not sConfig['timer'] and source then
            -- Case Rewards
            local rewards = getRandomRewards()

            -- iterate through to get rewards
            for k,v in pairs(rewards) do 
                exports.ox_inventory:AddItem(source, v.item, v.count)
            end
            -- reset table
            cases = {}

            globalNotify('The crate has been opened!')
            lib.logger(source, 'CayoCrate', "Player with id " .. source .. " has open a crate.")
            -- will delete case and break any loops running
            TriggerClientEvent('corrupt-cases:cleanupCase', -1)
        elseif sConfig['timer'] then 
            local player = lib.getClosestPlayer(caseCoords, 20, true)

            -- Case Rewards
            local rewards = getRandomRewards()

            -- iterate through to get rewards
            for k,v in pairs(rewards) do 
                exports.ox_inventory:AddItem(player, v.item, v.count)
            end
            -- reset table
            cases = {}

            globalNotify('The crate has been opened!')
            lib.logger(player, 'CayoCrate', "Player with id " .. player .. " has opened a crate.")
            -- will delete case and break any loops running
            TriggerClientEvent('corrupt-cases:cleanupCase', -1)
        end
    else
        lib.logger(source, 'CayoCrate', "Player opened a crate without one being spawned - most likely a hacker.")
    end
end)

-- Handle Crate Drop Logic 
RegisterNetEvent('corrupt-cases:createDrop', function()
    if source then 
        lib.logger(source, 'CayoCrate', "Player has spawned crate - hacking (or admin)")
    end

    globalNotify('A Crate has dropped on Cayo Perico! Be the first to get it for cool rewards!')
    cases[#cases + 1] = 1
    TriggerClientEvent('corrupt-cases:spawnCase', -1)
end)

-- Admin command to spawn crate
lib.addCommand('spawnCrate', {
    help = 'Force Spawn A Cayo Perico Crate',
    restricted = 'group.admin'
}, function(souirce, args)
    TriggerEvent('corrupt-cases:createDrop')
end)

-- Thread to handle case creation at set times
Citizen.CreateThread(function()
    if config['setTimes'] == true then
        local scheduledTimes = config['spawnTimes']
        local lastTriggeredHour = nil
        local warnedHours = {}

        while true do
            Wait(1000)

            local currentTime = os.date("*t")
            local currentHour = currentTime.hour
            local currentMinute = currentTime.min
            local currentSecond = currentTime.sec

            -- Only run logic at the start of a minute
            if currentSecond == 0 then
                -- 15-minute warning
                for _, hour in ipairs(scheduledTimes) do
                    if currentHour == (hour - 1) and currentMinute == 45 and not warnedHours[hour] then
                        warnedHours[hour] = true
                        globalNotify('A crate will drop in 15 minutes!')
                    end
                end

                -- Trigger drop at exact time
                if table.contains(scheduledTimes, currentHour) and currentMinute == 0 and lastTriggeredHour ~= currentHour then
                    lastTriggeredHour = currentHour
                    warnedHours[currentHour] = nil -- Reset warning for this hour
                    TriggerEvent('corrupt-cases:createDrop')
                end

                -- Reset lastTriggeredHour if the hour has passed
                if lastTriggeredHour and lastTriggeredHour ~= currentHour then
                    lastTriggeredHour = nil
                end
            end
        end
    end
end)

-- Countdown timer to open crate 
RegisterNetEvent('corrupt-cases:startCountdownTimer', function(caseLocation)
    TriggerClientEvent('corrupt-cayo:startTimerClient', -1, caseLocation)
end)
