PowerUp = Object.extend(Object)

function PowerUp.new(self)
	self.image = love.graphics.newImage("data/images/power_ups/power_up.png")
	self.x = love.math.random(0, 500)
	self.y = love.math.random(0, 400)
	self.size_w = self.image:getWidth()
	self.size_h = self.image:getHeight()
	self.move_x = 0
	self.move_y = 0
	self.player_speed = 0
	self.collision_area = {
		x = self.x - self.size_w / 2,
		y = self.y - self.size_h / 2 - 10,
		width = self.size_w,
		height = self.size_h - 4
	}
	self.active = true
	self.type = "life" --weapon, life, speed
end

function PowerUp.update(self, dt)	
	-- PowerUp
	self.x = self.x - (self.player_speed * dt) * self.move_x
	self.y = self.y - (self.player_speed * dt) * self.move_y

	self.collision_area.x = self.x - self.size_w / 2
	self.collision_area.y = self.y - self.size_h / 2 - 10
end

function PowerUp:shift(player_speed, move_x, move_y)
	--print(player_speed, move_x, move_y)
	self.move_x = move_x
	self.move_y = move_y
	self.player_speed = player_speed
end

function PowerUp:draw(screen_shift_x, screen_shift_y)
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle("line", self.collision_area.x , self.collision_area.y, self.collision_area.width, self.collision_area.height)
	love.graphics.setColor(1, 1, 1, 1)
end

