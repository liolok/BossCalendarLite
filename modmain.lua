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

for _, drop in ipairs(T.DROPS) do -- validate defeat of boss after loot drop
  AddPrefabPostInit(drop, function(inst)
    inst:DoTaskInTime(0, function()
      if inst.entity and not inst.entity:GetParent() then BossCalendar:ValidateDefeatByDrop(inst) end
    end)
  end)
end

AddPrefabPostInit('klaus_sack', function(inst) -- Loot Stash
  inst:ListenForEvent('onremove', function(inst)
    if not G.IsSpecialEventActive('winters_feast') then return end -- Winter's Feast
    local x, y, z = inst.Transform:GetWorldPosition()
    local entities = G.TheSim:FindEntities(x, y, z, 4, { 'bundle' }) -- Gift or Bundled Supplies
    local gift_count = 0
    for _, v in ipairs(entities) do
      if v.prefab == 'gift' then gift_count = gift_count + 1 end
    end
    if gift_count >= 6 then BossCalendar:OnDefeat('klaus_sack') end
  end)
end) -- credit: Huxi, 3161117403/modtable/61.lua: InitPrefab("klaus_sack", ...)
