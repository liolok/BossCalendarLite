local Screen = require 'widgets/screen'
local Widget = require 'widgets/widget'
local Text = require 'widgets/text'
local Image = require 'widgets/image'
local Talker = require 'components/talker'

require 'bosscalendar/constants'
local Announcer = require 'bosscalendar/announcer'
local PersistentData = require 'bosscalendar/persistentdata'

local BossCalendar = Class(Screen)
local Data = PersistentData 'BossCalendarLite'
local timestamp = {}              -- will init in BossCalendar:Init() then maybe load in BossCalendar:Load()
local is_next_daywalker_2 = false -- will load in BossCalendar:Load(), "at first" werepig is in cavejail

-- Helper

-- count of seconds the world has run till now
local function SecondsNow() return (TheWorld.state.cycles + TheWorld.state.time) * TUNING.TOTAL_DAY_TIME end

local function GetName(boss)
  if is_next_daywalker_2 then boss = boss:gsub('daywalker$', 'daywalker2') end
  return STRINGS.NAMES[boss:upper()]
end

local function FMT(s, boss, time)
  local tab = {}
  if boss then tab.boss = GetName(boss) end
  if time then tab.time = time end
  return subfmt(s, tab)
end

local function AbsoluteGameDay(boss, announce)
  local time = string.format('%.1f', 1 + (timestamp[boss].respawn / TUNING.TOTAL_DAY_TIME))
  return announce and FMT(STRINGS.BCL.AGD.LONG, boss, time) or FMT(STRINGS.BCL.AGD.SHORT, nil, time)
end

local function CountdownGameDays(boss, announce)
  local delta = math.max(0, timestamp[boss].respawn - SecondsNow())
  local time = string.format('%.1f', delta / TUNING.TOTAL_DAY_TIME)

  if announce then
    time = time .. (tonumber(time) == 1 and STRINGS.BCL.DAY or STRINGS.BCL.DAYS)
    return FMT(STRINGS.BCL.CGD.LONG, boss, time)
  else
    return FMT(STRINGS.BCL.CGD.SHORT, nil, time)
  end
end

local function CountdownRealTime(boss, announce)
  local delta = math.max(0, timestamp[boss].respawn - SecondsNow())

  local hour = math.floor(delta / 3600)
  local minute = math.floor(delta % 3600 / 60)
  local time = ''

  if hour >= 1 then
    local suffix = not announce and STRINGS.BCL.H or hour == 1 and STRINGS.BCL.HOUR or STRINGS.BCL.HOURS
    time = hour .. suffix
  end

  if minute >= 1 then
    local separator = time == '' and '' or ' '
    local suffix = not announce and STRINGS.BCL.M or minute == 1 and STRINGS.BCL.MINUTE or STRINGS.BCL.MINUTES
    time = time .. separator .. minute .. suffix
  end

  if hour < 1 and minute < 1 then
    local second = math.ceil(delta)
    local suffix = not announce and STRINGS.BCL.S or second == 1 and STRINGS.BCL.SECOND or STRINGS.BCL.SECONDS
    time = second .. suffix
  end

  return announce and FMT(STRINGS.BCL.CRT, boss, time) or time
end

local function OnTimerDone(_, data)
  local boss = data.name
  if not timestamp[boss] then return end

  timestamp[boss].respawn = nil
  BossCalendar:Save()
  BossCalendar:Say(FMT(STRINGS.BCL.OTD, boss), TUNING.BCL.REMINDER_DURATION or 5)
end

local search_cd = {} -- cooldown
local function SearchBossByDrop(inst)
  local drop = inst.prefab
  if not ThePlayer or search_cd[drop] then return nil end

  search_cd[drop] = ThePlayer:DoTaskInTime(3, function() search_cd[drop] = nil end)

  return FindEntity(inst, 15, nil, { 'epic' })
end

