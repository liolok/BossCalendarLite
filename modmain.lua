local G = GLOBAL
if G.GetGameModeProperty('level_type') ~= G.LEVELTYPE.SURVIVAL then return end
local BossCalendar = require('screens/bosscalendar')
Assets = { Asset('ATLAS', 'images/boss.xml') }

modimport('languages/en') -- load translation strings with English fallback
local lang = 'languages/' .. G.LOC.GetLocaleCode()
if G.kleifileexists(MODROOT .. lang .. '.lua') then modimport(lang) end
modimport('keybind') -- refine key binding UI
modimport('tuning') -- load constants and options

AddPlayerPostInit(function(inst) -- initialize after player
  inst:DoTaskInTime(0, function() BossCalendar:Init() end)
end)

G.TheInput:AddKeyDownHandler(TUNING.BCL.VIEW_KEY, function() -- add view calendar keybind
  if TheFrontEnd:GetActiveScreen().name == 'HUD' then BossCalendar:Show() end
end)
G.TheInput:AddKeyUpHandler(TUNING.BCL.VIEW_KEY, function()
  if TheFrontEnd:GetActiveScreen().name == 'Boss Calendar' then BossCalendar:Hide() end
end)

for _, drop in pairs(TUNING.BCL.DROPS) do -- validate defeat of boss after loot drop
  AddPrefabPostInit(drop, function(inst)
    inst:DoTaskInTime(0, function()
      if inst.entity and not inst.entity:GetParent() then BossCalendar:ValidateDefeatByDrop(inst) end
    end)
  end)
end

AddPrefabPostInit('klaus_sack', function(inst) -- Loot Stash
  inst:ListenForEvent('onremove', function(inst)
    if not G.IsSpecialEventActive('winters_feast') then return end -- Winter's Feast
    if not G.FindEntity(inst, 4, nil, { 'bundle' }) then return end -- Gift or Bundled Supplies
    BossCalendar:OnDefeat('klaus_sack')
  end)
end) -- credit: Huxi, 3161117403/modtable/61.lua: InitPrefab("klaus_sack", ...)
