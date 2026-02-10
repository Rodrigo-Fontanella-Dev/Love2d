local scene = {}

local window_size_w, window_size_h = 960,720 --fixed game resolution

function scene.modify(flags)
end

--love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setDefaultFilter("nearest", "nearest")

-- Library to create classes
Object = require "data/libraries/classic"
Camera = require "data/libraries/camera"
--Sti = require "data/libraries/sti"

require "enemy"
require "player"
require "tree"
require "shot"
require "power_up"
require "void_energy"

local game_maps = require "maps"
local map = {}

--Map Vars
local map_w = 30 -- Size of the map
local map_h = 30 -- Size of the map
local tile_w = 100 -- Tile Size
local tile_h = 100 -- Tile Size
local map_x = 0 -- Start Position
local map_y = 0 -- Start Position
local map_offset_x = -(1500 - (window_size_w / 2) + 100) -- Shift Map Position -- Player in the center of map
local map_offset_y = -(1500 - (window_size_h / 2) + 100) -- Shift Map Position -- Player in the center of map
local map_display_w = 30 -- Number of tiles that will be displayed
local map_display_h = 30 -- Number of tiles that will be displayed
local map_limits = {left = -500, right = 1460, top = -640, bottom = 1340}

local weapons = require "weapons"

local shaders = require "shaders"

local objects = {}
local mouse = {}
local angle_shot = 0
local shot_direction = {}
local shot = {}

local shot_group = {}
local enemy_group = {}
local tree_group = {}
local power_up_group = {}
local void_energy_group = {}
local game_paused = false

local collision_enemy = false
local basic_shot = love.audio.newSource("data/sfx/effects/shot.wav", "static")
local enemy_hurt = love.audio.newSource("data/sfx/effects/hurt.wav", "static")
local powerup = love.audio.newSource("data/sfx/effects/powerup.wav", "static")
local powerup_type = {"player_life", "player_speed", "weapon_type", "bullet_speed", "bullet_power"}

local game_paused_img = love.graphics.newImage("data/images/ui/game_paused.png")

local shakeDuration = 0 -- How long the shake lasts
local shakeMagnitude = 0 -- How intense the shake is (pixels)
local shakeTimer = 0 -- Internal timer for the shake

local game_clock = 0
-- Energy and Rage Bars from Player
local bar_size_w = 650

local actual_weapon = weapons.pistol

local dust_particle = love.graphics.newImage("data/images/particles/dust/dust.png")
local psystem = love.graphics.newParticleSystem(dust_particle, 5)

local rain_particle = love.graphics.newImage("data/images/particles/rain/rain.png")
local rain_psystem = love.graphics.newParticleSystem(rain_particle, 400)

local mx, my = 0, 0

local spawn_enemies_ini_time = 20
local spawn_enemies_time = 20
local spawn_enemies_speed = 10
local spawn_enemies_rate = 1

local collision = false

