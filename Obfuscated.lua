local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ChatService = game:GetService("Chat")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Replication = ReplicatedStorage:WaitForChild("Replication")
local HotbarUI = Player.PlayerGui:WaitForChild("Hotbar").Backpack.Hotbar
local Backpack = Player.Backpack

local CLOSE_RANGE = 14
local LONG_RANGE = 35
local ENABLED = true

local closeAnims = {
    "rbxassetid://16552234590","rbxassetid://17889290569","rbxassetid://17889461810","rbxassetid://17889458563",
    "rbxassetid://17889471098","rbxassetid://16515448089","rbxassetid://16515520431","rbxassetid://16515503507",
    "rbxassetid://15162694192","rbxassetid://15240176873","rbxassetid://15240216931","rbxassetid://15259161390",
    "rbxassetid://14136436157","rbxassetid://14001963401","rbxassetid://13997092940","rbxassetid://14004222985",
    "rbxassetid://13378708199","rbxassetid://13378751717","rbxassetid://13390230973","rbxassetid://13295936866",
    "rbxassetid://13295919399","rbxassetid://13296577783","rbxassetid://13491635433","rbxassetid://13294471966",
    "rbxassetid://13532604085","rbxassetid://13532600125","rbxassetid://13532562418","rbxassetid://10469643643",
    "rbxassetid://10469630950","rbxassetid://10469639222","rbxassetid://10469493270","rbxassetid://10479335397",
    "rbxassetid://17325537719","rbxassetid://17325522388","rbxassetid://17325510002","rbxassetid://17325513870",
    "rbxassetid://13380255751","rbxassetid://17857788598","rbxassetid://17799224866","rbxassetid://10470104242",
    "rbxassetid://10503381238","rbxassetid://17889290569","rbxassetid://17889471098","rbxassetid://10479335397",
    "rbxassetid://18464351556","rbxassetid://17889461810","rbxassetid://17889458563","rbxassetid://10466974800",
    "rbxassetid://10468665991","rbxassetid://13380255751","rbxassetid://12509505723","rbxassetid://18179181663",
    "rbxassetid://17857880283","rbxassetid://12534735382","rbxassetid://12296882427","rbxassetid://12272894215",
    "rbxassetid://15290930205","rbxassetid://16431491215","rbxassetid://16515850153","rbxassetid://16139402582",
    "rbxassetid://13362587853","rbxassetid://16139108718","rbxassetid://14046756619","rbxassetid://134775406437626",
    "rbxassetid://104895379416342","rbxassetid://100059874351664","rbxassetid://123005629431309","rbxassetid://98542310119798",
    "rbxassetid://77509627104305","rbxassetid://113166426814229","rbxassetid://13376869471","rbxassetid://15295895753",
    "rbxassetid://13370310513","rbxassetid://125955606488863"
}

local longAnims = {
    "rbxassetid://10479335397","rbxassetid://10468665991","rbxassetid://12684185971","rbxassetid://12509505723",
    "rbxassetid://12684390285","rbxassetid://17275150809","rbxassetid://131820095363270","rbxassetid://13362587853",
    "rbxassetid://14046756619","rbxassetid://15295895753","rbxassetid://15290930205","rbxassetid://13380255751"
}

local counterToolAnims = {
    "rbxassetid://10469493270","rbxassetid://10469630950","rbxassetid://10469639222","rbxassetid://10469643643",
    "rbxassetid://13532562418","rbxassetid://13532600125","rbxassetid://13532604085","rbxassetid://13294471966",
    "rbxassetid://13491635433","rbxassetid://13296577783","rbxassetid://13295919399","rbxassetid://13295936866",
    "rbxassetid://13370310513","rbxassetid://13390230973","rbxassetid://13378751717","rbxassetid://13378708199",
    "rbxassetid://14004222985","rbxassetid://13997092940","rbxassetid://14001963401","rbxassetid://14136436157",
    "rbxassetid://15259161390","rbxassetid://15240216931","rbxassetid://15240176873","rbxassetid://15162694192",
    "rbxassetid://16515503507","rbxassetid://16515520431","rbxassetid://16515448089","rbxassetid://16552234590",
    "rbxassetid://17889458563","rbxassetid://17889461810","rbxassetid://17889471098","rbxassetid://17889290569",
    "rbxassetid://123005629431309","rbxassetid://100059874351664","rbxassetid://104895379416342","rbxassetid://134775406437626"
}

local CDNFix = loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkRandomUsernameok/PublicAssets/refs/heads/main/Modules/FixCDN.lua"))()

local IsAttacking = false

local ScriptAuth = loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkRandomUsernameok/PublicAssets/refs/heads/main/Connections/832767.lua"))
if not ScriptAuth then
    return 
end

local function GetCharacter()
    if not Player.Character then Player.CharacterAdded:Wait() end
    Player.Character:WaitForChild("HumanoidRootPart")
    return Player.Character
end

