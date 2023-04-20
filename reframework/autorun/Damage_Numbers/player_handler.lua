local this = {};

local utils;
local singletons;
local config;
local customization_menu;
local time;

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

this.player = {};
this.player.position = Vector3f.new(0, 0, 0);
this.player.is_aiming = false;
this.player.is_using_scope = false;
this.player.aim_target_body = nil;

local character_manager_type_def = sdk.find_type_definition("chainsaw.CharacterManager");
local get_player_context_method = character_manager_type_def:get_method("getPlayerContextRef");

local player_base_context_type_def = sdk.find_type_definition("chainsaw.PlayerBaseContext");
local get_is_holding_method = player_base_context_type_def:get_method("get_IsHolding");
local get_camera_controller_method = player_base_context_type_def:get_method("get_CameraController");

local main_camera_controller_type_def = get_camera_controller_method:get_return_type();
local get_is_scope_camera_method = main_camera_controller_type_def:get_method("get_IsScopeCamera");


function this.update_is_aiming(player_context)
	local cached_config = config.current_config.settings;

	if player_context == nil then
		customization_menu.status = "[player.update_is_aiming] No Player Context";
		return;
	end

	local is_aiming = get_is_holding_method:call(player_context);
	if is_aiming == nil then
		customization_menu.status = "[player.update_is_aiming] No Player IsAiming";
		return;
	end

	this.player.is_aiming = is_aiming;
end

function this.update_is_using_scope(player_context)
	if player_context == nil then
		customization_menu.status = "[player.update_is_using_scope] No Player Context";
		return;
	end

	local camera_controller = get_camera_controller_method:call(player_context);
	if camera_controller == nil then
		customization_menu.status = "[player.update_is_using_scope] No Player Camera Controller";
		return;
	end

	local is_scope_camera = get_is_scope_camera_method:call(camera_controller);
	if is_scope_camera == nil then
		customization_menu.status = "[player.update_is_using_scope] No Player IsScopeCamera";
		return;
	end

	this.player.is_using_scope = is_scope_camera;
end

function this.update()
    if singletons.character_manager == nil then
		customization_menu.status = "[player.update] No Character Manager";
        return;
    end

	local player_context = get_player_context_method:call(singletons.character_manager);
	if player_context == nil then
		customization_menu.status = "[player.update] No Player Context";
		return;
	end

	this.update_is_aiming(player_context);
	this.update_is_using_scope(player_context);
end

function this.init_module()
	utils = require("Damage_Numbers.utils");
	config = require("Damage_Numbers.config");
	singletons = require("Damage_Numbers.singletons");
	customization_menu = require("Damage_Numbers.customization_menu");
	time = require("Damage_Numbers.time");
end

return this;