BOSS = { -- codename for bosses
    "dragonfly", "beequeen", "klaus_sack", "toadstool", "stalker_atrium",
    "crabking", "malbatross", "terrarium", "daywalker",
}

INFO = { -- all other information of bosses
    dragonfly = {
        NAME = "Dragonfly",
        DROPS = {"dragon_scales"},
        ANIMS = {"death"},
        RESPAWN_INTERVAL = TUNING.DRAGONFLY_RESPAWN_TIME,
    },
    beequeen = {
        NAME = "Bee Queen",
        DROPS = {"hivehat"},
        ANIMS = {"death"},
        RESPAWN_INTERVAL = TUNING.BEEQUEEN_RESPAWN_TIME,
    },
    klaus = {
        NAME = "Loot Stash",
        DROPS = {"klaussackkey"},
        ANIMS = {"death"},
        RESPAWN_INTERVAL = TUNING.KLAUSSACK_EVENT_RESPAWN_TIME,
    },
    toadstool = {
        NAME = "Toadstool",
        DROPS = {"shroom_skin"},
        ANIMS = {"death"},
        RESPAWN_INTERVAL = TUNING.TOADSTOOL_RESPAWN_TIME,
    },
    fuelweaver = {
        NAME = "Fuelweaver",
        DROPS = {"skeletonhat"},
        ANIMS = {"death3"},
        RESPAWN_INTERVAL = TUNING.ATRIUM_GATE_COOLDOWN + TUNING.ATRIUM_GATE_DESTABILIZE_TIME,
    },
    crabking = {
        NAME = "Crab King",
        DROPS = {"singingshell_octave5"},
        ANIMS = {"death2"},
        RESPAWN_INTERVAL = TUNING.CRABKING_RESPAWN_TIME,
    },
    malbatross = {
        NAME = "Malbatross",
        DROPS = {"malbatross_beak"},
        ANIMS = {"death_ocean", "death"},
        RESPAWN_INTERVAL = TUNING.MALBATROSS_SPAWNDELAY_BASE + TUNING.MALBATROSS_SPAWNDELAY_RANDOM,
    },
    terrarium = {
        NAME = "Terrarium",
        DROPS = {"eyemaskhat", "shieldofterror"},
        ANIMS = {"death", "defeat"},
        RESPAWN_INTERVAL = TUNING.EYEOFTERROR_SPAWNDELAY,
    },
    daywalker = {
        NAME = "Nightmare Werepig",
        DROPS = {"horrorfuel"},
        ANIMS = {"defeat"},
        RESPAWN_INTERVAL = (TUNING.DAYWALKER_RESPAWN_DAYS_COUNT + 1) * TUNING.TOTAL_DAY_TIME,
        -- will subtract time spent on current day
    },
    daywalker2 = {
        NAME = "Scrappy Werepig",
        DROPS = {"wagpunk_bits"},
        ANIMS = {"defeat"},
        RESPAWN_INTERVAL = (TUNING.DAYWALKER_RESPAWN_DAYS_COUNT + 1) * TUNING.TOTAL_DAY_TIME,
        -- will subtract time spent on current day
    },
}

BOSS_BY_DROP = {} -- to quick backward query by drop prefab name
for boss, info in pairs(INFO) do
    for _, drop in pairs(info.DROPS) do 
        BOSS_BY_DROP[drop] = boss
    end
end
