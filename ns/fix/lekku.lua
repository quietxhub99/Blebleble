-------------------------------------------
----- =======[ Load WindUI ]
-------------------------------------------

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-------------------------------------------
----- =======[ GLOBAL FUNCTION ]
-------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local net = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")

local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RF/CatchFishCompleted")
local Constants = require(ReplicatedStorage:WaitForChild("Shared", 20):WaitForChild("Constants"))

local Player = Players.LocalPlayer
local XPBar = Player:WaitForChild("PlayerGui"):WaitForChild("XP")

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

task.spawn(function()
    if XPBar then
        XPBar.Enabled = true
    end
end)

local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local VirtualUser = game:GetService("VirtualUser")

-- =========================
-- STRONG ANTI AFK SYSTEM
-- =========================

_G.Players = game:GetService("Players")
_G.VirtualUser = game:GetService("VirtualUser")

local Player = _G.Players.LocalPlayer
if not Player then return end

if _G.AntiAFKConnection then
    _G.AntiAFKConnection:Disconnect()
    _G.AntiAFKConnection = nil
end


_G.AntiAFKConnection = Player.Idled:Connect(function()
    pcall(function()
        _G.VirtualUser:CaptureController()
        _G.VirtualUser:ClickButton2(Vector2.new(0,0))
        _G.VirtualUser:ClickButton1(Vector2.new(0,0))
    end)
end)

if _G.AntiAFKLoop then
    task.cancel(_G.AntiAFKLoop)
end

_G.AntiAFKLoop = task.spawn(function()
    while task.wait(60) do
        pcall(function()
            _G.VirtualUser:CaptureController()
            _G.VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            _G.VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

local function AutoReconnect()
    while task.wait(5) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(PlaceId)
        end
    end
end

Players.LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        TeleportService:Teleport(PlaceId)
    end
end)

task.spawn(AutoReconnect)

local ijump = false

local RodIdle = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("ReelingIdle")

local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("RodThrow")

-- Pastikan kamu punya Humanoid
local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Buat Animator jika belum ada
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

-- Load dan Play animasi
local RodShake = animator:LoadAnimation(RodShake)
local RodIdle = animator:LoadAnimation(RodIdle)

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)

if Shared then
    if not _G.ItemUtility then
        local success, utility = pcall(require, Shared:WaitForChild("ItemUtility", 5))
        if success and utility then
            _G.ItemUtility = utility
        else
            warn("ItemUtility module not found or failed to load.")
        end
    end
    if not _G.ItemStringUtility and Modules then
        local success, stringUtility = pcall(require, Modules:WaitForChild("ItemStringUtility", 5))
        if success and stringUtility then
            _G.ItemStringUtility = stringUtility
        else
            warn("ItemStringUtility module not found or failed to load.")
        end
    end
    -- Memuat Replion, Promise, PromptController untuk Auto Accept Trade
    if not _G.Replion then pcall(function() _G.Replion = require(ReplicatedStorage.Packages.Replion) end) end
    if not _G.Promise then pcall(function() _G.Promise = require(ReplicatedStorage.Packages.Promise) end) end
    if not _G.PromptController then pcall(function() _G.PromptController = require(ReplicatedStorage.Controllers.PromptController) end) end
end


-- =======================================================
-- == QUIETX PERFECTION SYSTEM (AUTO REGISTER, HIDE CHAT)
-- =======================================================

_G.AUTO_MESSAGE = "!p"
_G.NEWBIE_MESSAGE = "!n"
_G.HideLocalChat = true
_G.Players = game:GetService("Players")
_G.LocalPlayer = _G.Players.LocalPlayer
_G.TextChatService = game:GetService("TextChatService")
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")


if _G.HideLocalChat and not _G.ChatHiddenHooked then
    _G.ChatHiddenHooked = true

    if _G.TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        _G.TextChatService.MessageReceived:Connect(function(msg)
            if msg.TextSource and msg.TextSource.UserId == _G.LocalPlayer.UserId then
                msg:Cancel()
            end
        end)

    else
        local chatEvents = _G.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents and chatEvents:FindFirstChild("OnMessageDoneFiltering") then
            chatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
                if data.FromSpeaker == _G.LocalPlayer.Name then
                    return nil
                end
            end)
        end
    end
end


function _G.SendChat(msg)
    task.spawn(function()

        local successNew = pcall(function()
            if _G.TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channel = _G.TextChatService.TextChannels.RBXGeneral
                if channel then channel:SendAsync(msg) return end
            end
        end)

        if not successNew then
            pcall(function()
                local chatEvents = _G.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
                    chatEvents.SayMessageRequest:FireServer(msg, "All")
                end
            end)
        end
    end)
end


task.delay(1, function()
    _G.SendChat(_G.NEWBIE_MESSAGE)
    task.wait(0.4)
    _G.SendChat(_G.AUTO_MESSAGE)
end)


-- =======================================================
-- == PERFECTION SETTINGS
-- =======================================================

_G.PerfText = "PERFECTION!"
_G.PerfColor = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(64, 255, 118)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(64, 255, 118))
})

_G.TargetTexts = {
    ["ok"] = true, ["good"] = true, ["great"] = true,
    ["amazing"] = true, ["perfect!"] = true
}

_G.Rep = _G.ReplicatedStorage
_G.Effects = require(_G.Rep.Shared.Effects)
_G.VFX = require(_G.Rep.Controllers.VFXController)
_G.Sounds = require(_G.Rep.Shared.Soundbook)

_G.PerfPlayers = _G.PerfPlayers or {}

if not _G.OriginalTextEffect then
    _G.OriginalTextEffect = _G.Effects.TextEffect
end



function _G.ListenToPlayer(player)
    if player == _G.LocalPlayer then return end

    player.Chatted:Connect(function(msg)
        msg = msg:lower()

        if msg == _G.NEWBIE_MESSAGE then
            task.delay(0.3, function()
                _G.SendChat(_G.AUTO_MESSAGE)
            end)
            return
        end


        if msg == "!p" then
            _G.PerfPlayers[player.Name] = true
            print("[PERFECTION] Enabled for:", player.Name)
        end

        if msg == "!unp" then
            _G.PerfPlayers[player.Name] = nil
            print("[PERFECTION] Disabled for:", player.Name)
        end
    end)
end


for _, p in ipairs(_G.Players:GetPlayers()) do
    _G.ListenToPlayer(p)
end

_G.Players.PlayerAdded:Connect(function(player)
    _G.ListenToPlayer(player)
end)


_G.Effects.TextEffect = function(self, data, ...)
    if data and data.Container and data.TextData and data.TextData.Text then

        local character = data.Container.Parent
        local owner = game.Players:GetPlayerFromCharacter(character)

        local isLocal = owner == _G.LocalPlayer
        local forced = owner and _G.PerfPlayers[owner.Name]

        if (isLocal or forced) then
            local text = string.lower(data.TextData.Text)

            if _G.TargetTexts[text] or text == string.lower(_G.PerfText) then
                data.TextData.Text = _G.PerfText
                data.TextData.TextColor = _G.PerfColor

                task.spawn(function()
                    pcall(function()
                        _G.VFX.Handle(_G.PerfText, data.Container)
                    end)
                end)

                task.spawn(function()
                    pcall(function()
                        if _G.Sounds.Sounds.Perfect then
                            _G.Sounds.Sounds.Perfect:Play()
                        elseif _G.Sounds.Sounds.PerfectCast then
                            _G.Sounds.Sounds.PerfectCast:Play()
                        end
                    end)
                end)
            end
        end
    end

    return _G.OriginalTextEffect(self, data, ...)
end

-------------------------------------------
----- =======[ NOTIFY FUNCTION ]
-------------------------------------------

local function NotifySuccess(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "circle-check"
    })
end

local function NotifyError(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "ban"
    })
end

local function NotifyInfo(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "info"
    })
end

local function NotifyWarning(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "triangle-alert"
    })
end

-------------------------------------------
----- =======[ CONFIRM POPUP ]
-------------------------------------------

local confirmed = false
WindUI:Popup({
    Title = "Thanksgiving!",
    Icon = "rbxassetid://129260712070622",
    Content = [[
Thank you for using Premium script!.
]],
    Buttons = {
        { Title = "Close", Variant = "Secondary", Callback = function() end },
        { Title = "Next", Variant = "Primary", Callback = function() confirmed = true end },
    }
})

repeat task.wait() until confirmed


-------------------------------------------
----- =======[ LOAD WINDOW ]
-------------------------------------------

local Window = WindUI:CreateWindow({
    Title = "QuietXHub Premium",
    Icon = "cannabis",
    Author = "by Prince",
    Folder = "QuietXHub",
    Size = UDim2.fromOffset(600, 400),
    Transparent = true,
    Theme = "Dark",
    KeySystem = false,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
        end,
    }
})

Window:EditOpenButton({
    Title = "QuietXHub",
    Icon = "crown",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("9600FF"), 
        Color3.fromHex("AEBAF8")
    ),
    Enabled = true,
    Draggable = true,
})

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("QuietXConfig")

WindUI:SetNotificationLower(true)

-------------------------------------------
----- =======[ ALL TAB ]
-------------------------------------------

local Trade = Window:Tab({
	Title = "Trade",
	Icon = "handshake"
})

local AutoFarmTab = Window:Tab({
	Title = "Auto Farm",
	Icon = "leaf"
})

local AutoFarmArt = Window:Tab({
	Title = "Auto Farm Artifact",
	Icon = "flask-round"
})

local WeatherTab = Window:Tab({
	Title = "Auto Weather", 
	Icon = "cloud-rain"
})

local Utils = Window:Tab({
    Title = "Utility",
    Icon = "earth"
})

local SettingsTab = Window:Tab({ 
	Title = "Settings", 
	Icon = "cog" 
})


if getgenv().AutoRejoinConnection then
    getgenv().AutoRejoinConnection:Disconnect()
    getgenv().AutoRejoinConnection = nil
end

getgenv().AutoRejoinConnection = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    task.wait()
    if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") and child.MessageArea:FindFirstChild("ErrorFrame") then
        local TeleportService = game:GetService("TeleportService")
        local Player = game.Players.LocalPlayer
        task.wait(2) 
        TeleportService:Teleport(game.PlaceId, Player)
    end
end)

-------------------------------------------  
----- =======[ AUTO FISH TAB ]  
-------------------------------------------



-------------------------------------------
----- =======[ AUTO FARM TAB ]
-------------------------------------------


-------------------------------------------
----- =======[ AUTO FISH TAB ]
-------------------------------------------

_G.REFishingStopped = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingStopped"]
_G.RFCancelFishingInputs = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]
_G.REUpdateChargeState = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/UpdateChargeState"]


_G.StopFishing = function()
	  _G.RFCancelFishingInputs:InvokeServer()
    firesignal(_G.REFishingStopped.OnClientEvent)
end

local FuncAutoFish = {
    REReplicateTextEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"],
    autofish5x = false,
    perfectCast5x = true,
    fishingActive = false,
    delayInitialized = false,
    lastCatchTime5x = 0,
    CatchLast = tick(),
}



_G.REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]
_G.REPlayFishingEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlayFishingEffect"]
_G.equipRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
_G.REObtainedNewFishNotification = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"]
    .net["RE/ObtainedNewFishNotification"]


_G.isSpamming = false
_G.rSpamming = false
_G.spamThread = nil
_G.rspamThread = nil
_G.lastRecastTime = 0
_G.DELAY_ANTISTUCK = 10
_G.isRecasting5x = false
_G.STUCK_TIMEOUT = 10
_G.AntiStuckEnabled = false
_G.lastFishTime = tick()
_G.FINISH_DELAY = 1
_G.fishCounter = 0
_G.sellThreshold = 30
_G.sellActive = false

_G.RemotePackage = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
_G.RemoteFish = _G.RemotePackage["RE/ObtainedNewFishNotification"]
_G.RemoteSell = _G.RemotePackage["RF/SellAllItems"]

