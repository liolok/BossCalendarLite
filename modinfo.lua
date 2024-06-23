name = 'Boss Calendar Lite'
description = 'Calculate and remember when bosses respawn, with click-announcing and auto-reminding.'
author = 'Boas, xaT2x, iaman2b & liolok'
version = '2024.06.24.1'
api_version = 10
dont_starve_compatible = false
dst_compatible = true
all_clients_require_mod = false
client_only_mod = true
icon_atlas = 'modicon.xml'
icon = 'modicon.tex'

-- stylua: ignore
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
for i = 1, #keys do
  keys[i] = { description = keys[i], data = 'KEY_' .. keys[i]:gsub('Keypad ', 'KP_'):upper() }
end

configuration_options = {
  {
    label = 'Keybind',
    hover = 'Assign a key, press and hold to view calendar.',
    options = keys,
    default = 'KEY_V',
    name = 'key_to_view',
  },
  {
    label = 'Font Size',
    hover = 'How big should the calendar text be?',
    options = {
      { description = '24', data = 24, hover = 'Turn up if feeling too small.' },
      { description = '26', data = 26 },
      { description = '28', data = 28 },
      { description = '30', data = 30 },
      { description = '32', data = 32, hover = 'Text may become blank if too long.' },
    },
    default = '24',
    name = 'calendar_font_size',
  },

  { name = 'Time Style', options = { { description = '', data = 0 } }, default = 0 },
  {
    label = 'Calendar',
    hover = 'How respawn time shows up in calendar.',
    options = { -- function names from BossCalendar class
      { description = 'Day', data = 'AbsoluteGameDay', hover = 'Day 21.10' },
      { description = 'Days', data = 'CountdownGameDays', hover = '19.99d' },
      { description = 'Time', data = 'CountdownRealTime', hover = 'hh:mm:ss' },
    },
    default = 'CountdownGameDays',
    name = 'calendar_time_style',
  },
  {
    label = 'Announce',
    hover = 'How do you announce respawn time.',
    options = { -- function names from BossCalendar class
      { description = 'Day', data = 'AbsoluteGameDay', hover = 'Dragonfly will repsawn on day 21.10.' },
      { description = 'Days', data = 'CountdownGameDays', hover = 'Dragonfly will repsawn in 19.99 days.' },
      { description = 'Time', data = 'CountdownRealTime', hover = 'Dragonfly will repsawn in 1 hour 30 minutes.' },
    },
    default = 'AbsoluteGameDay',
    name = 'announce_time_style',
  },

  { name = 'Remind', options = { { description = '', data = 0 } }, default = 0 },
  {
    label = 'Position',
    hover = 'Where should message appear?',
    options = {
      { description = 'Chat', data = 'chat', hover = 'Message shows up in chat history, visible to yourself only.' },
      { description = 'Head', data = 'head', hover = 'Message shows upon your player character.' },
    },
    default = 'chat',
    name = 'remind_position',
  },
  {
    label = 'Color',
    hover = 'Choose a color for message.',
    options = { -- will use PLAYERCOLOURS from constants.lua
      { description = 'Red', data = 'RED' },
      { description = 'Blue', data = 'BLUE' },
      { description = 'Purple', data = 'PURPLE' },
      { description = 'Orange', data = 'ORANGE' },
      { description = 'Yellow', data = 'YELLOW' },
      { description = 'Green', data = 'GREEN' },
    },
    default = 'GREEN',
    name = 'remind_color',
  },
  {
    label = 'Duration',
    hover = 'How long does head message last? (not for chat message)',
    options = {
      { description = 'Short', data = 3, hover = '3 Seconds' },
      { description = 'Default', data = 5, hover = '5 Seconds' },
      { description = 'Long', data = 7, hover = '7 Seconds' },
    },
    default = 5,
    name = 'talk_duration',
  },
}
