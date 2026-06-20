local Barrel = require("lua.client.Barrel.Barrel")
local Config = require("lua.shared.Config")
local eStum = require("lua.shared.enums.eStum")
local eBarrelMaterial = require("lua.shared.enums.eBarrelMaterial")
local eWarehouse = require("lua.shared.enums.eWarehouse")
local WarehouseService = require("lua.client.Warehouse.WarehouseService")
local MaterialBarrel = require("lua.shared.data.MaterialBarrel")

local BarrelService = {}
---@type table<number, C_Barrel>
BarrelService._entities = {}
BarrelService._tickState = false

---@param data IBarrel
function BarrelService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = Barrel:new(data.id, data.material, data.position, data.rotation)

        self._entities[entity:getId()] = entity
    end

    entity:setMaterial(data.material)
    entity:setDurability(data.durability)
    entity:setPlacementState(data.placementState)
    entity:setLockedState(data.lockedState)

    entity:getStum():setContent(data.stum.id)
    entity:getStum():setVolume(data.stum.volume)
    entity:getStum():setQualityPercentage(data.stum.quality)
    entity:getStum():setProgressPercentage(data.stum.progress)
    entity:getStum():setConditionPercentage(data.stum.condition)
    entity:getStum():setSpeedModifier(data.stum.speedModifier)
end

function BarrelService:get(id)
    return self._entities[id]
end

function BarrelService:getAll()
    return self._entities
end

function BarrelService:onEnteringInstance()
    if not self._tickState then
        self._tickState = true

        Citizen.CreateThread(function()
            while self._tickState do
                self:onTick()

                Citizen.Wait(0)
            end
        end)
    end
end

function BarrelService:onLeavingInstance()
    self._tickState = false

    for k, v in pairs(self._entities) do
        v:destroy()
    end

    self._entities = {}
end

---@param entity C_Barrel
function BarrelService:openCreateMenu(entity)
    ---@type ContextMenuItem[]
    local options = {}

    for _, material in pairs(eBarrelMaterial) do
        options[#options + 1] = {
            title = material,
            description = locale("YOU_HAVE_IN_STORAGE", WarehouseService:getCount(MaterialBarrel[material])),
            icon = ("nui://%s/images/%s.png"):format(GetCurrentResourceName(), material),
            onSelect = function()
                lib.callback.await(
                    "Winery::Barrel::Insert",
                    false,
                    entity:getId(),
                    material
                )
            end
        }
    end

    lib.registerContext({
        id = "barrel_setup",
        title = "Setup",
        options = options
    })

    lib.showContext("barrel_setup")
end

