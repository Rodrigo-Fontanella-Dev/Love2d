Enemy = Object.extend(Object)

local collision_rect = {}
local collision_body_rect = {}
local window_size_w, window_size_h = 1280,720 --fixed game resolution

function Enemy.new(self)
	self.enemy = "enemy"
	self.image = love.graphics.newImage("data/images/enemy/contaminated_48x48.png")
	self.x = love.math.random(0, 500)
	self.y = love.math.random(0, 400)
	self.speed = 10
	self.direction = {}
	self.direction[0] = 1
	self.direction[1] = -1
	self.size_w = self.image:getWidth()
	self.size_h = self.image:getHeight()
	--print(self.size_w, self.size_h)
	self.move_x = 0
	self.move_y = 0
	self.player_speed = 0
	self.collision_area = {
		x = self.x - self.size_w / 4 - 4,
		y = self.y - 2,
		width = self.size_w / 2 + 5,
		height = self.size_h / 4
	}
	self.body_collision_area = {
		x = self.x,
		y = self.y,
		width = self.size_w / 2 - 5,
		height = self.size_h
	}
	self.player_position = {}
	self.player_position[0] = 0
	self.player_position[1] = 0
	self.active = true
	self.hurt = false
	self.energy = 5
	self.energy_bar_active = true
	self.energy_bar_rect = {}
	self.energy_bar_rect[0] = self.x
	self.energy_bar_rect[1] = self.y
	self.energy_bar_rect[2] = self.size_w
	self.energy_bar_rect[3] = 2 -- Thickness of line

	self.energy_bar_background_rect = {
		x = self.x - 1,
		y = self.y - 1,
		width = self.size_w + 2,
		height = 4 -- Thickness of line
	}
	self.energy_bar_alpha = 0
	self.alpha_counter = 40
	self.energy_bar_fade_speed = 5
	self.dead = false
	self.timer_dead = 20
	self.timer_dead_speed = 10
end

-- Go for Player
function Enemy.update(self, dt)
	
	-- Enemy movement test
	--       { This block is the move}  {This block is the move correction from player move}	
	self.x = self.x + self.speed * self.direction[0] * dt -- self.player_position[0] * dt
	self.y = self.y + self.speed * self.direction[1] * dt -- self.player_position[1] * dt

	--Update Collision Areas
	self.collision_area.x = self.x - self.size_w / 4 - 3 
	self.collision_area.y = self.y 

	self.body_collision_area.x = self.x - self.size_w / 5 - 1
	self.body_collision_area.y = self.y - self.size_h + 12

	-- Update Energy Bar Position
	self.energy_bar_rect[0] = self.x - self.size_w / 2
	self.energy_bar_rect[1] = self.y - self.size_h / 2 - 20

	self.energy_bar_background_rect.x = self.energy_bar_rect[0] - 1
	self.energy_bar_background_rect.y = self.energy_bar_rect[1] - 1

	if self.x - self.player_position[0] < 0 then
		self.direction[0] = 1
	else
		self.direction[0] = -1
	end

	-- Um pouco para cima do Player
	if self.y - self.player_position[1] + 3 < 0 then
		self.direction[1] = 1
	else
		self.direction[1] = -1
	end

	self.energy_bar_rect[2] = (self.size_w / 5) * self.energy

	if self.dead then -- If enemy is dead then freeze it and start timer to remove it
		self.direction[0] = 0
		self.direction[1] = 0
		self.energy_bar_alpha = 0
		self.timer_dead = self.timer_dead - self.timer_dead_speed * dt
	end

	if self.timer_dead <= 0 then
		self:enemy_dead()
	end

	-- Hurt logic
	if self.hurt then
		self.energy_bar_alpha = 1
		self.energy = self.energy - 1
		self.hurt = false
		self.alpha_counter = 40
	end

	if self.energy_bar_alpha > 0 then
		self.alpha_counter = self.alpha_counter - self.energy_bar_fade_speed * dt
		if self.alpha_counter < 30 then
			self.energy_bar_alpha = self.energy_bar_alpha - self.energy_bar_fade_speed * dt
		end
		if self.alpha_counter <= 0 then
			self.energy_bar_alpha = 0
			self.alpha_counter = 40
		end
	else
		self.energy_bar_alpha = 0
		self.alpha_counter = 40
	end

	if self.energy <= 0 then
		self.dead = true
	end
end

-- Shift when Player moves
function Enemy:shift(player_speed, move_x, move_y)
	--print(player_speed, move_x, move_y)
	self.move_x = move_x
	self.move_y = move_y
	self.player_speed = player_speed
end

function Enemy.draw(self)
	love.graphics.setColor(1, 0, 0, 1)
	collision_rect = love.graphics.rectangle("line", self.collision_area.x , self.collision_area.y, self.collision_area.width, self.collision_area.height)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setColor(0, 1, 0, 1)
	collision_body_rect = love.graphics.rectangle("line", self.body_collision_area.x , self.body_collision_area.y, self.body_collision_area.width, self.body_collision_area.height)
	love.graphics.setColor(1, 1, 1, 1)

	--Draw Enemy Red
	-- love.graphics.setColor(1, 0, 0, 1)
	-- love.graphics.draw(self.image, self.x - self.size_w / 2, self.y - self.size_h + 12)
	-- love.graphics.setColor(1, 1, 1, 1)

	if self.energy_bar_active  then
		-- Draw energy bar
		love.graphics.setColor(0.2, 0, 0, self.energy_bar_alpha)
		love.graphics.rectangle("fill", self.energy_bar_background_rect.x, self.energy_bar_background_rect.y, self.energy_bar_background_rect.width, self.energy_bar_background_rect.height)
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.setColor(1, 0, 0, self.energy_bar_alpha)
		love.graphics.rectangle("fill", self.energy_bar_rect[0], self.energy_bar_rect[1], self.energy_bar_rect[2], self.energy_bar_rect[3])
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function Enemy:enemy_dead()
	self.active = false
end
