local combatModule = {}

local players = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local HitboxModule = require(rs.Libs.RaycastHitboxV4)
local vfxHandler = rs.Events.VFXEvent
local vfxClients = rs.Events.VFXEventClients
local audios = script.Hit:GetChildren()
local clothAudios = script.Clothes:GetChildren()
local blockAudios = script.Block:GetChildren()
local parryingAudio = script.Parrying
local vulnerableAudio = script.Vulnerable
local usedAudioHit
local usedAudioCloth

local animation = Instance.new("Animation")
animation.AnimationId = 'rbxassetid://14424734804'
local animation2 = Instance.new("Animation")
animation2.AnimationId = 'rbxassetid://14436912328'
local animation3 = Instance.new("Animation")
animation3.AnimationId = 'rbxassetid://14436916723'

function combatModule:hit(character, dmg, bodyPart)
	if players:GetPlayerFromCharacter(character) then
		players:GetPlayerFromCharacter(character).PlayerGui.SprintToggle.Enabled = false
	end
	
	local clothClone = clothAudios[math.random(1, #clothAudios)]:Clone()
	while usedAudioCloth == clothClone.Name do
		clothClone = clothAudios[math.random(1, #clothAudios)]:Clone()
	end
	clothClone.Volume = 0.3
	usedAudioCloth = clothClone.Name
	clothClone.Parent = character.HumanoidRootPart
	clothClone:Play()
	debris:AddItem(clothClone, 1)
	
	if character.Humanoid.WalkSpeed >= 16 then
		character.Humanoid.WalkSpeed = 7
	end
	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	
	local newhitbox = HitboxModule.new(bodyPart)
	newhitbox.Visualizer = true
	newhitbox.RaycastParams = params
	newhitbox:SetPoints(bodyPart, {Vector3.new(0, 1, 0), Vector3.new(0, -1, 0), Vector3.new(0, 0, 0), Vector3.new(-1, 0, 0)})
	
	newhitbox.OnHit:Connect(function(hit, humanoid: Humanoid)
		local char
		if hit.Parent:FindFirstChild("Humanoid") then
			char = hit.Parent
		else
			char = hit.Parent.Parent
		end
		
		if char.Name:match("Horse") then
			local hitClone = audios[math.random(1, #audios)]:Clone()
			while usedAudioHit == hitClone.Name do
				hitClone = audios[math.random(1, #audios)]:Clone()
			end
			usedAudioHit = hitClone.Name
			hitClone.Parent = char.HumanoidRootPart
			
			humanoid:TakeDamage(dmg)
			hitClone:Play()
			debris:AddItem(1, hitClone)
		else
			local isBlocking = char.Bools.IsBlocking
			local iframes = char.Bools.IFrames
			local parrying = char.Bools.IsParrying
			local stunned = char.Bools.Stunned
			local heavyHit = false
			
			if isBlocking.Value then
				local blockingAudio = blockAudios[math.random(1, #blockAudios)]:Clone()
				blockingAudio.Parent = char.HumanoidRootPart
				blockingAudio:Play()
				debris:AddItem(blockingAudio, 1)
			end
			
			if parrying.Value then
				local animator = character.Humanoid:FindFirstChildOfClass("Animator")
				local stunnedAnim = animator:LoadAnimation(animation)
				local parryingAudioClone = parryingAudio:Clone()
				local VulnerableAudioClone = vulnerableAudio:Clone()
				
				parryingAudioClone.Parent = char.HumanoidRootPart
				VulnerableAudioClone.Parent = character.HumanoidRootPart
				parryingAudioClone:Play()
				VulnerableAudioClone:Play()
				debris:AddItem(parryingAudioClone, 1)
				debris:AddItem(VulnerableAudioClone, 3)
				
				if players:GetPlayerFromCharacter(character) then
					vfxHandler:FireClient(players:GetPlayerFromCharacter(character), "Parry On")
				end
				character.Bools.Stunned.Value = true
				character.Bools.Parried.Value = true
				character.Humanoid.WalkSpeed = 0
				stunnedAnim:Play()
				task.delay(2.5, function()
					if not heavyHit then
						character.Bools.Stunned.Value = false
						character.Bools.Parried.Value = false
						character.Humanoid.WalkSpeed = 16
						stunnedAnim:Stop()
						if players:GetPlayerFromCharacter(character) then
							players:GetPlayerFromCharacter(character).PlayerGui.SprintToggle.Enabled = true
							vfxHandler:FireClient(players:GetPlayerFromCharacter(character), "Parry Off")
						end
					end
				end)
			end
			
			
			if char.Bools.Parried.Value then
				heavyHit = true
				
				local animatorCharacter = character.Humanoid:FindFirstChildOfClass("Animator")
				local animatorChar = char.Humanoid:FindFirstChildOfClass("Animator")
				local attackingAnim = animatorCharacter:LoadAnimation(animation2)
				local beingAttackedAnim = animatorChar:LoadAnimation(animation3)
				
				if players:GetPlayerFromCharacter(character) then
					players:GetPlayerFromCharacter(character).PlayerGui.SprintToggle.Enabled = false
				end
				
				character.Humanoid.WalkSpeed = 0
				character.Humanoid.AutoRotate = false
				humanoid.WalkSpeed = 0
				humanoid.AutoRotate = false
				
				character.Bools.Stunned.Value = true
				stunned.Value = true
				
				local weld = Instance.new("WeldConstraint")
				
				char.HumanoidRootPart.CFrame *= CFrame.new(-1, 0, 0)
				if players:GetPlayerFromCharacter(character) then
					vfxHandler:FireClient(players:GetPlayerFromCharacter(character), "Camera Anim", character, char)
				end
				if players:GetPlayerFromCharacter(char) then
					vfxHandler:FireClient(players:GetPlayerFromCharacter(char), "Camera Anim", character, char)
				end
				
				weld.Parent = character
				weld.Part0 = character.HumanoidRootPart
				weld.Part1 = char.HumanoidRootPart
				
				attackingAnim:Play()
				beingAttackedAnim:Play()
				
				
				task.delay(1, function()
					stunned.Value = false
					character.Bools.Stunned.Value = false
					character.Humanoid.WalkSpeed = 16
					character.Humanoid.AutoRotate = true
					humanoid.WalkSpeed = 16
					humanoid.AutoRotate = true
					weld:Destroy()
					if players:GetPlayerFromCharacter(character) then
						players:GetPlayerFromCharacter(character).PlayerGui.SprintToggle.Enabled = true
					end
					heavyHit = false
				end)
			end
			
			
			if not isBlocking.Value and not iframes.Value and not parrying.Value and not heavyHit then
				local hitClone = audios[math.random(1, #audios)]:Clone()
				while usedAudioHit == hitClone.Name do
					hitClone = audios[math.random(1, #audios)]:Clone()
				end
				
				stunned.Value = true
				usedAudioHit = hitClone.Name
				hitClone.Parent = char.HumanoidRootPart
				
				char.HumanoidRootPart:SetNetworkOwner(nil)
				char.HumanoidRootPart.AssemblyLinearVelocity = character.HumanoidRootPart.CFrame.LookVector * 35
				char.HumanoidRootPart:SetNetworkOwner(game:GetService("Players"):GetPlayerFromCharacter(char))
				
				humanoid.WalkSpeed = 2
				vfxClients:FireAllClients(char, "Hit", bodyPart)
				humanoid:TakeDamage(dmg)
				
				hitClone:Play()
				debris:AddItem(hitClone, 1)
				
				task.delay(0.9, function()
					stunned.Value = false
					humanoid.WalkSpeed = 16
					if players:GetPlayerFromCharacter(character) then
						players:GetPlayerFromCharacter(character).PlayerGui.SprintToggle.Enabled = true
					end
				end)
			end
		end
		--newhitbox:HitStop()
	end)
	
	newhitbox:HitStart()
	wait(0.5)
	newhitbox:Destroy()
	
	if not character.Bools.Stunned.Value and not character.Bools.Parried.Value then
		character.Humanoid.WalkSpeed = 16
		if players:GetPlayerFromCharacter(character) then
			players:GetPlayerFromCharacter(character).PlayerGui.SprintToggle.Enabled = true
		end
	end
	
end

function combatModule:Block(char)
	local bools = char.Bools
	
	bools.IsBlocking.Value = true
	if not char.Bools.Stunned.Value and not char.Bools.Parried.Value then
		char.Humanoid.WalkSpeed = 7
		if players:GetPlayerFromCharacter(char) then
			players:GetPlayerFromCharacter(char).PlayerGui.SprintToggle.Enabled = false
		end
	end
end

function combatModule:Unblock(char)
	local bools = char.Bools

	bools.IsBlocking.Value = false
	if not char.Bools.Stunned.Value and not char.Bools.Parried.Value then
		char.Humanoid.WalkSpeed = 16
		if players:GetPlayerFromCharacter(char) then
			players:GetPlayerFromCharacter(char).PlayerGui.SprintToggle.Enabled = true
		end
	end
end

function combatModule:Parry(char)
	local bools = char.Bools
	local clothClone = clothAudios[math.random(1, #clothAudios)]:Clone()
	clothClone.Volume = 0.3
	clothClone.Parent = char.HumanoidRootPart
	clothClone:Play()
	debris:AddItem(clothClone, 1)

	bools.IsParrying.Value = true
	if not char.Bools.Stunned.Value and not char.Bools.Parried.Value then
		char.Humanoid.WalkSpeed = 7
		if players:GetPlayerFromCharacter(char) then
			players:GetPlayerFromCharacter(char).PlayerGui.SprintToggle.Enabled = false
		end
	end
end

function combatModule:Unparry(char)
	local bools = char.Bools

	bools.IsParrying.Value = false
	if not char.Bools.Stunned.Value and not char.Bools.Parried.Value then
		char.Humanoid.WalkSpeed = 16
		if players:GetPlayerFromCharacter(char) then
			players:GetPlayerFromCharacter(char).PlayerGui.SprintToggle.Enabled = true
		end
	end
end

return combatModule