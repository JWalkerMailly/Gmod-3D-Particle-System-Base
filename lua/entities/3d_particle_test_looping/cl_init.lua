
include("shared.lua");

function PARTICLE:InitializeParticles()

	local pos = self:GetPos();

	local inner = ParticleEffect3D:New("models/hunter/misc/shell2x2.mdl", self);
	inner:SetMaterial("Models/effects/comball_sphere");
	inner:SetLooping(true);
	inner:SetPos(pos);
	inner:SetLifeTime(0.6);
	inner:SetRotationNormal(Vector(1, 1, 1));
	inner:SetStartRotation(0);
	inner:SetEndRotation(-90);
	inner:SetRotationFunctionMod(2);
	inner:SetStartColor(Color(255, 255, 255));
	inner:SetEndColor(Color(51, 61, 227));
	inner:SetColorFunctionMod(1);
	inner:SetStartAlpha(0);
	inner:SetEndAlpha(255);
	inner:SetAlphaFunctionMod(3);
	inner:SetStartScale(1.2);
	inner:SetEndScale(1.3);
	inner:SetScaleFunctionMod(2.25);

	local mid = ParticleEffect3D:New("models/hunter/misc/shell2x2.mdl", self);
	mid:SetMaterial("models/props_combine/portalball001_sheet");
	mid:SetLooping(true);
	mid:SetPos(pos);
	mid:SetLifeTime(0.6);
	mid:SetRotationNormal(Vector(1, 1, 0));
	mid:SetStartRotation(0);
	mid:SetEndRotation(-90);
	mid:SetRotationFunctionMod(2);
	mid:SetStartColor(Color(255, 255, 255));
	mid:SetEndColor(Color(51, 61, 227));
	mid:SetColorFunctionMod(2);
	mid:SetStartAlpha(0);
	mid:SetEndAlpha(255);
	mid:SetAlphaFunctionMod(3);
	mid:SetStartScale(1.2);
	mid:SetEndScale(1.45);
	mid:SetScaleFunctionMod(2.5);
	mid:SetDelay(0.1);

	local outer = ParticleEffect3D:New("models/hunter/misc/shell2x2.mdl", self);
	outer:SetMaterial("Models/effects/splodearc_sheet");
	outer:SetLooping(true);
	outer:SetPos(pos);
	outer:SetLifeTime(0.6);
	outer:SetRotationNormal(Vector(1, 0, 1));
	outer:SetStartRotation(0);
	outer:SetEndRotation(90);
	outer:SetRotationFunctionMod(2);
	outer:SetStartColor(Color(255, 255, 255));
	outer:SetEndColor(Color(51, 61, 227));
	outer:SetColorFunctionMod(0.45);
	outer:SetStartAlpha(0);
	outer:SetEndAlpha(155);
	outer:SetAlphaFunctionMod(3.5);
	outer:SetScaleAxis(Vector(0.25, 1.5, 1.5));
	outer:SetStartScale(0);
	outer:SetEndScale(1.55);
	outer:SetScaleFunctionMod(2.25);
	outer:SetDelay(0.2);
end