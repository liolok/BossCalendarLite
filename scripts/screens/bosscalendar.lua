local Screen = require('widgets/screen')
local Widget = require('widgets/widget')
local Text = require('widgets/text')
local Image = require('widgets/image')
local BossCalendar = Class(Screen)
local Data = require('bosscalendar/persistentdata')('BossCalendarLite')
local S, T, cooldown = STRINGS.BOSS_CALENDAR, TUNING.BOSS_CALENDAR, {}

local function FindEntity(boss)
  local x, y, z = ThePlayer.Transform:GetWorldPosition()
  for _, entity in ipairs(TheSim:FindEntities(x, y, z, 80, { 'epic' }) or {}) do
    if entity.prefab == boss then return entity end
  end
  return nil
end

local function FMT(s, boss, time)
  local tab = {}
  if boss then tab.boss = BossCalendar:Name(boss) end
  if time then tab.time = time end
  return subfmt(s, tab)
end

local function Now() return (TheWorld.state.cycles + TheWorld.state.time) * TUNING.TOTAL_DAY_TIME end -- count of seconds the world has run till now

local function Remind(message, duration, color)
  if cooldown.remind then return end
  cooldown.remind = ThePlayer:DoTaskInTime(30, function() cooldown.remind = nil end)
  color = color or PLAYERCOLOURS[T.REMIND_COLOR]
  if T.REMIND_POSITION == 'chat' then
    ChatHistory:OnAnnouncement(message, color, 'default') -- ChatHistoryManager:OnAnnouncement(message, colour, announce_type)
  elseif T.REMIND_POSITION == 'head' then
    if not ThePlayer.components.talker then return end
    ThePlayer.components.talker:Say(message, duration or T.TALK_DURATION, true, true, true, color) -- Talker:Say(script, time, noanim, force, nobroadcast, colour, ...)
  end
end

