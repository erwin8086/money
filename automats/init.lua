--[[
	A mod for automats
	depends on bank
	Adds an Food Automat, an Tools Automat, an Ores Automat and
	an Money Automat.
	Food-, Tools- and Ores Automat:
		left-click with currency to pay in.
		Give ec card into inventory to pay with ec account.
		Give currency into inventory to pay with currency.
		Click Button to pay item(item added to players inventory).
	Money Automat:
		Sell items by click on button(item taken from players inventory).
		Give ec card into inventory slot to load money to ec cards account.
		If no ec card in inventory slot currency added to inventory.
		
]]

if minetest.get_modpath("intllib") then
		S = intllib.Getter()
	else
		S = function(s) return s end
end
-- Food Automat
minetest.register_node("automats:apple", {
	description=S("Food Automat"),
	tiles={"automats_apple.png"},
	groups={cracky=3},
	on_construct=function(pos)
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		inv:set_size("ec", 1)
		meta:set_int("currency", 0)
		local formspec = "size[10,9]"..
		"list[context;ec;9,0;1,1;]"..
		"list[current_player;main;0,5;8,4;]"..
		"button[0,1;4,1;apple;"..S("Buy an Apple: 1cr").."]"..
		"button[5,1;4,1;bread;"..S("Buy a Bread: 5cr").."]"..
		"button[0,2;4,1;wseed;"..S("Buy a Wheat Seed: 10cr").."]"..
		"button[5,2;4,1;cseed;"..S("Buy a Cotton Seed: 10cr").."]"
		meta:set_string("formspec", formspec)
		meta:set_string("raw_formspec", formspec)
		meta:set_string("pay_in", "true")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local pinv = sender:get_inventory()
		local stack = inv:get_stack("ec",1)
		local buy
		local price=0
		if fields.apple~=nil then
			price=1
			buy=ItemStack('default:apple')
		end
		if fields.bread~=nil then
			price=5
			buy=ItemStack('farming:bread')
		end
		if fields.wseed~=nil then
			price=10
			buy=ItemStack('farming:seed_wheat')
		end
		if fields.cseed~=nil then
			price=10
			buy=ItemStack('farming:seed_cotton')
		end
		if price~=0 then
			local count = bank.get_count(stack)
			if count~=nil then
				local formspec=meta:get_string("raw_formspec")
				local inm = meta:get_int("currency")
				inm=inm+count
				stack:take_item()
				meta:set_int("currency",inm)
			end
			if meta:get_int("currency") >= price then
				if pinv:room_for_item("main", buy) then
					pinv:add_item("main", buy)
					meta:set_int("currency",meta:get_int("currency")-price)
				end
			else
				if pinv:room_for_item("main", buy) and bank.is_ec(stack,0, sender) then
					local inm = meta:get_int("currency")
					price=price-inm
					meta:set_int("currency", 0)
					if bank.get_ec(stack, price, sender) then
						pinv:add_item("main", buy)
					else
						meta:set_int("currency", inm)
					end
				end
			end
		end
		local formspec = meta:get_string("raw_formspec")
		formspec = formspec.."label[0,0;"..S("Money:")..meta:get_int("currency").."]"
		meta:set_string("formspec",formspec)
		inv:set_stack("ec",1,stack)
	end,
})

minetest.register_craft({
	type="shapeless",
	output="automats:apple",
	recipe={"default:cobble", "default:apple"}
})

