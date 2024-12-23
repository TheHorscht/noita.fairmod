dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/noita.fairmod/files/content/fishing/files/eva_utils.lua")
local entity_id = GetUpdatedEntityID()

local lerp_amount = 0.975
local bob_h = 6
local bob_w = EntityGetVariable(entity_id, "fish_width", "int")
local bob_speed_y = 0.0065
local bob_speed_x = 0.01421

local pos_x, pos_y = EntityGetTransform(entity_id)

if pos_x == 0 and pos_y == 0 then
	-- get position from wand when starting
	pos_x, pos_y = EntityGetTransform(EntityGetParent(entity_id))
end

-- ghost continously lerps towards a target that floats around the parent
local target_x, target_y = EntityGetTransform(EntityGetParent(entity_id))
if target_x == nil then return end
target_y = target_y - 10

local time = GameGetFrameNum()
local r = ProceduralRandomf(entity_id, 0, -1, 1)

-- randomize times and speeds slightly so that multiple ghosts don't fly identically
time = time + r * 10000
bob_speed_y = bob_speed_y + (r * bob_speed_y * 0.1)
bob_speed_x = bob_speed_x + (r * bob_speed_x * 0.1)
lerp_amount = lerp_amount - (r * lerp_amount * 0.01)

-- bob
target_y = target_y + math.sin(time * bob_speed_y) * bob_h
target_x = target_x + math.sin(time * bob_speed_x) * bob_w

local dist_x = pos_x - target_x

-- move towards target
pos_x, pos_y = vec_lerp(pos_x, pos_y, target_x, target_y, lerp_amount)
EntitySetTransform(entity_id, pos_x, pos_y, 0, 1, 1)

-- animation state
edit_component(entity_id, "SpriteComponent", function(comp, vars)
	-- check if changing the animation is needed based on current animation and heading
	if dist_x < 2 then
		--ComponentSetValue( comp, "rect_animation", mode.."right")

		x, y, r = EntityGetTransform(entity_id)

		EntitySetTransform(entity_id, x, y, r, -1, 1)
	elseif dist_x > 2 then
		--ComponentSetValue( comp, "rect_animation", mode.."left")
		x, y, r = EntityGetTransform(entity_id)
		EntitySetTransform(entity_id, x, y, r, 1, 1)
	end
end)
