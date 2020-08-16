-- Minetest Mod: pencil_redo - text_table.lua
-- (c) 2020 Emoji
-- Under LGPLv2.1

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path.."/text_table.lua")

minetest.register_craftitem("pencil_redo:pencil", {
	description = "Pencil",
	on_use = function(itemstack, user, pointed_thing)
		local pmeta = itemstack:get_meta()
		local text = pmeta:get_string("ptext") or "" 
		if not(pointed_thing.type == "node") then
			return
		end
		local pos = minetest.get_pointed_thing_position(pointed_thing, above)
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
