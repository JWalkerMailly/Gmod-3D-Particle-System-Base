
ParticleEffect3D = {};
ParticleEffect3D.__index = ParticleEffect3D;

function ParticleEffect3D:New(model, system)

	local object = {

		System = system,

		Model = model,
		ModelCache = ClientsideModel(model),
		Skin = nil,
		BodyGroups = nil,
		Material = nil,
		Dirty = false,

		Color = Color(255, 255, 255),
		Alpha = 255,
		Scale = 1,
		Rotation = 0,
		Looping = false,

		Pos = Vector(0, 0, 0),
		Angles = Angle(0, 0, 0),

		SpawnTime = CurTime(),
		Delay = 0,
		LifeTime = nil,

		RotationFunction = math.sin,
		RotationNormal = Vector(0, 0, 0),
		RotateAroundNormal = false,
		StartRotation = 0,
		EndRotation = nil,
		RotationFunctionMod = 0,

		ColorFunction = math.sin,
		StartColor = Color(0, 0, 0),
		EndColor = nil,
		ColorFunctionMod = 0,

		AlphaFunction = math.sin,
		StartAlpha = 0,
		EndAlpha = nil,
		AlphaFunctionMod = 0,

		ScaleFunction = math.sin,
		ScaleAxis = Vector(0, 0, 0),
		StartScale = 0,
		EndScale = nil,
		ScaleFunctionMod = 0,

		ThinkFunction = nil
	};

	object.ModelCache:SetNoDraw(true);
	util.PrecacheModel(model);
	setmetatable(object, ParticleEffect3D);
	system:Add(object);
	return object;
end

function ParticleEffect3D:GetModel()
	return self.Model;
end

function ParticleEffect3D:GetSkin()
	return self.Skin;
end

function ParticleEffect3D:SetSkin(skin)
	self.Skin = skin;
	self.ModelCache:SetSkin(skin);
end

function ParticleEffect3D:GetBodyGroups()
	return self.BodyGroups;
end

function ParticleEffect3D:SetBodyGroups(bodyGroups)
	self.BodyGroups = bodyGroups;
	self.ModelCache:SetBodyGroups(bodyGroups);
end

function ParticleEffect3D:GetMaterial()
	return self.Material;
end

function ParticleEffect3D:SetMaterial(texture)
	self.Material = Material(texture);
end

function ParticleEffect3D:LerpColor(t, from, to)
	return Color(
		Lerp(t, from.r, to.r),
		Lerp(t, from.g, to.g),
		Lerp(t, from.b, to.b),
		Lerp(t, from.a || 255, to.a || 255)
	);
end