_G.RemoteFish.OnClientEvent:Connect(function(_, _, data)
    if _G.sellActive and data then
        _G.fishCounter += 1
        if _G.fishCounter >= _G.sellThreshold then
            _G.TrySellNow()
            _G.fishCounter = 0
        end
    end
end)

_G.LastSellTick = 0

function _G.TrySellNow()
    local now = tick()
    if now - _G.LastSellTick < 1 then 
        return 
    end
    _G.LastSellTick = now
    _G.RemoteSell:InvokeServer()
end

function _G.RecastSpam()
    if _G.rSpamming then return end
    _G.rSpamming = true
    _G.rspamThread = task.spawn(function()
    while _G.rSpamming do
        StartCast5X()
        task.wait(0.01)
        end
    end)
end
    
function _G.RecastSpamStop()
   _G.rSpamming = false
end
    

function _G.startSpam()
    if _G.isSpamming then return end
    _G.isSpamming = true
    _G.spamThread = task.spawn(function()
    	task.wait(tonumber(_G.FINISH_DELAY))
    	finishRemote:InvokeServer()
    end)
end
    
function _G.stopSpam()
   _G.isSpamming = false
end

_G.REPlayFishingEffect.OnClientEvent:Connect(function(player, head, data)
    if player == Players.LocalPlayer and FuncAutoFish.autofish5x then
        _G.RecastSpamStop()
    end
end)


_G.REObtainedNewFishNotification.OnClientEvent:Connect(function(...)
	_G.lastFishTime = tick()
end)

task.spawn(function()
	while task.wait(1) do
		if _G.AntiStuckEnabled then
			if tick() - _G.lastFishTime > tonumber(_G.STUCK_TIMEOUT) then
				StopAutoFish5X()
				task.wait(1)
				StartAutoFish5X()
				_G.lastFishTime = tick()
			end
		end
	end
end)

FuncAutoFish.REReplicateTextEffect.OnClientEvent:Connect(function(data)
    if FuncAutoFish.autofish5x 
    and data and data.TextData 
    and data.TextData.EffectType == "Exclaim" then
    	local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")
    	if myHead and data.Container == myHead then
    		_G.startSpam()
    	end
    end
end)

_G.REFishCaught.OnClientEvent:Connect(function(fishName, info)
    if FuncAutoFish.autofish5x then
        _G.stopSpam()
        _G.StopFishing()
        _G.RecastSpam()
    end
end)

function StartCast5X()
	  _G.StopFishing()
    local getPowerFunction = Constants.GetPower
    local perfectThreshold = 0.99
    local chargeStartTime = workspace:GetServerTimeNow()
    rodRemote:InvokeServer(chargeStartTime)
    local calculationLoopStart = tick()
    local timeoutDuration = 0.01
    local lastPower = 0
    while (tick() - calculationLoopStart < timeoutDuration) do
        local currentPower = getPowerFunction(Constants, chargeStartTime)
        if currentPower < lastPower and lastPower >= perfectThreshold then
            break
        end

        lastPower = currentPower
        task.wait(0.001)
    end
    miniGameRemote:InvokeServer(-1.25, 1.0, workspace:GetServerTimeNow())
end

function StopCast()
    _G.StopFishing()
end

function StartAutoFish5X()
    FuncAutoFish.autofish5x = true
    FuncAutoFish.CatchLast5x = tick()
    _G.equipRemote:FireServer(1)
    task.wait(0.05)
    StartCast5X()
end

function StopAutoFish5X()
    FuncAutoFish.autofish5x = false
    FuncAutoFish.delayInitialized = false
    _G.StopFishing()
    _G.isRecasting5x = false
    _G.stopSpam()
    _G.RecastSpamStop()
end

--[[

INI AUTO FISH LEGIT 

]]


_G.RunService = game:GetService("RunService")
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.FishingControllerPath = _G.ReplicatedStorage.Controllers.FishingController
_G.FishingController = require(_G.FishingControllerPath)

_G.AutoFishingControllerPath = _G.ReplicatedStorage.Controllers.AutoFishingController
_G.AutoFishingController = require(_G.AutoFishingControllerPath)
_G.Replion = require(_G.ReplicatedStorage.Packages.Replion)

_G.AutoFishState = {
    IsActive = false,
    MinigameActive = false
}

_G.SPEED_LEGIT = 0.05

function _G.performClick()
    _G.FishingController:RequestFishingMinigameClick()
    task.wait(tonumber(_G.SPEED_LEGIT))
end

_G.originalAutoFishingStateChanged = _G.AutoFishingController.AutoFishingStateChanged
function _G.forceActiveVisual(arg1)
    _G.originalAutoFishingStateChanged(true)
end

_G.AutoFishingController.AutoFishingStateChanged = _G.forceActiveVisual

function _G.ensureServerAutoFishingOn()
    local replionData = _G.Replion.Client:WaitReplion("Data")
    local currentAutoFishingState = replionData:GetExpect("AutoFishing")

    if not currentAutoFishingState then
        local remoteFunctionName = "UpdateAutoFishingState"
        local Net = require(_G.ReplicatedStorage.Packages.Net)
        local UpdateAutoFishingRemote = Net:RemoteFunction(remoteFunctionName)

        local success, result = pcall(function()
            return UpdateAutoFishingRemote:InvokeServer(true)
        end)

        if success then
        else
        end
    else
    end
end

-- ===================================================================
-- BAGIAN 2: AUTO CLICK MINIGAME
-- ===================================================================

_G.originalRodStarted = _G.FishingController.FishingRodStarted
_G.originalFishingStopped = _G.FishingController.FishingStopped
_G.clickThread = nil

-- Hook FishingRodStarted (Minigame Aktif)
_G.FishingController.FishingRodStarted = function(self, arg1, arg2)
    _G.originalRodStarted(self, arg1, arg2)

    if _G.AutoFishState.IsActive and not _G.AutoFishState.MinigameActive then
        _G.AutoFishState.MinigameActive = true

        if _G.clickThread then
            task.cancel(_G.clickThread)
        end

        _G.clickThread = task.spawn(function()
            while _G.AutoFishState.IsActive and _G.AutoFishState.MinigameActive do
                _G.performClick()
            end
        end)
    end
end

_G.FishingController.FishingStopped = function(self, arg1)
    _G.originalFishingStopped(self, arg1)

    if _G.AutoFishState.MinigameActive then
        _G.AutoFishState.MinigameActive = false
        task.wait(1)
        _G.ensureServerAutoFishingOn()
    end
end

function _G.ToggleAutoClick(shouldActivate)
    _G.AutoFishState.IsActive = shouldActivate

    if shouldActivate then
        _G.ensureServerAutoFishingOn()
    else
        if _G.clickThread then
            task.cancel(_G.clickThread)
            _G.clickThread = nil
        end
        _G.AutoFishState.MinigameActive = false
    end
end

