
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

AddCSLuaFile("particle.lua");

include("shared.lua");

function PARTICLE:Use(activator, caller)
	return false;
end

function PARTICLE:OnTakeDamage(damageInfo)
	return false;
end