function ParticleEffect3D:Draw()

	if (self.ModelCache == NULL || self.ModelCache == nil || self.Dirty) then
		return;
	end

	-- Particle is finished, reset spawn time.
	if (self.Looping && self:Finished()) then
		self.SpawnTime = CurTime();
	end

	-- Do nothing if the particle is dead and wait for cleanup.
	if (self:Finished()) then
		self:CleanUp();
		return;
	end

	-- Used to fix frametime when drawing the entity.
	if (self.FrameTime == nil) then
		self.FrameTime = CurTime();
	end

	local delay = self.Delay;
	local delta = math.Clamp((CurTime() - (self.SpawnTime + delay)) / self:GetLifeTime(), 0, 1);
	local frametime = CurTime() - self.FrameTime;

	-- Wait for the particle delay to finish before rendering.
	if (CurTime() < self.SpawnTime + delay) then
		return;
	end

	-- Do think.
	if (self.ThinkFunction != nil) then
		self.ThinkFunction(self);
	end

	-- Setup color.
	if (self.StartColor != nil) then
		self.Color = self.StartColor;
	end

	-- Setup alpha.
	if (self.StartAlpha != nil) then
		self.Alpha = self.StartAlpha;
	end

	-- Setup scale.
	if (self.StartScale != nil) then
		self.Scale = self.StartScale;
	end

	-- Setup roll.
	if (self.StartRotation != nil) then
		self.Rotation = self.StartRotation;
	end

	-- Patricle effect color parameters.
	if (self.EndColor != nil) then
		self.Color = self:LerpColor(
			self.ColorFunction(delta * self.ColorFunctionMod),
			self.StartColor,
			self.EndColor);
	end

	-- Particle effect alpha parameters.
	if (self.EndAlpha != nil) then
		self.Alpha = Lerp(
			self.AlphaFunction(delta * self.AlphaFunctionMod),
			self.StartAlpha,
			self.EndAlpha);
	end

	-- Particle effect size parameters.
	if (self.EndScale != nil) then
		self.Scale = Lerp(
			self.ScaleFunction(delta * self.ScaleFunctionMod),
			self.StartScale,
			self.EndScale);
	end

	-- Particle effect rotation parameters.
	if (self.EndRotation != nil) then
		self.Rotation = Lerp(
			self.RotationFunction(delta * self.RotationFunctionMod),
			self.StartRotation,
			self.EndRotation);
	end

	-- Compute rotation based on the desired behavior.
	local angles = self.Angles;
	if (self.RotateAroundNormal) then
		angles:RotateAroundAxis(self.RotationNormal, (self.EndRotation || 0) * frametime);
	else
		local normal = self.RotationNormal;
		angles = Angle(normal[1], normal[2], normal[3]) * self.Rotation;
	end

	-- Used for axis scaling.
	local matScale = Matrix();
	local initialScale = Vector(1, 1, 1) * self.StartScale;
	if (self.ScaleAxis != Vector(0, 0, 0)) then
		matScale:Scale(initialScale + self.ScaleAxis * self.Scale);
	else
		matScale:Scale(Vector(1, 1, 1) * self.Scale);
	end

	-- Handle parenting;
	local renderingPos 		= self.Pos;
	local renderingAngles 	= angles;
	local parent 			= self.System:GetParent();
	if (parent != NULL && parent != nil && parent:IsValid()) then

		-- Transform parent world matrix using position and angle data as local transforms.
		local parentMatrix = self.System:GetParentWorldTransformMatrix();
		parentMatrix:Translate(renderingPos);
		parentMatrix:Rotate(renderingAngles);
		renderingPos = parentMatrix:GetTranslation();
		renderingAngles = parentMatrix:GetAngles();
	end

	-- Render 3D effect using our model cache.
	render.SetBlend(self.Alpha / 255);
	render.SetColorModulation(self.Color.r / 255, self.Color.g / 255, self.Color.b / 255)
	self.ModelCache:EnableMatrix("RenderMultiply", matScale);
	render.MaterialOverride(self.Material);
	render.Model({
		model = self.Model,
		pos = renderingPos,
		angle = renderingAngles
	}, self.ModelCache);
	render.MaterialOverride(nil);
	render.SetColorModulation(1, 1, 1);
	render.SetBlend(1);
	self.FrameTime = CurTime();
end

function ParticleEffect3D:GetLooping()
	return self.Looping;
end

function ParticleEffect3D:SetLooping(loop)
	self.Looping = loop;
end

function ParticleEffect3D:GetPos()
	return self.Pos;
end

function ParticleEffect3D:SetPos(pos)
	self.Pos = Vector(pos);
end

function ParticleEffect3D:GetAngles()
	return self.Angles;
end

function ParticleEffect3D:SetAngles(ang)
	self.Angles = Angle(ang);
end

function ParticleEffect3D:GetSpawnTime()
	return self.SpawnTime;
end

function ParticleEffect3D:SetSpawnTime(time)
	self.SpawnTime = time;
end

function ParticleEffect3D:GetDelay()
	return self.Delay;
end

function ParticleEffect3D:SetDelay(time)
	self.Delay = time;
end

function ParticleEffect3D:GetLifeTime()

	if (self.LifeTime == nil) then
		local systemLifeTime = self.System:GetLifeTime();
		return math.Clamp(systemLifeTime - self.Delay, FrameTime(), systemLifeTime);
	end

	return self.LifeTime;
end

function ParticleEffect3D:SetLifeTime(time)
	self.LifeTime = time;
end

function ParticleEffect3D:GetRotationFunction()
	return self.RotationFunction;
