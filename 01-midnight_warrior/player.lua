Player = Object.extend(Object)

local window_size_w, window_size_h = 960,720 --fixed game resolution
local mx, my = love.mouse.getPosition()
local angle_shot = 0

function Player.new(self)
	self.player = "player"
	self.player_img_right = love.graphics.newImage("data/images/player/elias_wolf_80x80px.png")
	self.player_img_left = love.graphics.newImage("data/images/player/elias_wolf_80x80px_left.png")
	self.rage_attack_img = love.graphics.newImage("data/images/rage_attack/rage_attack1.png")
	self.image = self.player_img_right
	self.speed = 150
	self.screen_shift_x = 0
	self.screen_shift_y = 0
	self.x = 0
	self.y = 0
	self.size_w = self.image:getWidth()
	self.size_h = self.image:getHeight()
	self.movement_x = 0
	self.movement_y = 0

	self.move_player_left = 1
	self.move_player_right = 1
	self.move_player_up = 1
	self.move_player_down = 1

	self.collision_area = {
		x = self.x - self.size_w / 4 - 2,
		y = self.y -2,
		width = self.size_w / 2 + 5,
		height = self.size_h / 4
	}
	self.hurt = false
	self.active = true
	self.life_total = 100
	self.life = 100
	-- The rage begin with 1 charge that can be increased during the game
	self.rage_total = 1
	self.rage = 1
	self.rage_charge = 1
	self.rage_power = 4
	self.rage_area = {
		x = self.x,
		y = self.y,
		width = 120,
		height = 40
	}
	self.rage_attack = false
	self.rage_attack_duration = 0.3
	self.void_energy = 0
	self.kills = 0
	self.dead = false
	self.weapon = ""
	self.weapon_angle = 0

	self.blood_particle = love.graphics.newImage("data/images/particles/blood/blood.png")
	self.psystem = love.graphics.newParticleSystem(self.blood_particle, 10)
	self.blood_duration = 5
	self.generate_blood = false

	self.draw_collision_alpha = 0
end

function Player.update(self, dt)
	--print(self.movement_x, self.movement_y)
	if self.dead == false then
		if love.keyboard.isDown("d") then
			self.x = self.x + self.speed * dt * self.move_player_right
			self.movement_x = 1
		elseif love.keyboard.isDown("a") then
			self.x = self.x - self.speed * dt * self.move_player_left
			self.movement_x = 1
		else
			self.movement_x = 0
		end
		if love.keyboard.isDown("w") then
			self.y = self.y - self.speed * dt * self.move_player_up
			self.movement_y = 1
		elseif love.keyboard.isDown("s") then
			self.y = self.y + self.speed * dt * self.move_player_down
			self.movement_y = 1
		else
			self.movement_y = 0
		end

		self.collision_area.x = self.x - self.size_w / 4 - 2
		self.collision_area.y = self.y -2 self.collision_area.x = self.x - self.size_w / 4 - 2
		self.collision_area.y = self.y -2

		self.rage_area.x = self.x - self.rage_area.width / 2
		self.rage_area.y = self.y - self.rage_area.height / 2
	end

	if self.rage_attack then
		self.rage_attack_duration = self.rage_attack_duration - 1 * dt
		--print(self.rage_attack_duration)
		if self.rage_attack_duration <= 0 then
			self.rage_attack = false
			self.rage_attack_duration = 0.3
		end
	end

	--Rage Regeneration
	if self.rage < 1 then
		self.rage = self.rage + 0.1 * dt
	elseif self.rage >= 1 then
		self.rage = 1
	end

	-- Hurt logic
	if self.hurt then
		self.generate_blood = true
	else
		self.psystem:stop()
	end

	self.psystem:update(dt)
	self.psystem:setPosition(self.x, self.y - 20)

	if self.generate_blood then
		--Emit blood particles at enemy position
		self.psystem:start()
		--Particle System specs
		self.psystem:setParticleLifetime(0.5, 1)
		self.psystem:setEmissionRate(500) --particle emitted per second
		self.psystem:setSpeed(10, 200)
		self.psystem:setColors(255, 255, 255, 30, 255, 255, 255, 0) -- Fade out.
		self.psystem:setRotation(0, 6.28)
		self.psystem:setSpread(50)
		self.psystem:setLinearAcceleration(-20, -20, 20, 20)
		self.psystem:setSizes(1, 0.5, 0.0)
		self.psystem:setSpinVariation(1)
		self.psystem:setSpeed(1, 100)
		self.psystem:emit(1)

		self.blood_duration = self.blood_duration - 20 * dt
	else
		-- Stop emission of particlesystem
		self.psystem:stop()
	end

	if self.blood_duration <= 0 then
		self.generate_blood = false
		self.blood_duration = 5
		self.hurt = false
	end
end

function Player.draw(self)
	love.graphics.draw(self.psystem)

	if self.rage_attack then
		love.graphics.draw(self.rage_attack_img, self.x - self.rage_attack_img:getWidth() / 2, self.y - self.rage_attack_img:getHeight() / 2, 0, 1, 1)
	end

	love.graphics.setColor(1, 0, 0, self.draw_collision_alpha)
	love.graphics.rectangle("line", self.collision_area.x, self.collision_area.y, self.collision_area.width, self.collision_area.height)

	if self.rage_attack then
		love.graphics.setColor(1, 0.5, 0.5, self.draw_collision_alpha)
	else
		love.graphics.setColor(0.5, 1, 0.5, self.draw_collision_alpha)
	end
	love.graphics.ellipse("line",self.x, self.y, self.rage_area.width / 2, self.rage_area.height / 2, 30)
	love.graphics.rectangle("line", self.rage_area.x, self.rage_area.y, self.rage_area.width, self.rage_area.height)
end
