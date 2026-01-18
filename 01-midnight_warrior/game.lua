local scene = {}

local push = require "data.libraries.push"
local window_size_w, window_size_h = 800,600 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
windowWidth, windowHeight = windowWidth*.6, windowHeight*.8 --make the window a bit smaller than the screen itselfas, false, pixelperfect = false})
push:setupScreen(window_size_w, window_size_h, windowWidth, windowHeight)

function scene.modify(flags)
end

--love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setDefaultFilter("nearest", "nearest")


-- Library to create classes
Object = require "data/libraries/classic"
require "enemy"
require "player"
require "tree"
require "shot"
local shaders = require("shaders")

local objects = {}
local mouse = {}
local angle_shot = 0
local shot_direction = {}
local shot = {}

local shot_group = {}
local enemy_group = {}
local tree_group = {}
local offset = {}
local game_paused = false

local collision_enemy = false
local basic_shot = love.audio.newSource("data/sfx/effects/shot.wav", "static")
local shake_render_offset = {}
shake_render_offset[0] = 0
shake_render_offset[1] = 0

local anim_shake_active = false
local shake_timer = 500
local shake_intensity = 500
local shake_timer = 1000
local shake_intensity = 10000
local anim_shake_active = false

local scale_factor_w = windowWidth / window_size_w
local scale_factor_h = windowHeight / window_size_h



function scene.load()

	


	Font = love.graphics.newFont("data/fonts/robot.otf", 30)
	Font_small = love.graphics.newFont("data/fonts/robot.otf", 15)

	Paused_on_sound = love.audio.newSource("data/sfx/effects/pause_on.wav", "static")
	Paused_off_sound = love.audio.newSource("data/sfx/effects/pause_off.wav", "static")

	-- window_size_w = 800	
	-- window_size_h = 600

	-- Make a player instance	
	Player = Player()
	-- Center Player in Screen
	Player.x = window_size_w / 2
	Player.y = window_size_h / 2
	table.insert(objects, Player)

	--Creation of Enemies
	for e = 1, 1 do
		Enemy = Enemy()
		table.insert(objects, Enemy)
		table.insert(enemy_group, Enemy)
	end

	--Creation of Trees
	for t = 1, 1 do
		local tree = Tree()
		table.insert(objects, tree)
		table.insert(tree_group, tree)
	end

	Map = love.graphics.newImage("data/maps/map01.png")

	--Particle System
	local img = love.graphics.newImage("data/images/particles/slime/slime.png")
	local psystem = love.graphics.newParticleSystem(img, 32)
	psystem:setParticleLifetime(2, 4) -- Particles live at least 2s and at most 5s.
	psystem:setLinearAcceleration(0, 0, 0, 0)
	psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to black.
	psystem:setRotation(0, 3)
	psystem:setRadialAcceleration(3, 3)
	psystem:setSpread(3)
	psystem:setOffset(-1, 3)
	psystem:setLinearDamping(0, 5)
	psystem:setEmissionArea("uniform", 200, 200, 0, true)
	psystem:setDirection(0.5)
	psystem:setSpeed(20, 100)
	psystem:setSizes(1, 10, 20)
	psystem:setSpinVariation(1)
end

function scene.update(dt)
	if not game_paused then
		mouse[0], mouse[1] = love.mouse.getPosition()
		--print(mouse[0], mouse[1])

		-- mouse_left_click = love.mouse.isDown(1)
		-- mouse_right_click = love.mouse.isDown(2)

		local dist_x = (mouse[0] / scale_factor_w - Player.x)
		local dist_y = (mouse[1] / scale_factor_h - Player.y)

		angle_shot = math.atan2(dist_y, dist_x)
		--print(angle_shot)

		if mouse[0] > Player.x then
			shot_direction[0] = 1
		else
			shot_direction[0] = -1
		end

		if mouse[1] > Player.y then
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

		-- Shift enemies when player moves
		for i, enemy in ipairs(enemy_group) do
			enemy:shift(Player.speed, Player.move_x, Player.move_y)
		end

		-- Shift shot when player moves
		for s, player_shot in ipairs(shot_group) do
			player_shot:shift(Player.speed, Player.move_x, Player.move_y)
		end

		-- Shift Trees when player moves
		for t, tree in ipairs(tree_group) do
			tree:shift(Player.speed, Player.move_x, Player.move_y)
		end

		-- SHOT DETECTION --------------------------------------
		-- Shot out of range
		for i, _shot in ipairs(shot_group) do
			if _shot.shot_distance > Player.weapon.range then
				_shot.active = false
				table.remove(shot_group, i)
			end
		end

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
					print("acertou inimigo")
					player_shot.active = false
					table.remove(shot_group, s)
				end
			end
		end

		-- Enemy Collision with player (Only Ground collision Rectangle)
		for e, enemy in ipairs(enemy_group) do
			collision_enemy = Detect_collision(Player.collision_area, enemy.collision_area)
			if collision_enemy then
				Player.hurt = true
				Player.psystem_blood:update(dt)
				Player.psystem_blood:emit(32)
				--print("Collision:", Player.hurt)
			else
				Player.hurt = false
				--Player.psystem_blood:stop()
				--print("Collision:", Player.hurt)
			end
		end

		-- Send player positio to the shaders file
		shaders.light:send("playerPosition", {Player.x, Player.y})

		if anim_shake_active then
			offset = Anim_shake(dt)
			--print(offset[0], offset[1])
			--print(anim_shake_active, shake_timer)
		end
		--print(shake_timer)
	end
