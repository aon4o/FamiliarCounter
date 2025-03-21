local json = require("json")
local settings = require("src.settings")
local SPRITES = require("src.enums.sprites")

local mod = RegisterMod("Familiar Counter", 1)

-- hud offset scale factor
local OFFSET = Vector(2, 1.2)

-- used to split the list with counters into multiple lines
local LISTYOFFSET = Vector(0, 13)

local SaveState = {}

function mod:save()
    SaveState.Settings = {}

    for key, value in pairs(settings) do
        SaveState.Settings[key] = value
    end

    mod:SaveData(json.encode(SaveState))
end

function mod:load()
    if not mod:HasData() then
        return
    end

    SaveState = json.decode(mod:LoadData())

    for key, value in pairs(SaveState.Settings) do
        settings[key] = value
    end
end

function mod:init()
    mod:load()

    self.sprites = {
        spider = Sprite(),
        fly = Sprite(),
        clot = Sprite(),
        dip = Sprite(),
        all = Sprite(),
        max = Sprite(),
        locust = Sprite(),
        wisp = Sprite()
    }

    self.sprites.spider:Load(SPRITES.SPIDER, true)
    self.sprites.fly:Load(SPRITES.FLY, true)
    self.sprites.clot:Load(SPRITES.CLOT, true)
    self.sprites.dip:Load(SPRITES.DIP, true)
    self.sprites.all:Load(SPRITES.ALL, true)
    self.sprites.max:Load(SPRITES.MAX, true)
    self.sprites.locust:Load(SPRITES.LOCUST, true)
    self.sprites.wisp:Load(SPRITES.WISP, true)

    for _, sprite in pairs(self.sprites) do
        sprite.Color = Color(1, 1, 1, 1)
        sprite.Scale = Vector(0.5, 0.5)
        sprite:SetFrame("Idle", 0)
    end

    self.sprites.all:SetFrame("IdleDown", 0)

    -- Count, display string, sprite object, default position (factoring in hud offset), text offset
    self.familiars = {
        clot = {
            count = 0,
            textCount = "00",
            sprite = self.sprites.clot,
            spriteOffset = Vector(45, 43),
            textOffset = -10
        },
        locust = {
            count = 0,
            textCount = "00",
            sprite = self.sprites.locust,
            spriteOffset = Vector(45, 50),
            textOffset = -16
        },
        wisp = {
            count = 0,
            textCount = "00",
            sprite = self.sprites.wisp,
            spriteOffset = Vector(45, 50),
            textOffset = -16
        },
        fly = {
            count = 0,
            textCount = "00",
            sprite = self.sprites.fly,
            spriteOffset = Vector(45, 48),
            textOffset = -15
        },
        spider = {
            count = 0,
            textCount = "00",
            sprite = self.sprites.spider,
            spriteOffset = Vector(45, 43),
            textOffset = -9
        },
        dip = {
            count = 0,
            textCount = "00",
            sprite = self.sprites.dip,
            spriteOffset = Vector(45, 45),
            textOffset = -11
        },
        all = {
            count = 0,
            textCount = "00",
            sprite = self.sprites.all,
            spriteOffset = Vector(45, 48),
            textOffset = -15
        },
    }

    self.font = Font()
    self.font:Load("font/pftempestasevencondensed.fnt")

    mod:calculate(Isaac.GetRoomEntities())
end

function mod:render()
    if not self.familiars then
        mod:init()
    end

    if not Game():GetHUD():IsVisible() then
        return
    end

    if settings.detailed then
        mod:renderDetailed()
    else
        mod:renderCompact()
    end
end

function mod:renderDetailed()
    local x = 0
    local total = 0

    local hudOffset = settings:getHudOffset()
    local xOffset = settings.xOffset
    local yOffset = settings.yOffset

    for _, familiar in pairs(self.familiars) do
        if familiar.count > 0 then
            familiar.sprite:Render(
                familiar.spriteOffset + LISTYOFFSET * x + (OFFSET * hudOffset) + Vector(xOffset, yOffset)
            )

            self.font:DrawString(
                familiar.textCount,
                familiar.spriteOffset.X + 9 + (OFFSET * hudOffset).X + xOffset,
                familiar.spriteOffset.Y + (LISTYOFFSET * x).Y + familiar.textOffset + (OFFSET * hudOffset).Y + yOffset,
                KColor(1, 1, 1, 1)
            )

            x = x + 1
            total = total + familiar.count
        end
    end

    if total > 0 then
        self.font:DrawString(
            tostring(total) .. "/64",
            40 + (OFFSET * hudOffset).X + xOffset,
            31 + LISTYOFFSET.Y * x + (OFFSET * hudOffset).Y + yOffset,
            KColor(1, 1, 1, 1)
        )
    end
end

function mod:renderCompact()
    local x = 0
    local total = 0

    local hudOffset = settings:getHudOffset()
    local xOffset = settings.xOffset
    local yOffset = settings.yOffset

    for _, familiar in pairs(self.familiars) do
        total = total + familiar.count
    end

    if total > 63 then
        self.sprites.max:Render(
            Vector(45, 41) + LISTYOFFSET * x + (OFFSET * hudOffset) + Vector(xOffset, yOffset)
        )
    end
end

function mod:onNewFamiliar(familiar)
    local roomEntities = Isaac.GetRoomEntities()
    table.insert(roomEntities, familiar)
    mod:calculate(roomEntities)
end

function mod:onEntityDeath(deadEntity)
    if deadEntity.Type ~= EntityType.ENTITY_FAMILIAR then
        return
    end

    local roomEntities = Isaac.GetRoomEntities()

    for key, entity in pairs(roomEntities) do
        if entity.Variant == deadEntity.Variant then
            table.remove(roomEntities, key)
            break
        end
    end

    mod:calculate(roomEntities)
end

function mod:calculate(roomEntities)
    if #roomEntities == 0 or not self.familiars then
        return
    end

    local total = 0

    for _, familiar in pairs(self.familiars) do
        familiar.count = 0
        familiar.textCount = "00"
    end

    for _, entity in pairs(roomEntities) do
        if entity.Type ~= EntityType.ENTITY_FAMILIAR then
            goto continue
        end

        total = total + 1

        if entity.Variant == FamiliarVariant.BLUE_SPIDER then
            self.familiars.spider.count = self.familiars.spider.count + 1
        elseif entity.Variant == FamiliarVariant.BLUE_FLY then
            self.familiars.fly.count = self.familiars.fly.count + 1
        elseif entity.Variant == FamiliarVariant.DIP then
            self.familiars.dip.count = self.familiars.dip.count + 1
        elseif entity.Variant == FamiliarVariant.BLOOD_BABY then
            self.familiars.clot.count = self.familiars.clot.count + 1
        elseif entity.Variant == FamiliarVariant.ABYSS_LOCUST then
            self.familiars.locust.count = self.familiars.locust.count + 1
        elseif entity.Variant == FamiliarVariant.WISP or entity.Variant == FamiliarVariant.ITEM_WISP then
            self.familiars.wisp.count = self.familiars.wisp.count + 1
        else
            self.familiars.all.count = self.familiars.all.count + 1
        end

        ::continue::
    end

    for _, familiar in pairs(self.familiars) do
        if familiar.count < 10 then
            familiar.textCount = "0" .. tostring(familiar.count)
        else
            familiar.textCount = tostring(familiar.count)
        end
    end

    -- Probably not the most efficient but this was the only way to get it to properly update the number after the game auto-removes a familiar due to there being too many.
    if total == 65 then
        mod:calculate(Isaac.GetRoomEntities())
    end
end

return mod
