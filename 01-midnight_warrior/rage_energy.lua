Rage = Object.extend(Object)

function Rage.new(self)
	self.image = love.graphics.newImage("data/images/rage_energy/rage_energy.png")
	self.x = 1
	self.y = 1
	self.size_w = self.image:getWidth()
	self.size_h = self.image:getHeight()
	self.move_x = 0
	self.move_y = 0
	self.player_speed = 0
	self.collision_area = {
		x = self.x - self.size_w / 2 + 5,
		y = self.y - self.size_h / 2 - 5,
		width = self.size_w - 10,
		height = self.size_h - 10
	}
end

function Rage.update(self, dt)
	self.x = self.x
	self.y = self.y

	self.collision_area.x = self.x - self.size_w / 2 + 3
	self.collision_area.y = self.y - self.size_h / 2 - 4
end

function Rage.draw(self, screen_shift_x, screen_shift_y)
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.rectangle("line", self.collision_area.x , self.collision_area.y, self.collision_area.width, self.collision_area.height)
	love.graphics.setColor(1, 1, 1, 1)
end

