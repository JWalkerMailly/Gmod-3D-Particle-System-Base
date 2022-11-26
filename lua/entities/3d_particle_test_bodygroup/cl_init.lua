
include("shared.lua");

function PARTICLE:InitializeParticles()

	local pos = self:GetPos();

	local inner = ParticleEffect3D:New("models/weapons/w_slam.mdl", self);
	inner:SetBodyGroups("1");
	inner:SetPos(pos);
	inner:SetLifeTime(10);
	inner:SetRotationNormal(Vector(1, 1, 1));
	inner:SetStartRotation(0);
	inner:SetEndRotation(-90);
	inner:SetRotationFunctionMod(2);
	inner:SetStartColor(Color(255, 255, 255));
	inner:SetStartAlpha(0);
	inner:SetEndAlpha(255);
	inner:SetAlphaFunctionMod(3);
	inner:SetStartScale(5);
	inner:SetEndScale(5);
	inner:SetScaleFunctionMod(2.25);
end