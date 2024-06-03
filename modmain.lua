local _G = GLOBAL
if _G.GetGameModeProperty("level_type") ~= _G.LEVELTYPE.SURVIVAL then return end

local BossCalendar = _G.require("screens/bosscalendar")
Assets = {Asset("ATLAS", "images/boss.xml")}

for _, drop in pairs {
    "dragon_scales",
    "hivehat",
    "klaussackkey",
    "shroom_skin",
    "skeletonhat",
    "singingshell_octave5",
    "malbatross_beak",
    "eyemaskhat",
    "shieldofterror",
    "horrorfuel",
    "wagpunk_bits",
} do AddPrefabPostInit(drop, function(inst)
        inst:DoTaskInTime(0, function()
            if inst.entity and not inst.entity:GetParent() then
                BossCalendar:ValidateDefeatByDrop(inst)
            end
        end)
    end)
end

local OPEN_KEY = _G.rawget(_G, GetModConfigData("OPEN_KEY"))
if OPEN_KEY then
    local TheInput = _G.TheInput

    local function ValidateToggle()
        local active_screen = TheFrontEnd:GetActiveScreen()
        local active_screen_name = active_screen and active_screen.name or ""
        return active_screen_name == "HUD" or active_screen_name == "Boss Calendar"
    end

    local function OpenCalendar()
        if not ValidateToggle() then return end
        if BossCalendar:Open() then TheFrontEnd:PushScreen(BossCalendar) end
    end

    local function CloseCalendar() if ValidateToggle() then BossCalendar:Close() end end

    TheInput:AddKeyDownHandler(OPEN_KEY, OpenCalendar)
    TheInput:AddKeyUpHandler(OPEN_KEY, CloseCalendar)
end

local function RGB(r, g, b) return {r / 255, g / 255, b / 255, 1} end
local COLOR = {
    ["White"]       = RGB(255, 255, 255),
    ["Red"]         = RGB(255,   0,   0),
    ["Green"]       = RGB(  0, 255,   0),
    ["Blue"]        = RGB(  0,   0, 255),
    ["Yellow"]      = RGB(255, 255,   0),
    ["Crimsom"]     = RGB(220,  20,  60),
    ["Coral"]       = RGB(255, 127,  80),
    ["Orange"]      = RGB(255, 165,   0),
    ["Khaki"]       = RGB(240, 230, 140),
    ["Chocolate"]   = RGB(210, 105,  30),
    ["Brown"]       = RGB(165, 42,   42),
    ["Light Green"] = RGB(144, 238, 144),
    ["Cyan"]        = RGB(  0, 255, 255),
    ["Light Blue"]  = RGB(173, 216, 230),
    ["Purple"]      = RGB(128,   0, 128),
    ["Pink"]        = RGB(255, 192, 203),
}
local configuration = {
    CALENDAR_UNIT = GetModConfigData("CALENDAR_UNIT"),
    CALENDAR_STYLE = GetModConfigData("CALENDAR_STYLE"),
    ANNOUNCE_UNIT = GetModConfigData("ANNOUNCE_UNIT"),
    ANNOUNCE_STYLE = GetModConfigData("ANNOUNCE_STYLE"),
    REMINDER_COLOR = COLOR[GetModConfigData("REMINDER_COLOR")],
    REMINDER_DURATION = GetModConfigData("REMINDER_DURATION"),
}

AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(0, function()
        BossCalendar:Init(inst, configuration)
    end)
end)

local loc, exist = _G.GetCurrentLocale(), _G.kleifileexists
if loc and loc.code and exist(MODROOT.."languages/"..loc.code..".lua") then
    modimport("languages/"..loc.code..".lua")
else
    modimport("languages/en.lua") -- fallback to English
end
