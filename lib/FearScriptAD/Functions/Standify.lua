--[[
    FearScript Advanced for Stand by StealthyAD.
    The All-In-One Script combines every each script.

    Script Part: Standify

    Features:
    - Compatible All Stand Versions.
    - Includes Standify & Cruise Missile Tool (GitHub)

    Help with Lua?
    - GTAV Natives: https://nativedb.dotindustries.dev/natives/
    - FiveM Docs Natives: https://docs.fivem.net/natives/
    - Stand Lua Documentation: https://stand.gg/help/lua-api-documentation
    - Lua Documentation: https://www.lua.org/docs.html
]]--

    local aalib = require("aalib")
    local FearStandify_ver = "0.20.7"
    local FearScriptStandify = "> FearScript Standify "..FearStandify_ver
    local FearPlaySound = aalib.play_sound
    local SND_ASYNC<const> = 0x0001
    local SND_FILENAME<const> = 0x00020000
    local FearToast = util.toast

    ----=======================================----
    ---    File Directory 'Standify Ported'
    --- Locate songs.wav and stop music easily.
    ----=======================================----

    local script_store_dir = filesystem.store_dir() .. 'FearScriptAD\\songs' -- Redirects to %appdata%\Stand\Lua Scripts\store\FearScriptAD\songs
    if not filesystem.is_dir(script_store_dir) then
        filesystem.mkdirs(script_store_dir)
    end

    local script_store_dir_stop = filesystem.store_dir() .. 'FearScriptAD/stop_sounds' -- Redirects to %appdata%\Stand\Lua Scripts\store\FearScriptAD\stop_sounds
    if not filesystem.is_dir(script_store_dir_stop) then
        filesystem.mkdirs(script_store_dir_stop)
    end

    ----=======================================----
    ---             Standify Ported
    ---             Basic Functions
    ----=======================================----

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

    local FearRoot = menu.my_root()
    local FearStandify = FearRoot:list("Standify", {}, "Standify, script related to music.\nCreated by StealthyAD.")

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

        FearStandify:action("Play Random Music", {'fstandrand'}, "Play a random music.\nNOTE: You have each interval to click the action to select random music.", function(selected_index)
            FearStandifyAuto()
        end)

        ----================================================----
        ---               Stop Sounds
        ---     Automatically end the musics while playing.
        ----================================================----

        FearStandify:action("Stop Music", {'fstandstop'}, "It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file.", function(selected_index) -- Force automatically stop your musics
            local sound_location_1 = join_path(script_store_dir_stop, "stop.wav")
            if not filesystem.exists(sound_location_1) then
                FearToast(FearScriptStandify.."\nMusic file does not exist: " .. sound_location_1.. "\n\nNOTE: You need to get the file, otherwise you can't stop the sound.")
            else
                FearPlaySound(sound_location_1, SND_FILENAME | SND_ASYNC)
            end
        end)

    FearStandify:divider("Miscs")
    FearStandify:readonly("FearScript (Standify)", FearStandify_ver)
    FearStandify:hyperlink("Standify: GitHub Source", "https://github.com/StealthyAD/Standify")

util.on_stop(function()
    local sound_location_1 = join_path(script_store_dir_stop, "stop.wav")
    FearPlaySound(sound_location_1, SND_FILENAME | SND_ASYNC) -- Stop current sound while using Standify
end)