local function Communicate(data)
    local char = GetCharacter()
    if char:FindFirstChild("Communicate") then
        char.Communicate:FireServer(data)
    end
end

local function EnsureAssetDownloaded(fileName, url)
    local success, _ = pcall(readfile, fileName)
    if success then return end
    
    writefile(fileName, game:HttpGet(CDNFix(url)))
end

local function FireSignal(data)
    firesignal(Replication.OnClientEvent, table.unpack({data}))
end

local function PlayAnimation(animId)
    local char = GetCharacter()
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. tostring(animId)
    
    local track = char.Humanoid:LoadAnimation(animation)
    track:Play(0.2)
    return track
end

local function FireSound(volume, soundId)
    local char = GetCharacter()
    local sound = Instance.new("Sound", char.HumanoidRootPart)
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Volume = volume
    
    task.delay(sound.TimeLength + 4, function()
        if sound then sound:Destroy() end
    end)
    
    sound:Play()
    return sound
end

local function Debris(instance, timeout)
    if typeof(instance) ~= "Instance" then return end
    task.delay(timeout, function()
        if instance and instance.Parent then instance:Destroy() end
    end)
end

local function ToggleBlock(state)
    local char = GetCharacter()
    if not char:GetAttribute("RealBlock") then
        char:SetAttribute("RealBlock", false)
    end

    if state then
        Communicate({ Goal = "KeyPress", Key = Enum.KeyCode.F })
    else
        Communicate({ Goal = "KeyRelease", Key = Enum.KeyCode.F })
    end
    return true
end

local function isPlaying(humanoid, list)
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and table.find(list, track.Animation.AnimationId) then
            return true
        end
    end
    return false
end

local autoBlocking = false

RunService.Heartbeat:Connect(function()
    if not ENABLED then
        if autoBlocking then 
            Communicate({Goal = "KeyRelease", Key = Enum.KeyCode.F}) 
            autoBlocking = false 
        end
        return
    end

    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local rootPos = char.HumanoidRootPart.Position
    local closeTarget, longTarget = nil, nil
    local dClose, dLong = math.huge, math.huge

    for _, p in Players:GetPlayers() do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (rootPos - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < CLOSE_RANGE and dist < dClose then closeTarget, dClose = p, dist end
            if dist < LONG_RANGE  and dist < dLong  then longTarget,  dLong  = p, dist end
        end
    end

    local target = longTarget or closeTarget
    if not target or not target.Character or not target.Character:FindFirstChild("Humanoid") then
        if autoBlocking then 
            Communicate({Goal = "KeyRelease", Key = Enum.KeyCode.F}) 
            autoBlocking = false 
        end
        return
    end

    local hum = target.Character.Humanoid
    local shouldBlock = false
    local useTool = false

    if longTarget and isPlaying(hum, longAnims) then
        shouldBlock = true
    elseif closeTarget and isPlaying(hum, closeAnims) then
        shouldBlock = true
        if isPlaying(hum, counterToolAnims) then
            useTool = true
        end
    end

    if shouldBlock and not autoBlocking then
        autoBlocking = true
        if useTool then
            local tool = Backpack:FindFirstChild("Prey's Peril") or Backpack:FindFirstChild("Split Second Counter")
            if tool and char:FindFirstChild("Communicate") then
                char.Communicate:FireServer({Tool = tool, Goal = "Console Move"})
            end
        end
        Communicate({Goal = "KeyPress", Key = Enum.KeyCode.F})
    elseif not shouldBlock and autoBlocking then
        autoBlocking = false
        Communicate({Goal = "KeyRelease", Key = Enum.KeyCode.F})
    end
end)

local function WaitForAttribute(instance, attribute, timeout)
    local start = os.clock()
    while instance:GetAttribute(attribute) == nil do
        if os.clock() - start > (timeout or 10) then return nil end
        task.wait()
    end
    return instance:GetAttribute(attribute)
end

local function ReplaceAnimations(animConfig)
    GetCharacter():WaitForChild("Humanoid").AnimationPlayed:Connect(function(track)
        local config = animConfig[track.Animation.AnimationId]
        if not config then return end

        if typeof(config.Callback) == "function" then
            task.spawn(config.Callback, track)
        end

        track:AdjustSpeed(0) 

        if config.Kill then
            track:Stop()
            return 
        end

        if not config.UpdateToAnimation then track:Stop() end

        local newTrack = PlayAnimation(config.Animation)
        if config.Speed then newTrack:AdjustSpeed(config.Speed) end
        if config.Priority then newTrack.Priority = config.Priority end
        
        if config.StopOnLength then
            task.delay(track.Length, function() track:Stop() end)
        end
    end)
end

local function AccessoryBind(mode, duration)
    local char = GetCharacter()
    if mode == "Emote" then
        local holder = Instance.new("Accessory")
        holder.Name = "#EmoteHolder_" .. math.random(1, 100000)
        holder:SetAttribute("EmoteProperty", true)
        holder.Parent = char
        if duration then Debris(holder, duration) end
        return holder
    end
    return false
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if not checkcaller() and method == "FireServer" and self.Name == "Communicate" then
        local data = args[1]
        if typeof(data) == "table" then
            local goal = data.Goal
            
            if goal == "LeftClick" then
                IsAttacking = true
            elseif goal == "KeyRelease" and data.Key == Enum.UserInputType.MouseButton1 then
                IsAttacking = false
            end

            if goal == "LeftClick" or goal == "Console Move" or (goal == "KeyPress" and data.Dash) then
                task.spawn(function()
                    if GetCharacter():GetAttribute("RealBlock") == true then
                        ToggleBlock(false)
                    end
                end)
            elseif goal == "KeyRelease" and data.Key == Enum.KeyCode.F then
                task.spawn(function()
                    local char = GetCharacter()
                    char:SetAttribute("RealBlock", false)
                    repeat task.wait() ToggleBlock(true) until char:GetAttribute("RealBlock")
                end)
            end
        end
    end
    return oldNamecall(self, ...)
end)

