local mod = require("src.mod")
local settings = require("src.settings")

settings:load()

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.init);
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.save)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.render)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.onNewFamiliar)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.onEntityDeath)