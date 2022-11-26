# 3D Particle System Base

### Description
Lua base used to create 3D particle systems using models. The system will create ClientsideModels inside a single entity.

### Setup
Test systems are included as reference, they can be found in *lua/entities/*. Each particle system is its own entity. Here is how to create a system from scratch:

#### Folder Structure
In your addons folder, create an *entities* folder in *lua* if not already present. In entities, add a folder for your particle system:
```
your_addon/lua/entities/your_particle_system
```

#### shared.lua
```lua

if (SERVER) then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
end

DEFINE_BASECLASS("3d_particle_system");

ENT.RenderGroup 	= RENDERGROUP_BOTH;
ENT.LifeTime 		= 0; -- NOTE: This variable is important, it represents the lifetime of your system. It should be longer than any of the particles you will be adding in InitializeParticles. You must take into account Delay.

```

#### init.lua
```lua

AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

include("shared.lua");

```

#### cl_Init.lua
```lua

include("shared.lua");

function ENT:InitializeParticles()
	-- Create your particles here.
end

function ENT:UpdateParticles()
	-- Update your particles here. (Optional)
	-- This is primarily used to animate particles individually.
	-- Particles are stored in: self.Particles.
end

```

#### Adding particles to InitializeParticles
```lua

function ENT:InitializeParticles()

	-- Test particle, as found in 3d_particle_test. The second parameter (self) will automatically add the effect to the system's Particles array.
	local effect = ParticleEffect3D:New("models/hunter/misc/shell2x2.mdl", self);
	effect:SetMaterial("Models/effects/comball_sphere");
	effect:SetPos(self:GetPos());
	effect:SetLifeTime(0.6);
	effect:SetRotationNormal(Vector(1, 1, 1));
	effect:SetStartRotation(0);
	effect:SetEndRotation(-90);
	effect:SetRotationFunctionMod(2);
	effect:SetStartColor(Color(255, 255, 255));
	effect:SetEndColor(Color(51, 61, 227));
	effect:SetColorFunctionMod(1);
	effect:SetStartAlpha(0);
	effect:SetEndAlpha(255);
	effect:SetAlphaFunctionMod(3);
	effect:SetStartScale(1.2);
	effect:SetEndScale(1.3);
	effect:SetScaleFunctionMod(2.25);
end

```

#### Using your particle system

To use your particle system in your addon:
```lua

local particleEffect = ents.Create("your_particle_system");
particleEffect:SetPos(some_position);
particleEffect:Spawn();

```

### 3d_particle_system Properties & Callbacks
Here is a list of properties available on the system entity. Each property has its own Getter/Setter.
| Property | Type | Usage |
|--|--|--|
| LifeTime | Float | Defines the lifetime of the system. This is mainly used for dynamic lifetimes. If your system is static, you should refer to the example at the top of this readme and use the *self.LifeTime* property instead. If your system is dynamic and you wish for your particles to inherit their system's LifeTime, simply avoid using SetLifeTime on your particles in InitializeParticles.
The *3d_particle_system* is a regular entity and to that effect, any base entity functions can be used on it. Here is a list of custom callbacks available for you to override in your systems.
| Function | Realm | Usage |
|--|--|--|
| OnDestroy | Shared | Callback when the particle system dies. |

### ParticleEffect3D Properties
Here is a list of all available properties for animating a particle effect. Please note that all animation properties are reliant on LifeTime. LifeTime is used to compute a delta [0..1] to be used as interpolation for the duration of the effect. Each property has its own Getter/Setter.
| Property | Type | Usage |
|--|--|--|
| Looping | Bool | *Optional*: Loop particle or not. This is still dependent on the lifetime of the overall system. If you wish for your system to loop until stopped manually, set a large lifetime on the system and call *Destroy()* when ready to remove manually. |
| Material | String | *Optional*: The material override to be applied on the model. This field is optional if your model already has a material applied. |
| Skin | Integer | Sets the skin of the model being used for the particle. |
| BodyGroups | String | Sets the bodygroups of the model being used for the particle. Refer to https://wiki.facepunch.com/gmod/Entity:SetBodyGroups for how to use. |
| Pos | Vector | **Mandatory**: Position of the effect. |
| Angles | Angle | *Optional*: The angle of the effect. If unsure set Angle(0, 0, 0) |
| Delay | Float | *Optional*: Delay in seconds before spawning the effect. |
| LifeTime | Float | **Mandatory**: The duration of the effect in seconds. |
| RotationFunction | Function | *Optional*: The function to be used on the animation delta for interpolating the effect's rotation. Example: "math.sin". |
| RotationNormal | Vector | *Optional*: Specifies the "up" direction for the effect. This is used to influence the way the final result will rotate. |
| StartRotation | Float | *Optional*: Starting rotation in degrees. |
| RotateAroundNormal | Bool | *Optional*: Set to true to make the particle effect spin around its "up" axis. If this is used in conjunction with RotationNormal, make sure that you initially use SetAngles on your particle effect to orient it towards your RotationNormal. |
| EndRotation | Float | *Optional*: Target rotation in degrees. |
| RotationFunctionMod | Float | *Optional*: Multiplier influencing the animation rate of the rotation. |
| ColorFunction | Function | *Optional*: The function to be used on the animation delta for interpolating the effect's color. Example: "math.sin". |
| StartColor | Color | *Optional*: The starting color of the effect. |
| EndColor | Color | *Optional*: The target color of the effect. |
| ColorFunctionMod | Float | *Optional*: Multiplier influencing the animation rate of the color. |
| AlphaFunction | Function | *Optional*: The function to be used on the animation delta for interpolating the effect's alpha. Example: "math.sin". |
| StartAlpha | Float | **Mandatory**: The starting alpha of the effect. |
| EndAlpha | Float | *Optional*: The target alpha of the effect. |
| AlphaFunctionMod | Float | *Optional*: Multiplier influencing the animation rate of the alpha. |
| ScaleFunction | Function | *Optional*: The function to be used on the animation delta for interpolating the effect's scale. Example: "math.sin". |
| ScaleAxis | Vector | *Optional* Used to influence axis scaling. StartScale will also be added onto each axis.
| StartScale | Float | **Mandatory**: The starting scale of the effect. |
| EndScale | Float | *Optional*: The target scale of the effect. |
| ScaleFunctionMod | Float | *Optional*: Multiplier influencing the animation rate of the scale. |
| ThinkFunction | Function | *Optional*: Function used to control the behavior of the particle. Signature is of the form *function(particle)* where particle is your instance. |