_G.FishSec = AutoFarmTab:Section({
    Title = "Auto Fishing",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.FishSec:Slider({
    Title = "Delay Finish",
    Step = 0.01,
    Value = {
        Min = 0.01,
        Max = 5,
        Default = _G.FINISH_DELAY,
    },
    Callback = function(value)
        _G.FINISH_DELAY = value
    end
})

_G.RecastCD = _G.FishSec:Slider({
    Title = "Speed Legit",
    Step = 0.01,
    Value = {
        Min = 0.01,
        Max = 5,
        Default = _G.SPEED_LEGIT,
    },
    Callback = function(value)
        _G.SPEED_LEGIT = value
    end
})

_G.FishSec:Slider({
    Title = "Sell Threshold",
    Step = 1,
    Value = {
        Min = 1,
        Max = 6000,
        Default = 30,
    },
    Callback = function(value)
        _G.sellThreshold = value
    end
})

_G.FishSec:Slider({
    Title = "Anti Stuck Delay",
    Step = 1,
    Value = {
        Min = 1,
        Max = 6000,
        Default = _G.STUCK_TIMEOUT,
    },
    Callback = function(value)
        _G.STUCK_TIMEOUT = value
    end
})

_G.FishSec:Toggle({
    Title = "Auto Sell",
    Value = false,
    Callback = function(state)
        _G.sellActive = state
        if state then
            NotifySuccess("Auto Sell", "Limit: " .. _G.sellThreshold)
        else
            NotifySuccess("Auto Sell", "Disabled")
        end
    end
})

_G.AutoFishes = _G.FishSec:Toggle({
    Title = "Auto Fish",
    Callback = function(value)
        if value then
            StartAutoFish5X()
        else
            StopAutoFish5X()
        end
    end
})

_G.FishSec:Toggle({
    Title = "Auto Fish Legit",
    Value = false,
    Callback = function(state)
        _G.equipRemote:FireServer(1)
        _G.ToggleAutoClick(state)

        local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local fishingGui = playerGui:WaitForChild("Fishing"):WaitForChild("Main")
        local chargeGui = playerGui:WaitForChild("Charge"):WaitForChild("Main")

        if state then
            fishingGui.Visible = false
            chargeGui.Visible = false
        else
            fishingGui.Visible = true
            chargeGui.Visible = true
        end
    end
})

_G.FishSec:Toggle({
	Title = "Anti Stuck",
	Value = false,
	Callback = function(state)
		_G.AntiStuckEnabled = state
	end
})


_G.FishSec:Space()


_G.FishSec:Button({
    Title = "Stop Fishing",
    Locked = false,
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.StopFishing()
        RodIdle:Stop()
        RodIdle:Stop()
        _G.stopSpam()
        _G.RecastSpamStop()
    end
})

_G.FishSec:Space()


-- =======================================================
-- == AUTO CUTSCENE REMOVER (TOGGLE + HOOK)
-- =======================================================

_G.CutsceneController = require(ReplicatedStorage.Controllers.CutsceneController)
_G.GuiControl = require(ReplicatedStorage.Modules.GuiControl)
_G.ProximityPromptService = game:GetService("ProximityPromptService")

_G.AutoSkipCutscene = true

if not _G.OriginalPlayCutscene then
    _G.OriginalPlayCutscene = _G.CutsceneController.Play
end

_G.CutsceneController.Play = function(self, ...)
    if _G.AutoSkipCutscene then
        task.spawn(function()
            task.wait()
            if _G.GuiControl then 
                _G.GuiControl:SetHUDVisibility(true) 
            end
            _G.ProximityPromptService.Enabled = true
            LocalPlayer:SetAttribute("IgnoreFOV", false)
        end)

        return
    end

    return _G.OriginalPlayCutscene(self, ...)
end

_G.FishSec:Toggle({
    Title = "Auto Skip Cutscenes",
    Value = true,
    Callback = function(state)
        _G.AutoSkipCutscene = state

        if state then
            if _G.CutsceneController then
                _G.CutsceneController:Stop()
                _G.GuiControl:SetHUDVisibility(true)
                _G.ProximityPromptService.Enabled = true
            end
            NotifySuccess("Cutscene", "Auto Skip Enabled. No more animations.")
        else
            NotifyInfo("Cutscene", "Auto Skip Disabled.")
        end
    end
})

_G.FishSec:Input({
    Title = "Max Inventory Size",
    Value = tostring(Constants.MaxInventorySize or 0),
    Placeholder = "Input Number...",
    Callback = function(input)
        local newSize = tonumber(input)
        if not newSize then
            NotifyWarning("Inventory Size", "Must be numbers!")
            return
        end
        Constants.MaxInventorySize = newSize
    end
})


function sellAllFishes()
	local charFolder = workspace:FindFirstChild("Characters")
	local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		NotifyError("Character Not Found", "HRP tidak ditemukan.")
		return
	end

	local originalPos = hrp.CFrame
	local sellRemote = net:WaitForChild("RF/SellAllItems")

	task.spawn(function()
		NotifyInfo("Selling...", "I'm going to sell all the fish, please wait...", 3)

		task.wait(1)
		local success, err = pcall(function()
			sellRemote:InvokeServer()
		end)

		if success then
			NotifySuccess("Sold!", "All the fish were sold successfully.", 3)
		else
			NotifyError("Sell Failed", tostring(err, 3))
		end

	end)
end


local floatPlatform = nil

local function floatingPlat(enabled)
	if enabled then
			local charFolder = workspace:WaitForChild("Characters", 5)
			local char = charFolder:FindFirstChild(LocalPlayer.Name)
			if not char then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			floatPlatform = Instance.new("Part")
			floatPlatform.Anchored = true
			floatPlatform.Size = Vector3.new(10, 1, 10)
			floatPlatform.Transparency = 1
			floatPlatform.CanCollide = true
			floatPlatform.Name = "FloatPlatform"
			floatPlatform.Parent = workspace

			task.spawn(function()
				while floatPlatform and floatPlatform.Parent do
					pcall(function()
						floatPlatform.Position = hrp.Position - Vector3.new(0, 3.5, 0)
					end)
					task.wait(0.1)
				end
			end)

			NotifySuccess("Float Enabled", "This feature has been successfully activated!")
		else
			if floatPlatform then
				floatPlatform:Destroy()
				floatPlatform = nil
			end
			NotifyWarning("Float Disabled", "Feature disabled")
		end
end

  
local workspace = game:GetService("Workspace")

local BlockEnabled = false

local function createLocalBlock(size, position, color)
    local part = Instance.new("Part")
    part.Size = size or Vector3.new(5, 1, 5)
    part.Position = position or
    (LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, -3, 0)) or
    Vector3.new(0, 5, 0)
    part.Anchored = true
    part.CanCollide = true
    part.Color = color or Color3.fromRGB(0, 0, 255)
    part.Material = Enum.Material.ForceField
    part.Name = "LocalBlock"
    part.Parent = workspace
    return part
end


local function createBlockUnderPlayer()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if workspace:FindFirstChild("LocalBlock") then
            workspace.LocalBlock:Destroy()
        end
        createLocalBlock(Vector3.new(6, 1, 6), hrp.Position - Vector3.new(0, 3, 0), Color3.fromRGB(0, 0, 255))
    end
end


function _G.ToggleBlockOnce(state)
    BlockEnabled = state
    if state then
        createBlockUnderPlayer()
    else
        if workspace:FindFirstChild("LocalBlock") then
            workspace.LocalBlock:Destroy()
        end
    end
end

local function getPartRecursive(o)
    if o:IsA("BasePart") then return o end
    for _, c in ipairs(o:GetChildren()) do
        local p = getPartRecursive(c)
        if p then return p end
    end
    return nil
end

local eventMap = {
    ["Shark Hunt"]       = { name = "Shark Hunt", part = nil },
    ["Ghost Shark Hunt"] = { name = "Ghost Shark Hunt", part = "Part" },
    ["Worm Hunt"]        = { name = "Model", part = "Part" },
    ["Black Hole"]       = { name = "BlackHole", part = nil },
    ["Meteor Rain"]      = { name = "MeteorRain", part = nil },
    ["Ghost Worm"]       = { name = "Model", part = "Part" },
    ["Shocked"]          = { name = "Shocked", part = nil },
    ["Megalodon Hunt"]   = { name = "Megalodon Hunt", part = "Color" },
}

local eventNames = {}
for _, data in pairs(eventMap) do
    if data.name ~= "Model" then
        table.insert(eventNames, data.name)
    end
end
table.insert(eventNames, "Worm Hunt")
table.insert(eventNames, "Ghost Worm")

local autoTPEvent = false
local savedCFrame = nil
local alreadyTeleported = false
local teleportTime = nil
local selectedEvent = nil
local wasAutoFishing = false

local function teleportTo(position)
    _G.isTeleporting = true
    local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp then
        local wasLocked = hrp.Anchored -- Jika fitur Lock Position aktif
        if wasLocked then hrp.Anchored = false end
        task.wait(0.1)

        -- Teleport
        hrp.CFrame = CFrame.new(position + Vector3.new(0, 15, 0))
        _G.ToggleBlockOnce(true)

        task.wait(0.5)
        if wasLocked then hrp.Anchored = true end
    end
    _G.isTeleporting = false
end

local function saveOriginalPosition()
    local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedCFrame = char.HumanoidRootPart.CFrame
    end
end

local function returnToOriginalPosition()
    if savedCFrame then
        local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = savedCFrame
        end
    end
end

local function findEventPart(eventName)
    local menuRings = workspace:FindFirstChild("!!! DEPENDENCIES")
    if not menuRings then return nil end

    local props = menuRings:FindFirstChild("Props")
    if not props then return nil end

    local targetEventData = eventMap[eventName]
    if not targetEventData then return nil end

    local eventModel = props:FindFirstChild(targetEventData.name)
    if not eventModel or not eventModel:IsA("Model") then return nil end

    local targetPart = nil

    if eventName == "Megalodon Hunt" then
        targetPart = eventModel:FindFirstChild("Color")
    elseif eventName == "Ghost Shark Hunt" then
        targetPart = eventModel:FindFirstChild("Part")
    elseif eventName == "Worm Hunt" or eventName == "Ghost Worm" then
        targetPart = eventModel:FindFirstChild("Part")
    elseif eventModel.PrimaryPart and eventModel.PrimaryPart:IsA("BasePart") then
        targetPart = eventModel.PrimaryPart
    else

        targetPart = getPartRecursive(eventModel)
    end

    if targetPart and targetPart:IsA("BasePart") then
        return targetPart
    end

    return nil
end

local function monitorAutoTP()
    while task.wait(3) do -- Cek setiap 3 detik
        -- Periksa kondisi utama untuk menjalankan logika TP
        if autoTPEvent and selectedEvent then
            local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)

            if char then
                local eventPart = findEventPart(selectedEvent)

                if eventPart and not alreadyTeleported then
                    -- === [ EVENT TERDETEKSI & BELUM TELEPORT ] ===
                    saveOriginalPosition()
                    wasAutoFishing = FuncAutoFish.autofish5x 

                    if wasAutoFishing then
                        _G.StopAutoFish5X() 
                        task.wait(0.5)
                    end

                    teleportTo(eventPart.Position)
                    alreadyTeleported = true
                    teleportTime = tick()

                    -- Mulai AutoFish setelah TP
                    if wasAutoFishing then
                        _G.StartAutoFish5X()
                    end

                    NotifySuccess("Event Farm", ("Teleported to %s. Farming started."):format(selectedEvent))
                elseif alreadyTeleported then
                    -- === [ SUDAH DI LOKASI EVENT ] ===

                    -- Cek Event Hilang atau Timeout 15 menit
                    local isTimeout = teleportTime and (tick() - teleportTime >= 900)

                    if isTimeout or not eventPart then
                        -- Hentikan AutoFish
                        if wasAutoFishing then _G.StopAutoFish5X() end

                        returnToOriginalPosition()

                        NotifyInfo("Event Ended", ("Returned to start position. Reason: %s"):format(
                            isTimeout and "Timeout 15m" or "Event Ended"
                        ))

                        -- Reset State
                        alreadyTeleported = false
                        teleportTime = nil

                        -- Lanjutkan AutoFish jika sebelumnya aktif
                        if wasAutoFishing then
                            task.wait(1)
                            _G.StartAutoFish5X()
                        end
                    end
                end
            end
        else
            -- === [ AUTO TP OFF ] ===
            if alreadyTeleported then
                if wasAutoFishing then _G.StopAutoFish5X() end
                returnToOriginalPosition()
                alreadyTeleported = false
                teleportTime = nil
                NotifyWarning("Auto TP Event", "Fitur dimatikan. Kembali ke posisi awal.")
            end
        end
    end
end

if _G.monitorTPThread then task.cancel(_G.monitorTPThread) end
_G.monitorTPThread = task.spawn(monitorAutoTP)

local isAutoFarmRunning = false

local islandCodes = {
    ["01"] = "Crater Islands",
    ["02"] = "Tropical Grove",
    ["03"] = "Vulcano",
    ["04"] = "Coral Reefs",
    ["05"] = "Winter",
    ["06"] = "Machine",
    ["07"] = "Treasure Room",
    ["08"] = "Sisyphus Statue",
    ["09"] = "Fisherman Island",
    ["10"] = "Esoteric Depths",
    ["11"] = "Kohana",
    ["12"] = "Underground Cellar",
    ["13"] = "Ancient Jungle",
    ["14"] = "Secret Farm Ancient",
    ["15"] = "The Temple (Unlock First)",
    ["16"] = "Ancient Ruin",
    ["17"] = "Pirate Cove",
    ["18"] = "Pirate Treasure Room",
    ["19"] = "Crystal Depths",
    ["78"] = "Heartfelt Island"
}

