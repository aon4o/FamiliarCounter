--[[
TODO:

]]

local json = require("json")

local hudOffset = 0 --CHANGE ME, 0-10
local OFFSET = Vector(2,1.2)
local LISTYOFFSET = Vector(0, 13)

local SaveState = {}

local mod = RegisterMod("Familiar Counter", 1)

local SPIDERPATH = "gfx/003.073_blue spider.anm2"
local FLYPATH = "gfx/003.043_attack fly.anm2"
local CLOTPATH = "gfx/003.238_blood baby.anm2"
local DIPPATH = "gfx/003.201_dip.anm2"
-- local ALLPATH = "gfx/003.109_kingbaby.anm2"  -- Use the king baby to represent "all familiars"
local ALLPATH = "gfx/003.001_brother bobby.anm2"  -- brother bobby is a better representation of familiars
local MAXPATH = "gfx/maxfamiliars.anm2"
local LOCUSTPATH = "gfx/003.031_distant admiration.anm2" -- Locusts are tinted by game, but this is already red so less effort.
local WISPPATH = "gfx/003.206_wisp.anm2"

local options = {
    detailed = true
}

local DISPLAYORDER = {"clot", "locust", "wisp", "fly", "spider", "dip", "all"}

-- function mod:init()  -- This has been commented out as it is redundant (see first part of mod:render)
--     self.spiderSprite = Sprite()
--     self.spiderSprite:Load(spiderPath, true)
--     self.spiderSprite.Color = Color(0,0,1,1,0,0,0.3); --Roughly same as blue spider, cba to get it exactly the same
--     self.spiderSprite:SetFrame("Idle", 0)

--     self.flySprite = Sprite()
--     self.flySprite:Load(flyPath, true)
--     self.flySprite.Color = Color(1,1,1,1,0,0,0.2)
--     self.flySprite:SetFrame("Fly", 0)

--     self.spiderCoords = Vector(50,45) + (OFFSET * Vector(HUDOFFSET, HUDOFFSET))
--     self.flyCoords = Vector(50,70) + (OFFSET * Vector(HUDOFFSET, HUDOFFSET))

--     self.font = Font()
--     self.font:Load("font/pftempestasevencondensed.fnt")

--     self.familiarNumbers = {
--         spider = {0,"00"},
--         fly = {0, "00"},
--         dip = {0, "00"},
--         clot = {0, "00"},
--         all = {0, "00"}
--     }
-- end

if ModConfigMenu then
    ModConfigMenu.UpdateCategory("Familiar Counter", {
        Name = "Familiar Counter",
    })
    ModConfigMenu.AddSetting("Familiar Counter", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        Attribute = "Detailed",
        Default = true,
        Display = function()
            if options.detailed then
                return "Detailed Mode: Enabled"
            else
                return "Detailed Mode: Disabled"
            end
        end,
        CurrentSetting = function()
            return options.detailed
        end,
        OnChange = function(newOption)
            options.detailed = newOption
        end,
        Info = {"Show number of each familiar or just show an icon when the max is reached."}
    })
end

-- Save functions are ripped from the pog mod
function mod:save()
    SaveState.Settings = {}
	
	for i, v in pairs(options) do
		SaveState.Settings[tostring(i)] = options[i]
	end
    mod:SaveData(json.encode(SaveState))
end

function mod:init()
    if mod:HasData() then
        SaveState = json.decode(mod:LoadData())	
        
        for i, v in pairs(SaveState.Settings) do
            options[tostring(i)] = SaveState.Settings[i]
        end
    end

    self.spiderSprite = Sprite()
    self.spiderSprite:Load(SPIDERPATH, true)
    self.spiderSprite.Color = Color(1,1,1,1)
    self.spiderSprite.Scale = Vector(0.5, 0.5)
    self.spiderSprite:SetFrame("Idle", 0)

    self.flySprite = Sprite()
    self.flySprite:Load(FLYPATH, true)
    self.flySprite.Color = Color(1,1,1,1)
    self.flySprite.Scale = Vector(0.5, 0.5)
    self.flySprite:SetFrame("Idle", 0)

    self.clotSprite = Sprite()
    self.clotSprite:Load(CLOTPATH, true)
    self.clotSprite.Color = Color(1,1,1,1)
    self.clotSprite.Scale = Vector(0.5, 0.5)
    self.clotSprite:SetFrame("Idle", 0)

    self.dipSprite = Sprite()
    self.dipSprite:Load(DIPPATH, true)
    self.dipSprite.Color = Color(1,1,1,1)
    self.dipSprite.Scale = Vector(0.5, 0.5)
    self.dipSprite:SetFrame("Idle",0)

    self.allSprite = Sprite()
    self.allSprite:Load(ALLPATH, true)
    self.allSprite.Color = Color(1,1,1,1)
    self.allSprite.Scale = Vector(0.5, 0.5)
    self.allSprite:SetFrame("IdleDown", 0)

    self.maxSprite = Sprite()
    self.maxSprite:Load(MAXPATH, true)
    self.maxSprite.Color = Color(1,1,1,1)
    self.maxSprite.Scale = Vector(0.5, 0.5)
    self.maxSprite:SetFrame("Idle", 0)

    self.locustSprite = Sprite()
    self.locustSprite:Load(LOCUSTPATH, true)
    self.locustSprite.Color = Color(1,1,1,1)
    self.locustSprite.Scale = Vector(0.5,0.5)
    self.locustSprite:SetFrame("Idle", 0)

    self.wispSprite = Sprite()
    self.wispSprite:Load(WISPPATH, true)
    self.wispSprite.Color = Color(1,1,1,1) -- DO MEEEEEEEEEEEEEEEEEEE
    self.wispSprite.Scale = Vector(0.5, 0.5)
    self.wispSprite:SetFrame("Idle", 0)

    self.familiars = {  -- Count, display string, sprite object, default position (factoring in hud offset), text offset
        clot = {0, "00", self.clotSprite, Vector(45, 43), -10},
        fly = {0, "00", self.flySprite, Vector(45, 48) , -15},
        spider = {0, "00", self.spiderSprite, Vector(45, 43), -9},
        dip = {0, "00", self.dipSprite, Vector(45, 45), -11},
        all = {0, "00", self.allSprite, Vector(45, 48), -15},
        locust = {0, "00", self.locustSprite, Vector(45, 50), -16},
        wisp = {0, "00", self.wispSprite, Vector(45, 50), -16}
    }

    self.font = Font()
    self.font:Load("font/pftempestasevencondensed.fnt")

    mod:main(Isaac.GetRoomEntities())
