local scene = {}

local push = require "data.libraries.push"
local window_size_w, window_size_h = 800,600 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
windowWidth, windowHeight = windowWidth*.6, windowHeight*.8 --make the window a bit smaller than the screen itself
push:setupScreen(window_size_w, window_size_h, windowWidth, windowHeight)

function scene.modify(flags)
end
--love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setDefaultFilter("linear", "linear")

function scene.load()
	timer = 0
	timer_speed = 1
	scale = 0.2
	scale_speed = 0.1
	alpha_speed = 0.2
	alpha = 0

	logo = love.graphics.newImage("/data/images/game_axe/game_axe.png")
	logo_w = logo:getWidth()
	logo_h = logo:getHeight()
	logo_x = window_size_w / 2 - logo_w / 2
	logo_y = window_size_h / 2 - logo_h / 2 - 20
end

function scene.update(dt)
	if love.keyboard.isDown("escape") then
		love.window.close()
		love.event.quit()
	end

	if love.keyboard.isDown("return") then
		if alpha >= 1 then
			SM.load("title")
		end
	end

	if scale >= 0.7 then
		scale = 0.7
	else
		scale = scale + scale_speed * dt
		scale = scale + scale_speed * dt
	end

	if alpha >= 1 then
		alpha = 1
	else
		alpha = alpha + alpha_speed * dt
		alpha = alpha + alpha_speed * dt
	end

	if timer >= 5 then
		SM.load("title")
	else
		timer = timer + timer_speed * dt
	end
	--print(timer)
end

function scene.draw()
	push:start()

	love.graphics.setColor(0, 0, 0, 0) -- Set color to black for background
    love.graphics.rectangle("fill", 0, 0, window_size_w, window_size_h)

	love.graphics.setColor(1, 1, 1, alpha)
	love.graphics.draw(logo, window_size_w / 2, window_size_h / 2 - 20, 0, scale, scale, logo:getWidth() / 2, logo:getHeight() / 2)

	push:finish()
end

return scene
