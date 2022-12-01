
include("shared.lua");

function PARTICLE:InitializeParticles(particles)

	-- Override here to setup particles for the old system.
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
			Particle3D:New(nil, self, v);
		end

		return;
	end

	-- Load configuration from cache.
	local config = self:GetConfig();
	if (config != nil && config != "") then
		self:SetConfig("");
		self:InitializeParticles(game.__3DParticleCache[config]);
	end
end