local weapons = {}

weapons.weapon_list = {
	-- Weapon 1 (Pistol)
	pistol = {
		name = "Pistol",
		bullets = 5,
		range = 150,
		charge_time = 5,
		damage = 1,
		speed = 300,
		image_icon = love.graphics.newImage("data/images/weapons_icons/pistol.png"),
		image = love.graphics.newImage("data/images/weapons/pistol.png")
	},

	-- Weapon 2 (Automatic Rifle)
	automatic_rifle = {
		name = "Automatic Rifle",
		bullets = 15,
		range = 200,
		charge_time = 5,
		damage = 2,
		speed = 250,
		image_icon = love.graphics.newImage("data/images/weapons_icons/automatic_rifle.png"),
		image = love.graphics.newImage("data/images/weapons/automatic_rifle.png")
	},

	-- Weapon 3 (Automatic Rifle with Granade Launcher)
	automatic_rifle_granade_launcher = {
		name = "Automatic Rifle Granade Launcher",
		bullets = 20,
		range = 250,
		charge_time = 5,
		damage = 5,
		speed = 250,
		image_icon = love.graphics.newImage("data/images/weapons_icons/automatic_rifle_granade_launcher.png"),
		image = love.graphics.newImage("data/images/weapons/automatic_rifle_granade_launcher.png")
	},

	-- Weapon 4 (Flame Launcher)
	flame_launcher = {
		name = "Flame Launcher",
		bullets = 15,
		range = 150,
		charge_time = 5,
		damage = 10,
		speed = 200,
		image_icon = love.graphics.newImage("data/images/weapons_icons/flame_launcher.png"),
		image = love.graphics.newImage("data/images/weapons/flame_launcher.png")
	},

	-- Weapon 5 (Bazooka)
	bazooka = {
		name = "Bazooka",
		bullets = 15,
		range = 250,
		charge_time = 5,
		damage = 15,
		speed = 200,
		image_icon = love.graphics.newImage("data/images/weapons_icons/bazooka.png"),
		image = love.graphics.newImage("data/images/weapons/bazooka.png")
	},

	-- Weapon 6 (Multi Rocket Launcher)
	multi_rocket_launcher = {
		name = "Multi Rocket Launcher",
		bullets = 15,
		range = 300,
		charge_time = 5,
		damage = 20,
		speed = 200,
		image_icon = love.graphics.newImage("data/images/weapons_icons/multi_rocket_launcher.png"),
		image = love.graphics.newImage("data/images/weapons/multi_rocket_launcher.png")
	}
}

return weapons.weapon_list