local farmLocations = {
    ["Crater Islands"] = {
    	CFrame.new(1066.1864, 57.2025681, 5045.5542, -0.682534158, 1.00865822e-08, 0.730853677, -5.8900711e-09, 1, -1.93017531e-08, -0.730853677, -1.74788859e-08, -0.682534158),
    	CFrame.new(1057.28992, 33.0884132, 5133.79883, 0.833871782, 5.44149223e-08, 0.551958203, -6.58184218e-09, 1, -8.86416984e-08, -0.551958203, 7.02829084e-08, 0.833871782),
    	CFrame.new(988.954712, 42.8254471, 5088.71289, -0.849417388, -9.89310394e-08, 0.527721584, -5.96115086e-08, 1, 9.15179328e-08, -0.527721584, 4.62786431e-08, -0.849417388),
    	CFrame.new(1006.70685, 17.2302666, 5092.14844, -0.989664078, 5.6538525e-09, -0.143405005, 9.14879283e-09, 1, -2.3711717e-08, 0.143405005, -2.47786183e-08, -0.989664078),
    	CFrame.new(1025.02356, 2.77259707, 5011.47021, -0.974474192, -6.87871804e-08, 0.224499553, -4.47472104e-08, 1, 1.12170284e-07, -0.224499553, 9.92613209e-08, -0.974474192),
    	CFrame.new(1071.14551, 3.528404, 5038.00293, -0.532300115, 3.38677708e-08, 0.84655571, 6.69992914e-08, 1, 2.12149165e-09, -0.84655571, 5.7847906e-08, -0.532300115),
    	CFrame.new(1022.55457, 16.6277809, 5066.28223, 0.721996129, 0, -0.691897094, 0, 1, 0, 0.691897094, 0, 0.721996129),
    },
    ["Tropical Grove"] = {
    	CFrame.new(-2165.05469, 2.77070165, 3639.87451, -0.589090407, -3.61497356e-08, -0.808067143, -3.20645626e-08, 1, -2.13606164e-08, 0.808067143, 1.3326984e-08, -0.589090407)
    },
    ["Vulcano"] = {
    	CFrame.new(-701.447937, 48.1446075, 93.1546631, -0.0770962164, 1.34335654e-08, -0.997023642, 9.84464776e-09, 1, 1.27124169e-08, 0.997023642, -8.83526763e-09, -0.0770962164),
    	CFrame.new(-654.994934, 57.2567711, 75.098526, -0.540957272, 2.58946509e-09, -0.841050088, -7.58775585e-08, 1, 5.18827363e-08, 0.841050088, 9.1883166e-08, -0.540957272),
    },
    ["Coral Reefs"] = {
    	CFrame.new(-3118.39624, 2.42531538, 2135.26392, 0.92336154, -1.0069185e-07, -0.383931547, 8.0607947e-08, 1, -6.84016968e-08, 0.383931547, 3.22115596e-08, 0.92336154),
    },
    ["Winter"] = {
    	CFrame.new(2036.15308, 6.54998732, 3381.88916, 0.943401575, 4.71338666e-08, -0.331652641, -3.28136842e-08, 1, 4.87781051e-08, 0.331652641, -3.51345975e-08, 0.943401575),
    },
    ["Machine"] = {
    	CFrame.new(-1459.3772, 14.7103214, 1831.5188, 0.777951121, 2.52131862e-08, -0.628324807, -5.24126378e-08, 1, -2.47663063e-08, 0.628324807, 5.21991339e-08, 0.777951121)
    },
    ["Treasure Room"] = {
    	CFrame.new(-3625.0708, -279.074219, -1594.57605, 0.918176472, -3.97606392e-09, -0.396171629, -1.12946204e-08, 1, -3.62128851e-08, 0.396171629, 3.77244298e-08, 0.918176472),
    	CFrame.new(-3600.72632, -276.06427, -1640.79663, -0.696130812, -6.0491181e-09, 0.717914939, -1.09490363e-08, 1, -2.19084972e-09, -0.717914939, -9.38559541e-09, -0.696130812),
    	CFrame.new(-3548.52222, -269.309845, -1659.26685, 0.0472991578, -4.08685423e-08, 0.998880744, -7.68598838e-08, 1, 4.45538149e-08, -0.998880744, -7.88812216e-08, 0.0472991578),
    	CFrame.new(-3581.84155, -279.09021, -1696.15637, -0.999634147, -0.000535600528, -0.0270430837, -0.000448358158, 0.999994695, -0.00323198596, 0.0270446707, -0.00321867829, -0.99962908),
    	CFrame.new(-3601.34302, -282.790955, -1629.37036, -0.526346684, 0.00143659476, 0.850268841, -0.000266355521, 0.999998271, -0.00185445137, -0.850269973, -0.00120255165, -0.526345372)
    },
    ["Sisyphus Statue"] = {
    	CFrame.new(-3777.43433, -135.074417, -975.198975, -0.284491211, -1.02338751e-08, -0.958678663, 6.38407585e-08, 1, -2.96199456e-08, 0.958678663, -6.96293867e-08, -0.284491211),
    	CFrame.new(-3697.77124, -135.074417, -886.946411, 0.979794085, -9.24526766e-09, 0.200008959, 1.35701708e-08, 1, -2.02526174e-08, -0.200008959, 2.25575487e-08, 0.979794085),
    	CFrame.new(-3764.021, -135.074417, -903.742493, 0.785813689, -3.05788426e-08, -0.618463278, -4.87374336e-08, 1, -1.11368585e-07, 0.618463278, 1.17657272e-07, 0.785813689)
    },
    ["Fisherman Island"] = {
    	CFrame.new(-75.2439423, 3.24433279, 3103.45093, -0.996514142, -3.14880424e-08, -0.0834242329, -3.84156422e-08, 1, 8.14354024e-08, 0.0834242329, 8.43563228e-08, -0.996514142),
    	CFrame.new(-162.285294, 3.26205397, 2954.47412, -0.74356699, -1.93168272e-08, -0.668661416, 1.03873425e-08, 1, -4.04397653e-08, 0.668661416, -3.70152904e-08, -0.74356699),
    	CFrame.new(-69.8645096, 3.2620542, 2866.48096, 0.342575252, 8.79649331e-09, 0.939490378, 4.78986739e-10, 1, -9.53770485e-09, -0.939490378, 3.71738529e-09, 0.342575252),
    	CFrame.new(247.130951, 2.47001815, 3001.72412, -0.724809051, -8.27166033e-08, -0.688949764, -8.16509669e-08, 1, -3.41610367e-08, 0.688949764, 3.14931867e-08, -0.724809051)
    },
    ["Esoteric Depths"] = {
    	CFrame.new(3253.26099, -1293.7677, 1435.24756, 0.21652025, -3.88184027e-08, -0.976278126, 1.20091812e-08, 1, -3.70982107e-08, 0.976278126, -3.69178754e-09, 0.21652025),
    	CFrame.new(3299.66333, -1302.85474, 1370.98621, -0.440755099, -5.91509552e-09, 0.897627413, -2.5926683e-09, 1, 5.31664224e-09, -0.897627413, 1.60869356e-11, -0.440755099),
    	CFrame.new(3250.94531, -1302.85547, 1324.77942, -0.998184919, 5.84032058e-08, 0.0602233484, 5.50187451e-08, 1, -5.78567096e-08, -0.0602233484, -5.44382814e-08, -0.998184919),
    	CFrame.new(3219.16309, -1294.03394, 1364.41492, 0.676777482, -4.18104094e-08, -0.736187637, 8.28715798e-08, 1, 1.93907237e-08, 0.736187637, -7.41322381e-08, 0.676777482)
    },
    ["Kohana"] = {
    	CFrame.new(-921.516602, 24.5000591, 373.572754, -0.315036476, -3.65496575e-08, -0.949079573, -2.09816324e-08, 1, -3.15460156e-08, 0.949079573, 9.97509186e-09, -0.315036476),
    	CFrame.new(-821.466125, 18.0640106, 442.570953, 0.502961993, 3.55151641e-08, 0.864308536, -2.61714685e-08, 1, -2.58610324e-08, -0.864308536, -9.61310764e-09, 0.502961993),
    	CFrame.new(-656.069275, 17.2500572, 450.77124, 0.899714053, -3.28262595e-09, -0.436479777, -5.17725418e-09, 1, -1.81925373e-08, 0.436479777, 1.86278477e-08, 0.899714053),
    	CFrame.new(-584.202759, 17.2500572, 459.276672, 0.0987685546, 5.48308599e-09, 0.995110452, -6.92575881e-08, 1, 1.36405531e-09, -0.995110452, -6.90536694e-08, 0.0987685546),
    },
    ["Underground Cellar"] = {
    	CFrame.new(2159.65723, -91.198143, -730.99707, -0.392579645, -1.64555736e-09, 0.919718027, 4.08579943e-08, 1, 1.92293435e-08, -0.919718027, 4.51268818e-08, -0.392579645),
    	CFrame.new(2114.22144, -91.1976471, -732.656738, -0.543168366, -3.4070105e-08, -0.839623809, 2.10003783e-08, 1, -5.41633582e-08, 0.839623809, -4.70522394e-08, -0.543168366),
    	CFrame.new(2134.35767, -91.1985855, -698.182983, 0.989448071, -1.28799131e-08, -0.144888103, 2.66212989e-08, 1, 9.29025887e-08, 0.144888103, -9.57793915e-08, 0.989448071),
    },
    ["Ancient Jungle"] = {
    	CFrame.new(1515.67676, 25.5616989, -306.595856, 0.763029754, -8.87780942e-08, 0.646363378, 5.24343307e-08, 1, 7.5451581e-08, -0.646363378, -2.36801707e-08, 0.763029754),
    	CFrame.new(1489.29553, 6.23855162, -342.620209, -0.831362545, 6.32348289e-08, -0.555730462, 7.59748353e-09, 1, 1.02421176e-07, 0.555730462, 8.09269736e-08, -0.831362545),
    	CFrame.new(1467.59143, 7.2090292, -324.716827, -0.086521171, 2.06461745e-08, -0.996250033, -4.92800183e-08, 1, 2.50037022e-08, 0.996250033, 5.12585707e-08, -0.086521171),
    },
    ["Secret Farm Ancient"] = {
    	CFrame.new(2110.91431, -58.1463356, -732.848816, 0.0894816518, -9.7328666e-08, -0.995988488, 5.18647809e-08, 1, -9.30610398e-08, 0.995988488, -4.3329468e-08, 0.0894816518)
    },
    ["The Temple (Unlock First)"] = {
    	CFrame.new(1479.11865, -22.1250019, -662.669373, 0.161120579, -2.03902815e-08, -0.986934721, -3.03227985e-08, 1, -2.56105164e-08, 0.986934721, 3.40530022e-08, 0.161120579),
    	CFrame.new(1465.41211, -22.1250019, -670.940002, -0.21706377, -2.10148947e-08, 0.976157427, 3.29077707e-08, 1, 2.88457365e-08, -0.976157427, 3.83845311e-08, -0.21706377),
    	CFrame.new(1496.21802, -32.1248207, -718.443481, 0.6035254, -8.12091461e-09, 0.797343791, -4.36373142e-08, 1, 4.32149143e-08, -0.797343791, -6.08752373e-08, 0.6035254),
    	CFrame.new(1470.30334, -12.2246475, -587.052612, -0.101084575, -9.68974163e-08, 0.994877815, -1.47451953e-08, 1, 9.5898109e-08, -0.994877815, -4.97584818e-09, -0.101084575),
    	CFrame.new(1451.19983, -22.1250019, -621.852478, -0.986927867, 8.68970318e-09, -0.161162451, 9.61592317e-09, 1, -4.96716179e-09, 0.161162451, -6.4519563e-09, -0.986927867),
    	CFrame.new(1499.44788, -22.1250019, -628.441711, -0.985374331, 7.20484294e-08, -0.170403719, 8.45688035e-08, 1, -6.62162876e-08, 0.170403719, -7.9658669e-08, -0.985374331)
    },
    ["Ancient Ruin"] = {
    	CFrame.new(6096.86865, -585.924683, 4667.34521, -0.0791911632, 5.17708685e-08, 0.996859431, -4.35256062e-08, 1, -5.53916735e-08, -0.996859431, -4.77754405e-08, -0.0791911632),
    	CFrame.new(6022.87109, -585.924194, 4631.0127, -0.669677734, -6.96009084e-10, -0.74265182, -5.20333909e-09, 1, 3.75485687e-09, 0.74265182, 6.37881348e-09, -0.669677734),
    	CFrame.new(6020.40186, -555.693909, 4513.84229, -0.0245459341, -2.1426688e-08, -0.999698699, -1.28175666e-08, 1, -2.11184314e-08, 0.999698699, 1.22953328e-08, -0.0245459341),
    	CFrame.new(6057.14893, -557.975098, 4485.46631, -0.985172093, -3.35700534e-08, -0.171569183, -3.98707982e-08, 1, 3.32783721e-08, 0.171569183, 3.9625526e-08, -0.985172093)
    },
    ["Pirate Cove"] = {
        CFrame.new(3469.79932, 4.19277096, 3496.23315, 0.598028243, -1.68198007e-08, 0.801475048, 3.59461581e-08, 1, -5.83551296e-09, -0.801475048, 3.22997487e-08, 0.598028243),
        CFrame.new(3423.27734, 4.19297075, 3433.854, -0.852984607, -4.74888253e-08, -0.521936059, -8.19830319e-08, 1, 4.29965361e-08, 0.521936059, 7.94652877e-08, -0.852984607)
    },
    ["Pirate Treasure Room"] = {
        CFrame.new(3342.62842, -303.497864, 3031.78931, -0.974473, 4.25567244e-08, 0.224504679, 2.92667632e-08, 1, -6.25245491e-08, -0.224504679, -5.43579617e-08, -0.974473),
        CFrame.new(3309.69922, -304.120056, 3031.46533, -0.833008647, 3.85916898e-08, -0.553259969, 1.32056241e-08, 1, 4.9870394e-08, 0.553259969, 3.42363258e-08, -0.833008647),
        CFrame.new(3338.89404, -302.507324, 3089.49756, 0.908972621, 1.19190865e-07, 0.416855842, -1.08876826e-07, 1, -4.85175207e-08, -0.416855842, -1.2848439e-09, 0.908972621)
    },
    ["Crystal Depths"] = {
        CFrame.new(5493.9292, -905.426758, 15388.6152, 0.988680065, 8.46355319e-10, 0.150039181, -6.88645307e-10, 1, -1.10308129e-09, -0.150039181, 9.8727071e-10, 0.988680065),
        CFrame.new(5479.45117, -905.566101, 15311.2441, -0.689366877, 2.96502733e-08, -0.724412382, 1.44044519e-08, 1, 2.72225069e-08, 0.724412382, 8.33153102e-09, -0.689366877),
        CFrame.new(5700.58936, -905.412964, 15329.3477, -0.967974067, -8.2060275e-08, 0.251050174, -8.28385538e-08, 1, 7.46743645e-09, -0.251050174, -1.35683482e-08, -0.967974067),
        CFrame.new(5734.73975, -901.84314, 15324.0293, -0.882043004, -1.53820352e-08, 0.471168876, -7.74457554e-10, 1, 3.11967341e-08, -0.471168876, 2.71519607e-08, -0.882043004),
    },
    ["Heartfelt Island"] = {
        CFrame.new(1125.25037, 3.76695824, 2605.67896, -0.990018368, 3.81225007e-08, 0.140938357, 5.03357533e-08, 1, 8.3091777e-08, -0.140938357, 8.93566181e-08, -0.990018368),
        CFrame.new(1103.02942, 3.32089734, 2842.01123, 0.98076731, 8.16230994e-08, 0.195180759, -7.19631359e-08, 1, -5.65834917e-08, -0.195180759, 4.14494181e-08, 0.98076731),
        CFrame.new(1043.38147, 3.76740384, 2800.51196, 0.452702761, -2.31139285e-08, -0.891661465, 2.74349432e-08, 1, -1.19934009e-08, 0.891661465, -1.90332372e-08, 0.452702761)
    }
}


