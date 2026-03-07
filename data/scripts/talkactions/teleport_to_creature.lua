local function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local x, y, z = param:match("^%s*(-?%d+)%s*,%s*(-?%d+)%s*,%s*(-?%d+)%s*$")
	if x and y and z then
		local position = Position(tonumber(x), tonumber(y), tonumber(z))
		player:teleportTo(position)
		return false
	end

	local target = Creature(param)
	if target then
		player:teleportTo(target:getPosition())
	else
		player:sendCancelMessage("Creature not found.")
	end
	return false
end

-- Revscript registrations
local teleport_to_creature = TalkAction("/goto")
function teleport_to_creature.onSay(player, words, param)
    return onSay(player, words, param)
end
teleport_to_creature:separator(" ")
teleport_to_creature:register()
