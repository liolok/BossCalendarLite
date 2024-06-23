local Screen = require('widgets/screen')
local Widget = require('widgets/widget')
local Text = require('widgets/text')
local Image = require('widgets/image')

local Data = require('bosscalendar/persistentdata')('BossCalendarLite')
local BossCalendar = Class(Screen)
local cooldown = {}

-- count of seconds the world has run till now
local function Now() return (TheWorld.state.cycles + TheWorld.state.time) * TUNING.TOTAL_DAY_TIME end

local function FMT(s, boss, time)
  local tab = {}
  if boss then tab.boss = BossCalendar:Name(boss) end
  if time then tab.time = time end
  return subfmt(s, tab)
end

local function Remind(message, duration, color)
  if cooldown.remind then return end
  cooldown.remind = ThePlayer:DoTaskInTime(30, function() cooldown.remind = nil end)
  color = color or PLAYERCOLOURS[TUNING.BCL.REMIND_COLOR]
  if TUNING.BCL.REMIND_POSITION == 'chat' then
    -- ChatHistoryManager:OnAnnouncement(message, colour, announce_type)
    ChatHistory:OnAnnouncement(message, color, 'default')
  elseif TUNING.BCL.REMIND_POSITION == 'head' then
    if not ThePlayer.components.talker then return end
    -- Talker:Say(script, time, noanim, force, nobroadcast, colour, ...)
    ThePlayer.components.talker:Say(message, duration or TUNING.BCL.TALK_DURATION, true, true, true, color)
  end
end

