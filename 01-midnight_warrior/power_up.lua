PowerUp = Object.extend(Object)

function PowerUp.new(self)
	self.image = love.graphics.newImage("data/images/power_ups/power_up.png")
	self.x = love.math.random(0, 960)
	self.y = love.math.random(0, 720)
	self.size_w = self.image:getWidth()
	self.size_h = self.image:getHeight()
	self.move_x = 0
	self.move_y = 0
	self.player_speed = 0
	self.collision_area = {
		x = self.x - self.size_w / 2 + 6,
		y = self.y - self.size_h / 2,
		width = self.size_w - 12,
		height = self.size_h - 20
	}
	self.active = true
	self.type = "life" --weapon, life, speed
	self.draw_collision_alpha = 0
end

function PowerUp.update(self, dt)	
	-- PowerUp
	self.x = self.x -- - (self.player_speed * dt) * self.move_x
	self.y = self.y -- - (self.player_speed * dt) * self.move_y

	self.collision_area.x = self.x - self.size_w / 2 + 6
	self.collision_area.y = self.y - self.size_h / 2
end

function PowerUp:draw(screen_shift_x, screen_shift_y)

	love.graphics.setColor(1, 0, 0, self.draw_collision_alpha)
	love.graphics.rectangle("line", self.collision_area.x , self.collision_area.y, self.collision_area.width, self.collision_area.height)
	love.graphics.setColor(1, 1, 1, self.draw_collision_alpha)

end

