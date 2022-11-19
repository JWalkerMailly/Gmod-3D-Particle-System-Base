
-- Syntactic sugar.
PARTICLE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");

	AddCSLuaFile("particle.lua");
end

include("particle.lua");

DEFINE_BASECLASS("base_anim");

PARTICLE.RenderGroup = RENDERGROUP_BOTH;

PARTICLE.Particles 	= {};
PARTICLE.SpawnTime 	= 0;
PARTICLE.LifeTime 	= 0;
PARTICLE.ThinkRate 	= 1;

function PARTICLE:SetLifeTime(lifetime)
	self.LifeTime = lifetime;
end

function PARTICLE:Initialize()

	self:DrawShadow(false);
	self.SpawnTime = CurTime();

	if (CLIENT) then
		self:InitializeParticles();
	end
end

function PARTICLE:Add(particle)
	table.insert(self.Particles, particle);
end

function PARTICLE:Think()

	-- Cleanup if this system has finished emitting.
	if (CurTime() > self.SpawnTime + self.LifeTime) then
		self:Destroy();
		return;
	end

	if (CLIENT) then self:UpdateParticles(); end
	self:NextThink(CurTime() + self.ThinkRate);
	return true;
end

function PARTICLE:Destroy()

	-- Dispose of all 3D particles tables.
	if (CLIENT) then
		for k,v in pairs(self.Particles) do
			v:CleanUp();
		end
	end

	-- Dispose of our entity (particle).
	if (SERVER) then
		SafeRemoveEntity(self);
	end
end