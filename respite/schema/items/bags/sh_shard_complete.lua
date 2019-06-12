ITEM.name = "Respite Orb"
ITEM.name = "Respite Orb"
ITEM.uniqueID = "respite_orb"
ITEM.desc = "A peculiar crystalline object, it emits a bright white light."
ITEM.model = "models/props_phx/misc/smallcannonball.mdl"
ITEM.material = "models/props_combine/portalball001_sheet"
ITEM.width = 1
ITEM.height = 1
ITEM.flag = "1"
ITEM.category = "Shard"
ITEM.invWidth = 3
ITEM.invHeight = 3
ITEM.color = Color(255, 255, 255)
ITEM.openTime = 0.5
ITEM.isBag = true

local otherBags = {
	respite_orb = true
}

--table for creating things
ITEM.funcTableC = {
	{
		id = "wood",
		name = "Woodcutting",
		icon = "icon16/cog.png",
		sound = "ambient/machines/machine6.wav",	
		--startString = "The machine accepts the materials and outputs adhesive."
		--endString = "The machine accepts the materials and outputs adhesive."
		prodTime = 1,
		--[[
		required = {
			["j_scrap_plastics"] = 10,
			["j_scrap_organic"] = 5,
		},
		--]]
		
		results = {
			["j_scrap_wood"] = 1,
		},
	},
}

--table for absorbing things
ITEM.funcTableA = {
	{
		id = "blight",
		name = "Blight",
		icon = "icon16/cog.png",
		sound = "ambient/machines/machine6.wav",	
		--startString = "The machine accepts the materials and outputs adhesive."
		--endString = "The machine accepts the materials and outputs adhesive."
		prodTime = 11,
		absorb = {
			"blight"
		},
		results = {
			["j_scrap_wood"] = 1,
		},
	},
}

--table for developing things
ITEM.funcTableD = {
	{
		id = "build1",
		name = "Housing",
		icon = "icon16/cog.png",
		sound = "ambient/machines/machine6.wav",	
		--startString = "The machine accepts the materials and outputs adhesive."
		--endString = "The machine accepts the materials and outputs adhesive."
		prodTime = 1,
		required = {
			["j_scrap_wood"] = 5,
			["j_scrap_metals"] = 5,
		},
		results = {
			["j_scrap_wood"] = 1,
		},
	},
}

for k, v in pairs(ITEM.funcTableC) do
	ITEM.functions[v.id] = {
		name = v.name,
		icon = v.icon,
		onRun = function(item)
			local client = item.player
			local position = client:getItemDropPos()
			local inventory = client:getChar():getInv()
			local itemInv = item:getInv()
			
			if(v.required) then
				local required = requiredItems(inventory, item, v.required)
				if (!required) then
					client:notify("You do not have the required materials.") 
					return false
				end
			end
		
			if(v.startString) then
				nut.chat.send(client, "itclose", v.startString)
			end
		
			if(v.prodTime) then
				item:setData("producing", CurTime())
				
				timer.Simple(v.prodTime, function()
					item:setData("producing", nil)
				
					if(v.results) then
						for newItem, amt in pairs(v.results) do
							itemInv:addSmart(newItem, amt, position, v.data)
						end
					end
					
					if(v.sound) then
						client:EmitSound(v.sound)
					end
					
					if(v.endString) then
						nut.chat.send(client, "itclose", v.endString)
					end
				end)
			end

			return false
		end,
		onCanRun = function(item)
			if(item:getData("producing")) then
				if(item:getData("producing") < CurTime() and item:getData("producing") + (v.prodTime or 0) >= CurTime()) then
					return false
				end
			end
			
			return true
		end
	}
end

if (CLIENT) then
	function ITEM:drawEntity(entity, item)
		entity:DrawModel()
		entity:DrawShadow(false)
		
		local pos = entity:GetPos() + entity:GetUp()
		local dlight = DynamicLight(entity:EntIndex())
		dlight.Pos = pos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 3
		dlight.Size = 128
		dlight.Decay = 1024
		dlight.style = 5
		dlight.DieTime = CurTime() + .1	
	end
end

