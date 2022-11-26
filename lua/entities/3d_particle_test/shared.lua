
-- Syntactic sugar.
PARTICLE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("3d_particle_system");

PARTICLE.RenderGroup 	= RENDERGROUP_BOTH;
PARTICLE.LifeTime 		= 2.4;

function PARTICLE:OnDestroy()
	print("OnDestroy callback test.");
end