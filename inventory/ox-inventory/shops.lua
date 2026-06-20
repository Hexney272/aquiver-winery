return {
    Winery = {
        name = 'Winery Store',
        blip = {
            id = 277,
            colour = 48,
            scale = 0.8
        },
        inventory = {
            { name = 'winery_furmint_wine',     price = 15 },
            { name = 'winery_merlot_wine',      price = 15 },
            { name = 'winery_generosa_wine',    price = 15 },
            { name = 'winery_portugieser_wine', price = 15 },
        },
        locations = {
            vector3(-1924.633, 2051.351, 140.832),
        },
        targets = {
            {
                ped = `mp_m_shopkeep_01`,
                scenario = 'WORLD_HUMAN_AA_COFFEE',
                loc = vec3(-1924.633, 2051.351, 140.832),
                heading = 258.1,
            },
        }
    }
}
