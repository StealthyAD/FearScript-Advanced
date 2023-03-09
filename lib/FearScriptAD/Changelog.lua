--[[
    FearScript Advanced for Stand by StealthyAD.
    The All-In-One Script combines every each script.
    
    -- Changelog Script

    Features:
    - Compatible All Stand Versions.
    - Includes Standify & Cruise Missile Tool (GitHub)

    Help with Lua?
    - GTAV Natives: https://nativedb.dotindustries.dev/natives/
    - FiveM Docs Natives: https://docs.fivem.net/natives/
    - Stand Lua Documentation: https://stand.gg/help/lua-api-documentation
    - Lua Documentation: https://www.lua.org/docs.html
]]--

local FearRoot = menu.my_root()
local FearHelp = util.show_corner_help
local FearVersion = "0.29.9"
local FearHelpNotification = "FearScript Advanced "..FearVersion

local FearChangelog = FearRoot:list("Changelog Update")

    FearChangelog:divider("FearScript Changelog")

    FearChangelog:divider("Active Changelog")

    FearChangelog:action("Patch 0.29.9", {}, "", function() -- 0.29.9
        FearHelp(FearHelpNotification.."\nWhat's new?\n\n - Improvements about Update.")
    end)

    FearChangelog:divider("Inactive Changelog")

    FearChangelog:action("Patch 0.29.8", {}, "", function() -- 0.29.8
        FearHelp(FearHelpNotification.."\nWhat's new?\n\n - Adding Changelog Update which you can track what's updated.")
    end)