ITEM.functions.View = {
	icon = "icon16/briefcase.png",
	onClick = function(item)
		nut.bar.actionStart = CurTime()
		nut.bar.actionEnd = CurTime() + (item.openTime or 1)
		nut.bar.actionText = "Opening.."
		surface.PlaySound("items/ammocrate_open.wav")
		
		timer.Simple((item.openTime or 1), function()
			local inventory = item:getInv()
			if (not inventory) then return false end

			local panel = nut.gui["inv"..inventory:getID()]
			local parent = item.invID and nut.gui["inv"..item.invID] or nil

			if (IsValid(panel)) then
				panel:Remove()
			end

			if (inventory) then
				local panel = nut.inventory.show(inventory, parent)
				if (IsValid(panel)) then
					panel:ShowCloseButton(true)
					panel:SetTitle(item:getName())
				end
			else
				local itemID = item:getID()
				local index = item:getData("id", "nil")
				ErrorNoHalt(
					"Invalid inventory "..index.." for bag item "..itemID.."\n"
				)
			end
		end)

		return false
	end,
	onCanRun = function(item)
		return true
	
		--[[
		local player = item.player or item:getOwner()
		local inventory = player:getChar():getInv()
		local items = inventory:getItems()
		local packs = 0
		
		for k, v in pairs(items) do
			if(otherBags[v.uniqueID]) then
				packs = packs + 1
			end
		end
		
		if(packs > 1) then
			return false
		end
		
		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return !IsValid(item.entity) and item:getData("id")
		--]]
	end
}

ITEM.functions.Claim = {
	name = "Claim Orb",
	tip = "Claim this orb as yours.",
	icon = "icon16/house.png",
	onRun = function(item)
		item:setData("char", item.player:getChar():getID())
		return false
	end,
	onCanRun = function(item)
		if(IsValid(item.entity)) then
			return false
		end
		
		if(item:getData("char") == nil or item:getData("char") == 0) then
			return true
		else
			return false
		end
	end
}

