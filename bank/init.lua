--[[
	A mod for currency and bankomat card
	depends on money2
	Add a Bankomat, an ec card
	and 1, 5, 10 currency
	Crafts:
		SC = Bankomat
		SG = ec card
		-------------
		S = Cobble
		C = Coallump
		G = Goldingot
	Use:
		Bankomat don't requirre ec card.
		It's Used to get currency from money2 account
		and to load currency to money2 account(pay in).
		ec card is bound to the "crafter", so don't cheat it and
		don't give it untrusted persons.
]]
if minetest.get_modpath("intllib") then
		S = intllib.Getter()
	else
		S = function(s) return s end
end
bank = {}

--[[
	Prints message to player
]]
bank.print = function(name, msg)
	minetest.chat_send_player(name, "bank: "..msg)
end


--[[
	Checks if player has an money2 account
]]
bank.has_credit = function(name, player)
	if not money.has_credit(name) then
		bank.print(player:get_player_name(), S("Error :")..name..S(" has no bank account"))
		return false
	end
	return true
end
--[[
	Is used when left-click with currency.
	If node has string "pay_in" set to "true", money loaded into node.
]]
bank.add_money = function(count, pos, stack)
	pos.y=pos.y-1
	local meta = minetest.get_meta(pos)
	if meta:get_string("pay_in") ~= "true" then
		return nil
	end
	local inm = meta:get_int("currency")
	inm=inm+count
	meta:set_int("currency", inm)
	local formspec = meta:get_string("raw_formspec")
	formspec = formspec.."label[0,0;Money:"..inm.."]"
	meta:set_string("formspec", formspec)
	stack:take_item()
	return stack
	
		
end
--[[
	Is used to get value of currency stack.
	returns nil if stack is no currency.
]]
bank.get_count= function(stack)
	if stack:get_name()=="bank:onecr" then
		return 1
	end
	if stack:get_name()=="bank:fifecr" then
		return 5
	end
	if stack:get_name()=="bank:tencr" then
		return 10
	end
end
--[[
	Check if ec card has count credit.
	if count = 0, it's checks if stack is a ec card
]]
bank.is_ec=function(stack, count, player)
	if stack:get_name()=="bank:ec" then
		local name = stack:get_metadata()
		if name == "" then
			bank.print(player:get_player_name(), S("Error ec card has no owner. Don't cheat ec card with giveme use get_ec"))
			return false
		end
		if not bank.has_credit(name, player) then
			return false
		end
		local money = money.get(name)
		if money == nil then
			bank.print(player:get_player_name(), S("Error :")..name..S(" has no bank account"))
			return false
		end
		if money >= count then
			return true
		else
			bank.print(player:get_player_name(), S("Error :")..name..S(" has not enoug credit"))
		end
	end
	return false
end

--[[
	Gets money from ec card. if returns true get was successfully
	else returns false
]]
bank.get_ec=function(stack, count, player)
	if bank.is_ec(stack, count, player) == true then
		local name = stack:get_metadata()
		money.dec(name, count)
		return true
	end
	return false
end

--[[
	Adds money to ec card. if return true add was successfully
	else returns false
]]
bank.add_ec=function(stack, count, player)
	if bank.is_ec(stack, 0, player) then
		local name = stack:get_metadata()
		money.add(name, count)
		return true
	end
	return false
end

-- One Currency
minetest.register_craftitem("bank:onecr", {
	description=S("one currency"),
	inventory_image="bank_onecr.png",
	on_use=function(stack, user, pt)
		if pt.type=="node" then
			return bank.add_money(1, pt.above, stack)
		end
	end,
})


-- Fife Currency
minetest.register_craftitem("bank:fifecr", {
	description=S("fife currency"),
	inventory_image="bank_fifecr.png",
	on_use=function(stack, user, pt)
		if pt.type=="node" then
			return bank.add_money(5, pt.above, stack)
		end
	end,
})

-- Ten Currency
minetest.register_craftitem("bank:tencr", {
	description=S("ten currency"),
	inventory_image="bank_tencr.png",
	on_use=function(stack, user, pt)
		if pt.type=="node" then
			return bank.add_money(10, pt.above, stack)
		end
	end,
})

-- ec card
minetest.register_craftitem("bank:ec", {
	description=S("EC Card"),
	stack_max=1,
	inventory_image="bank_ec.png"
})

-- Add name to ec card
minetest.register_on_craft(function(stack, player, old, inv)
	if stack:get_name()=="bank:ec" then
		stack:set_metadata(player:get_player_name())
		return stack
	end
end)

-- The Bankomat
minetest.register_node("bank:bankomat", {
	tiles= {"bank_bankomat.png"},
	description=S("Bankomat"),
	groups={cracky=3},
	-- Set formspec and inventory
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[10,9]"..
		"list[context;main;0,0;1,1;]"..
		"button[0,2;4,1;inm;"..S("Pay In").."]"..
		"button[5,2;4,1;out1;"..S("Get 1cr").."]"..
		"button[0,4;4,1;out5;"..S("Get 5cr").."]"..
		"button[5,4;4,1;out10;"..S("Get 10cr").."]"..
		"list[current_player;main;0,5;8,4;]")
		local inv = meta:get_inventory()
		inv:set_size("main", 1)

	end,
	-- Pay out and in
	on_receive_fields=function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack("main",1)
		if not bank.has_credit(sender:get_player_name(), sender) then
			return nil
		end
		-- Pay in
		if fields.inm~=nil then
			if bank.get_count(stack) ~= nil then
				money.add(sender:get_player_name(), bank.get_count(stack))
				stack:take_item()
			end
		end
		-- Pay Out
		if stack:get_count()==0 then
			-- One Currency
			if fields.out1~=nil then
				if money.get(sender:get_player_name()) >= 1 then
					stack = ItemStack("bank:onecr")
					money.dec(sender:get_player_name(), 1)
				end
			end
			-- Fife Currency			
			if fields.out5~=nil then
				if money.get(sender:get_player_name()) >= 5 then
					stack = ItemStack("bank:fifecr")
					money.dec(sender:get_player_name(), 5)
				end
			end
			-- Ten Currency
			if fields.out10~=nil then
				if money.get(sender:get_player_name()) >= 10 then
					stack = ItemStack("bank:tencr")
					money.dec(sender:get_player_name(), 10)
				end
			end
		end		
		inv:set_stack("main", 1, stack)
			
			
	end,
})

minetest.register_craft({
	type="shapeless",
	output="bank:ec",
	recipe={"default:cobble", "default:gold_ingot"}
})

minetest.register_craft({
	type="shapeless",
	output="bank:bankomat",
	recipe={"default:coal_lump", "default:cobble"}
})

minetest.register_chatcommand("get_ec", {
	privs = {money_admin=true},
	params = "<account>",
	description = "Get a ec card for an account",
	func = function(name, param)
		if param=="" then
			bank.print(name, S("Error you must specific an account"))
		else
			local player = minetest.get_player_by_name(name)
			if player == nil then
				return nil
			end
			local inv = player:get_inventory()
			local stack = ItemStack('bank:ec')
			stack:set_metadata(param)
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			else
				bank.print(name, S("Error your inventory is full"))
			end
		end
	end
})