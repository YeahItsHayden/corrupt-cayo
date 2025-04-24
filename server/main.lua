local config = require 'config/sv_config'
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
    math.randomseed(os.time())
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

RegisterNetEvent('corrupt-cases:openCase', function()
    if cases[1] and source then
        -- Case Rewards
        local rewards = getRandomRewards()

        -- iterate through to get rewards
        for k,v in pairs(rewards) do 
            exports.ox_inventory:AddItem(source, v.item, v.count)
        end
        -- reset table
        cases = {}

        globalNotify('A team has grabbed the crate!')
        lib.logger(source, 'CayoCrate', "Player with id " .. source .. " has open a crate.")
        -- will delete case and break any loops running
        TriggerClientEvent('corrupt-cases:cleanupCase', -1)
    else
        lib.logger(source, 'CayoCrate', "Player opened a crate without one being spawned - most likely a hacker.")
    end
end)

-- Handle Crate Drop Logic 
RegisterNetEvent('corrupt-cases:createDrop', function()
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

        while true do
            Wait(1000)

            local currentTime = os.date("*t")
            local currentHour = currentTime.hour
            local currentMinute = currentTime.min

            -- Check if the current hour matches a scheduled time and hasn't been triggered yet
            if table.contains(scheduledTimes, currentHour) and currentMinute == 0 and lastTriggeredHour ~= currentHour then
                lastTriggeredHour = currentHour 
                TriggerEvent('corrupt-cases:createDrop')
            end

            -- Reset lastTriggeredHour if the hour has passed
            if lastTriggeredHour and lastTriggeredHour ~= currentHour then
                lastTriggeredHour = nil
            end
        end
    end
end)
