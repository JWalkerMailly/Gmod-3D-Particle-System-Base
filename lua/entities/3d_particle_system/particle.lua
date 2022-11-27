
ParticleEffect3D = {};
ParticleEffect3D.__index = ParticleEffect3D;

function ParticleEffect3D:New(model, system, config)

	-- Setup base object.
	local object = {};
	object.Dirty = false;
	object.System = system;
	object.SpawnTime = CurTime();
	object.ThinkFunction = nil;

	-- Setup base properties.
	object.Color = Color(255, 255, 255);
	object.Alpha = 255;
	object.Scale = 1;
	object.Rotation = 0;

	-- Setup default configuration.
	if (config != nil) then
		object.Config = config;
	else
		object.Config = {

			Model = model,
			Skin = nil,
			BodyGroups = nil,
			Material = nil,

			Pos = nil,
			LocalPos = nil,
			Angles = Angle(0, 0, 0),

			Delay = 0,
			LifeTime = nil,
			Looping = false,

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
			ScaleFunctionMod = 0
		};
	end

	-- Prepare model for particle rendering.
	util.PrecacheModel(object.Config.Model);
	object.ModelCache = ClientsideModel(object.Config.Model);
	object.ModelCache:SetNoDraw(true);

	-- Create object from metadata.
	setmetatable(object, ParticleEffect3D);
	system:Add(object);
	return object;
end

function ParticleEffect3D:GetModel()
	return self.Config.Model;
end

function ParticleEffect3D:GetSkin()
	return self.Config.Skin;
end

function ParticleEffect3D:SetSkin(skin)
	self.Config.Skin = skin;
	self.ModelCache:SetSkin(skin);
end

function ParticleEffect3D:GetBodyGroups()
	return self.Config.BodyGroups;
end

function ParticleEffect3D:SetBodyGroups(bodyGroups)
	self.Config.BodyGroups = bodyGroups;
	self.ModelCache:SetBodyGroups(bodyGroups);
end

function ParticleEffect3D:GetMaterial()
	return self.Config.Material;
end

function ParticleEffect3D:SetMaterial(texture)
	self.Config.Material = Material(texture);
end

function ParticleEffect3D:LerpColor(t, from, to)
	return Color(
		Lerp(t, from.r, to.r),
		Lerp(t, from.g, to.g),
		Lerp(t, from.b, to.b),
		Lerp(t, from.a, to.a)
	);
end

function ParticleEffect3D:Draw()

	if (self.ModelCache == NULL || self.ModelCache == nil || self.Dirty) then
		return;
	end

	-- Particle is finished, reset spawn time.
	if (self.Config.Looping && self:Finished()) then
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

	local delay = self.Config.Delay;
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
	if (self.Config.StartColor != nil) then
		self.Color = self.Config.StartColor;
	end

	-- Setup alpha.
	if (self.Config.StartAlpha != nil) then
		self.Alpha = self.Config.StartAlpha;
	end

	-- Setup scale.
	if (self.Config.StartScale != nil) then
		self.Scale = self.Config.StartScale;
	end

	-- Setup roll.
	if (self.Config.StartRotation != nil) then
		self.Rotation = self.Config.StartRotation;
	end

	-- Patricle effect color parameters.
	if (self.Config.EndColor != nil) then
		self.Color = self:LerpColor(
			self.Config.ColorFunction(delta * self.Config.ColorFunctionMod),
			self.Config.StartColor,
			self.Config.EndColor);
	end

	-- Particle effect alpha parameters.
	if (self.Config.EndAlpha != nil) then
		self.Alpha = Lerp(
			self.Config.AlphaFunction(delta * self.Config.AlphaFunctionMod),
			self.Config.StartAlpha,
			self.Config.EndAlpha);
	end

	-- Particle effect size parameters.
	if (self.Config.EndScale != nil) then
		self.Scale = Lerp(
			self.Config.ScaleFunction(delta * self.Config.ScaleFunctionMod),
			self.Config.StartScale,
			self.Config.EndScale);
	end

	-- Particle effect rotation parameters.
	if (self.Config.EndRotation != nil) then
		self.Rotation = Lerp(
			self.Config.RotationFunction(delta * self.Config.RotationFunctionMod),
			self.Config.StartRotation,
			self.Config.EndRotation);
	end

	-- Compute rotation based on the desired behavior.
	local angles = self.Config.Angles;
	if (self.Config.RotateAroundNormal) then
		angles:RotateAroundAxis(self.Config.RotationNormal, (self.Config.EndRotation || 0) * frametime);
	else
		local normal = self.Config.RotationNormal;
		angles = Angle(normal[1], normal[2], normal[3]) * self.Rotation;
	end

	-- Used for axis scaling.
	local matScale = Matrix();
	local initialScale = Vector(1, 1, 1) * self.Config.StartScale;
	if (self.Config.ScaleAxis != Vector(0, 0, 0)) then
		matScale:Scale(initialScale + self.Config.ScaleAxis * self.Scale);
	else
		matScale:Scale(Vector(1, 1, 1) * self.Scale);
	end

	-- Handle parenting;
	local parent = self.System:GetParent();
	local renderingPos = self:GetPos() + self:GetLocalPos();
	local renderingAngles = angles;
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
	render.MaterialOverride(self.Config.Material);
	render.Model({
		model = self.Config.Model,
		pos = renderingPos,
		angle = renderingAngles
	}, self.ModelCache);
	render.MaterialOverride(nil);
	render.SetColorModulation(1, 1, 1);
	render.SetBlend(1);
	self.FrameTime = CurTime();
