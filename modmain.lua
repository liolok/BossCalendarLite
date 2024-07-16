local G = GLOBAL
if G.GetGameModeProperty('level_type') ~= G.LEVELTYPE.SURVIVAL then return end
Assets = { Asset('ATLAS', 'images/boss.xml') }
modimport('languages/en') -- load translation strings with English fallback
local lang = 'languages/' .. G.LOC.GetLocaleCode()
if G.kleifileexists(MODROOT .. lang .. '.lua') then modimport(lang) end
modimport('keybind') -- refine key binding UI
modimport('tuning') -- load constants and options
local BossCalendar = require('screens/bosscalendar')
local T = TUNING.BOSS_CALENDAR

AddPlayerPostInit(function(inst) -- initialize after player
  inst:DoTaskInTime(0, function() BossCalendar:Init() end)
end)

G.TheInput:AddKeyDownHandler(T.VIEW_KEY, function() BossCalendar:Show() end) -- bind key
G.TheInput:AddKeyUpHandler(T.VIEW_KEY, function() BossCalendar:Hide() end)

for prefab, boss in pairs(T.BY_DROP) do -- validate defeat of boss after loot drop
  AddPrefabPostInit(prefab, function(inst)
    if inst.entity and not inst.entity:GetParent() then BossCalendar:ValidateDefeat(boss) end
  end)
end

local function ValidateAnimation(as, anim)
  if as:IsCurrentAnimation('death') then return true end
  return anim and as:IsCurrentAnimation(anim) or false
end
local SHIELD_TAG = { 'handfed', 'fedbyall', 'toolpunch', 'eatsrawmeat', 'strongstomach', 'weapon', 'shadowlevel' }
for prefab, boss in pairs(T.BY_PREFAB) do
  AddPrefabPostInit(prefab, function(inst)
    inst:ListenForEvent('onremove', function(inst)
      if prefab == 'klaus_sack' and not G.IsSpecialEventActive('winters_feast') then return end
      if not ValidateAnimation(inst.AnimState, T.ANIM[boss]) then return end
      if prefab:find('twinofterror') and not G.FindEntity(inst, 4, nil, SHIELD_TAG) then return end
      BossCalendar:OnDefeat(boss)
    end)
  end)
end
