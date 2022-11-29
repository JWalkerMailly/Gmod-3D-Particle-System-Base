
include("shared.lua");

function PARTICLE:InitializeParticles(particles)

	-- Override here to setup particles for the system.
	-- Load configuration if supplied. A config is a JSON file of 1 or multiple particles
	-- that gets deserialized and passed into the ParticleEffect3D:New method for initialization.
	-- This is mainly used by the particle editor and not intended for normal use.
	if (particles != nil) then

		-- Reset particles array as a precaution. This effectively garbage
		-- collects all previous client side model caches from the system.
		if (self.Particles != nil) then
			for k,v in pairs(self.Particles) do
				v:CleanUp();
			end
		end

		-- Initialize particles from config.
		for k,v in pairs(particles) do
			ParticleEffect3DConfigurable:New(nil, self, v);
		end

		return;
	end

	-- Load configuration from cache.
	local config = self:GetConfig();
	if (config != nil && config != "") then
		self:SetConfig("");
		self:InitializeParticles(game.__3DParticleCache[config]);
	end

	-- This should only be used for testing purposes.
	local configFile = self:GetConfigFile();
	if (configFile != nil && configFile != "") then

		if (GLOBALS_3D_PARTICLE_EDITOR == nil) then
			ErrorNoHalt("Cannot parse particle configuration file without 3D Particle Editor.\n");
			return;
		end

		-- Use the supplied config path, else default to data.
		-- This is useful for particle systems that ship with addons but use
		-- the new configuration feature from the particle editor.
		local configPath = self:GetConfigPath();
		if (configPath == nil || configPath == "") then configPath = "DATA"; end

		local configExists = file.Exists(configFile, configPath);
		if (!configExists) then
			ErrorNoHalt("Could not find configuration file: " .. configFile .. ".\n");
			return;
		end

		-- Parse config file into the particle system if valid. This code is effectively the same
		-- as the one found in the particle editor addon. We include it here for compatibility reasons
		-- if people do not wish no install the editor. This way, addons can ship using only the
		-- 3D particle effects base without the need to the 3D particle effects editor to be installed.
		local data = file.Read(configFile, configPath)
		self:InitializeParticles(GLOBALS_3D_PARTICLE_EDITOR:ParseConfiguration(data));
	end
end