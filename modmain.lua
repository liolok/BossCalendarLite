local G = GLOBAL
if G.GetGameModeProperty 'level_type' ~= G.LEVELTYPE.SURVIVAL then return end
local BossCalendar = G.require 'screens/bosscalendar'
Assets = { Asset('ATLAS', 'images/boss.xml') }

AddPlayerPostInit(function(inst) inst:DoTaskInTime(0, function() BossCalendar:Init() end) end)

for _, drop in pairs {
  'dragon_scales',
  'hivehat',
  'klaussackkey',
  'shroom_skin',
  'skeletonhat',
  'singingshell_octave5',
  'malbatross_beak',
  'eyemaskhat',
  'shieldofterror',
  'horrorfuel',
  'wagpunk_bits',
  'bootleg',
} do
  AddPrefabPostInit(drop, function(inst)
    inst:DoTaskInTime(0, function()
      if inst.entity and not inst.entity:GetParent() then
        BossCalendar:ValidateDefeatByDrop(inst)
      end
    end)
  end)
end

-- setup calendar keybind
local function Validate()
  local active_screen_name = TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name or ''
  return active_screen_name == 'HUD' or active_screen_name == 'Boss Calendar'
end
local function Open() if Validate() and BossCalendar:Open() then TheFrontEnd:PushScreen(BossCalendar) end end
local function Close() if Validate() then BossCalendar:Close() end end
G.TheInput:AddKeyDownHandler(G.rawget(G, GetModConfigData 'KEY'), Open)
G.TheInput:AddKeyUpHandler(G.rawget(G, GetModConfigData 'KEY'), Close)

-- get config options
G.TUNING.BCL = {
  STYLE = {
    CALENDAR = GetModConfigData 'CALENDAR_TIME_STYLE',
    ANNOUNCE = GetModConfigData 'ANNOUNCE_TIME_STYLE',
  },
  SAY = {
    COLOR = GetModConfigData 'SAY_COLOR',
    DURATION = GetModConfigData 'SAY_DURATION',
  },
}

-- load translation strings
local loc, exist = G.GetCurrentLocale(), G.kleifileexists
if loc and loc.code and exist(MODROOT .. 'languages/' .. loc.code .. '.lua') then
  modimport('languages/' .. loc.code)
else
  modimport 'languages/en' -- fallback to English
end
