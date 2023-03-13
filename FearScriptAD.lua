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

    util.keep_running()
    util.require_natives(1676318796)
    util.require_natives(1663599433)

    local FearRoot = menu.my_root()
    local FearVersion = "0.30.9"
    local FearScriptNotif = "> FearScript Advanced "..FearVersion
    local FearScriptV1 = "FearScript Advanced "..FearVersion
    local FearSEdition = 100.7
    local FearToast = util.toast

    local ScriptDir <const> = filesystem.scripts_dir()
    local required_files <const> = {
        "lib\\FearScriptAD\\Functions\\Standify.lua",
        "lib\\FearScriptAD\\Functions\\CruiseMissile.lua",
    }

    for _, file in pairs(required_files) do
        local file_path = ScriptDir .. file
        if not filesystem.exists(file_path) then
            util.toast(FearScriptNotif.."\nSorry, you missed these documents:" .. file_path, TOAST_ALL)
            util.toast("The script has stopped running")
        end
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

    local function FearGeneratorPlate()
        local plate = ""
            for i=1,8 do
                local r = math.random(1,36)
                if r <= 10 then
                    plate = plate .. tostring(r-1) 
                    else
                    r = r + 54 
                    if r > 90 then
                    r = r + 6 
                    end
                    plate = plate .. string.char(r)
                end
            end
        return plate
    end

    local function show_custom_rockstar_alert(l1)
        poptime = os.time()
        while true do
            if PAD.IS_CONTROL_JUST_RELEASED(18, 18) then
                if os.time() - poptime > 0.1 then
                    break
                end
            end
            native_invoker.begin_call()
            native_invoker.push_arg_string("ALERT")
            native_invoker.push_arg_string("JL_INVITE_ND")
            native_invoker.push_arg_int(2)
            native_invoker.push_arg_string("")
            native_invoker.push_arg_bool(true)
            native_invoker.push_arg_int(-1)
            native_invoker.push_arg_int(-1)
            -- line here
            native_invoker.push_arg_string(l1)
            -- optional second line here
            native_invoker.push_arg_int(0)
            native_invoker.push_arg_bool(true)
            native_invoker.push_arg_int(0)
            native_invoker.end_call("701919482C74B5AB")
            util.yield()
        end
    end

    local function CameraMoving(pid, force) -- most of script use ShakeCamera
        local entity = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 7, 0, false, true, force)
    end

    local function FRModel(Hash)
        if STREAMING.IS_MODEL_VALID(Hash) then
            STREAMING.REQUEST_MODEL(Hash)
            while not STREAMING.HAS_MODEL_LOADED(Hash) do
                STREAMING.REQUEST_MODEL(Hash)
                util.yield()
            end
        end
    end
    local function Create_Network_Object(modelHash, x, y, z)
        FRModel(modelHash)
        local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(modelHash, x, y, z, true, true, false)
        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(obj, true)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, false)
        ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)
    
        NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(obj)
        local net_id = NETWORK.OBJ_TO_NET(obj)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
        for _, player in pairs(players.list(true, true, true)) do
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, player, true)
        end
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
        return obj
    end

    local function Create_Network_Ped(pedType, modelHash, x, y, z, heading)
        FRModel(modelHash)
        local ped = PED.CREATE_PED(pedType, modelHash, x, y, z, heading, true, true)
    
        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(ped, true)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ped, true, false)
        ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(ped, true)
    
        NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(ped)
        local net_id = NETWORK.PED_TO_NET(ped)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
        for _, player in pairs(players.list(true, true, true)) do
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, player, true)
        end
    
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
        return ped
    end

    local function Increase_Ped_Combat_Ability(ped, isGodmode, canRagdoll)
        if isGodmode == nil then isGodmode = false end
        if canRagdoll == nil then canRagdoll = true end
    
        if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
            ENTITY.SET_ENTITY_INVINCIBLE(ped, isGodmode)
            ENTITY.SET_ENTITY_PROOFS(ped, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode, isGodmode,
                isGodmode)
            PED.SET_PED_CAN_RAGDOLL(ped, canRagdoll)
            --PERCEPTIVE
            PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
            PED.SET_PED_VISUAL_FIELD_PERIPHERAL_RANGE(ped, 500.0)
            PED.SET_PED_SEEING_RANGE(ped, 500.0)
            PED.SET_PED_HEARING_RANGE(ped, 500.0)
            PED.SET_PED_ID_RANGE(ped, 500.0)
            PED.SET_PED_VISUAL_FIELD_MIN_ANGLE(ped, 90.0)
            PED.SET_PED_VISUAL_FIELD_MAX_ANGLE(ped, 90.0)
            PED.SET_PED_VISUAL_FIELD_MIN_ELEVATION_ANGLE(ped, 90.0)
            PED.SET_PED_VISUAL_FIELD_MAX_ELEVATION_ANGLE(ped, 90.0)
            PED.SET_PED_VISUAL_FIELD_CENTER_ANGLE(ped, 90.0)
            --WEAPON
            PED.SET_PED_CAN_SWITCH_WEAPON(ped, true)
            WEAPON.SET_PED_INFINITE_AMMO_CLIP(ped, true)
            PED.SET_PED_SHOOT_RATE(ped, 1000)
            PED.SET_PED_ACCURACY(ped, 100)
            --COMBAT
            PED.SET_PED_COMBAT_ABILITY(ped, 2) --Professional
            PED.SET_PED_COMBAT_RANGE(ped, 2) --Far
            PED.SET_PED_TARGET_LOSS_RESPONSE(ped, 1) --NeverLoseTarget
            PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, true) -- NEVER_FLEE
            --TASK
            TASK.SET_PED_PATH_CAN_USE_CLIMBOVERS(ped, true)
            TASK.SET_PED_PATH_CAN_USE_LADDERS(ped, true)
            TASK.SET_PED_PATH_CAN_DROP_FROM_HEIGHT(ped, true)
            TASK.SET_PED_PATH_AVOID_FIRE(ped, false)
            TASK.SET_PED_PATH_MAY_ENTER_WATER(ped, true)
        end
    end
    
    local function Increase_Ped_Combat_Attributes(ped)
        if ENTITY.DOES_ENTITY_EXIST(ped) and ENTITY.IS_ENTITY_A_PED(ped) then
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 4, true) --Can Use Dynamic Strafe Decisions
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) --Always Fight
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 6, false) --Flee Whilst In Vehicle
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 13, true) --Aggressive
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 14, true) --Can Investigate
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 17, false) --Always Flee
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 20, true) --Can Taunt In Vehicle
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 21, true) --Can Chase Target On Foot
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 22, true) --Will Drag Injured Peds to Safety
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 24, true) --Use Proximity Firing Rate
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 27, true) --Perfect Accuracy
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 28, true) --Can Use Frustrated Advance
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 29, true) --Move To Location Before Cover Search
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 38, true) --Disable Bullet Reactions
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 39, true) --Can Bust
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 41, true) --Can Commandeer Vehicles
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 42, true) --Can Flank
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true) --Can Fight Armed Peds When Not Armed
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 49, false) --Use Enemy Accuracy Scaling
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 52, true) --Use Vehicle Attack
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 53, true) --Use Vehicle Attack If Vehicle Has Mounted Guns
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 54, true) --Always Equip Best Weapon
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 55, true) --Can See Underwater Peds
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true) --Disable Flee From Combat
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 60, true) --Can Throw Smoke Grenade
            PED.SET_PED_COMBAT_ATTRIBUTES(ped, 78, true) --Disable All Randoms Flee
        end
    end
    
    local function IS_PED_PLAYER(Ped)
        if PED.GET_PED_TYPE(Ped) >= 4 then
            return false
        else
            return true
        end
    end
    
    local function IS_PLAYER_VEHICLE(Vehicle)
        if Vehicle == entities.get_user_vehicle_as_handle() or Vehicle == entities.get_user_personal_vehicle_as_handle() then
            return true
        elseif not VEHICLE.IS_VEHICLE_SEAT_FREE(Vehicle, -1, false) then
            local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Vehicle, -1)
            if ped then
                if IS_PED_PLAYER(ped) then
                    return true
                end
            end
        end
        return false
    end
    
    local function REQUEST_CONTROL_ENTITY(ent, tick)
        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then
            local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
            for i = 1, tick do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
                if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then
                    return true
                end
            end
        end
        return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent)
    end
    
    local function GET_NEARBY_VEHICLES(p, radius)
        local vehicles = {}
        local pos = ENTITY.GET_ENTITY_COORDS(p)
        for k, veh in pairs(entities.get_all_vehicles_as_handles()) do
            if radius == 0 then
                table.insert(vehicles, veh)
            else
                local veh_pos = ENTITY.GET_ENTITY_COORDS(veh)
                local distance = v3.distance(v3(pos), v3(veh_pos))
                if distance <= radius then
                    table.insert(vehicles, veh)
                end
            end
        end
        return vehicles
    end
    
    local function GET_NEARBY_PEDS(p, radius)
        local peds = {}
        local pos = ENTITY.GET_ENTITY_COORDS(p)
        for k, ped in pairs(entities.get_all_peds_as_handles()) do
            if radius == 0 then
                table.insert(peds, ped)
            else
                local ped_pos = ENTITY.GET_ENTITY_COORDS(ped)
                local distance = v3.distance(v3(pos), v3(ped_pos))
                if distance <= radius then
                    table.insert(peds, ped)
                end
            end
        end
        return peds
    end
    
    local function GET_NEARBY_OBJECTS(p, radius)
        local objects = {}
        local pos = ENTITY.GET_ENTITY_COORDS(p)
        for k, obj in pairs(entities.get_all_objects_as_handles()) do
            if radius == 0 then
                table.insert(objects, obj)
            else
                local obj_pos = ENTITY.GET_ENTITY_COORDS(obj)
                local distance = v3.distance(v3(pos), v3(obj_pos))
                if distance <= radius then
                    table.insert(objects, obj)
                end
            end
        end
        return objects
    end

    local function RequestControl(entity, tick)
        if tick == nil then tick = 20 end
        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and util.is_session_started() then
            entities.set_can_migrate(entities.handle_to_pointer(entity), true)
    
            local i = 0
            while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and i <= tick do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
                i = i + 1
                util.yield()
            end
        end
        return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
    end

    local function on_user_change_vehicle(vehicle)
        if vehicle ~= 0 then
            if initial_d_mode then 
                set_vehicle_into_drift_mode(vehicle)
            end
        end
    end

    local function SendRequest(hash, timeout)
        timeout = timeout or 3
        STREAMING.REQUEST_MODEL(hash)
        local end_time = os.time() + timeout
        repeat
            util.yield()
        until STREAMING.HAS_MODEL_LOADED(hash) or os.time() >= end_time
        return STREAMING.HAS_MODEL_LOADED(hash)
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
                    return RemoveProjectiles
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

        explodePlayer = function(ped, loop) -- Required for Nuke Session
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

        explode_all = function(earrape_type, wait_for) -- Required for Nuke Session
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

    local function OverrideCamOffset(distance) -- Required for Nuke Session
        local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(2)
        local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
        local direction = Fear.rotation_to_direction(cam_rot)
        local destination = 
        { 
            x = cam_pos.x + direction.x * distance, 
            y = cam_pos.y + direction.y * distance, 
            z = cam_pos.z + direction.z * distance 
        }
        return destination
    end

    local function CameraPerspective(flag, distance) -- Required for Nuke Session
        local ptr1, ptr2, ptr3, ptr4 = memory.alloc(), memory.alloc(), memory.alloc(), memory.alloc()
        local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
        local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
        local direction = Fear.rotation_to_direction(cam_rot)
        local destination = 
        { 
            x = cam_pos.x + direction.x * distance, 
            y = cam_pos.y + direction.y * distance, 
            z = cam_pos.z + direction.z * distance 
        }
        SHAPETEST.GET_SHAPE_TEST_RESULT(
            SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
                cam_pos.x, 
                cam_pos.y, -
                cam_pos.z, 
                destination.x, 
                destination.y, 
                destination.z, 
                flag, 
                -1, 
                1
            ), ptr1, ptr2, ptr3, ptr4)
        local p1 = memory.read_int(ptr1)
        local p2 = memory.read_vector3(ptr2)
        local p3 = memory.read_vector3(ptr3)
        local p4 = memory.read_int(ptr4)
        memory.free(ptr1)
        memory.free(ptr2)
        memory.free(ptr3)
        memory.free(ptr4)
        return {p1, p2, p3, p4}
    end

    local function GetPlayerDirection() -- Required for Nuke Session
        local c1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0, 5, 0)
        local res = CameraPerspective(-1, 1000)
        local c2
    
        if res[1] ~= 0 then
            c2 = res[2]
        else
            c2 = OverrideCamOffset(1000)
        end
    
        c2.x = (c2.x - c1.x) * 1000
        c2.y = (c2.y - c1.y) * 1000
        c2.z = (c2.z - c1.z) * 1000
        return c2, c1
    end
        function request_model(hash)
            local timeout = 3
            STREAMING.REQUEST_MODEL(hash)
            local end_time = os.time() + timeout
            repeat util.yield() until STREAMING.HAS_MODEL_LOADED(hash) or os.time() >= end_time
            return STREAMING.HAS_MODEL_LOADED(hash)
        end
        
        function get_distance_between(pos1, pos2) -- Credits to kektram for this function
            if math.type(pos1) == "integer" then
                pos1 = ENTITY.GET_ENTITY_COORDS(pos1)
            end
            if math.type(pos2) == "integer" then 
                pos2 = ENTITY.GET_ENTITY_COORDS(pos2)
            end
            return pos1:distance(pos2)
        end
        
        function get_offset_from_gameplay_camera(distance)
            local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
            local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
            local direction = v3.toDir(cam_rot)
            local destination = {
            x = cam_pos.x + direction.x * distance, 
            y = cam_pos.y + direction.y * distance, 
            z = cam_pos.z + direction.z * distance 
            }
            return destination
        end

        local function RequestOrbitalCannon(Position) -- Skid from METEOR SCRIPT, because it was always used
            local player_ped = players.user_ped()
            FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z + 1, 59, 1, true, false, 1.0, false)
            while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
                STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                util.yield(0)
            end
            GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z + 1, 0, 180, 0, 1.0, true, true, true)
            for i = 1, 4 do
                AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "DLC_XM_Explosions_Orbital_Cannon", player_ped, 0, true, false)
            end
        end

        local function CreateNuke(Position, Named) -- Shortcut of Nuke Features bcz too lazy to get high line codes
            local Owner
            if Named then
                Owner = players.user_ped()
            else
                Owner = 0
            end
            local function spawn_explosion()
                while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
                    STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                    util.yield(0)
                end
                FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z, 59, 1, true, false, 5.0, false)
                GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)
            end
            for i = 1, 7 do
                spawn_explosion()
            end
            for i=-30,30,10 do
                for j=-30,30,10 do
                    if i~=0 or j~=0 then
                        FIRE.ADD_EXPLOSION(Position.x+i, Position.y+j, Position.z, 59, 1.0, true, false, 1.0, false)
                    end
                end
            end
        
            for i = 1, 4 do
                AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "DLC_XM_Explosions_Orbital_Cannon", players.user_ped(), 0, true, false)
            end
            
            FIRE.ADD_EXPLOSION(Position.x+10, Position.y+30, Position.z, 59, 1.0, true, false, 1.0, false)
            FIRE.ADD_EXPLOSION(Position.x+30, Position.y+10, Position.z, 59, 1.0, true, false, 1.0, false)
            FIRE.ADD_EXPLOSION(Position.x-30, Position.y-10, Position.z, 59, 1.0, true, false, 1.0, false)
            FIRE.ADD_EXPLOSION(Position.x-10, Position.y-30, Position.z, 59, 1.0, true, false, 1.0, false)
            FIRE.ADD_EXPLOSION(Position.x-10, Position.y+30, Position.z, 59, 1.0, true, false, 1.0, false)
            FIRE.ADD_EXPLOSION(Position.x-30, Position.y+10, Position.z, 59, 1.0, true, false, 1.0, false)
            FIRE.ADD_EXPLOSION(Position.x+30, Position.y-10, Position.z, 59, 1.0, true, false, 1.0, false)
            FIRE.ADD_EXPLOSION(Position.x+10, Position.y-30, Position.z, 59, 1.0, true, false, 1.0, false)
            -- Définir les coordonnées z de chaque explosion
            local coords = {1, 3, 5, 7, 10, 12, 15, 17}
        
            while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
                STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                util.yield(0)
            end
        
            for i = 1, #coords do
                if coords[i] % 2 ~= 0 then
                    FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+coords[i], 59, 1, true, false, 5.0, false)
                end
                GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+coords[i], 0, 180, 0, 1.5, true, true, true)
                util.yield(10)
            end
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+80, 0, 0, 0, 3, true, true, true)
        
            for pid = 0, 31 do
                if players.exists(pid) and get_distance_between(players.get_position(pid), Position) < 200 then
                    local pid_pos = players.get_position(pid)
                    FIRE.ADD_EXPLOSION(pid_pos.x, pid_pos.y, pid_pos.z, 59, 1.0, true, false, 1.0, false)
                end
            end
        
            local peds = entities.get_all_pickups_as_handles()
            for i = 1, #peds do
                if get_distance_between(peds[i], Position) < 400 and NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(peds[i]) ~= players.user() then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds[i])
                    local ped_pos = ENTITY.GET_ENTITY_COORDS(peds[i], false)
                    FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1.0, true, false, 0.1, false)
                    PED.SET_PED_TO_RAGDOLL(peds[i], 1000, 1000, 0, false, false, false)
                end
            end
        
            local vehicles = entities.get_all_vehicles_as_handles()
            for i = 1, #vehicles do
                if get_distance_between(vehicles[i], Position) < 400 then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles[i])
                    VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicles[i], -999.90002441406)
                    VEHICLE.EXPLODE_VEHICLE(vehicles[i], true, false)
                elseif get_distance_between(vehicles[i], Position) < 400 then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles[i])
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicles[i], -4000)
                end
            end
        end

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

        local cruiselib = {
            source_url="https://raw.githubusercontent.com/StealthyAD/FearScript-Advanced/main/lib/FearScriptAD/Functions/CruiseMissile.lua",
            script_relpath="lib/FearScriptAD/Functions/CruiseMissile.lua",
            verify_file_begins_with="--",
            check_interval=86400,
            silent_updates=true,
        }

        local standifylib = {
            source_url="https://raw.githubusercontent.com/StealthyAD/FearScript-Advanced/main/lib/FearScriptAD/Functions/Standify.lua",
            script_relpath="lib/FearScriptAD/Functions/Standify.lua",
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
            verify_file_begins_with="--",
        })

        auto_updater.run_auto_update(auto_update_config)

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
        local FearSelf = FearRoot:list("Self Features")
        local FearVehicles = FearRoot:list("Vehicles Features")
        local FearOnline = FearRoot:list("Online Features")
        local FearWorld = FearRoot:list("World Features")
        require "FearScriptAD.Functions.Standify" -- Without Standify, no Music, file required
        require "FearScriptAD.Functions.CruiseMissile" -- Without CruiseMissile, no missile can go far, file required
        local FearMiscs = FearRoot:list("Miscellaneous")

        ------==============------
        ---   Self Functions
        ------==============------  

            FearSelf:divider("FearScript Self")
            local FearWeapons = FearSelf:list("Weapons")
            local FearAnimations = FearSelf:list("Animations")
            local FearAnimals = FearSelf:list("Animals")
            local FearWantedSelf = FearSelf:list("Wanted Settings")
            FearSelf:action("Simple Ragdoll", {}, "Just fall yourself on the ground.", function()
                PED.SET_PED_TO_RAGDOLL(players.user_ped(), 2500, 0, 0, false, false, false) 
                FearTime(150)
                FearToast(FearScriptNotif.."\nLol, why are you falling on the ground?")
                FearTime(100)
            end)

            FearSelf:toggle_loop("Ragdoll Loop", {}, "Loop Ragdoll", function()
                PED.SET_PED_TO_RAGDOLL(players.user_ped(), 2500, 0, 0, false, false, false)
            end)

            FearSelf:toggle_loop("Burn Proof Mode", {}, "Make able to avoid burn in fire while put fire", function()
                FIRE.STOP_ENTITY_FIRE(PLAYER.PLAYER_PED_ID())
            end)

            FearSelf:toggle("Partial Invisible", {}, "Turn partially invisible mode (Players will not able to see you), but you will see only yourself, includes vehicles.", function(toggle)
                if toggle then
                    FearCommands("otr on")
                    FearCommands("invisibility remote")
                    FearCommands("vehinvisibility remote")
                else
                    FearCommands("otr off")
                    FearCommands("invisibility off")
                    FearCommands("vehinvisibility off")
                end
            end)

            FearSelf:toggle_loop("Force Clean Ped & Wetness", {}, "Force Cleanup Ped & Wetness against blood or damage.", function() 
                PED.CLEAR_PED_BLOOD_DAMAGE(PLAYER.PLAYER_PED_ID()) 
                PED.CLEAR_PED_WETNESS(PLAYER.PLAYER_PED_ID())
            end)

            FearSelf:toggle("Ghost Rider", {}, "Become Ghost Rider.", function(toggle)
                if toggle then
                    FIRE.START_ENTITY_FIRE(PLAYER.PLAYER_PED_ID())
                    PLAYER.SET_PLAYER_INVINCIBLE(PLAYER.PLAYER_PED_ID(), true)
                else
                    FIRE.STOP_ENTITY_FIRE(PLAYER.PLAYER_PED_ID())
                    PLAYER.SET_PLAYER_INVINCIBLE(PLAYER.PLAYER_PED_ID(), false)
                end
            end)

            FearSelf:toggle("Reduce Footsteps", {}, "", function(toggle) -- Everyone use the part of the script, but I will add this if they need this.
                AUDIO.SET_PED_FOOTSTEPS_EVENTS_ENABLED(PLAYER.PLAYER_PED_ID(), not toggle)
            end)
            
            ------=====================------
            ---   Wanted SELF Functions
            ------=====================------  

            local SWLevel = {
                WantedMUT = 0,
            }

            FearWantedSelf:slider_float("Wanted Level Multiplier", {'fwlmut'}, "If you set the wanted multiplier to a low value 0.01 and a cop see you shoot a ped in face you wil still get a wanted level. \n\n1.0 is the default value and it will automatically be reset when Finished Mission has been set. \n\nMore than 2 will be able to get more cops while put more wanted multiplier." , 0, 1000, 0, 10, function(value)
                SWLevel.WantedMUT = value * 0.01
            end)

            FearWantedSelf:toggle("Police ignores you", {}, "", function(toggle)
                PLAYER.SET_POLICE_IGNORE_PLAYER(players.user_ped(), toggle)
            end)

            FearWantedSelf:toggle_loop("Set Wanted Level Multiplier", {}, "", function()
                PLAYER.SET_WANTED_LEVEL_MULTIPLIER(SWLevel.WantedMUT)
            end)

            FearWantedSelf:action("Force Start Hidden Evasion", {}, "Can be used at any point that police \"know\" where the player is to force hidden evasion to start (e.g. : flashing stars, cops use vision cones)", function()
                PLAYER.FORCE_START_HIDDEN_EVASION(PLAYER.PLAYER_ID())
            end)

            ------===================------
            ---   Animation Functions
            ------===================------  

            local FearAnime1 = {
                ToggleFeature = {},
                ToggleMenu = {},
            }
            FearAnime1.task_list = {
                { 1,   "Climb Ladder" },
                { 2,   "Exit Vehicle" },
                { 3,   "Combat Roll" },
                { 16,  "Get Up" },
                { 17,  "Get Up And Stand Still" },
                { 50,  "Vault" },
                { 54,  "Open Door" },
                { 121, "Steal Vehicle" },
                { 128, "Melee" },
                { 135, "Synchronized Scene" },
                { 150, "In Vehicle Basic" },
                { 152, "Leave Any Car" },
                { 160, "Enter Vehicle" },
                { 162, "Open Vehicle Door From Outside" },
                { 163, "Enter Vehicle Seat" },
                { 164, "Close Vehicle Door From Inside" },
                { 165, "In Vehicle Seat Shuffle" },
                { 167, "Exit Vehicle Seat" },
                { 168, "Close Vehicle Door From Outside" },
                { 177, "Try To Grab Vehicle Door" },
                { 286, "Throw Projectile" },
                { 300, "Enter Cover" },
                { 301, "Exit Cover" },
            }

            FearAnimations:divider("FearSelf Animations")
            FearAnimations:toggle_loop("Toggle Feature", {}, "Turning On/Off for Fast Animation", function()
                for id, toggle in pairs(FearAnime1.ToggleFeature) do
                    if toggle and TASK.GET_IS_TASK_ACTIVE(players.user_ped(), id) then
                        PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
                    end
                end
            end)

            FearAnimations:divider("Options")
            FearAnimations:toggle("Enable/Disable Feature", {}, "", function(toggle)
                for _, v in pairs(FearAnime1.ToggleMenu) do
                    if menu.is_ref_valid(v) then
                        menu.set_value(v, toggle)
                    end
                end
            end)

            for _, v in pairs(FearAnime1.task_list) do
                local id = v[1]
                local name = v[2]

                FearAnime1.ToggleFeature[id] = false

                local menu_toggle = menu.toggle(FearAnimations, name, {}, "", function(toggle)
                    FearAnime1.ToggleFeature[id] = toggle
                end)
                FearAnime1.ToggleMenu[id] = menu_toggle
            end

            ------=================------
            ---   Weapons Functions
            ------=================------  

                FearWeapons:divider("FearSelf Weapons")
                local FearNukeWeap = FearWeapons:list("Nuke / Orbital Weapons")

                    ------=================------
                    ---   Nukes   Functions
                    ------=================------  
                    FearNukeWeap:divider("FearWeapons Nuke")
                    local NukeToggleActive = FearNukeWeap:toggle("Nuclear Weapon", {}, "Compatible only explosive weapon. Make sure you shoot like a mortar.", function(toggle)
                        NukeActive = toggle	
                        if NukeActive then
                            if animals_running then menu.trigger_command(exp_animal_toggle, "off") end
                            util.create_tick_handler(function()
                                local selectedWeapon = WEAPON.GET_SELECTED_PED_WEAPON(PLAYER.PLAYER_PED_ID())
                                local weaponTable = {-1312131151, 1672152130, 125959754, -1568386805}
                                if string.find(table.concat(weaponTable, ","), tostring(selectedWeapon)) and PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
                                    if not RemoveProjectiles then 
                                        RemoveProjectiles = true 
                                        Fear.disableProjectileLoop(selectedWeapon)
                                    end
                                    util.create_thread(function()
                                        local hash = util.joaat("w_arena_airmissile_01a")
                                        STREAMING.REQUEST_MODEL(hash)
                                        Fear.yieldModelLoad(hash)
                                        local cam_rot = CAM.GET_FINAL_RENDERED_CAM_ROT(2)   
                                        local dir, pos = GetPlayerDirection()
                                        local bomb = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, pos.x, pos.y, pos.z, true, true, false)
                                        ENTITY.APPLY_FORCE_TO_ENTITY(bomb, 0, dir.x, dir.y, dir.z, 0.0, 0.0, 0.0, 0, true, false, true, false, true)
                                        ENTITY.SET_ENTITY_ROTATION(bomb, cam_rot.x, cam_rot.y, cam_rot.z, 1, true)
                                        while not ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(bomb) do util.yield() end
                                        local nukePos = ENTITY.GET_ENTITY_COORDS(bomb, true)
                                        entities.delete(bomb)
                                        LaunchNuke(nukePos)
                                    end)
                                else
                                    RemoveProjectiles = false
                                end
                            end)
                        end
                    end)

                    FearNukeWeap:toggle_loop("Improved Nuke Weapon", {}, "Improving old feature but it's better than old.\nBig Radius", function()
                        if PED.IS_PED_SHOOTING(players.user_ped()) then
                            local hash = util.joaat("prop_military_pickup_01")
                            request_model(hash)
                            local player_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 5.0, 3.0)
                            local dir = {}
                            local c2 = {}
                              c2 = get_offset_from_gameplay_camera(1000)
                              dir.x = (c2.x - player_pos.x) * 1000
                              dir.y = (c2.y - player_pos.y) * 1000
                              dir.z = (c2.z - player_pos.z) * 1000
                            local nuke = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, player_pos.x, player_pos.y, player_pos.z, true, false, false)
                              ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(nuke, players.user_ped(), false)
                              ENTITY.APPLY_FORCE_TO_ENTITY(nuke, 0, dir.x, dir.y, dir.z, 0.0, 0.0, 0.0, 0, true, false, true, false, true)
                              ENTITY.SET_ENTITY_HAS_GRAVITY(nuke, true)
                    
                              while not ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(nuke) and not ENTITY.IS_ENTITY_IN_WATER(nuke) do
                                util.yield(0)
                              end
                            local nukePos = ENTITY.GET_ENTITY_COORDS(nuke, true)
                            entities.delete_by_handle(nuke)
                            CreateNuke(nukePos)
                        end
                    end)

                    FearNukeWeap:toggle_loop("Orbital Gun Weapon", {}, "Shoot everywhere to orbital player without reason.", function()
                        local last_hit_coords = v3.new()
                        if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(players.user_ped(), last_hit_coords) then
                            RequestOrbitalCannon(last_hit_coords)
                        end
                    end)
                    
                    local nuke_height = 20
                    FearNukeWeap:slider("Height Nuke", {'fnukeheight'}, "", 20, 100, nuke_height, 10, function(value)
                        nuke_height = value
                    end)

                    function LaunchNuke(pos)	
                        for a = 0, nuke_height, 4 do
                            FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z + a, 8, 10, true, false, 1, false)	
                            util.yield(50)
                        end
                        local offsets = {{8, 8}, {8, -8}, {-8, 8}, {-8, -8}}
                        for _, offset in ipairs(offsets) do
                            FIRE.ADD_EXPLOSION(pos.x + offset[1], pos.y + offset[2], pos.z + nuke_height, 82, 10, true, false, 1, false)
                        end
                    end

                FearWeapons:toggle("Authorize Fire Friendly", {}, "Allow shoot your teammates if he's in the CEO/MC.", function(toggle)
                    PED.SET_CAN_ATTACK_FRIENDLY(PLAYER.PLAYER_PED_ID(), toggle, false)
                end)

                FearWeapons:toggle_loop("Refill Instant Ammo", {"ffammo"}, "Refill Instantly your ammo without reloading while losing ammo.\n\nAlternative to Stand, have the same feature but it will make easier to not reloading.", function() 
                    WEAPON.REFILL_AMMO_INSTANTLY(PLAYER.PLAYER_PED_ID()) 
                end)

                FearWeapons:toggle_loop("Night Vision Scope" ,{}, "Press E while aiming to activate.\n\nRecommended to use only night time, using daytime can may have complication on your eyes watching the screen.",function()
                    local aiming = PLAYER.IS_PLAYER_FREE_AIMING(players.user())
                    local FearNV = menu.ref_by_path('Game>Rendering>Night Vision')
                    if GRAPHICS.GET_USINGSEETHROUGH() and not aiming then
                        menu.trigger_command(FearNV,'off')
                    elseif PAD.IS_CONTROL_JUST_PRESSED(38,38) then
                        if menu.get_value(FearNV) or not aiming then
                            FearCommand(FearNV,"off")
                        else
                            FearCommand(FearNV,"on")
                        end
                    end
                end)

                local FearNR = menu.ref_by_path('Self>Weapons>No Recoil')
                FearWeapons:toggle_loop("No Recoil Alt", {}, "Press E while aiming to activate.\n\nRecommended to use standard weapon or RPG.", function()
                    local aiming = PLAYER.IS_PLAYER_FREE_AIMING(players.user())
                    if not aiming then
                        menu.trigger_command(FearNR, 'off')
                    elseif PAD.IS_CONTROL_JUST_PRESSED(38, 38) then
                        if not menu.get_value(FearNR) then
                            FearCommand(FearNR, 'on')
                        else
                            FearCommand(FearNR, 'off')
                        end
                    end
                end)

                FearWeapons:toggle_loop("Explosive Ammo", {}, "Simple Explosive Ammo for all weapons.", function()
                    MISC.SET_EXPLOSIVE_AMMO_THIS_FRAME(players.user())
                end)

                FearWeapons:toggle("Infinite Ammo", {"ffclip"}, "Lock your ammo to get not reloading fire.\n\nAlternative to Stand, has reloading fire. Better alternative to avoid reloading and made reloading easier without losing time.", function(toggle)
                    local WeaponHashes = { -- Added Hash Weapons to look the real infinite weapon without reloading
                        0x1B06D571,0xBFE256D4,0x5EF9FEC4,0x22D8FE39,0x3656C8C1,0x99AEEB3B,0xBFD21232,0x88374054,0xD205520E,0x83839C4,0x47757124,
                        0xDC4DB296,0xC1B3C3D1,0xCB96392F,0x97EA20B8,0xAF3696A1,0x2B5EF5EC,0x917F6C8C,0x13532244,0x2BE6766B,0x78A97CD0,0xEFE7E2DF,
                        0xA3D4D34,0xDB1AA450,0xBD248B55,0x476BF155,0x1D073A89,0x555AF99A,0x7846A318,0xE284C527,0x9D61E50F,0xA89CB99E,0x3AABBBAA,
                        0xEF951FBB,0x12E82D3D,0xBFEFFF6D,0x394F415C,0x83BF0278,0xFAD1F1C9,0xAF113F99,0xC0A3098D,0x969C3D67,0x7F229F94,0x84D6FAFD,
                        0x624FE830,0x9D07F764,0x7FD62962,0xDBBD7280,0x61012683,0x5FC3C11,0xC472FE2,0xA914799,0xC734385A,0x6A6C02E0,0xB1CA77B1,
                        0xA284510B,0x4DD2DC56,0x42BF8A85,0x7F7497E5,0x6D544C99,0x63AB0442,0x781FE4A,0xB62D1F67,0x93E220BD,0xA0973D5E,0xFDBC8A50,
                        0x497FACC3,0x24B17070,0x2C3731D9,0xAB564B93,0x787F0BB,0xBA45E8B8,0x23C9F95C,0xFEA23564,0xDB26713A,0x1BC4FDB9,0xD1D5F52B,0x45CD9CF3
                    }
        
                    for k,v in WeaponHashes do
                        WEAPON.SET_PED_INFINITE_AMMO(players.user_ped(), toggle, v)
                        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), toggle)
                    end
                end)

                FearWeapons:toggle_loop("Quick Reload", {}, "Reload faster than normal weapon.\n\nRecommended for big magazine which it's very slow to reload", function()
                    if PED.IS_PED_RELOADING(PLAYER.PLAYER_PED_ID()) then
                        PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(PLAYER.PLAYER_PED_ID())
                    end
                end)
                
                FearWeapons:toggle_loop("Quick Weapon Change", {}, "Speed up the action while changing weapon\n\nExample: Changing AP Pistol to RPG/Sniper/Carbine/Shotgun...", function()
                    if PED.IS_PED_SWITCHING_WEAPON(PLAYER.PLAYER_PED_ID()) then
                        PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(PLAYER.PLAYER_PED_ID())
                    end
                end)

                FearWeapons:toggle_loop("Quick Reload while Rolling", {}, "Reload automatically while rolling\n\nRecommended for PvP or something else.", function()
                if TASK.GET_IS_TASK_ACTIVE(PLAYER.PLAYER_PED_ID(), 4) and PAD.IS_CONTROL_PRESSED(2, 22) and
                    not PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
                    FearTime(900)
                    WEAPON.REFILL_AMMO_INSTANTLY(PLAYER.PLAYER_PED_ID())
                    end
                end)

                ------==================------
                ---   Animals  Functions
                ------==================------  

                FearAnimals:divider("FearSelf Animals")
                FearAnimals:toggle_loop("Polish Cow", {}, "", function()
                    if not custom_pet or not ENTITY.DOES_ENTITY_EXIST(custom_pet) then
                        local pet = util.joaat("a_c_cow")
                        Fear.request_model(pet)
                        local pos = players.get_position(players.user())
                        custom_pet = entities.create_ped(28, pet, pos, 0)
                        PED.SET_PED_COMPONENT_VARIATION(custom_pet, 0, 0, 1, 0)
                        ENTITY.SET_ENTITY_INVINCIBLE(custom_pet, true)
                    end
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(custom_pet)
                    TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(custom_pet, players.user_ped(), 0, -0.3, 0, 7.0, -1, 1.5, true)
                    util.yield(2500)
                end, function()
                    entities.delete_by_handle(custom_pet)
                    custom_pet = nil
                end)

                FearAnimals:toggle_loop("Canadian Deer", {}, "", function()
                    if not custom_pet or not ENTITY.DOES_ENTITY_EXIST(custom_pet) then
                        local pet = util.joaat("a_c_deer")
                        Fear.request_model(pet)
                        local pos = players.get_position(players.user())
                        custom_pet = entities.create_ped(28, pet, pos, 0)
                        PED.SET_PED_COMPONENT_VARIATION(custom_pet, 0, 0, 1, 0)
                        ENTITY.SET_ENTITY_INVINCIBLE(custom_pet, true)
                    end
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(custom_pet)
                    TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(custom_pet, players.user_ped(), 0, -0.3, 0, 7.0, -1, 1.5, true)
                    util.yield(2500)
                end, function()
                    entities.delete_by_handle(custom_pet)
                    custom_pet = nil
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

            FearVehicles:action("Commercial Planes", {}, "Summon plane and flight peacefully.\nNOTE: Some vehicles are randomly spawned.", function()
                local vehicles = {"Boeing 747", "Antonov AN-225", "Nimbus", "Private Jet", "Golden Jet", "Miljet"}
                local index = math.random(#vehicles)
                local vehicle = vehicles[index]
                table.remove(vehicles, index)
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

            FearVehicles:action("Dogfight Planes", {}, "Summon plane and Fight.\nNOTE: Some vehicles are randomly spawned.", function()
                local vehicles = {"P-996 Lazer", "Mammoth Hydra", "B-11 Strikeforce", "LF-22 Starling", "V-65 Molotok", "P-45 Nokota", "Pyro", "Western Rogue", "Seabreeze"}
                local index = math.random(#vehicles)
                local vehicle = vehicles[index]
                table.remove(vehicles, index)
                if vehicle == "P-996 Lazer" then -- Spawning Lazer
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("lazer")
                   FearTime(300)
                   FearCommands("upgrade")
                   FearTime(250)
                elseif vehicle == "Mammoth Hydra" then -- Spawning Hydra
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("hydra")
                   FearTime(300)
                   FearCommands("upgrade")
                   FearTime(250)
                elseif vehicle == "B-11 Strikeforce" then -- Spawning B-11 Strikeforce Fully
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("strikeforce")
                   FearTime(300)
                   FearCommands("upgrade")
                   FearTime(250)
                elseif vehicle == "LF-22 Starling" then -- Spawning LF-22 Starling Fully
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("starling")
                   FearTime(300)
                   FearCommands("upgrade")
                   FearTime(250)
                elseif vehicle == "V-65 Molotok" then -- Spawning V-65 Molotok Fully
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("molotok")
                    FearTime(300)
                    FearCommands("upgrade")
                    FearTime(250)
                elseif vehicle == "P-45 Nokota" then -- Spawning P-45 Nokota Fully
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("nokota")
                    FearTime(300)
                    FearCommands("upgrade")
                    FearTime(250)
                elseif vehicle == "Western Rogue" then -- Spawning Western Rogue Fully
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("rogue")
                    FearTime(300)
                    FearCommands("upgrade")
                    FearTime(250)
                elseif vehicle == "Seabreeze" then -- Spawning Seabreeze Fully
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("seabreeze") 
                    FearTime(300)
                    FearCommands("upgrade")
                    FearTime(250)
                end
                FearToast(FearScriptNotif.."\nEnjoy your dogfight at cruise altitude with your "..vehicle.." !")
            end)

            FearVehicles:action("Strategic Bomber Planes", {}, "Summon Strategic Bomber Planes and fly harder to bomb.\nNOTE: Some vehicles are randomly spawned.", function()
                local vehicles = {"B-1B Lancer", "Avro Vulcan", "AC-130"}
                local index = math.random(#vehicles)
                local vehicle = vehicles[index]
                table.remove(vehicles, index)
                if vehicle == "B-1B Lancer" then
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("alkonost")
                   FearTime(300)
                   FearCommands("upgrade")
                   FearTime(250)
                elseif vehicle == "Avro Vulcan" then
                   FearCommands("tphigh")
                   FearTime(500)
                   FearCommands("volatol")
                   FearTime(300)
                   FearCommands("upgrade")
                   FearTime(250)
                elseif vehicle == "AC-130" then
                    FearCommands("tphigh")
                    FearTime(500)
                    FearCommands("bombushka")
                    FearTime(300)
                    FearCommands("upgrade")
                    FearTime(250)
                end
                FearToast(FearScriptNotif.."\nEnjoy your Strategic Bomber at cruise altitude with your "..vehicle.." !")
            end)
             
            FearVehicles:action("Tank Spawner", {}, "Summon Leopard 2A (Rhino Tank) / PL-01 Concept (TM-02 Khanjali) or BRDM-2 (APC).\nNOTE: Some vehicles are randomly spawned.", function()
                local vehicles = {"Leopard 2A", "PL-01 Concept", "BRDM-2"}
                local index = math.random(#vehicles)
                local vehicle = vehicles[index]
                table.remove(vehicles, index)
                if vehicle == "Leopard 2A" then
                   FearCommands("rhino")
                   FearTime(300)
                   FearCommands("upgrade")
                   FearTime(250)
                elseif vehicle == "PL-01 Concept" then
                   FearCommands("khanjali")
                   FearTime(300)
                   FearCommands("upgrade")
                   FearTime(250)
                elseif vehicle == "BRDM-2" then
                    FearCommands("apc")
                    FearTime(300)
                    FearCommands("upgrade")
                    FearTime(250)
                end
                FearToast(FearScriptNotif.."\nEnjoy your "..vehicle.." !")
            end)

            FearVehicles:action("Oppressor Party", {}, "Summon Oppressor.\nNOTE: Some vehicles are randomly spawned.", function()
                local vehicles = {"Oppressor", "Oppressor Mk II"}
                local index = math.random(#vehicles)
                local vehicle = vehicles[index]
                table.remove(vehicles, index)
                if vehicle == "Oppressor" then
                   FearCommands("oppressor")
                   FearTime(300)
                   FearCommands("upgrade")
                   FearTime(250)
                elseif vehicle == "Oppressor Mk II" then
                   FearCommands("oppressor2")
                   FearTime(300)
                   FearCommands("upgrade")
                   FearTime(250)
                end
                FearToast(FearScriptNotif.."\nEnjoy your "..vehicle.." !")
            end)
            FearVehicles:divider("Vehicle Tweaks")
            local FearVehicleSettings = FearVehicles:list("Vehicle Settings")
            FearVehicles:toggle_loop("Toggle Engine", {}, "Cut off/On your Engine", function()
                FearCommands("turnengineoff")
            end)

            FearVehicles:toggle("Toggle No Traffic", {}, "Toggle On/Off Traffic if NPC are driving.\nNOTE: It will affects nearby players who drive.\nChanging the session will revert back Normal Traffic NPC.", function(on)
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

            FearVehicles:toggle("Infinite Ammo", {"fvehinf"}, "Able to spam every each weapon which have limited ammo.\n\nCompatible with Deluxo, Oppressor/MK2, B-11 Strikeforce, etc...", function()
                local user_ped = players.user_ped()
                local vehicle = entities.get_user_vehicle_as_handle()
                if vehicle ~= 0 then
                    if VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(vehicle) then
                        for i = 0, 3 do
                            local ammo = VEHICLE.GET_VEHICLE_WEAPON_RESTRICTED_AMMO(vehicle, i)
                            if ammo ~= -1 then
                                VEHICLE.SET_VEHICLE_WEAPON_RESTRICTED_AMMO(vehicle, i, -1)
                            end
                        end
                    end
                end
            end)

            FearVehicles:toggle_loop("Toggle Car Horn", {}, "Toggle Enable/Disable Car Horn.", function()
                local vehicle = entities.get_user_vehicle_as_handle()
                if vehicle ~= 0 then
                    AUDIO.SET_HORN_ENABLED(vehicle, false)
                end
            end, function()
                local vehicle = entities.get_user_vehicle_as_handle()
                if vehicle ~= 0 then
                    AUDIO.SET_HORN_ENABLED(vehicle, true)
                end
            end)

            FearVehicles:toggle_loop("Quick Start Engine", {}, "Reduce time for start engine car and drive quick in 1 seconds.", function()
                if PED.IS_PED_GETTING_INTO_A_VEHICLE(PLAYER.PLAYER_PED_ID()) then
                    local veh = PED.GET_VEHICLE_PED_IS_ENTERING(PLAYER.PLAYER_PED_ID())
                    if veh ~= 0 then
                        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
                        VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, true)
                    end
                end
            end)

            FearVehicles:toggle_loop("Boost Heli Engine", {}, "Enable the feature will make helicopter faster than 1 second\nDisable the feature will able to stop engine and continue.", function()
                if entities.get_user_vehicle_as_handle() ~= 0 then
                    VEHICLE.SET_HELI_BLADES_FULL_SPEED(entities.get_user_vehicle_as_handle())
                else
                    VEHICLE.SET_HELI_BLADES_SPEED(entities.get_user_vehicle_as_handle(), 0)
                end
            end)

            FearVehicles:toggle_loop("Stealth Godmode Vehicle", {}, "Toggle Stealth Godmode vehicle.\n\nNOTE: Most Menus will not able to detect as vehicle god mode, exception biggest menus can detect such as Stand, 2Take1.", function()
                ENTITY.SET_ENTITY_PROOFS(entities.get_user_vehicle_as_handle(), true, true, true, true, true, 0, 0, true)
                ENTITY.SET_ENTITY_PROOFS(PED.GET_VEHICLE_PED_IS_IN(players.user(), false), false, false, false, false, false, 0, 0, false)
            end)

            FearVehicles:toggle_loop("Infinite Countermeasures", {}, "Only works in plane if user has countermeasures.\nIt will able to counter some weaponized planes with homing missiles.", function()
                local current_car = entities.get_user_vehicle_as_handle()
                if VEHICLE.GET_VEHICLE_COUNTERMEASURE_AMMO(current_car) < 100 then
                    VEHICLE.SET_VEHICLE_COUNTERMEASURE_AMMO(current_car, 400)
                end
            end)

            FearA10Warthog = FearVehicles:toggle_loop("A-10 Warthog Avenger", {}, "Only Works on the B-11. Makes the Cannon like how it is in Real Life, you could make BRRRTTT.", function(on)
                if VEHICLE.IS_VEHICLE_MODEL(entities.get_user_vehicle_as_handle(), 1692272545) then
                    local A10_while_using = entities.get_user_vehicle_as_handle()
                    local CorCanPosition = ENTITY.GET_ENTITY_BONE_POSTION(A10_while_using, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(A10_while_using, "weapon_1a"))
                    local target = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(A10_while_using, 0, 175, 0)
                    if PAD.IS_CONTROL_PRESSED(114, 114) then
                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(CorCanPosition['x'], CorCanPosition['y'], CorCanPosition['z'], target['x']+math.random(-3,3), target['y']+math.random(-3,3), target['z']+math.random(-3,3), 100.0, true, 3800181289, players.user_ped(), true, false, 100.0)
                    end
                else
                    util.toast(FearScriptNotif.."\nYou have to be in a B-11 Strikeforce to use the feature.")
                    menu.trigger_command(FearA10Warthog, "off")
                end
            end)

            ------================------
            ---   Vehicle Settings
            ------================------

                local FearVehicleWCompart = {
                    { "All" },
                    { "Left front window" }, -- 0
                    { "Right front window" }, -- 1
                    { "Left rear window" }, -- 2
                    { "Right rear window " }, -- 3
                    { "Front windshield window" }, -- 4
                    { "Rear windshield window" } -- 5
                }
                local FearVehicleWindowParts = 1 
                FearVehicleSettings:divider("FearVehicles Settings")
                FearVehicleSettings:list_select("Select Part Windows", {}, "", FearVehicleWCompart, 1, function(value)
                    FearVehicleWindowParts = value
                end)

                FearVehicleSettings:toggle_loop("Toggle Windows (Open/Close)", {}, "", function()
                    local vehicle = entities.get_user_vehicle_as_handle()
                    if vehicle ~= 0 then
                        if FearVehicleWindowParts == 1 then
                            for i = 0, 7 do
                                VEHICLE.ROLL_DOWN_WINDOW(vehicle, i)
                            end
                        elseif FearVehicleWindowParts > 1 then
                            VEHICLE.ROLL_DOWN_WINDOW(vehicle, FearVehicleWindowParts - 2)
                        end
                    end
                end, function()
                    local vehicle = entities.get_user_vehicle_as_handle()
                    if vehicle ~= 0 then
                        if FearVehicleWindowParts == 1 then
                            for i = 0, 7 do
                                VEHICLE.ROLL_UP_WINDOW(vehicle, i)
                            end
                        elseif FearVehicleWindowParts > 1 then
                            VEHICLE.ROLL_UP_WINDOW(vehicle, FearVehicleWindowParts - 2)
                        end
                    end
                end)

                FearVehicleSettings:action("Repair Windows", {}, "", function()
                    local vehicle = entities.get_user_vehicle_as_handle()
                    if vehicle ~= 0 then
                        if FearVehicleWindowParts == 1 then
                            for i = 0, 7 do
                                VEHICLE.FIX_VEHICLE_WINDOW(vehicle, i)
                            end
                        elseif FearVehicleWindowParts > 1 then
                            VEHICLE.FIX_VEHICLE_WINDOW(vehicle, FearVehicleWindowParts - 2)
                        end
                    end
                end)

                FearVehicleSettings:action("Break Windows", {}, "", function()
                    local vehicle = entities.get_user_vehicle_as_handle()
                    if vehicle ~= 0 then
                        if FearVehicleWindowParts == 1 then
                            for i = 0, 7 do
                                VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, i)
                            end
                        elseif FearVehicleWindowParts > 1 then
                            VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, FearVehicleWindowParts - 2)
                        end
                    end
                end)

                local FearDustCar = 0.0
                FearVehicleSettings:click_slider("Dust Car Vehicle", {}, "Applies Dust Car Vehicle.", 0.0, 15.0, 0.0, 1.0, function(value)
                    FearDustCar = value
                    local vehicle = entities.get_user_vehicle_as_handle()
                    if vehicle ~= 0 then
                        VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, FearDustCar)
                    end
                end)

                FearVehicleSettings:divider("Vehicle Tweaks")

                FearVehicleSettings:slider("Change Vehicle Seat", {}, "Change Vehicle Seat while driving.", -1, 8, -1, 1, function(value)
                    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                        PED.SET_PED_INTO_VEHICLE(players.user_ped(), PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false), value)
                    else
                        FearToast(FearScriptNotif.."\nHey, we can't recognize where do you sit. Change your sit, first.")
                    end
                end)

        ------================------
        ---   Online Functions
        ------================------

            FearOnline:divider("FearScript Online")
            local FearSessionL = FearOnline:list("Session")
            local FearToggleSelf = true
            

                local FearStandID = FearPath("Online>Protections>Detections>Stand User Identification")
                FearOnline:toggle("Toggle Stand User ID", {"fearstandid"}, "Toggle Stand Users ID Verification.\nNOTE: Toggle Stand User ID will not able to do something like Kick/Crash.", function(toggle)
                if toggle then
                    FearCommand(FearStandID, "on")
                else
                    FearCommand(FearStandID, "off")
                    end
                end)
            
                FearOnline:toggle_loop("Bruteforce Script Host", {}, "Brute Force Script Host to unlock some features such as unfreeze clouds, loading screen, etc...", function()
                    FearCommands("givesh"..players.get_name(players.user()))
                end)

                FearOnline:toggle_loop("Enforce Nightclub", {""}, "Boost your popularity and keep safe.", function()
                    menu.trigger_command(menu.ref_by_path("Online>Quick Progress>Set Nightclub Popularity", 38), 100)
                    util.yield(2000)
                end)

            ------================------
            ---   Session Features
            ------================------

            FearSessionL:divider("FearOnline Session")
            player_count = FearSessionL:divider(get_player_count())

            local function RNGCount(min, max)
                return math.random(min, max)
            end

                FearSessionL:action("Find Public Session (Max)", {"fearsmax"}, "Join the Public Session.\nYou will not have the same chance, it's a game of probability.", function()
                    FearCommands("go public")
                    
                    local rngValue = math.random(1, 100)
                    local playerCount = 0
                    
                    if rngValue <= 60 then -- 60% chance of finding 17-21 players
                        playerCount = math.random(17, 21)
                    elseif rngValue <= 30 then -- 30% chance of finding 22-25 players
                        playerCount = math.random(22, 25)
                    else -- 10% chance of finding 26-30 players
                        playerCount = math.random(26, 30)
                    end
                    
                    FearCommands("playermagnet " ..playerCount)
                    FearToast(FearScriptNotif.."\nYou will gonna join the session approximately atleast: "..playerCount.." players. (Not Precise, Remember)")
                
                    local loadTime = math.random(20000, 60000) -- 20 seconds / 1 min random time to able to reset player magnet
                    FearTime(loadTime)
                    FearCommands("playermagnet 0") -- Take time to revert the settings.
                end)
    
                FearSessionL:action("Find Public Session (Less)", {"fearsless"}, "Join the Public Session.\nYou will not have the same chance, it's a game of probability.", function()
                    FearCommands("go public")
                    
                    local rngValue = math.random(1, 100)
                    local playerCount = 0
                    
                    if rngValue <= 75 then -- 75% chance of finding 1-4 players
                        playerCount = math.random(1, 4)
                    elseif rngValue <= 20 then -- 20% chance of finding 5-9 players
                        playerCount = math.random(5, 9)
                    else -- 5% chance of finding 10-16 players
                        playerCount = math.random(10, 16)
                    end
                    
                    FearCommands("playermagnet " ..playerCount)
                    FearToast(FearScriptNotif.."\nYou will gonna join the session approximately atleast: "..playerCount.." players. (Not Precise, Remember)")
                
                    local loadTime = math.random(20000, 60000) -- 20 seconds / 1 min random time to able to reset player magnet
                    FearTime(loadTime)
                    FearCommands("playermagnet 0") -- Take time to revert the settings.
                end)

                FearSessionL:action("Find Random Session", {"fearsrand"}, "Join the Public Session.\nYou will not have the same chance, it's a game of probability.", function()
                    FearCommands("go public")
                    
                    local rngValue = math.random(1, 100)
                    local playerCount = 0
                    
                    if rngValue <= 10 then -- 10% chance of finding 1-4 players
                        playerCount = math.random(1, 4)
                    elseif rngValue <= 50 then -- 40% chance of finding 5-9 players
                        playerCount = math.random(5, 9)
                    elseif rngValue <= 80 then -- 30% chance of finding 10-19 players
                        playerCount = math.random(10, 19)
                    else -- 20% chance of finding 20-29 players
                        playerCount = math.random(20, 29)
                    end
                    
                    FearCommands("playermagnet " ..playerCount)
                    FearToast(FearScriptNotif.."\nYou will gonna join the session approximately atleast: "..playerCount.." players. (Not Precise, Remember)")
            
                    local loadTime = math.random(20000, 60000) -- 20 seconds / 1 min random time to able to reset player magnet
                    FearTime(loadTime)
                    FearCommands("playermagnet 0") -- Take time to revert the settings.
                end)
    

                FearSessionL:divider("Main Tweaks")
                FearSessionL:toggle_loop("Exclude Self", {"fexcludeself"}, "Exclude Self for using these features.\nNOTE: It will includes Main Tweaks and Game Tweaks.", function()
                    FearToggleSelf = on == false
                end)
                local FearBountySess = FearSessionL:list("Bounty Features")
                local FearVehicleSess = FearSessionL:list("Vehicles Features")
                local FearSoundSess = FearSessionL:list("Sound Features", {}, "WARNING: Don't use anything if you don't wanna break your ear.\n\nREAD before clicking: Repeated use of this feature can make you deaf like assault rifles, airplane engines, rocket motors, etc... creates tinnitus, or whistling. It is a prevention above all.\n\nYou are responsible for your actions if someone is deaf or hard of hearing")

            ----=====================================================----
            ---                 Bounty Features
            ---     All of the functions, Bounty Functions
            ----=====================================================----

                    FearBountySess:divider("FearSession Bounty")
                    FearBountyValue = FearBountySess:slider("Bounty Value",{"fearbountys"}, "Chose the amount of the bounty offered automatically.", 0, 10000, 0 , 1, function(value)end)
                    
                    FearBountySess:toggle("Auto Bounty", {}, "Put everyone automatically Bounty to all players." ,function()
                        for _,pid in pairs(players.list(FearToggleSelf)) do
                            if FearSession() and players.get_bounty(pid) ~= menu.get_value(FearBountyValue) and players.get_name(pid) ~= "UndiscoveredPlayer" then
                                FearCommands("bounty"..players.get_name(pid).." "..menu.get_value(FearBountyValue))
                            end
                        end
                        util.yield(1000)
                    end)

                    FearBountySess:action("Manual Bounty", {}, "Put everyone manually Bounty to all players." ,function()
                        for _,pid in pairs(players.list(FearToggleSelf)) do
                            if FearSession() and players.get_bounty(pid) ~= menu.get_value(FearBountyValue) and players.get_name(pid) ~= "UndiscoveredPlayer" then
                                FearCommands("bounty"..players.get_name(pid).." "..menu.get_value(FearBountyValue))
                            end
                        end
                        util.yield(1000)
                    end, nil, nil, COMMANDPERM_RUDE)

            ----=====================================================----
            ---                 Vehicle Tweaks
            ---     All of the functions, spawning cars, etc...
            ----=====================================================----

                FearVehicleSess:divider("FearSession Vehicle")
                local FearPlateName
                FearToggleGod = FearVehicleSess:toggle_loop("Toggle Invincible Cars", {}, "Turn On/Off Invincible Car, exception don't use weaponized weapons, I will not recommend you use.\nNOTE: It will be absurd to enable the features make causing griefing constantly.\nNOTE: It will applicable for 'Friendly Features'.", function() end)
                FearToggleCustom = FearVehicleSess:toggle_loop("Toggle Upgrade Cars", {}, "Toggle On/Off for Maximum Car.\nNOTE: It will applicable for 'Friendly Features'.", function()end)
                FearPlateIndex = FearVehicleSess:slider("Plate Color", {"fplatecolor"}, "Choose Plate Color.\nNOTE: It will applicable for 'Friendly Features'.", 0, 5, 0, 1, function()end)
                FearVehicleSess:text_input("Plate Name", {"fearplateall"}, "Apply Plate Name when summoning vehicles.\nNOTE: It will also too apply to 'Friendly Features' spawning vehicles.\nYou are not allowed to write more than 8 characters.\nNOTE: It will applicable for 'Friendly Features'.", function(name)
                    FearPlateName = name:sub(1, 8)
                end)

                FearVehicleSess:action("Spawn Vehicle", {"fearspawn"}, "Spawn everyone a vehicle.\nNOTE: It will applied also some modification like Plate License (name/color)", function (click_type)
                    menu.show_command_box_click_based(click_type, "fearspawn ")
                end,
                function (txt)
                    local hash = util.joaat(txt)
                    
                    if not STREAMING.HAS_MODEL_LOADED(hash) then
                        load_model(hash)
                    end
                    local function upgrade_vehicle(vehicle)
                        if menu.get_value(FearToggleCustom) == true then
                            for i = 0,49 do
                                local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                                VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                            end
                        else
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                        end
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, menu.get_value(FearPlateIndex))
                        if FearPlateName == nil then
                            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, FearGeneratorPlate())
                        else
                            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, FearPlateName)
                        end
                    end
                    for k,v in pairs(players.list(true, true, true)) do
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(v)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                    
                        local vehicle = entities.create_vehicle(hash, c, 0)
                        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(FearToggleGod))
                        upgrade_vehicle(vehicle)
                        request_control_of_entity(vehicle)
                        FearTime()
                    end
                end)

                FearVehicleSess:action("Summon Adder Fool", {}, "Spawn everyone Adder", function ()
                    local function upgrade_vehicle(vehicle)
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, menu.get_value(FearPlateIndex))
                        if FearPlateName == nil then
                            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, FearGeneratorPlate())
                        else
                            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, FearPlateName)
                        end
                        if menu.get_value(FearToggleCustom) == true then
                            for i = 0,49 do
                                local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                                VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                            end
                        else
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                        end
                    end
                    local function give_adderl(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                    
                        local hash = util.joaat("adder")
                    
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            load_model(hash)
                        end
                        local adder1 = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        ENTITY.SET_ENTITY_INVINCIBLE(adder1, menu.get_value(FearToggleGod))
                        upgrade_vehicle(adder1)
                    end
                    for k,v in pairs(players.list(true, true, true)) do
                        give_adderl(v)
                        util.yield()
                    end
                end)

                FearVehicleSess:action("Summon Oppressor MK2", {}, "Spawn everyone Oppressor", function ()
                    local function upgrade_vehicle(vehicle)
                        if menu.get_value(FearToggleCustom) == true then
                            for i = 0,49 do
                                local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                                VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                            end
                        else
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
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
                        ENTITY.SET_ENTITY_INVINCIBLE(oppressor, menu.get_value(FearToggleGod))
                        upgrade_vehicle(oppressor)
                    end
                    for k,v in pairs(players.list(true, true, true)) do
                        give_oppressor(v)
                        util.yield()
                    end
                end)

                FearVehicleSess:action("Summon Leopard 2A (Rhino)", {}, "Spawn everyone Tank", function ()
                    local function upgrade_vehicle(vehicle)
                        if menu.get_value(FearToggleCustom) == true then
                            for i = 0,49 do
                                local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                                VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                            end
                        else
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                        end
                    end
                    local function give_tank(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 7.5, 0.0)
                    
                        local hash = util.joaat("rhino")
                    
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            load_model(hash)
                        end
                    
                        local tank = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        ENTITY.SET_ENTITY_INVINCIBLE(tank, menu.get_value(FearToggleGod))
                        upgrade_vehicle(tank)
                    end
                    for k,v in pairs(players.list(true, true, true)) do
                        give_tank(v)
                        util.yield()
                    end
                end)

                FearVehicleSess:action("Summon Dogfight Plane", {}, "Spawn everyone Lazer", function ()
                    local function upgrade_vehicle(vehicle)
                        if menu.get_value(FearToggleCustom) == true then
                            for i = 0,49 do
                                local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                                VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                            end
                        else
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                        end
                    end
                    local function give_plane(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 11.0, 0.0)
                    
                        local hash = util.joaat("lazer")
                    
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            load_model(hash)
                        end
                    
                        local lazer = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        ENTITY.SET_ENTITY_INVINCIBLE(lazer, menu.get_value(FearToggleGod))
                        upgrade_vehicle(lazer)
                    end
                    for k,v in pairs(players.list(true, true, true)) do
                        give_plane(v)
                        FearTime()
                    end
                end)

            ----=====================================================----
            ---                 Sound Session 
            ---     All of the functions, improving the sessions
            ----=====================================================----

                FearSoundSess:divider("FearSession Sounds")
                FearSoundSess:action("Stop Completely Sounds", {}, "Able to stop the earrape/sounds can might breakup the session.\n\nTIP: spamming the feature will speed up stop sounds.", function()
                    for i=0,99 do
                        AUDIO.STOP_SOUND(i)
                        util.yield() 
                     end
                end)

                FearSoundSess:toggle_loop("Alarm Loop",{'fearaall'}, "Put Alarm to the entire session?\nNOTE: It may be detected by any modders and may karma you.\n\nToggle 'Exclude Self' to avoid using these functions.",function()
                    for _,pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Air_Defences_Activated", PLAYER.GET_PLAYER_PED(pid), "DLC_sum20_Business_Battle_AC_Sounds", true, true)
                            players.send_sms(pid, players.user(), "WARNING: Ukraine has been invaded by Russia. Fuck Russia.")
                        end
                        FearTime(30)
                    end
                    FearTime(100)
                end)

                FWarningSS = FearSoundSess:action("Earrape Session", {'fearsound'}, "Put Earrape Alarm to the entire session?\nYou will be impacted for using the sound (WARNING)\n\nRepeated use of this feature can make you deaf like assault rifles, airplane engines, rocket motors, etc... creates tinnitus, or whistling. It is a prevention above all.",function(warningtype)
                    menu.show_warning(FWarningSS, warningtype, "WARNING: Do you really put Earrape Sound all around in the session? Because it was a dangerous idea to put these sounds.\n\nREAD before clicking: Repeated use of this feature can make you deaf like assault rifles, airplane engines, rocket motors, etc... creates tinnitus, or whistling. It is a prevention above all.\n\nYou are responsible for your actions if someone is deaf or hard of hearing.", function()
                        for _, pid in pairs(players.list(true, true, true)) do
                            for i = 0, 200 do -- Volume Sound
                                local player_pos = players.get_position(pid)
                                AUDIO.PLAY_SOUND_FROM_COORD(-1, "BED", player_pos.x, player_pos.y, player_pos.z, "WASTEDSOUNDS", true, 9999, false)
                            end
                        end
                    end)
                end)                                                                

            ----=====================================================----
            ---                 Game Tweaks
            ---     All of the functions, improving the sessions
            ----=====================================================----

                FearSessionL:divider("Game Tweaks")
                FearSessionL:toggle("Disarm all Weapons Permanently",{'feardall'}, "Disarm weapon entirely in the session?\nAlternative to Stand, better because it will toggle everyone and not players having weapon.\n\nToggle 'Exclude Self' to avoid using these functions.",function(toggle)
                    for _,pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            if toggle then
                                FearCommands("disarm"..players.get_name(pid))
                            else
                                FearCommands("disarm"..players.get_name(pid))
                            end
                        end
                        util.yield(150)
                    end
                    util.yield(5000)
                end)

                FearSessionL:toggle_loop("Loop Explode All Session",{'feareall'}, "Explode the entire session?\nNOTE: It may be detected by any modders and may karma you.\n\nToggle 'Exclude Self' to avoid using these functions.",function()
                    for _,pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            FearCommands("explode"..players.get_name(pid))
                        end
                        util.yield(150)
                        update_player_count()
                    end
                    util.yield(5000)
                end)

                FearSessionL:toggle("Riot Mode", {"fearrt"}, "Put Riot Mode in the session.\nMake sure you don't wanna live this shit world.", function(toggle) MISC.SET_RIOT_MODE_ENABLED(toggle)end)

                FearSessionL:toggle_loop("Pretend God Mode", {"feargall"}, "This is not the real god mode, you shoot (he's not invincible), but if you fight with fist, it will consider Invincible.\n\nNOTE: It may detected like 'attacking while invulnerable' if your friend or your foe attack, be careful.",function()
                    local FearToggleSelf_God = false
                    for _, pid in pairs(players.list(FearToggleSelf_God)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" and PLAYER.GET_PLAYER_INVINCIBLE(PLAYER.GET_PLAYER_PED(pid)) == false then
                            ENTITY.SET_ENTITY_INVINCIBLE(PLAYER.GET_PLAYER_PED(pid), true)
                            PLAYER.SET_PLAYER_INVINCIBLE(PLAYER.GET_PLAYER_PED(pid), true)
                        else
                            ENTITY.SET_ENTITY_INVINCIBLE(PLAYER.GET_PLAYER_PED(pid), false)
                            PLAYER.SET_PLAYER_INVINCIBLE(PLAYER.GET_PLAYER_PED(pid), false)
                        end
                    end
                end)

                FearSessionL:toggle_loop("Camera Moving", {'fearcms'}, "Moving, shake with the hardest force in the session.\n\nToggle 'Exclude Self' to avoid using these features", function()
                    for _, pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            CameraMoving(players.get_name(pid), 50000)
                        end
                    end
                end)

                FearSessionL:toggle_loop("I don't like Silencers", {}, "Remove all weapons to all players while trying to use silencer weapons.\n\nToggle 'Exclude Self' to avoid using these features", function()
                    for _, pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and WEAPON.IS_PED_CURRENT_WEAPON_SILENCED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)) == true and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            WEAPON.REMOVE_ALL_PED_WEAPONS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
                        end
                    end
                end)

                FearTP1Warning = FearSessionL:action("Near Location Teleport", {"feartll"}, "Teleport the entire session?\nAlternative to Stand Features but may not karma you.\n\nToggle 'Exclude Self' to avoid using these functions.",function(type)
                    menu.show_warning(FearTP1Warning, type, "Do you really want teleport the entire session to the same apartment location?\nNOTE: Teleporting all players will cost a fight against players.", function()
                    for _, pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            FearCommands("aptme"..players.get_name(pid))
                            end
                        end
                    end)
                end)

                local timerStarted = false
                FearWarningNuke = FearSessionL:action("Putin Button Session", {}, "I love Vladimir Putin but we need to click to erase these western pigs.", function(type)
                    menu.show_warning(FearWarningNuke, type, "Do you really want send Putin to invade WW3?\nYou might be detected by modder and it will cost karma.", function()
                        if not timerStarted then
                            timerStarted = true
                            for i = 5, 1, -1 do
                                local delay = (i > 2 and i % 2 == 1) and 125 or 500
                                util.toast(FearScriptNotif.."\nReady to Explode?\n"..i.." seconds to detonate.")
                                util.yield(750)
                                Fear.play_all("5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", delay)
                                util.yield(delay)
                            end
                            util.toast(FearScriptNotif.."\nDetonation Ready, you are ready to nuke the session.")
                            Fear.play_all("Air_Defences_Activated", "DLC_sum20_Business_Battle_AC_Sounds", 3000)
                            for i = 0, 31 do
                                if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
                                    local ped = PLAYER.GET_PLAYER_PED(i)
                                    ENTITY.SET_ENTITY_INVINCIBLE(ped, false)
                                end
                            end
                            for i = 0, 31 do
                                if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
                                    local ped = PLAYER.GET_PLAYER_PED(i)
                                    PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(ped, true)
                                    PED.SET_PED_CAN_BE_SHOT_IN_VEHICLE(ped, true)
                                    PED.SET_PED_CONFIG_FLAG(ped, 32, false)
                                    PED.SET_PED_CONFIG_FLAG(ped, 223, false)
                                    PED.SET_PED_CONFIG_FLAG(ped, 224, false)
                                    PED.SET_PED_CONFIG_FLAG(ped, 228, false)
                                    PED.SET_PED_CONFIG_FLAG(ped, 118, false)
                                end
                            end
                            Fear.explode_all(EARRAPE_FLASH, 0, 150)
                            util.yield(1000)
                            Fear.explode_all(EARRAPE_BED)
                            Fear.explode_all(EARRAPE_NONE)
                            local playersKilled = 0
                            for i = 0, 31 do
                                if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
                                    local ped = PLAYER.GET_PLAYER_PED(i)
                                    local health = ENTITY.GET_ENTITY_HEALTH(ped)
                                    if health <= 0 then
                                        playersKilled = playersKilled + 1
                                    end
                                end
                            end
                            if playersKilled == 0 then
                                util.toast(FearScriptNotif.."\nDetonation complete!\nNo one has been eliminated.")
                            else
                                util.toast(FearScriptNotif.."\nDetonation complete!\n"..playersKilled.." player(s) has been eliminated.")
                            end
                            timerStarted = false
                        else
                            util.toast(FearScriptNotif.."\nI'm sorry but the timer has already started.")
                        end
                    end)
                end)
                

                FearTPWarning = FearSessionL:action("Random Teleport Homogenous", {'feartprandho'}, "Teleport the entire session into random apartment?\nAlternative to Stand Features but may not karma you.\n\nToggle 'Exclude Self' to avoid using these functions.", function(type)
                    menu.show_warning(FearTPWarning, type, "Do you really want teleport the entire session to the random apartment?\nNOTE: Teleporting all players will cost a fight against players.", function()
                    local FearAPPRand = RNGCount(1, 114)
                    for _, pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            FearCommands("apt"..FearAPPRand..players.get_name(pid))
                            end
                        end
                    end)
                end)

                FearSessionL:action("Random Teleport Heterogenous", {'feartprandhe'}, "Teleport each player in the session to a random apartment heterogeneously?\nAlternative to Stand Features but may not karma you.\n\nToggle 'Exclude Self' to avoid using these functions.", function()
                local assignedApartments = {}
                    for _, pid in pairs(players.list(FearToggleSelf)) do
                        if FearSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                            local FearAPPRand
                            repeat
                                FearAPPRand = RNGCount(1, 114)
                            until not assignedApartments[FearAPPRand]
                
                            assignedApartments[FearAPPRand] = true
                            FearCommands("apt"..FearAPPRand..players.get_name(pid))
                        end
                    end
                end)
                  
            ----=====================================================----
            ---                 World Features
            ---     All of the functions, changing the mind of world
            ----=====================================================----

            FearWorld:divider("FearScript World")    
            local FearDestroyWorld = FearWorld:list("Panic Tools", {}, "Alternative to Menyoo called 'Massacre Mode', but slightly better with improvements.")

                ----=====================================================----
                ---                 Griefing Tools
                ---  All of the functions of world which change the mind
                ----=====================================================----
                    FearDestroyWorld:divider("FearWorld Panic Mode")  
                    
                    local FearDeathPoint = {
                        groundpoint = 100,
                        vehicle_toggle = true,
                        ped_toggle = true,
                        object_toggle = false,
                        forward_speed = 30,
                        forward_degree = 30,
                        has_gravity = true,
                        time_delay = 100,
                        exclude_mission = false,
                        exclude_dead = false
                    }
                    
                    FearDestroyWorld:toggle_loop("Toggle Panic Mode", {}, "Attract all entites around of you.\n\nNOTE: You will also too attract yourself and can make strange movements.", function()
                        -- Vehicle
                        if FearDeathPoint.vehicle_toggle then
                            for _, ent in pairs(GET_NEARBY_VEHICLES(players.user_ped(), FearDeathPoint.groundpoint)) do
                                if not IS_PLAYER_VEHICLE(ent) then
                                    if FearDeathPoint.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                                    elseif FearDeathPoint.exclude_dead and ENTITY.IS_ENTITY_DEAD(ent) then
                                    else
                                        REQUEST_CONTROL_ENTITY(ent, 10)
                                        VEHICLE.SET_VEHICLE_MAX_SPEED(ent, 99999.0)
                                        ENTITY.FREEZE_ENTITY_POSITION(ent, false)
                                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(ent, FearDeathPoint.forward_speed)
                                        VEHICLE.SET_VEHICLE_OUT_OF_CONTROL(ent, false, false)
                                        VEHICLE.SET_VEHICLE_GRAVITY(ent, FearDeathPoint.has_gravity)
                                    end
                                end
                            end
                        end
                        if FearDeathPoint.ped_toggle then
                            for _, ent in pairs(GET_NEARBY_PEDS(players.user_ped(), FearDeathPoint.groundpoint)) do
                                if not IS_PED_PLAYER(ent) then
                                    if FearDeathPoint.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                                    elseif FearDeathPoint.exclude_dead and ENTITY.IS_ENTITY_DEAD(ent) then
                                    else
                                        REQUEST_CONTROL_ENTITY(ent, 10)
                                        ENTITY.SET_ENTITY_MAX_SPEED(ent, 99999.0)
                                        ENTITY.FREEZE_ENTITY_POSITION(ent, false)
                                        local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(ent)
                                        local force = {}
                                        force.x = vector.x * math.random(-1, 1) * FearDeathPoint.forward_degree
                                        force.y = vector.y * math.random(-1, 1) * FearDeathPoint.forward_degree
                                        force.z = vector.z * math.random(-1, 1) * FearDeathPoint.forward_degree
                    
                                        ENTITY.APPLY_FORCE_TO_ENTITY(ent, 1, force.x, force.y, force.z, 0.0, 0.0, 0.0, 1, false, true, true,
                                            true, true)
                                        ENTITY.SET_ENTITY_HAS_GRAVITY(ent, FearDeathPoint.has_gravity)
                                    end
                                end
                            end
                        end
                        if FearDeathPoint.object_toggle then
                            for _, ent in pairs(GET_NEARBY_OBJECTS(players.user_ped(), FearDeathPoint.groundpoint)) do
                                if FearDeathPoint.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                                elseif FearDeathPoint.exclude_dead and ENTITY.IS_ENTITY_DEAD(ent) then
                                else
                                    REQUEST_CONTROL_ENTITY(ent, 10)
                                    ENTITY.SET_ENTITY_MAX_SPEED(ent, 99999.0)
                                    ENTITY.FREEZE_ENTITY_POSITION(ent, false)
                                    local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(ent)
                                    local force = {}
                                    force.x = vector.x * math.random(-1, 1) * FearDeathPoint.forward_degree
                                    force.y = vector.y * math.random(-1, 1) * FearDeathPoint.forward_degree
                                    force.z = vector.z * math.random(-1, 1) * FearDeathPoint.forward_degree
                    
                                    ENTITY.APPLY_FORCE_TO_ENTITY(ent, 1, force.x, force.y, force.z, 0.0, 0.0, 0.0, 1, false, true, true,
                                        true, true)
                                    ENTITY.SET_ENTITY_HAS_GRAVITY(ent, FearDeathPoint.has_gravity)
                                end
                            end
                        end
                        FearTime(FearDeathPoint.time_delay)
                    end)
                    
                    FearDestroyWorld:divider("Panic Mode Settings")
                    local groundpoint_slider = FearDestroyWorld:slider("Panic Mode Range", {'ffpanicrange'}, "Range centered of you, will able to choose range distance which it will attract.", 0, 1000, 100, 10, function(value)
                        FearDeathPoint.groundpoint = value
                    end)

                    FearDestroyWorld:toggle("Toggle Car", {}, "", function(toggle)
                        FearDeathPoint.vehicle_toggle = toggle
                    end, true)

                    FearDestroyWorld:toggle("Toggle NPC", {}, "", function(toggle)
                        FearDeathPoint.ped_toggle = toggle
                    end, true)

                    FearDestroyWorld:toggle("Toggle Object", {}, "", function(toggle)
                        FearDeathPoint.object_toggle = toggle
                    end)

                    FearDestroyWorld:slider("Speed Cars", {'ffpspeedcar'}, "", 0, 1000, 30, 10,
                        function(value)
                            FearDeathPoint.forward_speed = value
                        end)

                    FearDestroyWorld:slider("Speed Propulsion of NPCs", {'ffpanspeednpc'}, "", 0, 1000, 30, 10,
                    function(value)
                        FearDeathPoint.forward_degree = value
                    end)

                    FearDestroyWorld:toggle("Gravity Entities", {}, "", function(toggle)
                        FearDeathPoint.has_gravity = toggle
                    end, true)

                    FearDestroyWorld:slider("Delay Time (ms)", {'ffdelaytime'}, "", 0, 3000, 100, 10, function(value)
                        FearDeathPoint.time_delay = value
                    end)

                    FearDestroyWorld:toggle("Exclude Mission", {}, "", function(toggle)
                        FearDeathPoint.exclude_mission = toggle
                    end)

                    FearDestroyWorld:toggle("Exclude Deaths", {}, "", function(toggle)
                        FearDeathPoint.exclude_dead = toggle
                    end)
                    
                    local is_groundpoint_slider_onFocus
                    menu.on_focus(groundpoint_slider, function()
                        is_groundpoint_slider_onFocus = true
                        util.create_tick_handler(function()
                            if not is_groundpoint_slider_onFocus then
                                return false
                            end
                    
                            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
                            GRAPHICS.DRAW_MARKER_SPHERE(coords.x, coords.y, coords.z, FearDeathPoint.groundpoint, 200, 50, 200, 0.5)
                        end)
                    end)
                    
                    menu.on_blur(groundpoint_slider, function()
                        is_groundpoint_slider_onFocus = false
                    end)

            ----=====================================================----
            ---                 World Features - Main
            ---     All of the functions, changing the mind of world
            ----=====================================================----

            local positions = {
                v3.new(125.72, -1146.2, 222.75),
                v3.new(118.13, -365.5, 213.06),
                v3.new(-126.54, -508.41, 226.35),
                v3.new(368.63, -656.42, 199.41),
                v3.new(486.79584, -836.7407, 201.24078)
            }
            
            local orientations = {
                v3.new(0, 0, -3),
                v3.new(0, 10, -180), -- test1
                v3.new(10, 0, -118), -- noppe
                v3.new(10, 0, -244), -- No
                v3.new(10, 0, -285) -- No
            }
            
            local currentPosition = 1
            local lastBoeingSent = 0
            
            FearWorld:action("Send Boeing to Twin Towers", {}, "Send Boeing to Twin Towers.\nWARNING: It may possible another aircraft can deviate from its path.\n\nNOTE: You have a delay which you can send another Boeing Plane to the Twin Towers.\nSpamming 'Send Boeing to Twin Towers' will sent 2 planes simultaneously, be careful if you don't wanna block road.", function()
                if lastBoeingSent ~= 1 then
                    lastBoeingSent = 1
                else
                    lastBoeingSent = 0
                    return
                end
                
                local hash = util.joaat("jet")
                load_model(hash)
                while not STREAMING.HAS_MODEL_LOADED(hash) do
                    util.yield()
                end
            
                local pos = positions[currentPosition]
                local orient = orientations[currentPosition]
            
                local boeing = entities.create_vehicle(hash, pos, orient.z)
                ENTITY.SET_ENTITY_INVINCIBLE(boeing, menu.get_value(FearToggleGod))
            
                local speed = currentPosition == 1 and 850.0 or 500.0
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(boeing, speed)
                VEHICLE.SET_VEHICLE_MAX_SPEED(boeing, speed)
            
                if currentPosition > 1 then
                    ENTITY.SET_ENTITY_ROTATION(boeing, orient.x, orient.y, orient.z, 2, false)
                    VEHICLE.SET_HELI_BLADES_SPEED(boeing, 0)
                end
            
                VEHICLE.CONTROL_LANDING_GEAR(boeing, 3)
            
                currentPosition = math.random(#positions)
                FearTime()
            end)
            

            local posCas = {v3.new(618.32416, 43.211624, 105.66624), v3.new(1171.9432, -95.993965, 105.080505)}
            local oriTCas = {v3.new(0, 0, -88), v3.new(0, 0, 60)}
            local lastPosition = 0
            
            FearWorld:action("Send Boeing to Casino", {}, "Send Boeing to the Casino.\nWARNING: It may possible another aircraft can deviate from its path if you are spamming. ", function()
                local hash = util.joaat("jet")
                load_model(hash)
                while not STREAMING.HAS_MODEL_LOADED(hash) do
                    util.yield()
                end
            
                local currentPosition = math.random(#posCas)
                while currentPosition == lastPosition do
                    currentPosition = math.random(#posCas)
                end
                lastPosition = currentPosition
            
                local pos = posCas[currentPosition]
                local orient = oriTCas[currentPosition]
            
                local boeing = entities.create_vehicle(hash, pos, orient.z)
                ENTITY.SET_ENTITY_INVINCIBLE(boeing, menu.get_value(FearToggleGod))
            
                local speed = currentPosition == 1 and 850.0 or 500.0
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(boeing, speed)
                VEHICLE.SET_VEHICLE_MAX_SPEED(boeing, speed)
            
                if currentPosition > 1 then
                    ENTITY.SET_ENTITY_ROTATION(boeing, orient.x, orient.y, orient.z, 2, false)
                    VEHICLE.SET_HELI_BLADES_SPEED(boeing, 0)
                end
            
                VEHICLE.CONTROL_LANDING_GEAR(boeing, 3)
                FearTime()
            end)

            FearWorld:toggle("Toggle Blackout", {}, "", function(toggle)
                GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(toggle)
            end) 

            FearWorld:toggle_loop("Disable Godmode Players", {}, "Remove completely godmode player to all players.\n\nNOTE: It will not easier to remove godmode vehicle to all players, almost mod menus blocked it.\nREAD before: You can't remove Godmode Players if they are in interior.", function()
                for i = 0, 31 do
                    if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
                        local ped = PLAYER.GET_PLAYER_PED(i)
                        ENTITY.SET_ENTITY_INVINCIBLE(ped, false)
                    end
                end
            end)
                       
            FearWorld:divider("Vehicle Tweaks")
            FearWorld:action("Blow up your vehicle", {}, "Destroy your own car while using, previous car or current car.\n\nNOTE: Without Godmode, you will instantly die with explosion or burnt-out vehicle.", function()
                local vehicle = entities.get_user_vehicle_as_handle()
                if vehicle ~= 0 then
                    RequestControl(vehicle)
                    VEHICLE.EXPLODE_VEHICLE_IN_CUTSCENE(vehicle)
                end
            end)

            FearWorld:action("Blow up nearby vehicles", {}, "It will guaranteed burning all vehicles except Personal Vehicles.\n\nNOTE: It will affect players while driving and can burn, die easily.", function()
                for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
                    if vehicle ~= entities.get_user_personal_vehicle_as_handle() then
                        RequestControl(vehicle)
                        VEHICLE.EXPLODE_VEHICLE_IN_CUTSCENE(vehicle)
                    end
                end
            end)

            FearWorld:toggle_loop("Disable Godmode Vehicle", {}, "Remove completely godmode vehicle to all players.\n\nNOTE: It will not easier to remove godmode vehicle to all players, almost mod menus blocked it.", function()
                for i = 0, 31 do
                    if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
                        local ped = PLAYER.GET_PLAYER_PED(i)
                        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                            local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                            ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, true)
                            ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
                        end
                    end
                end
            end)   

        ------===============------
        ---   Miscs Functions
        ------===============------

            FearMiscs:divider("FearScript Miscs")
            FearMiscs:readonly("FearScript Version: "..FearVersion)
            FearMiscs:readonly("Stand Version: "..FearSEdition)
            local FearUpdates = FearMiscs:list("Update Config")
            FearUpdates:action("Update Script", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
                auto_update_config.check_interval = 0
                if auto_updater.run_auto_update(auto_update_config) then
                    FearToast(FearScriptNotif.."\nNo updates found.")
                end
            end)

            FearUpdates:action("Update Library", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
                standifylib.check_interval = 0
                if auto_updater.run_auto_update(standifylib) then
                    FearToast(FearScriptNotif.."\nNo updates found.")
                end

                cruiselib.check_interval = 0
                if auto_updater.run_auto_update(cruiselib) then
                    FearToast(FearScriptNotif.."\nNo updates found.")
                end
            end)

            FearMiscs:divider("FearScript Credits")
            FearMiscs:hyperlink("StealthyAD", "https://github.com/StealthyAD")
	        FearMiscs:hyperlink("GitHub Source", "https://github.com/StealthyAD/FearScript-Advanced")
            FearMiscs:divider("FearScript Others")


                local FearMiscsOptions = FearMiscs:list("Miscs Options")
                FearMiscsOptions:divider("FearMiscs Options")
                FearMiscsOptions:slider_float("Radar Zoom Size", {'fradarzoom'}, "You will able to zoom the radar what are you doing right now.\n\nNOTE: Pressing Z or W, depending on your keyboard type, resets the zoom to zero by default.", 0, 1400, 0, 1, function(value) HUD.SET_RADAR_ZOOM(value) end)
                FearMiscsOptions:toggle("Display Money", {}, "", function(toggle)
                    if toggle then
                        HUD.SET_MULTIPLAYER_WALLET_CASH()
                        HUD.SET_MULTIPLAYER_BANK_CASH()
                    else
                        HUD.REMOVE_MULTIPLAYER_WALLET_CASH()
                        HUD.REMOVE_MULTIPLAYER_BANK_CASH()
                    end
                end)

                FearMiscsOptions:toggle_loop("Toggle Skip Cutscene", {}, "Skip automatically cutscene", function() CUTSCENE.STOP_CUTSCENE_IMMEDIATELY() end)
                FearMiscsOptions:toggle("Block Phone Calls", {""}, "Blocks incoming phones calls", function(state)
                    local phone_calls = menu.ref_by_command_name("nophonespam")
                    phone_calls.value = state
                end)

                FearMiscsOptions:toggle("Toggle Radar/HUD", {}, "", function(toggle)
                    if toggle then
                        HUD.DISPLAY_RADAR(false)
                        HUD.DISPLAY_HUD(false)
                    else
                        HUD.DISPLAY_RADAR(true)
                        HUD.DISPLAY_HUD(true)
                    end
                end)

                FearMiscsOptions:divider("Game Miscs")
                FWarningRG = FearMiscsOptions:action("Restart Game", {}, "Leave the game and restart the game.\n\nNOTE: After Restarting the Game, make sure you will inject Stand.", function(click)
                    menu.show_warning(FWarningRG, click, "Are you sure to leave the game?\n\nNOTE: It's an alternative Stand for YEET but it will override restrictions.\n\nIt allows you to override the warnings given by Stand and makes your job easier and restart GTAV easier.", function()
                        MISC.RESTART_GAME()
                    end)
                end)
    
                FWarningLG = FearMiscsOptions:action("Leave Game", {}, "Leave the game.", function(click)
                    menu.show_warning(FWarningLG, click, "Are you sure to leave the game?\n\nNOTE: It's an alternative Stand for YEET but it will override restrictions.", function()
                        MISC.QUIT_GAME()
                    end)
                end)

            local FearMoney = FearMiscs:list("Money Features")
            FearRemoverCash = FearMoney:slider("Choose Value Money", {"fearrm"}, "", 0, 2147483647, 0, 1, function()end)
            FearWF = FearMoney:action("Money Remover Tool", {}, "", function(type)
                menu.show_warning(FearWF, type, "Do you really want remove the money?\nNOTE: You will able to remove your own modded money. This action is irreversible.", function()
                    SET_INT_GLOBAL(262145 + 20288, menu.get_value(FearRemoverCash))
                end)
            end)

            FearMoney:action("Revert Money Tool", {}, "", function()
                SET_INT_GLOBAL(262145 + 20288, 5000)
                FearToast(FearScriptNotif.."\nDefault State applied for Remover Tool.")
            end)
            local FearAlert = FearMiscs:list("Fake Alert")

            FearAlert:action("Custom Alert Suspension", {"ffakesusalert"}, "Put the fake alert of your choice. (Write the date like that: 'February 24 2022')", function()
                FearSus = menu.show_command_box("ffakesusalert ")
            end, function(on_command)
                show_custom_rockstar_alert("You have been suspended from Grand Theft Auto Online until "..on_command..".~n~In addition, your Grand Theft Auto Online character(s) will be reset.~n~Return to Grand Theft Auto V.")
            end)

            FearAlert:action("Ban Message", {"ffakebanp"}, "A Fake Ban Message.", function()
                show_custom_rockstar_alert("You have been banned from Grand Theft Auto Online permanently.~n~Return to Grand Theft Auto V.")
            end)
            
            FearAlert:action("Services Unavailable", {"ffakesu"}, "A Fake 'Servives Unavailable' Message.", function()
                show_custom_rockstar_alert("The Rockstar Game Services are Unavailable right now.~n~Please Return to Grand Theft Auto V.")
            end)

            FearAlert:action("Case Support", {"fcasesupport"}, "A Fake 'Support Channel' Message.", function()
                show_custom_rockstar_alert("Remember, if you find this, this is not the Support Channel.~n~Return to Grand Theft Auto V.")
            end)
            
            FearAlert:action("Custom Alert", {"ffakecustomalert"}, "Put the fake alert of your choice.", function()
                menu.show_command_box("ffakecustomalert ")
            end, function(on_command)
                show_custom_rockstar_alert(on_command)
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
        local FearScriptP = FearPlayer:list("FearScript Tools", {"fearscript"}, "", function()end)
        local FearFriendly = FearScriptP:list("Friendly Features")
        local FearNeutral = FearScriptP:list("Neutral Features", {}, "")
        local FearGriefing = FearScriptP:list("Griefing Features", {}, "")
        local FearAttack = FearScriptP:list("Attack Features", {}, "")
        FearScriptP:toggle("Fast Spectate", {"fearsp"}, "Spectate "..FearPlayerName, function(toggle)
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

            FearFriendly:divider("FearFriendly Advanced")
            FearFriendly:divider("Main Tweaks")
            FearFriendly:action("Unstuck Loading Screen", {"fearuls"}, "Unstuck "..FearPlayerName.." to the clouds or something else could be affect the session.", function()
                FearCommands("givesh"..FearPlayerName)
                FearCommands("aptme"..FearPlayerName)
            end)

            FearFriendly:toggle("Toggle Infinite Ammo", {}, "Put Infinite ammo to "..FearPlayerName..", able to shoot x times without reloading.\nI'm not sure if the function works to players.\n\nNOTE: Don't use the feature if it's against players.", function(toggle)
                if toggle then
                    WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
                else
                    WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), false)
                end
            end)

            FearFriendly:divider("Vehicle Tweaks")
            FearFriendly:action("Spawn vehicle", {"fearspawnv"}, "Summon variable car for " ..FearPlayerName.."\nNOTE: You can spawn every each vehicle of your choice.", function (click_type)
            menu.show_command_box_click_based(click_type, "fearspawnv" .. FearPlayerName .. " ")end,
            function(txt)
                local function platechanger(vehicle)
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, menu.get_value(FearPlateIndex))
                    if FearPlateName == nil then
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, FearGeneratorPlate())
                    else
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, FearPlateName)
                    end
                end
                local function upgradecar(vehicle)
                    if menu.get_value(FearToggleCustom) == true then
                        for i = 0,49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                    else
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                    end
                end
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
        
                local hash = util.joaat(txt)
        
                if not STREAMING.HAS_MODEL_LOADED(hash) then
                    load_model(hash)
                end
                local vehicle = entities.create_vehicle(hash, c, 0)
                ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(FearToggleGod))
                platechanger(vehicle)
                upgradecar(vehicle)
                request_control_of_entity(vehicle)
            end)

            FearFriendly:action("Oppresor Land", {"fearopr"}, "Spawn OppressorLand for "..FearPlayerName, function ()
            local function upgradecar(vehicle)
                if menu.get_value(FearToggleCustom) == true then
                    for i = 0,49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                else
                    local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                    VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
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
            ENTITY.SET_ENTITY_INVINCIBLE(adder, menu.get_value(FearToggleGod))
                upgradecar(oppressor)
            end
                give_ind_oppressor(pid)
                util.yield()
            end)

            FearFriendly:action("Adder Race", {"fearadder"}, "Spawn Adder for "..FearPlayerName, function ()
            local function platechanger(vehicle)
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, menu.get_value(FearPlateIndex))
                if FearPlateName == nil then
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, FearGeneratorPlate())
                else
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, FearPlateName)
                end
            end
            local function upgradecar(vehicle)
                if menu.get_value(FearToggleCustom) == true then
                    for i = 0,49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                else
                    local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                    VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
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
            ENTITY.SET_ENTITY_INVINCIBLE(adder, menu.get_value(FearToggleGod))
                upgradecar(adder)
                platechanger(adder)
            end
                give_adder(pid)
                util.yield()
            end)

        ----=====================----
        --- Griefing     Features
        ----=====================----

            FearGriefing:divider("FearGriefing Advanced")
            FearGriefing:divider("Game Tweaks")
            local FearBounty = FearGriefing:list("Bounty Features",{},"")

            FearGriefing:divider("Player Tweaks")
            local FearCage = FearGriefing:list("Cage Options")

            FearGriefing:action("Kill "..FearPlayerName, {}, "Do you really want kill "..FearPlayerName.." ?\nNOTE: It will affect car if he's in interior or Godmode.",function()
                local function KillPlayer(pid)
                    local entity = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
                    FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'] + 2, 7, 1000, false, true, 0)
                end
                if FearSession() then
                    if FearPlayerName then
                        KillPlayer(pid)
                    end
                    FearTime(150)
                end
                FearTime(500)
            end)
            
            FearGriefing:toggle_loop("Disarm Entire Weapons",{}, "Disarm "..FearPlayerName.."?\nNOTE: It will block Custom Weapon Loadout.",function()
                if FearSession() then
                    if FearPlayerName then
                        FearCommands("disarm"..FearPlayerName)
                    end
                    util.yield(150)
                end
                util.yield(5000)
            end)

            FearGriefing:toggle_loop("Toggle Bulletproof Helmet", {}, "Enable the Bulletproof Helmet will remove helmet, especially for PvP/Combat, but activate the feature may freeze the player quickly.\n\nNOTE: Recommended for PvPs if your opponent are using Thermal Helmet/Riot Helmet/Bulletproof Helmet...", function() 
                if FearSession() then
                    if PED.IS_PED_WEARING_HELMET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)) == true then
                        PED.REMOVE_PED_HELMET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
                    else
                        PED.REMOVE_PED_HELMET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), false)
                    end
                end
            end)

            FearGriefing:toggle_loop("Kill "..FearPlayerName.." Loop", {}, "Kill "..FearPlayerName.." in Loop?",function()
                local function KillPlayer(pid)
                    local entity = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
                    FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'] + 2, 7, 1000, false, true, 0)
                end
                if FearSession() then
                    if FearPlayerName then
                        KillPlayer(pid)
                    end
                    FearTime(150)
                end
                FearTime(500)
            end)

            FearGriefing:toggle_loop("Eliminate Passive Mode Loop", {}, "Are you sure to kill "..FearPlayerName.." during the Loop?", function()
                FearPassiveShot(pid)
            end)

            FearGriefing:toggle_loop("Alarm Loop",{}, "You really want put Alarm to "..FearPlayerName.." ?\nNOTE: It may be detected by player and may possible karma you if he's a modder.",function()
                if FearSession() then
                    if FearPlayerName then
                        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Air_Defences_Activated", PLAYER.GET_PLAYER_PED(pid), "DLC_sum20_Business_Battle_AC_Sounds", true, true)
                    end
                    FearTime(30)
                end
                FearTime(150)
            end)

            FearGriefing:toggle_loop("Camera Moving",{'fearcam'}, "You really want put camera moving "..FearPlayerName.." ?\nNOTE: It may be detected by player and may possible karma you if he's a modder.",function()
                if FearSession() then
                    if FearPlayerName then
                        CameraMoving(pid, 99999)
                    end
                end
            end)

            FearGriefing:action("Send Dog Attack", {}, "", function()
                local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local modelHash = util.joaat("A_C_Chop")
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, -1.0, 0.0)
                local heading = ENTITY.GET_ENTITY_HEADING(player_ped)
        
                local ChopPed = Create_Network_Ped(28, modelHash, coords.x, coords.y, coords.z, heading)
        
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ChopPed, true)
                TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ChopPed, true)
                TASK.TASK_COMBAT_PED(ChopPed, player_ped, 0, 16)
                PED.SET_PED_KEEP_TASK(ChopPed, true)
        
                PED.SET_PED_MONEY(ChopPed, 2000)
                ENTITY.SET_ENTITY_MAX_HEALTH(ChopPed, 30000)
                ENTITY.SET_ENTITY_HEALTH(ChopPed, 30000)
        
                Increase_Ped_Combat_Ability(ChopPed, false, false)
                Increase_Ped_Combat_Attributes(ChopPed)
            end)

            FearGriefing:action("Quick Airstrike", {"ffstrike"}, "Launch Airstrike to "..FearPlayerName.."\nNOTE: It will randomly spawned how many missiles will drop on the player.", function()
                local pidPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local abovePed = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(pidPed, 0, 0, 8)
                local missileCount = RNGCount(8, 48)
                for i=1, missileCount do
                    local missileOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(pidPed, math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(abovePed.x, abovePed.y, abovePed.z, missileOffset.x, missileOffset.y, missileOffset.z, 100, true, 1752584910, 0, true, false, 250)
                end
            end)

            FearGriefing:action("put me a dick fire", {}, "just troll the player by making it look like he got hit in the ass.\n\nit's very precise probably you like the sound.", function(on_click)
                menu.trigger_command(menu.ref_by_path("Players>"..players.get_name_with_tags(pid)..">Spectate>Legit Method", 33))
                util.yield(500)
                local pidPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local onPed = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(pidPed, 0, 0, .5)
                local frontOfPed
                local randomMunitions = math.random(24, 48)
                local increment = 0.1
            
                for i = 1, randomMunitions do
                    frontOfPed = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(pidPed, 0, i * increment, (6 - i) * increment)
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(frontOfPed.x, frontOfPed.y, frontOfPed.z, onPed.x, onPed.y, onPed.z, 350, true, 205991906, 0, true, false, 100)
                end
                util.yield(1000)
                menu.trigger_command(menu.ref_by_path("Players>"..players.get_name_with_tags(pid)..">Spectate>Legit Method", 33))
                util.yield(500)
            end)
            
            FearGriefing:divider("Vehicle Tweaks")

            FearGriefing:action_slider("Send Plane", {}, "Call the Plane to send "..FearPlayerName.." to die.\n\nBOEING IS THE FASTEST PLANE EVER THAN SHITTY PLANES.", {"Boeing 747","F-16 Falcon","Antonov AN-225"}, function(select)
                if select == 1 then
                    local function upgrade_vehicle(vehicle)
                        if menu.get_value(FearToggleCustom) == true then
                            for i = 0,49 do
                                local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                                VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                            end
                        else
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                        end
                    end

                    local function summon_entity_face(entity, targetplayer, inclination)
                        local pos1 = ENTITY.GET_ENTITY_COORDS(entity, false)
                        local pos2 = ENTITY.GET_ENTITY_COORDS(targetplayer, false)
                        local rel = v3.new(pos2)
                        rel:sub(pos1)
                        local rot = rel:toRot()
                        if not inclination then
                            ENTITY.SET_ENTITY_HEADING(entity, rot.z)
                        else
                            ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z, 2, false)
                        end
                    end

                    local function GiveSPlane(pid)
                        local targetID = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetID, 0.0, 0, 200.0)
                    
                        local hash = util.joaat("jet")
                    
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            load_model(hash)
                        end
                    
                        local boeing = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(targetID))
                        ENTITY.SET_ENTITY_INVINCIBLE(boeing, menu.get_value(FearToggleGod))
                        summon_entity_face(boeing, targetID, true)
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(boeing, 1000.0)
                        VEHICLE.SET_VEHICLE_MAX_SPEED(boeing, 1000.0)
                        VEHICLE.CONTROL_LANDING_GEAR(boeing, 3)
                        upgrade_vehicle(boeing)
                    end
                    if FearSession() then
                        if FearPlayerName then
                            GiveSPlane(pid)
                            FearTime()
                        end
                    end
                elseif select == 2 then
                    local function upgrade_vehicle(vehicle)
                        if menu.get_value(FearToggleCustom) == true then
                            for i = 0,49 do
                                local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                                VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                            end
                        else
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                        end
                    end

                    local function summon_entity_face(entity, targetplayer, inclination)
                        local pos1 = ENTITY.GET_ENTITY_COORDS(entity, false)
                        local pos2 = ENTITY.GET_ENTITY_COORDS(targetplayer, false)
                        local rel = v3.new(pos2)
                        rel:sub(pos1)
                        local rot = rel:toRot()
                        if not inclination then
                            ENTITY.SET_ENTITY_HEADING(entity, rot.z)
                        else
                            ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z, 2, false)
                        end
                    end

                    local function GiveSPlane(pid)
                        local targetID = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetID, 0.0, 40, 150.0)
                    
                        local hash = util.joaat("lazer")
                    
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            load_model(hash)
                        end
                    
                        local lazersuicide = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(targetID))
                        ENTITY.SET_ENTITY_INVINCIBLE(lazersuicide, menu.get_value(FearToggleGod))
                        summon_entity_face(lazersuicide, targetID, true)
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(lazersuicide, 540.0)
                        VEHICLE.SET_VEHICLE_MAX_SPEED(lazersuicide, 540.0)
                        VEHICLE.CONTROL_LANDING_GEAR(lazersuicide, 3)
                        upgrade_vehicle(lazersuicide)
                    end
                    if FearSession() then
                        if FearPlayerName then
                            GiveSPlane(pid)
                            FearTime()
                        end
                    end
                else
                    local function upgrade_vehicle(vehicle)
                        if menu.get_value(FearToggleCustom) == true then
                            for i = 0,49 do
                                local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                                VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                            end
                        else
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                        end
                    end

                    local function summon_entity_face(entity, targetplayer, inclination)
                        local pos1 = ENTITY.GET_ENTITY_COORDS(entity, false)
                        local pos2 = ENTITY.GET_ENTITY_COORDS(targetplayer, false)
                        local rel = v3.new(pos2)
                        rel:sub(pos1)
                        local rot = rel:toRot()
                        if not inclination then
                            ENTITY.SET_ENTITY_HEADING(entity, rot.z)
                        else
                            ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z, 2, false)
                        end
                    end

                    local function GiveSPlane(pid)
                        local targetID = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetID, 0.0, 0, 200.0)
                    
                        local hash = util.joaat("cargoplane")
                    
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            load_model(hash)
                        end
                    
                        local cargoplane = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(targetID))
                        ENTITY.SET_ENTITY_INVINCIBLE(cargoplane, menu.get_value(FearToggleGod))
                        summon_entity_face(cargoplane, targetID, true)
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(cargoplane, 1000.0)
                        VEHICLE.SET_VEHICLE_MAX_SPEED(cargoplane, 1000.0)
                        VEHICLE.CONTROL_LANDING_GEAR(cargoplane, 3)
                        upgrade_vehicle(cargoplane)
                    end
                    if FearSession() then
                        if FearPlayerName then
                            GiveSPlane(pid)
                            FearTime()
                        end
                    end
                end
            end)


            FearGriefing:action("Summon Cargo Plane", {"fearcargoplane"}, "Spawn Big Cargo for "..FearPlayerName.."\nSpawning Cargo Plane to "..FearPlayerName.." will create +50 entites Cargo Plane.", function ()
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

                    FearSpam = 400
                    while FearSpam >= 1 do
                        entities.create_vehicle(hash, c, 0)
                        FearSpam = FearSpam - 1
                        util.yield(10)
                    end
                
                    local cargoplane = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                
                    upgrade_vehicle(cargoplane)
                end
                for k,v in pairs(players.list(true, true, true)) do
                    give_cargoplane(pid)
                    util.yield()
                end
            end, nil, nil, COMMANDPERM_RUDE)

            FearGriefing:action("Summon Boeing", {"fearboeing"}, "Spawn Big Boeing 747 for "..FearPlayerName.."\nSpawning Boeing to "..FearPlayerName.." will create +50 entites Boeing 747.", function ()
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

                    FearSpam = 400
                    while FearSpam >= 1 do
                        entities.create_vehicle(hash, c, 0)
                        FearSpam = FearSpam - 1
                        util.yield(10)
                    end
                
                    local boeing = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                
                    upgrade_vehicle(boeing)
                end
                for k,v in pairs(players.list(true, true, true)) do
                    give_boeing(pid)
                    util.yield()
                end
            end, nil, nil, COMMANDPERM_RUDE)

            FearGriefing:action("Summon B-1B Lancer", {"fearlancer"}, "Spawn Mass B-1B Lancer for "..FearPlayerName.."\nSpawning B-1B Lancer to "..FearPlayerName.." will create +50 entites B-1B Lancer.", function ()
                local function upgrade_vehicle(vehicle)
                    for i = 0, 49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                end
                local function give_lancer(pid)
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                
                    local hash = util.joaat("alkonost")
                
                    if not STREAMING.HAS_MODEL_LOADED(hash) then
                        load_model(hash)
                    end

                    FearSpam = 400
                    while FearSpam >= 1 do
                        entities.create_vehicle(hash, c, 0)
                        FearSpam = FearSpam - 1
                        util.yield(10)
                    end
                
                    local lancer = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                
                    upgrade_vehicle(lancer)
                end
                for k,v in pairs(players.list(true, true, true)) do
                    give_lancer(pid)
                    util.yield()
                end
            end, nil, nil, COMMANDPERM_RUDE)

            FearGriefing:action("Summon Leopard 2A", {"fearleo"}, "Spawn Mass Leopard Tank for "..FearPlayerName.."\nSpawning Leopard 2A to "..FearPlayerName.." will create +50 entites Leopard 2A.", function ()
                local function upgrade_vehicle(vehicle)
                    for i = 0, 49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                end
                local function give_leopard(pid)
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                
                    local hash = util.joaat("rhino")
                
                    if not STREAMING.HAS_MODEL_LOADED(hash) then
                        load_model(hash)
                    end

                    FearSpam = 1000
                    while FearSpam >= 1 do
                        entities.create_vehicle(hash, c, 0)
                        FearSpam = FearSpam - 1
                        util.yield(10)
                    end
                
                    local leopard = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                
                    upgrade_vehicle(leopard)
                end
                for k,v in pairs(players.list(true, true, true)) do
                    give_leopard(pid)
                    util.yield()
                end
            end, nil, nil, COMMANDPERM_RUDE)

                ----=================----
                ---   Cage Features
                ----=================----     

                    FearCage:divider("FearGriefing Cage")
                    FearCage:action("Normal Cage", {}, "", function()
                        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        if not PED.IS_PED_IN_ANY_VEHICLE(player_ped) then
                            local modelHash = util.joaat("prop_gold_cont_01")
                            local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
                            local obj = Create_Network_Object(modelHash, pos.x, pos.y, pos.z)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                        end
                    end)

                    FearCage:action("Electric Cage", {}, "Same as Cage but if he tries to move, he will gonna eletrocute himself.", function(on_click)
                        SpawnObjects = {}
                        get_vtable_entry_pointer = function(address, index)
                            return memory.read_long(memory.read_long(address) + (8 * index))
                        end
                        local FTotalCage = 6
                        local FElectricBox = util.joaat("prop_elecbox_12")
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local pos = ENTITY.GET_ENTITY_COORDS(ped)
                        pos.z = pos.z - 0.5
                        SendRequest(FElectricBox)
                        local temp_v3 = v3.new(0, 0, 0)
                        for i = 1, FTotalCage do
                            local angle = (i / FTotalCage) * 360
                            temp_v3.z = angle
                            local obj_pos = temp_v3:toDir()
                            obj_pos:mul(2.5)
                            obj_pos:add(pos)
                            for offs_z = 1, 5 do
                                local ElecCages = entities.create_object(FElectricBox, obj_pos)
                                SpawnObjects[#SpawnObjects + 1] = ElecCages
                                ENTITY.SET_ENTITY_ROTATION(ElecCages, 90.0, 0.0, angle, 2, 0)
                                obj_pos.z = obj_pos.z + 0.75
                                ENTITY.FREEZE_ENTITY_POSITION(ElecCages, true)
                            end
                        end
                    end)

                    FearCage:action("Container Box", {}, "Same as Cage, but container, we will remove his weapon for life.", function()
                        SpawnObjects = {}
                        get_vtable_entry_pointer = function(address, index)
                            return memory.read_long(memory.read_long(address) + (8 * index))
                        end
                        local ContainerBox = util.joaat("prop_container_ld_pu")
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local pos = ENTITY.GET_ENTITY_COORDS(ped)
                        SendRequest(ContainerBox)
                        pos.z = pos.z - 1
                        local Container = entities.create_object(ContainerBox, pos, 0)
                        SpawnObjects[#SpawnObjects + 1] = container
                        ENTITY.FREEZE_ENTITY_POSITION(Container, true)
                        WEAPON.REMOVE_ALL_PED_WEAPONS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
                    end)

            ----=================----
            --- Bounty   Features
            ----=================----        

                local FearBounty_value = 0
                FearBounty:divider("FearBounty Advanced")
                FearBounty:slider("Bounty Value",{"fearbp"}, "Chose the amount of the bounty offered automatically to "..FearPlayerName..".", 0, 10000, 0, 1, function(value)
                    FearBounty_value = value
                end)
                
                FearBounty:toggle("Auto Bounty", {"fearautoby"}, "Put automatically bounty to "..FearPlayerName.."." ,function()
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

            FearNeutral:divider("FearNeutral Advanced")

            local FearPresetChat = FearNeutral:list("Spoof Preset Chats")

            FearPresetChat:action("Austrian Painter", {""}, "", function()
                local from = pid
                for k,v in pairs(players.list(true, true, true)) do
                    chat.send_targeted_message(v, from, "His name is Adolf Hitler. He's the greatest leader of the world during the era. Remember, he was an exceptional painter, he changed the world forever and changed world maps forever too.", false)
                end
            end)

            FearPresetChat:action("Propaganda Putin", {""}, "", function()
                local from = pid
                for k,v in pairs(players.list(true, true, true)) do
                    chat.send_targeted_message(v, from, "I only fucked Ukraine, dick Ukrainians. I hope all those Ukronazis should die. I don't care if all those ukrainians are going to die, in my own way I didn't started the Invasion but Ukrainians started.", false)
                end
            end)

            FearNeutral:action("Detection Language", {"flang"}, "Notifies you if someone speak another language.", function()
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
                    if players.get_language(pid) == 5 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is Portuguese/Brazilian.") -- Portuguese/Brazilian Detection
                    end
                    if players.get_language(pid) == 6 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is Polish.") -- Polish Detection
                    end
                    if players.get_language(pid) == 7 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is Russian.") -- Russian Detection
                    end
                    if players.get_language(pid) == 8 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is Korean.") -- Korean Detection
                    end
                    if players.get_language(pid) == 9 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is from Taiwan.") -- Chinese Tradition (Taiwan) Detection
                    end
                    if players.get_language(pid) == 10 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is Japanese.") -- Japanese Detection
                    end
                    if players.get_language(pid) == 11 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is Spanish (Mexican).") -- Mexican Detection
                    end
                    if players.get_language(pid) == 12 then
                        FearToast(FearScriptNotif.."\n"..FearPlayerName.. " is from China Mainland.") -- Chinese Detection
                    end
                end
            end)

            FearNeutral:action("Spoof Chat ", {"fspc"}, "Spoofs your chat username name", 
            function (click_type)
                menu.show_command_box_click_based(click_type, "fspc" .. FearPlayerName .. " ")
            end,
            function (txt)
                local from = pid
                local message = txt
    
                for k,v in pairs(players.list(true, true, true)) do
                    chat.send_targeted_message(v, from, message, false)
                end
            end)

        ----====================================----
        --- Features Crash Player with Boom Nuke
        ----====================================----

            FearAttack:divider("FearAttack Advanced")
            local FearLagPlayer = FearAttack:list("Lag Players", {}, "")
            local FearCrashTool = FearAttack:list("Crash Tool Players", {}, "")

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

        FearAttack:action_slider("Crash Button Method", {}, "", {"Simple Nuke","American Button", "Putin Button", "Fragment Crash"}, function(select)
            if select == 1 then 
                FearToast(FearScriptNotif.."\nNuke Button on " ..FearPlayerName)
                FearBoomCrash(pid, FearPlayerName)
                util.yield(2000)
                if players.get_name(pid) == FearPlayerName then
                    menu.trigger_commands("breakup"..FearPlayerName)
                    FearToast(FearScriptNotif.."\n"..FearPlayerName.." has been nuked.")
                end
            elseif select == 2 then
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
            elseif select == 3 then
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
            else
                local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(csPID)))
                OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                util.yield(1000)
                entities.delete_by_handle(object)
            end
        end)

        ----============================----
        --- Standard Crash & Kick Player
        ----============================----       

        FearAttack:action("Force Breakup ", {"fbreakup"}, "Force "..FearPlayerName.." to leave the session.\nNOTE: You can't kick Stand Users if Stand User Identification has been activated.\nIt will be useful if you want kick Players using Host Spoof Token (Aggressive/Spot) but reverse side.", function()
            FearCommands("breakup"..FearPlayerName)
            FearCommands("kick"..FearPlayerName)
            FearCommands("confusionkick"..FearPlayerName)
            FearCommands("aids"..FearPlayerName)
            FearCommands("orgasmkick"..FearPlayerName)
            FearCommands("nonhostkick"..FearPlayerName)
            FearCommands("pickupkick"..FearPlayerName)
            FearToast(FearScriptNotif.."\n"..FearPlayerName.." has been forced breakup.")
        end, nil, nil, COMMANDPERM_AGGRESSIVE)
    end)

    players.dispatch_on_join()

    players.on_leave(function()
        update_player_count()
    end)

util.on_stop(function()
    SET_INT_GLOBAL(262145 + 20288, 5000) -- Reset Ballistic Armor
end)
