local G = GLOBAL
if G.GetGameModeProperty('level_type') ~= G.LEVELTYPE.SURVIVAL then return end
local BossCalendar = require('screens/bosscalendar')
Assets = { Asset('ATLAS', 'images/boss.xml') }

-- load constants and options
modimport('tuning')
TUNING.BCL.CALENDAR_TIME_STYLE = GetModConfigData('calendar_time_style')
TUNING.BCL.ANNOUNCE_TIME_STYLE = GetModConfigData('announce_time_style')
TUNING.BCL.REMIND_POSITION = GetModConfigData('remind_position')
TUNING.BCL.REMIND_COLOR = GetModConfigData('remind_color')
TUNING.BCL.TALK_DURATION = GetModConfigData('talk_duration')

-- load translation strings
local loc, exist = G.GetCurrentLocale(), G.kleifileexists
if loc and loc.code and exist(MODROOT .. 'languages/' .. loc.code .. '.lua') then
  modimport('languages/' .. loc.code)
else
  modimport('languages/en') -- fallback to English
end

-- setup calendar keybind
local function Validate()
  local active_screen = TheFrontEnd:GetActiveScreen()
  local active_screen_name = active_screen and active_screen.name or ''
  return active_screen_name == 'HUD' or active_screen_name == 'Boss Calendar'
end
local function Open()
  if Validate() and BossCalendar:Open() then TheFrontEnd:PushScreen(BossCalendar) end
end
local function Close()
  if Validate() then BossCalendar:Close() end
end
G.TheInput:AddKeyDownHandler(G.rawget(G, GetModConfigData('key_to_view')), Open)
G.TheInput:AddKeyUpHandler(G.rawget(G, GetModConfigData('key_to_view')), Close)

-- initialize after player
AddPlayerPostInit(function(inst)
  inst:DoTaskInTime(0, function() BossCalendar:Init() end)
end)

-- validate defeat of boss after loot drop
for _, drop in pairs(TUNING.BCL.DROPS) do
  AddPrefabPostInit(drop, function(inst)
    inst:DoTaskInTime(0, function()
      local e = inst.entity
      if e and not e:GetParent() then BossCalendar:ValidateDefeatByDrop(inst) end
    end)
  end)
end

-- Loot Stash
-- Credit: Huxi, 3161117403/modtable/61.lua:120-130, InitPrefab("klaus_sack", ...)
AddPrefabPostInit('klaus_sack', function(inst)
  inst:ListenForEvent('onremove', function(inst)
    if not G.IsSpecialEventActive('winters_feast') then return end -- Winter's Feast
    if not G.FindEntity(inst, 4, nil, { 'bundle' }) then return end -- Gift or Bundled Supplies
    BossCalendar:OnDefeat('klaus_sack')
  end)
end)
