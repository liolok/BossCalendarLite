local BOSS = { -- codename for bosses
  'dragonfly', -- Dragonfly
  'toadstool', -- Toadstool
  'beequeen', -- Bee Queen
  'klaus_sack', -- Loot Stash
  'stalker_atrium', -- Fuelweaver
  'malbatross', -- Malbatross
  'crabking', -- Crab King
  'terrarium', -- Terrarium
  'daywalker', -- Nightmare Werepig / Scrappy Werepig
  'sharkboi', -- Frostjaw
}

local info = { -- all other information of bosses
  dragonfly = { -- Dragonfly
    DROPS = { 'dragon_scales' },
    ANIMS = { 'death' },
    KEYS = { 'DRAGONFLY_RESPAWN_TIME' },
  },
  toadstool = { -- Toadstool
    DROPS = { 'shroom_skin' },
    ANIMS = { 'death' },
    KEYS = { 'TOADSTOOL_RESPAWN_TIME' },
  },
  beequeen = { -- Bee Queen
    DROPS = { 'hivehat' },
    ANIMS = { 'death' },
    KEYS = { 'BEEQUEEN_RESPAWN_TIME' },
  },
  klaus_sack = { -- Loot Stash
    DROPS = {}, -- we don't validate opening by loot drop, but listen for 'onremove' event instead.
    ANIMS = {}, -- we don't validate opening by animation, but listen for 'onremove' event instead.
    KEYS = { 'KLAUSSACK_EVENT_RESPAWN_TIME' },
  },
  stalker_atrium = { -- Fuelweaver
    DROPS = { 'skeletonhat' },
    ANIMS = { 'death3' },
    KEYS = { 'ATRIUM_GATE_COOLDOWN', 'ATRIUM_GATE_DESTABILIZE_TIME' },
  },
  malbatross = { -- Malbatross
    DROPS = { 'malbatross_beak' },
    ANIMS = { 'death_ocean', 'death' },
    KEYS = { 'MALBATROSS_SPAWNDELAY_BASE', 'MALBATROSS_SPAWNDELAY_RANDOM' },
  },
  crabking = { -- Crab King
    DROPS = { 'singingshell_octave5' },
    ANIMS = { 'death2' },
    KEYS = { 'CRABKING_RESPAWN_TIME' },
  },
  terrarium = { -- Terrarium
    DROPS = { 'eyemaskhat', 'shieldofterror' },
    ANIMS = { 'death' },
    KEYS = { 'EYEOFTERROR_SPAWNDELAY' },
  },
  daywalker = { -- Nightmare Werepig
    DROPS = { 'horrorfuel' },
    ANIMS = { 'defeat' },
    KEYS = { 'DAYWALKER_RESPAWN_DAYS_COUNT' },
    -- will multiply seconds of a day, add remaining time of the day, then maybe add a whole day
  },
  daywalker2 = { -- Scrappy Werepig
    COLOR = GLOBAL.WEBCOLOURS.ORANGE,
    DROPS = { 'wagpunk_bits' },
    ANIMS = { 'defeat' },
    KEYS = { 'DAYWALKER_RESPAWN_DAYS_COUNT' },
    -- will multiply seconds of a day, add remaining time of the day, then maybe add a whole day
  },
  sharkboi = { -- Frostjaw
    DROPS = { 'bootleg' },
    ANIMS = { 'sharkboi_take' },
    KEYS = { 'SHARKBOI_ARENA_COOLDOWN_DAYS' },
  },
}
-- use red for all other bosses except Scrappy Werepig
for _, boss in ipairs(BOSS) do
  info[boss].COLOR = GLOBAL.WEBCOLOURS.RED
end

local drops = {}
local boss_by_drop = {} -- to quick backward query by drop prefab name
for boss, i in pairs(info) do
  for _, drop in pairs(i.DROPS) do
    table.insert(drops, drop)
    boss_by_drop[drop] = boss
  end
end

GLOBAL.TUNING.BOSS_CALENDAR = { -- create our mod namespace
  BOSS = BOSS,
  INFO = info,
  DROPS = drops,
  BOSS_BY_DROP = boss_by_drop,
  VIEW_KEY = GLOBAL.rawget(GLOBAL, GetModConfigData('key_to_view')),
  FONT_SIZE = GetModConfigData('calendar_font_size'),
  CALENDAR_TIME_STYLE = GetModConfigData('calendar_time_style'),
  ANNOUNCE_TIME_STYLE = GetModConfigData('announce_time_style'),
  REMIND_POSITION = GetModConfigData('remind_position'),
  REMIND_COLOR = GetModConfigData('remind_color'),
  TALK_DURATION = GetModConfigData('talk_duration'),
}
