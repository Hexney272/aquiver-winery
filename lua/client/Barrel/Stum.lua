local Config = require("lua.shared.Config")

---@class C_Stum : OxClass
---@field private _id eStum | ""
---@field private _volume number
---@field private _quality number
---@field private _progress number
---@field private _condition number
---@field private _speedModifier number
local Stum = lib.class("C_Stum")

function Stum:constructor()
    self._id            = ""
    self._volume        = 0.0
    self._quality       = 100.0
    self._condition     = 100.0
    self._progress      = 0.0
    self._speedModifier = 0.0
end

function Stum:isEmpty()
    return self._id == ""
end

function Stum:getContent()
    return self._id
end

function Stum:setContent(id)
    self._id = id
end

function Stum:getVolume()
    return self._volume
end

function Stum:setVolume(volume)
    self._volume = volume
end

function Stum:getEmptyVolumeCount()
    return Config.BARREL_STUM_CAPACITY - self:getVolume()
end

function Stum:getQualityPercentage()
    return self._quality
end

function Stum:setQualityPercentage(quality)
    self._quality = quality
end

function Stum:getSpeedModifier()
    return self._speedModifier
end

---@param modifier number
function Stum:setSpeedModifier(modifier)
    self._speedModifier = modifier
end

function Stum:getConditionPercentage()
    return self._condition
end

function Stum:setConditionPercentage(condition)
    self._condition = condition
end

function Stum:getProgressPercentage()
    return self._progress
end

function Stum:setProgressPercentage(percentage)
    self._progress = percentage
end

---@return IStum
function Stum:serialize()
    return {
        id = self._id,
        volume = self._volume,
        quality = self._quality,
        progress = self._progress,
        condition = self._condition,
        speedModifier = self._speedModifier
    }
end

return Stum
