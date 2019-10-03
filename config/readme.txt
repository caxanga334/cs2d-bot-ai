# AI config file. Format: X Y TEAM HINT DATA1 DATA2

X = X COORDINATES (TILES)
Y = Y COORDINATES (TILES)
TEAM = WHICH TEAM IS THIS FOR
HINT = HINT TYPE
DATA1 = HINT DATA
DATA2 = HINT DATA

NOTES: not all hint types will use datas

===TEAMS===

0 - ALL
1 - T
2 - CT


===HINTS===

0 - POINT OF INTEREST/ROAM
Works the same way info_botnode does but can be team specific
DATA1: Not Used | DATA2: Not Used

1 - BUILD SPOT: BASE
Build spot, team base
DATA1: <Optional> Building Type | DATA2: Not Used

2 - BUILD SPOT: OFFENCE
Build spot, ideal spot for attacking enemy base
DATA1: <Optional> Building Type | DATA2: Not Used

3 - BUILD SPOT: INTEREST
Build spot, an interesting place to build
DATA1: <Optional> Building Type | DATA2: Not Used