
-------------------------------------------------------------------------------------------------------
-- randombgm.lua
-- A simple module that allows you to randomize music selection in Ikemen Go

-- Usage guide: 

-- 1. Put this file in the external/mods folder and it will be loaded automatically by the engine

-- 2. Change the file paths defined below to point to directories where you store your music.
-- Selection will be made from all files with a valid extension (mp3, ogg or wav) in the defined folder.
-- For more flexibility new paths can easily be added by defining new variables below.
-- Just remember to also define a unique keyword in the keyword map for each added path.

-- 3. Whenever you want to use random music where you normally would refer to a specific file,
-- instead refer to one of the defined keywords in the map below.
-- For example, adding a stage with random stage music via select.def can be done like this:
-- stages/kfm.def, music=random_stage_music
-- or adding random music to the title screen via system.def like this:
-- title.bgm = random_title_music
-------------------------------------------------------------------------------------------------------

-- Below are paths to each distinct directory containing music files
-- (relative to the Ikemen main directory)

local TITLE_MUSIC_PATH = "bgm/title" -- put your random title screen music files in this folder
local SELECT_MUSIC_PATH = "bgm/select" -- put your random select screen music files in this folder 
local STAGE_MUSIC_PATH = "bgm/stage" -- put your random stage music files in this folder
local VS_MUSIC_PATH = "bgm/vs" -- put your random versus screen music files in this folder

-- If you want you could also define folders for:
-- the victory screen, option screen, replay screen, results screen, hiscore screen (or anything you want really)

-- Each path has a specific keyword mapped to it, defined by the keyword map:
local keyword_map = {
    random_title_music = TITLE_MUSIC_PATH,
    random_select_music = SELECT_MUSIC_PATH,
    random_stage_music = STAGE_MUSIC_PATH,
    random_vs_music = VS_MUSIC_PATH
}

-- a function to check for valid file extensions
local function has_valid_extension(file)
    return file:lower():match("%.mp3$") or file:lower():match("%.ogg$") or file:lower():match("%.wav$")
end

-- a function to get a random valid file from a folder
local function get_random_song(path)
    local files = {}
    local command

    -- detect operating system
    if package.config:sub(1, 1) == "\\" then
        -- windows
        command = 'dir "' .. path .. '" /b /a-d'
    else
        -- macOS/linux
        command = 'ls -p "' .. path .. '" | grep -v /'
    end

    -- get all valid files
    for file in io.popen(command):lines() do
        if has_valid_extension(file) then
            table.insert(files, path .. "/" .. file)
        end
    end

    if #files == 0 then
        return nil
    end
    
    return files[math.random(#files)]
end

-- store the original playBGM function from main.lua
local original_PlayBGM = main.f_playBGM

-- put a wrapper around the original function that allows the usage of the defined keywords
main.f_playBGM = function(interrupt, bgm, bgmLoop, bgmVolume, bgmLoopstart, bgmLoopend)
    if keyword_map[bgm] then
        local random_song = get_random_song(keyword_map[bgm])
        if random_song then
            original_PlayBGM(interrupt, random_song, bgmLoop, bgmVolume, bgmLoopstart, bgmLoopend)
            return
        end
    end
    original_PlayBGM(interrupt, bgm, bgmLoop, bgmVolume, bgmLoopstart, bgmLoopend)
end
