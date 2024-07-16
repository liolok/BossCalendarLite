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

local RESPAWN_TIME = {
  dragonfly = { 'DRAGONFLY_RESPAWN_TIME' },
  toadstool = { 'TOADSTOOL_RESPAWN_TIME' },
  beequeen = { 'BEEQUEEN_RESPAWN_TIME' },
  klaus_sack = { 'KLAUSSACK_EVENT_RESPAWN_TIME' },
  stalker_atrium = { 'ATRIUM_GATE_COOLDOWN', 'ATRIUM_GATE_DESTABILIZE_TIME' },
  malbatross = { 'MALBATROSS_SPAWNDELAY_BASE', 'MALBATROSS_SPAWNDELAY_RANDOM' },
  crabking = { 'CRABKING_RESPAWN_TIME' },
  terrarium = { 'EYEOFTERROR_SPAWNDELAY' },
  daywalker = { 'DAYWALKER_RESPAWN_DAYS_COUNT' }, -- will multiply seconds of a day, add remaining time of the day, then maybe add a whole day
  daywalker2 = { 'DAYWALKER_RESPAWN_DAYS_COUNT' }, -- will multiply seconds of a day, add remaining time of the day, then maybe add a whole day
  sharkboi = { 'SHARKBOI_ARENA_COOLDOWN_DAYS' },
}

local ANIM = {
  klaus_sack = 'open',
  stalker_atrium = 'death3',
  malbatross = 'death_ocean',
  crabking = 'death2',
  daywalker = 'defeat',
  daywalker2 = 'defeat',
  sharkboi = 'sharkboi_take',
}

local PREFAB = {
  toadstool = { 'toadstool', 'toadstool_dark' },
  terrarium = { 'eyeofterror', 'twinofterror1', 'twinofterror2' },
}

local DROP = {
  horrorfuel = 'daywalker',
  scrap_monoclehat2 = 'daywalker',
  bootleg = 'sharkboi',
}

local prefab_boss = {}
for _, boss in ipairs(BOSS) do
  if not DROP[boss] then
    for _, prefab in ipairs(PREFAB[boss] or { boss }) do
      prefab_boss[prefab] = boss
    end
  end
end

GLOBAL.TUNING.BOSS_CALENDAR = { -- create our mod namespace
  BOSS = BOSS,
  RESPAWN_TIME = RESPAWN_TIME,
  ANIM = ANIM,
  BY_DROP = DROP,
  BY_PREFAB = prefab_boss,
  VIEW_KEY = GLOBAL.rawget(GLOBAL, GetModConfigData('key_to_view')),
  FONT_SIZE = GetModConfigData('calendar_font_size'),
  CALENDAR_TIME_STYLE = GetModConfigData('calendar_time_style'),
  ANNOUNCE_TIME_STYLE = GetModConfigData('announce_time_style'),
  REMIND_POSITION = GetModConfigData('remind_position'),
  REMIND_COLOR = GetModConfigData('remind_color'),
  TALK_DURATION = GetModConfigData('talk_duration'),
}
