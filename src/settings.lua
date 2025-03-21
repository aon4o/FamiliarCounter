local settings = {
    detailed = true,
    xOffset = 0,
    yOffset = 0,
}

function settings:load()
    if ModConfigMenu == nil then
        return
    end

    local categoryName = "Familiar Counter"

    ModConfigMenu.RemoveCategory(categoryName)

    ModConfigMenu.UpdateCategory(categoryName, {
        Name = categoryName,
    })

    ModConfigMenu.AddSetting(categoryName, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        Attribute = "Detailed",
        Default = true,
        Display = function()
            if settings.detailed then
                return "Detailed Mode: Enabled"
            else
                return "Detailed Mode: Disabled"
            end
        end,
        CurrentSetting = function()
            return settings.detailed
        end,
        OnChange = function(value)
            settings.detailed = value
        end,
        Info = {"Show number of each familiar or just show an icon when the max is reached."}
    })

    ModConfigMenu.AddSetting(categoryName, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return settings.xOffset
        end,
        Minimum = 0,
        Maximum = 300,
        Display = function()
            return "X Offset: " .. settings.xOffset
        end,
        OnChange = function(value)
            settings.xOffset = value
        end,
        Info = { "The offset of the counter from left to right." }
    })

    ModConfigMenu.AddSetting(categoryName, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return settings.yOffset
        end,
        Minimum = 0,
        Maximum = 150,
        Display = function()
            return "Y Offset: " .. settings.yOffset
        end,
        OnChange = function(value)
            settings.yOffset = value
        end,
        Info = { "The offset of the counter from top to bottom." }
    })
end


function settings:getHudOffset()
    return Options.HUDOffset * 10
end

return settings