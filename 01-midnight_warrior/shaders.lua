local shaders = {}

shaders.whiteout = love.graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
	{
		vec4 pixel = Texel(texture, texture_coords);
		return vec4(1, 1, 1, pixel.a);
	}
]]

shaders.light = love.graphics.newShader[[
	extern vec2 playerPosition;
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
		
		vec4 pixel = Texel(texture, texture_coords);
		float distance = length(pixel_coords - playerPosition);
		float fade = clamp(distance/300, 0.0, 1.0);
		
		pixel.a = pixel.a * fade;

		return pixel * color;
	}
]]


return shaders