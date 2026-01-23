Rage = Object.extend(Object)

function Rage.new(self)
	self.image = love.graphics.newImage("data/images/rage_energy/rage_energy.png")
	self.x = love.math.random(0, 500)
	self.y = love.math.random(0, 400)
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

	self.x = self.x - (self.player_speed * dt) * self.move_x
	self.y = self.y - (self.player_speed * dt) * self.move_y

	self.collision_area.x = self.x - self.size_w / 2 + 3
	self.collision_area.y = self.y - self.size_h / 2 - 4
end

function Rage:shift(player_speed, move_x, move_y)
	--print(player_speed, move_x, move_y)
	self.move_x = move_x
	self.move_y = move_y
	self.player_speed = player_speed
end

function Rage.draw(self, screen_shift_x, screen_shift_y)
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.rectangle("line", self.collision_area.x , self.collision_area.y, self.collision_area.width, self.collision_area.height)
	love.graphics.setColor(1, 1, 1, 1)
end