function scene.load()
	-- Joysticks = love.joystick.getJoysticks()
    -- Joystick = Joysticks[1] -- Get the first joystick
	-- print(Joystick:getButtonCount( )) --11
	-- print(Joystick:getAxisCount()) -- 6

	Tile = {}
	for i = 1, 2 do
		Tile[i] = love.graphics.newImage("data/maps/map01_tile"..i..".png")
	end
	--print(Tile[1], Tile[2])
	--print(game_maps, game_maps[1], game_maps[2])
	for t, tiles in ipairs(game_maps[1]) do
		--print(tiles)
		table.insert(map, tiles)
	end

	shakeDuration = 0

	Font = love.graphics.newFont("data/fonts/quadrangle.otf", 15)
	Font_medium = love.graphics.newFont("data/fonts/quadrangle.otf", 12)
	Font_small = love.graphics.newFont("data/fonts/quadrangle.otf", 10)

	Paused_on_sound = love.audio.newSource("data/sfx/effects/pause_on.wav", "static")
	Paused_off_sound = love.audio.newSource("data/sfx/effects/pause_off.wav", "static")

	-- Make a player instance	
	Player = Player()
	-- Center Player in Screen
	Player.x = window_size_w / 2
	Player.y = window_size_h / 2
	table.insert(objects, Player)
	Player.weapon = actual_weapon

	--Create a camera
	GameCamera = Camera(Player.x, Player.y)
	-- Set smoother for dampening (lower number = smoother/slower, higher = faster)
	GameCamera.smoother = Camera.smooth.damped(15)

	--Start Creation of Enemies
	for e = 1, 5 do
		local enemy = Enemy(Player.x, Player.y)
		table.insert(objects, enemy)
		table.insert(enemy_group, enemy)
	end

	--Creation of Trees
	for t = 1, 40 do
		Tree_noob = Tree()
		table.insert(objects, Tree_noob)
		table.insert(tree_group, Tree_noob)
		--print(Tree_noob.collision_area.x, Tree_noob.collision_area.y)
	end

	--Creation of PowerUps
	for p = 1, 5 do
		local power_up = PowerUp()
		power_up.type = powerup_type[love.math.random(1, #powerup_type)]
		--print(power_up.type)
		table.insert(objects, power_up)
		table.insert(power_up_group, power_up)
	end
	--Create Map
	--Map = Map()

	--Particle System
	psystem:setParticleLifetime(0.1, 0.8)
	--psystem:setLinearAcceleration(0, 0, 0, 0)
	psystem:setColors(255, 255, 255, 30, 255, 255, 255, 0) -- Fade out.
	psystem:setRotation(0, 6.28)
	--psystem:setRadialAcceleration(3, 3)
	psystem:setSpread(1)
	--psystem:setOffset(-1, 3)
	--psystem:setLinearDamping(0, 5)
	--psystem:setEmissionArea("uniform", 200, 200, 0, true)
	--psystem:setDirection(0.5)
	psystem:setEmissionRate(0)
	--psystem:setSizeVariation(1)
	psystem:setLinearAcceleration(-20, -20, 20, 20)
	psystem:setSizes(0.2, 0.4, 0.6)
	psystem:setSpinVariation(0.5)

--Rain Particle System
	rain_psystem:setParticleLifetime(2, 5)
	--psystem:setLinearAcceleration(0, 0, 0, 0)
	rain_psystem:setColors(255, 255, 255, 50, 255, 255, 255, 0) -- Fade out.
	rain_psystem:setRotation(0.3, 0.3)
	--psystem:setRadialAcceleration(3, 3)
	--rain_psystem:setSpread(1)
	--psystem:setOffset(-1, 3)
	--psystem:setLinearDamping(0, 5)
	rain_psystem:setEmissionArea("uniform", 960, 200, 0, true)
	rain_psystem:setDirection(2)
	--rain_psystem:setEmissionRate(200)
	--psystem:setSizeVariation(1)
	--rain_psystem:setLinearAcceleration(-20, -20, 20, 20)
	rain_psystem:setSizes(0.3, 0.5, 0.8)
	--rain_psystem:setSpinVariation(0.2)
end

function scene.update(dt)
	--local dx,dy = Player.x - GameCamera.x, Player.y - GameCamera.y
    --GameCamera:move(dx/2, dy/2)
	GameCamera:lockPosition(Player.x, Player.y)
	--Map:update(dt)

	if not game_paused then
		-- Enemies Creation at Time
		-- if spawn_enemies_time <= 0 then
		-- --Start Creation of Enemies
		-- 	for e = 1, spawn_enemies_rate do
		-- 		local enemy = Enemy(Player.x, Player.y)
		-- 		table.insert(objects, enemy)
		-- 		table.insert(enemy_group, enemy)
		-- 	end
		-- 	spawn_enemies_time = spawn_enemies_ini_time
		-- else
		-- 	spawn_enemies_time = spawn_enemies_time - spawn_enemies_speed * dt
		-- end

		-- Increase Enemy Number/Dificulty
		if Player.kills == 50 then
			spawn_enemies_rate = 2
		end
		if Player.kills == 100 then
			spawn_enemies_rate = 3
		end

		-- Decrease shake timer if active
		if shakeTimer > 0 then
			shakeTimer = shakeTimer - dt
		end

		--Start Game Timer
		game_clock = game_clock + dt

		local dist_x = mx - (window_size_w / 2)
		local dist_y = my - (window_size_h / 2)
		--print(dist_x, dist_y)

		angle_shot = math.atan2(dist_y, dist_x)
		--print(angle_shot)
		Player.weapon_angle = angle_shot
		--print(math.deg(angle_shot))

		if mx > window_size_w / 2 then
			shot_direction[0] = 1
		else
			shot_direction[0] = -1
		end

		if my > window_size_h / 2 then
			shot_direction[1] = 1
		else
			shot_direction[1] = -1
		end

		-- OBJECTS MOTION ----------------------------------
		-- Update all objects
		for i, object in ipairs(objects) do
			object:update(dt)
		end

		-- Objects change in depth
		table.sort(objects, function(a, b)
			--print(a.y, b.y)
			return a.y < b.y
		end)

		-- Shift enemies when player moves and detect player position
		for i, enemy in ipairs(enemy_group) do
			enemy.player_position[0] = Player.x
			enemy.player_position[1] = Player.y
		end

		-- SHOT DETECTION --------------------------------------
		-- Shot out of range
		for i, _shot in ipairs(shot_group) do
			if _shot.shot_distance > Player.weapon.range then
				_shot.active = false
				table.remove(shot_group, i)
			end
		end

		-- If Shot is not active, remove from group Objects
		for s, _shot in ipairs(objects) do
			if _shot.active == false then
				table.remove(objects, s)
			end
		end

		--Shot Hit Enemy
		for _, enemy in ipairs(enemy_group) do
			for s, player_shot in ipairs(shot_group) do
				--print(shot)
				if Detect_collision(enemy.body_collision_area, player_shot.shot_collision_area) then
					-- If Enemy is dead, the shot doesn't affect it
					if not enemy.dead then
						enemy_hurt:stop()
						--print("acertou inimigo")
						player_shot.active = false
						table.remove(shot_group, s)
						enemy.hurt = true
						enemy_hurt:play()
					end
				end
			end
		end

		--If Enemy Dies remove it from enemy_group and add a void energy
		for i, enemy in ipairs(enemy_group) do
			if enemy.active == false then
				-- Create Void Energy PowerUp at Enemy Position
				local void_energy = Void()
				void_energy.x = enemy.x
				void_energy.y = enemy.y
				table.insert(objects, void_energy)
				table.insert(void_energy_group, void_energy)

				table.remove(enemy_group, i)
				Player.kills = Player.kills + 1
			end
		end

		--Remove enemy from objects if not active
		for e, enemy in ipairs(objects) do
			if enemy.active == false then
				table.remove(objects, e)
				-- Add 1 Kill to Player Kills Counter			
			end
		end

		--Shot Hit Tree
		for t, tree in ipairs(tree_group) do
			for s, player_shot in ipairs(shot_group) do
				if Detect_collision(tree.body_collision_area, player_shot.shot_collision_area) then
					--print("acertou arvore")
					player_shot.active = false
					table.remove(shot_group, s)
				end
			end
		end
		--print(Player.hurt)
		-- Enemy Collision with player (Only Ground collision Rectangle)
		for e, enemy in ipairs(enemy_group) do
			if enemy.dead == false then
				collision_enemy = Detect_collision(Player.collision_area, enemy.collision_area)
				if collision_enemy then
					Player.hurt = true
					Player.life = Player.life - 0.01
					if Player.life < 0 then
						Player.life = 0
						Player.dead = true
					end
				end
			end
		end
		--Enemy collision with Rage Area Attack
		for e, enemy in ipairs(enemy_group) do
			if enemy.dead == false then
				if Detect_collision(enemy.body_collision_area, Player.rage_area) then
					if not enemy.dead then
						if Player.rage_attack then
							enemy_hurt:stop()
							--print("acertou inimigo")
							enemy.energy = enemy.energy - Player.rage_power
							enemy.hurt = true
							enemy_hurt:play()
						end
					end
				end
			end
		end

		--Powerup Collision with player
		for p, power_up in ipairs(power_up_group) do
			if Detect_collision(Player.collision_area, power_up.collision_area) then
				powerup:stop()
				print("PowerUp Collected:", power_up.type)
				powerup:play()
				power_up.active = false

				if power_up.type == "player_life" then
					Player.life = Player.life + 10
					if Player.life > Player.life_total then
						Player.life = Player.life_total
					end
				end

				--Remove PowerUp from groups
				table.remove(power_up_group, p)
				for pu, obj in ipairs(objects) do
					if obj == power_up then
						if power_up.active == false then
							print("Removing PowerUp from objects")
							table.remove(objects, pu)
						end
					end
				end
			end
		end

		--Void Energy Collision with player
		for r, void_energy in ipairs(void_energy_group) do
			if Detect_collision(Player.collision_area, void_energy.collision_area) then
				powerup:stop()
				print("Void Energy Collected:")
				powerup:play()
				Player.void_energy = Player.void_energy + 1

				void_energy.active = false
				--Remove Void Energy from groups
				table.remove(void_energy_group, r)
				for re, obj in ipairs(objects) do
					if obj == void_energy then
						if void_energy.active == false then
							print("Removing Void Energy from objects")
							table.remove(objects, re)
						end
					end
				end
			end
		end

		-- -- Tree Collision with player (Only Ground collision Rectangle)
		for t, tree in ipairs(tree_group) do
			-- Player collision movement
			Player.move_player_left, Player.move_player_right, Player.move_player_up, Player.move_player_down = Collision_with_trees(Player.collision_area, tree.collision_area, tree.collision_sensor, Player.move_player_left, Player.move_player_right, Player.move_player_up, Player.move_player_down)
			-- Enemy collision movement
			for e, enemy in ipairs(enemy_group) do
				enemy.move_enemy_left, enemy.move_enemy_right, enemy.move_enemy_up, enemy.move_enemy_down = Collision_with_trees(enemy.collision_area, tree.collision_area, tree.collision_sensor, enemy.move_enemy_left, enemy.move_enemy_right, enemy.move_enemy_up, enemy.move_enemy_down)
			end
		end

		-- Send player position to the shaders file
		shaders.light:send("playerPosition", {window_size_w / 2, window_size_h / 2})

		--Emit dust particles at player position
		psystem:update(dt)
		if Player.movement_x ~= 0 or Player.movement_y ~= 0 then
			psystem:start()
		else
			psystem:stop()
		end
		psystem:setRotation(0, 6.28)
		psystem:setSpeed(1, 120)
		psystem:setPosition(Player.x, Player.y + 15)
		psystem:emit(1)

		rain_psystem:start()
		rain_psystem:update(dt)
		rain_psystem:setSpeed(300, 600)
		rain_psystem:setPosition(Player.x - window_size_w / 2, Player.y - 720)
		rain_psystem:emit(1)
	end
end

function scene.draw()
 	love.graphics.push() -- Save current drawing state for Shake Effect	
	if not game_paused then
		mx, my = love.mouse.getPosition()
	end

	GameCamera:attach()

	-- Apply screen shake if timer is active
    if shakeTimer > 0 then
        local dx = love.math.random(-shakeMagnitude, shakeMagnitude)
        local dy = love.math.random(-shakeMagnitude, shakeMagnitude)
        love.graphics.translate(dx, dy)
    end

	--Shader Grayscale START if PAUSED
	if game_paused then
		love.graphics.setShader(shaders.greyscale)
	end
	-- Bright Shader
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("fill", 0, 0, window_size_w, window_size_h)

	Draw_map()

	-- Loop to Draw all Objects	
	for i, object in ipairs(objects) do
		if object == Player then
			love.graphics.draw(object.image, object.x, object.y, 0, 1, 1, object.size_w / 2, object.size_h - object.size_h / 4)
		else
			love.graphics.draw(object.image, object.x, object.y, 0, 1, 1, object.size_w / 2, object.size_h - object.size_h / 4)
		end
	end
	-- Weapon direction
	if mx > window_size_w / 2 then
		love.graphics.draw(Player.weapon.image, Player.x, Player.y, Player.weapon_angle, 1, 1, Player.weapon.image:getWidth()/2, Player.weapon.image:getHeight()/2)
	else
		love.graphics.draw(Player.weapon.image, Player.x, Player.y, Player.weapon_angle, 1, -1, Player.weapon.image:getWidth()/2, Player.weapon.image:getHeight()/2)
	end
	-- Player direction
	if mx > window_size_w / 2 then
		Player.image = Player.player_img_right
	else
		Player.image = Player.player_img_left
	end

	love.graphics.draw(psystem)
	love.graphics.draw(rain_psystem)

	-- Draw Collision Lines and Guides ---------------------------------
	Collision_rectangles(true) -- true or false

	GameCamera:detach()

	if Player.draw_collision then
		--Circle Weapon Range of player
		love.graphics.setColor(1, 1, 1, 0.2)
		love.graphics.circle("line", window_size_w / 2, window_size_h / 2, Player.weapon.range, 30)
		love.graphics.setColor(1, 1, 1, 1)

		--Circle start shot
		love.graphics.setColor(0, 0, 1, 0.2)
		love.graphics.circle("line", window_size_w / 2, window_size_h / 2, 20, 30)
		love.graphics.setColor(1, 1, 1, 1)

		--Line test of sight of player
		love.graphics.setColor(1, 1, 1, 0.2)
		love.graphics.line(window_size_w / 2, window_size_h / 2, mx, my)
		love.graphics.setColor(1, 1, 1, 1)
	end

	love.graphics.pop() -- Restore drawing state for Shake Effect

	-- Shader Light Start
	love.graphics.setShader(shaders.light)
	love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, window_size_w, window_size_h)
    love.graphics.setShader()
    -- Shader Light End

	-- UI Elements  --------------------------------------
	-- Draws Energy Bar
	-- Life Dark Background Bar
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 50, window_size_h - 705, bar_size_w, 5)
	love.graphics.setColor(1, 1, 1, 1)

	-- Life Red Foreground Bar
	love.graphics.setColor(1, 0, 0, 0.6)
	love.graphics.rectangle("fill", 50, window_size_h - 705, bar_size_w * (Player.life / Player.life_total), 5)
	love.graphics.setColor(1, 1, 1, 1)

	-- Rage Dark Background Bar
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 50, window_size_h - 692, bar_size_w, 5)
	love.graphics.setColor(1, 1, 1, 1)

	-- Rage Purple Foreground Bar
	love.graphics.setColor(0.6, 0, 1, 0.6)
	love.graphics.rectangle("fill", 50, window_size_h - 692, bar_size_w * (Player.rage / Player.rage_total), 5)
	love.graphics.setColor(1, 1, 1, 1)

	-- Draws Game Time, Kills and Void Particles Counter
	love.graphics.setFont(Font_small)
	love.graphics.print("Time:", 905, window_size_h + (10 - window_size_h))
	love.graphics.print(FormatTime(game_clock), 902, window_size_h + (23 - window_size_h))

	love.graphics.setFont(Font_small)
	love.graphics.print("Kills: "..Player.kills, 705, window_size_h + (10 - window_size_h))
	love.graphics.print("Void Energy: "..Player.void_energy, 705, window_size_h + (23 - window_size_h))

	-- Draws the Life ans Rage Bar Titles
	love.graphics.print("Life:", 10, window_size_h + (10 - window_size_h))
	love.graphics.print("Rage:", 10, window_size_h + (23 - window_size_h))

	-- Draws the actual image and weapon name
	love.graphics.setFont(Font_small)
	love.graphics.print(Player.weapon.name, 10, window_size_h - 50)
	love.graphics.draw(Player.weapon.image, 40, window_size_h - 90)

	--Shader Gray END
	if game_paused then
		love.graphics.setShader()
		love.graphics.draw(game_paused_img, window_size_w / 2 - game_paused_img:getWidth() / 2, window_size_h / 2 + 20)
	end

	-- FPS Counter
	Fps_counter()
