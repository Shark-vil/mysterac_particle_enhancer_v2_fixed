util.AddNetworkString('MysterAC_Particle_PlayerSpawnInit')
--
local util_TraceLine = util.TraceLine
local ParticleEffect = ParticleEffect
local IsValid = IsValid
local Vector = Vector
local Angle = Angle
local pairs = pairs
local math_random = math.random
local CurTime = CurTime
local player_GetCount = player.GetCount
--
local TRACKING_EXPLOSIVES_GRENADE = {}
local TRACKING_EXPLOSIVES_RPGS = {}
local TRACKING_EXPLOSIVES_AR2 = {}
local grenade_explosion_particle = 'AC_grenade_explosion'
local grenade_explosion_air_particle = 'AC_grenade_explosion_air'
local rpg_explosion_particle = 'AC_rpg_explosion'
local rpg_explosion_air_particle = 'AC_rpg_explosion_air'
local grenade_ar2_explosion_particle = 'AC_grenade_ar2_explosion'
local grenade_ar2_explosion_air_particle = 'AC_grenade_ar2_explosion_air'
local vector_0_0_60 = Vector(0, 0, 60)
local MASK_SOLID_BRUSHONLY = MASK_SOLID_BRUSHONLY
--

local function CreateParticleEffect(pos, elapsed_time, particle, particle_in_air)
	local tr = util_TraceLine({
		start = pos,
		endpos = pos - vector_0_0_60,
		mask = MASK_SOLID_BRUSHONLY
	})

	if tr.HitWorld then
		ParticleEffect(particle, pos, Angle(0, math_random(0, 360), 0))
	else
		ParticleEffect(particle_in_air, pos, Angle(0, math_random(0, 360), 0))
	end
end

local function CreateGrenadeExplosionEffect(pos, elapsed_time, particle, particle_in_air)
	CreateParticleEffect(pos, elapsed_time, grenade_explosion_particle, grenade_explosion_air_particle)
end

local function CreateRPGExplosionEffect(pos, elapsed_time)
	CreateParticleEffect(pos, elapsed_time, rpg_explosion_particle, rpg_explosion_air_particle)
end

local function CreateAR2ExplosionEffect(pos, elapsed_time)
	CreateParticleEffect(pos, elapsed_time, grenade_ar2_explosion_particle, grenade_ar2_explosion_air_particle)
end

local function TrackingEntity(ent, tbl)
	if not IsValid(ent) then return false end
	if not tbl[ent] then
		tbl[ent] = {ent:GetPos(), CurTime()}
	else
		tbl[ent][1] = ent:GetPos()
	end
	return true
end

local function ExplosionTrackingEntity(tbl, ent, data, invoke)
	if IsValid(ent) then return end
	local pos, elapsed_time = data[1], CurTime() - data[2]
	invoke(pos, elapsed_time)
	tbl[ent] = nil
end

local function CheckForGrenades()
	for ent, data in pairs(TRACKING_EXPLOSIVES_GRENADE) do
		if not TrackingEntity(ent, TRACKING_EXPLOSIVES_GRENADE) then
			ExplosionTrackingEntity(TRACKING_EXPLOSIVES_GRENADE, ent, data, CreateGrenadeExplosionEffect)
		end
	end
end

local function CheckForRPGS()
	for ent, data in pairs(TRACKING_EXPLOSIVES_RPGS) do
		if not TrackingEntity(ent, TRACKING_EXPLOSIVES_RPGS) then
			ExplosionTrackingEntity(TRACKING_EXPLOSIVES_RPGS, ent, data, CreateRPGExplosionEffect)
		end
	end
end

local function CheckForAR2Grenades()
	for ent, data in pairs(TRACKING_EXPLOSIVES_AR2) do
		if not TrackingEntity(ent, TRACKING_EXPLOSIVES_AR2) then
			ExplosionTrackingEntity(TRACKING_EXPLOSIVES_AR2, ent, data, CreateAR2ExplosionEffect)
		end
	end
end

if not file.Exists('autorun/gexplo_autorun.lua', 'LUA') then
	hook.Add('Think', 'MysterAC_ParticleEntityChecker', function()
		CheckForGrenades()
		CheckForRPGS()
		CheckForAR2Grenades()
	end)

	hook.Add('OnEntityCreated', 'MysterAC_TrackingEntityCreated', function(ent)
		if player_GetCount() == 0 then return end

		local entity_class = ent:GetClass()
		if entity_class == 'env_explosion' or entity_class == 'npc_grenade_frag' then
			TrackingEntity(ent, TRACKING_EXPLOSIVES_GRENADE)
		elseif entity_class == 'rpg_missile' then
			TrackingEntity(ent, TRACKING_EXPLOSIVES_RPGS)
		elseif entity_class == 'grenade_ar2' then
			TrackingEntity(ent, TRACKING_EXPLOSIVES_AR2)
		end
	end)

	hook.Add('PlayerInitialSpawn', 'MysterAC_ParticleEnhancer_InitNewImpactEffectCvar', function(ply)
		local hook_name = 'MysterAC_ParticleEnhancer_SetupMovePlayer_' .. ply:UserID()
		hook.Add('SetupMove', hook_name, function(mv_ply, mv, cmd)
			if not IsValid(ply) then
				hook.Remove('SetupMove', hook_name)
			elseif IsValid(mv_ply) and ply == mv_ply and not cmd:IsForced() then
				hook.Remove('SetupMove', hook_name)
				net.Start('MysterAC_Particle_PlayerSpawnInit')
				net.Send(mv_ply)
			end
		end)
	end)
end