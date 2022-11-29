
-- Syntactic sugar.
PARTICLE = ENT;

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");

	AddCSLuaFile("particle_configurable.lua");
end

include("particle_configurable.lua");

DEFINE_BASECLASS("3d_particle_system");

PARTICLE.RenderGroup = RENDERGROUP_BOTH;

function PARTICLE:SetupDataTables()
	BaseClass.SetupDataTables(self);
	self:NetworkVar("String", 0, "Config");
	self:NetworkVar("String", 1, "ConfigFile");	-- This should only be used for testing purposes.
	self:NetworkVar("String", 2, "ConfigPath");	-- This should only be used for testing purposes.
end