---@param entity C_Barrel
function BarrelService:openMenu(entity)
    ---@type ContextMenuItem[]
    local stumOptions = {}

    for _, stum in pairs(eStum) do
        local itemCount = exports["aquiver_cfx"]:GetInventoryItemCount(
            Config.STUM[stum]
        )

        stumOptions[#stumOptions + 1] = {
            title = locale(stum),
            description = locale("BARREL_ADD_STUM_SUB", itemCount),
            icon = ("nui://%s/txd/%s.png"):format(GetCurrentResourceName(), stum),
            disabled = not (entity:getStum():isEmpty() or entity:getStum():getContent() == stum),
            onSelect = function()
                local input = lib.inputDialog(locale("BARREL_ADD_STUM"), {
                    {
                        type = 'slider',
                        label = locale("QUANTITY"),
                        min = 1,
                        max = entity:getStum():getEmptyVolumeCount()
                    }
                })

                if input then
                    local count = input[1]

                    TriggerServerEvent(
                        "Winery::Barrel::AddStum",
                        entity:getId(),
                        stum,
                        count
                    )
                end
            end
        }
    end

    lib.registerContext({
        id = "barrel_stum_selection",
        title = locale("BARREL_ADD_STUM"),
        menu = "barrel",
        options = stumOptions
    })

    lib.registerContext({
        id = "barrel_additives",
        title = locale("BARREL_ADDITIVES"),
        menu = "barrel",
        options = {
            {
                title = locale("BARREL_ADD_PECTINASE"),
                description = locale("BARREL_ADD_PECTINASE_DESCRIPTION"),
                icon = 'hand',
                disabled = not entity:getLockedState(),
                onSelect = function()
                    TriggerServerEvent("Winery::Barrel::AddPectinase", entity:getId())
                end
            },
            {
                title = locale("BARREL_ADD_YEAST"),
                description = locale("BARREL_ADD_YEAST_DESCRIPTION"),
                icon = 'hand',
                disabled = not entity:getLockedState(),
                onSelect = function()
                    TriggerServerEvent("Winery::Barrel::AddYeast", entity:getId(), eWarehouse.YEAST)
                end
            },
            {
                title = locale("BARREL_ADD_TURBO_YEAST"),
                description = locale("BARREL_ADD_TURBO_YEAST_DESCRIPTION"),
                icon = 'hand',
                disabled = not entity:getLockedState(),
                onSelect = function()
                    TriggerServerEvent("Winery::Barrel::AddYeast", entity:getId(), eWarehouse.TURBO_YEAST)
                end
            },
            {
                title = locale("BARREL_ADD_PREMIUM_YEAST"),
                description = locale("BARREL_ADD_PREMIUM_YEAST_DESCRIPTION"),
                icon = 'hand',
                disabled = not entity:getLockedState(),
                onSelect = function()
                    TriggerServerEvent("Winery::Barrel::AddYeast", entity:getId(), eWarehouse.PREMIUM_YEAST)
                end
            },
        }
    })

    local repairMeta = {}

    for k, v in pairs(entity:getRepairMaterials()) do
        repairMeta[#repairMeta + 1] = {
            label = locale(k),
            value = v
        }
    end

    lib.registerContext({
        id = "barrel_manage",
        title = locale("CONTEXTMENU_MANAGE"),
        menu = "barrel",
        options = {
            {
                title = locale("CONTEXTMENU_TOOL_REPAIR"),
                description = locale("CONTEXTMENU_TOOL_REPAIR_DESCRIPTION", entity:getDurability()),
                icon = 'wrench',
                progress = entity:getDurability(),
                colorScheme = "#ff6b6b",
                metadata = repairMeta,
                onSelect = function()
                    local response = lib.alertDialog({
                        header = locale("DIALOG_REPAIR_TITLE"),
                        content = locale("DIALOG_REPAIR_DESCRIPTION"),
                        centered = true,
                        cancel = true
                    })

                    if response == 'confirm' then
                        TriggerServerEvent("Winery::Barrel::Repair", entity:getId())
                    end
                end
            },
            {
                title = locale("BARREL_CLEAN"),
                description = locale("BARREL_CLEAN_DESCRIPTION"),
                icon = 'soap',
                onSelect = function()
                    local response = lib.alertDialog({
                        header = locale("BARREL_CLEAN_DIALOG_TITLE"),
                        content = locale("BARREL_CLEAN_DIALOG_DESCRIPTION"),
                        centered = true,
                        cancel = true
                    })

                    if response == 'confirm' then
                        TriggerServerEvent("Winery::Barrel::Clean", entity:getId())
                    end
                end
            },
            {
                title = locale("CONTEXTMENU_REMOVE"),
                description = locale("CONTEXTMENU_REMOVE_DESCRIPTION"),
                icon = 'cancel',
                onSelect = function()
                    local response = lib.alertDialog({
                        header = locale("DIALOG_REMOVE_TITLE"),
                        content = locale("DIALOG_REMOVE_DESCRIPTION"),
                        centered = true,
                        cancel = true
                    })

                    if response == "confirm" then
                        TriggerServerEvent("Winery::Barrel::Remove", entity:getId())
                    end
                end
            },
        }
    })

    lib.registerContext({
        id = 'barrel',
        title = ('(%s) Barrel (%d)'):format(entity:getMaterial(), entity:getId()),
        options = {
            {
                title = locale("CONTEXTMENU_MANAGE"),
                description = locale("CONTEXTMENU_MANAGE_DESCRIPTION"),
                icon = "layer-group",
                arrow = true,
                menu = "barrel_manage",
            },
            {
                title = locale("BARREL_ADD_STUM"),
                description = locale("BARREL_ADD_STUM_DESCRIPTION"),
                icon = "fill-drip",
                arrow = true,
                menu = "barrel_stum_selection",
                disabled = (
                    entity:getLockedState() or
                    entity:getStum():getVolume() >= entity:getCapacity()
                )
            },
            {
                title = locale("BARREL_START"),
                description = locale("BARREL_START_DESCRIPTION"),
                icon = "hourglass-start",
                iconAnimation = entity:getLockedState() and "spin" or nil,
                disabled = entity:getLockedState() or entity:getStum():isEmpty(),
                onSelect = function()
                    TriggerServerEvent("Winery::Barrel::Start", entity:getId())
                end
            },
            {
                title = locale("BARREL_ADDITIVES"),
                description = locale("BARREL_ADDITIVES_DESCRIPTION"),
                icon = "flask-vial",
                arrow = true,
                menu = "barrel_additives",
                disabled = not entity:getLockedState()
            },
            {
                title = locale("BARREL_COLLECT"),
                description = locale("BARREL_COLLECT_DESCRIPTION"),
                icon = 'hand-holding-droplet',
                colorScheme = "red",
                disabled = entity:getStum():getProgressPercentage() < 100,
                onSelect = function()
                    local response = lib.alertDialog({
                        header = locale("BARREL_COLLECT_DIALOG_TITLE"),
                        content = locale("BARREL_COLLECT_DIALOG_DESCRIPTION"),
                        centered = true,
                        cancel = true
                    })

                    if response == 'confirm' then
                        TriggerServerEvent("Winery::Barrel::Collect", entity:getId())
                    end
                end
            },
            {
                title = locale("BARREL_CAPACITY"),
                description = locale("BARREL_CAPACITY_DESCRIPTION",
                    entity:getStum():getVolume(),
                    entity:getCapacity(),
                    locale(entity:getStum():getContent())
                ),
                icon = 'cubes',
                progress = (entity:getStum():getVolume() / entity:getCapacity()) * 100,
                colorScheme = "#fcc2d7"
            },
            {
                title = locale("BARREL_PROGRESS"),
                description = locale("BARREL_PROGRESS_DESCRIPTION",
                    entity:getStum():getProgressPercentage()
                ),
                icon = 'spinner',
                iconAnimation = entity:getLockedState() and "spin" or nil,
                progress = entity:getStum():getProgressPercentage(),
                colorScheme = "#ffc078"
            },
            {
                title = locale("BARREL_QUALITY"),
                description = locale("BARREL_QUALITY_DESCRIPTION",
                    entity:getStum():getQualityPercentage()
                ),
                icon = 'star-half-stroke',
                progress = entity:getStum():getQualityPercentage(),
                colorScheme = "#b2f2bb"
            },
            {
                title = locale("BARREL_CONDITION"),
                description = locale("BARREL_CONDITION_DESCRIPTION",
                    entity:getStum():getConditionPercentage()
                ),
                icon = 'temperature-arrow-down',
                progress = entity:getStum():getConditionPercentage(),
                colorScheme = "#66d9e8"
            },
        }
    })

    lib.showContext('barrel')
