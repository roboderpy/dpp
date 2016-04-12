
local EmptyVector = Vector()

function DPP.CheckDroppedEntity(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('prevent_player_stuck') then return end
	if ent:IsPlayer() then return end
	
	for k, v in pairs(player.GetAll()) do
		if v == ply then continue end
		if v:InVehicle() then continue end
		if DPP.IsPlayerInEntity(v, ent) then
			DPP.Notify(ply, 'Your prop is stuck in other player')
			DPP.SetGhosted(ent, true)
			break
		end
	end
end

local function PhysgunDrop2(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if ent:IsPlayer() or ent:IsNPC() then return end
	if not DPP.GetConVar('prevent_prop_throw') then return end
	
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(Vector(0, 0, 0))
	end
end

local function EntityTakeDamage(ent, dmg)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('apropkill_damage') then return end
	if not ent:IsPlayer() then return end
	
	local attacker = dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()
	
	if DPP.GetConVar('apropkill_vehicle') then
		if IsValid(attacker) and attacker:IsVehicle() then
			if attacker:GetSolid() ~= SOLID_NONE and (attacker:GetCollisionGroup() == COLLISION_GROUP_NONE or attacker:GetCollisionGroup() == COLLISION_GROUP_VEHICLE) then
				attacker:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			end
		end
		
		if IsValid(inflictor) and inflictor:IsVehicle() then
			if inflictor:GetSolid() ~= SOLID_NONE and (inflictor:GetCollisionGroup() == COLLISION_GROUP_NONE or inflictor:GetCollisionGroup() == COLLISION_GROUP_VEHICLE) then
				inflictor:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			end
		end
	end
	
	local cond = dmg:GetDamageType() == DMG_CRUSH or 
		(dmg:GetDamageType() == DMG_VEHICLE and DPP.GetConVar('apropkill_damage_vehicle')) or
		(IsValid(attacker) and attacker:GetClass() == 'prop_physics') or
		(IsValid(inflictor) and inflictor:GetClass() == 'prop_physics')
	
	if cond then
		dmg:SetDamage(0)
		dmg:SetDamageForce(EmptyVector)
		dmg:SetDamageType(DMG_GENERIC)
	end
end

local function PlayerSpawnedVehicle(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('apropkill_vehicle') then return end
	
	if ent:GetSolid() == SOLID_NONE then return end
	
	if ent:GetCollisionGroup() == COLLISION_GROUP_VEHICLE or ent:GetCollisionGroup() == COLLISION_GROUP_NONE then
		ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	end
end

local function PlayerEnteredVehicle(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('apropkill_vehicle') then return end
	
	if ent:GetSolid() == SOLID_NONE then return end
	
	if ent:GetCollisionGroup() == COLLISION_GROUP_VEHICLE or ent:GetCollisionGroup() == COLLISION_GROUP_NONE then
		ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	end
end

local HoldingEntities = {}

local function PhysgunPickup(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('apropkill_nopush') then return end
	if ent:IsPlayer() or ent:IsNPC() then return end
	
	if HoldingEntities[ent] then return end --Already holding
	HoldingEntities[ent] = ent:GetCollisionGroup()
	ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
end

local function PhysgunDrop(ply, ent)
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('apropkill_nopush') then return end
	
	if not IsValid(ent) then return end --Dropping deleted entity
	if ent:IsPlayer() or ent:IsNPC() then return end
	if not HoldingEntities[ent] then return end
	ent:SetCollisionGroup(HoldingEntities[ent])
	HoldingEntities[ent] = nil
end

local function Think()
	if not DPP.GetConVar('apropkill_enable') then return end
	if not DPP.GetConVar('apropkill_nopush') then return end
	
	for ent, collision in pairs(HoldingEntities) do
		if not IsValid(ent) then
			HoldingEntities[ent] = nil
			continue
		end
		
		if ent:GetCollisionGroup() ~= COLLISION_GROUP_PASSABLE_DOOR then
			ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		end
	end
end

hook.Add('EntityTakeDamage', '!DPP.APropKill', EntityTakeDamage, -1)
hook.Add('Think', 'DPP.APropKill', Think)
hook.Add('PhysgunDrop', 'DPP.APropKill', PhysgunDrop)
hook.Add('PhysgunPickup', 'DPP.APropKill', PhysgunPickup)
hook.Add('PlayerSpawnedVehicle', 'DPP.APropKill', PlayerSpawnedVehicle)
hook.Add('PlayerEnteredVehicle', 'DPP.APropKill', PlayerEnteredVehicle)

hook.Add('PhysgunDrop', 'DPP.PreventPropThrow', PhysgunDrop2)
hook.Add('PhysgunDrop', 'DPP.PreventPlayerStuck', DPP.CheckDroppedEntity)
