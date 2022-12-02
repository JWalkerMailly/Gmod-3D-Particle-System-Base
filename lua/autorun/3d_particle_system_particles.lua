-- MOTD --
if (SERVER) then

	timer.Simple(10, function()

		-- Do nothing if the server was informed of the new addon.
		if (file.Exists("3d_particle_system_editor", "DATA")) then return; end

		-- Setup for people who do not have the new editor addon installed.
		file.CreateDir("3d_particle_system_editor/");

		-- Send out message to everyone.
		for k,v in pairs(player.GetAll()) do
			local message = "Update: A new addon was released to aid in the creation of 3D Particles.";
			v:PrintMessage(HUD_PRINTCENTER, message);
			v:PrintMessage(HUD_PRINTTALK, message .. " Link: https://steamcommunity.com/sharedfiles/filedetails/?id=2895831461")
		end
	end);
end

game.Add3DParticles("particles/3d_blood.lua");
game.Add3DParticles("particles/fusion_explosion.lua");