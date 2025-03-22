local metadata = require("src.metadata")

local settings = {
    detailed = true,
    xOffset = 1,  -- actually 5
    yOffset = 37, -- actually 185
    textOpacity = 0.6,
}

function settings:load()
    if ModConfigMenu == nil then
        return
    end

    local categoryName = metadata.modName
    local sectionAbout = "About"
    local sectionSettings = "Settings"

    ModConfigMenu.RemoveCategory(categoryName)

    ModConfigMenu.UpdateCategory(categoryName, {
        Name = categoryName,
    })

    ModConfigMenu.AddTitle(categoryName, sectionAbout, categoryName)
    ModConfigMenu.AddSpace(categoryName, sectionAbout)
    ModConfigMenu.AddText(categoryName, sectionAbout, "Version: " .. metadata.version)
    ModConfigMenu.AddSpace(categoryName, sectionAbout)
    ModConfigMenu.AddText(categoryName, sectionAbout, "Made with Love <3 by: " .. metadata.author)

    ModConfigMenu.AddSetting(categoryName, sectionSettings, {
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
        Info = { "Show number of each familiar or just show an icon when the max is reached." }
    })
    
    ModConfigMenu.AddSpace(categoryName, sectionSettings)

    ModConfigMenu.AddSetting(categoryName, sectionSettings, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return settings.xOffset / 5
        end,
        Minimum = 0,
        Maximum = 100, -- actually 500
        Display = function()
            return "X Offset: " .. settings.xOffset
        end,
        OnChange = function(value)
            settings.xOffset = value * 5
        end,
        Info = { "The offset of the counter from left to right." }
    })

    ModConfigMenu.AddSetting(categoryName, sectionSettings, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return settings.yOffset / 5
        end,
        Minimum = 0,
        Maximum = 60, -- actually 300
        Display = function()
            return "Y Offset: " .. settings.yOffset
        end,
        OnChange = function(value)
            settings.yOffset = value * 5
        end,
        Info = { "The offset of the counter from top to bottom." }
    })

    ModConfigMenu.AddSpace(categoryName, sectionSettings)
    ModConfigMenu.AddText(categoryName, sectionSettings, "[WIP]")

    ModConfigMenu.AddSetting(categoryName, sectionSettings, {
        Type = ModConfigMenu.OptionType.SCROLL,
        CurrentSetting = function()
            return settings.textOpacity
        end,
        Display = function()
            return "Text Opacity: $scroll" .. settings.textOpacity
        end,
        OnChange = function(value)
            settings.textOpacity = value
        end,
        Info = { "How transperent the text is." }
    })
end

function settings:getHudOffset()
    return Options.HUDOffset * 10
end

return settings
