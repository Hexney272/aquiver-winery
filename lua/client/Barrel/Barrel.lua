local Stum = require("lua.client.Barrel.Stum")
local BarrelMaterialHash = require("lua.shared.data.BarrelMaterialHash")
local eBarrelMaterial = require("lua.shared.enums.eBarrelMaterial")
local Config = require("lua.shared.Config")

---@class C_Barrel : OxClass
---@field private _id number
---@field private _material eBarrelMaterial
---@field private _position vector3
---@field private _rotation vector3
---@field private _stum C_Stum
---@field private _placementState boolean
---@field private _durability number
---@field private _lockedState boolean
---@field private _entity number
---@field private _attachedEntity number
local Barrel = lib.class("C_Barrel")

---@param id number
---@param material eBarrelMaterial
---@param position vector3
---@param rotation vector3
function Barrel:constructor(id, material, position, rotation)
    self._id = id
    self._material = material
    self._position = position
    self._rotation = rotation
    self._stum = Stum:new()
    self._durability = 0.0
    self._placementState = false
    self._lockedState = false

    self._entity = CreateObjectNoOffset(
        BarrelMaterialHash[self._material],
        position.x,
        position.y,
        position.z,
        false,
        false,
        false
    )
    FreezeEntityPosition(self._entity, true)
    SetEntityRotation(self._entity, rotation.x, rotation.y, rotation.z, 2, false)

    self._attachedEntity = -1
end

function Barrel:getId()
    return self._id
end

function Barrel:getEntity()
    return self._entity
end

function Barrel:getPosition()
    return self._position
end

function Barrel:getRotation()
    return self._rotation
end

function Barrel:getEntityPosition()
    return GetEntityCoords(self._entity)
end

function Barrel:getRepairMaterials()
    return Config.REPAIR[self._material]
end

function Barrel:getCapacity()
    return Config.BARREL_STUM_CAPACITY
end

function Barrel:setMaterial(material)
    self._material = material

    local entity = CreateObjectNoOffset(
        BarrelMaterialHash[self._material],
        self._position.x,
        self._position.y,
        self._position.z,
        false,
        false,
        false
    )
    FreezeEntityPosition(entity, true)
    SetEntityRotation(entity, self._rotation.x, self._rotation.y, self._rotation.z, 2, false)

    if DoesEntityExist(self._entity) then
        DeleteObject(self._entity)
    end

    self._entity = entity
end

function Barrel:getMaterial()
    return self._material
end

function Barrel:getLockedState()
    return self._lockedState
end

function Barrel:setLockedState(newState)
    self._lockedState = newState

    local modelHash = ""
    local offsetPosition = vector3(0, 0, 0)
    local offsetRotation = vector3(0, 0, 0)

    if self._material == eBarrelMaterial.PLASTIC then
        if self:getLockedState() then
            modelHash = "avp_winery_prop_fermenter_barrel_01_top_close"
        else
            modelHash = "avp_winery_prop_fermenter_barrel_01_top_open"
        end

        offsetPosition = vector3(0, 0, 0)
        offsetRotation = vector3(0, 0, 0)
    elseif self._material == eBarrelMaterial.STEEL then
        if self:getLockedState() then
            modelHash = "avp_winery_prop_fermenter_barrel_02_top_close"
        else
            modelHash = "avp_winery_prop_fermenter_barrel_02_top_open"
        end

        offsetPosition = vector3(0, 0, 0)
        offsetRotation = vector3(0, 0, 0)
    end

    if DoesEntityExist(self._attachedEntity) then
        DeleteObject(self._attachedEntity)
    end

    if self:getPlacementState() then
        self._attachedEntity = CreateObject(
            modelHash,
            0,
            0,
            0,
            false,
            false,
            false
        )

        AttachEntityToEntity(
            self._attachedEntity,
            self._entity,
            -1,
            offsetPosition.x,
            offsetPosition.y,
            offsetPosition.z,
            offsetRotation.x,
            offsetRotation.y,
            offsetRotation.z,
            false,
            false,
            true,
            false,
            2,
            true
        )
    end
end

function Barrel:getPlacementState()
    return self._placementState
end

function Barrel:setPlacementState(newState)
    self._placementState = newState

    SetEntityAlpha(self._entity, self._placementState and 255 or 0, false)
    SetEntityAlpha(self._attachedEntity, self._placementState and 255 or 0, false)
    SetEntityCollision(self._entity, self._placementState, true)
    SetEntityCollision(self._attachedEntity, self._placementState, true)
end

function Barrel:getDurability()
    return self._durability
end

function Barrel:setDurability(durability)
    self._durability = durability
end

function Barrel:getStum()
    return self._stum
end

function Barrel:hasStum()
    return self._stum ~= nil
end

function Barrel:destroy()
    DeleteObject(self._entity)
    DeleteObject(self._attachedEntity)
end

return Barrel
