name = "Boss Calendar Lite"
description = "Caculate and remember when bosses respawn, with click-announcing and auto-reminding."

icon_atlas = "modicon.xml"
icon = "modicon.tex"

author = "Boas (Altered by xaT2x) (Altered by iaman2b & liolok)"
version = "1.1.20240601"

dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true

all_clients_require_mod = false
client_only_mod = true

api_version = 10

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

local function AddSectionTitle(title)
    return AddConfig(title, "", {{description = "", data = 0}}, 0)
end

local function GetKeyboardOptions()
    local keys = {}
    local special_keys = {
        "TAB",
        "MINUS",
        "SPACE",
        "ENTER",
        "ESCAPE",
        "INSERT",
        "DELETE",
        "END",
        "PAUSE",
        "PRINT",
        "CAPSLOCK",
        "SCROLLOCK",
        "RSHIFT",
        "LSHIFT",
        "SHIFT",
        "RCTRL",
        "LCTRL",
        "CTRL",
        "RALT",
        "LALT",
        "ALT",
        "BACKSPACE",
        "PERIOD",
        "SLASH",
        "SEMICOLON",
        "LEFTBRACKET",
        "RIGHTBRACKET",
        "BACKSLASH",
        "TILDE",
        "UP",
        "DOWN",
        "RIGHT",
        "LEFT",
        "PAGEUP",
        "PAGEDOWN"
    }

    local function AddConfigKey(t, key)
        t[#t + 1] = AddConfigOption(key, "KEY_" .. key)
    end

    local function AddDisabledConfigOption(t)
        t[#t + 1] = AddConfigOption("Disabled", false)
    end

    AddDisabledConfigOption(keys)

    local string = ""
    for i = 1, 26 do
        AddConfigKey(keys, string.char(64 + i))
    end

    for i = 1, 10 do
        AddConfigKey(keys, i % 10 .. "")
    end

    for i = 1, 12 do
        AddConfigKey(keys, "F" .. i)
    end

    for i = 1, #special_keys do
        AddConfigKey(keys, special_keys[i])
    end
    
    AddDisabledConfigOption(keys)

    return keys
end

local KeyboardOptions = GetKeyboardOptions()

local CalendarUnitOptions = {
    AddConfigOption("Game Days", true, "Pick your style below"),
    AddConfigOption("Real Time", false, "1h 30m"),
}
local CalendarStyleOptions = {
    AddConfigOption("Absolute Day", true, "Day 21.1"),
    AddConfigOption("Countdown Days", false, "19.9d"),
}

local AnnounceUnitOptions = {
    AddConfigOption("Game Days", true, "Pick your style below"),
    AddConfigOption("Real Time", false, "Dragonfly should be ready in 1 hour 30 minutes."),
}
local AnnounceStyleOptions = {
    AddConfigOption("Absolute Day", true, "Dragonfly should be ready on day 21.1."),
    AddConfigOption("Countdown Days", false, "Dragonfly should be ready in 19.9 days."),
}

local ColorOptions = {
    "White",
    "Red",
    "Coral",
    "Orange",
    "Yellow",
    "Khaki",
    "Chocolate",
    "Brown",
    "Green",
    "Light Green",
    "Cyan",
    "Blue",
    "Light Blue",
    "Purple",
    "Pink"
}

for i = 1, #ColorOptions do
    ColorOptions[i] = AddConfigOption(ColorOptions[i], ColorOptions[i])
end

local SayDurationOptions = {
    AddConfigOption("Short", 3, "Reminders last for 3 seconds"),
    AddConfigOption("Default", 5, "Reminders last for 5 seconds"),
    AddConfigOption("Long", 7, "Reminders last for 7 seconds"),
}

local SettingMessage  = "Set to your preference"
local AssignKeyMessage = "Assign a key, press and hold to view calendar."

configuration_options =
{
    AddSectionTitle("Keybind"),
    AddConfig(
        "Open key",
        "OPEN_KEY",
        KeyboardOptions,
        "KEY_V",
        AssignKeyMessage
    ),

    AddSectionTitle("Calendar"),
    AddConfig(
        "Calendar time unit",
        "CALENDAR_UNIT",
        CalendarUnitOptions,
        true,
        SettingMessage 
    ),
    AddConfig(
        "Calendar time style",
        "CALENDAR_STYLE",
        CalendarStyleOptions,
        false,
        SettingMessage 
    ),

    AddSectionTitle("Announcing"),
    AddConfig(
        "Announce time units",
        "ANNOUNCE_UNIT",
        AnnounceUnitOptions,
        true,
        SettingMessage 
    ),
    AddConfig(
        "Announce time style",
        "ANNOUNCE_STYLE",
        AnnounceStyleOptions,
        false,
        SettingMessage 
    ),


    AddSectionTitle("Reminder"),
    AddConfig(
        "Reminder color",
        "REMINDER_COLOR",
        ColorOptions,
        "Green",
        SettingMessage 
    ),
    AddConfig(
        "Reminder duration",
        "REMINDER_DURATION",
        SayDurationOptions,
        5,
        SettingMessage 
    ),
}
