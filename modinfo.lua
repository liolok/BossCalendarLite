name = 'Boss Calendar Lite'
description = 'Calculate and remember when bosses respawn, with click-announcing and auto-reminding.'
author = 'Boas, xaT2x, iaman2b & liolok'
version = '2024.06.10.2'
api_version = 10
dont_starve_compatible = false
dst_compatible = true
all_clients_require_mod = false
client_only_mod = true
icon_atlas = 'modicon.xml'
icon = 'modicon.tex'

local function Section(title) return { name = title, options = { { description = '', data = 0 } }, default = 0 } end

local keys = {
  'Escape', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Print', 'ScrolLock', 'Pause',
  'Tilde', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Minus', 'Equals', 'Backspace',
  'Tab', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'LeftBracket', 'RightBracket', 'Backslash',
  'CapsLock', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Semicolon', 'Enter',
  'LShift', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Period', 'Slash', 'RShift', 'LCtrl', 'LAlt', 'Space', 'RAlt', 'RCtrl',
  'Insert', 'Delete', 'Home', 'End', 'PageUp', 'PageDown', 'Up', 'Down', 'Left', 'Right',
  'Keypad 0', 'Keypad 1', 'Keypad 2', 'Keypad 3', 'Keypad 4', 'Keypad 5', 'Keypad 6', 'Keypad 7', 'Keypad 8', 'Keypad 9',
  'Keypad Divide', 'Keypad Multiply', 'Keypad Minus', 'Keypad Plus', 'Keypad Enter', 'Keypad Equals',
}
for i = 1, #keys do keys[i] = { description = keys[i], data = 'KEY_' .. keys[i]:gsub('Keypad ', 'KP_'):upper() } end

configuration_options = {
  {
    name = 'KEY',
    label = 'Keybind',
    hover = 'Assign a key, press and hold to view calendar.',
    options = keys,
    default = 'KEY_V'
  },

  Section 'Time Style',
  {
    name = 'CALENDAR_TIME_STYLE',
    label = 'Calendar',
    hover = 'How respawn time shows up in calendar.',
    options = {
      { description = 'Day',  data = 'DAY',  hover = 'Day 21.1' },
      { description = 'Days', data = 'DAYS', hover = '19.9d' },
      { description = 'Time', data = 'TIME', hover = '1h 30m' },
    },
    default = 'DAYS'
  },
  {
    name = 'ANNOUNCE_TIME_STYLE',
    label = 'Announce',
    hover = 'How do you announce respawn time.',
    options = {
      { description = 'Day',  data = 'DAY',  hover = 'Dragonfly will repsawn on day 21.1.' },
      { description = 'Days', data = 'DAYS', hover = 'Dragonfly will repsawn in 19.9 days.' },
      { description = 'Time', data = 'TIME', hover = 'Dragonfly will repsawn in 1 hour 30 minutes.' },
    },
    default = 'DAYS'
  },

  Section 'Reminder',
  {
    name = 'REMINDER_LINE_COLOR',
    label = 'Color',
    hover = 'Choose a color for respawn reminder line.',
    options = { -- will use PLAYERCOLOURS from constants.lua
      { description = 'Red',    data = 'RED' },
      { description = 'Blue',   data = 'BLUE' },
      { description = 'Purple', data = 'PURPLE' },
      { description = 'Orange', data = 'ORANGE' },
      { description = 'Yellow', data = 'YELLOW' },
      { description = 'Green',  data = 'GREEN' },
    },
    default = 'GREEN'
  },
  {
    name = 'REMINDER_DURATION',
    label = 'Duration',
    hover = 'How long does respawn reminder last?',
    options = {
      { description = 'Short',   data = 3, hover = '3 Seconds' },
      { description = 'Default', data = 5, hover = '5 Seconds' },
      { description = 'Long',    data = 7, hover = '7 Seconds' },
    },
    default = 5
  },
}
