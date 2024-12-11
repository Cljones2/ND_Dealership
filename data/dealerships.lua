return {
    ["PDM"] = {
        showroomCategories = {"Coupes", "Muscle", "Classics", "Sports", "super"},
        categories = {"Compacts", "Sedans", "SUVs", "Coupes", "Muscle", "Classics", "Sports", "super", "Motorcycles", "Off-Road", "Vans"},
        blip = {
            coords = vec3(-56.59, -1098.67, 26.42),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "Premium Deluxe Motorsports",
        },
        groups = {
            ["default"] = {
                switch = true,
                testdrive = false,
                purchase = true,
                interact = true,
                blip = true
            }
        },
        interact = {
            pedModel = `cs_siemonyetarian`,
            pedCoords = vec4(-57.19, -1098.90, 26.42, 17.27),
            vehicleCoords = vec4(405.13, -957.99, -99.54, 156.02)
        },
        showroomLocations = {
            vec4(-47.12, -1102.36, 25.78, 268.31),
            vec4(-42.63, -1095.90, 26.11, 120.56),
            vec4(-47.57, -1093.96, 26.11, 117.36),
            vec4(-36.96, -1101.80, 26.33, 157.99)
        },
        spawns = {
            vector4(-14.16, -1108.17, 26.20, 282.01),
            vector4(-12.82, -1105.19, 26.20, 282.08),
            vector4(-11.70, -1102.36, 26.20, 280.18),
            vector4(-10.60, -1099.58, 26.20, 280.60),
            vector4(-9.77, -1096.74, 26.20, 280.28),
            vector4(-8.10, -1081.52, 26.21, 124.82),
            vector4(-11.14, -1080.48, 26.20, 125.45),
            vector4(-47.71, -1116.63, 25.96, 1.28),
            vector4(-50.64, -1116.85, 25.96, 1.26),
            vector4(-53.53, -1116.77, 25.96, 0.48),
            vector4(-56.33, -1116.96, 25.96, 2.03)
        }
    },
    
    ["LSIA Plane Dealer"] = {
        categories = {"planes"},
        blip = {
            coords = vec3(-950.53, -3056.26, 13.95),
            sprite = 523,
            color = 3,
            scale = 0.8,
            label = "LSIA Plane Dealer",
        },
        interact = {
            pedModel = `csb_trafficwarden`,
            pedCoords = vec4(-950.53, -3056.26, 13.95, 62.97),
            vehicleCoords = vec4(-964.23, -2984.09, 14.78, 59.78)
        },
        spawns = {
            vec4(-964.23, -2984.09, 14.78, 59.78),
            vec4(-1064.22, -2919.28, 14.79, 181.29)
        }
    }
}
