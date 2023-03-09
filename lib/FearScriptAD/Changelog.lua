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
local FearVersion = "0.29.10"
local FearHelpNotification = "FearScript Advanced "..FearVersion

local FearChangelog = FearRoot:list("Changelog Update")

    FearChangelog:divider("FearScript Changelog")

    FearChangelog:divider("Active Changelog")
    FearChangelog:action("Patch 0.29.10", {}, "", function() -- 0.29.9
        FearHelp(FearHelpNotification.."\nWhat's new for 0.29.10?\n\n- Removed Clock Time\n - Minor improvements")
    end)

    FearChangelog:divider("Inactive Changelog")
    FearChangelog:action("Patch 0.29.9", {}, "", function() -- 0.29.9
        FearHelp(FearHelpNotification.."\nWhat's new for 0.29.9?\n\n - Improvements about Update.\n - Updated about creating 'Changelog Update' twice.\n - Minor improvements")
    end)
    FearChangelog:action("Patch 0.29.8", {}, "", function() -- 0.29.8
        FearHelp(FearHelpNotification.."\nWhat's new for 0.29.8?\n\n - Adding Changelog Update which you can track what's updated.")
    end)
