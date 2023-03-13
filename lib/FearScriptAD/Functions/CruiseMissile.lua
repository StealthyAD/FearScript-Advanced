--[[
    FearScript Advanced for Stand by StealthyAD.
    The All-In-One Script combines every each script.

    Script Part: Cruise Missile

    Features:
    - Compatible All Stand Versions.
    - Includes Standify & Cruise Missile Tool (GitHub)

    Help with Lua?
    - GTAV Natives: https://nativedb.dotindustries.dev/natives/
    - FiveM Docs Natives: https://docs.fivem.net/natives/
    - Stand Lua Documentation: https://stand.gg/help/lua-api-documentation
    - Lua Documentation: https://www.lua.org/docs.html
]]--

    util.require_natives(1663599433)

    ----=======================================----
    ---             Cruise Missile
    ---             Basic Functions
    ----=======================================----

    function SET_INT_GLOBAL(Global, Value)
        memory.write_int(memory.script_global(Global), Value)
    end
    
    function GET_INT_LOCAL(script, script_local)
        if memory.script_local(script, script_local) ~= 0 then
            local ReadLocal = memory.read_int(memory.script_local(script, script_local))
            if ReadLocal ~= nil then
                return ReadLocal
            end
        end
    end
    
    function EXECUTION_FUNCTION_WORKING(IsAddNewLine)
        local State = ""
        local Version = tonumber(NETWORK.GET_ONLINE_VERSION())
        if util.is_session_started() then
            if GET_INT_LOCAL("freemode", 3618) ~= util.joaat("lr_prop_carkey_fob") then 
            end
        end
        return State
    end

    local FearRoot = menu.my_root()
    local FearToast = util.toast
    local FearCommands = menu.trigger_commands
    local FearCruiseMissile = FearRoot:list("Cruise Missile", {""}, "CruiseMissile, script related to Cruise Missile Range.\nMade by StealthyAD.")

    ------==============------
    ---   Cruise Missile
    ------==============------

    local FearCruiseMissile_ver = "0.34.6"
    local FearCruiseMissileNTF = "> FearScript CruiseMissile "..FearCruiseMissile_ver
    FearCruiseMissile:divider("FearScript CruiseMissile "..FearCruiseMissile_ver)
    local FearPresetMissile = FearCruiseMissile:list("Cruise Missile Presets")
    FearPresetMissile:toggle_loop("Cruise Missile Range (9.32 Miles)", {}, EXECUTION_FUNCTION_WORKING(false), function() -- 9.32 Miles Cruise Missile Range
        FearCommands('damagemultiplier 7500')
        SET_INT_GLOBAL(262145 + 30188, 15000)
    end, function()
        FearCommands('damagemultiplier 1')
        SET_INT_GLOBAL(262145 + 30188, 4000)
    end)

    FearPresetMissile:toggle_loop("Cruise Missile Range (18.6 Miles)", {}, EXECUTION_FUNCTION_WORKING(false), function() -- 18.6 miles Cruise Missile Range
        FearCommands('damagemultiplier 8500')
        SET_INT_GLOBAL(262145 + 30188, 30000)
    end, function()
        FearCommands('damagemultiplier 1')
        SET_INT_GLOBAL(262145 + 30188, 4000)
    end)

    FearPresetMissile:toggle_loop("Cruise Missile Range (37.2 Miles)", {}, EXECUTION_FUNCTION_WORKING(false), function() -- 37.2 Miles Cruise Missile Range
        FearCommands('damagemultiplier 10000')
        SET_INT_GLOBAL(262145 + 30188, 60000)
    end, function()
        FearCommands('damagemultiplier 1')
        SET_INT_GLOBAL(262145 + 30188, 4000)
    end)

    FearPresetMissile:toggle_loop("Cruise Missile Range (Bypass)", {}, EXECUTION_FUNCTION_WORKING(false), function() -- Bypass Cruise Missile Range
        FearCommands('damagemultiplier 10000')
        SET_INT_GLOBAL(262145 + 30188, 99999)
    end, function()
        FearCommands('damagemultiplier 1')
        SET_INT_GLOBAL(262145 + 30188, 4000)
    end)
    
    FearCruiseMissileRange = FearCruiseMissile:slider("Cruise Missile Range", {"fcmr"}, "Make sure you put the limit atleast 99 KM/H (which means 61.5 Miles)\nE.G: you want unlimited range, put the max.", 2, 99, 4, 1, function()end) -- Maximise your chance to hit enemy to high range

    FearCruiseMissile:toggle_loop("Toggle Cooldown Cruise Missile", {}, EXECUTION_FUNCTION_WORKING(false), function()
        SET_INT_GLOBAL(262145 + 30187, 0)
    end,function()
        SET_INT_GLOBAL(262145 + 30187, 60000)
    end)

    FearCruiseMissile:toggle("Execute Cruise Missile", {}, "NOTE: For indication detection, it tells you according to the range of the missile.\n\n- 2 to 4 Km - Short Missile\n- 4 to 6 Km - Standard Missile\n- 6 to 10 Km - Medium Missile\n- 10 to 19 Km - Long Range Missile\n- Superior than 20 Km - Extra Long Range Missile\n\nWARNING: Changing the session will put your Cruise Missile to Default State.", function()
        SET_INT_GLOBAL(262145 + 30188, menu.get_value(FearCruiseMissileRange) * 1000)

        if menu.get_value(FearCruiseMissileRange) >= 20 then -- Extra Long Range Range Missile
            FearToast(FearCruiseMissileNTF.."\nStatus : Extra Long Range Missile")
            FearCommands('damagemultiplier 10000')
        end

        if menu.get_value(FearCruiseMissileRange) >= 10 and menu.get_value(FearCruiseMissileRange) <= 19 then -- Long Range Missile
            FearToast(FearCruiseMissileNTF.."\nStatus : Long Range Missile")
            FearCommands('damagemultiplier 7500')
        end

        if menu.get_value(FearCruiseMissileRange) >=6 and menu.get_value(FearCruiseMissileRange) <= 9 then -- Medium Range Missile
            FearToast(FearCruiseMissileNTF.."\nStatus : Medium Range Missile")
            FearCommands('damagemultiplier 10000')
        end

        if menu.get_value(FearCruiseMissileRange) >= 4 and menu.get_value(FearCruiseMissileRange) <= 5 then -- Standard Missile
            FearToast(FearCruiseMissileNTF.."\nStatus : Standard Missile")
            FearCommands('damagemultiplier 1')
        end
        if menu.get_value(FearCruiseMissileRange) >= 2 and menu.get_value(FearCruiseMissileRange) <= 3 then -- Short Range Missile
            FearToast(FearCruiseMissileNTF.."\nStatus : Short Range Missile")
            FearCommands('damagemultiplier 1')
        end
    end)

    FearCruiseMissile:action("Revert to Default State", {}, "Revert to Default State like Cruise Missile Range and Cooldown.", function() -- Revert Default Settings
        SET_INT_GLOBAL(262145 + 30188, 4000) -- Remove Bypass
        SET_INT_GLOBAL(262145 + 30187, 60000) -- Cooldown Time
        FearToast(FearCruiseMissileNTF.."\nReverted to Default State")
    end)

    FearCruiseMissile:divider("Miscs")
    FearCruiseMissile:readonly("FearScript (CruiseMissile)", FearCruiseMissile_ver)
    FearCruiseMissile:hyperlink("CruiseMissile: GitHub Source", "https://github.com/StealthyAD/Cruise-Missile")