end

function ParticleEffect3D:GetLooping()
	return self.Config.Looping;
end

function ParticleEffect3D:SetLooping(loop)
	self.Config.Looping = loop;
end

function ParticleEffect3D:GetPos()

	if (self.Config.Pos == nil) then

		-- No position and no parent supplied, return the system's position for rendering.
		local parent = self.System:GetParent();
		if (parent == NULL || parent == nil || !parent:IsValid()) then
			return self.System:GetPos();
		end

		-- No position supplied, parent must be supplied, return local origin.
		return Vector(0, 0, 0);
	end

	return self.Config.Pos;
end

function ParticleEffect3D:SetPos(pos)
	self.Config.Pos = Vector(pos);
end

function ParticleEffect3D:GetLocalPos()

	if (self.Config.LocalPos == nil) then
		return Vector(0, 0, 0);
	end

	return self.Config.LocalPos;
end

function ParticleEffect3D:SetLocalPos(pos)
	self.Config.LocalPos = Vector(pos);
end

function ParticleEffect3D:GetAngles()
	return self.Config.Angles;
end

function ParticleEffect3D:SetAngles(ang)
	self.Config.Angles = Angle(ang);
end

function ParticleEffect3D:GetSpawnTime()
	return self.SpawnTime;
end

function ParticleEffect3D:SetSpawnTime(time)
	self.SpawnTime = time;
end

function ParticleEffect3D:GetDelay()
	return self.Config.Delay;
end

function ParticleEffect3D:SetDelay(time)
	self.Config.Delay = time;
end

function ParticleEffect3D:GetLifeTime()

	if (self.Config.LifeTime == nil) then
		local systemLifeTime = self.System:GetLifeTime();
		return math.Clamp(systemLifeTime - self.Delay, FrameTime(), systemLifeTime);
	end

	return self.Config.LifeTime;
end

function ParticleEffect3D:SetLifeTime(time)
	self.Config.LifeTime = time;
end

function ParticleEffect3D:GetRotationFunction()
	return self.Config.RotationFunction;
end

function ParticleEffect3D:SetRotationFunction(name)
	self.Config.RotationFunction = name;
end

function ParticleEffect3D:GetRotationNormal()
	return self.Config.RotationNormal;
end

function ParticleEffect3D:SetRotationNormal(normal)
	self.Config.RotationNormal = Vector(normal);
end

