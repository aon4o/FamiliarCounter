local settings = {
    loaded = false
}

function settings:load()
    if self.loaded then
        return
    end

    if ModConfigMenu == nil then
        return
    end

    local categoryName = "Familiar Counter"

    local options = {
        detailed = true
    }

    ModConfigMenu.RemoveCategory(categoryName)

    ModConfigMenu.UpdateCategory(categoryName, {
        Name = categoryName,
    })

    ModConfigMenu.AddSetting(categoryName, {
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
        OnChange = function(value)
            options.detailed = value
        end,
        Info = {"Show number of each familiar or just show an icon when the max is reached."}
    })

    self.loaded = true
end


function settings:getHudOffset()
    -- if ModConfigMenu then
    --     return ModConfigMenu.Config.General.HudOffset
    -- end

    return Options.HUDOffset * 10
end

return settings