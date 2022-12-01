
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
PARTICLE.Dirty 		= false;

function PARTICLE:SetupDataTables()
	self:NetworkVar("Float", 0, "LifeTime");
end

function PARTICLE:Initialize()

	self:DrawShadow(false);
	self.SpawnTime = CurTime();

	-- Backwards compatibility for old systems using the LifeTime property.
	-- Static systems will make use of the self.LifeTime property while dynamic
	-- systems (variable LifeTime for example) should call SetLifeTime(time)
	-- before calling Spawn(). If you want your particles to inherit the system's
	-- lifetime, simply avoid calling SetLifeTime on your particle in InitializeParticles().
	if (self:GetLifeTime() == 0) then
		self:SetLifeTime(self.LifeTime);
	end

	if (CLIENT) then
		self:InitializeParticles();
	end
end

function PARTICLE:Add(particle)
	table.insert(self.Particles, particle);
end

function PARTICLE:Think()

	-- Cleanup if this system has finished emitting.
	if (CurTime() > self.SpawnTime + self:GetLifeTime()) then
		self:Destroy();
		return;
	end

	-- Max think for anim type entity.
	if (CLIENT) then self:UpdateParticles(); end
	self:NextThink(CurTime());
	return true;
end

function PARTICLE:OnDestroy()
	-- override.
end

function PARTICLE:Destroy()

	-- Dispose of all 3D particles tables.
	if (CLIENT) then
		for k,v in pairs(self.Particles) do
			v:CleanUp();
		end
	end

	-- Dispose of our entity (system).
	if (!self.Dirty) then

		self:OnDestroy();
		self.Dirty = true;

		-- Theory: To prevent client side models from not being garbage collected,
		-- we set a 1 second delay + the server's tickrate. This should prevent
		-- desync during lag and be accurate to 1 fps.
		SafeRemoveEntityDelayed(self, FrameTime() + 1);
	end
end