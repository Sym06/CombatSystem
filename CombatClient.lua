local player = game.Players.LocalPlayer
local char = workspace:WaitForChild(player.Name)
local cam = workspace.CurrentCamera
local mouse = player:GetMouse()
local humanoid: Humanoid = char:WaitForChild("Humanoid")
local tool = script.Parent
local combatEvent = tool:WaitForChild('RemoteEvent')
local tweenservice = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cd = 0.55
local count = 0
local debounce = false
local damage = 10
local equippedBool = false
local parryingBool = false

local blocking = char.Bools.IsBlocking
local parrying = char.Bools.IsParrying
local stunned = char.Bools.Stunned
local parried = char.Bools.Parried

local animation1 = Instance.new("Animation")
animation1.AnimationId = 'rbxassetid://14410557910'
local animation2 = Instance.new("Animation")
animation2.AnimationId = 'rbxassetid://14410561237'
local animation3 = Instance.new("Animation")
animation3.AnimationId = 'rbxassetid://14410564673'
local animation4 = Instance.new("Animation")
animation4.AnimationId = 'rbxassetid://14410532000'
local animation5 = Instance.new("Animation")
animation5.AnimationId = 'rbxassetid://14410551103'
local animation6 = Instance.new("Animation")
animation6.AnimationId = 'rbxassetid://14424729763'
local animation7 = Instance.new("Animation")
animation7.AnimationId = 'rbxassetid://14424489981'
local animation8 = Instance.new("Animation")
animation8.AnimationId = 'rbxassetid://14424734804'

local animator = humanoid:WaitForChild("Animator")

local hit1 = animator:LoadAnimation(animation1)
local hit2 = animator:LoadAnimation(animation2)
local hit3 = animator:LoadAnimation(animation3)

local equipped = animator:LoadAnimation(animation4)
local idle = animator:LoadAnimation(animation5)

local blockingAnim = animator:LoadAnimation(animation6)
local parryingAnim = animator:LoadAnimation(animation7)
local stunnedAnim = animator:LoadAnimation(animation8)

local lastTimeClicked = tick()

tool.Equipped:Connect(function()
	if not equipped.IsPlaying then
		equipped:Play()
	end
	if not idle.IsPlaying then
		idle:Play()
	end
	equippedBool = true
end)

tool.Activated:Connect(function()
	if blocking.Value or parrying.Value or stunned.Value or parried.Value then return end
	
	if debounce == false then
		debounce = true
		if tick() - lastTimeClicked > 2 then
			count = 0
		end
		lastTimeClicked = tick()
		count += 1
		if count == 1 then
			hit1:Play()
		elseif count == 2 then
			hit2:Play()
		elseif count == 3 then
			hit3:Play()
		end
		combatEvent:FireServer(count, damage)
		if count == 3 then
			count = 0
			wait(0.15)
		end
		wait(cd)
		debounce = false
	end
	
end)

tool.Unequipped:Connect(function()
	if equipped.IsPlaying then
		equipped:Stop()
	end
	if idle.IsPlaying then
		idle:Stop()
	end
	equippedBool = false
end)

mouse.Button2Down:Connect(function()
	if not equippedBool or stunned.Value or parried.Value or parrying.Value then return end
	combatEvent:FireServer("Blocking")
	blockingAnim:Play()
end)

mouse.Button2Up:Connect(function()
	blockingAnim:Stop()
	combatEvent:FireServer("Unblocking")
end)

uis.InputBegan:Connect(function(key, istyping)
	if istyping then return end
	if blocking.Value or parrying.Value or parried.Value or not equippedBool or parryingBool then return end
	
	if key.KeyCode == Enum.KeyCode.F then
		parryingBool = true
		combatEvent:FireServer("Parry")
		parryingAnim:Play()
		wait(0.5)
		combatEvent:FireServer("Unparry")
		task.delay(2, function()
			parryingBool = false
		end)
	end
end)