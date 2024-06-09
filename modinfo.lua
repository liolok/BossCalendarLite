name = 'Boss Calendar Lite'
description = 'Calculate and remember when bosses respawn, with click-announcing and auto-reminding.'
author = 'Boas, xaT2x, iaman2b & liolok'
version = '2024.06.10.1'
api_version = 10
dont_starve_compatible = false
dst_compatible = true
all_clients_require_mod = false
client_only_mod = true
icon_atlas = 'modicon.xml'
icon = 'modicon.tex'

local function AddConfigOption(desc, data, hover)
  return {
    description = desc,
    data = data,
    hover = hover
  }
end

local function AddConfig(label, name, options, default, hover)
  return {
    label = label,
    name = name,
    options = options,
    default = default,
    hover = hover
  }
end

local function AddSection(title) return AddConfig(title, '', { { description = '', data = 0 } }, 0) end

local function GetKeyboardOptions()
  local keys = {}
  local special_keys = {
    'TAB', 'MINUS', 'SPACE', 'ENTER', 'ESCAPE', 'INSERT', 'DELETE', 'END',
    'PAUSE', 'PRINT', 'CAPSLOCK', 'SCROLLOCK', 'RSHIFT', 'LSHIFT', 'SHIFT',
    'RCTRL', 'LCTRL', 'CTRL', 'RALT', 'LALT', 'ALT', 'BACKSPACE', 'PERIOD',
    'SLASH', 'SEMICOLON', 'LEFTBRACKET', 'RIGHTBRACKET', 'BACKSLASH', 'TILDE',
    'UP', 'DOWN', 'RIGHT', 'LEFT', 'PAGEUP', 'PAGEDOWN'
  }

  local function AddConfigKey(t, key) t[#t + 1] = AddConfigOption(key, 'KEY_' .. key) end

  for i = 65, 90 do AddConfigKey(keys, (i .. ''):char()) end -- A-Z
  for i = 1, 10 do AddConfigKey(keys, i % 10) end            -- 1-0
  for i = 1, 12 do AddConfigKey(keys, 'F' .. i) end          -- F1-F12
  for i = 1, #special_keys do AddConfigKey(keys, special_keys[i]) end

  return keys
end

configuration_options = {
  AddSection 'Keybind',
  AddConfig(
    'Open key',
    'OPEN_KEY',
    GetKeyboardOptions(),
    'KEY_V',
    'Assign a key, press and hold to view calendar.'
  ),

  AddSection 'Calendar',
  AddConfig(
    'Calendar time unit',
    'CALENDAR_UNIT',
    {
      AddConfigOption('Game Days', true, 'Pick your style below'),
      AddConfigOption('Real Time', false, '1h 30m'),
    },
    true
  ),
  AddConfig(
    'Calendar time style',
    'CALENDAR_STYLE',
    {
      AddConfigOption('Absolute Day', true, 'Day 21.1'),
      AddConfigOption('Countdown Days', false, '19.9d'),
    },
    false
  ),

  AddSection 'Announcing',
  AddConfig(
    'Announce time unit',
    'ANNOUNCE_UNIT',
    {
      AddConfigOption('Game Days', true, 'Pick your style below'),
      AddConfigOption('Real Time', false, 'Dragonfly will repsawn in 1 hour 30 minutes.'),
    },
    true
  ),
  AddConfig(
    'Announce time style',
    'ANNOUNCE_STYLE',
    {
      AddConfigOption('Absolute Day', true, 'Dragonfly will repsawn on day 21.1.'),
      AddConfigOption('Countdown Days', false, 'Dragonfly will repsawn in 19.9 days.'),
    },
    false
  ),

  AddSection 'Reminder',
  AddConfig(
    'Reminder color',
    'REMINDER_COLOR',
    { -- will use PLAYERCOLOURS from constants.lua
      AddConfigOption('Red', 'RED'),
      AddConfigOption('Blue', 'BLUE'),
      AddConfigOption('Purple', 'PURPLE'),
      AddConfigOption('Orange', 'ORANGE'),
      AddConfigOption('Yellow', 'YELLOW'),
      AddConfigOption('Green', 'GREEN'),
    },
    'GREEN'
  ),
  AddConfig(
    'Reminder duration',
    'REMINDER_DURATION',
    {
      AddConfigOption('Short', 3, 'Reminders last for 3 seconds'),
      AddConfigOption('Default', 5, 'Reminders last for 5 seconds'),
      AddConfigOption('Long', 7, 'Reminders last for 7 seconds'),
    },
    5
  ),
}
