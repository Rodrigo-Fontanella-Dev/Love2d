Player = Object.extend(Object)

local window_size_w, window_size_h = 1280,720 --fixed game resolution

local player_img_right = love.graphics.newImage("data/images/player/elias_wolf_80x80px.png")
local player_img_left = love.graphics.newImage("data/images/player/elias_wolf_80x80px_left.png")
local blood = love.graphics.newImage("data/images/particles/blood/blood.png")
local mx, my = love.mouse.getPosition()
local angle_shot = 0

function Player.new(self)
	self.player = "player"
	self.image = player_img_right
	self.speed = 150
	self.screen_shift_x = 0
	self.screen_shift_y = 0
	self.x = 0
	self.y = 0
	self.size_w = self.image:getWidth()
	self.size_h = self.image:getHeight()
	self.move_x = 0
	self.move_y = 0
	self.collision_area = {
		x = self.x - self.size_w / 4 - 2,
		y = self.y -2,
		width = self.size_w / 2 + 5,
		height = self.size_h / 4
	}
	self.hurt = false

	self.psystem_blood = love.graphics.newParticleSystem(blood, 32)
	self.psystem_blood:setParticleLifetime(1, 2) -- Particles live at least 2s and at most 5s.
	self.psystem_blood:setLinearAcceleration(0, 0, -100, -100) 
	self.psystem_blood:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to black.
	self.psystem_blood:setSpeed(0 , 100)

	self.active = true
	self.life_total = 100
	self.life = 100
	-- The rage has 3 charges that can be increased during the game
	self.rage_total = 3
	self.rage = 3
	self.kills = 0
	self.dead = false
	self.weapon = ""
	self.weapon_angle = 0
end

function Player.update(self, dt)
	--print(self.weapon.name)
	if self.dead == false then
		--print(dt)
		if love.keyboard.isDown("d") then
			self.x = self.x + self.speed * dt
			self.move_x = 1
			self.image = player_img_right
		elseif love.keyboard.isDown("a") then
			self.x = self.x - self.speed * dt
			self.move_x = -1
			self.image = player_img_left
		else
			self.move_x = 0
		end
		if love.keyboard.isDown("w") then
			self.y = self.y - self.speed * dt
			self.move_y = -1
		elseif love.keyboard.isDown("s") then
			self.y = self.y + self.speed * dt
			self.move_y = 1
		else
			self.move_y = 0
		end

		local xAxis = Joystick:getGamepadAxis("leftx")
		local yAxis = Joystick:getGamepadAxis("lefty")

		-- Move player based on input, with a small deadzone check
		if math.abs(xAxis) > 0.1 then
			self.x = self.x + self.speed * dt * xAxis
			self.move_x = 1
			if xAxis < 0 then
				self.image = player_img_left
			else
				self.image = player_img_right
			end
		end
		if math.abs(yAxis) > 0.1 then
			self.move_y = 1
			self.y = self.y + self.speed * dt * yAxis
		end

		if self.move_x == 0 and self.move_y == 0 then
			self.image = player_img_right
		end

		self.collision_area.x = self.x - self.size_w / 4 - 2
		self.collision_area.y = self.y -2 self.collision_area.x = self.x - self.size_w / 4 - 2
		self.collision_area.y = self.y -2
	end

	if love.keyboard.isDown("escape") then
			love.window.close()
	end

	if mx > window_size_w / 2 then
		self.image = player_img_right
	else
		self.image = player_img_left
	end
end

function Player.draw(self)
	mx, my = love.mouse.getPosition()
	-- Weapon direction
	if mx > window_size_w / 2 then
		love.graphics.draw(self.weapon.image, self.x, self.y, self.weapon_angle, 1, 1, self.weapon.image:getWidth()/2, self.weapon.image:getHeight()/2)
	else
		love.graphics.draw(self.weapon.image, self.x, self.y, self.weapon_angle, 1, -1, self.weapon.image:getWidth()/2, self.weapon.image:getHeight()/2)
	end
	local collision_rect = love.graphics.rectangle("line", self.collision_area.x, self.collision_area.y, self.collision_area.width, self.collision_area.height)
end