local function parseNumberWithDot(str)
    if typeof(str) ~= "string" or str == "" then return nil end
    local clean = str:gsub("%.", "")
    if clean == "" then return nil end
    return tonumber(clean)
end
      
local obtainedFishUUIDs = {}
local obtainedLimit = 30 -- bisa diubah sesuai kebutuhan

local Remote = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]
Remote.OnClientEvent:Connect(function(_, _, data)
    if data and data.InventoryItem and data.InventoryItem.UUID then
        table.insert(obtainedFishUUIDs, data.InventoryItem.UUID)
    end
end)

local function sellItems()
    if #obtainedFishUUIDs > 0 then
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems"):InvokeServer()
    end

    obtainedFishUUIDs = {}
end

local function startAutoFarmLoop()
    NotifySuccess("Auto Farm Enabled", "Fishing started on island: " .. selectedIsland)

    while isAutoFarmRunning do  
        local islandSpots = farmLocations[selectedIsland]  
        if type(islandSpots) == "table" and #islandSpots > 0 then  
            location = islandSpots[math.random(1, #islandSpots)]  
        else  
            location = islandSpots  
        end  

        if not location then  
            NotifyError("Invalid Island", "Selected island name not found.")  
            return  
        end  

        local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)  
        local hrp = char and char:FindFirstChild("HumanoidRootPart")  
        if not hrp then  
            NotifyError("Teleport Failed", "HumanoidRootPart not found.")  
            return  
        end  

        hrp.CFrame = location  
        task.wait(1.5)  

        _G.ToggleAutoClick(true)
        
        while isAutoFarmRunning do
            if not isAutoFarmRunning then  
                _G.ToggleAutoClick(false)  
                NotifyWarning("Auto Farm Stopped", "Auto Farm manually disabled. Auto Fish stopped.")  
                break  
            end  
            task.wait(0.5)
        end
    end
end


local nameList = {}
local islandNamesToCode = {}

for code, name in pairs(islandCodes) do
    table.insert(nameList, name)
    islandNamesToCode[name] = code
end

table.sort(nameList)

local CodeIsland = AutoFarmTab:Dropdown({
    Title = "Farm Island",
    Values = nameList,
    Value = nameList[12],
    Callback = function(selectedName)
        local code = islandNamesToCode[selectedName]
        local islandName = islandCodes[code]
        if islandName and farmLocations[islandName] then
            selectedIsland = islandName
            NotifySuccess("Island Selected", "Farming location set to " .. islandName)
        else
            NotifyError("Invalid Selection", "The island name is not recognized.")
        end
    end
})

myConfig:Register("IslCode", CodeIsland)

local FishThres = AutoFarmTab:Input({
	Title = "Fish Threshold",
	Placeholder = "Example: 1500",
	Value = nil,
	Callback = function(value)
		local number = tonumber(value)
		if number then
		  obtainedLimit = number
			NotifySuccess("Threshold Set", "Fish threshold set to " .. number)
		else
		  NotifyError("Invalid Input", "Failed to convert input to number.")
		end
	end,
})

myConfig:Register("FishThreshold", FishThres)

local AutoFarm = AutoFarmTab:Toggle({
	Title = "Start Auto Farm",
	Callback = function(state)
		isAutoFarmRunning = state
		if state then
			startAutoFarmLoop()
		else
			StopAutoFish()
		end
	end
})

AutoFarmTab:Button({
    Title = "Sell All Fishes",
    Locked = false,
    Callback = function()
        sellAllFishes()
    end
})

myConfig:Register("AutoFarmStart", AutoFarm)

do
    --------------------------------------------------
    -- DEPENDENCIES
    --------------------------------------------------
    _G.Replion = require(
        ReplicatedStorage.Packages._Index["ytrev_replion@2.0.0-rc.3"].replion
    )

    _G.EventsReplion = _G.Replion.Client:WaitReplion("Events")

    --------------------------------------------------
    -- STATE
    --------------------------------------------------
    _G.AutoEventTeleport = {
        selectedEvent = "OFF",
        originalCFrame = nil,
        lastSpawnPos = nil,
    }
    
    _G.__LastEventSignature = nil

    --------------------------------------------------
    -- HELPERS
    --------------------------------------------------
    _G.getHRP = function()
        local char = LocalPlayer.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    _G.SafeTeleport = function(cf)
        local hrp = _G.getHRP()
        if hrp then
            hrp.CFrame = cf
        end
    end

    --------------------------------------------------
    -- EVENTS WITH SPAWN ONLY
    --------------------------------------------------
    _G.GetTeleportableEvents = function()
        local events = _G.EventsReplion:Get("Events")
        local spawns = _G.EventsReplion:Get("EventSpawnLocations")

        if typeof(events) ~= "table" or typeof(spawns) ~= "table" then
            return { "OFF" }
        end

        local results = { "OFF" }

        for _, name in ipairs(events) do
            if typeof(spawns[name]) == "Vector3" then
                table.insert(results, tostring(name))
            end
        end

        return results
    end
    
    _G.BuildEventSignature = function()
        local events = _G.EventsReplion:Get("Events")
        local spawns = _G.EventsReplion:Get("EventSpawnLocations")
    
        if typeof(events) ~= "table" or typeof(spawns) ~= "table" then
            return ""
        end
    
        local parts = {}
    
        for _, name in ipairs(events) do
            local pos = spawns[name]
            if typeof(pos) == "Vector3" then
                table.insert(
                    parts,
                    string.format(
                        "%s:%d,%d,%d",
                        name,
                        pos.X,
                        pos.Y,
                        pos.Z
                    )
                )
            end
        end
    
        table.sort(parts)
        return table.concat(parts, "|")
    end

    --------------------------------------------------
    -- CHECK EVENT ACTIVE
    --------------------------------------------------
    _G.IsEventActive = function(name)
        if name == "OFF" then return false end

        local events = _G.EventsReplion:Get("Events")
        if typeof(events) ~= "table" then return false end

        for _, ev in ipairs(events) do
            if ev == name then
                return true
            end
        end
        return false
    end

    --------------------------------------------------
    -- APPLY TELEPORT (AUTO FOLLOW)
    --------------------------------------------------
    _G.ApplyEventTeleport = function()
        local selected = _G.AutoEventTeleport.selectedEvent
    
        -- JANGAN sentuh posisi kalau OFF
        if selected == "OFF" then
            _G.AutoEventTeleport.lastSpawnPos = nil
            return
        end

        -- event yang DIPILIH benar-benar berakhir
        if selected ~= "OFF" and not _G.IsEventActive(selected) then
            if _G.AutoEventTeleport.originalCFrame then
                _G.SafeTeleport(_G.AutoEventTeleport.originalCFrame)
            end
        
            _G.AutoEventTeleport.selectedEvent = "OFF"
            _G.AutoEventTeleport.lastSpawnPos = nil
        
            if _G.AutoEventDropdown then
                _G.AutoEventDropdown:Refresh(_G.GetTeleportableEvents())
            end
        
            return
        end

        if not _G.IsEventActive(selected) then
            if _G.AutoEventTeleport.originalCFrame then
                _G.SafeTeleport(_G.AutoEventTeleport.originalCFrame)
            end
            _G.AutoEventTeleport.selectedEvent = "OFF"
            _G.AutoEventTeleport.lastSpawnPos = nil
            return
        end

        local spawns = _G.EventsReplion:Get("EventSpawnLocations")
        local pos = spawns and spawns[selected]

        if typeof(pos) == "Vector3" then
            if not _G.AutoEventTeleport.lastSpawnPos
            or (_G.AutoEventTeleport.lastSpawnPos - pos).Magnitude > 3 then

                _G.AutoEventTeleport.lastSpawnPos = pos
                local targetCF = CFrame.new(pos + Vector3.new(0, 2, 0))
                _G.SafeTeleport(targetCF)

                if _G.ToggleBlockOnce then
                    pcall(function()
                        _G.ToggleBlockOnce(true)
                    end)
                end
            end
        end
    end
    
    _G.ForceRefreshEvents = function()
        -- akses ulang semua path agar Replion "bangun"
        pcall(function()
            _G.EventsReplion:Get("Events")
            _G.EventsReplion:Get("EventSpawnLocations")
        end)
    end

    _G.AutoEventDropdown = AutoFarmTab:Dropdown({
        Title = "Event Teleport",
        Values = _G.GetTeleportableEvents(),
        Value = "OFF",
        Callback = function(v)
            local prev = _G.AutoEventTeleport.selectedEvent
            _G.AutoEventTeleport.selectedEvent = v
        
            -- simpan posisi awal saat PERTAMA kali masuk event
            if prev == "OFF" and v ~= "OFF" then
                local hrp = _G.getHRP()
                if hrp then
                    _G.AutoEventTeleport.originalCFrame = hrp.CFrame
                end
            end
        
            -- USER PILIH OFF → BALIK KE POSISI AWAL
            if v == "OFF" then
                if _G.AutoEventTeleport.originalCFrame then
                    _G.SafeTeleport(_G.AutoEventTeleport.originalCFrame)
                end
        
                _G.AutoEventTeleport.lastSpawnPos = nil
                return
            end
        
            -- user pilih event
            _G.AutoEventTeleport.lastSpawnPos = nil
            _G.ApplyEventTeleport()
        end
    })

    task.spawn(function()
        while true do
            task.wait(0.5)
    
            local sig = _G.BuildEventSignature()
    
            if sig ~= _G.__LastEventSignature then
                _G.__LastEventSignature = sig
    
                if _G.AutoEventDropdown then
                    _G.AutoEventDropdown:Refresh(
                        _G.GetTeleportableEvents()
                    )
                end
    
                -- HANYA follow jika user memang sedang di event
                if _G.AutoEventTeleport.selectedEvent ~= "OFF" then
                    _G.ApplyEventTeleport()
                end
            end
        end
    end)
end

AutoFarmTab:Button({
    Title = "Sell All Fishes",
    Locked = false,
    Callback = function()
        sellAllFishes()
    end
})

AutoFarmTab:Button({
    Title = "Auto Enchant Rod",
    Callback = function()
        local ENCHANT_POSITION = Vector3.new(3231, -1303, 1402)
		local char = workspace:WaitForChild("Characters"):FindFirstChild(LocalPlayer.Name)
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if not hrp then
			NotifyError("Auto Enchant Rod", "Failed to get character HRP.")
			return
		end

		NotifyInfo("Preparing Enchant...", "Please manually place Enchant Stone into slot 5 before we begin...", 5)

		task.wait(3)

		local Player = game:GetService("Players").LocalPlayer
		local slot5 = Player.PlayerGui.Backpack.Display:GetChildren()[10]

		local itemName = slot5 and slot5:FindFirstChild("Inner") and slot5.Inner:FindFirstChild("Tags") and slot5.Inner.Tags:FindFirstChild("ItemName")

		if not itemName or not itemName.Text:lower():find("enchant") then
			NotifyError("Auto Enchant Rod", "Slot 5 does not contain an Enchant Stone.")
			return
		end

		NotifyInfo("Enchanting...", "It is in the process of Enchanting, please wait until the Enchantment is complete", 7)

		local originalPosition = hrp.Position
		task.wait(1)
		hrp.CFrame = CFrame.new(ENCHANT_POSITION + Vector3.new(0, 5, 0))
		task.wait(1.2)

		local equipRod = net:WaitForChild("RE/EquipToolFromHotbar")
		local activateEnchant = net:WaitForChild("RE/ActivateEnchantingAltar")

		pcall(function()
			equipRod:FireServer(5)
			task.wait(0.5)
			activateEnchant:FireServer()
			task.wait(7)
			NotifySuccess("Enchant", "Successfully Enchanted!", 3)
		end)

		task.wait(0.9)
		hrp.CFrame = CFrame.new(originalPosition + Vector3.new(0, 3, 0))
    end
})

-------------------------------------------
----- =======[ ARTIFACT TAB ]
-------------------------------------------

local REPlaceLeverItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlaceLeverItem"]

_G.UnlockTemple = function()
    task.spawn(function()
        local Artifacts = {
            "Hourglass Diamond Artifact",
            "Crescent Artifact",
            "Arrow Artifact",
            "Diamond Artifact"
        }

        for _, artifact in ipairs(Artifacts) do
            REPlaceLeverItem:FireServer(artifact)
            NotifyInfo("Temple Unlock", "Placing: " .. artifact)
            task.wait(2.1)
        end

        NotifySuccess("Temple Unlock", "All Artifacts placed successfully!")
    end)
end


_G.ArtifactSpots = {
    ["Spot 1"] = CFrame.new(1404.16931, 6.38866091, 118.118126, -0.964853525, 8.69606822e-08, 0.262788326, 9.85441346e-08, 1, 3.08992689e-08, -0.262788326, 5.5709517e-08, -0.964853525),
    ["Spot 2"] = CFrame.new(883.969788, 6.62499952, -338.560059, -0.325799465, 2.72482961e-08, 0.945438921, 3.40634649e-08, 1, -1.70824759e-08, -0.945438921, 2.6639464e-08, -0.325799465),
    ["Spot 3"] = CFrame.new(1834.76819, 6.62499952, -296.731476, 0.413336992, -7.92166972e-08, -0.910578132, 3.06007166e-08, 1, -7.31055181e-08, 0.910578132, 2.35287234e-09, 0.413336992),
    ["Spot 4"] = CFrame.new(1483.25586, 6.62499952, -848.38031, -0.986296117, 2.72397838e-08, 0.164984599, 3.60663037e-08, 1, 5.05033348e-08, -0.164984599, 5.57616318e-08, -0.986296117)
}

local REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]

