Tree = Object.extend(Object)

function Tree.new(self)
	self.image = love.graphics.newImage("data/images/trees/tree01.png")
	self.x = love.math.random(0, 960)
	self.y = love.math.random(0, 720)
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
	self.draw_collision_alpha = 0
	self.collided_active = false
	self.collision_sensor = {
		x = self.x - self.size_w / 4 + 20,
		y = self.y + 8,
		width = self.size_w / 3,
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

	self.collision_sensor.x = self.x - self.size_w / 2 + 40
	self.collision_sensor.y = self.y - 5

end

function Tree.draw(self, screen_shift_x, screen_shift_y)

	love.graphics.setColor(0, 1, 1, self.draw_collision_alpha)
	love.graphics.rectangle("line", self.collision_area.x , self.collision_area.y, self.collision_area.width, self.collision_area.height)
	love.graphics.setColor(1, 1, 1, self.draw_collision_alpha)

	love.graphics.setColor(0, 1, 0, self.draw_collision_alpha)
	love.graphics.rectangle("line", self.body_collision_area.x , self.body_collision_area.y, self.body_collision_area.width, self.body_collision_area.height)
	love.graphics.setColor(1, 1, 1, self.draw_collision_alpha)

	love.graphics.setColor(1, 0, 0, self.draw_collision_alpha)
	love.graphics.rectangle("line", self.collision_sensor.x , self.collision_sensor.y, self.collision_sensor.width, self.collision_sensor.height)
	love.graphics.setColor(1, 1, 1, self.draw_collision_alpha)
end