end

function scene.draw()
	push:start()

	local mx, my = love.mouse.getPosition()
	local mouse_x = mx / scale_factor_w
	local mouse_y = my / scale_factor_h

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("fill", 0, 0, window_size_w, window_size_h)

	love.graphics.draw(Map, -Player.screen_shift_x, -Player.screen_shift_y)

	-- Loop to Draw all Objects	
	for i, object in ipairs(objects) do
		love.graphics.draw(object.image, object.x, object.y, 0, 1, 1, object.size_w / 2, object.size_h - object.size_h / 4)
	end

	-- Draw the particle system at the center of the game window.
	--love.graphics.draw(psystem, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)
	love.graphics.draw(Player.psystem_blood, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5 - 30)

	Collision_rectangles()

	-- Shader Light Start
	love.graphics.setShader(shaders.light)
	love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, window_size_w, window_size_h)
    love.graphics.setShader()
    -- Shader Light End

	--Circle Weapon Range of player
	love.graphics.setColor(1, 0, 0, 0.2)
	love.graphics.circle("line", Player.x, Player.y, Player.weapon.range, 30)
	love.graphics.setColor(1, 1, 1, 1)

	--Line test of sight of player
	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.line(window_size_w / 2, window_size_h / 2, mouse_x, mouse_y)
	love.graphics.setColor(1, 1, 1, 1)

	if game_paused then
		love.graphics.setColor(1, 1, 0, 1)
		love.graphics.setFont(Font)
        love.graphics.print("PAUSED", window_size_w / 2 - 50, window_size_h / 2)
        love.graphics.setColor(1, 1, 1, 1)
    end

    --Draw Rectangle Shake effect Test
    love.graphics.rectangle("fill", 100 + shake_render_offset[0], 100 + shake_render_offset[1], 50, 50)

    push:finish()

	-- Draws the actual image and weapon name
	love.graphics.setFont(Font)
	love.graphics.print(Player.weapon.name, 50, windowHeight - 120)
	love.graphics.draw(Player.weapon.image, 5, windowHeight - 100)

    Fps_counter()
end

function Fps_counter()
	Fps = love.timer.getFPS()
		--print(fps)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(Font_small)
		love.graphics.print("FPS: " .. tostring(Fps), windowWidth - 80, windowHeight - 40)
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
        Game_paused = not Game_paused
    end
	if key == "l" then
		shake_timer = 1000
		shake_intensity = 10000
    	anim_shake_active = true
    end
end

function love.mousepressed(x, y, button, istouch)
	--print(x, y, button)
	if button == 1 then
		basic_shot:stop()
   		--print("tiro")
   		-- Make a player instance	
		shot = Shot()
		-- Center shot in Player Position
		shot.x = window_size_w / 2
		shot.y = window_size_h / 2
		shot.speed = Player.weapon.speed
		table.insert(objects, shot)
		table.insert(shot_group, shot)
		shot:start(angle_shot, shot_direction)
		basic_shot:play()
   	end
   	if button == 2 then
   		--print("garra")
   	end
end

function Anim_shake(dt)
	shake_timer = shake_timer - 1
    shake_render_offset[0] = math.floor(math.cos(shake_timer) * shake_intensity * dt)
    shake_render_offset[1] = math.floor(math.sin(shake_timer) * shake_intensity * dt)
    if shake_timer <= 0 then  -- Quando acabar o shake, volta os valores render_offset para 0
        shake_render_offset[0] = 0
        shake_render_offset[1] = 0
        anim_shake_active = false
    end
	return shake_render_offset
end

return scene



