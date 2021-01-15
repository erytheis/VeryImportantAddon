--local version = '0.1'
--
-- Created by IntelliJ IDEA.
-- User: bulat
-- Date: 20.12.2020
-- Time: 23:49
-- To change this template use File | Settings | File Templates.

---------------
-- SOUNDS   --
---------------


local soundType = {
    SOUND = 1,
    GAME_MUSIC = 2,
    CUSTOM = 3
}

local sounds = {
    ["murloc"] = {
        ["sound"] = 416,
        ["description"] = "Mglrlrlrlrlrl!",
        ["type"] = soundType.SOUND
    },
    ["ding"] = {
        ["sound"] = 888,
        ["description"] = "Grats!",
        ["type"] = soundType.SOUND
    },
    ["main theme"] = {
        ["sound"] = "Sound\\Music\\GlueScreenMusic\\wow_main_theme.mp3",
        ["description"] = "DUN DUNNN... DUNNNNNNNNNN",
        ["type"] = soundType.GAME_MUSIC
    },
    ["custom"] = {
        ["sound"] = "Interface\\AddOns\\MusicPlayer\\Sounds\\custom.mp3",
        ["description"] = "Custom sound!",
        ["type"] = soundType.CUSTOM
    },
    ["comet"] = {
        ["sound"] = "Interface/AddOns/VeryImportantAddon/res/audios/comet.mp3",
        ["description"] = "Custom sound!",
        ["type"] = soundType.CUSTOM
    },
    ["what_is_he_doing"] = {
        ["sound"] = "Interface/AddOns/VeryImportantAddon/res/audios/what_is_he_doing.mp3",
        ["description"] = "Custom sound!",
        ["type"] = soundType.CUSTOM
    },
    ["dimon"] = {
        ["sound"] = "Interface/AddOns/VeryImportantAddon/res/audios/dimon.mp3",
        ["description"] = "Custom sound!",
        ["type"] = soundType.CUSTOM
    }
}

local dimon_name = "Йоггсатотх"
local name, _ = ...
local hpPct = 1.
local enable_sounds = true
local last_triggered_ts = 0.
local hp_above_threshold = false

local f = CreateFrame("Frame")
local function onevent(self, event, arg1, ...)
    if ((event == "ADDON_LOADED" and name == arg1)) then
        -- Fresh Install, setting globals
        if (LowHPAlert_Options == nil) then
            LowHPAlert_Options = {
                ["soundcombatonly"] = false,
                ["disablesound"] = false,
                ["showtext"] = true,
                ["version"] = version
            }
        end
        f:UnregisterAllEvents()
    end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", onevent)

-------------------------
-- SOUNDS PLAY METHODS --
-------------------------
local function playTrack(track)
    print(track.description)

    if (track.type == soundType.GAME_MUSIC) then
        PlayMusic(track.sound)
        ViragDevTool_AddData(track.sound, "My local var in MyModFN")
        print("To stop the music type /stopsound")
    elseif (track.type == soundType.SOUND) then
        PlaySound(track.sound)
    elseif (track.type == soundType.CUSTOM) then
        stopSoundHandler()
        customSoundId = select(2, PlaySoundFile(track.sound, "Master"))
    end
end

local function playSoundHandler(trackId)
    if (string.len(trackId) > 0) then
        local matchesKnownTrack = sounds[trackId] ~= nil
        if (matchesKnownTrack) then
            local track = sounds[trackId]
            playTrack(track)
        else
            print(trackId .. " - Doesn't match a known track.")
        end
    else
        print("No sound found")
    end
end

local function stopSoundHandler()
    StopMusic()

    if (customSoundId ~= nil) then
        StopSound(customSoundId)
        customSoundId = nil
    end
end

local customSoundId


SlashCmdList["SOUND"] = playSoundHandler;
--SlashCmdList["STOPSOUND"] = stopSoundHandler;

-- CONVOKE
local ConvokeEventFrame = CreateFrame("Frame")
ConvokeEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
ConvokeEventFrame:SetScript("OnEvent",
    function(self, event, ...)
        local sounds = { 'comet', 'what_is_he_doing' }
        local arg1, arg2, arg3, arg4, arg5 = ...

        if (arg3 == 323764) then
            --        if (arg3==194153) then
            sound = sounds[math.random(#sounds)]
            playSoundHandler(sound)
        end
    end)

function isSameLocation(arg1)
    _, _, _, instance1 = UnitPosition('player')
    _, _, _, instance2 = UnitPosition(arg1)
    return instance1 == instance2
end

-- HEALTH
function LowHPAlert_OnUpdate_default()
    local cur_ts = GetTime();
    local time_diff = cur_ts - last_triggered_ts
    local is_same_loc = isSameLocation(dimon_name)

    if (hpPct < 0.25) then
        hp_above_threshold = false
        if (time_diff > 30)
                and (hp_above_threshold)
                and (is_same_loc) then
            last_triggered_ts = GetTime();
            if (enable_sounds) then playSoundHandler('dimon') end
        end
    else
        hp_above_threshold = true
    end
end



-- event caller
function LowHPAlert_OnUpdate()
    if (LowHPAlert_Options.soundalwaysoff) then
        enable_sounds = false
    elseif (LowHPAlert_Options.soundcombatonly and not UnitAffectingCombat("player")) then
        enable_sounds = false
    else
        enable_sounds = true
    end

    -- some hardcore math
    hp = UnitHealth(dimon_name)
    hpPct = hp / UnitHealthMax(dimon_name)

    LowHPAlert_OnUpdate_default()
end

---------------
-- SETTINGS ---
---------------

-- slash commands
SLASH_LOWHPALERT1 = '/via'
local function slashhandler(msg, editbox)
    if msg == 'combatmode' then
        if (LowHPAlert_Options.soundcombatonly) then
            LowHPAlert_Options.soundcombatonly = false
            print("Alerts always ON!")
        else
            LowHPAlert_Options.soundcombatonly = true
            print("Alertts will be only played in combat!")
        end
    elseif msg == 'sound' then
        if (LowHPAlert_Options.soundalwaysoff) then
            LowHPAlert_Options.soundalwaysoff = false
            print("Sounds ON!")
        else
            LowHPAlert_Options.soundalwaysoff = true
            print("Sounds always OFF!")
        end
    elseif msg == 'text' then
        if (LowHPAlert_Options.showtext) then
            LowHPAlert_Options.showtext = false
            print("Text OFF!")
        else
            LowHPAlert_Options.showtext = true
            print("Text ON!")
        end
    else
        print(" ")
        print("VIA addon version " .. version)
        print("-----------------------------")
        print("/via combatmode - only play alert sounds in combat")
        print("/via sound - turns off all sounds")
        print("/via text - turns off all text messages on screen")
    end
end

SlashCmdList["LOWHPALERT"] = slashhandler

function LowHPAlert_OnLoad()
    DEFAULT_CHAT_FRAME:AddMessage("Low HP Alert version " .. version .. " loaded - Options: /lowhpalert", 0.0, 0.8, 0.0, nil, true)
end