-- Tools Automat
minetest.register_node("automats:tools", {
	description=S("Tools Automat"),
	tiles={"automats_tools.png"},
	groups={cracky=3},
	on_construct=function(pos)
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		inv:set_size("ec", 1)
		meta:set_int("currency", 0)
		local formspec = "size[10,9]"..
		"list[context;ec;9,0;1,1;]"..
		"list[current_player;main;0,5;8,4;]"..
		"button[0,1;4,1;axe;"..S("Buy an Stoneaxe: 10cr").."]"..
		"button[5,1;4,1;pickaxe;"..S("Buy an Stonepickaxe: 10cr").."]"..
		"button[0,2;4,1;shovel;"..S("Buy an Stoneshovel: 10cr").."]"..
		"button[5,2;4,1;sword;"..S("Buy an Stonesword: 10cr").."]"..
		"button[0,3;4,1;hoe;"..S("Buy an Stonehoe: 10cr").."]"..
		"button[5,3;4,1;screwdriver;"..S("Buy an Screwdriver: 20cr").."]"
		meta:set_string("formspec", formspec)
		meta:set_string("raw_formspec", formspec)
		meta:set_string("pay_in", "true")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local pinv = sender:get_inventory()
		local stack = inv:get_stack("ec",1)
		local buy
		local price=0
		if fields.axe~=nil then
			price=10
			buy=ItemStack('default:axe_stone')
		end
		if fields.pickaxe~=nil then
			price=10
			buy=ItemStack('default:pick_stone')
		end
		if fields.shovel~=nil then
			price=10
			buy=ItemStack('default:shovel_stone')
		end
		if fields.sword~=nil then
			price=10
			buy=ItemStack('default:sword_stone')
		end
		if fields.hoe~=nil then
			price=10
			buy=ItemStack('farming:hoe_stone')
		end
		if fields.screwdriver~=nil then
			price=20
			buy=ItemStack('screwdriver:screwdriver')
		end
		if price~=0 then
			local count = bank.get_count(stack)
			if count~=nil then
				local formspec=meta:get_string("raw_formspec")
				local inm = meta:get_int("currency")
				inm=inm+count
				stack:take_item()
				meta:set_int("currency",inm)
			end
			if meta:get_int("currency") >= price then
				if pinv:room_for_item("main", buy) then
					pinv:add_item("main", buy)
					meta:set_int("currency",meta:get_int("currency")-price)
				end
			else
				if pinv:room_for_item("main", buy) and bank.is_ec(stack,0, sender) then
					local inm = meta:get_int("currency")
					price=price-inm
					meta:set_int("currency", 0)
					if bank.get_ec(stack, price, sender) then
						pinv:add_item("main", buy)
					else
						meta:set_int("currency", inm)
					end
				end
			end
		end
		local formspec = meta:get_string("raw_formspec")
		formspec = formspec.."label[0,0;"..S("Money:")..meta:get_int("currency").."]"
		meta:set_string("formspec",formspec)
		inv:set_stack("ec",1,stack)
	end,
})

minetest.register_craft({
	type="shapeless",
	output="automats:tools",
	recipe={"default:cobble", "default:axe_stone"}
})

