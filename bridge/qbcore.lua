local state = GetResourceState("qb-core")

if state ~= "started" and state ~= "starting" then
    return
end

print("QBCore framework recognized.")

local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('winery_create', 'Creates new instance at your local ped position',
    {
        { name = 'price', help = 'Price' },
        { name = 'name',  help = 'Name' },
    }, true, function(source, args)
        local ped = GetPlayerPed(source)
        local coords = GetEntityCoords(ped) + vector3(0, 0, -1)

        local price = tonumber(args[1])
        local name = args[2]

        if not name or not price then
            return
        end

        local x, y, z = table.unpack(coords)

        exports[GetCurrentResourceName()]:insertInstance(x, y, z, price, name)
    end, 'admin'
)

QBCore.Commands.Add("winery_remove", "Removes an instance", {
    { name = 'id', help = 'ID' },
}, true, function(source, args)
    local id = tonumber(args[1])

    if not id then
        return
    end

    exports[GetCurrentResourceName()]:removeInstance(id)
end)
