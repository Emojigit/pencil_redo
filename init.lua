-- Minetest Mod: pencil_redo - text_table.lua
-- (c) 2020 Emoji
-- Under LGPLv2.1

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)
local default_here = minetest.get_modpath("default")

local function check_protection(pos, name, text)
	if minetest.is_protected(pos, name) then
		minetest.log("action", (name ~= "" and name or "A mod")
			.. " tried to " .. text
			.. " at protected position "
			.. minetest.pos_to_string(pos))
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

pencil_redo = {}

dofile(path.."/text_table.lua")

minetest.register_craftitem("pencil_redo:pencil", {
	description = "Pencil",
	groups = {flammable = 2},
	on_use = function(itemstack, user, pointed_thing)
		local pmeta = itemstack:get_meta()
		local text = pmeta:get_string("ptext") or "" 
		if not(pointed_thing.type == "node") then
			return
		end
		local pos = minetest.get_pointed_thing_position(pointed_thing, above)
		if check_protection(pos, user and user:get_player_name() or "", " Used a pencil with text "..text.." .") then
			return
		end
		local meta = minetest.get_meta(pos);
		meta:set_string("infotext",text);
		local log_front = ""
		if user:is_player() then
			log_front = "Player "..user:get_player_name()
		else
			log_front = "A non-player Object"
		end
		minetest.log("action",log_front.." Used a pencil with text "..text.." .")
	end,
	inventory_image = "pencil.png"
})

if default_here then
	minetest.register_craft({
		output = "pencil_redo:pencil 4",
		recipe = {
			{"default:coal_lump", "", ""},
			{"group:stick", "", ""},
			{"group:stick", "", ""},
		},
	})
	minetest.register_craft({
		output = "pencil_redo:pencil 4",
		recipe = {
			{"", "default:coal_lump", ""},
			{"", "group:stick", ""},
			{"", "group:stick", ""},
		},
	})
	minetest.register_craft({
		output = "pencil_redo:pencil 4",
		recipe = {
			{"", "", "default:coal_lump"},
			{"", "", "group:stick"},
			{"", "", "group:stick"},
		},
	})
	minetest.register_craft({
		output = "pencil_redo:table",
		recipe = {
			{"group:wood", "default:cobble", "group:wood"},
			{"group:wood", "default:diamond", "group:wood"},
			{"group:wood", "group:wood", "group:wood"},
		},
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "pencil_redo:pencil",
	burntime = 5,
})
minetest.register_craft({
	type = "fuel",
	recipe = "pencil_redo:table",
	burntime = 10,
})

pencil_redo.get_pencil_stack = function(text)
	local stack = ItemStack("pencil:pencil 1")
	local meta = stack:get_meta()
	local stext = tostring(text)
	if stext=="" or type(text) == "nil" then
		meta:set_string("ptext", "")
		meta:set_string("description", "Pencil")
	else
		meta:set_string("ptext", text)
		meta:set_string("description", "Pencil With Text")
	end
	return stack
end
