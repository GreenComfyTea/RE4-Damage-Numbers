local this = {};

local config;
local utils;
local time;
local keyframe_handler;
local drawing;
local customization_menu;
local player_handler;
local gui_handler;

local sdk = sdk;
local tostring = tostring;
local pairs = pairs;
local ipairs = ipairs;
local tonumber = tonumber;
local require = require;
local pcall = pcall;
local table = table;
local string = string;
local Vector3f = Vector3f;
local d2d = d2d;
local math = math;
local json = json;
local log = log;
local fs = fs;
local next = next;
local type = type;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local assert = assert;
local select = select;
local coroutine = coroutine;
local utf8 = utf8;
local re = re;
local imgui = imgui;
local draw = draw;
local Vector2f = Vector2f;
local reframework = reframework;
local os = os;

this.list = {};

local enemy_manager = sdk.find_type_definition("chainsaw.EnemyManager");
local notify_hit_damage_method = enemy_manager:get_method("notifyHitDamage");
local notify_dead_method = enemy_manager:get_method("notifyDead");

local damage_info_type_def = sdk.find_type_definition("chainsaw.HitController.DamageInfo");
local get_damage_method = damage_info_type_def:get_method("get_Damage");
local get_position_method = damage_info_type_def:get_method("get_Position");

function this.new(damage, hit_position)
	local cached_config = config.current_config;

	local damage_number = {};

	damage_number.display_delay = cached_config.settings.display_delay;
	damage_number.display_duration = cached_config.settings.display_duration;

	if damage_number.display_duration < 0.000001 then
		return;
	end

	damage_number.init_time = time.total_elapsed_script_seconds;
	damage_number.progress = 0;

	damage_number.text = tostring(damage) or "0";

	damage_number.hit_position = hit_position or Vector3f.new(0, 0, 0);
	damage_number.current_position = hit_position;

	damage_number.floating_distance = utils.math.random(cached_config.settings.floating_distance.min, cached_config.settings.floating_distance.max);
	damage_number.floating_direction = utils.vec2.random(damage_number.floating_distance);

	damage_number.floating_progress = 0;
	damage_number.opacity_scale = 0;

	damage_number.label = utils.table.deep_copy(cached_config.damage_number_label);
	damage_number.keyframes = utils.table.deep_copy(cached_config.keyframes);

	table.insert(this.list, damage_number);
end

function this.update_progress(damage_number)
	local elapsed_time = time.total_elapsed_script_seconds - damage_number.init_time;

	if elapsed_time < damage_number.display_delay then
		damage_number.progress = 0;
		return;
	end

	damage_number.progress = (elapsed_time - damage_number.display_delay) / damage_number.display_duration;
end

function this.update_values_from_keyframes(damage_number)
	local label = damage_number.label;
	local label_shadow = label.shadow;

	local progress = damage_number.progress;
	local keyframes = damage_number.keyframes;

	local damage_number_label_keyframes = keyframes.damage_number_label;
	local damage_number_label_shadow_keyframes = damage_number_label_keyframes.shadow;

	local label = damage_number.label;
	local label_shadow = label.shadow;

	local progress = damage_number.progress;
	local keyframes = damage_number.keyframes;

	local damage_number_label_keyframes = damage_number.keyframes.damage_number_label;
	local damage_number_label_shadow_keyframes = damage_number_label_keyframes.shadow;

	damage_number.opacity_scale = keyframe_handler.calculate_current_value(progress, keyframes.opacity_scale);
	damage_number.floating_progress = keyframe_handler.calculate_current_value(progress, keyframes.floating_movement);

	label.visibility = keyframe_handler.calculate_current_value(progress, damage_number_label_keyframes.visibility);

	label.offset.x = keyframe_handler.calculate_current_value(progress, damage_number_label_keyframes.offset.x);
	label.offset.y = keyframe_handler.calculate_current_value(progress, damage_number_label_keyframes.offset.y);

	label.color = keyframe_handler.calculate_current_value(progress, damage_number_label_keyframes.color);

	label_shadow.visibility = keyframe_handler.calculate_current_value(progress, damage_number_label_shadow_keyframes.visibility);

	label_shadow.offset.x = keyframe_handler.calculate_current_value(progress, damage_number_label_shadow_keyframes.offset.x);
	label_shadow.offset.y = keyframe_handler.calculate_current_value(progress, damage_number_label_shadow_keyframes.offset.y);

	label_shadow.color = keyframe_handler.calculate_current_value(progress, damage_number_label_shadow_keyframes.color);
end

function this.tick()
	local cached_config = config.current_config.settings;

	if gui_handler.game.current_active_input_level > 0 then
		return;
	end

	if not cached_config.render_during_cutscenes and gui_handler.game.is_cutscene_playing then
		return;
	end

	if not cached_config.render_when_hud_is_off and gui_handler.game.is_hud_off then
		return;
	end

	if not player_handler.player.is_aiming then
		if not cached_config.render_when_normal then
			return;
		end
	elseif not player_handler.player.is_using_scope then
		if not cached_config.render_when_aiming then
			return;
		end
	else
		if not cached_config.render_when_using_scope then
			return;
		end
	end

	for index, damage_number in pairs(this.list) do
		this.update_progress(damage_number);

		if damage_number.progress == 0 then
			goto continue;
		end

		if damage_number.progress > 1 then
			this.list[index] = nil;
			goto continue;
		end

		this.update_values_from_keyframes(damage_number);

		local hit_position_on_screen = draw.world_to_screen(damage_number.hit_position);
		if hit_position_on_screen == nil then
			goto continue;
		end

		damage_number.current_position = {
			x = hit_position_on_screen.x + damage_number.floating_direction.x * damage_number.floating_progress,
			y = hit_position_on_screen.y + damage_number.floating_direction.y * damage_number.floating_progress,
		}

		drawing.draw_label(damage_number.label, damage_number.current_position, damage_number.opacity_scale, damage_number.text);
		
		::continue::
	end
end

function this.on_hit(damage_info, enemy_context)
	if damage_info == nil then
		customization_menu.status = "[damage_handler.on_hit] No Damage Info";
		return;
	end

	local damage = get_damage_method:call(damage_info);

	if damage == nil then
		customization_menu.status = "[damage_handler.on_hit] No Damage";
		return;
	end

	if damage == 0 then
		return;
	end

	local position = get_position_method:call(damage_info);

	if position == nil then
		customization_menu.status = "[damage_handler.on_hit] No Position";
		return;
	end

	this.new(damage, position);
end

function this.init_module()
	config = require("Damage_Numbers.config");
	utils = require("Damage_Numbers.utils");
	time = require("Damage_Numbers.time");
	keyframe_handler = require("Damage_Numbers.keyframe_handler");
	drawing = require("Damage_Numbers.drawing");
	customization_menu = require("Damage_Numbers.customization_menu");
	player_handler = require("Damage_Numbers.player_handler");
	gui_handler = require("Damage_Numbers.gui_handler");

	sdk.hook(notify_hit_damage_method, function(args)

		local damage_info = sdk.to_managed_object(args[3]);
		local enemy_context = sdk.to_managed_object(args[4]);

		this.on_hit(damage_info, enemy_context);
	end, function(retval)
		return retval;
	end);

	sdk.hook(notify_dead_method, function(args)

		local damage_info = sdk.to_managed_object(args[3]);
		local enemy_context = sdk.to_managed_object(args[4]);

		this.on_hit(damage_info, enemy_context);
	end, function(retval)
		return retval;
	end);
end

return this;