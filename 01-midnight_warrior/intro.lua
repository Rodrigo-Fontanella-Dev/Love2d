local scene = {}

local window_size_w, window_size_h = 1280,720 --fixed game resolution

function scene.modify(flags)
end
--love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setDefaultFilter("linear", "linear")

local scale = 0.2
local scale_speed = 0.1
local alpha_speed = 0.2
local alpha = 0
local timer = 0
local timer_speed = 1
local logo = love.graphics.newImage("/data/images/game_axe/game_axe.png")
local logo_w = logo:getWidth()
local logo_h = logo:getHeight()
local logo_x = logo_w / 2
local logo_y = logo_h / 2

function scene.load()
	--print(window_size_w, window_size_h,logo_x, logo_y, logo_w, logo_h)
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
		logo_x = (logo_w * scale) / 2
		logo_y = (logo_h * scale) / 2
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
	love.graphics.setColor(0, 0, 0, 0) -- Set color to black for background
    love.graphics.rectangle("fill", 0, 0, window_size_w, window_size_h)
	love.graphics.setColor(1, 1, 1, alpha)
	love.graphics.draw(logo,window_size_w / 2 + logo_x, window_size_h / 2 + logo_y -20, 0, scale, scale, logo_w, logo_h)
end

return scene
