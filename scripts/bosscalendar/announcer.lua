local Announcer = Class()

local cooldown = false
local cooldowns = {}

local function IsInCoolDown(boss)
  if cooldown or cooldowns[boss] then return true end
  cooldown = ThePlayer:DoTaskInTime(3, function() cooldown = false end)
  cooldowns[boss] = ThePlayer:DoTaskInTime(10, function() cooldowns[boss] = nil end)
end

function Announcer:Announce(message, boss)
  if not IsInCoolDown(boss) then TheNet:Say(STRINGS.LMB .. ' ' .. message) end
end

return Announcer
