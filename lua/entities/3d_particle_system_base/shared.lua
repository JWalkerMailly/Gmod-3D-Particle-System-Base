
-- Syntactic sugar.
PARTICLE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");

	AddCSLuaFile("particle_3d.lua");
end

include("particle_3d.lua");

DEFINE_BASECLASS("3d_particle_system");

PARTICLE.RenderGroup = RENDERGROUP_BOTH;

function PARTICLE:SetupDataTables()
	BaseClass.SetupDataTables(self);
	self:NetworkVar("String", 0, "Config");
end