local scene = {}

local push = require "data.libraries.push"
local window_size_w, window_size_h = 800,600 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
windowWidth, windowHeight = windowWidth*.6, windowHeight*.8 --make the window a bit smaller than the screen itself
push:setupScreen(window_size_w, window_size_h, windowWidth, windowHeight)

function scene.modify(flags)
end
love.graphics.setDefaultFilter("nearest", "nearest")
--love.graphics.setDefaultFilter("linear", "linear")

local rollover_intro = false
local rollover_game = false
local rollover_options = false
local rollover_exit = false

local mouse = {}

local anim_y = 300
local anim_speed = 300
local unlock_buttons = false

local rollover_timer = 0

local button_rollover_sound = love.audio.newSource("data/sfx/effects/button_rollover.wav", "static")
local button_select_sound = love.audio.newSource("data/sfx/effects/mouse_select.wav", "static")

local scale_factor_w = windowWidth / window_size_w
local scale_factor_h = windowHeight / window_size_h

local logo = love.graphics.newImage("/data/images/screens/midnight_warrior_logo_640x640.png")
local background_screen = love.graphics.newImage("/data/images/screens/title_screen_background_800x600.png")

local button_hightlight = love.graphics.newImage("/data/images/buttons/button_highlight.png")

local button_intro = love.graphics.newImage("/data/images/buttons/button_intro.png")
local button_intro_off = love.graphics.newImage("/data/images/buttons/button_intro_off.png")
local button_intro_w = button_intro:getWidth()
local button_intro_h = button_intro:getHeight()
local button_intro_x = window_size_w / 2 - button_intro_w / 2
local button_intro_y = window_size_h / 2 + 80

local button_game = love.graphics.newImage("/data/images/buttons/button_game.png")
local button_game_off = love.graphics.newImage("/data/images/buttons/button_game_off.png")
local button_game_w = button_intro:getWidth()
local button_game_h = button_intro:getHeight()
local button_game_x = button_intro_x
local button_game_y = button_intro_y + button_game_h / 2 + 30

local button_options = love.graphics.newImage("/data/images/buttons/button_options.png")
local button_options_off = love.graphics.newImage("/data/images/buttons/button_options_off.png")
local button_options_w = button_intro:getWidth()
local button_options_h = button_intro:getHeight()
local button_options_x = button_game_x
local button_options_y = button_game_y + button_options_h / 2 + 30

local button_exit = love.graphics.newImage("/data/images/buttons/button_exit.png")
local button_exit_off = love.graphics.newImage("/data/images/buttons/button_exit_off.png")
local button_exit_w = button_intro:getWidth()
local button_exit_h = button_intro:getHeight()
local button_exit_x = button_options_x	
local button_exit_y = button_options_y + button_exit_h / 2 + 30

function scene.load()

end

function scene.update(dt)
	--print(windowWidth, windowHeight)
	
	if love.keyboard.isDown("escape") then
		button_selected()
		love.window.close()
		love.event.quit()
	end

	if love.keyboard.isDown("return") then
		button_selected()
		SM.load("game")
	end

	mouse[0], mouse[1] = love.mouse.getPosition()
	--print(mouse[0], mouse[1])

	local mouse_click = love.mouse.isDown(1)
	
	if unlock_buttons then
		if button_intro_x * scale_factor_w < mouse[0] and mouse[0] < button_intro_x * scale_factor_w + button_intro_w then
			if button_intro_y * scale_factor_h < mouse[1] and mouse[1] < button_intro_y * scale_factor_h + button_intro_h then
				rollover_intro = true  
			else
				rollover_intro = false	
			end
		else
			rollover_intro = false
		end
		if button_game_x * scale_factor_w < mouse[0] and mouse[0] < button_game_x * scale_factor_w + button_game_w then
			if button_game_y * scale_factor_h < mouse[1] and mouse[1] < button_game_y * scale_factor_h + button_game_h then
				rollover_game = true
			else
				rollover_game = false
			end
		else
			rollover_game = false  
		end
		if button_options_x * scale_factor_w < mouse[0] and mouse[0] < button_options_x * scale_factor_w + button_options_w then
			if button_options_y * scale_factor_h < mouse[1] and mouse[1] < button_options_y * scale_factor_h + button_options_h then
				rollover_options = true
			else
				rollover_options = false
			end
		else
			rollover_options = false
		end
		if button_exit_x * scale_factor_w < mouse[0] and mouse[0] < button_exit_x * scale_factor_w + button_exit_w then
			if button_exit_y * scale_factor_h < mouse[1] and mouse[1] < button_exit_y * scale_factor_h + button_exit_h then
				rollover_exit = true
			else
				rollover_exit = false 
			end
		else
			rollover_exit = false 
		end

		--print(rollover_timer)
		--Play Sound
		if rollover_intro or rollover_game or rollover_options or rollover_exit then
			rollover_timer = rollover_timer + 1
			if rollover_timer == 1 then
				play_sound_rollover()
			end
		else
			rollover_timer = 0
			button_rollover_sound:stop()
		end

		if rollover_intro then
			if mouse_click then
			end
		end
		if rollover_game then
			if mouse_click then
				button_selected()
				SM.load("game")
			end
		end
		if rollover_options then
			if mouse_click then
			end
		end
		if rollover_exit then
			if mouse_click then
				button_selected()
				love.window.close()
				love.event.quit()
			end
		end
	end

	if anim_y > 0 then
		anim_y = anim_y - anim_speed * dt
	else
		anim_y = 0
		unlock_buttons = true
	end
end

function scene.draw()
	push:start()

	love.graphics.draw(background_screen, 0, 0)
	love.graphics.draw(logo, 0, -50, 0, 0.6, 0.6)

	if rollover_intro then
		-- love.graphics.setColor(0, 0.5, 0, 1)
		-- love.graphics.rectangle("line",button_intro_x, button_intro_y, button_intro_w, button_intro_h)
		-- love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(button_hightlight, button_intro_x, button_intro_y + anim_y)		
		love.graphics.draw(button_intro, button_intro_x, button_intro_y + anim_y)
	else
		love.graphics.draw(button_intro_off, button_intro_x, button_intro_y + anim_y)
	end

	if rollover_game then
		--love.graphics.rectangle("line", button_game_x, button_game_y, button_game_w, button_game_h)
		love.graphics.draw(button_hightlight, button_game_x, button_game_y + anim_y)
		love.graphics.draw(button_game, button_game_x, button_game_y + anim_y)
	else
		love.graphics.draw(button_game_off, button_game_x, button_game_y + anim_y)
	end

	if rollover_options then
		--love.graphics.rectangle("line",button_options_x, button_options_y, button_options_w, button_options_h)
		love.graphics.draw(button_hightlight, button_options_x, button_options_y + anim_y)
		love.graphics.draw(button_options, button_options_x, button_options_y + anim_y)
	else
		love.graphics.draw(button_options_off, button_options_x, button_options_y + anim_y)
	end

	if rollover_exit then
		--love.graphics.rectangle("line",button_exit_x, button_exit_y, button_exit_w, button_exit_h)
		love.graphics.draw(button_hightlight, button_exit_x, button_exit_y + anim_y)
		love.graphics.draw(button_exit, button_exit_x, button_exit_y + anim_y)
	else
		love.graphics.draw(button_exit_off, button_exit_x, button_exit_y + anim_y)
	end
	push:finish()
end

function play_sound_rollover()
	button_rollover_sound:play()
end

function button_selected()
	button_select_sound:play()
end

return scene