--[[
ITEM.functions.AbsorbShards = {
	name = "Absorb Shards",
	tip = "Absorb shards in inventory.",
	icon = "icon16/add.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		local shardstack = item:getData("shardcount", 10)
		local shard = inventory:getFirstItemOfType("shard")	
		while(shard) do
			shardstack = shardstack + shard:getData("shardcount", 10)
			shard:remove()
			shard = inventory:getFirstItemOfType("shard")
		end
		item:setData("shardcount", shardstack)
		item.player:EmitSound("physics/glass/glass_bottle_impact_hard3.wav")
		return false
		end,
	onCanRun = function(item)
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}

ITEM.functions.AbsorbChips = {
	name = "Absorb Chips",
	tip = "Absorb chips in inventory.",
	icon = "icon16/add.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		local chipstack = item:getData("chipcount", 0)
		local chip = inventory:getFirstItemOfType("cube_chip")	
		while(chip) do
			chipstack = chipstack + 1
			chip:remove()
			chip = inventory:getFirstItemOfType("cube_chip")
		end
		item:setData("chipcount", chipstack)
		item.player:EmitSound("physics/glass/glass_bottle_impact_hard3.wav")
		return false
	end,
	onCanRun = function(item)
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}

ITEM.functions.AbsorbEChips = {
	name = "Absorb Enhanced Chips",
	tip = "Absorb enhanced chips in inventory.",
	icon = "icon16/add.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		local chipstack = item:getData("echipcount", 0)
		local chip = inventory:getFirstItemOfType("cube_chip_enhanced")	
		while(chip) do
			chipstack = chipstack + 1
			chip:remove()
			chip = inventory:getFirstItemOfType("cube_chip_enhanced")
		end
		item:setData("echipcount", chipstack)
		item.player:EmitSound("ambient/levels/citadel/portal_beam_shoot"..math.random(1,6)..".wav", 100, 80)
		return false
	end,
	onCanRun = function(item)
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}

ITEM.functions.Farm = {
	tip = "Generate food from within the respite room.",
	icon = "icon16/world.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		
		local delay = getDelay(item)
		local amount = getAmount(item)
		
		item.player:EmitSound("plats/bigstop1.wav")	
		item:setData("producing2", CurTime())
		timer.Simple(delay, 
			function()
				if (item != nil) then
					local index = item:getData("id")
					local roomspace = nut.item.inventories[index]
					
					for i=1, amount do 
						timer.Simple(i/2, 
							function()
								roomspace:add("food_potato_plastic")
							end
						)
					end
					
					item:setData("producing2", 0)
					client:notify("Farming has finished.")
				end
			end
		)
		
		return false
	end,
	onCanRun = function(item)	
		if(!orbTimerCheck(item)) then
			return false
		end
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return orbTimerCheck(item)
	end
}

ITEM.functions.Fish = {
	tip = "Generate fish from within the respite room.",
	icon = "icon16/bug.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		
		local delay = getDelay(item)
		local amount = getAmount(item)
		
		item.player:EmitSound("plats/bigstop1.wav")
		item:setData("producing2", CurTime())
		
		timer.Simple(delay, 
			function()
				if (item != nil) then
					local index = item:getData("id")
					local roomspace = nut.item.inventories[index]

					for i=1, amount do 
						timer.Simple(i/2, 
							function()
								roomspace:add("food_fish"..math.random(1,2).."_plastic")
							end
						)
					end
					
					item:setData("producing2", 0)
					client:notify("Fishing has finished.")
				end
			end
		)
		
		return false
	end,
	onCanRun = function(item)
		if(!orbTimerCheck(item)) then
			return false
		end
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}

ITEM.functions.Hunt = {
	tip = "Generate monster meat from within the respite room.",
	icon = "icon16/bug.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		
		local delay = getDelay(item)
		local amount = getAmount(item)
		
		item.player:EmitSound("plats/bigstop1.wav")
		item:setData("producing2", CurTime())
		
		timer.Simple(delay, 
			function()
				if (item != nil) then
					local index = item:getData("id")
					local roomspace = nut.item.inventories[index]
					
					for i=1, amount do 
						timer.Simple(i/2, 
							function()
								roomspace:add("food_monster_meat")
							end
						)
					end
					
					item:setData("producing2", 0)
					client:notify("Hunting has finished.")
				end
			end
		)
		
		return false
	end,
	onCanRun = function(item)
		if(!orbTimerCheck(item)) then
			return false
		end
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}

ITEM.functions.Well = {
	tip = "Generate water from within the respite room.",
	icon = "icon16/cup.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		
		local delay = getDelay(item)
		local amount = getAmount(item)
		
		item.player:EmitSound("plats/bigstop1.wav")
		item:setData("producing2", CurTime())
		
		timer.Simple(delay, 
			function()
				if (item != nil) then
					local index = item:getData("id")
					local roomspace = nut.item.inventories[index]
					
					for i=1, amount do 
						timer.Simple(i/2, 
							function()
								roomspace:add("food_water_misc")
							end
						)
					end
					
					item:setData("producing2", 0)
					client:notify("Water has been extracted from the respite well.")
				end
			end
		)
		
		return false
	end,
	onCanRun = function(item)
		if(!orbTimerCheck(item)) then
			return false
		end
		
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}

ITEM.functions.Woodcut = {
	name = "Chop Wood",
	tip = "Generate wood from within the respite room.",
	icon = "icon16/world.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		
		local delay = getDelay(item)
		local amount = getAmount(item)
		
		item.player:EmitSound("plats/bigstop1.wav")
		item:setData("producing2", CurTime())
		
		timer.Simple(delay, 
			function()
				if (item != nil) then
					local index = item:getData("id")
					local roomspace = nut.item.inventories[index]
					roomspace:add("j_scrap_wood", 1, { Amount = (amount * 2) })
					item:setData("producing2", 0)
					client:notify("Woodcutting has finished.")
				end
			end
		)
		
		return false
	end,
	onCanRun = function(item)
		if(!orbTimerCheck(item)) then
			return false
		end
		
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}

ITEM.functions.Mine = {
	tip = "Generate concrete from within the respite room.",
	icon = "icon16/world.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		
		local delay = getDelay(item)
		local amount = getAmount(item)
		
		item.player:EmitSound("plats/bigstop1.wav")
		item:setData("producing2", CurTime())
		
		timer.Simple(delay, 
			function()
				if (item != nil) then
					local index = item:getData("id")
					local roomspace = nut.item.inventories[index]
					roomspace:add("j_scrap_concrete", 1, { Amount = (amount * 2) })
					item:setData("producing2", 0)
					client:notify("Mining has finished.")
				end
			end
		)
		
		return false
	end,
	onCanRun = function(item)
		if(!orbTimerCheck(item)) then
			return false
		end
		
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}

ITEM.functions.Scavenge = {
	name = "Scavenge",
	tip = "Generate random scrap from within the respite room.",
	icon = "icon16/map.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		
		local delay = getDelay(item)
		local amount = getAmount(item)
		
		item.player:EmitSound("plats/bigstop1.wav")
		item:setData("producing2", CurTime())
		
		timer.Simple(delay, 
			function()
				if (item != nil) then
					local index = item:getData("id")
					local roomspace = nut.item.inventories[index]
					local ranScrap = {}
					ranScrap[1] = "j_scrap_adhesive"
					ranScrap[2] = "j_scrap_battery"
					ranScrap[3] = "j_scrap_bone"
					ranScrap[4] = "j_scrap_chems"
					ranScrap[5] = "j_scrap_cloth"
					ranScrap[6] = "j_scrap_concrete"
					ranScrap[7] = "j_scrap_elastic"
					ranScrap[8] = "j_scrap_elecs"
					ranScrap[9] = "j_scrap_glass"
					ranScrap[10] = "j_scrap_light"
					ranScrap[11] = "j_scrap_metals"
					ranScrap[12] = "j_scrap_nails"
					ranScrap[13] = "j_scrap_organic"
					ranScrap[14] = "j_scrap_plastics"
					ranScrap[15] = "j_scrap_rubber"
					--ranScrap[16] = "c_scrap_gnome"
					ranScrap[16] = "j_scrap_screws"
					ranScrap[17] = "j_scrap_wood"
					--ranScrap[18] = "cube_chip"
					for i=1,amount*2 do 
						timer.Simple(i/2, 
							function()
								roomspace:add(ranScrap[math.random(1,17)])
							end
						)
					end
					item:setData("producing2", 0)
					client:notify("Scavenging has finished.")
				end
			end
		)
		
		return false
	end,
	onCanRun = function(item)
		if(item:getData("echipcount", 0) < 5) then
			return false
		end
	
		if(!orbTimerCheck(item)) then
			return false
		end
		
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}

ITEM.functions.Weather = {
	name = "Weather",
	tip = "Start some random weather in your Respite.",
	icon = "icon16/map.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		
		local delay = getDelay(item)
		local amount = getAmount(item)
		
		item.player:EmitSound("plats/bigstop1.wav")
		item:setData("producing2", CurTime())
		
		local ranWeather = {}
		ranWeather[1] = "rain"
		ranWeather[2] = "snow"
		ranWeather[3] = "fog"
		ranWeather[4] = "blue haze"
		ranWeather[5] = "black haze"
		ranWeather[6] = "pink haze"

		local weather = table.Random(ranWeather)
		local reward = "food_lemon_plastic"
		if (weather == "rain") then
			client:notify("It is raining in your Respite.")
			reward = "food_water_misc"
		elseif (weather == "snow") then
			client:notify("It is snowing in your Respite.")
			reward = "food_water_misc"
		elseif (weather == "fog") then
			client:notify("It is foggy in your Respite.")		
			reward = "food_monster_meat"
		elseif (weather == "blue haze") then
			client:notify("Blue Haze has arrived in your Respite.")		
			reward = "haze_bottled"
		elseif (weather == "black haze") then
			client:notify("Black Haze has arrived in your Respite.")
			reward = "blight"
		elseif (weather == "pink haze") then
			client:notify("Pink Haze has arrived in your Respite.")
			reward = "haze_bottled_pink"
		end
		--client:notify(weather.." has entered your Respite.")
		timer.Simple(delay, 
			function()
				if (item != nil) then
					local index = item:getData("id")
					local roomspace = nut.item.inventories[index]
					
					for i=1, math.ceil(amount/4) do 
						timer.Simple(i/2, 
							function()
								roomspace:add(reward)
							end
						)
					end
					
					item:setData("producing2", 0)
					client:notify("The "..weather.." has left your Respite.")
				end
			end
		)
		
		return false
	end,
	onCanRun = function(item)
		if(item:getData("echipcount", 0) < 5) then
			return false
		end
	
		if(!orbTimerCheck(item)) then
			return false
		end
		
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}

ITEM.functions.Portal = {
	name = "Explore Portal",
	tip = "Explore a random portal in your Respite.",
	icon = "icon16/map.png",
	onRun = function(item)
		local client = item.player
		local inventory = client:getChar():getInv()
		
		local delay = getDelay(item)
		local amount = getAmount(item)
		
		item.player:EmitSound("plats/bigstop1.wav")
		item:setData("producing2", CurTime())
		
		client:notify("Your Plastics enter a portal inside of your Respite.")
		timer.Simple(delay, 
			function()
				if (item != nil) then
					local index = item:getData("id")
					local roomspace = nut.item.inventories[index]
					
					local ranPort = {}
					ranPort[1] = "white"
					ranPort[2] = "red"
					ranPort[3] = "blue"
					ranPort[4] = "green"
					ranPort[5] = "black"
					ranPort[6] = "yellow"
					ranPort[7] = "orange"
					ranPort[8] = "brown"
					ranPort[9] = "gray"

					local portal = table.Random(ranPort)
					local reward = "food_lemon_plastic"
					if (portal == "white") then
						reward = {"cube_chip", "j_scrap_glass", "j_scrap_memory", "j_scrap_plastics"}
					elseif (portal == "red") then
						reward = {"food_monster_meat", "j_scrap_bone", "hl2_m_monsterclaw", "food_human_meat", "j_scrap_organic", "food_soda_cherry"}
					elseif (portal == "blue") then
						reward = {"food_water_misc", "j_empty_water", "food_water", "food_water_mountain", "purifier_water_tablet"}
					elseif (portal == "green") then
						reward = {"food_yams", "food_beans", "food_peas", "food_canned_1", "food_peaches", "food_corn", "j_cactus_plant"}
					elseif (portal == "black") then
						reward = {"blight", "j_scrap_memory", "drug_depress"}
					elseif (portal == "yellow") then
						reward = {"nut_flare", "nut_flare_b", "nut_flare_g", "nut_flare_o", "nut_flare_p", "nut_flare_t", "nut_flare_w", "nut_flare_y", "molotov", "flashlight"}
					elseif (portal == "orange") then
						reward = {"food_orange", "food_lemon_soda", "food_orange_plastic"}
					elseif (portal == "brown") then
						reward = {"food_tea", "food_whiskey", "j_scrap_wood", "food_potato", "food_soda_cola"}
					elseif (portal == "gray") then
						reward = {"drug_depress", "cube_chip", "drug_sleepingpills", "drug_painkillers", "food_apple_cursed", "blight"}
					end
					
					for i=1, math.ceil(amount/3) do 
						timer.Simple(i/2, 
							function()
								roomspace:add(table.Random(reward), 1)
							end
						)
					end
					
					item:setData("producing2", 0)
					client:notify("Your Plastics return from the " ..portal.. " portal.")
				end
			end
		)
		
		return false
	end,
	onCanRun = function(item)
		if(item:getData("echipcount", 0) < 5) then
			return false
		end
	
		if(!orbTimerCheck(item)) then
			return false
		end
		
		local player = item.player or item:getOwner()
	
		if(IsValid(item.entity)) then
			return false
		end

		if(item:getData("char") != player:getChar():getID()) then
			return false
		end
		
		return true
	end
}
--]]