-- Ores Automat
minetest.register_node("automats:ores", {
	description=S("Ores Automat"),
	tiles={"automats_ores.png"},
	groups={cracky=3},
	on_construct=function(pos)
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		inv:set_size("ec", 1)
		meta:set_int("currency", 0)
		local formspec = "size[10,9]"..
		"list[context;ec;9,0;1,1;]"..
		"list[current_player;main;0,5;8,4;]"..
		"button[0,1;4,1;iron;"..S("Buy an Steelingot: 20cr").."]"..
		"button[5,1;4,1;copper;"..S("Buy an Copperingot: 30cr").."]"..
		"button[0,2;4,1;coal;"..S("Buy an Coallump: 10cr").."]"..
		"button[5,2;4,1;mese;"..S("Buy an Mesecrystal: 100cr").."]"..
		"button[0,3;4,1;diamond;"..S("Buy an Diamond: 150cr").."]"
		meta:set_string("formspec", formspec)
		meta:set_string("raw_formspec", formspec)
		meta:set_string("pay_in", "true")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local pinv = sender:get_inventory()
		local stack = inv:get_stack("ec",1)
		local buy
		local price=0
		if fields.iron~=nil then
			price=20
			buy=ItemStack('default:steel_ingot')
		end
		if fields.copper~=nil then
			price=30
			buy=ItemStack('default:copper_ingot')
		end
		if fields.coal~=nil then
			price=10
			buy=ItemStack('default:coal_lump')
		end
		if fields.mese~=nil then
			price=100
			buy=ItemStack('default:mese_crystal')
		end
		if fields.diamond~=nil then
			price=150
			buy=ItemStack('default:diamond')
		end
		if price~=0 then
			local count = bank.get_count(stack)
			if count~=nil then
				local inm = meta:get_int("currency")
				inm=inm+count
				stack:take_item()
				meta:set_int("currency",inm)
			end
			if meta:get_int("currency") >= price then
				if pinv:room_for_item("main", buy) then
					pinv:add_item("main", buy)
					meta:set_int("currency",meta:get_int("currency")-price)
				end
			else
				if pinv:room_for_item("main", buy) and bank.is_ec(stack,0,sender) then
					local inm = meta:get_int("currency")
					price=price-inm
					meta:set_int("currency", 0)
					if bank.get_ec(stack, price, sender) then
						pinv:add_item("main", buy)
					else
						meta:set_int("currency", inm)
					end
				end
			end
		end
		local formspec = meta:get_string("raw_formspec")
		formspec = formspec.."label[0,0;"..S("Money:")..meta:get_int("currency").."]"
		meta:set_string("formspec",formspec)
		inv:set_stack("ec",1,stack)
	end,
})

minetest.register_craft({
	type="shapeless",
	output="automats:ores",
	recipe={"default:cobble", "default:steel_ingot"}
})

-- Money Automat
minetest.register_node("automats:money", {
	description=S("Money Automat"),
	tiles={"automats_money.png"},
	groups={cracky=3},
	on_construct=function(pos)
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		inv:set_size("ec", 1)
		local formspec = "size[10,9]"..
		"list[context;ec;9,0;1,1;]"..
		"list[current_player;main;0,5;8,4;]"..
		"button[0,1;4,1;iron;"..S("Sell an Steelingot: 20cr").."]"..
		"button[5,1;4,1;bread;"..S("Sell an Bread: 5cr").."]"..
		"button[0,2;4,1;axe;"..S("Sell an Stoneaxe: 10cr").."]"..
		"button[5,2;4,1;tree;"..S("Sell an Tree: 5cr").."]"..
		"button[0,3;4,1;cactus;"..S("Sell an Cactus: 10cr").."]"
		meta:set_string("formspec", formspec)
		meta:set_string("raw_formspec", formspec)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local pinv = sender:get_inventory()
		local stack = inv:get_stack("ec",1)
		local buy
		local price=0
		local pricei
		if fields.iron~=nil then
			pricei=ItemStack('bank:tencr 2')
			price=20
			buy=ItemStack('default:steel_ingot')
		end
		if fields.bread~=nil then
			pricei=ItemStack('bank:fifecr')
			price=5
			buy=ItemStack('farming:bread')
		end
		if fields.axe~=nil then
			pricei=ItemStack('bank:tencr')
			price=10
			buy=ItemStack('default:axe_stone')
		end
		if fields.tree~=nil then
			pricei=ItemStack('bank:fifecr')
			price=5
			buy=ItemStack('default:tree')
		end
		if fields.cactus~=nil then
			pricei=ItemStack('bank:tencr')
			price=10
			buy=ItemStack('default:cactus')
		end
		if price~=0 then
			if bank.is_ec(stack, 0, sender) then
				if pinv:contains_item("main", buy) then
					if bank.add_ec(stack, price, sender) then
						pinv:remove_item("main", buy)
					end
				end
			else
				if pinv:room_for_item("main", pricei) and pinv:contains_item("main", buy) then
					pinv:remove_item("main", buy)
					pinv:add_item("main", pricei)
				end
			end
		end
		inv:set_stack("ec",1,stack)
	end,
})

minetest.register_craft({
	type="shapeless",
	output="automats:money",
	recipe={"default:cobble", "bank:onecr"}
})