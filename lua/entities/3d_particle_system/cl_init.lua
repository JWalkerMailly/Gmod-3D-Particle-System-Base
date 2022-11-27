
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
			ParticleEffect3D:New(nil, self, v);
		end
	end
end

function PARTICLE:UpdateParticles()
	-- Override here to update particles.
end

function PARTICLE:Draw()

	-- Render all particles from this system.
	for k,v in pairs(self.Particles) do
		if (v != NULL && v != nil) then
			v:Draw();
		end
	end
end