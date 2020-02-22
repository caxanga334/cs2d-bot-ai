# AI config file. Format: X Y TEAM HINT DATA1 DATA2

X = X COORDINATES (TILES)
Y = Y COORDINATES (TILES)
TEAM = WHICH TEAM IS THIS FOR
HINT = HINT TYPE
DATA1 = HINT DATA
DATA2 = HINT DATA

===TEAMS===

0 - ALL
1 - T
2 - CT


===HINTS===

0 - POINT OF INTEREST/ROAM
Works the same way info_botnode does but can be team specific
DATA1: Radius | DATA2: Not used

1 - BUILD SPOT: BASE
Build spot, team base
DATA1: <Optional> Building Type | DATA2: Radius

2 - BUILD SPOT: OFFENCE
Build spot, ideal spot for attacking enemy base
DATA1: <Optional> Building Type | DATA2: Radius

3 - BUILD SPOT: INTEREST
Build spot, an interesting place to build
DATA1: <Optional> Building Type | DATA2: Radius

4 - GOAL ROUTE
Bots will go to the map goal after reaching this point
DATA1: Radius | DATA2: not used
TIP: Use this to make bots take alternative routes to bomb sites, hostages, escape point, etc

===NOTES===

Not all hint types will use datas

Radius data must always be negative

Building type is the object internal type ID
	Barricade || 1
	Barbed Wire || 2
	Wall 1 || 3
	Wall 2 || 4
	Wall 3 || 5
	Gate Field || 6
	Dispenser || 7
	Turret || 8
	Supply || 9
	Teleporter Entrance || 13
	Teleporter Exit || 14