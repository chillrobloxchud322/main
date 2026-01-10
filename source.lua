local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Debris = game:GetService("Debris")

local function BindCooldownToMove(move,Callback)
	local cooldown = move:GetAttributeChangedSignal("COOLDOWN"):Connect(function()
		if move:GetAttribute("COOLDOWN") == 1 then
			return Callback()
		end
	end)
end
ESP_TABLE = {}


local Target_Anims = {
    ["rbxassetid://1461128166"] = {},
    ["rbxassetid://1461128859"] = {},
    ["rbxassetid://1461136273"] = {},
    ["rbxassetid://1461136875"] = {},
    ["rbxassetid://1470422387"] = {},
    ["rbxassetid://1470439852"] = {},
    ["rbxassetid://1470449816"] = {},
    ["rbxassetid://1470447472"] = {},
    ["rbxassetid://1461145506"] = {
        Scaling = 2
    }
}

local Logged = {}

local function BindRemoteToMove(moveName, callback)
    Logged[moveName] = callback
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }

    if not checkcaller()
        and method == "FireServer"
        and self.Name == "Input"
        and args[1] == "fire"
        and typeof(args[2]) == "table"
        and args[2].ToolName
        and Logged[args[2].ToolName]
    then
        Logged[args[2].ToolName](args[2],oldNamecall(self, ...))
    end

    return oldNamecall(self, ...)
end))


