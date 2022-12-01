
game.__3DParticleCache = {};

-- Add custom hook onto game table in order to support 3D particle configuration files.
-- This must be called from the shared realm in order to send resources to clients.
function game.Add3DParticles(particleFile, path)

	if (particleFile != nil && particleFile != "" && string.match(particleFile, ".lua") != nil) then

		-- Use the supplied config path, else default to game.
		-- This is useful for particle systems that ship with addons but use
		-- the new configuration feature from the particle editor.
		if (path == nil || path == "") then path = "LUA"; end
		local configExists = file.Exists(particleFile, path);
		if (!configExists) then
			ErrorNoHalt("Could not find 3D Particle configuration file: " .. particleFile .. ".\n");
			return;
		end

		if (SERVER) then
			resource.AddFile(particleFile);
		end

		-- Parse config file into cache.
		local data = file.Read(particleFile, path)
		if (CLIENT) then
			game.__3DParticleCache[string.Replace(string.match(particleFile, "[^/]+$"), ".lua", "")] = GLOBALS_3D_PARTICLE_PARSER:ParseConfiguration(data);
		end
	end
end

-- Helper function to create 3D particle systems like PCFs when using config files.
ParticleSystem3D = function(particleName, position, angles, lifetime, parent, attach)

	local effect = ents.Create("3d_particle_system_base");
	effect:SetPos(position);
	effect:SetAngles(angles);
	effect:SetLifeTime(lifetime);
	effect:SetConfig(particleName);
	if (parent != NULL && parent != nil && parent:IsValid() && IsEntity(parent)) then
		effect:SetParent(parent, attach || 0);
	end
	effect:Spawn();
end