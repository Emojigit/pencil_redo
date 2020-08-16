-- Minetest Mod: pencil_redo - text_table.lua
-- Origin Codes (c) 2017 orwell96
-- Edited code (c) 2020 Emoji
-- Under LGPLv2.1

minetest.register_privilege("pencil_redo_long_names", "When using the Engraving Table, Player can set names that contain more than 40 characters and/or newlines")

minetest.register_node("pencil_redo:table", {
	description = "Pencil Text Editing Table",
	tiles = {"engrave_top.png", "engrave_side.png"},
	groups = {choppy=2,flammable=3, oddly_breakable_by_hand=2},
	sounds = default and default.node_sound_wood_defaults(),
	on_rightclick = function(pos, node, player)
		local pname=player:get_player_name()
		local stack=player:get_wielded_item()
		if not(stack:get_name()=="pencil_redo:pencil") then
			minetest.chat_send_player(pname, "Please wield the pencil you want to change the text, and then click the edit table again.")
			return
		end
		local idef=minetest.registered_items[stack:get_name()]
		if not idef then
			minetest.chat_send_player(pname, "You can't name an unknown item!")
			return
		end
		local what="Pencil"
		if stack:get_count()>1 then
			what="stack of "..what
		end
		local name = ""
		local meta=stack:get_meta()
		if meta then
			local metaname=meta:get_string("ptext") or ""
			name=metaname
		end
		local fieldtype = "field"
		if minetest.check_player_privs(pname, {pencil_redo_long_names=true}) then
			fieldtype = "textarea"
		end
		minetest.show_formspec(pname, "pencil_redo_table", "size[5.5,2.5]"..fieldtype.."[0.5,0.5;5,1;name;Enter a new text for this "..what..";"..name.."]button_exit[1,1.5;3,1;ok;OK]")
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname=="pencil_redo_table" and fields.name and fields.ok then
		local pname=player:get_player_name()
		if (#fields.name>40 or string.match(fields.name, "\n", nil, true)) and not minetest.check_player_privs(pname, {pencil_redo_long_names=true}) then
			minetest.chat_send_player(pname, "Insufficient Privileges: Item names that are longer than 40 characters and/or contain newlines require the 'pencil_redo_long_names' privilege")
			return
		end
		
		local stack=player:get_wielded_item()
		if not(stack:get_name()=="pencil_redo:pencil") then
			minetest.chat_send_player(pname, "Please wield the pencil you want to change the text, and then click the edit table again.")
			return
		end
		local idef=minetest.registered_items[stack:get_name()]
		if not idef then
			minetest.chat_send_player(pname, "You can't name an unknown item!")
			return
		end
		
		local meta=stack:get_meta()
		if not meta then
			minetest.chat_send_player(pname, "For some reason, the stack metadata couldn't be acquired. Try again!")
			return
		end
		
		if fields.name=="" then
			meta:set_string("ptext", "")
			meta:set_string("description", "Pencil")
		else
			meta:set_string("ptext", fields.name)
			meta:set_string("description", "Pencil With Text")
		end
		--write back
		player:set_wielded_item(stack)
	end
end)


