-- Minetest Mod: pencil_redo - init.lua
-- (c) 2020, 2022  Emoji
-- Under LGPLv2.1

local path = minetest.get_modpath("pencil_redo")
local S = minetest.get_translator("pencil_redo")
local gui = flow.widgets
pencil_redo = {}

-- We no longer need a table
minetest.register_alias("pencil_redo:table","air")

local my_gui = flow.make_gui(function(player, ctx)
	return gui.VBox {
		gui.Label {
			label = S("Change the infotext of node at @1",minetest.pos_to_string(ctx.pos)),
		},
		gui.Box{w = 1, h = 0.05, color = "grey", padding = 0.25},
		gui.Textarea {
			name = "infotextField",
			h = 3, w = 6, default = minetest.get_meta(ctx.pos):get_string("infotext")
		},
		gui.HBox {
			gui.ButtonExit {
				label = S("Abort"), w = 1, expand = true,
			},
			gui.ButtonExit {
				label = S("Confirm"), w = 1, expand = true,
				on_event = function(player,ctx)
					local pos = ctx.pos
					local name = player:get_player_name()
					if minetest.is_protected(name,pos) then
						minetest.record_protection_violation(name,pos)
						return
					end
					local meta = minetest.get_meta(ctx.pos)
					if ctx.form.infotextField then
						minetest.log("action",name .. "used a pencil on node at " .. minetest.pos_to_string(pos) .. " with the following infotext:\n" .. ctx.form.infotextField)
						meta:set_string("infotext",ctx.form.infotextField)
					end
				end
			},
		}
	}
end)

minetest.register_craftitem("pencil_redo:pencil", {
	description = S("Pencil"),
	_doc_items_longdesc = S("Tool to edit infotext of nodes"),
	_doc_items_usagehelp = S("Rightclick on a node to edit its infotext."),
	on_place = function(itemstack, placer, pointed_thing)
		if not placer:is_player() then return end
		local pos = pointed_thing.under
		local node = minetest.get_node(pos).name
		local name = placer:get_player_name()
		if node == "air" or node == "ignore" then
			minetest.chat_send_player(name,S("Invalid node!"))
			return
		elseif minetest.is_protected(name,pos) then
			minetest.record_protection_violation(name,pos)
			return
		end
		my_gui:show(placer,{pos=pos})
	end,
	inventory_image = "pencil_pencil.png",
	stack_max = 1,
})

if default then
	minetest.register_craft({
		output = "pencil_redo:pencil",
		recipe = {
			{"default:coal_lump"},
			{"group:stick"},
			{"group:stick"},
		},
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "pencil_redo:pencil",
	burntime = 5,
})