function ITEM:getDesc()
	local str = self.desc
	
	--[[
	local size = 0
	local plastics = 0
	local eChips = self:getData("echipcount", 0)
	
	local plasDiv = 25
	
	if(eChips > 0) then
		plasDiv = 15 + (15 / eChips)
	end
	
	if (self:getData("shardcount")) then
		size = self:getData("shardcount") / 4
		size = (size * size / 2.5) --increases exponentially
		str = str .. "\nRespite Size: "..size.." square meters."
	end
	
	if (self:getData("chipcount")) then
		plastics = math.floor(self:getData("chipcount") / plasDiv)
		if(plastics > (math.floor(size / 2.5)) * 3) then --we dont want more plastics than the room can fit. at most 3 plastics for every 2.5 cubic meters.
			plastics = (math.floor(size / 2.5) * 3)
		end
		if(plastics >= 1) then
			str = str .. "\nPlastics: "..plastics.."."
		end
	end	
	
	if (eChips > 0) then
		str = str .. "\nEnhanced Chips: "..eChips.."."
	end
	--]]
	
	return Format(str)
end

function ITEM:getInv()
	return nut.inventory.instances[self:getData("id")]
end

ITEM.iconCam = {
	pos = Vector(142.9214630127, 125.8981628418, 91.33309173584),
	ang = Angle(25, 220, 0),
	fov = 4.5763000053135,
}