local function RemindOfflineRespawn(bosses)
  local separator = #bosses == 2 and S.AND or S.ANDS
  Remind(subfmt(S.ROR, { bosses = table.concat(bosses, separator), have = #bosses == 1 and S.HAS or S.HAVE }))
end

-- Persistant Data -------------------------------------------------------------

function BossCalendar:Save()
  Data:SetValue(self.session_id .. '_timestamp', self.timestamp)
  Data:SetValue(self.session_id .. '_is_daywalker2', self.is_daywalker2)
  Data:Save()
end

function BossCalendar:Load()
  Data:Load()
  self.is_daywalker2 = Data:GetValue(self.session_id .. '_is_daywalker2') -- "initially" werepig is in cavejail, so nil
  local data = Data:GetValue(self.session_id .. '_timestamp')
  if not data then return end

  local respawned = {} -- bosses respawned during offline
  for _, boss in ipairs(T.BOSS) do
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
  if #respawned > 0 then ThePlayer:DoTaskInTime(10, function() RemindOfflineRespawn(respawned) end) end

  self:Save()
end

-- General ---------------------------------------------------------------------

function BossCalendar:OnTimerDone(boss)
  if not self.timestamp[boss] then return end -- unrelated timers
  self.timestamp[boss].respawn = nil
  self:Save()
  Remind(FMT(S.OTD, boss))
end

function BossCalendar:Init()
  if not ThePlayer.components.timer then ThePlayer:AddComponent('timer') end
  ThePlayer:ListenForEvent('timerdone', function(_, data) self:OnTimerDone(data.name) end)
  self.session_id = TheWorld.net.components.shardstate:GetMasterSessionId()
  self.timestamp = {} -- init timestamp table, maybe load in self:Load() later
  for _, boss in ipairs(T.BOSS) do
    self.timestamp[boss] = {
      defeat = nil, -- when did player defeat this boss
      respawn = nil, -- when will this boss respawn
    }
  end
  self.CalendarTimeStyle = self[T.CALENDAR_TIME_STYLE]
  self.AnnounceTimeStyle = self[T.ANNOUNCE_TIME_STYLE]
  self:Load()
  self.init = true
end

function BossCalendar:ValidateDefeat(boss)
  if cooldown[boss] or not ThePlayer then return end
  cooldown[boss] = ThePlayer:DoTaskInTime(3, function() cooldown[boss] = nil end)
  local entity = FindEntity(boss)
  if entity and entity.AnimState:IsCurrentAnimation(T.ANIM[boss]) then self:OnDefeat(boss) end
end

function BossCalendar:CheckDaywalkerAround()
  local defeated = self.is_daywalker2 and 'daywalker' or 'daywalker2'
  if not FindEntity(defeated) then return end
  local message = subfmt(S.CDA, { boss = STRINGS.NAMES[defeated:upper()] })
  Remind(message, TUNING.MAX_TALKER_DURATION, WEBCOLOURS[self.is_daywalker2 and 'RED' or 'ORANGE'])
  local interval = ThePlayer.components.timer:GetTimeLeft('daywalker') + TUNING.TOTAL_DAY_TIME -- add a whole day
  ThePlayer.components.timer:SetTimeLeft('daywalker', interval) -- reset timer
  self.timestamp.daywalker.respawn = Now() + interval -- reset repsawn timestamp
  self:Save()
end

function BossCalendar:OnDefeat(boss)
  if not self.init then return end

  local interval = 0 -- how many seconds will it take to respawn this boss
  for _, respawn_time in ipairs(T.RESPAWN_TIME[boss]) do
    interval = interval + TUNING[respawn_time]
  end

  if boss:find('daywalker') then -- daywalker or daywalker2
    local seconds_left_today = (1 - TheWorld.state.time) * TUNING.TOTAL_DAY_TIME
    interval = interval * TUNING.TOTAL_DAY_TIME + seconds_left_today -- multiply seconds of a day, add remaining time of the day.
    ThePlayer:DoTaskInTime(seconds_left_today, function() self:CheckDaywalkerAround() end) -- still around player when next day coming?
    self.is_daywalker2 = boss == 'daywalker' -- Nightmare Werepig is defeated in cave this time, next time it will be in big junk pile on forest.
    boss = 'daywalker' -- regard two variants as one same boss
  end

  ThePlayer.components.timer:StartTimer(boss, interval)
  self.timestamp[boss].defeat = Now()
  self.timestamp[boss].respawn = Now() + interval
  self:Save()
end

-- GUI -------------------------------------------------------------------------

function BossCalendar:Name(boss)
  if self.is_daywalker2 then boss = boss:gsub('daywalker$', 'daywalker2') end
  return STRINGS.NAMES[boss:upper()]
end

function BossCalendar:AbsoluteGameDay(boss, announce)
  local day = string.format('%.2f', 1 + (self.timestamp[boss].respawn / TUNING.TOTAL_DAY_TIME))
  return announce and FMT(S.AGD_LONG, boss, day) or FMT(S.AGD_SHORT, nil, day)
end

function BossCalendar:CountdownGameDays(boss, announce)
  local delta = math.max(0, self.timestamp[boss].respawn - Now())
  local days = string.format('%.2f', delta / TUNING.TOTAL_DAY_TIME)
  days = days .. (tonumber(days) <= 1 and S.DAY or S.DAYS)
  return announce and FMT(S.CGD, boss, days) or days
end

function BossCalendar:CountdownRealTime(boss, announce)
  local delta = math.ceil(math.max(0, self.timestamp[boss].respawn - Now()))
  local h = math.floor(delta / 3600)
  local m = math.floor(delta % 3600 / 60)
  local s = math.floor(delta % 60)
  if not announce then return string.format('%02d:%02d:%02d', h, m, s) end
  local time = {}
  if h > 0 then table.insert(time, h .. (h == 1 and S.HOUR or S.HOURS)) end
  if m > 0 then table.insert(time, m .. (m == 1 and S.MINUTE or S.MINUTES)) end
  if s > 0 then table.insert(time, s .. (s == 1 and S.SECOND or S.SECONDS)) end
  return FMT(S.CRT, boss, table.concat(time, ' '))
end

function BossCalendar:OnClick(boss)
  if cooldown.announce then return end
  cooldown.announce = ThePlayer:DoTaskInTime(5, function() cooldown.announce = nil end)
  local message = self.timestamp[boss].respawn and self:AnnounceTimeStyle(boss, true) or FMT(S.OC, boss)
  TheNet:Say(STRINGS.LMB .. ' ' .. message)
end

function BossCalendar:Update()
  for _, boss in ipairs(T.BOSS) do
    local img, txt = self[boss], self[boss].text
    if self.timestamp[boss].respawn then -- display respawn time information
      img:SetTint(unpack(DARKGREY)) -- darken image
      txt:SetString(self:CalendarTimeStyle(boss))
      txt:SetColour(WEBCOLOURS[(boss == 'daywalker' and self.is_daywalker2) and 'ORANGE' or 'RED'])
      txt:Show()
    else
      img:SetTint(unpack(WHITE)) -- lighten image
      txt:Hide()
    end
  end
end

function BossCalendar:Show() -- DoInit(), screens/playerstatusscreen.lua
  if not (self.init and TheFrontEnd:GetActiveScreen().name == 'HUD') then return end
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
  self.title:SetPosition(0, 150)
  self.title:SetString(S.TITLE)

  for i, boss in ipairs(T.BOSS) do
    self[boss] = self.root:AddChild(Image('images/boss.xml', boss .. '.tex'))
    self[boss].text = self[boss]:AddChild(Text(UIFONT, T.FONT_SIZE))
    self[boss]:SetSize(120, 120)
    self[boss]:SetPosition(120 * ((i - 1) % 5 - 2), 60 - 160 * math.floor((i - 1) / 5))
    self[boss].OnMouseButton = function(_, button, down)
      if button == MOUSEBUTTON_LEFT and down then self:OnClick(boss) end
    end
  end

  self:Update()
  self.update_task = ThePlayer:DoPeriodicTask(1, function() self:Update() end)
  TheFrontEnd:PushScreen(self)
end

function BossCalendar:Hide()
  if TheFrontEnd:GetActiveScreen().name ~= 'Boss Calendar' then return end
  if self.update_task then self.update_task:Cancel() end
  TheFrontEnd:PopScreen(self)
end

return BossCalendar
