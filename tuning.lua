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
    RESPAWN_INTERVAL = TUNING.DRAGONFLY_RESPAWN_TIME,
  },
  toadstool = { -- Toadstool
    DROPS = { 'shroom_skin' },
    ANIMS = { 'death' },
    RESPAWN_INTERVAL = TUNING.TOADSTOOL_RESPAWN_TIME,
  },
  beequeen = { -- Bee Queen
    DROPS = { 'hivehat' },
    ANIMS = { 'death' },
    RESPAWN_INTERVAL = TUNING.BEEQUEEN_RESPAWN_TIME,
  },
  klaus_sack = { -- Loot Stash
    DROPS = {}, -- we don't validate opening by loot drop, but listen for 'onremove' event instead.
    ANIMS = {}, -- we don't validate opening by animation, but listen for 'onremove' event instead.
    RESPAWN_INTERVAL = TUNING.KLAUSSACK_EVENT_RESPAWN_TIME,
  },
  stalker_atrium = { -- Fuelweaver
    DROPS = { 'skeletonhat' },
    ANIMS = { 'death3' },
    RESPAWN_INTERVAL = TUNING.ATRIUM_GATE_COOLDOWN + TUNING.ATRIUM_GATE_DESTABILIZE_TIME,
  },
  malbatross = { -- Malbatross
    DROPS = { 'malbatross_beak' },
    ANIMS = { 'death_ocean', 'death' },
    RESPAWN_INTERVAL = TUNING.MALBATROSS_SPAWNDELAY_BASE + TUNING.MALBATROSS_SPAWNDELAY_RANDOM,
  },
  crabking = { -- Crab King
    DROPS = { 'singingshell_octave5' },
    ANIMS = { 'death2' },
    RESPAWN_INTERVAL = TUNING.CRABKING_RESPAWN_TIME,
  },
  terrarium = { -- Terrarium
    DROPS = { 'eyemaskhat', 'shieldofterror' },
    ANIMS = { 'death' },
    RESPAWN_INTERVAL = TUNING.EYEOFTERROR_SPAWNDELAY,
  },
  daywalker = { -- Nightmare Werepig
    DROPS = { 'horrorfuel' },
    ANIMS = { 'defeat' },
    RESPAWN_INTERVAL = TUNING.DAYWALKER_RESPAWN_DAYS_COUNT * TUNING.TOTAL_DAY_TIME,
    -- will add remaining time of the day, then may add a whole day
  },
  daywalker2 = { -- Scrappy Werepig
    COLOR = GLOBAL.WEBCOLOURS.ORANGE,
    DROPS = { 'wagpunk_bits' },
    ANIMS = { 'defeat' },
    RESPAWN_INTERVAL = TUNING.DAYWALKER_RESPAWN_DAYS_COUNT * TUNING.TOTAL_DAY_TIME,
    -- will add remaining time of the day, then may add a whole day
  },
  sharkboi = { -- Frostjaw
    DROPS = { 'bootleg' },
    ANIMS = { 'sharkboi_take' },
    RESPAWN_INTERVAL = TUNING.SHARKBOI_ARENA_COOLDOWN_DAYS,
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

GLOBAL.TUNING.BCL = { -- create our mod name space
  BOSS = BOSS,
  INFO = info,
  DROPS = drops,
  BOSS_BY_DROP = boss_by_drop,
}
