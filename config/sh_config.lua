return {
    ['framework'] = 'qbx', -- This just handles money stuff, current values: qbx/esx
    ['vehicle'] = { -- vehicle settings for cayo
        enabled = true, -- wether or not to have vehicle rental on the island?
        costs = false, -- Does it cost money to spawn a vehicle?
        amount = 500, -- If true to the above, how much?
        model = `glendale`, -- vehicle to spawn
        textCoords = vec3(4433.85, -4485.11, 3.3), -- where the text is to spawn a vehicle
        spawnCoords = vec4(4439.33, -4490.94, 4.22, 291.96), -- where to spawn the vehicle
        deleteVehicleCoord = vec3(4467.36, -4473.39, 3.93), -- where the user can delete their vehicle
    }, 
}