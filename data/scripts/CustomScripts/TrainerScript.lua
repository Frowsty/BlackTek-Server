local TRAINER_ZONE_ID = 1
local TRAINER_NAME = "Training Monk"
local trainerMonksByPlayerGuid = {}

local function trainerInstanceId(player)
  return player:getGuid()
end

local function positionHasCustomZone(position, zoneId)
  local getZones = position.getZones or position["getZones()"]
  if not getZones then
    return false
  end

  local zones = getZones(position)
  if type(zones) ~= "table" then
    return false
  end

  for _, id in ipairs(zones) do
    if id == zoneId then
      return true
    end
  end
  return false
end

local function clearTrainerMonks(playerGuid)
	local monks = trainerMonksByPlayerGuid[playerGuid]
	if not monks then
		return
	end

	for _, monk in ipairs(monks) do
		if monk and not monk:isRemoved() then
			monk:remove()
		end
	end

	trainerMonksByPlayerGuid[playerGuid] = nil
end

local function spawnTrainerMonks(player)
	local playerGuid = player:getGuid()
	clearTrainerMonks(playerGuid)

	local pos = player:getPosition()
	local spawnPositions = {
		Position(pos.x - 1, pos.y - 1, pos.z), -- north-west
		Position(pos.x + 1, pos.y - 1, pos.z), -- north-east
	}

	local spawned = {}
	for _, spawnPos in ipairs(spawnPositions) do
		local monk = Game.createMonster(TRAINER_NAME, spawnPos, false, true)
		if monk then
			monk:setInstanceId(player:getInstanceId())
			spawned[#spawned + 1] = monk
		end
	end

	trainerMonksByPlayerGuid[playerGuid] = spawned
end

local ec = EventCallback

ec.onEnterZone = function(creature, newZone, newZoneId)
  local player = Player(creature)
  if not player then
    return
  end

  if newZoneId == TRAINER_ZONE_ID then
    if player:getInstanceId() == 0 then
      player:setInstanceId(trainerInstanceId(player))
      print("Set instance id: " .. tostring(player:getInstanceId()))
      spawnTrainerMonks(player)
    end
    return
  end
end
ec:register()

ec.onExitZone = function(creature, oldZone, oldZoneId)
  local player = Player(creature)
  if not player then
    return
  end 

  if oldZoneId == TRAINER_ZONE_ID then
    if player:getInstanceId() == trainerInstanceId(player) then
      clearTrainerMonks(player:getGuid())
      player:setInstanceId(0)
    end
    return
  end
end
ec:register()
