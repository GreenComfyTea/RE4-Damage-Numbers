local this = {};

local config;
local utils;
local time;
local keyframe_handler;
local drawing;

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

local manager_type_def = sdk.find_type_definition("chainsaw.Cp1021HudScoreDispGuiBehavior.ScoreData");
local method = manager_type_def:get_method("start");

local enemy_manager = sdk.find_type_definition("chainsaw.EnemyManager");
local notify_hit_damage_method = enemy_manager:get_method("notifyHitDamage");
local notify_dead_method = enemy_manager:get_method("notifyDead");

function this.new(damage, hit_position)
	local cached_config = config.current_config;

	local damage_number = {};

	damage_number.display_duration = cached_config.settings.display_duration;

	if damage_number.display_duration < 0.01 then
		return;
	end

	damage_number.init_time = time.total_elapsed_script_seconds;
	damage_number.progress = 0;

	damage_number.text = tostring(damage) or "0";

	damage_number.hit_position = hit_position or Vector3f.new(0, 0, 0);
	damage_number.current_position = hit_position;

	damage_number.floating_distance = utils.math.random(cached_config.settings.floating_distance.min, cached_config.settings.floating_distance.max);
	damage_number.floating_direction = Vector2f.new(0, -500);--utils.vec2.random(damage_number.floating_distance);

	damage_number.floating_progress = 0;
	damage_number.opacity_scale = 0;

	damage_number.label = utils.table.deep_copy(cached_config.damage_number_label);
	damage_number.keyframes = utils.table.deep_copy(cached_config.keyframes);

	table.insert(this.list, damage_number);
end

function this.update_progress(damage_number)
	local elapsed_time = time.total_elapsed_script_seconds - damage_number.init_time;

	if damage_number.display_duration > 0.001 then
		damage_number.progress = elapsed_time / damage_number.display_duration;
	else
		damage_number.progress = 0;
	end
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
	--xy = utils.table.tostring(this.list);

	for index, damage_number in pairs(this.list) do
		this.update_progress(damage_number);

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

		xy = utils.vec2.tostring(hit_position_on_screen);

		--xy = utils.table.tostring(damage_number.keyframes.floating_movement) .. "\n";
		--xy = xy .. utils.table.tostring(target_position) .. "\n";
		--xy = xy .. utils.table.tostring(current_position) .. "\n";
		--xy = xy .. tostring(damage_number.floating_progress) .. "\n";

		drawing.draw_label(damage_number.label, damage_number.current_position, damage_number.opacity_scale, damage_number.text);
		
		::continue::
	end
end

function this.on_hit(damage_info, enemy_context)
	local damage = damage_info:get_Damage();

	if damage == nil or damage == 0 then
		return;
	end

	local position = damage_info:get_Position();

	if position == nil then
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