end

function BarrelService:onTick()
    local localPed = PlayerPedId()
    local localPos = GetEntityCoords(localPed)

    for _, entity in pairs(self._entities) do
        local entityPosition = entity:getPosition()
        local distanceTo = #(localPos - entityPosition)

        if distanceTo < 3.0 then
            if not entity:getPlacementState() then
                Graphics:drawInteractive3D(
                    entityPosition,
                    0.025,
                    function()
                        self:openCreateMenu(entity)
                    end,
                    { "aquiver_winery", "hammer", 0.55, { 255, 255, 255, 255 } }
                )
            else
                local isFound, screenX, screenY = GetScreenCoordFromWorldCoord(
                    entityPosition.x,
                    entityPosition.y,
                    entityPosition.z + 1.25
                )
                local spacing = 0.015

                DrawSpriteMeter(
                    "aquiver_winery",
                    "barrel_condition",
                    screenX - spacing,
                    screenY,
                    0.025,
                    0.025,
                    entity:getStum():getConditionPercentage() / 100,
                    { 102, 217, 232, 200 }
                )
                DrawSpriteMeter(
                    "aquiver_winery",
                    "avp_winery_progress",
                    screenX,
                    screenY,
                    0.035,
                    0.035,
                    entity:getStum():getProgressPercentage() / 100,
                    { 255, 255, 255, 200 }
                )
                DrawSpriteMeter(
                    "aquiver_winery",
                    "avp_winery_quality",
                    screenX + spacing,
                    screenY,
                    0.025,
                    0.025,
                    entity:getStum():getQualityPercentage() / 100,
                    { 255, 255, 255, 200 }
                )

                Graphics:drawInteractive3D(
                    entity:getPosition(),
                    0.025,
                    function()
                        self:openMenu(entity)
                    end,
                    { "aquiver_winery", "cog", 0.75, { 255, 255, 255, 255 } }
                )
            end
        end
    end
end

return BarrelService
