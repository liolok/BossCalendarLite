local G = GLOBAL
if G.GetGameModeProperty 'level_type' ~= G.LEVELTYPE.SURVIVAL then return end
local BossCalendar = G.require 'screens/bosscalendar'
Assets = { Asset('ATLAS', 'images/boss.xml') }

-- load constants and options
modimport 'tuning'
TUNING.BCL.CALENDAR_TIME_STYLE = GetModConfigData 'calendar_time_style'
TUNING.BCL.ANNOUNCE_TIME_STYLE = GetModConfigData 'announce_time_style'
TUNING.BCL.REMIND_POSITION = GetModConfigData 'remind_position'
TUNING.BCL.REMIND_COLOR = GetModConfigData 'remind_color'
TUNING.BCL.TALK_DURATION = GetModConfigData 'talk_duration'

-- load translation strings
local loc, exist = G.GetCurrentLocale(), G.kleifileexists
if loc and loc.code and exist(MODROOT .. 'languages/' .. loc.code .. '.lua') then
  modimport('languages/' .. loc.code)
else
  modimport 'languages/en' -- fallback to English
end

-- setup calendar keybind
local function Validate()
  local active_screen_name = TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name or ''
  return active_screen_name == 'HUD' or active_screen_name == 'Boss Calendar'
end
local function Open() if Validate() and BossCalendar:Open() then TheFrontEnd:PushScreen(BossCalendar) end end
local function Close() if Validate() then BossCalendar:Close() end end
G.TheInput:AddKeyDownHandler(G.rawget(G, GetModConfigData 'key_to_view'), Open)
G.TheInput:AddKeyUpHandler(G.rawget(G, GetModConfigData 'key_to_view'), Close)

AddPlayerPostInit(function(inst) inst:DoTaskInTime(0, function() BossCalendar:Init() end) end)

for _, drop in pairs(TUNING.BCL.DROPS) do
  AddPrefabPostInit(drop, function(inst)
    inst:DoTaskInTime(0, function()
      if inst.entity and not inst.entity:GetParent() then
        BossCalendar:ValidateDefeatByDrop(inst)
      end
    end)
  end)
end