local saveFile = "ArtifactProgress.json"

if isfile(saveFile) then
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(saveFile))
    end)
    if success and type(data) == "table" then
        _G.ArtifactCollected = data.ArtifactCollected or 0
        _G.CurrentSpot = data.CurrentSpot or 1
    else
        _G.ArtifactCollected = 0
        _G.CurrentSpot = 1
    end
else
    _G.ArtifactCollected = 0
    _G.CurrentSpot = 1
end

_G.ArtifactFarmEnabled = false

local function saveProgress()
    local data = {
        ArtifactCollected = _G.ArtifactCollected,
        CurrentSpot = _G.CurrentSpot
    }
    writefile(saveFile, game:GetService("HttpService"):JSONEncode(data))
end

_G.StartArtifactFarm = function()
    if _G.ArtifactFarmEnabled then return end
    _G.ArtifactFarmEnabled = true

    updateParagraph("Auto Farm Artifact", ("Resuming from Spot %d..."):format(_G.CurrentSpot))

    local Player = game.Players.LocalPlayer
    task.wait(1)
    Player.Character:PivotTo(_G.ArtifactSpots["Spot " .. tostring(_G.CurrentSpot)])
    task.wait(1)

    _G.ToggleAutoClick(true)
    _G.AutoFishStarted = true

    _G.ArtifactConnection = REFishCaught.OnClientEvent:Connect(function(fishName, data)
        if string.find(fishName, "Artifact") then
            _G.ArtifactCollected += 1
            saveProgress()

            updateParagraph(
                "Auto Farm Artifact",
                ("Artifact Found : %s\nTotal: %d/4"):format(fishName, _G.ArtifactCollected)
            )

            if _G.ArtifactCollected < 4 then
                _G.CurrentSpot += 1
                saveProgress()
                local spotName = "Spot " .. tostring(_G.CurrentSpot)
                if _G.ArtifactSpots[spotName] then
                    task.wait(2)
                    Player.Character:PivotTo(_G.ArtifactSpots[spotName])
                    updateParagraph("Auto Farm Artifact",
                        ("Artifact Found : %s\nTotal : %d/4\n\nTeleporting to %s..."):format(
                            fishName,
                            _G.ArtifactCollected,
                            spotName
                        )
                    )
                    task.wait(1)
                end
            else
                updateParagraph("Auto Farm Artifact", "All Artifacts collected! Unlocking Temple...")
                _G.ToggleAutoClick(false)
                task.wait(1.5)
                if typeof(_G.UnlockTemple) == "function" then
                    _G.UnlockTemple()
                end
                _G.StopArtifactFarm()
                delfile(saveFile)
            end
        end
    end)
end

_G.StopArtifactFarm = function()
    StopAutoFish()
    _G.ArtifactFarmEnabled = false
    _G.AutoFishStarted = false
    if _G.ArtifactConnection then
        _G.ArtifactConnection:Disconnect()
        _G.ArtifactConnection = nil
    end
    saveProgress()
    updateParagraph("Auto Farm Artifact", "Auto Farm Artifact stopped. Progress saved.")
end

function updateParagraph(title, desc)
    if _G.ArtifactParagraph then
        _G.ArtifactParagraph:SetDesc(desc)
    end
end

_G.ArtifactParagraph = AutoFarmArt:Paragraph({
    Title = "Auto Farm Artifact",
    Desc = "Waiting for activation...",
    Color = "Green",
})

AutoFarmArt:Toggle({
    Title = "Auto Farm Artifact",
    Desc = "Automatically collects 4 Artifacts and unlocks The Temple.",
    Default = false,
    Callback = function(state)
        if state then
            _G.StartArtifactFarm()
        else
            _G.StopArtifactFarm()
        end
    end
})

local spotNames = {}
for name in pairs(_G.ArtifactSpots) do
    table.insert(spotNames, name)
end

AutoFarmArt:Dropdown({
    Title = "Teleport to Lever Temple",
    Values = spotNames,
    Value = spotNames[1],
    Callback = function(selected)
        local spotCFrame = _G.ArtifactSpots[selected]
        if spotCFrame then
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hrp then
                hrp.CFrame = spotCFrame
                NotifySuccess("Lever Temple", "Teleported to " .. selected)
            else
                warn("HumanoidRootPart not found!")
            end
        else
            warn("Invalid teleport spot: " .. tostring(selected))
        end
    end
})

AutoFarmArt:Button({
    Title = "Unlock The Temple",
    Desc = "Still need Artifacts!",
    Justify = "Center",
    Callback = function()
        _G.UnlockTemple()
    end
})


-------------------------------------------
----- =======[ AUTO WEATHER TAB ]
-------------------------------------------


local weatherActive = {}
local weatherData = {
    ["Storm"] = { duration = 900 },
    ["Cloudy"] = { duration = 900 },
    ["Snow"] = { duration = 900 },
    ["Wind"] = { duration = 900 },
    ["Radiant"] = { duration = 900 }
}

local function randomDelay(min, max)
    return math.random(min * 100, max * 100) / 100
end

local function autoBuyWeather(weatherType)
    local purchaseRemote = ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")
        :WaitForChild("RF/PurchaseWeatherEvent")

    task.spawn(function()
        while weatherActive[weatherType] do
            pcall(function()
                purchaseRemote:InvokeServer(weatherType)
                NotifySuccess("Weather Purchased", "Successfully activated " .. weatherType)

                task.wait(weatherData[weatherType].duration)

                local randomWait = randomDelay(1, 5)
                NotifyInfo("Waiting...", "Delay before next purchase: " .. tostring(randomWait) .. "s")
                task.wait(randomWait)
            end)
        end
    end)
end


local WeatherDropdown = WeatherTab:Dropdown({
    Title = "Auto Buy Weather",
    Values = { "Storm", "Cloudy", "Snow", "Wind" },
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
    	  if not blockNotif then
    	  	blockNotif = true
    	  	return
    	  end
        for weatherType, active in pairs(weatherActive) do
            if active and not table.find(selected, weatherType) then
                weatherActive[weatherType] = false
                NotifyWarning("Auto Weather", "Auto buying " .. weatherType .. " has been stopped.")
            end
        end
        for _, weatherType in pairs(selected) do
            if not weatherActive[weatherType] then
                weatherActive[weatherType] = true
                NotifyInfo("Auto Weather", "Auto buying " .. weatherType .. " has started!")
                autoBuyWeather(weatherType)
            end
        end
    end
})

myConfig:Register("WeatherDropdown", WeatherDropdown)

-------------------------------------------
----- =======[ PLAYER TAB ]
-------------------------------------------

-------------------------------------------
----- =======[ UTILITY TAB ]
-------------------------------------------

_G.RFRedeemCode = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RedeemCode"]

_G.RedeemCodes = {
    "BLAMETALON",
    "FISHMAS2025",
    "GOLDENSHARK",
    "THANKYOU",
}

_G.RedeemAllCodes = function()
    for _, code in ipairs(_G.RedeemCodes) do
        local success, result = pcall(function()
            return _G.RFRedeemCode:InvokeServer(code)
        end)
        task.wait(1)
    end
end

Utils:Button({
    Title = "Redeem All Codes",
    Locked = false,
    Callback = function()
        _G.RedeemAllCodes()
    end
})

local RFPurchaseMarketItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseMarketItem"]

local merchantItems = {
    ["Luck Totem | 2M"] = 5,
    ["Royal Bait | 400K+"] = 4,
}

local function getKeys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

Utils:Dropdown({
    Title = "Traveling Merchant",
    Desc = "Select an item to purchase from Traveling Merchant",
    Values = getKeys(merchantItems),
    Callback = function(selected)
        local itemID = merchantItems[selected]
        if itemID then
            local success, err = pcall(function()
                RFPurchaseMarketItem:InvokeServer(itemID)
            end)
            if success then
                NotifyInfo("Purchase Success", "Successfully bought: " .. selected)
            else
                NotifyInfo("Purchase Failed", "Error: " .. tostring(err))
            end
        end
    end
})


