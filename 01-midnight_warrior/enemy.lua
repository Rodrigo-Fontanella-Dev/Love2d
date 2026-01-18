Enemy = Object.extend(Object)

local collision_rect = {}
local collision_body_rect = {}

function Enemy.new(self)
	self.enemy = "enemy"
	self.image = love.graphics.newImage("data/images/enemy/contaminated_48x48.png")
	self.x = love.math.random(0, 500)
	self.y = love.math.random(0, 400)
	self.speed = 10
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
	self.active = true
	self.hurt = false
end
-- Go for Player
function Enemy.update(self, dt)
	-- Enemy movement test
	--       { This block is the move}  {This block is the move correction from player move}	
	self.x = self.x + self.speed * dt - (self.player_speed * dt) * self.move_x
	self.y = self.y + self.speed * dt - (self.player_speed * dt) * self.move_y

	--Update Collision Areas
	self.collision_area.x = self.x - self.size_w / 4 - 3 
	self.collision_area.y = self.y 

	self.body_collision_area.x = self.x - self.size_w / 5 - 1
	self.body_collision_area.y = self.y - self.size_h + 12

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

	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.draw(self.image, self.x - self.size_w / 2, self.y - self.size_h + 12)
	love.graphics.setColor(1, 1, 1, 1)

end

function Enemy:hurt()
	print("dano")
end

