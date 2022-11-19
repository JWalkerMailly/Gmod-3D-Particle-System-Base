
include("shared.lua");

function PARTICLE:InitializeParticles()
	-- Override here to setup particles for the system.
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