end

local function getHudOffset()
    if ModConfigMenu then
        return ModConfigMenu.Config.General.HudOffset or hudOffset
    end
    return hudOffset
end

function mod:render()
    if not self.familiars then --Used to check if this init has been done yet.
        mod:init()
    end

    if Game():GetHUD():IsVisible() then
        local x = 0
        local total = 0

        if Isaac.GetPlayer(0):GetPlayerType() == PlayerType.PLAYER_XXX_B or Isaac.GetPlayer(0):GetPlayerType() == PlayerType.PLAYER_ISAAC_B then -- Check for tainted ???

            x = 2 -- Move all familiars down to avoid clash with poo or items

        end

        if options.detailed then

            for _,v in pairs(DISPLAYORDER) do
                local familiar = self.familiars[v]

                if familiar[1] > 0 then
                    familiar[3]:Render(familiar[4] + LISTYOFFSET*x + (OFFSET * getHudOffset()))
                    self.font:DrawString(familiar[2], 
                                        familiar[4].X + 9 + (OFFSET * getHudOffset()).X, 
                                        familiar[4].Y + (LISTYOFFSET*x).Y + familiar[5] + (OFFSET * getHudOffset()).Y, 
                                        KColor(1,1,1,1))
                    x = x + 1
                    total = total + familiar[1]
                end
            end

            if total > 0 then
                self.font:DrawString(tostring(total) .. "/64", 
                                    40 + (OFFSET * getHudOffset()).X, 
                                    31+LISTYOFFSET.Y*x + (OFFSET * getHudOffset()).Y, 
                                    KColor(1,1,1,1))
            end
        else

            for _,v in pairs(self.familiars) do
                total = total + v[1]
            end

            if total > 63 then
                self.maxSprite:Render(Vector(45, 41) + LISTYOFFSET*x + (OFFSET * getHudOffset()))
            end

        end
    end
end

function mod:onNewFamiliar(newFamiliar)
    local roomEntities = Isaac.GetRoomEntities()
    table.insert(roomEntities, newFamiliar) --When function is called, the new familiar isn't present in the room entities and must be manually added.
    mod:main(roomEntities)
end

function mod:onEntityDeath(deadEntity)
    if deadEntity.Type == EntityType.ENTITY_FAMILIAR then  -- Reduces lag with high tears
        local roomEntities = Isaac.GetRoomEntities()
        for i,entity in pairs(roomEntities) do
            if entity.Variant == deadEntity.Variant then
                table.remove(roomEntities, i)
                break
            end
        end
        mod:main(roomEntities)
    end
end

function mod:main(roomEntities)
    if #roomEntities > 0 and self.familiars then
        local total = 0

        for _,v in pairs(self.familiars) do
            v[1] = 0
            v[2] = "00"
        end

        for i,v in pairs(roomEntities) do

            if v.Type == EntityType.ENTITY_FAMILIAR then
                total = total + 1

                if v.Variant == FamiliarVariant.BLUE_SPIDER then
                    self.familiars.spider[1] = self.familiars.spider[1] + 1

                elseif v.Variant == FamiliarVariant.BLUE_FLY then
                    self.familiars.fly[1] = self.familiars.fly[1] + 1
                
                elseif v.Variant == FamiliarVariant.DIP then
                    self.familiars.dip[1] = self.familiars.dip[1] + 1
                
                elseif v.Variant == FamiliarVariant.BLOOD_BABY then -- I wonder why clots are called blood babies??
                    self.familiars.clot[1] = self.familiars.clot[1] + 1
                
                elseif v.Variant == FamiliarVariant.ABYSS_LOCUST then
                    self.familiars.locust[1] = self.familiars.locust[1] + 1
                
                elseif v.Variant == FamiliarVariant.WISP or v.Variant == FamiliarVariant.ITEM_WISP then
                    self.familiars.wisp[1] = self.familiars.wisp[1] + 1
                    -- local clr = v:GetSprite().Color -- I tried :(
                    -- self.wispSprite.Color = clr
                    -- Isaac.DebugString(clr.R .. clr.G .. clr.B .. clr.RO .. clr.GO .. clr.BO)
                    -- Isaac.DebugString(v:GetSprite():GetFilename())
                
                else
                    self.familiars.all[1] = self.familiars.all[1] + 1

                end
            end
        end

        for i,v in pairs(self.familiars) do
            if v[1] < 10 then
                v[2] = "0" .. tostring(v[1])
            else
                v[2] = tostring(v[1])
            end
        end
        if total == 65 then  -- Probably not the most efficient but this was the only way to get it to properly update the number after the game auto-removes a familiar due to there being too many.
            local roomEntities = Isaac.GetRoomEntities()
            mod:main(roomEntities)
        end
    end
end


mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.onNewFamiliar)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.onEntityDeath)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.init);
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.save)
