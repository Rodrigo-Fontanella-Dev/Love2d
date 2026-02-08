Void = Object.extend(Object)

function Void.new(self)
	self.image = love.graphics.newImage("data/images/void_energy/void_energy.png")
	self.x = 1
	self.y = 1
	self.size_w = self.image:getWidth()
	self.size_h = self.image:getHeight()
	self.move_x = 0
	self.move_y = 0
	self.player_speed = 0
	self.collision_area = {
		x = self.x - self.size_w / 2,
		y = self.y - self.size_h / 2 + 10,
		width = self.size_w - 30,
		height = self.size_h - 5
	}
	self.draw_collision_alpha = 0
end

function Void.update(self, dt)
	self.x = self.x
	self.y = self.y

	self.collision_area.x = self.x - self.size_w / 2 + 15
	self.collision_area.y = self.y - self.size_h / 2 - 8
end

function Void.draw(self, screen_shift_x, screen_shift_y)

	love.graphics.setColor(0, 1, 0, self.draw_collision_alpha)
	love.graphics.rectangle("line", self.collision_area.x , self.collision_area.y, self.collision_area.width, self.collision_area.height)
	love.graphics.setColor(1, 1, 1, self.draw_collision_alpha)

end

