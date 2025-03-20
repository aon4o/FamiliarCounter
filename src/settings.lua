local settings = {
    detailed = true
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
end


function settings:getHudOffset()
    return Options.HUDOffset * 10
end

return settings