local function CheckDaywalkerAround()
  local x, y, z = ThePlayer.Transform:GetWorldPosition()
  local entities = TheSim:FindEntities(x, y, z, 80, { 'epic' })
  if not entities then return end

  local daywalker_defeat = is_next_daywalker_2 and 'daywalker' or 'daywalker2'
  for _, entity in ipairs(entities) do
    if entity.prefab == daywalker_defeat then
      local interval = INFO['daywalker'].RESPAWN_INTERVAL
      local message = subfmt(STRINGS.BCL.CDA, { boss = STRINGS.NAMES[daywalker_defeat:upper()] })
      local color = WEBCOLOURS[is_next_daywalker_2 and 'RED' or 'ORANGE']

      timestamp['daywalker'].respawn = SecondsNow() + interval
      ThePlayer.components.timer:SetTimeLeft('daywalker', interval)
      BossCalendar:Say(message, 10, color)
      BossCalendar:Save()
      break
    end
  end
end

local function OnAnnounce(boss)
  local message = FMT(STRINGS.BCL.OA, boss)

  if timestamp[boss].respawn then
    if TUNING.BCL.ANNOUNCE_UNIT then
      message = TUNING.BCL.ANNOUNCE_STYLE and AbsoluteGameDay(boss, true) or CountdownGameDays(boss, true)
    else
      message = CountdownRealTime(boss, true)
    end
  end

  Announcer:Announce(message, boss)
end

-- Reminder

function BossCalendar:Say(message, duration, color)
  if self.talking then return end

  local color = color and color or PLAYERCOLOURS[TUNING.BCL.REMINDER_COLOR]
  self.talking = true
  ThePlayer.components.talker.lineduration = duration
  ThePlayer.components.talker:Say(message, duration, 0, true, false, color)
  ThePlayer.components.talker.Say = function() end
  ThePlayer:DoTaskInTime(duration, function()
    ThePlayer.components.talker.lineduration = 2.5
    ThePlayer.components.talker.Say = Talker.Say
    self.talking = false
  end)
end

-- Persistant Data

function BossCalendar:Save()
  Data:SetValue(self.session_id .. '_timestamp', timestamp)
  Data:SetValue(self.session_id .. '_is_next_daywalker_2', is_next_daywalker_2)
  Data:Save()
  self:Update()
end

function BossCalendar:Load()
  Data:Load()
  is_next_daywalker_2 = Data:GetValue(self.session_id .. '_is_next_daywalker_2')
  local timestamp_data = Data:GetValue(self.session_id .. '_timestamp')
  if not timestamp_data then return end

  local respawned = {} -- bosses respawned during offline

  for _, boss in ipairs(BOSS) do
    if timestamp_data[boss] then
      timestamp[boss] = timestamp_data[boss]
      -- if rolled back before defeat, reset both timestamps
      if timestamp[boss].defeat and timestamp[boss].defeat > SecondsNow() then
        timestamp[boss].defeat = nil
        timestamp[boss].respawn = nil
        self:Save()
      end
      if timestamp[boss].respawn then
        local delta = timestamp[boss].respawn - SecondsNow()
        if delta > 0 then -- not respawned yet
          ThePlayer.components.timer:StartTimer(boss, delta)
        else              -- already respawned during offline
          timestamp[boss].respawn = nil
          table.insert(respawned, GetName(boss))
        end
      end
    end
  end

  if #respawned > 0 then -- offline respawn reminder
    ThePlayer:DoTaskInTime(5, function()
      local separator = #respawned == 2 and STRINGS.BCL.AND or STRINGS.BCL.ANDS
      local bosses = table.concat(respawned, separator)
      local have = #respawned == 1 and STRINGS.BCL.HAS or STRINGS.BCL.HAVE
      local duration = TUNING.BCL.REMINDER_DURATION or 5
      self:Say(bosses .. have .. STRINGS.BCL.RESPAWNED, duration)
      self:Save()
    end)
  end
end

-- General

function BossCalendar:Init()
  if not ThePlayer.components.timer then ThePlayer:AddComponent 'timer' end
  ThePlayer:ListenForEvent('timerdone', OnTimerDone)
  for _, boss in ipairs(BOSS) do
    timestamp[boss] = { -- init timestamp table
      defeat = nil,     -- when did player defeat this boss
      respawn = nil     -- when will this boss respawn
    }
  end
  self.talking = false
  self.session_id = TheWorld.net.components.shardstate:GetMasterSessionId()
  self:Load()
  self.init = true
end

