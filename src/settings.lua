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

    local menu = ModConfigMenu

    local categoryName = metadata.modName
    local sectionAbout = "About"
    local sectionSettings = "Settings"

    menu.RemoveCategory(categoryName)

    menu.UpdateCategory(categoryName, {
        Name = categoryName,
        Info = "Settings for the " .. categoryName .. " mod."
    })

    menu.UpdateSubcategory(categoryName, sectionAbout, {
        Name = sectionAbout,
        Info = "Information about the " .. categoryName .. " mod."
    })

    menu.AddTitle(categoryName, sectionAbout, categoryName)
    menu.AddSpace(categoryName, sectionAbout)
    menu.AddText(categoryName, sectionAbout, "Version: " .. metadata.version)
    menu.AddSpace(categoryName, sectionAbout)
    menu.AddText(categoryName, sectionAbout, "Made with Love <3 by: " .. metadata.author)

    menu.UpdateSubcategory(categoryName, sectionSettings, {
        Name = sectionSettings,
        Info = "Settings for the " .. categoryName .. " mod."
    })

    menu.AddSetting(categoryName, sectionSettings, {
        Type = menu.OptionType.BOOLEAN,
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

    menu.AddSpace(categoryName, sectionSettings)

    menu.AddSetting(categoryName, sectionSettings, {
        Type = menu.OptionType.NUMBER,
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

    menu.AddSetting(categoryName, sectionSettings, {
        Type = menu.OptionType.NUMBER,
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

    menu.AddSpace(categoryName, sectionSettings)
    menu.AddText(categoryName, sectionSettings, "[WIP]")

    menu.AddSetting(categoryName, sectionSettings, {
        Type = menu.OptionType.SCROLL,
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