function ParticleEffect3D:GetRotateAroundNormal()
	return self.Config.RotateAroundNormal;
end

function ParticleEffect3D:SetRotateAroundNormal(rotate)
	self.Config.RotateAroundNormal = rotate;
end

function ParticleEffect3D:GetStartRotation()
	return self.Config.StartRotation;
end

function ParticleEffect3D:SetStartRotation(rotation)
	self.Config.StartRotation = rotation;
end

function ParticleEffect3D:GetEndRotation()
	return self.Config.EndRotation;
end

function ParticleEffect3D:SetEndRotation(rotation)
	self.Config.EndRotation = rotation;
end

function ParticleEffect3D:GetRotationFunctionMod()
	return self.Config.RotationFunctionMod;
end

function ParticleEffect3D:SetRotationFunctionMod(mod)
	self.Config.RotationFunctionMod = mod;
end

function ParticleEffect3D:GetColorFunction()
	return self.Config.ColorFunction;
end

function ParticleEffect3D:SetColorFunction(name)
	self.Config.ColorFunction = name;
end

function ParticleEffect3D:GetStartColor()
	return self.Config.StartColor;
end

function ParticleEffect3D:SetStartColor(col)
	self.Config.StartColor = Color(col.r, col.g, col.b);
end

function ParticleEffect3D:GetEndColor()
	return self.Config.EndColor;
end

function ParticleEffect3D:SetEndColor(col)
	self.Config.EndColor = Color(col.r, col.g, col.b);
end

function ParticleEffect3D:GetColorFunctionMod()
	return self.Config.ColorFunctionMod;
end

function ParticleEffect3D:SetColorFunctionMod(mod)
	self.Config.ColorFunctionMod = mod;
end

function ParticleEffect3D:GetAlphaFunction()
	return self.Config.AlphaFunction;
end

function ParticleEffect3D:SetAlphaFunction(name)
	self.Config.AlphaFunction = name;
end

function ParticleEffect3D:GetStartAlpha()
	return self.Config.StartAlpha;
end

function ParticleEffect3D:SetStartAlpha(alpha)
	self.Config.StartAlpha = alpha;
end

function ParticleEffect3D:GetEndAlpha()
	return self.Config.EndAlpha;
end

function ParticleEffect3D:SetEndAlpha(alpha)
	self.Config.EndAlpha = alpha;
end

function ParticleEffect3D:GetAlphaFunctionMod()
	return self.Config.AlphaFunctionMod;
end

function ParticleEffect3D:SetAlphaFunctionMod(mod)
	self.Config.AlphaFunctionMod = mod;
end

function ParticleEffect3D:GetScaleFunction()
	return self.Config.ScaleFunction;
end

function ParticleEffect3D:SetScaleFunction(name)
	self.Config.ScaleFunction = name;
end

function ParticleEffect3D:GetScaleAxis()
	return self.Config.ScaleAxis;
end

function ParticleEffect3D:SetScaleAxis(axis)
	self.Config.ScaleAxis = Vector(axis);
end

function ParticleEffect3D:GetStartScale()
	return self.Config.StartScale;
end

function ParticleEffect3D:SetStartScale(scale)
	self.Config.StartScale = scale;
end

function ParticleEffect3D:GetEndScale()
	return self.Config.EndScale;
end

function ParticleEffect3D:SetEndScale(scale)
	self.Config.EndScale = scale;
end

function ParticleEffect3D:GetScaleFunctionMod()
	return self.Config.ScaleFunctionMod;
end

function ParticleEffect3D:SetScaleFunctionMod(moc)
	self.Config.ScaleFunctionMod = moc;
end

function ParticleEffect3D:SetThinkFunction(func)
	self.ThinkFunction = func;
end

function ParticleEffect3D:Finished()
	return CurTime() > self.SpawnTime + self:GetLifeTime() + self.Config.Delay;
end

function ParticleEffect3D:CleanUp()
	self.Dirty = true;
	self.ModelCache:Remove();
end

setmetatable(ParticleEffect3D, {__call = ParticleEffect3D.New });