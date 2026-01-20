Shot = Object.extend(Object)


function Shot.new(self)
	self.shot = "shot"
	self.image = love.graphics.newImage("data/images/shot/basic_shot.png")
	self.x = 0
	self.y = 0
	self.x_ini = 0
	self.y_ini = 0
	self.speed = 0
	self.size_w = self.image:getWidth()
	self.size_h = self.image:getHeight()
	self.move_x = 0
	self.move_y = 0
	self.angle = 0
	self.direction = {}
	self.player_speed = 0
	self.shot_collision_area = {
		x = self.x,
		y = self.y,
		width = self.size_w,
		height = self.size_h
	}
	self.shot_distance = 0
	self.active = true
end

function Shot.update(self, dt)
	-- shot movement test
	--       { This block is the move}  {This block is the move correction from player move}	
	self.x = self.x + math.cos(self.angle) * self.speed * dt  - (self.player_speed * dt) * self.move_x
	self.y = self.y + math.sin(self.angle) * self.speed * dt  - (self.player_speed * dt) * self.move_y

	self.shot_collision_area.x = self.x - self.size_w / 2
	self.shot_collision_area.y = self.y - self.size_h / 2 - 1
	--print(self.x_ini, self.y_ini, self.x, self.y)
	self:calculateDistance(self.x_ini, self.y_ini, self.x, self.y)
end

function Shot.draw(self)
	love.graphics.setColor(1, 1, 0, 1)
	Collision_rect = love.graphics.rectangle("line", self.shot_collision_area.x , self.shot_collision_area.y, self.shot_collision_area.width, self.shot_collision_area.height)
	love.graphics.setColor(1, 1, 1, 1)
end

-- Shift when Player moves
function Shot:shift(player_speed, move_x, move_y)
	--print(player_speed, move_x, move_y)
	self.move_x = move_x
	self.move_y = move_y
	self.player_speed = player_speed
end

function Shot:start(angle, direction)
	self.angle = angle
	self.direction = direction
end

function Shot:calculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    -- math.pow(base, exponent) raises the base to the power of the exponent
    local distance_squared = math.pow(dx, 2) + math.pow(dy, 2)
    -- math.sqrt() calculates the square root of a number
    self.shot_distance = math.sqrt(distance_squared)
    --print(self.shot_distance)
    return self.shot_distance
end