local islandCoords = {
	["01"] = { name = "Weather Machine", position = Vector3.new(-1459.3772, 14.7103214, 1831.5188, 0.777951121, 2.52131862e-08, -0.628324807, -5.24126378e-08, 1, -2.47663063e-08, 0.628324807, 5.21991339e-08, 0.777951121) },
	["02"] = { name = "Esoteric Depths", position = Vector3.new(3157, -1303, 1439) },
	["03"] = { name = "Tropical Grove", position = Vector3.new(-2165.05469, 2.77070165, 3639.87451, -0.589090407, -3.61497356e-08, -0.808067143, -3.20645626e-08, 1, -2.13606164e-08, 0.808067143, 1.3326984e-08, -0.589090407) },
	["04"] = { name = "Stingray Shores", position = Vector3.new(247.130951, 2.47001815, 3001.72412, -0.724809051, -8.27166033e-08, -0.688949764, -8.16509669e-08, 1, -3.41610367e-08, 0.688949764, 3.14931867e-08, -0.724809051) },
	["05"] = { name = "Kohana Volcano", position = Vector3.new(-654.994934, 57.2567711, 75.098526, -0.540957272, 2.58946509e-09, -0.841050088, -7.58775585e-08, 1, 5.18827363e-08, 0.841050088, 9.1883166e-08, -0.540957272) },
	["06"] = { name = "Coral Reefs", position = Vector3.new(-3118.39624, 2.42531538, 2135.26392, 0.92336154, -1.0069185e-07, -0.383931547, 8.0607947e-08, 1, -6.84016968e-08, 0.383931547, 3.22115596e-08, 0.92336154) },
	["07"] = { name = "Crater Island", position = Vector3.new(1066.1864, 57.2025681, 5045.5542, -0.682534158, 1.00865822e-08, 0.730853677, -5.8900711e-09, 1, -1.93017531e-08, -0.730853677, -1.74788859e-08, -0.682534158) },
	["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
	["09"] = { name = "Winter Fest", position = Vector3.new(2036.15308, 6.54998732, 3381.88916, 0.943401575, 4.71338666e-08, -0.331652641, -3.28136842e-08, 1, 4.87781051e-08, 0.331652641, -3.51345975e-08, 0.943401575) },
	["10"] = { name = "Isoteric Island", position = Vector3.new(1987, 4, 1400) },
	["11"] = { name = "Treasure Hall", position = Vector3.new(-3600.72632, -276.06427, -1640.79663, -0.696130812, -6.0491181e-09, 0.717914939, -1.09490363e-08, 1, -2.19084972e-09, -0.717914939, -9.38559541e-09, -0.696130812) },
	["12"] = { name = "Lost Shore", position = Vector3.new(-3663, 38, -989 ) },
	["13"] = { name = "Sishypus Statue", position = Vector3.new(-3722.92139, -101.130035, -955.649902, 0.777723014, -1.41385739e-08, 0.628607094, -2.57670365e-08, 1, 5.43713092e-08, -0.628607094, -5.84831632e-08, 0.777723014) },
	["14"] = { name = "Ancient Jungle", position = Vector3.new(1478, 131, -613) },
	["15"] = { name = "The Temple", position = Vector3.new(1477, -22, -631) },
	["16"] = { name = "Underground Cellar", position = Vector3.new(2133, -91, -674)},
	["17"] = { name = "Ancient Ruin", position = Vector3.new(6052, -546, 4427)},
    ["21"] = {name = "Pirate Cove", position = Vector3.new(3497, 4, 3447) },
	["83"] = {name = "Crystal Pessage", position = Vector3.new(3433, -299, 3365) },
    ["72"] = {name = "Crystal Depths", position = Vector3.new(5494, -905, 15389) },
    ["39"] = {name = "Heartfelt Island", position = Vector3.new(1083, 5, 2721)},
}

local islandNames = {}
for _, data in pairs(islandCoords) do
    table.insert(islandNames, data.name)
end

Utils:Dropdown({
    Title = "Island Selector",
    Desc = "Select island to teleport",
    Values = islandNames,
    Value = islandNames[1],
    Callback = function(selectedName)
        for code, data in pairs(islandCoords) do
            if data.name == selectedName then
                local success, err = pcall(function()
                    local charFolder = workspace:WaitForChild("Characters", 5)
                    local char = charFolder:FindFirstChild(LocalPlayer.Name)
                    if not char then error("Character not found") end
                    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
                    if not hrp then error("HumanoidRootPart not found") end
                    hrp.CFrame = CFrame.new(data.position)
                end)

                if success then
                    NotifySuccess("Teleported!", "You are now at " .. selectedName)
                else
                    NotifyError("Teleport Failed", tostring(err))
                end
                break
            end
        end
    end
})



local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local HRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local Items = ReplicatedStorage:WaitForChild("Items")
local Baits = ReplicatedStorage:WaitForChild("Baits")
local net = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")


local npcCFrame = CFrame.new(
	66.866745, 4.62500143, 2858.98535,
	-0.981261611, 5.77215005e-08, -0.192680314,
	6.94250204e-08, 1, -5.39889484e-08,
	0.192680314, -6.63541186e-08, -0.981261611
)


local function FadeScreen(duration)
	local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame", gui)
	frame.BackgroundColor3 = Color3.new(255, 255, 255)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1

	local tweenIn = TweenService:Create(frame, TweenInfo.new(0.2), { BackgroundTransparency = 0.9 })
	tweenIn:Play()

	wait(duration)

	local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
	tweenOut:Play()
end

local function SafePurchase(callback)
	local originalCFrame = HRP.CFrame
	HRP.CFrame = npcCFrame
	pcall(callback)
	wait(99999)
	HRP.CFrame = originalCFrame
end

-- RODS DROPDOWN
local rodOptions = {}
local rodData = {}

for _, rod in ipairs(Items:GetChildren()) do
	if rod:IsA("ModuleScript") then
		local success, module = pcall(require, rod)
		if success and module and module.Data and module.Data.Type == "Fishing Rods" then
			local id = module.Data.Id
			local name = module.Data.Name or rod.Name
			local price = module.Price or module.Data.Price

			if price then
				table.insert(rodOptions, name .. " | Price: " .. tostring(price))
				rodData[name] = id
			end
		end
	end
end

Utils:Dropdown({
	Title = "Rod Shop",
	Desc = "Select Rod to Buy",
	Values = rodOptions,
	Value = nil,
	Callback = function(option)
		local selectedName = option:split(" |")[1]
		local id = rodData[selectedName]

		SafePurchase(function()
			net:WaitForChild("RF/PurchaseFishingRod"):InvokeServer(id)
			NotifySuccess("Rod Purchased", selectedName .. " has been successfully purchased!")
		end)
	end,
})


local baitOptions = {}
local baitData = {}

for _, bait in ipairs(Baits:GetChildren()) do
	if bait:IsA("ModuleScript") then
		local success, module = pcall(require, bait)
		if success and module and module.Data then
			local id = module.Data.Id
			local name = module.Data.Name or bait.Name
			local price = module.Price or module.Data.Price

			if price then
				table.insert(baitOptions, name .. " | Price: " .. tostring(price))
				baitData[name] = id
			end
		end
	end
end

Utils:Dropdown({
	Title = "Baits Shop",
	Desc = "Select Baits to Buy",
	Values = baitOptions,
	Value = nil,
	Callback = function(option)
		local selectedName = option:split(" |")[1]
		local id = baitData[selectedName]

		SafePurchase(function()
			net:WaitForChild("RF/PurchaseBait"):InvokeServer(id)
			NotifySuccess("Bait Purchased", selectedName .. " has been successfully purchased!")
		end)
	end,
})

local npcFolder = game:GetService("ReplicatedStorage"):WaitForChild("NPC")

local npcList = {}
for _, npc in pairs(npcFolder:GetChildren()) do
	if npc:IsA("Model") then
		local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
		if hrp then
			table.insert(npcList, npc.Name)
		end
	end
end


-------------------------------------------
----- =======[ SETTINGS TAB ]
-------------------------------------------

local RunService = game:GetService("RunService")

function _G.Disable3DRendering(enabled)
	if enabled then
		RunService:Set3dRenderingEnabled(false)
	else
		RunService:Set3dRenderingEnabled(true)
	end
end

SettingsTab:Toggle({
    Title = "Disable 3D Rendering",
    Value = false,
    Callback = function(state)
        _G.Disable3DRendering(state)
    end
})

SettingsTab:Button({  
	Title = "Boost FPS (Ultra Low Graphics)",  
	Callback = function()  
		for _, v in pairs(game:GetDescendants()) do  
			if v:IsA("BasePart") then  
				v.Material = Enum.Material.SmoothPlastic  
				v.Reflectance = 0  
				v.CastShadow = false  
				v.Transparency = v.Transparency > 0.5 and 1 or v.Transparency  
			elseif v:IsA("Decal") or v:IsA("Texture") then  
				v.Transparency = 1  
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Explosion") then  
				v.Enabled = false  
			elseif v:IsA("Beam") or v:IsA("SpotLight") or v:IsA("PointLight") or v:IsA("SurfaceLight") then  
				v.Enabled = false  
			elseif v:IsA("ShirtGraphic") or v:IsA("Shirt") or v:IsA("Pants") then  
				v:Destroy()  
			end  
		end  
  
		local Lighting = game:GetService("Lighting")  
		for _, effect in pairs(Lighting:GetChildren()) do  
			if effect:IsA("PostEffect") then  
				effect.Enabled = false  
			end  
		end  
		Lighting.GlobalShadows = false  
		Lighting.FogEnd = 9e9  
		Lighting.Brightness = 1  
		Lighting.EnvironmentDiffuseScale = 0  
		Lighting.EnvironmentSpecularScale = 0  
		Lighting.ClockTime = 12  
		Lighting.Ambient = Color3.new(1, 1, 1)  
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)  
  
		local Terrain = workspace:FindFirstChildOfClass("Terrain")  
		if Terrain then  
			Terrain.WaterWaveSize = 0  
			Terrain.WaterWaveSpeed = 0  
			Terrain.WaterReflectance = 0  
			Terrain.WaterTransparency = 1  
			Terrain.Decoration = false  
		end  
  
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01  
		settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01  
		settings().Rendering.TextureQuality = Enum.TextureQuality.Low  
  
		game:GetService("UserSettings").GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1  
		game:GetService("UserSettings").GameSettings.Fullscreen = true  
  
		for _, s in pairs(workspace:GetDescendants()) do  
			if s:IsA("Sound") and s.Playing and s.Volume > 0.5 then  
				s.Volume = 0.1  
			end  
		end  
  
		if collectgarbage then  
			collectgarbage("collect")  
		end  
  
		local fullWhite = Instance.new("ScreenGui")  
		fullWhite.Name = "FullWhiteScreen"  
		fullWhite.ResetOnSpawn = false  
		fullWhite.IgnoreGuiInset = true  
		fullWhite.ZIndexBehavior = Enum.ZIndexBehavior.Global  
		fullWhite.DisplayOrder = 999999999  
		fullWhite.Parent = game:GetService("CoreGui")  
  
		local whiteFrame = Instance.new("Frame")  
		whiteFrame.Size = UDim2.new(1, 0, 1, 0)  
		whiteFrame.BackgroundColor3 = Color3.new(0, 0, 0)  
		whiteFrame.BorderSizePixel = 0  
		whiteFrame.ZIndex = 999999999  
		whiteFrame.Parent = fullWhite  
  
		-- Tambahan keamanan agar layer putih tetap di layar selamanya  
		task.spawn(function()  
			while task.wait(0.5) do  
				if not fullWhite or not fullWhite.Parent then  
					fullWhite.Parent = game:GetService("CoreGui")  
				end  
			end  
		end)  
  
		NotifySuccess("Boost FPS", "Boost FPS mode applied successfully with Full White Screen!")  
	end  
})  

SettingsTab:Button({
	Title = "HDR Shader",
	Callback = function()
		loadstring(game:HttpGet("https://paste.monster/IVE9Xt3YJWkp/raw/"))()
	end,
})

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local function Rejoin()
	local player = Players.LocalPlayer
	if player then
		TeleportService:Teleport(game.PlaceId, player)
	end
end