local Camera = game.Workspace.Camera
local OldFov = Camera.FieldOfView
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local function FindNearestLive(NearMouse)
        local closestHRP = nil
        local closestDist = math.huge
        
        for _, v in ipairs(workspace.Live:GetChildren()) do
            if v.Name ~= player.Name and v:FindFirstChild("HumanoidRootPart") then
                local dist = (v.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if NearMouse then
                    local Mouse = game.Players.LocalPlayer:GetMouse()
                    dist = (v.HumanoidRootPart.Position - Mouse.Hit.Position).Magnitude
                end

                if dist < 100 and dist < closestDist then
                    closestDist = dist
                    closestHRP = v.HumanoidRootPart
                end
            end
        end
    return closestHRP
end

local Window = Library:CreateWindow({
    Title = 'ABA X 67',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Characters = Window:AddTab('Character Stuff'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local MainBox = Tabs.Main:AddLeftGroupbox('PVP')
local CharBox = Tabs.Characters:AddLeftGroupbox('Main')
local ESPBox = Tabs.Main:AddRightGroupbox('ESP')
MainBox:AddToggle('Upfling', {
    Text = 'Upfling Extend',
    Default = false
})

MainBox:AddToggle('AP', {
    Text = 'Auto Block M1s',
    Tooltip = 'really bad',
    Default = false
})

local Hitboxes = {}

MainBox:AddToggle('Hitboxes', {
    Text = 'show m1 hitboxes',
    Tooltip = 'm1 hitboxes',
    Default = false
})

MainBox:AddToggle('NoStun', {
    Text = 'No Stun',
    Default = false
})

MainBox:AddToggle('AutoBlackFlash', {
    Text = 'Auto Black Flash',
    Default = false
})

MainBox:AddToggle('NanamiAuto', {
    Text = 'Nanami Auto',
    Default = false
})

ESPBox:AddToggle('ESP',{
    Text = 'ESP',
    Default = false,
})

MainBox:AddButton({
    Text = 'Reset',
    Func = function()
        LocalPlayer.Character:WaitForChild("Humanoid").Health = 0
    end
})

CharBox:AddToggle('sandtp',{
    Text = 'Insant Sand Coffin',
    Default = false
})


CharBox:AddToggle('kitp',{
    Text = 'TP Krillin Moves',
    Default = false
})

CharBox:AddToggle('Backugo', {
    Text = 'Backugo Damage Aura',
    Tooltip = 'press reset to speed up',
    Default = false
})

CharBox:AddToggle('RocketTp', {
    Text = 'Raiden Rocket Tp',
    Tooltip = 'look down after pressing 2',
    Default = false
})

CharBox:AddToggle('stp', {
    Text = 'Invisible Stand',
    Tooltip = 'makes ur stand invis but breaks some moves',
    Default = false
})

CharBox:AddToggle('etp', {
    Text = 'Everything TP',
    Tooltip = 'looks for whatever u have network ownership of and tps to enemy [LAGGY]',
    Default = false
})

CharBox:AddButton({
    Text = 'Morel Void',
    Func = function()
            BindCooldownToMove(LocalPlayer.Backpack:FindFirstChild('Smoky Chain'),function()
            wait(1)
            local hrp = char:WaitForChild("HumanoidRootPart")
            local originalCFrame = hrp.CFrame
            hrp.CFrame = originalCFrame * CFrame.new(1, 9e9, 0)
            wait(1)

            task.wait(10)
            hrp.CFrame = originalCFrame
        end)
    end
})

local TP_UP_TIME = 0.03
local TP_DOWN_TIME = 0.5

local watchedAnimations = {
    ["rbxassetid://1461252313"] = 0.9,
    ["none"] = 0.9
}



local function Parry(held)
    local char = LocalPlayer.Character
    if not char then return end
    local remote = LocalPlayer.Backpack.ServerTraits:FindFirstChild('Input')
    if not remote then return end

    remote:FireServer("f")
    task.wait(held or 0.2)
    remote:FireServer("foff")
end

local function CreateHitBox(root,config)
    task.wait(config.delay)

    if not root or not root.Parent then return end

    local Hitbox = Instance.new("Part")
    Hitbox.Size = Vector3.new(4.7, 4.7, 4.7) * (config.Scaling)
    Hitbox.Material = Enum.Material.ForceField
    Hitbox.Shape = Enum.PartType.Ball
    Hitbox.CanCollide = false
    Hitbox.Massless = true
    Hitbox.Anchored = false
    Hitbox.CFrame = root.CFrame * CFrame.new(0, 0, (config.offset or -3.5) )
    Hitbox.Parent = workspace
    Hitbox.BrickColor = BrickColor.new("Really red")
    if not Toggles.Hitboxes.Value then
        Hitbox.Transparency = 1
    end

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Hitbox
    weld.Part1 = root
    weld.Parent = Hitbox

    Hitboxes[Hitbox] = true

    Debris:AddItem(Hitbox, 0.15)
    task.delay(0.15, function()
        Hitboxes[Hitbox] = nil
    end)
end



local function CreateESP(char)
    if not Players:GetPlayerFromCharacter(char) then return end
    local ESP_Gui = game:GetObjects('rbxassetid://72926575986789')[1];

    ESP_Gui.Parent = char.HumanoidRootPart
    ESP_Gui.Enabled = false
    table.insert(ESP_TABLE,ESP_Gui)
end



local function addedChild(child)
    if not child:IsA("Model") then return end

    local humanoid = child:FindFirstChildOfClass("Humanoid")
    local root = child:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end
    
    humanoid.AnimationPlayed:Connect(function(track)
        local anim = track.Animation
        if not anim then return end

        local data = Target_Anims[anim.AnimationId]
        if not data then return end

        CreateHitBox(root,{
            delay = data.delay or 0.1,
            Scaling = data.Scaling or 3
        })
    end)

    CreateESP(child)
end

BindRemoteToMove("Sand Coffin", function(data,callback)
    if Toggles.sandtp.Value then
    wait(0.35)
    for i,v in pairs(workspace:GetDescendants()) do
    if v:IsA('BasePart') and isnetworkowner(v) then
        if v.Name == 'SwipeCloud' then
            v.CFrame = FindNearestLive(true).CFrame
        end 
    end
    end
    end
    return callback
end)

BindRemoteToMove("Scattershot", function(data,callback)
    if Toggles.kitp.Value then
    wait(0.35)
    for i,v in pairs(workspace:GetDescendants()) do
    if v:IsA('BasePart') and isnetworkowner(v) then
        if v.Name == 'KiBlast' then
            v.CFrame = FindNearestLive(true).CFrame
        end 
    end
    end
    end
    return callback
end)

local function onCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    root.Touched:Connect(function(part)
        if Hitboxes[part] and Toggles.AP.Value then
            Parry(0.2)
        end
    end)
    humanoid.AnimationPlayed:Connect(function(track)
        if not Toggles.Upfling.Value then return end
        if not track.Animation then return end

        local delayTime = watchedAnimations[track.Animation.AnimationId]
        if not delayTime then return end
        local closestHRP = FindNearestLive()
        if not closestHRP then return end
        task.wait(delayTime)

        a = 15 
        b,c = char.HumanoidRootPart.Position.X,char.HumanoidRootPart.Position.Z 
        char.HumanoidRootPart.CFrame = closestHRP.CFrame * CFrame.new(0, a, 0) 
        char.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(b,char.HumanoidRootPart.Position.Y,c)) 
    end)

     local hrp = char:WaitForChild("HumanoidRootPart")
    local live = workspace:WaitForChild("Live")
    local auto = live.DescendantAdded:Connect(function(desc)
        if not Toggles.NanamiAuto.Value then return end
	    if desc.Name == "NanamiCutGUI" then
		    local gui = desc
		    local mainBar = gui:WaitForChild("MainBar")
		    local cutter = mainBar:WaitForChild("Cutter")
	        local goal = mainBar:WaitForChild("Goal")
	        local connection
	        connection = game:GetService("RunService").RenderStepped:Connect(function()
	            local cutterX = cutter.Position.X.Scale
                local goalX = goal.Position.X.Scale
	            if math.abs(cutterX - goalX) <= 0.016 then
			        mouse1click()
			        connection:Disconnect()
			        connection = nil
			    end
		    end)
        end
    end)

    humanoid.Died:Connect(function()
        auto:Disconnect()
    end)
end


if LocalPlayer.Character then
    onCharacter(LocalPlayer.Character)
end

for _, v in ipairs(workspace.Live:GetChildren()) do
    addedChild(v)
end

workspace.Live.ChildAdded:Connect(addedChild)


if LocalPlayer.Character then
    onCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacter)


RunService.RenderStepped:Connect(function()
    if Toggles.Backugo.Value then
        local traits = LocalPlayer.Backpack:FindFirstChild("ServerTraits")
        if traits and traits:FindFirstChild("Input") then
            traits.Input:FireServer("dodge", { explod = Enum.KeyCode.W })
        end
    end
    if Toggles.AutoBlackFlash.Value then
        if Camera.FieldOfView >= 40 and Camera.FieldOfView < 70 and Camera.FieldOfView > OldFov then
		    wait(0.01)
            print('CLICK')
		    mouse1click()
	    end
	    OldFov = Camera.FieldOfView
    end
    if Toggles.NoStun.Value then
        for i,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA('BodyVelocity') then
                v.MaxForce = Vector3.new(0,9e6,0)
            end
        end
    end
    if Toggles.RocketTp.Value then
        for i,v in pairs(workspace.Thrown:GetChildren()) do
            if v.Name ~= 'Missile' then continue end
            if v:IsA('BasePart') and isnetworkowner(v) then
                if FindNearestLive() then
                    v.CFrame = FindNearestLive().CFrame
                end 
            end
        end
    end
    if Toggles.kitp.Value then
        for i,v in pairs(workspace.Thrown:GetChildren()) do
            if v.Name ~= 'Blast' then continue end
            if v:IsA('BasePart') and isnetworkowner(v) then
                if FindNearestLive(true) then
                    v.CFrame = FindNearestLive(true).CFrame
                end 
            end
        end
    end
    if Toggles.stp.Value then
        if workspace.Stands:FindFirstChild(LocalPlayer.Name) then
            workspace.Stands:FindFirstChild(LocalPlayer.Name).HumanoidRootPart.CFrame = CFrame.new(Vector3.new(1,9e4,1))
        end
    end
    if Toggles.etp.Value then
        for i,v in pairs(workspace.Thrown:GetDescendants()) do
            if v:IsA('BasePart') and isnetworkowner(v) then
                if v.Name == 'Tar' or v.Name == 'DebreeePart2' then return end
                if FindNearestLive(true) then
                    v.CFrame = FindNearestLive(true).CFrame
                end 
            end
        end
    end
    if Toggles.ESP.Value then
        for i,ESP in pairs(ESP_TABLE) do
            ESP.Enabled = true
            local H = ESP.Parent.Parent:FindFirstChild('Humanoid')
            local P = Players:FindFirstChild(ESP.Parent.Parent.Name)
            local HP = H.Health /120
            local T = ESP.Target
            local M = P.Charge.Value / 325
            u2 = T.Mode:FindFirstChild('Ultimate2')
            if P:FindFirstChild('SecondBar') then
                Ultimate2.Bar.Size = UDim2.new(P:FindFirstChild('SecondBar').Value/150,0,0.86,0)
                else
                if u2 then
                    u2:Destroy()
                end
            end
            T.Health.Bar.Size = UDim2.new(HP,0,0.95,0)
            T.Mode.Ultimate.Bar.Size = UDim2.new(M,0,0.86,0)
            
            for i = 2,5 do
                local M = T.Moves:FindFirstChild(tostring(i-1))
                if M then
                   CD = M.CD
                   MV = P.Backpack:GetChildren()[i]
                   CDR = 0
                   pcall(function() 
                        CDR = -20 + MV:GetAttribute("COOLDOWN")
                    end)
                   CD.Size = UDim2.new(1,0,CDR/20,0)
                   N = M.TextLabel
                   N.Text = MV.Name
                end
            end
        end
        else
        for i,ESP in pairs(ESP_TABLE) do
            ESP.Enabled = false
        end
    end
end)


local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu keybind'
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('ABA_X_67')
SaveManager:SetFolder('ABA_X_67/configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
