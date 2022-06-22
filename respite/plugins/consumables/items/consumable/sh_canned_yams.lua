ITEM.name = "Canned Yams"
ITEM.prefix = "Yam"
ITEM.desc = "A can filled with yams."
ITEM.uniqueID = "food_yams"
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl"
ITEM.quantity2 = 3
ITEM.price = 5
ITEM.container = "j_tinc"
 
ITEM.attrib = { 
	["stm"] = 1, 
	["accuracy"] = 1, 
	["str"] = 1 
}

ITEM.loot = {
	["Consumable"] = 11,
	["Food"] = 6,
	["Canned"] = 11,
}

ITEM.craft = {
	hp = 3,

	buffTbl = {
		attrib = {
			["stm"] = 1, 
			["accuracy"] = 1, 
			["str"] = 1 
		},
		
		res = {
			["Taunt"] = 5,
			["Time"] = 5,
		}
	},
}

ITEM.iconCam = {
	pos = Vector(-200, 0, -0.5),
	ang = Angle(0, -0, 0),
	fov = 2.25,
}