end

function ParticleEffect3D:SetRotationFunction(name)
	self.RotationFunction = name;
end

function ParticleEffect3D:GetRotationNormal()
	return self.RotationNormal;
end

function ParticleEffect3D:SetRotationNormal(normal)
	self.RotationNormal = Vector(normal);
end

function ParticleEffect3D:GetRotateAroundNormal()
	return self.RotateAroundNormal;
end

function ParticleEffect3D:SetRotateAroundNormal(rotate)
	self.RotateAroundNormal = rotate;
end

function ParticleEffect3D:GetStartRotation()
	return self.StartRotation;
end

function ParticleEffect3D:SetStartRotation(rotation)
	self.StartRotation = rotation;
end

function ParticleEffect3D:GetEndRotation()
	return self.EndRotation;
end

function ParticleEffect3D:SetEndRotation(rotation)
	self.EndRotation = rotation;
end

function ParticleEffect3D:GetRotationFunctionMod()
	return self.RotationFunctionMod;
end

function ParticleEffect3D:SetRotationFunctionMod(mod)
	self.RotationFunctionMod = mod;
end

function ParticleEffect3D:GetColorFunction()
	return self.ColorFunction;
end

function ParticleEffect3D:SetColorFunction(name)
	self.ColorFunction = name;
end

function ParticleEffect3D:GetStartColor()
	return self.StartColor;
end

function ParticleEffect3D:SetStartColor(col)
	self.StartColor = Color(col.r, col.g, col.b);
end

function ParticleEffect3D:GetEndColor()
	return self.EndColor;
end

function ParticleEffect3D:SetEndColor(col)
	self.EndColor = Color(col.r, col.g, col.b);
end

function ParticleEffect3D:GetColorFunctionMod()
	return self.ColorFunctionMod;
end

function ParticleEffect3D:SetColorFunctionMod(mod)
	self.ColorFunctionMod = mod;
end

function ParticleEffect3D:GetAlphaFunction()
	return self.AlphaFunction;
end

function ParticleEffect3D:SetAlphaFunction(name)
	self.AlphaFunction = name;
end

function ParticleEffect3D:GetStartAlpha()
	return self.StartAlpha;
end

function ParticleEffect3D:SetStartAlpha(alpha)
	self.StartAlpha = alpha;
end

function ParticleEffect3D:GetEndAlpha()
	return self.EndAlpha;
end

function ParticleEffect3D:SetEndAlpha(alpha)
	self.EndAlpha = alpha;
end

function ParticleEffect3D:GetAlphaFunctionMod()
	return self.AlphaFunctionMod;
end

function ParticleEffect3D:SetAlphaFunctionMod(mod)
	self.AlphaFunctionMod = mod;
end

function ParticleEffect3D:GetScaleFunction()
	return self.ScaleFunction;
end

function ParticleEffect3D:SetScaleFunction(name)
	self.ScaleFunction = name;
end

function ParticleEffect3D:GetScaleAxis()
	return self.ScaleAxis;
end

function ParticleEffect3D:SetScaleAxis(axis)
	self.ScaleAxis = Vector(axis);
end

function ParticleEffect3D:GetStartScale()
	return self.StartScale;
end

function ParticleEffect3D:SetStartScale(scale)
	self.StartScale = scale;
end

function ParticleEffect3D:GetEndScale()
	return self.EndScale;
end

function ParticleEffect3D:SetEndScale(scale)
	self.EndScale = scale;
end

function ParticleEffect3D:GetScaleFunctionMod()
	return self.ScaleFunctionMod;
end

function ParticleEffect3D:SetScaleFunctionMod(moc)
	self.ScaleFunctionMod = moc;
end

function ParticleEffect3D:SetThinkFunction(func)
	self.ThinkFunction = func;
end

function ParticleEffect3D:Finished()
	return CurTime() > self.SpawnTime + self:GetLifeTime() + self.Delay;
end

function ParticleEffect3D:CleanUp()
	self.Dirty = true;
	self.ModelCache:Remove();
end

setmetatable(ParticleEffect3D, {__call = ParticleEffect3D.New });