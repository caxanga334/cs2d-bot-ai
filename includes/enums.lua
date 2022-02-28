---@class BOT_PRIORITY
BOT_PRIORITY = {}
BOT_PRIORITY.none = 0
BOT_PRIORITY.verylow = 1
BOT_PRIORITY.low = 2
BOT_PRIORITY.medium = 3
BOT_PRIORITY.high = 4
BOT_PRIORITY.veryhigh = 5
BOT_PRIORITY.combatlow = 6
BOT_PRIORITY.combatmedium = 7
BOT_PRIORITY.combathigh = 8
BOT_PRIORITY.critical = 9
BOT_PRIORITY.supercritical = 10

---@class GAMEMODE
GAMEMODE = {}
GAMEMODE.standard = 0
GAMEMODE.deathmatch = 1
GAMEMODE.teamdeathmatch = 2
GAMEMODE.construction = 3
GAMEMODE.zombies = 4

---@class CSTEAM
CSTEAM = {}
CSTEAM.neutral = 0 -- None/Spectator
CSTEAM.terrorist = 1 -- Terrorist/Zombies
CSTEAM.counterterrorist = 2 -- Counter-Terrorist/Survivors
CSTEAM.vip = 3 -- VIP (AS gamemode)


---@class BOT_DISTANCES
BOT_DISTANCES = {}
BOT_DISTANCES.maxvisionpixelsx = 420.0
BOT_DISTANCES.maxvisionpixelsy = 256.0