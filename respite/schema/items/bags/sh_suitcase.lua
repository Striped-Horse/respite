local INVENTORY_TYPE_ID = "grid"

ITEM.name = "Suitcase"
ITEM.desc = "A small brown suitcase for extra storage."
ITEM.model = "models/props_c17/suitcase_passenger_physics.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.invWidth = 4
ITEM.invHeight = 2
ITEM.price = 50
ITEM.category = "Storage"
ITEM.flag = "v"
ITEM.uniqueID = "stor_suitcase"

ITEM.iconCam = {
	pos = Vector(0, 200, -9),
	ang = Angle(0, 270, 0),
	fov = 8,
}

--this is used to make checking for other backpacks in the inventory a little less more efficient
local otherBags = {
	pack = true,
	pack_alice = true,
	pack_enhanced = true,
	stor_suitcase = true,
	stor_briefcase = true
}

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
		local player = item.player
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
		
		if(IsValid(item.entity)) then
			return false
		end

		if(!item:getInv()) then
			return false
		end
		
		return true
	end
}

function ITEM:onInstanced()
	local data = {
		item = self:getID(),
		w = self.invWidth,
		h = self.invHeight
	}
	
	nut.inventory.instance(INVENTORY_TYPE_ID, data)
		:next(function(inventory)
			self:setData("id", inventory:getID())
			hook.Run("SetupBagInventoryAccessRules", inventory)
			inventory:sync()
			self:resolveInvAwaiters(inventory)
		end)
end

function ITEM:onRestored()
	local invID = self:getData("id")
	if (invID) then
		nut.inventory.loadByID(invID)
			:next(function(inventory)
				hook.Run("SetupBagInventoryAccessRules", inventory)
				self:resolveInvAwaiters(inventory)
			end)
	end
end

function ITEM:onRemoved()
	local invID = self:getData("id")
	if (invID) then
		nut.inventory.deleteByID(invID)
	end
end

function ITEM:getInv()
	return nut.inventory.instances[self:getData("id")]
end

function ITEM:onSync(recipient)
	local inventory = self:getInv()
	if (inventory) then
		inventory:sync(recipient)
	end
end

function ITEM.postHooks:drop()
	local invID = self:getData("id")
	if (invID) then
		net.Start("nutInventoryDelete")
			net.WriteType(invID)
		net.Send(self.player)
	end
end

function ITEM:onCombine(other)
	local client = self.player
	local invID = self:getInv() and self:getInv():getID() or nil
	if (not invID) then return end

	-- If other item was combined onto this item, put it in the bag.
	local res = hook.Run(
		"HandleItemTransferRequest",
		client,
		other:getID(),
		nil,
		nil,
		invID
	)
	if (not res) then return end

	-- If an attempt was made, either report the error or make a
	-- "success" sound.
	res:next(function(res)
		if (not IsValid(client)) then return end
		if (istable(res) and type(res.error) == "string") then
			return client:notifyLocalized(res.error)
		end
		client:EmitSound(unpack(SOUND_BAG_RESPONSE))
	end)
end

if (SERVER) then
	function ITEM:onDisposed()
		local inventory = self:getInv()
		if (inventory) then
			inventory:destroy()
		end
	end

	function ITEM:resolveInvAwaiters(inventory)
		if (self.awaitingInv) then
			for _, d in ipairs(self.awaitingInv) do
				d:resolve(inventory)
			end
			self.awaitingInv = nil
		end
	end

	function ITEM:awaitInv()
		local d = deferred.new()
		local inventory = self:getInv()

		if (inventory) then
			d:resolve(inventory)
		else
			self.awaitingInv = self.awaitingInv or {}
			self.awaitingInv[#self.awaitingInv + 1] = d
		end

		return d
	end
end

-- Called when the item should tell whether or not it can be transfered between inventories.
function ITEM:onCanBeTransfered(oldInventory, newInventory)
	if(newInventory) then
		if(newInventory.isStorage) then
			return false
		end
		
		if(newInventory.isSafe) then
			return false
		end
	end
end