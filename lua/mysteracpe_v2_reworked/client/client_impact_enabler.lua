net.Receive('MysterAC_Particle_PlayerSpawnInit', function()
	if GetConVar('cl_new_impact_effects'):GetInt() == 1 then return end
	RunConsoleCommand('cl_new_impact_effects', '1')
	MsgN('[MysterAC Particle Enhancer] The "cl_new_impact_effects" parameter was forcibly changed to "1".')
end)