end

function Fps_counter()
	Fps = love.timer.getFPS()
		--print(fps)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(Font_small)
		love.graphics.print("FPS: " .. tostring(Fps), window_size_w - 90, window_size_h - 40)
		love.graphics.setColor(0, 0, 0, 0)
end

function Collision_rectangles(show)
	local rects_alpha
	if show then
		rects_alpha = 1
	else
		rects_alpha = 0
	end

	--Draw Collision Rectangles
	Player.draw_collision_alpha = rects_alpha
	Player:draw()

	for i, enemy in ipairs(enemy_group) do
		enemy.draw_collision_alpha = rects_alpha
		enemy:draw()
	end
	for t, tree in ipairs(tree_group) do
		tree.draw_collision_alpha = rects_alpha
		tree:draw()
	end
	for s, player_shot in ipairs(shot_group) do
		player_shot.draw_collision_alpha = rects_alpha
		player_shot:draw()
	end
	for p, power_up in ipairs(power_up_group) do
		power_up.draw_collision_alpha = rects_alpha
		power_up:draw()
	end
	for r, void_energy in ipairs(void_energy_group) do
		void_energy.draw_collision_alpha = rects_alpha
		void_energy:draw()
	end

end

function Detect_collision(a, b)
	local a_left = a.x
    local a_right = a.x + a.width
    local a_top = a.y
    local a_bottom = a.y + a.height

    local b_left = b.x
    local b_right = b.x + b.width
    local b_top = b.y
    local b_bottom = b.y + b.height

	--Directly return this boolean value without using if-statement
    return  a_right > b_left
        and a_left < b_right
        and a_bottom > b_top
        and a_top < b_bottom
