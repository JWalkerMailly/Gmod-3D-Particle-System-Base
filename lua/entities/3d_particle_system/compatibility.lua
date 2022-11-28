
-- This is the same lookup table as the particle editor. It is included for
-- compatibility reasons when reading a particle configuration file created with an editor.
PARTICLE.MathFunctionsConversionTable = {
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

function PARTICLE:ParseConfigurationFile()

	local config = self:GetConfig();
	if (config != nil && config != "") then

		-- Use the supplied config path, else default to data.
		-- This is useful for particle systems that ship with addons but use
		-- the new configuration feature from the particle editor.
		local configPath = self:GetConfigPath();
		if (configPath == nil || configPath == "") then configPath = "DATA"; end

		local configExists = file.Exists(config, configPath);
		if (!configExists) then return; end

		-- Parse config file into the particle system if valid. This code is effectively the same
		-- as the one found in the particle editor addon. We include it here for compatibility reasons
		-- if people do not wish no install the editor. This way, addons can ship using only the
		-- 3D particle effects base without the need to the 3D particle effects editor to be installed.
		local configParticles = util.JSONToTable(file.Read(config, configPath));
		for k,v in pairs(configParticles) do
			if (v.InheritPos) 		then v.Pos 			= nil; end
			if (v.InheritLifeTime) 	then v.LifeTime 	= nil; end
			if (!v.UseEndRotation) 	then v.EndRotation 	= nil; end
			if (!v.UseEndColor) 	then v.EndColor 	= nil; end
			if (!v.UseEndAlpha) 	then v.EndAlpha 	= nil; end
			if (!v.UseScaleAxis) 	then v.ScaleAxis 	= Vector(0, 0, 0); end
			if (!v.UseEndScale) 	then v.EndScale 	= nil; end
			if (v.Material != "")	then v.Material 	= Material(v.Material);
			else 						 v.Material 	= nil; end

			-- Convert each string representation to its actual function counterpart.
			v.RotationFunction 		= self.MathFunctionsConversionTable[v.RotationFunction];
			v.ColorFunction 		= self.MathFunctionsConversionTable[v.ColorFunction];
			v.AlphaFunction 		= self.MathFunctionsConversionTable[v.AlphaFunction];
			v.ScaleFunction 		= self.MathFunctionsConversionTable[v.ScaleFunction];
			ParticleEffect3D:New(nil, self, v);
		end
	end
end