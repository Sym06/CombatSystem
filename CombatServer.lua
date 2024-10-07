local rs = game:GetService("ReplicatedStorage")
local combatModule = require(rs.Libs.CombatModule)
local combatEvent = script.Parent.RemoteEvent

combatEvent.OnServerEvent:Connect(function(player, count, damage)
	if player.Character and damage then
		local char = player.Character

		if count == 1 then
			combatModule:hit(char, damage, char["Left Arm"])
		elseif count == 2 then
			combatModule:hit(char, damage, char["Right Arm"])
		elseif count == 3 then
			combatModule:hit(char, damage, char["Left Arm"])
		end
	else
		local char = player.Character
		local arg = count
		
		if arg == "Blocking" then
			combatModule:Block(char)
		elseif arg == "Unblocking" then
			combatModule:Unblock(char)
		end
		
		if arg == "Parry" then
			combatModule:Parry(char)
		elseif arg == "Unparry" then
			combatModule:Unparry(char)
		end
	end

end)