end

function love.keypressed(key)
    -- Toggle the pause state when 'p' is pressed
    if key == "p" then
    	if game_paused then
    		Paused_off_sound:play()
    	end
    	if not game_paused then
    		Paused_on_sound:play()
    	end
        game_paused = not game_paused
    end
	-- if key == "l" then
	-- 	StartShake(0.5, 10) -- Shake for 0.5 seconds with intensity 10
    -- end
	if love.keyboard.isDown("escape") then
		love.window.close()
		love.event.quit()
	end
end

function love.mousepressed(x, y, button, istouch)
	--print(x, y, button)
	if button == 1 then
		basic_shot:stop()

   		-- Make a Shot instance	
		shot = Shot()

		--Calculate de Start Point of the shot
		local start_pointX = Player.x + 20 * math.cos(angle_shot)
		local start_pointY = Player.y + 20 * math.sin(angle_shot)
		--print(start_pointX, start_pointY)
		--shot.x_ini = start_pointX
		--shot.y_ini = start_pointY
		shot.x_ini = Player.x
		shot.y_ini = Player.y
		shot.x = start_pointX
		shot.y = start_pointY
		shot.speed = Player.weapon.speed
		table.insert(objects, shot)
		table.insert(shot_group, shot)
		shot:start(angle_shot, shot_direction)
		basic_shot:play()
   	end

   	if button == 2 then
		if Player.rage >= Player.rage_charge and Player.rage_attack == false then --Only works if there's charge to use
			Player.rage = Player.rage - Player.rage_charge
			Player.rage_attack = true
			StartShake(0.5, 5) -- Shake for 0.5 seconds with intensity 5
		end
   		--print(Player.rage)
   	end