local function ServerHop()
	local placeId = game.PlaceId
	local servers = {}
	local cursor = ""
	local found = false

	repeat
		local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
		if cursor ~= "" then
			url = url .. "&cursor=" .. cursor
		end

		local success, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if success and result and result.data then
			for _, server in pairs(result.data) do
				if server.playing < server.maxPlayers and server.id ~= game.JobId then
					table.insert(servers, server.id)
				end
			end
			cursor = result.nextPageCursor or ""
		else
			break
		end
	until not cursor or #servers > 0

	if #servers > 0 then
		local targetServer = servers[math.random(1, #servers)]
		TeleportService:TeleportToPlaceInstance(placeId, targetServer, LocalPlayer)
	else
		NotifyError("Server Hop Failed", "No servers available or all are full!")
	end
end

local Keybind = SettingsTab:Keybind({
    Title = "Keybind",
    Desc = "Keybind to open UI",
    Value = "G",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})

myConfig:Register("Keybind", Keybind)

SettingsTab:Button({
	Title = "Rejoin Server",
	Callback = function()
		Rejoin()
	end,
})

SettingsTab:Button({
	Title = "Server Hop (New Server)",
	Callback = function()
		ServerHop()
	end,
})


local LocalPlayer = game:GetService("Players").LocalPlayer
local REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]

local webhookPath = nil
local FishWebhookEnabled = true

local function validateWebhook(path)
	if not path:match("^%d+/.+") then
		return false, "Invalid format"
	end

	local url = "https://discord.com/api/webhooks/" .. path
	local success, response = pcall(function()
		return game:HttpGet(url)
	end)

	if not success then
		return false, "Failed to connect to Discord"
	end

	local ok, data = pcall(function()
		return HttpService:JSONDecode(response)
	end)

	if not ok or not data or not data.channel_id then
		return false, "Invalid"
	end

	return true, data.channel_id
end

local apiKey = SettingsTab:Input({
    Title = "Key Notification",
    Desc = "Input your private key!",
    Placeholder = "Enter Key....",
    Callback = function(text)
        webhookPath = text
        local isValid, result = validateWebhook(webhookPath)
        if isValid then
            WindUI:Notify({
                Title = "Key Valid",
                Content = "Channel ID: " .. tostring(result),
                Duration = 5,
                Icon = "circle-check"
            })
        else
            WindUI:Notify({
                Title = "Key Invalid",
                Content = tostring(result),
                Duration = 5,
                Icon = "ban"
            })
        end
    end
})

myConfig:Register("FishApiKey", apiKey)

SettingsTab:Toggle({
    Title = "Fish Notification",
    Desc = "Send fish notifications to Discord",
    Value = true,
    Callback = function(state)
        FishWebhookEnabled = state
    end
})

local FishCategories = {
    ["Secret"] = {
        "Ancient Lochness Monster", "Ancient Whale", "Blob Shark", "Bloodmoon Whale", "Bone Whale",
        "Cryoshade Glider", "Crystal Crab", "Dead Zombie Shark", "Eerie Shark", "Elshark Gran Maja",
        "Frostborn Shark", "Ghost Shark", "Ghost Worm Fish", "Giant Squid", "Gladiator Shark",
        "Great Christmas Whale", "Great Whale", "King Jelly", "Lochness Monster", "Megalodon",
        "Monster Shark", "Mosasaur Shark", "Orca", "Queen Crab", "Robot Kraken", "Scare",
        "Skeleton Narwhal", "Talon Serpent", "Thin Armor Shark", "Wild Serpent", "Worm Fish",
        "Zombie Megalodon", "Zombie Shark"
    },

    ["Mythic"] = {
        "Ancient Relic Crocodile", "Ancient Squid", "Armor Catfish", "Blob Fish", "Cavern Dweller",
        "Crocodile", "Dark Pumpkin Appafish", "Flatheaded Whale Shark", "Fossilized Shark",
        "Frankenstein Longsnapper", "Gingerbread Shark", "Hammerhead Mummy",
        "Hybodus Shark", "King Crab", "Loving Shark", "Luminous Fish", "Magma Shark",
        "Mammoth Appafish", "Panther Eel", "Plasma Serpent", "Primordial Octopus",
        "Pumpkin Ray", "Runic Sea Crustacean", "Runic Squid", "Sea Crustacean",
        "Sharp One", "Starlight Manta Ray"
    },

    ["Legendary"] = {
        "Abyss Seahorse", "Ancient Pufferfish", "Blueflame Ray", "Crystal Salamander",
        "Deep Sea Crab", "Diamond Ring", "Dotted Stingray", "Fish Fossil", "Flying Manta",
        "Ghastly Crab", "Ghastly Hermit Crab", "Gingerbread Turtle", "Hammerhead Shark",
        "Hawks Turtle", "Lake Sturgeon", "Lined Cardinal Fish", "Loggerhead Turtle",
        "Manoai Statue Fish", "Manta Ray", "Plasma Shark", "Primal Axolotl",
        "Primal Lobster", "Prismy Seahorse", "Pumpkin Carved Shark", "Pumpkin Jellyfish",
        "Pumpkin StoneTurtle", "Ruby", "Runic Axolotl", "Runic Lobster",
        "Sacred Guardian Squid", "Saw Fish", "Strippled Seahorse", "Synodontis",
        "Temple Spokes Tuna", "Thresher Shark", "Wizard Stingray"
    },
}


local FishDataById = {}
for _, item in pairs(ReplicatedStorage.Items:GetChildren()) do
	local ok, data = pcall(require, item)
	if ok and data.Data and data.Data.Type == "Fish" then
		FishDataById[data.Data.Id] = {
			Name = data.Data.Name,
			SellPrice = data.SellPrice or 0
		}
	end
end


local VariantsByName = {}
for _, v in pairs(ReplicatedStorage.Variants:GetChildren()) do
	local ok, data = pcall(require, v)
	if ok and data.Data and data.Data.Type == "Variant" then
		VariantsByName[data.Data.Name] = data.SellMultiplier or 1
	end
end


local SelectedCategories = {}

SettingsTab:Dropdown({
	Title = "Select Fish Categories",
	Desc = "Choose which categories to send to webhook",
	Values = {"Secret", "Legendary", "Mythic"},
	Multi = true,
	Default = {"Secret"},
	Callback = function(selected)
		SelectedCategories = selected
		WindUI:Notify({
			Title = "Fish Category Updated",
			Content = "Now tracking: " .. table.concat(SelectedCategories, ", "),
			Duration = 5,
			Icon = "circle-check"
		})
	end
})

SettingsTab:Button({
    Title = "Test Webhook",
    Description = "Trigger Test Fish Notification",
    Callback = function()
        local randomWeight = math.random(20000, 25000)

        firesignal(REObtainedNewFishNotification.OnClientEvent, 
            218,
            {
                Weight = randomWeight
            },
            {
                CustomDuration = 5,
                Type = "Item",
                ItemType = "Fishes",
                _newlyIndexed = false,
                InventoryItem = {
                    Id = 218,
                    Favorited = false,
                    UUID = game:GetService("HttpService"):GenerateGUID(false),
                    Metadata = {
                        Weight = randomWeight
                    }
                },
                ItemId = 218
            },
            false
        )
    end
})

-- Check target fish
local function isTargetFish(fishName)
	for _, category in pairs(SelectedCategories) do
		local list = FishCategories[category]
		if list then
			for _, keyword in pairs(list) do
				if string.find(string.lower(fishName), string.lower(keyword)) then
					return true
				end
			end
		end
	end
	return false
end

-- Roblox image fetcher
local function GetRobloxImage(assetId)
	local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&size=420x420&format=Png&isCircular=false"
	local success, response = pcall(game.HttpGet, game, url)
	if success then
		local data = HttpService:JSONDecode(response)
		if data and data.data and data.data[1] and data.data[1].imageUrl then
			return data.data[1].imageUrl
		end
	end
	return nil
end

-- Send Webhook
local function sendFishWebhook(fishName, rarityText, assetId, itemId, variantId)

	local WebhookURL = "https://discord.com/api/webhooks/1413650840941498458/lj324JUNY2enPwBDyy0g1IjgI2F5IqrnSxqSBJ7gMvaS1Ey0jNeszglVu8CaMXRyx1-x"
	local username = LocalPlayer.DisplayName
	local imageUrl = "https://i.imgur.com/placeholder.png" -- Default placeholder

    task.spawn(function()
        local fetchedImage = GetRobloxImage(assetId)
        if fetchedImage then
            imageUrl = fetchedImage
        end
    end)
    
    -- Wait maksimal 2 detik untuk gambar
    local waitStart = tick()
    while imageUrl == "https://i.imgur.com/placeholder.png" and (tick() - waitStart) < 2 do
        task.wait(0.1)
    end

	-- Leaderstats
	local caught = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Caught")
	local rarest = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Rarest Fish")

	-- Sell Price calculation
	local basePrice = 0
	if itemId and FishDataById[itemId] then
		basePrice = FishDataById[itemId].SellPrice
	end

	if variantId and VariantsByName[variantId] then
		basePrice = basePrice * VariantsByName[variantId]
	end

	local embedDesc = string.format([[
Hei **%s**! 🎣
You have successfully caught a fish.

====| FISH DATA |====
🧾 Name : **%s**
🌟 Rarity : **%s**
💰 Sell Price : **%s**

====| ACCOUNT DATA |====
🎯 Total Caught : **%s**
🏆 Rarest Fish : **%s**
]],
		username,
		fishName,
		rarityText,
		tostring(basePrice),
		caught and caught.Value or "N/A",
		rarest and rarest.Value or "N/A"
	)

	local data = {
		["username"] = "QuietXHub",
		["embeds"] = {{
			["title"] = "Fish Caught!",
			["description"] = embedDesc,
			["color"] = tonumber("0x00bfff"),
			["image"] = { ["url"] = imageUrl },
			["footer"] = { ["text"] = "Fish Notification • " .. os.date("%d %B %Y, %H:%M:%S") }
		}}
	}

	local requestFunc = syn and syn.request or http and http.request or http_request or request or fluxus and fluxus.request
	if requestFunc then
		requestFunc({
			Url = WebhookURL,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode(data)
		})
	else
		warn("HttpRequest tidak tersedia di executor ini.")
	end
end

-- Save last catch info from Event
local LastCatchData = {}

local REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]
REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, metadata)
	LastCatchData.ItemId = itemId
	LastCatchData.VariantId = metadata and metadata.VariantId
end)

-- GUI Detection (Trigger)
local function startFishDetection()
    local plr = LocalPlayer
    local guiNotif = plr.PlayerGui:WaitForChild("Small Notification", 10)
    if not guiNotif then
        warn("Small Notification GUI not found.")
        return
    end

    local displayContainer = guiNotif:FindFirstChild("Display") and guiNotif.Display:FindFirstChild("Container")
    if not displayContainer then
        warn("Notification Container not found.")
        return
    end

    local fishText = displayContainer:FindFirstChild("ItemName")
    local rarityText = displayContainer:FindFirstChild("Rarity")
    local imageFrame = guiNotif:FindFirstChild("Display") and
    guiNotif.Display:FindFirstChild("VectorFrame"):FindFirstChild("Vector")

    if not (fishText and rarityText and imageFrame) then
        warn("Required notification components not found.")
        return
    end

    -- ============================================
    -- PERBAIKAN: VALIDASI GANDA (ID + NAMA)
    -- ============================================
    fishText:GetPropertyChangedSignal("Text"):Connect(function()
        local fishName = fishText.Text
        local currentItemId = LastCatchData.ItemId
        local currentVariantId = LastCatchData.VariantId
        
        -- VALIDASI 1: Pastikan ItemId ada
        if not currentItemId then
            warn("⚠️ ItemId tidak ditemukan, skip webhook.")
            return
        end
        
        -- VALIDASI 2: Cek apakah Tier sesuai filter
        if not isTargetTier(currentItemId) then
            -- Debug (hapus nanti)
            -- print("⚠️ Ikan tidak masuk filter tier:", fishName, "| ID:", currentItemId)
            return
        end
        
        -- VALIDASI 3: Cross-check Nama dengan ItemId
        local expectedFishData = FishDataById[currentItemId]
        if expectedFishData then
            local expectedName = expectedFishData.Name
            
            -- Jika ada variant, nama bisa beda (contoh: "Megalodon" vs "Megalodon Lightning")
            -- Kita cek apakah nama UI MENGANDUNG nama base fish
            if not string.find(fishName, expectedName) then
                warn("⚠️ MISMATCH! UI Name:", fishName, "| Expected:", expectedName)
                warn("   Kemungkinan ItemId dari catch sebelumnya (race condition)")
                return -- SKIP webhook karena data tidak match
            end
        end
        
        -- VALIDASI 4: Ambil asset ID dari gambar
        local assetId = string.match(imageFrame.Image, "%d+")
        if not assetId then
            warn("❌ Asset ID tidak ditemukan dari imageFrame!")
            return
        end
        
        -- SEMUA VALIDASI PASS - KIRIM WEBHOOK
        local rarity = rarityText.Text
        
        print("✅ Webhook triggered for:", fishName, "| ID:", currentItemId, "| Tier:", _G.FishTierById[currentItemId])
        
        sendFishWebhook(fishName, rarity, assetId, currentItemId, currentVariantId)
    end)
end

startFishDetection()

SettingsTab:Button({
    Title = "Save",
    Desc = "Save Settings to config",
    Callback = function()
        myConfig:Save()
        NotifySuccess("Config Saved", "Config has been saved!")
    end
})

myConfig:Load()