local M1_Animations = {
    133094662049155, 134711731729986, 76963965406296, 92546791251633,
    128188725134114, 109088632860488, 78339272602733, 127015697036075
}
local Hit_Sounds = {72555434288985, 91067294642442, 104124534923268}
local Block_Sounds_To_Mute = {"rbxassetid://4306994267", "rbxassetid://4306994664", "rbxassetid://4306994923", "rbxassetid://4306995205"}

function OnSpawn()
    local char = GetCharacter()
    char:SetAttribute("RealBlock", false)
    char:SetAttribute("Character", "Goku")
    char:SetAttribute("UltimateName", "LIMIT BURST")

    char.DescendantAdded:Connect(function(obj)
        if obj:IsA("Sound") and table.find(Block_Sounds_To_Mute, obj.SoundId) then
            RunService.Heartbeat:Wait()
            obj:Destroy()
        end
    end)

    ReplaceAnimations({
        ["rbxassetid://10470389827"] = { Kill = true },
        ["rbxassetid://10473655645"] = { Kill = true },
        ["rbxassetid://10473653782"] = { Kill = true },
        ["rbxassetid://10473655082"] = { Kill = true },
        ["rbxassetid://13380778193"] = { Kill = true },
    })

    char:GetAttributeChangedSignal("Blocking"):Connect(function()
        task.wait()
        if char:GetAttribute("Blocking") then
            char:SetAttribute("RealBlock", true)
            char:SetAttribute("Blocking", false) 
        end
    end)

    repeat task.wait() ToggleBlock(true) until char:GetAttribute("RealBlock")

    local function HandleCooldownBlock(attrName)
        char:GetAttributeChangedSignal(attrName):Connect(function()
            local waitTime = (attrName == "LastM1Fire") and 0.8 or 0.4
            char:SetAttribute("RealBlock", false)
            task.delay(waitTime, function()
                repeat task.wait() ToggleBlock(true) until char:GetAttribute("RealBlock")
            end)
        end)
    end

    local trackedAttributes = {"LastM1Fire", "LastDashSwing", "LastSkill", "_LastDash", "LastDamage"}
    for _, attr in ipairs(trackedAttributes) do HandleCooldownBlock(attr) end

    local lastReact = 0
    local m1Index = 1
    char:GetAttributeChangedSignal("BlockReact"):Connect(function()
        local val = math.abs(char:GetAttribute("BlockReact"))
        if lastReact < val then
            PlayAnimation(M1_Animations[m1Index])
            FireSound(1, Hit_Sounds[math.random(1, #Hit_Sounds)])
            m1Index = (m1Index % #M1_Animations) + 1
        end
        lastReact = val
    end)

    local emoteHolder = AccessoryBind("Emote")
    PlayAnimation("116187503451999")
    
    FireSignal({
        AnimSent = 116187503451999,
        Character = char,
        SpecificModule = ReplicatedStorage.Emotes.VFX,
        RealBind = emoteHolder,
        vfxName = "Divine Form",
        Type = "ReplicateEmoteVfx",
    })

    task.delay(7.2, function()
        local vfxFolder = ReplicatedStorage.Emotes.VFX.VfxMods.Evolved.vfx.Folder
        local auraHolder = Instance.new("Folder", char)
        auraHolder.Name = "AuraHolder"
        
        for _, part in pairs(vfxFolder:GetChildren()) do
            local targetPart = char:FindFirstChild(part.Name)
            if targetPart then
                local clone = part:Clone()
                clone.Transparency = 1
                clone.Parent = auraHolder
                local weld = Instance.new("Weld", clone)
                weld.Part0, weld.Part1 = targetPart, clone
            end
        end
    end)
end

if Player.Character then
    task.spawn(OnSpawn)
end

Player.CharacterAdded:Connect(OnSpawn)