local function RemindOfflineRespawn(bosses)
  if #bosses == 0 then return end
  local separator = (#bosses == 2) and STRINGS.BCL.AND or STRINGS.BCL.ANDS
  local tab = { bosses = table.concat(bosses, separator), have = #bosses == 1 and STRINGS.BCL.HAS or STRINGS.BCL.HAVE }
  Remind(subfmt(STRINGS.BCL.ORR, tab))
end

-- Persistant Data

function BossCalendar:Save()
  Data:SetValue(self.session_id .. '_timestamp', self.timestamp)
  Data:SetValue(self.session_id .. '_is_daywalker2', self.is_daywalker2)
  Data:Save()
  self:Update()
end

function BossCalendar:Load()
  Data:Load()
  self.is_daywalker2 = Data:GetValue(self.session_id .. '_is_daywalker2') -- "initially" werepig is in cavejail, so nil
  local data = Data:GetValue(self.session_id .. '_timestamp')
  if not data then return end

  local respawned = {} -- bosses respawned during offline

  for _, boss in ipairs(TUNING.BCL.BOSS) do
    if data[boss] then -- newly added boss may not be saved to persistent data
      local defeat = data[boss].defeat -- load timestamps only if not rolled back before defeat
      if defeat and defeat < Now() then self.timestamp[boss] = data[boss] end
      if self.timestamp[boss].respawn then
        local delta = self.timestamp[boss].respawn - Now()
        if delta > 0 then -- not respawned yet
          ThePlayer.components.timer:StartTimer(boss, delta)
        else -- already respawned during offline
          self.timestamp[boss].respawn = nil
          table.insert(respawned, self:Name(boss))
        end
      end
    end
  end

  self:Save()
  ThePlayer:DoTaskInTime(10, function() RemindOfflineRespawn(respawned) end)
end

-- General

function BossCalendar:OnTimerDone(boss)
  if not self.timestamp[boss] then return end -- unrelated timers
  self.timestamp[boss].respawn = nil
  self:Save()
  Remind(FMT(STRINGS.BCL.OTD, boss))
end

function BossCalendar:Init()
  if not ThePlayer.components.timer then ThePlayer:AddComponent('timer') end
  ThePlayer:ListenForEvent('timerdone', function(_, data) self:OnTimerDone(data.name) end)
  self.session_id = TheWorld.net.components.shardstate:GetMasterSessionId()
  self.timestamp = {} -- init timestamp table, maybe load in self:Load() later
  for _, boss in ipairs(TUNING.BCL.BOSS) do
    self.timestamp[boss] = {
      defeat = nil, -- when did player defeat this boss
      respawn = nil, -- when will this boss respawn
    }
  end
  self.CalendarTimeStyle = self[TUNING.BCL.CALENDAR_TIME_STYLE]
  self.AnnounceTimeStyle = self[TUNING.BCL.ANNOUNCE_TIME_STYLE]
  self:Load()
  self.init = true
end

local function SearchBossByDrop(inst, drop)
  if not ThePlayer or cooldown[drop] then return nil end
  cooldown[drop] = ThePlayer:DoTaskInTime(3, function() cooldown[drop] = nil end)
  return FindEntity(inst, 15, nil, { 'epic' })
end

function BossCalendar:ValidateDefeatByDrop(inst)
  local e = SearchBossByDrop(inst, inst.prefab) -- entity of boss
  if not e or not e:IsValid() then return end

  local boss = TUNING.BCL.BOSS_BY_DROP[inst.prefab]
  for _, a in pairs(TUNING.BCL.INFO[boss].ANIMS) do
    if e.AnimState:IsCurrentAnimation(a) then self:OnDefeat(boss) end
  end
end

function BossCalendar:CheckDaywalkerAround()
  local x, y, z = ThePlayer.Transform:GetWorldPosition()
  local entities = TheSim:FindEntities(x, y, z, 80, { 'epic' })
  if not entities then return end
  local dd = self.is_daywalker2 and 'daywalker' or 'daywalker2' -- Daywalker Defeated this time
  for _, entity in ipairs(entities) do
    if entity.prefab == dd then
      local message = subfmt(STRINGS.BCL.CDA, { boss = STRINGS.NAMES[dd:upper()] })
      local interval = TUNING.BCL.INFO[dd].RESPAWN_INTERVAL + TUNING.TOTAL_DAY_TIME -- add a whole day
      ThePlayer.components.timer:SetTimeLeft('daywalker', interval) -- reset timer
      self.timestamp['daywalker'].respawn = Now() + interval -- reset repsawn timestamp
      Remind(message, TUNING.MAX_TALKER_DURATION, TUNING.BCL.INFO[dd].COLOR)
      self:Save()
      break
    end
  end
end

function BossCalendar:OnDefeat(boss)
  if not self.init then return end
  if self.timestamp[boss:gsub('%d', '')].respawn then return end -- remove 2 from daywalker2

  local interval = TUNING.BCL.INFO[boss].RESPAWN_INTERVAL

  if boss:find('daywalker') then -- daywalker or daywalker2
    -- Nightmare Werepig is defeated in cave this time, next time it will be in big junk pile on forest.
    self.is_daywalker2 = boss == 'daywalker'
    boss = 'daywalker' -- regard two variants as one same boss
    local time_left_today = (1 - TheWorld.state.time) * TUNING.TOTAL_DAY_TIME
    interval = interval + time_left_today -- add remaining time of the day
    -- If it's still around player when next day coming, respawn will be delayed.
    ThePlayer:DoTaskInTime(time_left_today, function() self:CheckDaywalkerAround() end)
  end

  ThePlayer.components.timer:StartTimer(boss, interval)
  self.timestamp[boss].defeat = Now()
  self.timestamp[boss].respawn = Now() + interval
  self:Save()
end

-- GUI

function BossCalendar:Name(boss)
  if self.is_daywalker2 then boss = boss:gsub('daywalker$', 'daywalker2') end
  return STRINGS.NAMES[boss:upper()]
end

function BossCalendar:AbsoluteGameDay(boss, announce)
  local day = string.format('%.1f', 1 + (self.timestamp[boss].respawn / TUNING.TOTAL_DAY_TIME))
  return announce and FMT(STRINGS.BCL.AGD_LONG, boss, day) or FMT(STRINGS.BCL.AGD_SHORT, nil, day)
end

function BossCalendar:CountdownGameDays(boss, announce)
  local delta = math.max(0, self.timestamp[boss].respawn - Now())
  local days = string.format('%.1f', delta / TUNING.TOTAL_DAY_TIME)
  days = days .. (tonumber(days) <= 1 and STRINGS.BCL.DAY or STRINGS.BCL.DAYS)
  return announce and FMT(STRINGS.BCL.CGD, boss, days) or days
end

function BossCalendar:CountdownRealTime(boss, announce)
  local delta = math.max(0, self.timestamp[boss].respawn - Now())
  local hour = math.floor(delta / 3600)
  local minute = math.floor(delta % 3600 / 60)
  local second = math.ceil(delta)
  local unit = (not announce) and STRINGS.BCL.H or (hour == 1) and STRINGS.BCL.HOUR or STRINGS.BCL.HOURS
  local time = (hour > 0) and (hour .. unit) or ''
  unit = (not announce) and STRINGS.BCL.M or (minute == 1) and STRINGS.BCL.MINUTE or STRINGS.BCL.MINUTES
  local seperator = (time == '') and '' or ' '
  time = (minute > 0) and (time .. seperator .. minute .. unit) or time
  unit = (not announce) and STRINGS.BCL.S or (second == 1) and STRINGS.BCL.SECOND or STRINGS.BCL.SECONDS
  time = (time == '') and (second .. unit) or time
  return announce and FMT(STRINGS.BCL.CRT, boss, time) or time
end

function BossCalendar:OnClick(boss)
  if cooldown.announce then return end
  cooldown.announce = ThePlayer:DoTaskInTime(5, function() cooldown.announce = nil end)
  local message = self.timestamp[boss].respawn and self:AnnounceTimeStyle(boss, true) or FMT(STRINGS.BCL.OC, boss)
  TheNet:Say(STRINGS.LMB .. ' ' .. message)
end

function BossCalendar:Update()
  if not self.open or not self.init then return end
  for _, boss in ipairs(TUNING.BCL.BOSS) do
    local txt, img = 'text_' .. boss, 'image_' .. boss
    if self.timestamp[boss].respawn then -- display respawn time information
      self[img]:SetTint(unpack(DARKGREY)) -- darken image
      self[txt]:SetString(self:CalendarTimeStyle(boss))
      if self.is_daywalker2 then boss = boss:gsub('daywalker', 'daywalker2') end
      self[txt]:SetColour(TUNING.BCL.INFO[boss].COLOR)
    else -- display boss name
      self[img]:SetTint(unpack(WHITE))
      self[txt]:SetColour(WHITE)
      self[txt]:SetString(self:Name(boss))
    end
  end
end

function BossCalendar:Open()
  if self.open or not self.init then return end

  Screen._ctor(self, 'Boss Calendar')

  if self.root then self.root:Kill() end
  self.root = self:AddChild(Widget('ROOT'))
  self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
  self.root:SetHAnchor(ANCHOR_MIDDLE)
  self.root:SetVAnchor(ANCHOR_MIDDLE)

  if self.bg then self.bg:Kill() end
  self.bg = self.root:AddChild(Image('images/scoreboard.xml', 'scoreboard_frame.tex'))
  self.bg:SetScale(0.7, 0.7)

  if self.title then self.title:Kill() end
  self.title = self.root:AddChild(Text(TITLEFONT, 48))
  self.title:SetColour(WHITE)
  self.title:SetPosition(0, 150)
  self.title:SetString(STRINGS.BCL.TITLE)

  for i, boss in ipairs(TUNING.BCL.BOSS) do
    local x, y = (i - 1) % 5 * 120 - 240, -130 * math.floor((i - 1) / 5)
    local txt, img = 'text_' .. boss, 'image_' .. boss
    self[txt] = self.root:AddChild(Text(UIFONT, 32))
    self[txt]:SetPosition(x, y + 80)
    self[txt]:SetString(self:Name(boss))
    self[img] = self.root:AddChild(Image('images/boss.xml', boss .. '.tex'))
    self[img]:SetSize(68, 68)
    self[img]:SetPosition(x, y + 20)
    self[img].OnMouseButton = function(_, button, down)
      if button == MOUSEBUTTON_LEFT and down then self:OnClick(boss) end
    end
  end

  self.open = true

  self:Update()
  self.update_task = ThePlayer:DoPeriodicTask(1, function() self:Update() end)

  return true
end

function BossCalendar:Close()
  if not self.open then return end
  if self.update_task then self.update_task:Cancel() end
  self.update_task = nil
  TheFrontEnd:PopScreen(self)
  self.open = false
end

return BossCalendar
