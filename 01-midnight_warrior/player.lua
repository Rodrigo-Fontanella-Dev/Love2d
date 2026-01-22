Player = Object.extend(Object)

local weapon = require("weapons")
--local player_img_front = love.graphics.newImage("data/images/player/elias_wolf_front.png")
local player_img_front = love.graphics.newImage("data/images/player/elias_wolf_48x48px.png")
local player_img_back = love.graphics.newImage("data/images/player/elias_wolf_back.png")
local player_img_right = love.graphics.newImage("data/images/player/elias_wolf_right.png")
local player_img_left = love.graphics.newImage("data/images/player/elias_wolf_left.png")
local blood = love.graphics.newImage("data/images/particles/blood/blood.png")

function Player.new(self)
	self.player = "player"
	self.image = player_img_front
	self.speed = 80
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
	self.weapon = weapon.pistol
	self.active = true
	self.life_total = 100
	self.life = 100
	self.rage_total = 3
	self.rage = 3
	self.kills = 0
	self.dead = false
end

function Player.update(self, dt)
	if self.dead == false then
	
		--print(dt)
		if love.keyboard.isDown("d") then
			self.screen_shift_x = self.screen_shift_x + self.speed * dt
			self.image = player_img_right
			self.move_x = 1
		elseif love.keyboard.isDown("a") then
			self.screen_shift_x = self.screen_shift_x - self.speed * dt
			self.image = player_img_left
			self.move_x = -1
		else
			self.move_x = 0
		end
		if love.keyboard.isDown("w") then
			self.screen_shift_y = self.screen_shift_y - self.speed * dt
			self.image = player_img_back
			self.move_y = -1
		elseif love.keyboard.isDown("s") then
			self.screen_shift_y = self.screen_shift_y + self.speed * dt
			self.image = player_img_front
			self.move_y = 1
		else
			self.move_y = 0
		end

		if self.move_x == 0 and self.move_y == 0 then
			self.image = player_img_front
		end

		self.collision_area.x = self.x - self.size_w / 4 - 2 
		self.collision_area.y = self.y -2 self.collision_area.x = self.x - self.size_w / 4 - 2 
		self.collision_area.y = self.y -2
	end
	if love.keyboard.isDown("escape") then
			love.window.close()
	end
end

function Player.draw(self)
	local mx, my = love.mouse.getPosition()
	--print(mx, my)
	local collision_rect = love.graphics.rectangle("line", self.collision_area.x, self.collision_area.y, self.collision_area.width, self.collision_area.height)
end
