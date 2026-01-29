Tree = Object.extend(Object)

function Tree.new(self)
	self.image = love.graphics.newImage("data/images/trees/tree01.png")
	self.x = love.math.random(0, 500)
	self.y = love.math.random(0, 400)
	self.size_w = self.image:getWidth()
	self.size_h = self.image:getHeight()
	self.move_x = 0
	self.move_y = 0
	self.player_speed = 0
	self.collision_area = {
		x = self.x - self.size_w / 4 + 20,
		y = self.y + 8,
		width = self.size_w / 7,
		height = self.size_h / 7
	}

	self.body_collision_area = {
		x = self.x,
		y = self.y,
		width = self.size_w / 6,
		height = self.size_h / 3
	}
end

function Tree.update(self, dt)	
	-- Tree
	self.x = self.x -- - (self.player_speed * dt) * self.move_x
	self.y = self.y -- - (self.player_speed * dt) * self.move_y

	self.collision_area.x = self.x - self.size_w / 4 + 20
	self.collision_area.y = self.y + 8

	self.body_collision_area.x = self.x - self.size_w / 10
	self.body_collision_area.y = self.y - 25
end

function Tree:shift(player_speed, move_x, move_y)
	--print(player_speed, move_x, move_y)
	self.move_x = move_x
	self.move_y = move_y
	self.player_speed = player_speed
	
end

function Tree.draw(self, screen_shift_x, screen_shift_y)
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.rectangle("line", self.collision_area.x , self.collision_area.y, self.collision_area.width, self.collision_area.height)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setColor(0, 1, 0, 1)
	local collision_body_rect = love.graphics.rectangle("line", self.body_collision_area.x , self.body_collision_area.y, self.body_collision_area.width, self.body_collision_area.height)
	love.graphics.setColor(1, 1, 1, 1)

end

