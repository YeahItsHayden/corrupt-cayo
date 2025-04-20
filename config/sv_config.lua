return {
    ['crate_spawns'] = { -- where the crate will drop - choose wherever, add as many locations as u want
        vec3(4812.5, -4301.32, 4.33),
        vec3(5167.17, -4704.37, 2.17),
        vec3(5595.52, -5214.16, 13.33),
        vec3(5476.21, -5832.69, 19.22),
        vec3(4980.65, -5870.02, 18.81)
    },
    ['setTimes'] = true, -- Wether or not to have set spawn times of the crate, keep as true for now
    ['spawnTimes'] = { -- Add as many times as you want here, 24 hour format
        11, -- 11 am
        18, -- 6pm
        20, -- 8pm
        23, -- 11pm
        1 -- 1am
    },
    ['globalNotify'] = true, -- notify everyone on the server about the crate
    -- Rewards for the loot crates
    -- Add as many things as you want here
    ['rewards'] = {
       {item = 'weapon_assaultrifle', min = 1, max = 2, chance = 10}, --- 10% chance
    },
}