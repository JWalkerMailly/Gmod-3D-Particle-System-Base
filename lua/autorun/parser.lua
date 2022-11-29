
-- This behaves like a static class.
GLOBALS_3D_PARTICLE_PARSER = {};

-- This is only used internally by the configuration module. Configs
-- are JSON files and since we can't store function references, we need
-- to setup a lookup table and manually do the conversions afterwards.
GLOBALS_3D_PARTICLE_PARSER.MathFunctionsConversionTable = {
	["Sine"] 			= math.sin,
	["Cosine"] 			= math.cos,
	["Tangent"] 		= math.tan,
	["InBack"] 			= math.ease.InBack,
	["InBounce"] 		= math.ease.InBounce,
	["InCirc"] 			= math.ease.InCirc,
	["InCubic"] 		= math.ease.InCubic,
	["InElastic"] 		= math.ease.InElastic,
	["InExpo"] 			= math.ease.InExpo,
	["InOutBack"] 		= math.ease.InOutBack,
	["InOutBounce"] 	= math.ease.InOutBounce,
	["InOutCirc"] 		= math.ease.InOutCirc,
	["InOutCubic"] 		= math.ease.InOutCubic,
	["InOutElastic"] 	= math.ease.InOutElastic,
	["InOutExpo"] 		= math.ease.InOutExpo,
	["InOutQuad"] 		= math.ease.InOutQuad,
	["InOutQuart"] 		= math.ease.InOutQuart,
	["InOutQuint"] 		= math.ease.InOutQuint,
	["InOutSine"] 		= math.ease.InOutSine,
	["InQuad"] 			= math.ease.InQuad,
	["InQuart"] 		= math.ease.InQuart,
	["InQuint"] 		= math.ease.InQuint,
	["InSine"] 			= math.ease.InSine,
	["OutBack"] 		= math.ease.OutBack,
	["OutBounce"] 		= math.ease.OutBounce,
	["OutCirc"] 		= math.ease.OutCirc,
	["OutCubic"] 		= math.ease.OutCubic,
	["OutElastic"] 		= math.ease.OutElastic,
	["OutExpo"] 		= math.ease.OutExpo,
	["OutQuad"] 		= math.ease.OutQuad,
	["OutQuart"] 		= math.ease.OutQuart,
	["OutQuint"] 		= math.ease.OutQuint,
	["OutSine"] 		= math.ease.OutSine
};

-- Used to parse strings.
function GLOBALS_3D_PARTICLE_PARSER:ToGeneric(data)
	return "\"" .. data .. "\"";
end

-- Used to parse integers and floats.
function GLOBALS_3D_PARTICLE_PARSER:ToNumber(data)
	return data;
end

-- Used to parse angles.
function GLOBALS_3D_PARTICLE_PARSER:ToAngle(data)
	return "\"{" .. data.p .. " " .. data.y .. " " .. data.r .. "}\"";
end

-- Used to parse vectors.
function GLOBALS_3D_PARTICLE_PARSER:ToVector(data)
	return "\"[" .. data.x .. " " .. data.y .. " " .. data.z .. "]\"";
end

-- Used to parse colors.
function GLOBALS_3D_PARTICLE_PARSER:ToVectorColor(data)
	return "{\"r\":" .. data.r .. ",\"g\":" .. data.g .. ",\"b\":" .. data.b .. ",\"a\":255}";
end

function GLOBALS_3D_PARTICLE_PARSER:DeserializeParticlesToSource(data)

	-- If conversion fails, return empty table to avoid breaking the editor.
	local particles = util.JSONToTable(data);
	if (particles == nil) then
		return {};
	end

	return particles;
end

function GLOBALS_3D_PARTICLE_PARSER:DeserializeParticles(config, worker)

	-- Convert JSON config file datatypes to source datatypes.
	local particles = self:DeserializeParticlesToSource(config);

	-- Convert source datatypes to editor datatypes.
	for k,v in pairs(particles) do
		for x,y in pairs(v) do
			if (isstring(y)) then particles[k][x] = self:ToGeneric(y); continue; end
			if (isnumber(y)) then particles[k][x] = self:ToNumber(y); continue; end
			if (isangle(y))  then particles[k][x] = self:ToAngle(y); continue; end
			if (isvector(y)) then particles[k][x] = self:ToVector(y); continue; end
			if (isbool(y)) 	 then continue; end
			particles[k][x] = self:ToVectorColor(y);
		end
	end

	-- If a worker is suppplied, apply deserialized particles to it.
	if (worker != nil) then
		worker.Particles = particles;
	end

	return particles;
end

function GLOBALS_3D_PARTICLE_PARSER:ParseConfiguration(config)

	local particles = GLOBALS_3D_PARTICLE_PARSER:DeserializeParticlesToSource(config);
	for k,v in pairs(particles) do

		-- Since JSON and DPropertyLists can't handle nil or empty values,
		-- nil states must be handled manually according to the desired behavior.
		if (v.InheritPos) 		then v.Pos 			= nil; end
		if (v.InheritLifeTime) 	then v.LifeTime 	= nil; end
		if (!v.UseEndRotation) 	then v.EndRotation 	= nil; end
		if (!v.UseEndColor) 	then v.EndColor 	= nil; end
		if (!v.UseEndAlpha) 	then v.EndAlpha 	= nil; end
		if (!v.UseEndScale) 	then v.EndScale 	= nil; end
		if (!v.UseEndAxisScale) then v.EndAxisScale = nil; end
		if (v.Material != "")	then v.Material 	= Material(v.Material);
		else 						 v.Material 	= nil; end

		-- Convert each string representation to its actual math function counterpart.
		v.RotationFunction 	= GLOBALS_3D_PARTICLE_PARSER.MathFunctionsConversionTable[v.RotationFunction];
		v.ColorFunction 	= GLOBALS_3D_PARTICLE_PARSER.MathFunctionsConversionTable[v.ColorFunction];
		v.AlphaFunction 	= GLOBALS_3D_PARTICLE_PARSER.MathFunctionsConversionTable[v.AlphaFunction];
		v.ScaleFunction 	= GLOBALS_3D_PARTICLE_PARSER.MathFunctionsConversionTable[v.ScaleFunction];
		v.AxisScaleFunction = GLOBALS_3D_PARTICLE_PARSER.MathFunctionsConversionTable[v.AxisScaleFunction];
	end

	return particles;
end