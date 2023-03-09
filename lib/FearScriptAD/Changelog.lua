--[[
    FearScript Advanced for Stand by StealthyAD.
    The All-In-One Script combines every each script.

    Features:
    - Compatible All Stand Versions.
    - Includes Standify & Cruise Missile Tool (GitHub)

    Help with Lua?
    - GTAV Natives: https://nativedb.dotindustries.dev/natives/
    - FiveM Docs Natives: https://docs.fivem.net/natives/
    - Stand Lua Documentation: https://stand.gg/help/lua-api-documentation
    - Lua Documentation: https://www.lua.org/docs.html
]]--

    ----======================================----
    ---             Core Functions
    --- The most essential part of Lua Script.
    ----======================================----

    local FearHelp = util.show_corner_help
    local FearRoot = menu.my_root()
    local FearVersion = "0.29.11"
    local FearHelpNot = "FearScript Advanced"..FearVersion
    local FearChangelog = FearRoot:list("Changelog Update")

    FearChangelog:divider("FearScript Changelog")

        FearChangelog:action("Patch 0.29.11", {}, "", function()
            FearHelp(FearHelpNot.."\nWhat's New?\n\n- Updated about auto_updater which creates a lot of bug.")
        end)

        FearChangelog:action("Patch 0.29.10", {}, "", function()
            FearHelp(FearHelpNot.."\nWhat's New?\n\n- Update improvements.")
        end)
