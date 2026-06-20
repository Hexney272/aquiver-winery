local state = GetResourceState("es_extended")

if state ~= "started" and state ~= "starting" then
    return
end

print("ESX framework recognized.")

local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterCommand("winery_create", "admin",
    function(xPlayer, args)
        local playerPed = GetPlayerPed(xPlayer.source)
        local coords = GetEntityCoords(playerPed) + vector3(0, 0, -1)
        local price = args.price
        local name = args.name

        exports[GetCurrentResourceName()]:insertInstance(coords.x, coords.y, coords.z, price, name)
    end,
    false,
    {
        arguments = {
            {
                name = 'price',
                help = 'Price',
                type = 'number'
            },
            {
                name = 'name',
                help = 'Name',
                type = 'string'
            }
        }
    }
)

ESX.RegisterCommand("winery_remove", "admin",
    function(xPlayer, args)
        local id = args.id

        exports[GetCurrentResourceName()]:removeInstance(id)
    end,
    false,
    {
        arguments = {
            { name = 'id', help = 'ID', type = 'number' }
        }
    }
)
