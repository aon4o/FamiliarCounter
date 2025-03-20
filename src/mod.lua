local settings = require("src.settings")
local json = require("json")
local SPRITES = require("src.enums.sprites")

local mod = RegisterMod("Familiar Counter", 1)

local OFFSET = Vector(2,1.2)
local LISTYOFFSET = Vector(0, 13)

local SaveState = {}

local options = {
    detailed = true
}

function mod:save()
    SaveState.Settings = {}

	for key, value in pairs(options) do
		SaveState.Settings[tostring(key)] = options[key]
	end

    mod:SaveData(json.encode(SaveState))
end

function mod:init()
    if mod:HasData() then
        SaveState = json.decode(mod:LoadData())	

        for key, value in pairs(SaveState.Settings) do
            options[tostring(key)] = SaveState.Settings[key]
        end
    end

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
        sprite.Color = Color(1,1,1,1)
        sprite.Scale = Vector(0.5, 0.5)
        sprite:SetFrame("Idle", 0)
    end

    self.sprites.all:SetFrame("IdleDown", 0)

    -- Count, display string, sprite object, default position (factoring in hud offset), text offset
    self.familiars = {
        clot = {0, "00", self.sprites.clot, Vector(45, 43), -10},
        locust = {0, "00", self.sprites.locust, Vector(45, 50), -16},
        wisp = {0, "00", self.sprites.wisp, Vector(45, 50), -16},
        fly = {0, "00", self.sprites.fly, Vector(45, 48) , -15},
        spider = {0, "00", self.sprites.spider, Vector(45, 43), -9},
        dip = {0, "00", self.sprites.dip, Vector(45, 45), -11},
        all = {0, "00", self.sprites.all, Vector(45, 48), -15},
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

    if options.detailed then
        mod:renderDetailed()
    else
        mod:renderCompact()
    end
end

function mod:renderDetailed()
    local x = 0
    local total = 0

    local hudOffset = settings:getHudOffset()

    for _, familiar in pairs(self.familiars) do
        if familiar[1] > 0 then
            familiar[3]:Render(familiar[4] + LISTYOFFSET*x + (OFFSET * hudOffset))

            self.font:DrawString(
                familiar[2],
                familiar[4].X + 9 + (OFFSET * hudOffset).X, 
                familiar[4].Y + (LISTYOFFSET*x).Y + familiar[5] + (OFFSET * hudOffset).Y, 
                KColor(1,1,1,1)
            )

            x = x + 1
            total = total + familiar[1]
        end
    end

    if total > 0 then
        self.font:DrawString(
            tostring(total) .. "/64",
            40 + (OFFSET * hudOffset).X,
            31+LISTYOFFSET.Y*x + (OFFSET * hudOffset).Y,
            KColor(1,1,1,1)
        )
    end
end

function mod:renderCompact()
    local x = 0
    local total = 0

    local hudOffset = settings:getHudOffset()

    for _, v in pairs(self.familiars) do
        total = total + v[1]
    end

    if total > 63 then
        self.sprites.max:Render(Vector(45, 41) + LISTYOFFSET*x + (OFFSET * hudOffset))
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

    for i, entity in pairs(roomEntities) do
        if entity.Variant == deadEntity.Variant then
            table.remove(roomEntities, i)
            break
        end
    end

    mod:calculate(roomEntities)
end

function mod:calculate(roomEntities)
    if #roomEntities > 0 and self.familiars then
        local total = 0

        for _, familiar in pairs(self.familiars) do
            familiar[1] = 0
            familiar[2] = "00"
        end

        for _, entity in pairs(roomEntities) do
            if entity.Type ~= EntityType.ENTITY_FAMILIAR then
                goto continue
            end

            total = total + 1

            if entity.Variant == FamiliarVariant.BLUE_SPIDER then
                self.familiars.spider[1] = self.familiars.spider[1] + 1
            elseif entity.Variant == FamiliarVariant.BLUE_FLY then
                self.familiars.fly[1] = self.familiars.fly[1] + 1
            elseif entity.Variant == FamiliarVariant.DIP then
                self.familiars.dip[1] = self.familiars.dip[1] + 1
            elseif entity.Variant == FamiliarVariant.BLOOD_BABY then
                self.familiars.clot[1] = self.familiars.clot[1] + 1
            elseif entity.Variant == FamiliarVariant.ABYSS_LOCUST then
                self.familiars.locust[1] = self.familiars.locust[1] + 1
            elseif entity.Variant == FamiliarVariant.WISP or entity.Variant == FamiliarVariant.ITEM_WISP then
                self.familiars.wisp[1] = self.familiars.wisp[1] + 1
            else
                self.familiars.all[1] = self.familiars.all[1] + 1
            end

            ::continue::
        end

        for _, v in pairs(self.familiars) do
            if v[1] < 10 then
                v[2] = "0" .. tostring(v[1])
            else
                v[2] = tostring(v[1])
            end
        end

        if total == 65 then  -- Probably not the most efficient but this was the only way to get it to properly update the number after the game auto-removes a familiar due to there being too many.
            mod:calculate(Isaac.GetRoomEntities())
        end
    end
end

return mod