function BossCalendar:ValidateDefeatByDrop(inst)
  local entity = SearchBossByDrop(inst)
  if not entity or not entity:IsValid() then return end

  local boss = BOSS_BY_DROP[inst.prefab]
  for _, anim in pairs(INFO[boss].ANIMS) do
    if entity.AnimState:IsCurrentAnimation(anim) then
      self:OnDefeat(boss); break
    end
  end
end

function BossCalendar:OnDefeat(boss)
  if not self.init then return end
  if timestamp[boss:gsub('%d', '')].respawn then return end -- remove 2 from daywalker2
  if boss == 'klaus_sack' and not IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then return end

  local interval = INFO[boss].RESPAWN_INTERVAL

  if boss:find 'daywalker' then -- daywalker or daywalker2
    -- Nightmare Werepig is killed in cave this time, next time it will respawn in big junk pile on forest.
    is_next_daywalker_2 = boss == 'daywalker'
    -- check if daywalker is still around player when next day coming
    local time_left_today = (1 - TheWorld.state.time) * TUNING.TOTAL_DAY_TIME
    ThePlayer:DoTaskInTime(time_left_today, CheckDaywalkerAround)
    -- subtract time spent on current day
    interval = interval - (TheWorld.state.time * TUNING.TOTAL_DAY_TIME)
    boss = 'daywalker' -- regard two variants as one same boss
  end

  ThePlayer.components.timer:StartTimer(boss, interval)
  timestamp[boss].defeat = SecondsNow()
  timestamp[boss].respawn = SecondsNow() + interval
  self:Save()
end

-- GUI

function BossCalendar:Close()
  if not self.open then return end
  TheFrontEnd:PopScreen(self)
  self.open = false
end

function BossCalendar:Open()
  if self.open or not self.init then return end

  Screen._ctor(self, 'Boss Calendar')
  self.open = true

  if self.root then self.root:Kill() end
  self.root = self:AddChild(Widget 'ROOT')
  self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
  self.root:SetHAnchor(ANCHOR_MIDDLE)
  self.root:SetVAnchor(ANCHOR_MIDDLE)

  if self.bg then self.bg:Kill() end
  self.bg = self.root:AddChild(Image('images/scoreboard.xml', 'scoreboard_frame.tex'))
  self.bg:SetScale(.7, .7)

  if self.title then self.title:Kill() end
  self.title = self.root:AddChild(Text(TITLEFONT, 48))
  self.title:SetColour(WHITE)
  self.title:SetPosition(0, 150)
  self.title:SetString(STRINGS.BCL.TITLE)

  for i, boss in ipairs(BOSS) do
    local x, y = (i - 1) % 5 * 120 - 240, math.floor((i - 1) / 5) * (-130)
    local txt, img = boss .. '_txt', boss .. '_img'
    self[txt] = self.root:AddChild(Text(UIFONT, 32))
    self[txt]:SetPosition(x, y + 80)
    self[txt]:SetString(GetName(boss))
    self[img] = self.root:AddChild(Image('images/boss.xml', boss .. '.tex'))
    self[img]:SetSize(68, 68)
    self[img]:SetPosition(x, y + 30)
    self[img].OnMouseButton = function(_, button, down)
      if button == 1000 and down then OnAnnounce(boss) end -- Left Mounse Button
    end
  end

  self:Update()

  return true
end

function BossCalendar:Update()
  if not self.open or not self.init then return end

  for _, boss in ipairs(BOSS) do
    local txt, img = boss .. '_txt', boss .. '_img'
    if timestamp[boss].respawn then            -- display respawn information
      self[img]:SetTint(unpack(DARKGREY))      -- darken image for respawning
      self[txt]:SetColour(WEBCOLOURS.RED)      -- red for all other bosses
      if boss == 'daywalker' and is_next_daywalker_2 then
        self[txt]:SetColour(WEBCOLOURS.ORANGE) -- orange for Scrappy Werepig
      end
      if TUNING.BCL.CALENDAR_UNIT then
        self[txt]:SetString(TUNING.BCL.CALENDAR_STYLE and AbsoluteGameDay(boss) or CountdownGameDays(boss))
      else
        self[txt]:SetString(CountdownRealTime(boss))
      end
    else -- display boss name
      self[img]:SetTint(unpack(WHITE))
      self[txt]:SetColour(WHITE)
      self[txt]:SetString(GetName(boss))
    end
  end
end

return BossCalendar