end

function FormatTime(t)
    local minutes = math.floor(t / 60)
    local seconds = math.floor(math.fmod(t, 60)) -- Modulo to get remaining seconds

    -- Use string.format to ensure leading zeros for seconds if needed
    return string.format("%02d:%02d", minutes, seconds)
end

function StartShake(duration, magnitude)
    shakeDuration = duration or 1.0 -- Default to 1 second
    shakeMagnitude = magnitude or 8 -- Default to 8 pixels
    shakeTimer = shakeDuration
end

function Rubber_band(dx,dy)
    local dt = love.timer.getDelta()
    return dx*dt, dy*dt
end

function Draw_map()
   for y=1, map_display_h do
      for x=1, map_display_w do
         love.graphics.draw(
            Tile[map[y+map_y][x+map_x]],
            (x*tile_w)+map_offset_x,
            (y*tile_h)+map_offset_y)
      end
   end
end

function Collision_with_trees(actor_collision_area, tree_collision_area, tree_collision_sensor, actor_move_left, actor_move_right, actor_move_up, actor_move_down)
	local location
	local tolerance = 2
	local sensor_detection =  Detect_collision(actor_collision_area, tree_collision_sensor)
	local detect_collision =  Detect_collision(actor_collision_area, tree_collision_area)
	if sensor_detection and not detect_collision then
		--print("not collision")
		actor_move_left = 1
		actor_move_right = 1
		actor_move_up = 1
		actor_move_down = 1
	elseif sensor_detection and detect_collision then
		if actor_collision_area.y < tree_collision_area.y + tree_collision_area.height - tolerance and actor_collision_area.y + actor_collision_area.height > tree_collision_area.y + tolerance then
			location = "horizontal"
		elseif actor_collision_area.x < tree_collision_area.x + tree_collision_area.width - tolerance and actor_collision_area.x + actor_collision_area.width > tree_collision_area.x + tolerance then
			location = "vertical"
		else
			location = ""
		end
		if location == "horizontal" then
			-- Colliding right
			if actor_collision_area.x > tree_collision_area.x then
				if actor_collision_area.x <= tree_collision_area.x + tree_collision_area.width then
					actor_move_left = 0
					actor_move_right = 1
					actor_move_up = 1
					actor_move_down = 1
				end
			else
				-- Colliding left
				if actor_collision_area.x + actor_collision_area.width >= tree_collision_area.x then
					actor_move_right = 0
					actor_move_left = 1
					actor_move_up = 1
					actor_move_down = 1
				end
			end
		elseif location == "vertical" then
			if actor_collision_area.y > tree_collision_area.y then
				-- Colliding bottom
				if actor_collision_area.y <= tree_collision_area.y + tree_collision_area.height then
					actor_move_left = 1
					actor_move_right = 1
					actor_move_up = 0
					actor_move_down = 1
				end
			else
			-- Colliding top
				if actor_collision_area.y + actor_collision_area.height >= tree_collision_area.y then
					actor_move_right = 1
					actor_move_left = 1
					actor_move_up = 1
					actor_move_down = 0
				end
			end
		end
	end
	return actor_move_left, actor_move_right, actor_move_up, actor_move_down
end




return scene