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
} do
  AddPrefabPostInit(drop, function(inst)
    inst:DoTaskInTime(0, function()
      if inst.entity and not inst.entity:GetParent() then
        BossCalendar:ValidateDefeatByDrop(inst)
      end
    end)
  end)
end

local OPEN_KEY = G.rawget(G, GetModConfigData 'OPEN_KEY')
if OPEN_KEY then
  local function Validate()
    local active_screen_name = TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name or ''
    return active_screen_name == 'HUD' or active_screen_name == 'Boss Calendar'
  end

  local function Open() if Validate() and BossCalendar:Open() then TheFrontEnd:PushScreen(BossCalendar) end end
  local function Close() if Validate() then BossCalendar:Close() end end

  G.TheInput:AddKeyDownHandler(OPEN_KEY, Open)
  G.TheInput:AddKeyUpHandler(OPEN_KEY, Close)
end

local function RGB(r, g, b) return { r / 255, g / 255, b / 255, 1 } end
local COLOR = {
  white       = RGB(255, 255, 255),
  red         = RGB(255, 0, 0),
  green       = RGB(0, 255, 0),
  blue        = RGB(0, 0, 255),
  yellow      = RGB(255, 255, 0),
  crimsom     = RGB(220, 20, 60),
  coral       = RGB(255, 127, 80),
  orange      = RGB(255, 165, 0),
  khaki       = RGB(240, 230, 140),
  chocolate   = RGB(210, 105, 30),
  brown       = RGB(165, 42, 42),
  light_green = RGB(144, 238, 144),
  cyan        = RGB(0, 255, 255),
  light_blue  = RGB(173, 216, 230),
  purple      = RGB(128, 0, 128),
  pink        = RGB(255, 192, 203),
}
G.TUNING.BCL = {
  CALENDAR_UNIT = GetModConfigData 'CALENDAR_UNIT',
  CALENDAR_STYLE = GetModConfigData 'CALENDAR_STYLE',
  ANNOUNCE_UNIT = GetModConfigData 'ANNOUNCE_UNIT',
  ANNOUNCE_STYLE = GetModConfigData 'ANNOUNCE_STYLE',
  REMINDER_COLOR = COLOR[GetModConfigData 'REMINDER_COLOR'],
  REMINDER_DURATION = GetModConfigData 'REMINDER_DURATION',
}

local loc, exist = G.GetCurrentLocale(), G.kleifileexists
if loc and loc.code and exist(MODROOT .. 'languages/' .. loc.code .. '.lua') then
  modimport('languages/' .. loc.code)
else
  modimport 'languages/en' -- fallback to English
end
