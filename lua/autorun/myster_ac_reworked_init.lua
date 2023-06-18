if SERVER then
	AddCSLuaFile('mysteracpe_v2_reworked/ac_precache.lua')
	AddCSLuaFile('mysteracpe_v2_reworked/client/client_impact_enabler.lua')
	include('mysteracpe_v2_reworked/ac_precache.lua')
	include('mysteracpe_v2_reworked/server/ac_particles_remade.lua')
else
	include('mysteracpe_v2_reworked/ac_precache.lua')
	include('mysteracpe_v2_reworked/client/client_impact_enabler.lua')
end