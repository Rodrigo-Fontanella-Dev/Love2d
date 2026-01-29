local scene = {}

local window_size_w, window_size_h = 1280,720 --fixed game resolution

function scene.modify(flags)
end

--love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setDefaultFilter("nearest", "nearest")

-- Library to create classes
Object = require "data/libraries/classic"
Camera = require "data/libraries/camera"
require "enemy"
require "player"
require "tree"
require "shot"
require "power_up"
require "rage_energy"

local weapons = require "weapons"

local shaders = require("shaders")

local objects = {}
local mouse = {}
local angle_shot = 0
local shot_direction = {}
local shot = {}

local player_group = {}
local shot_group = {}
local enemy_group = {}
local tree_group = {}
local power_up_group = {}
local rage_energy_group = {}
local offset = {}
local game_paused = false

local collision_enemy = false
local basic_shot = love.audio.newSource("data/sfx/effects/shot.wav", "static")
local enemy_hurt = love.audio.newSource("data/sfx/effects/hurt.wav", "static")
local powerup = love.audio.newSource("data/sfx/effects/powerup.wav", "static")
local powerup_type = {"player_life", "player_speed", "weapon_type", "bullet_speed", "bullet_power"}

local shake_render_offset = {}
shake_render_offset[0] = 0
shake_render_offset[1] = 0

local game_paused_img = love.graphics.newImage("data/images/ui/game_paused.png")

local shake_timer = 1000
local shake_intensity = 10000
local anim_shake_active = false

local shakeDuration = 0 -- How long the shake lasts
local shakeMagnitude = 0 -- How intense the shake is (pixels)
local shakeTimer = 0 -- Internal timer for the shake

local scale_factor_w = 1
local scale_factor_h = 1

local game_clock = 0
-- Energy ans Rage Bars from Player
local bar_size_w = 650

local actual_weapon = weapons.pistol

local dust_particle = love.graphics.newImage("data/images/particles/dust/dust.png")
local psystem = love.graphics.newParticleSystem(dust_particle, 5)

local mx, my = 0, 0

function scene.load()
	Joysticks = love.joystick.getJoysticks()
    Joystick = Joysticks[1] -- Get the first joystick
	-- print(Joystick:getButtonCount( )) --11
	-- print(Joystick:getAxisCount()) -- 6

	shakeDuration = 0

	Font = love.graphics.newFont("data/fonts/quadrangle.otf", 15)
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
		local enemy = Enemy()
		table.insert(objects, enemy)
		table.insert(enemy_group, enemy)
	end

	--Creation of Trees
	for t = 1, 1 do
		local tree = Tree()
		table.insert(objects, tree)
		table.insert(tree_group, tree)
	end

	--Creation of PowerUps
	for p = 1, 5 do
		local power_up = PowerUp()
		power_up.type = powerup_type[love.math.random(1, #powerup_type)]
		--print(power_up.type)
		table.insert(objects, power_up)
		table.insert(power_up_group, power_up)
	end

	Map = love.graphics.newImage("data/maps/map01.png")

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
end

function scene.update(dt)
	--local dx,dy = Player.x - GameCamera.x, Player.y - GameCamera.y
    --GameCamera:move(dx/2, dy/2)
	GameCamera:lockPosition(Player.x, Player.y)

	--GameCamera:rotate(dt)

	-- if Joystick and Joystick:isGamepadDown("a") then
	-- 	print("A button pressed")
	-- end
	-- if Joystick and Joystick:isGamepadDown("dpleft") then
	-- 	print("Game Pad Left pressed")
	-- end

	-- local joy_x_left = Joystick:getGamepadAxis("leftx")
	-- local joy_y_left = Joystick:getGamepadAxis("lefty")
	-- print(joy_x_left, joy_y_left)

 -- Decrease shake timer if active
    if shakeTimer > 0 then
        shakeTimer = shakeTimer - dt
    end

	if not game_paused then
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

		--If Enemy Dies remove it from enemy_group
		for i, enemy in ipairs(enemy_group) do
			if enemy.active == false then
				-- Create Rage Energy PowerUp at Enemy Position
				local rage_energy = Rage()
				rage_energy.x = enemy.x
				rage_energy.y = enemy.y
				table.insert(objects, rage_energy)
				table.insert(rage_energy_group, rage_energy)

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
				else
					Player.hurt = false
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

		--Rage Collision with player
		for r, rage_energy in ipairs(rage_energy_group) do
			if Detect_collision(Player.collision_area, rage_energy.collision_area) then
				powerup:stop()
				print("Rage Energy Collected:")
				powerup:play()
				if Player.rage < Player.rage_total then
					Player.rage = Player.rage + 1
				end

				rage_energy.active = false
				--Remove Rage Energy from groups
				table.remove(rage_energy_group, r)
				for re, obj in ipairs(objects) do
					if obj == rage_energy then
						if rage_energy.active == false then
							print("Removing Rage Energy from objects")
							table.remove(objects, re)
						end
					end
				end
			end
		end
		-- Send player position to the shaders file
		shaders.light:send("playerPosition", {window_size_w / 2, window_size_h / 2})
	end

	--Emit dust particles at player position
	psystem:update(dt)
	if Player.move_x ~= 0 or Player.move_y ~= 0 then
		psystem:start()
	else
		psystem:stop()
	end
	psystem:setRotation(0, 6.28)
	psystem:setSpeed(1, 120)
	psystem:setPosition(Player.x, Player.y + 15)
	psystem:emit(1)
end

function scene.draw()
 	love.graphics.push() -- Save current drawing state for Shake Effect	
	mx, my = love.mouse.getPosition()

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

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("fill", 0, 0, window_size_w, window_size_h)

	love.graphics.draw(Map, 0, 0)

	-- Loop to Draw all Objects	
	for i, object in ipairs(objects) do
		if object == Player then
			love.graphics.draw(object.image, object.x, object.y, 0, 1, 1, object.size_w / 2, object.size_h - object.size_h / 4)
		else
			love.graphics.draw(object.image, object.x, object.y, 0, 1, 1, object.size_w / 2, object.size_h - object.size_h / 4)
		end
	end

	love.graphics.draw(psystem)

	-- Draw Collision Lines and Guides ---------------------------------
	Collision_rectangles()

	GameCamera:detach()

	--Circle Weapon Range of player
	love.graphics.setColor(1, 0, 0, 0.2)
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

	-- Draws Game Time and Kills Counter
	love.graphics.setFont(Font_small)
	love.graphics.print("Time: " .. FormatTime(game_clock), 705, window_size_h + (10 - window_size_h))
	love.graphics.print("Kills: "..Player.kills, 705, window_size_h + (23 - window_size_h))
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

function Collision_rectangles()
--Draw Collision Rectangles
	Player:draw()
	for i, enemy in ipairs(enemy_group) do
		enemy:draw()
	end
	for t, tree in ipairs(tree_group) do
		tree:draw()
	end
	for s, player_shot in ipairs(shot_group) do
		player_shot:draw()
	end
	for p, power_up in ipairs(power_up_group) do
		power_up:draw()
	end
	for r, rage_energy in ipairs(rage_energy_group) do
		rage_energy:draw()
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

function love.joystickpressed(joystick, button)
	print(joystick, joystick:getName(), joystick:getID(), button)

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
	if key == "l" then
		StartShake(0.5, 10) -- Shake for 0.5 seconds with intensity 10
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
		if Player.rage > 0 then
			Player.rage = Player.rage - 1
		else
			Player.rage = 0
		end
   		print(Player.rage)
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


return scene
