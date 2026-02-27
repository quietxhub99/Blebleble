------------------------------------------
----- =======[ Load WindUI ]
-------------------------------------------

local Version = "1.6.53"
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Madindun/Loader/refs/heads/shibal/ui.lua"))()

-------------------------------------------
----- =======[ GLOBAL FUNCTION ]
-------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Net = require(ReplicatedStorage.Packages.Net)

local rodRemote = Net:RemoteFunction("ChargeFishingRod")
local miniGameRemote = Net:RemoteFunction("RequestFishingMinigameStarted")
local finishRemote = Net:RemoteFunction("CatchFishCompleted")
local Constants = require(ReplicatedStorage:WaitForChild("Shared", 20):WaitForChild("Constants"))


local Player = Players.LocalPlayer
local XPBar = Player:WaitForChild("PlayerGui"):WaitForChild("XP")

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

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

task.spawn(function()
    if XPBar then
        XPBar.Enabled = true
    end
end)

local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

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

local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")


local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodShake = animator:LoadAnimation(RodShake)
local RodIdle = animator:LoadAnimation(RodIdle)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

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

_G.__UIReady = false
_G.__ProtectedCallbacks = setmetatable({}, { __mode = "k" })

function _G.ProtectCallback(callback)
    if type(callback) ~= "function" then return callback end

    local wrapper = function(...)
        if not _G.__UIReady then
            -- abaikan eksekusi pertama
            return
        end

        return callback(...)
    end

    -- simpan biar GC tidak makan wrapper
    _G.__ProtectedCallbacks[wrapper] = callback
    return wrapper
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
----- =======[ LOAD WINDOW ]
-------------------------------------------

WindUI:AddTheme({
    Name = "Deep Sea Dawn",
    Accent = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#FFC700"), Transparency = 0 }, -- Cahaya Fajar/Emas Ikan
        ["100"] = { Color = Color3.fromHex("#00BFFF"), Transparency = 0 }, -- Biru Langit Cerah
    }, {
        Rotation = 45,
    }),
    Dialog = Color3.fromHex("#082A4D"),      -- Biru Tua Dalam
    Outline = Color3.fromHex("#9BCFFF"),     -- Refleksi Air Laut
    Text = Color3.fromHex("#E0F4FF"),        -- Putih Awan
    Placeholder = Color3.fromHex("#5B8CA3"), -- Bayangan di Kedalaman
    Background = Color3.fromHex("#051930"),  -- Dasar Laut yang Gelap
    Button = Color3.fromHex("#176FA8"),      -- Biru Laut Menengah
    Icon = Color3.fromHex("#FFD75F")         -- Emas Ikan
})
WindUI.TransparencyValue = 0.3

local Window = WindUI:CreateWindow({
    Title = "Fish It",
    Icon = "crown",
    Author = "by Dhoing",
    Folder = "Dhoing",
    Size = UDim2.fromOffset(600, 400),
    Transparent = true,
    Theme = "Deep Sea Dawn",
    KeySystem = false,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    NewElements = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
        end,
    }
})

Window:EditOpenButton({
    Title = "DhoingXFox",
    Icon = "crown",
    CornerRadius = UDim.new(0,19),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("990c41"), 
        Color3.fromHex("500622")
    ),
    Draggable = true,
})

Window:Tag({
    Title = "PREMIUM VERSION",
    Color = Color3.fromHex("#30ff6a")
})



local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("QuietXConfig")

WindUI:SetNotificationLower(true)

WindUI:Notify({
	Title = "QuietXHub",
	Content = "All Features Loaded!",
	Duration = 5,
	Image = "square-check-big"
})

-------------------------------------------
----- =======[ ALL TAB ]
-------------------------------------------

local Home = Window:Tab({
	Title = "Developer Info",
	Icon = "hard-drive"
})

_G.CEvent = Window:Tab({
    Title = "Pirate Island",
    Icon = "solar:stars-bold",
})

local AllMenu = Window:Section({
	Title = "All Menu Here",
	Icon = "tally-3",
	Opened = false,
})

local AutoFish = AllMenu:Tab({ 
	Title = "Auto Fish", 
	Icon = "fish"
})

local AutoFav = AllMenu:Tab({
	Title = "Auto Favorite",
	Icon = "star"
})

local AutoFarmTab = AllMenu:Tab({
	Title = "Auto Farm",
	Icon = "leaf"
})

local AutoFarmArt = AllMenu:Tab({
	Title = "Auto Farm Artifact",
	Icon = "flask-round"
})

local Trade = AllMenu:Tab({
	Title = "Trade",
	Icon = "handshake"
})


local Player = AllMenu:Tab({
    Title = "Player",
    Icon = "users-round"
})

local Utils = AllMenu:Tab({
    Title = "Utility",
    Icon = "earth"
})

local FishNotif = AllMenu:Tab({
	Title = "Fish Notification",
	Icon = "bell-ring"
})

local SettingsTab = AllMenu:Tab({ 
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

local username = LocalPlayer.Name
_G.saveFileName = username .. "_savedPos.json"

function _G.savePosition()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local cx, cy, cz,
              r00, r01, r02,
              r10, r11, r12,
              r20, r21, r22 = root.CFrame:GetComponents()

        local posData = {
            cx = cx, cy = cy, cz = cz,
            r00 = r00, r01 = r01, r02 = r02,
            r10 = r10, r11 = r11, r12 = r12,
            r20 = r20, r21 = r21, r22 = r22
        }

        writefile(_G.saveFileName, HttpService:JSONEncode(posData))
    else
        warn("[❌] Gagal menyimpan posisi: HRP tidak ditemukan")
    end
end

function _G.loadPosition()
    if isfile(_G.saveFileName) then
        local data = readfile(_G.saveFileName)
        local pos = HttpService:JSONDecode(data)
        
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")

        root.CFrame = CFrame.new(
            pos.cx, pos.cy, pos.cz,
            pos.r00, pos.r01, pos.r02,
            pos.r10, pos.r11, pos.r12,
            pos.r20, pos.r21, pos.r22
        )

        print("[📍] CFrame berhasil diload!")
    else
        warn("[❌] Tidak ada posisi tersimpan.")
    end
end

_G.loadPosition()

-------------------------------------------
----- =======[ PIRATE ISSLAND ]
-------------------------------------------

_G.CEvent:Divider()

_G.CEvent:Section({
    Title = "Pirate Island",
    TextSize = 22,
    TextXAlignment = "Center",
})

_G.CEvent:Divider()

function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

function firePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        fireproximityprompt(prompt)
        task.wait(0.25)
    end
end

function fastTeleport(cf)
    local hrp = getHRP()
    hrp.CFrame = cf
    task.wait(0.15)
end

function collectAllTNT()
    local tntFolder = workspace:FindFirstChild("!!! SEARCH ITEM SPAWNS")
        and workspace["!!! SEARCH ITEM SPAWNS"]:FindFirstChild("TNT")

    if not tntFolder then
        warn("[PirateCove] TNT folder not found")
        return false
    end

    local collected = 0

    for _, obj in ipairs(tntFolder:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                fastTeleport(part.CFrame * CFrame.new(0, 0, -3))
                firePrompt(obj)
                collected = collected + 1
            end
        end
    end

    warn("[PirateCove] TNT collected:", collected)
    return collected > 0
end

function openPirateCoveWall()
    local wallPrompt =
        workspace:FindFirstChild("Islands")
        and workspace.Islands:FindFirstChild("Pirate's Cove")
        and workspace.Islands["Pirate's Cove"]:FindFirstChild("PirateCoveWall")
        and workspace.Islands["Pirate's Cove"].PirateCoveWall:FindFirstChild("Prompt")
        and workspace.Islands["Pirate's Cove"].PirateCoveWall.Prompt:FindFirstChild("ProximityPrompt")

    if not wallPrompt then
        warn("[PirateCove] Wall prompt not found")
        return
    end

    firePrompt(wallPrompt)
    warn("[PirateCove] Pirate Cove Wall opened")
end

_G.CEvent:Button({
    Title = "Auto Open Pirate Cove Wall",
    Justify = "Center",
    Icon = "",
    Callback = function()
        task.spawn(function()
            local ok = collectAllTNT()
            if ok then
                task.wait(1)
                openPirateCoveWall()
            end
        end)
    end
})

_G.FirePrompt = function(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        pcall(function()
            fireproximityprompt(prompt)
        end)
        task.wait(0.15)
    end
end

_G.OpenAllPirateChests = function()
    _G.ChestFolder = workspace:FindFirstChild("PirateChestStorage")

    if not _G.ChestFolder then
        warn("[PirateChest] PirateChestStorage not found")
        return
    end

    _G.Opened = 0

    for _, model in ipairs(_G.ChestFolder:GetChildren()) do
        if model:IsA("Model") then
            _G.Cover = model:FindFirstChild("Cover")

            if _G.Cover then
                _G.Prompt = _G.Cover:FindFirstChildWhichIsA("ProximityPrompt", true)

                if _G.Prompt then
                    _G.FirePrompt(_G.Prompt)
                    _G.Opened = _G.Opened + 1
                end
            end
        end
    end

    warn("[PirateChest] Opened:", _G.Opened)
end

_G.CEvent:Button({
    Title = "Open All Pirate Chest",
    Justify = "Center",
    Icon = "",
    Callback = function()
        task.spawn(function()
            _G.OpenAllPirateChests()
        end)
    end
})

-------------------------------------------
----- =======[ AUTO FISH TAB ]
-------------------------------------------

_G.REFishingStopped = Net:RemoteEvent("FishingStopped")
_G.RFCancelFishingInputs = Net:RemoteFunction("CancelFishingInputs")
_G.REUpdateChargeState = Net:RemoteEvent("UpdateChargeState")


_G.StopFishing = function()
	      _G.RFCancelFishingInputs:InvokeServer()
    firesignal(_G.REFishingStopped.OnClientEvent)
    RodIdle:Stop()
end

local FuncAutoFish = {
    REReplicateTextEffect = Net:RemoteEvent("ReplicateTextEffect"),
    autofish5x = false,
    perfectCast5x = true,
    fishingActive = false,
    delayInitialized = false,
    lastCatchTime5x = 0,
    CatchLast = tick(),
}



_G.REFishCaught = Net:RemoteEvent("FishCaught")
_G.REPlayFishingEffect = Net:RemoteEvent("PlayFishingEffect")
_G.equipRemote = Net:RemoteEvent("EquipToolFromHotbar")
_G.REObtainedNewFishNotification = Net:RemoteEvent("ObtainedNewFishNotification")


_G.isSpamming = false
_G.rSpamming = false
_G.spamThread = nil
_G.rspamThread = nil
_G.lastRecastTime = 0
_G.DELAY_ANTISTUCK = 9
_G.isRecasting5x = false
_G.STUCK_TIMEOUT = 9
_G.AntiStuckEnabled = false
_G.lastFishTime = tick()
_G.FINISH_DELAY = 1.5
_G.fishCounter = 0
_G.sellThreshold = 1000
_G.sellActive = false
_G.AutoFishHighQuality = false

_G.RemotePackage = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
_G.RemoteFish = Net:RemoteEvent("ObtainedNewFishNotification")
_G.RemoteSell = Net:RemoteFunction("SellAllItems")

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
		if _G.AntiStuckEnabled and not _G.AutoFishHighQuality then
			if tick() - _G.lastFishTime > tonumber(_G.STUCK_TIMEOUT) then
				StopAutoFish5X()
				task.wait(1)
				StartAutoFish5X()
				_G.lastFishTime = tick()
			end
		end
	end
end)

local lastEventTime = tick()

task.spawn(function()
    while task.wait(1) do
        if _G.AutoFishHighQuality and FuncAutoFish.autofish5x and FuncAutoFish.REReplicateTextEffect then
            if tick() - lastEventTime > 10 then
                StopAutoFish5X()
                lastEventTime = tick()
                task.wait(0.5)
                StartAutoFish5X()
            end
        end
    end
end)

local function approx(a, b, tolerance)
    return math.abs(a - b) <= (tolerance or 0.02)
end

local function isColor(r, g, b, R, G, B)
    return approx(r, R) and approx(g, G) and approx(b, B)
end

local BAD_COLORS = {
    COMMON    = {1,       0.980392, 0.964706},
    UNCOMMON  = {0.764706, 1,        0.333333},
    RARE      = {0.333333, 0.635294, 1},
    EPIC      = {0.678431, 0.309804, 1},
}

FuncAutoFish.REReplicateTextEffect.OnClientEvent:Connect(function(data)

    if not FuncAutoFish.autofish5x then return end

    local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")
    if not (data and data.TextData and data.TextData.TextColor and data.TextData.EffectType == "Exclaim" and myHead and data.Container == myHead) then
        return
    end

    lastEventTime = tick()
    if _G.AutoFishHighQuality then
        local colorValue = data.TextData.TextColor
        local r, g, b
    
        if typeof(colorValue) == "Color3" then
            r, g, b = colorValue.R, colorValue.G, colorValue.B
        elseif typeof(colorValue) == "ColorSequence" and #colorValue.Keypoints > 0 then
            local c = colorValue.Keypoints[1].Value
            r, g, b = c.R, c.G, c.B
        end
    
        if not (r and g and b) then return end
    
        local isBadFish = false
    
        for _, col in pairs(BAD_COLORS) do
            if isColor(r, g, b, col[1], col[2], col[3]) then
                isBadFish = true
                break
            end
        end
    
        if isBadFish then
        	  _G.StopFishing()
            _G.RecastSpam()
        else
            _G.startSpam()
        end
    else
        _G.startSpam()
    end
end)


task.spawn(function()
	while task.wait(1) do
		if _G.AntiStuckEnabled and FuncAutoFish.autofish5x and not _G.AutoFishHighQuality then
			if tick() - _G.lastFishTime > tonumber(_G.STUCK_TIMEOUT) then
				StopAutoFish5X()
				task.wait(0.5)
				StartAutoFish5X()
				_G.lastFishTime = tick()
			end
		end
	end
end)

_G.REFishCaught.OnClientEvent:Connect(function(fishName, info)
    if FuncAutoFish.autofish5x then
        _G.stopSpam()
        StopCast()
        _G.RecastSpam()
    end
end)

function StartCast5X()
    local getPowerFunction = Constants.GetPower
    local perfectThreshold = 0.99
    local chargeStartTime = workspace:GetServerTimeNow()
    rodRemote:InvokeServer(chargeStartTime)
    local calculationLoopStart = tick()

    local timeoutDuration = 1

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

-- REPLION DIHAPUS TOTAL

_G.AutoFishState = {
    IsActive = false
}

_G.SPEED_LEGIT = 0.5
_G.clickThread = nil

-- =====================================
-- PERFORM CLICK
-- =====================================

function _G.performClick()
    _G.FishingController:RequestFishingMinigameClick()
    task.wait(_G.SPEED_LEGIT)
end

-- =====================================
-- FORCE AUTO FISHING STATE TRUE
-- =====================================

function _G.ensureServerAutoFishingOn()
    local Net = require(_G.ReplicatedStorage.Packages.Net)
    local UpdateAutoFishingRemote = Net:RemoteFunction("UpdateAutoFishingState")

    task.spawn(function()
        pcall(function()
            UpdateAutoFishingRemote:InvokeServer(true)
        end)
    end)
end

-- =====================================
-- TOGGLE
-- =====================================

function _G.ToggleAutoClick(state)

    _G.AutoFishState.IsActive = state

    if state then

        _G.ensureServerAutoFishingOn()

        if _G.clickThread then
            task.cancel(_G.clickThread)
        end

        _G.clickThread = task.spawn(function()
            while _G.AutoFishState.IsActive do
                _G.performClick()
            end
        end)

    else

        if _G.clickThread then
            task.cancel(_G.clickThread)
            _G.clickThread = nil
        end

    end
end

local v5 = {
    Net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net,
    FishingController = require(ReplicatedStorage.Controllers.FishingController),
}

-------------------------------------------------
-- FORCE EQUIP SLOT 1 (AUTO)
-------------------------------------------------

local v6 = {
    Events = {
        REFishDone = Net:RemoteFunction("CatchFishCompleted"),
        REEquip = Net:RemoteEvent("EquipToolFromHotbar"),
    },
    Functions = {
        ChargeRod = Net:RemoteFunction("ChargeFishingRod"),
        StartMini = Net:RemoteFunction("RequestFishingMinigameStarted"),
        Cancel = Net:RemoteFunction("CancelFishingInputs"),
    }
}

_G.BlatantState = {
    enabled = false,
    mode = "Fast",
    fishingDelay = 1.0,
    reelDelay = 1.9
}

_G.ForceEquipRod = function()
    pcall(function()
        v6.Events.REEquip:FireServer(1)
    end)
    task.wait(0.25)
end

function Fastest()
    task.spawn(function()
        _G.ForceEquipRod()
        pcall(function()
            v6.Functions.Cancel:InvokeServer()
        end)
        local l_workspace_ServerTimeNow_0 = workspace:GetServerTimeNow()
        pcall(function()
            v6.Functions.ChargeRod:InvokeServer(l_workspace_ServerTimeNow_0)
        end)
        pcall(function()
            v6.Functions.StartMini:InvokeServer(-1, 0.999)
        end)
        task.wait(_G.BlatantState.fishingDelay)
        pcall(function()
            v6.Events.REFishDone:InvokeServer()
        end)
    end)
end

task.spawn(function()
    while true do
        if _G.BlatantState.enabled then
            if _G.BlatantState.mode == "Fast" then
                Fastest()
            end
            task.wait(_G.BlatantState.reelDelay)
        else
            task.wait(0.2)
        end
    end
end)

_G.BlatantSec = AutoFish:Section({
    Title = "Blatant Fishing",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

_G.BlatantSec:Input({
    Title = "Delay Reel",
    Value = tostring(_G.BlatantState.reelDelay),
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then
            _G.BlatantState.reelDelay = num
        end
    end
})

_G.BlatantSec:Input({
    Title = "Delay Fishing",
    Value = tostring(_G.BlatantState.fishingDelay),
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then
            _G.BlatantState.fishingDelay = num
        end
    end
})

_G.BlatantSec:Toggle({
    Title = "Enable Blatant",
    Value = false,
    Callback = function(state)
        _G.BlatantState.enabled = state
    end
})

_G.FishSec = AutoFish:Section({
    Title = "Auto Fishing",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.DelayFinish = _G.FishSec:Slider({
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

myConfig:Register("DelayFinish", _G.DelayFinish)

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

myConfig:Register("SpeedLegit", _G.RecastCD)

_G.SellThres = _G.FishSec:Slider({
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

myConfig:Register("SellThress", _G.SellThres)

_G.DelayStuck = _G.FishSec:Slider({
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

myConfig:Register("DelayStuck", _G.DelayStuck)

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
            _G.savePosition()
            StartAutoFish5X()
        else
            StopAutoFish5X()
        end
    end
})

_G.HighFish = _G.FishSec:Toggle({
    Title = "Fish High Quality",
    Desc = "Only Legendary, Mythic, & SECRET",
    Value = _G.AutoFishHighQuality,
    Callback = function(state)
        _G.AutoFishHighQuality = state
    end
})

myConfig:Register("FishHigh", _G.HighFish)

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

_G.DisplayNotif = game:GetService("Players").LocalPlayer.PlayerGui["Small Notification"].Display

_G.HideNotif = _G.FishSec:Toggle({
    Title = "Hide Notification",
    Value = false,
    Callback = function(state)
        if state then
            _G.DisplayNotif.Visible = false
        else 
            _G.DisplayNotif.Visible = true
        end
    end
})

_G.DisableAnimations = false

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    
    local success, AnimController = pcall(require, ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("AnimationController"))
    
    if success and AnimController then
        local originalPlayAnimation = AnimController.PlayAnimation
        
        AnimController.PlayAnimation = function(self, ...)
            if _G.DisableAnimations then
                if self.DestroyActiveAnimationTracks then
                    self:DestroyActiveAnimationTracks()
                end
                return nil 
            end
            return originalPlayAnimation(self, ...)
        end
        
        task.spawn(function()
            while task.wait(1) do
                if _G.DisableAnimations then
                    pcall(function()
                        local char = Players.LocalPlayer.Character
                        local hum = char and char:FindFirstChild("Humanoid")
                        local animator = hum and hum:FindFirstChild("Animator")
                        if animator then
                            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                track:Stop()
                            end
                        end
                    end)
                end
            end
        end)
    end
end)


_G.FishSec:Space()

_G.Animate = _G.FishSec:Toggle({
    Title = "Disable Animation",
    Desc = "Disable Rod Animation",
    Value = false,
    Callback = function(state)
        _G.DisableAnimations = state
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
    Value = truee,
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
	local sellRemote = Net:RemoteFunction("SellAllItems")

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

_G.FishSec:Space()

_G.FishSec:Button({
    Title = "Sell All Fishes",
    Locked = false,
    Justify = "Center",
    Icon = "",
    Callback = function()
        sellAllFishes()
    end
})

_G.FishSec:Space()

_G.FishSec:Button({
    Title = "Respawn Player",
    Justify = "Center",
    Callback = function()
        -- Cek apakah karakter ada
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")

            -- Simpan posisi terakhir (jika ingin respawn di tempat yang sama)
            local lastPosition = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame

            -- Paksa respawn
            humanoid.Health = 0

            -- Tunggu karakter baru
            LocalPlayer.CharacterAdded:Wait()

            -- (Opsional) Kembalikan ke posisi sebelumnya
            task.wait(0.5)
            if lastPosition and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:MoveTo(lastPosition.Position)
            end
        else
            warn("Character tidak ditemukan!")
        end
    end
})

-------------------------------------------
----- =======[ AUTO FAV TAB ]
-------------------------------------------


local GlobalFav = {
    REObtainedNewFishNotification = Net:RemoteEvent("ObtainedNewFishNotification"),
    REFavoriteItem = Net:RemoteEvent("FavoriteItem"),

    FishIdToName = {},
    FishNameToId = {},
    FishNames = {},
    FishRarity = {},
    Variants = {},
    SelectedFishIds = {},
    SelectedVariants = {},
    SelectedRarities = {},
    AutoFavoriteEnabled = false
}

local TierToRarityName = {
    [3] = "RARE",
    [4] = "EPIC",
    [5] = "LEGENDARY",
    [6] = "MYTHIC",
    [7] = "SECRET"
}

local ItemContainers = {
    ReplicatedStorage.Items,
    ReplicatedStorage.Items:FindFirstChild("New Area"),
    ReplicatedStorage.Items:FindFirstChild("BP"),
    ReplicatedStorage.Items:FindFirstChild("Magma Update 2")
        and ReplicatedStorage.Items["Magma Update 2"]:FindFirstChild("Fishies")
}

-- ===============================
-- AUTO FAV LOADER
-- ===============================

for _, container in ipairs(ItemContainers) do
    if container then
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("ModuleScript") then
                local ok, data = pcall(require, item)

                if ok and data and data.Data and data.Data.Type == "Fish" then
                    local id = data.Data.Id
                    local name = data.Data.Name
                    local tier = data.Data.Tier or 1

                    local nameWithId = string.format("%s [ID:%d]", name, id)

                    GlobalFav.FishIdToName[id] = nameWithId
                    GlobalFav.FishNameToId[nameWithId] = id
                    GlobalFav.FishRarity[id] = tier

                    table.insert(GlobalFav.FishNames, nameWithId)
                end
            end
        end
    end
end

-- Load Variants (BY NAME, MATCH METADATA)
for _, variantModule in pairs(ReplicatedStorage.Variants:GetChildren()) do
    local ok, variantData = pcall(require, variantModule)
    if ok and variantData.Data and variantData.Data.Name then
        local name = variantData.Data.Name
        GlobalFav.Variants[name] = name
    end
end

AutoFav:Section({
    Title = "Auto Favorite Menu",
    TextSize = 22,
    TextXAlignment = "Center",
})

_G.FavToggle = AutoFav:Toggle({
    Title = "Enable Auto Favorite",
    Value = false,
    Callback = function(state)
        GlobalFav.AutoFavoriteEnabled = state
        if state then
            NotifySuccess("Auto Favorite", "Auto Favorite feature enabled")
        else
            NotifyWarning("Auto Favorite", "Auto Favorite feature disabled")
        end
    end
})

myConfig:Register("ToggleFav", _G.FavToggle)

local fishName = GlobalFav.FishIdToName[itemId]

_G.FishList = AutoFav:Dropdown({
    Title = "Auto Favorite Fishes",
    Values = GlobalFav.FishNames,
    Value = {},
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = _G.ProtectCallback(function(selectedNames)
        GlobalFav.SelectedFishIds = {}

        for _, nameWithId in ipairs(selectedNames) do
            local id = GlobalFav.FishNameToId[nameWithId]
            if id then
                GlobalFav.SelectedFishIds[id] = true
            end
        end

        NotifyInfo("Auto Favorite", "Favoriting fish: " .. HttpService:JSONEncode(selectedNames))
    end)
})

GlobalFav.VariantList = {}

for variantName, _ in pairs(GlobalFav.Variants) do
    table.insert(GlobalFav.VariantList, variantName)
end

table.sort(GlobalFav.VariantList)


_G.FavVariantDropdown = AutoFav:Dropdown({
    Title = "Auto Favorite Variants",
    Values = GlobalFav.VariantList,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = _G.ProtectCallback(function(selectedVariants)
        GlobalFav.SelectedVariants = {}

        for _, vName in ipairs(selectedVariants) do
            GlobalFav.SelectedVariants[vName] = true
        end

        NotifyInfo(
            "Auto Favorite",
            "Favoriting variants: " .. table.concat(selectedVariants, ", ")
        )
    end)
})

myConfig:Register("FavVariants", _G.FavVariantDropdown)

-- Rarity dropdown
local rarityList = {}
for tier, name in pairs(TierToRarityName) do
    table.insert(rarityList, name)
end

_G.FavRarityDropdown = AutoFav:Dropdown({
    Title = "Auto Favorite by Rarity",
    Values = rarityList,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = _G.ProtectCallback(function(selectedRarities)
        GlobalFav.SelectedRarities = {}
        for _, rarityName in ipairs(selectedRarities) do
            for tier, name in pairs(TierToRarityName) do
                if name == rarityName then
                    GlobalFav.SelectedRarities[tier] = true
                end
            end
        end
        NotifyInfo("Auto Favorite", "Favoriting active for rarities: " .. HttpService:JSONEncode(selectedRarities))
    end)
})

myConfig:Register("FavRarity", _G.FavRarityDropdown)

function GlobalFav.ShouldFavorite(itemId, variantName, tier)
    local hasFish = next(GlobalFav.SelectedFishIds) ~= nil
    local hasVariant = next(GlobalFav.SelectedVariants) ~= nil
    local hasRarity = next(GlobalFav.SelectedRarities) ~= nil

    local matchFish =
        not hasFish or GlobalFav.SelectedFishIds[itemId]

    local matchVariant =
        not hasVariant or (variantName and GlobalFav.SelectedVariants[variantName])

    local matchRarity =
        not hasRarity or GlobalFav.SelectedRarities[tier]

    return matchFish and matchVariant and matchRarity
end

GlobalFav.REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, data)
    if not GlobalFav.AutoFavoriteEnabled then return end
    if not data or not data.InventoryItem then return end

    local uuid = data.InventoryItem.UUID
    if not uuid then return end

    local variantName =
    data.InventoryItem.Metadata
    and (data.InventoryItem.Metadata.VariantId
        or data.InventoryItem.Metadata.VariantName
        or data.InventoryItem.Metadata.Variant)

    local tier = GlobalFav.FishRarity[itemId] or 1

    if GlobalFav.ShouldFavorite(itemId, variantName, tier) then
        GlobalFav.REFavoriteItem:FireServer(uuid)
    end
end)

---------------------------------------------------------------------
-- FUNGSI BARU: SCAN INVENTORY & EKSEKUSI (LOCK / UNLOCK)
---------------------------------------------------------------------
function GlobalFav.ProcessInventory(action)
    
    local actionName = action and "Favorite" or "Unfavorite"
    
    if not _G.DataReplion then 
        NotifyWarning("Inventory Scan", "Data Replion not found. Please wait...")
        return 
    end

    local inventory = _G.DataReplion:Get({"Inventory", "Items"})
    if not inventory then 
        NotifyWarning("Inventory Scan", "No fish found in inventory.")
        return 
    end

    local count = 0
    NotifyInfo(actionName, "Scanning inventory...")

    for key, item in pairs(inventory) do
        local uuid = item.UUID or key
        local itemId = item.Id
        local tier = GlobalFav.FishRarity[itemId] or 1
        local currentLocked = item.Favorited or false
    
        if currentLocked ~= action then
            local variantName =
                item.Metadata
                and (item.Metadata.VariantId
                    or item.Metadata.VariantName
                    or item.Metadata.Variant)
    
            if GlobalFav.ShouldFavorite(itemId, variantName, tier) then
                GlobalFav.REFavoriteItem:FireServer(uuid)
                count += 1
                task.wait(0.1)
            end
        end
    end

    NotifySuccess(actionName, "Finished! Processed " .. count .. " items.")
end

AutoFav:Space()

AutoFav:Button({
    Title = "Favorite Fish",
    Justify = "Center",
    Icon = "",
    Callback = function()
        GlobalFav.ProcessInventory(true) -- True untuk Lock
    end
})

AutoFav:Space()

AutoFav:Button({
    Title = "Unfavorite All Fish",
    Justify = "Center",
    Icon = "",
    Callback = function()
        GlobalFav.ProcessInventory(false)
    end
})


-------------------------------------------
----- =======[ AUTO FARM TAB ]
-------------------------------------------


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
local fishCount = 0
local fishLimit = 10
local currentIslandIndex = 1
local currentSpotIndex = 0
local REObtainedNewFishNotification = Net:RemoteEvent("ObtainedNewFishNotification")

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
    ["22"] = "Volcanic Cavern",
    ["28"] = "Lava Basin",
    ["78"] = "Heartfelt Island"
}

local farmLocations = {
    ["Crater Islands"] = {
        CFrame.new(1066.1864, 57.2025681, 5045.5542, -0.682534158, 1.00865822e-08, 0.730853677, -5.8900711e-09, 1,
            -1.93017531e-08, -0.730853677, -1.74788859e-08, -0.682534158),
        CFrame.new(1057.28992, 33.0884132, 5133.79883, 0.833871782, 5.44149223e-08, 0.551958203, -6.58184218e-09, 1,
            -8.86416984e-08, -0.551958203, 7.02829084e-08, 0.833871782),
        CFrame.new(988.954712, 42.8254471, 5088.71289, -0.849417388, -9.89310394e-08, 0.527721584, -5.96115086e-08, 1,
            9.15179328e-08, -0.527721584, 4.62786431e-08, -0.849417388),
        CFrame.new(1006.70685, 17.2302666, 5092.14844, -0.989664078, 5.6538525e-09, -0.143405005, 9.14879283e-09, 1,
            -2.3711717e-08, 0.143405005, -2.47786183e-08, -0.989664078),
        CFrame.new(1025.02356, 2.77259707, 5011.47021, -0.974474192, -6.87871804e-08, 0.224499553, -4.47472104e-08, 1,
            1.12170284e-07, -0.224499553, 9.92613209e-08, -0.974474192),
        CFrame.new(1071.14551, 3.528404, 5038.00293, -0.532300115, 3.38677708e-08, 0.84655571, 6.69992914e-08, 1,
            2.12149165e-09, -0.84655571, 5.7847906e-08, -0.532300115),
        CFrame.new(1022.55457, 16.6277809, 5066.28223, 0.721996129, 0, -0.691897094, 0, 1, 0, 0.691897094, 0, 0.721996129),
    },
    ["Tropical Grove"] = {
        CFrame.new(-2165.05469, 2.77070165, 3639.87451, -0.589090407, -3.61497356e-08, -0.808067143, -3.20645626e-08, 1,
            -2.13606164e-08, 0.808067143, 1.3326984e-08, -0.589090407)
    },
    ["Vulcano"] = {
        CFrame.new(-433.240906, 7.20983887, 131.092194, 0.648306847, 8.24840782e-08, 0.761379182, -2.65132734e-08, 1, -8.57592894e-08, -0.761379182, 3.54116807e-08, 0.648306847),
        CFrame.new(-562.035522, 44.928669, 79.7976303, -0.192739666, 2.34128041e-08, -0.981249928, -2.48319552e-08, 1, 2.87377411e-08, 0.981249928, 2.99052587e-08, -0.192739666),
        CFrame.new(-635.196167, 40.9948311, 166.208664, -0.964496136, -8.92845762e-08, 0.264096886, -9.03357673e-08, 1, 8.16394863e-09, -0.264096886, -1.59832982e-08, -0.964496136),
    },
    ["Coral Reefs"] = {
        CFrame.new(-3118.39624, 2.42531538, 2135.26392, 0.92336154, -1.0069185e-07, -0.383931547, 8.0607947e-08, 1,
            -6.84016968e-08, 0.383931547, 3.22115596e-08, 0.92336154),
    },
    ["Winter"] = {
        CFrame.new(2036.15308, 6.54998732, 3381.88916, 0.943401575, 4.71338666e-08, -0.331652641, -3.28136842e-08, 1,
            4.87781051e-08, 0.331652641, -3.51345975e-08, 0.943401575),
    },
    ["Machine"] = {
        CFrame.new(-1459.3772, 14.7103214, 1831.5188, 0.777951121, 2.52131862e-08, -0.628324807, -5.24126378e-08, 1,
            -2.47663063e-08, 0.628324807, 5.21991339e-08, 0.777951121)
    },
    ["Treasure Room"] = {
        CFrame.new(-3625.0708, -279.074219, -1594.57605, 0.918176472, -3.97606392e-09, -0.396171629, -1.12946204e-08, 1,
            -3.62128851e-08, 0.396171629, 3.77244298e-08, 0.918176472),
        CFrame.new(-3600.72632, -276.06427, -1640.79663, -0.696130812, -6.0491181e-09, 0.717914939, -1.09490363e-08, 1,
            -2.19084972e-09, -0.717914939, -9.38559541e-09, -0.696130812),
        CFrame.new(-3548.52222, -269.309845, -1659.26685, 0.0472991578, -4.08685423e-08, 0.998880744, -7.68598838e-08, 1,
            4.45538149e-08, -0.998880744, -7.88812216e-08, 0.0472991578),
        CFrame.new(-3581.84155, -279.09021, -1696.15637, -0.999634147, -0.000535600528, -0.0270430837, -0.000448358158,
            0.999994695, -0.00323198596, 0.0270446707, -0.00321867829, -0.99962908),
        CFrame.new(-3601.34302, -282.790955, -1629.37036, -0.526346684, 0.00143659476, 0.850268841, -0.000266355521,
            0.999998271, -0.00185445137, -0.850269973, -0.00120255165, -0.526345372)
    },
    ["Sisyphus Statue"] = {
        CFrame.new(-3777.43433, -135.074417, -975.198975, -0.284491211, -1.02338751e-08, -0.958678663, 6.38407585e-08, 1,
            -2.96199456e-08, 0.958678663, -6.96293867e-08, -0.284491211),
        
        CFrame.new(-3697.77124, -135.074417, -886.946411, 0.979794085, -9.24526766e-09, 0.200008959, 1.35701708e-08, 1,
            -2.02526174e-08, -0.200008959, 2.25575487e-08, 0.979794085),
        CFrame.new(-3764.021, -135.074417, -903.742493, 0.785813689, -3.05788426e-08, -0.618463278, -4.87374336e-08, 1,
            -1.11368585e-07, 0.618463278, 1.17657272e-07, 0.785813689)
    },
    ["Fisherman Island"] = {
        CFrame.new(-75.2439423, 3.24433279, 3103.45093, -0.996514142, -3.14880424e-08, -0.0834242329, -3.84156422e-08, 1,
            8.14354024e-08, 0.0834242329, 8.43563228e-08, -0.996514142),
        CFrame.new(-162.285294, 3.26205397, 2954.47412, -0.74356699, -1.93168272e-08, -0.668661416, 1.03873425e-08, 1,
            -4.04397653e-08, 0.668661416, -3.70152904e-08, -0.74356699),
        CFrame.new(-69.8645096, 3.2620542, 2866.48096, 0.342575252, 8.79649331e-09, 0.939490378, 4.78986739e-10, 1,
            -9.53770485e-09, -0.939490378, 3.71738529e-09, 0.342575252),
        CFrame.new(247.130951, 2.47001815, 3001.72412, -0.724809051, -8.27166033e-08, -0.688949764, -8.16509669e-08, 1,
            -3.41610367e-08, 0.688949764, 3.14931867e-08, -0.724809051)
    },
    ["Esoteric Depths"] = {
        CFrame.new(3253.26099, -1293.7677, 1435.24756, 0.21652025, -3.88184027e-08, -0.976278126, 1.20091812e-08, 1,
            -3.70982107e-08, 0.976278126, -3.69178754e-09, 0.21652025),
        CFrame.new(3299.66333, -1302.85474, 1370.98621, -0.440755099, -5.91509552e-09, 0.897627413, -2.5926683e-09, 1,
            5.31664224e-09, -0.897627413, 1.60869356e-11, -0.440755099),
        CFrame.new(3250.94531, -1302.85547, 1324.77942, -0.998184919, 5.84032058e-08, 0.0602233484, 5.50187451e-08, 1,
            -5.78567096e-08, -0.0602233484, -5.44382814e-08, -0.998184919),
        CFrame.new(3219.16309, -1294.03394, 1364.41492, 0.676777482, -4.18104094e-08, -0.736187637, 8.28715798e-08, 1,
            1.93907237e-08, 0.736187637, -7.41322381e-08, 0.676777482)
    },
    ["Kohana"] = {
        CFrame.new(-921.516602, 24.5000591, 373.572754, -0.315036476, -3.65496575e-08, -0.949079573, -2.09816324e-08, 1,
            -3.15460156e-08, 0.949079573, 9.97509186e-09, -0.315036476),
        CFrame.new(-821.466125, 18.0640106, 442.570953, 0.502961993, 3.55151641e-08, 0.864308536, -2.61714685e-08, 1,
            -2.58610324e-08, -0.864308536, -9.61310764e-09, 0.502961993),
        CFrame.new(-656.069275, 17.2500572, 450.77124, 0.899714053, -3.28262595e-09, -0.436479777, -5.17725418e-09, 1,
            -1.81925373e-08, 0.436479777, 1.86278477e-08, 0.899714053),
        CFrame.new(-584.202759, 17.2500572, 459.276672, 0.0987685546, 5.48308599e-09, 0.995110452, -6.92575881e-08, 1,
            1.36405531e-09, -0.995110452, -6.90536694e-08, 0.0987685546),
    },
    ["Underground Cellar"] = {
        CFrame.new(2159.65723, -91.198143, -730.99707, -0.392579645, -1.64555736e-09, 0.919718027, 4.08579943e-08, 1,
            1.92293435e-08, -0.919718027, 4.51268818e-08, -0.392579645),
        CFrame.new(2114.22144, -91.1976471, -732.656738, -0.543168366, -3.4070105e-08, -0.839623809, 2.10003783e-08, 1,
            -5.41633582e-08, 0.839623809, -4.70522394e-08, -0.543168366),
        CFrame.new(2134.35767, -91.1985855, -698.182983, 0.989448071, -1.28799131e-08, -0.144888103, 2.66212989e-08, 1,
            9.29025887e-08, 0.144888103, -9.57793915e-08, 0.989448071),
    },
    ["Ancient Jungle"] = {
        CFrame.new(1515.67676, 25.5616989, -306.595856, 0.763029754, -8.87780942e-08, 0.646363378, 5.24343307e-08, 1,
            7.5451581e-08, -0.646363378, -2.36801707e-08, 0.763029754),
        CFrame.new(1489.29553, 6.23855162, -342.620209, -0.831362545, 6.32348289e-08, -0.555730462, 7.59748353e-09, 1,
            1.02421176e-07, 0.555730462, 8.09269736e-08, -0.831362545),
        CFrame.new(1467.59143, 7.2090292, -324.716827, -0.086521171, 2.06461745e-08, -0.996250033, -4.92800183e-08, 1,
            2.50037022e-08, 0.996250033, 5.12585707e-08, -0.086521171),
    },
    ["Secret Farm Ancient"] = {
        CFrame.new(2110.91431, -58.1463356, -732.848816, 0.0894816518, -9.7328666e-08, -0.995988488, 5.18647809e-08, 1,
            -9.30610398e-08, 0.995988488, -4.3329468e-08, 0.0894816518)
    },
    ["The Temple (Unlock First)"] = {
        CFrame.new(1479.11865, -22.1250019, -662.669373, 0.161120579, -2.03902815e-08, -0.986934721, -3.03227985e-08, 1,
            -2.56105164e-08, 0.986934721, 3.40530022e-08, 0.161120579),
        CFrame.new(1465.41211, -22.1250019, -670.940002, -0.21706377, -2.10148947e-08, 0.976157427, 3.29077707e-08, 1,
            2.88457365e-08, -0.976157427, 3.83845311e-08, -0.21706377),
        CFrame.new(1470.30334, -12.2246475, -587.052612, -0.101084575, -9.68974163e-08, 0.994877815, -1.47451953e-08, 1,
            9.5898109e-08, -0.994877815, -4.97584818e-09, -0.101084575),
        CFrame.new(1451.19983, -22.1250019, -621.852478, -0.986927867, 8.68970318e-09, -0.161162451, 9.61592317e-09, 1,
            -4.96716179e-09, 0.161162451, -6.4519563e-09, -0.986927867),
        CFrame.new(1499.44788, -22.1250019, -628.441711, -0.985374331, 7.20484294e-08, -0.170403719, 8.45688035e-08, 1,
            -6.62162876e-08, 0.170403719, -7.9658669e-08, -0.985374331)
    },
    ["Ancient Ruin"] = {
        CFrame.new(6096.86865, -585.924683, 4667.34521, -0.0791911632, 5.17708685e-08, 0.996859431, -4.35256062e-08, 1, -5.53916735e-08, -0.996859431, -4.77754405e-08, -0.0791911632),
        CFrame.new(6022.87109, -585.924194, 4631.0127, -0.669677734, -6.96009084e-10, -0.74265182, -5.20333909e-09, 1, 3.75485687e-09, 0.74265182, 6.37881348e-09, -0.669677734),
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
    ["Volcanic Cavern"] = {
        CFrame.new(1241.75488, 82.3315582, -10188.5684, 0.606033802, 1.16079759e-08, 0.795438886, -7.60513501e-08, 1, 4.33492922e-08, -0.795438886, -8.67653398e-08, 0.606033802),
        CFrame.new(1230.2738, 62.7213936, -10317.1621, -0.731822968, 3.05007433e-08, 0.681494772, 3.59822785e-08, 1, -6.11609074e-09, -0.681494772, 2.00458405e-08, -0.731822968),
        CFrame.new(1165.69446, 63.7063751, -10346.7969, -0.977984309, -3.32807417e-08, -0.208678365, -1.98564063e-08, 1, -6.64251374e-08, 0.208678365, -6.08191399e-08, -0.977984309),
        CFrame.new(1146.39746, 72.9385071, -10260.1484, 0.593335032, -6.09197386e-08, -0.804955602, -3.6591274e-08, 1, -1.026524e-07, 0.804955602, 9.03616169e-08, 0.593335032)
    },
    ["Lava Basin"] = {
        CFrame.new(951.114136, 85.0520401, -10198.3184, -0.201299608, 9.15099818e-08, 0.979529738, 2.35426292e-08, 1, -8.85842084e-08, -0.979529738, 5.22873833e-09, -0.201299608),
        CFrame.new(785.185852, 75.0568619, -10118.6631, 0.392952323, 1.80847746e-08, -0.919558823, 4.23913527e-08, 1, 3.77817635e-08, 0.919558823, -5.3827776e-08, 0.392952323),
        CFrame.new(784.451599, 83.2424316, -10168.9639, 0.159006074, 1.84810176e-08, -0.987277627, 3.04904746e-09, 1, 1.92102352e-08, 0.987277627, -6.06480022e-09, 0.159006074),
        CFrame.new(864.133484, 69.3645325, -10219.0361, -0.987480164, 4.37379697e-08, -0.15774326, 4.77367124e-08, 1, -2.15609024e-08, 0.15774326, -2.88211073e-08, -0.987480164)
    },
    ["Heartfelt Island"] = {
        CFrame.new(1125.25037, 3.76695824, 2605.67896, -0.990018368, 3.81225007e-08, 0.140938357, 5.03357533e-08, 1, 8.3091777e-08, -0.140938357, 8.93566181e-08, -0.990018368),
        CFrame.new(1103.02942, 3.32089734, 2842.01123, 0.98076731, 8.16230994e-08, 0.195180759, -7.19631359e-08, 1, -5.65834917e-08, -0.195180759, 4.14494181e-08, 0.98076731),
        CFrame.new(1043.38147, 3.76740384, 2800.51196, 0.452702761, -2.31139285e-08, -0.891661465, 2.74349432e-08, 1, -1.19934009e-08, 0.891661465, -1.90332372e-08, 0.452702761)
    }
}

local nameList = {}
local islandNamesToCode = {}

for code, name in pairs(islandCodes) do
    table.insert(nameList, name)
    islandNamesToCode[name] = code
end

table.sort(nameList)

_G.selectedIslands = {}

-------------------------------------------
----- =======[ FISH COUNTING & TELEPORT LOGIC ]
-------------------------------------------

-- 1. Listener untuk menghitung ikan
REObtainedNewFishNotification.OnClientEvent:Connect(function()
    if isAutoFarmRunning then
        fishCount = fishCount + 1
    end
end)

-- 2. Fungsi untuk berpindah ke spot/pulau berikutnya
local function teleportToNextSpot(forceNextIsland)
    if not _G.selectedIslands or #_G.selectedIslands == 0 then
        NotifyError("Farm Error", "No target islands selected for rotation.")
        isAutoFarmRunning = false
        return false
    end

    local currentIslandName = _G.selectedIslands[currentIslandIndex]
    local islandSpots = farmLocations[currentIslandName]

    if not islandSpots or #islandSpots == 0 then
        NotifyError("Farm Error", "No spots found for island: " .. currentIslandName)
        isAutoFarmRunning = false
        return false
    end

    -- Jika limit island tercapai, pindah ke island lain, bukan spot berikutnya
    if forceNextIsland then
        currentIslandIndex = currentIslandIndex + 1
        if currentIslandIndex > #_G.selectedIslands then
            currentIslandIndex = 1 -- Reset ke awal daftar island
        end
        currentIslandName = _G.selectedIslands[currentIslandIndex]
        islandSpots = farmLocations[currentIslandName]
        NotifyWarning("Island Rotation", "Switching to: " .. currentIslandName)
        _G.ToggleAutoClick(true)
    end

    -- Pilih spot acak di island baru
    currentSpotIndex = math.random(1, #islandSpots)
    local location = islandSpots[currentSpotIndex]

    local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = location
        NotifySuccess("Teleport Success",
            string.format("Farming %s | Spot %d/%d (Limit: %d Catches)",
                currentIslandName, currentSpotIndex, #islandSpots, fishLimit
            )
        )
        return true
    else
        NotifyError("Teleport Failed", "HumanoidRootPart not found.")
        isAutoFarmRunning = false
        return false
    end
end

-- 3. Loop utama Auto Farm
local function startAutoFarmLoop()
    if not _G.selectedIslands or #_G.selectedIslands == 0 then
        NotifyError("Auto Farm Disabled", "Please select at least one island for rotation.")
        isAutoFarmRunning = false
        return
    end

    NotifySuccess("Auto Farm Enabled",
        string.format("Starting auto farm rotation across %d islands (Limit: %d catches).", #_G.selectedIslands, fishLimit)
    )

    -- Reset indeks dan hitungan awal
    currentIslandIndex = 1
    currentSpotIndex = 0
    fishCount = 0

    while isAutoFarmRunning do
        -- 1. Teleport ke island saat ini (spot acak)
        local success = teleportToNextSpot(false)
        if not success then
            _G.ToggleAutoClick(false)
            isAutoFarmRunning = false
            break
        end
        task.wait(1.5)

        -- 2. Start Fishing
        _G.ToggleAutoClick(true)
        fishCount = 0 -- Reset count untuk spot baru

        -- 3. Tunggu hingga batas tangkapan tercapai atau farm dinonaktifkan
        while isAutoFarmRunning and fishCount < fishLimit do
            task.wait(0.5)
        end

        -- 4. Stop Fishing sebelum teleport berikutnya
        _G.ToggleAutoClick(false)

        if not isAutoFarmRunning then
            NotifyWarning("Auto Farm Stopped", "Auto Farm manually disabled. Auto Fish stopped.")
            break
        end

        -- 5. Jika limit tercapai, pindah ke island lain
        NotifyWarning("Limit Reached", string.format("Caught %d fish. Rotating to next island...", fishLimit))
        task.wait(1)

        teleportToNextSpot(true) -- Force pindah ke island berikutnya
    end
end

-------------------------------------------
----- =======[ UI DEFINITION MODIFIED ]
-------------------------------------------

_G.FarmSec = AutoFarmTab:Section({
	Title = "Auto Farming Menu",
	TextSize = 22,
	TextXAlignment = "Center",
	Opened = true,
})

-- =======================================================
-- == AUTO EVENT MANAGER (LOCHNESS + CHRISTMAS CAVE FINAL)
-- =======================================================

-------------------------------------------------
-- GLOBAL FLAGS
-------------------------------------------------
_G.AutoLochNess = false

_G.LochStatus = "Idle"

-------------------------------------------------
-- SERVICES
-------------------------------------------------

-------------------------------------------------
-- PATHS
-------------------------------------------------
_G.CountdownLabel =
    workspace["!!! DEPENDENCIES"]["Event Tracker"]
        .Main.Gui.Content.Items.Countdown.Label

-------------------------------------------------
-- CFRAMES
-------------------------------------------------
local LOCHNESS_CFRAME = CFrame.new(
    6003.8374, -585.924683, 4661.7334,
    0.0215646587, 0, -0.999767482,
    0, 1, 0,
    0.999767482, 0, 0.0215646587
)

-------------------------------------------------
-- STATE
-------------------------------------------------
_G.CaveReturnScheduled = false
_G.LochEventRunning = false
_G.LochEventEndTime = nil
_G.OriginalCFrame_Loch = nil

-------------------------------------------------
-- UI
-------------------------------------------------
_G.EventParagraph = _G.FarmSec:Paragraph({
    Title = "Event Status Monitor",
    Desc = "Loading...",
})

function _G.UpdateEventUI()
    _G.EventParagraph:SetDesc(string.format(
        "LochNess : %s\nCountdown: %s",
        _G.LochStatus,
        _G.CountdownLabel.Text or "N/A"
    ))
end

-------------------------------------------------
-- TOGGLES
-------------------------------------------------
_G.FarmSec:Toggle({
    Title = "Auto Lochness Monster",
    Callback = function(v)
        _G.AutoLochNess = v
        _G.LochStatus = v and "Monitoring..." or "Idle"
        _G.UpdateEventUI()
    end
})

-------------------------------------------------
-- SAFE TELEPORT (ANTI TERCEBUR / ANTI RENDER)
-------------------------------------------------
function SafeTeleport(cf)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.Anchored = true
    hrp.CFrame = cf
    task.wait(0.15)
    hrp.CFrame = cf
    task.wait(1)
    hrp.Anchored = false
end

function ForceReturnToOriginal(cf)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- tunggu server selesai teleport
    task.wait(2)

    hrp.Anchored = true

    for i = 1, 3 do
        hrp.CFrame = cf
        task.wait(0.1)
    end

    hrp.Anchored = false
end

-------------------------------------------------
-- LOCHNESS LOGIC (STABLE)
-------------------------------------------------
-------------------------------------------------
-- LOCHNESS LOGIC (FIXED & DETERMINISTIC)
-------------------------------------------------

function OnCountdownChanged()
    if not _G.AutoLochNess then return end
    if _G.LochEventRunning then return end

    local label = _G.CountdownLabel
    if not label or not label.Text then return end

    _G.UpdateEventUI()

    local txt = label.Text

    local h = tonumber(txt:match("(%d+)H")) or 0
    local m = tonumber(txt:match("(%d+)M")) or 0
    local s = tonumber(txt:match("(%d+)S")) or 0

    -- Trigger hanya SEKALI saat mendekati 0
    if h == 0 and m == 0 and s <= 10 and s >= 1 then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Simpan posisi awal
        _G.OriginalCFrame_Loch = hrp.CFrame

        _G.LochEventRunning = true
        _G.LochStatus = "Teleporting..."
        _G.UpdateEventUI()

        SafeTeleport(LOCHNESS_CFRAME)

        -- FIX: 11 MENIT TEPAT
        _G.LochEventEndTime = tick() + (11 * 60)
        _G.LochStatus = "Event Active (11 min)"
        _G.UpdateEventUI()

        -- Countdown return (thread terpisah, aman)
        task.spawn(function()
            while _G.LochEventRunning do
                if tick() >= _G.LochEventEndTime then
                    break
                end
                task.wait(1)
            end

            -- Return ke posisi awal
            _G.LochStatus = "Returning..."
            _G.UpdateEventUI()

            if _G.OriginalCFrame_Loch then
                SafeTeleport(_G.OriginalCFrame_Loch)
            end

            -- Reset state
            _G.LochEventRunning = false
            _G.LochEventEndTime = nil
            _G.OriginalCFrame_Loch = nil

            _G.LochStatus = "Monitoring..."
            _G.UpdateEventUI()
        end)
    end
end

_G.CountdownLabel:GetPropertyChangedSignal("Text"):Connect(OnCountdownChanged)

-------------------------------------------------
-- UI REFRESH FAILSAFE
-------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        _G.UpdateEventUI()
    end
end)

-- MODIFIKASI: Ganti Dropdown lama menjadi Multi-Dropdown
local CodeIsland = AutoFarmTab:Dropdown({
    Title = "Farm Islands (Rotation)",
    Desc = "Select multiple islands to rotate between based on the catch limit.",
    Values = nameList,
    Multi = true,
    Default = {nameList[1]}, 
    Callback = function(selectedNames)
        _G.selectedIslands = selectedNames -- Simpan sebagai array of names
        if #selectedNames > 0 then
            NotifySuccess("Islands Selected", "Rotation set for: " .. table.concat(selectedNames, ", "))
            -- Reset indeks rotasi saat pulau berubah
            currentIslandIndex = 1
            currentSpotIndex = 0
        else
            NotifyError("Selection Error", "Please select at least one island.")
        end
    end
})

myConfig:Register("IslCode", CodeIsland)

-- BARU: Slider untuk Batas Ikan
local FishLimitSlider = AutoFarmTab:Slider({
    Title = "Fish Catch Limit",
    Desc = "Number of fish to catch before rotating spot/island.",
    Step = 1,
    Value = {
    	Min = 1,
	    Max = 6000,
	    Default = 10,
    },
    Callback = function(value)
        fishLimit = math.floor(value)
        NotifySuccess("Limit Set", "New catch limit set to: " .. fishLimit)
    end
})

myConfig:Register("FishLimit", FishLimitSlider)


local AutoFarm = AutoFarmTab:Toggle({
	Title = "Start Auto Farm Rotation",
    Desc = "Starts auto-fishing and rotates spot/island after catching the set limit.",
	Callback = function(state)
		isAutoFarmRunning = state
		if state then
			startAutoFarmLoop()
		else
			StopAutoFish5X()
            NotifyWarning("Auto Farm Stopped", "Rotation stopped manually.")
		end
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
        Title = "Auto Event Teleport",
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


-------------------------------------------
----- =======[ ARTIFACT TAB ]
-------------------------------------------

AutoFarmArt:Section({
	Title = "Farming Artifact Menu",
	TextSize = 22,
	TextXAlignment = "Center",
})

local REPlaceLeverItem = Net:RemoteEvent("PlaceLeverItem")

_G.UnlockTemple = function()
    task.spawn(function()
        local Artifacts = {
            "Hourglass Diamond Artifact",
            "Crescent Artifact",
            "Arrow Artifact",
            "Diamond Artifact",
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

local REFishCaught = Net:RemoteEvent("FishCaught")

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

AutoFarmArt:Space()

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
    Icon = "",
    Callback = function()
        _G.UnlockTemple()
    end
})

-------------------------------------------
----- =======[ MASS TRADE TAB ]
-------------------------------------------

local GlobalFav = {
    REObtainedNewFishNotification = Net:RemoteEvent("ObtainedNewFishNotification"),
    REFavoriteItem = Net:RemoteEvent("FavoriteItem"),

    FishIdToName = {},
    FishNameToId = {},
    FishNames = {},
    FishRarity = {},
    Variants = {},
    SelectedFishIds = {},
    SelectedVariants = {},
    SelectedRarities = {},
    AutoFavoriteEnabled = false
}


-- [Trade State Baru]
local tradeState = { 
    mode = "V1",
    selectedPlayerName = nil, 
    selectedPlayerId = nil, 
    tradeAmount = 0, 
    autoTradeV2 = false,
    filterUnfavorited = false,
    
    saveTempMode = false,
    TempTradeList = {}, 
    onTrade = false 
}

-- [Cache & Utility untuk Mode V2]
local inventoryCache = {}
local fullInventoryDropdownList = {}

-- Asumsi Modul game inti sudah tersedia (seperti Replion)
local ItemUtility = _G.ItemUtility or require(ReplicatedStorage.Shared.ItemUtility) 
local ItemStringUtility = _G.ItemStringUtility or require(ReplicatedStorage.Modules.ItemStringUtility)
local InitiateTrade = Net:RemoteFunction("InitiateTrade")
local RFAwaitTradeResponse = Net:RemoteFunction("AwaitTradeResponse")


local function getPlayerListV2()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    table.sort(list)
    return list
end

local function refreshDropdownV2()
    if not _G.PlayerDropdownTrade then return end

    local previousSelection = tradeState.selectedPlayerName
    local list = getPlayerListV2()

    _G.PlayerDropdownTrade:Refresh(list)

    -- Restore selection TANPA trigger ulang
    if previousSelection then
        for _, name in ipairs(list) do
            if name == previousSelection then
                task.defer(function()
                    _G.PlayerDropdownTrade:SetValue(previousSelection, true)
                end)
                break
            end
        end
    end
end

-- =======================================================
-- LOGIKA PEMBARUAN INVENTARIS 
-- =======================================================

local AllowedPotionNames = {
    ["Cave Crystal"] = true
}

local function refreshInventory()
    local DataReplion = _G.Replion.Client:WaitReplion("Data")
    if not DataReplion or not ItemUtility or not ItemStringUtility then
        warn("Cannot refresh inventory: Missing modules.")
        return
    end

    local inventoryItems = DataReplion:Get({ "Inventory", "Items" })
    local inventoryPotions = DataReplion:Get({ "Inventory", "Potions" }) or {}
    inventoryCache = {}
    fullInventoryDropdownList = {}

    if not inventoryItems then return end

    ------------------------------------------------
    -- ITEMS
    ------------------------------------------------
    for _, itemData in ipairs(inventoryItems) do
        local baseItemData = ItemUtility:GetItemData(itemData.Id)

        if baseItemData and baseItemData.Data then
            local itemType = baseItemData.Data.Type
            local nameType = baseItemData.Data.Name

            if itemType == "Fish" or itemType == "Enchant Stones" or nameType == "Cave Crystal" then
                if not (tradeState.filterUnfavorited and itemData.Favorited) then

                    local name = ItemStringUtility.GetItemName(itemData, baseItemData)

                    -- =========================================
                    -- 🔹 ITEM BERBASIS QUANTITY
                    -- =========================================
                    if itemData.Quantity and itemData.Quantity > 1 then
                        inventoryCache[name] = {
                            Mode = "Quantity",
                            UUID = itemData.UUID,
                            Quantity = itemData.Quantity
                        }

                        table.insert(
                            fullInventoryDropdownList,
                            string.format("%s (%dx)", name, itemData.Quantity)
                        )

                    -- =========================================
                    -- 🔹 ITEM BERBASIS UUID
                    -- =========================================
                    else
                        inventoryCache[name] = inventoryCache[name] or {
                            Mode = "UUID",
                            UUIDs = {}
                        }

                        table.insert(inventoryCache[name].UUIDs, itemData.UUID)
                    end
                end
            end
        end
    end

    ------------------------------------------------
    -- POTIONS
    ------------------------------------------------
    for _, potionData in ipairs(inventoryPotions) do
        local basePotion = ItemUtility:GetItemData(potionData.Id)

        if basePotion and basePotion.Data then
            local name = basePotion.Data.Name

            if AllowedPotionNames[name] then
                inventoryCache[name] = inventoryCache[name] or {
                    Mode = "UUID",
                    UUIDs = {}
                }

                table.insert(inventoryCache[name].UUIDs, potionData.UUID)
            end
        end
    end

    ------------------------------------------------
    -- FINAL LIST (TERMAsuk POTION)
    ------------------------------------------------
    for name, data in pairs(inventoryCache) do
        if data.Mode == "UUID" then
            table.insert(
                fullInventoryDropdownList,
                string.format("%s (%dx)", name, #data.UUIDs)
            )
        end
    end

    table.sort(fullInventoryDropdownList)

    ------------------------------------------------
    -- UI REFRESH
    ------------------------------------------------
    if _G.InventoryDropdown then
        _G.InventoryDropdown:Refresh(fullInventoryDropdownList)
    end
    if _G.PlayerDropdownTrade then
        _G.PlayerDropdownTrade:Refresh(getPlayerListV2())
    end
end

-- =======================================================
-- LOGIKA HOOKING
-- =======================================================

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
_G.REEquipItem = Net:RemoteEvent("EquipItem")


mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    -- Logika Save/Send Trade Original (Mode Quiet)
    if method == "FireServer" and self == _G.REEquipItem then
        local uuid, categoryName = args[1], args[2]

        if tradeState.mode == "V1" and tradeState.saveTempMode then
            if uuid and categoryName then
                table.insert(tradeState.TempTradeList, {
                    UUID = uuid,
                    Category = categoryName
                })
                NotifySuccess("Save Mode", "Added item: " .. uuid .. " (" .. categoryName .. ")")
            else
                NotifyError("Save Mode", "Invalid data received.")
            end
            return nil
        end

        if tradeState.mode == "V1" and tradeState.onTrade then
            if uuid and tradeState.selectedPlayerId then
                InitiateTrade:InvokeServer(tradeState.selectedPlayerId, uuid)
                NotifySuccess("Trade Sent", "Trade sent to " .. tradeState.selectedPlayerName or tradeState.selectedPlayerId)
            else
                NotifyError("Trade Error", "Invalid target or item.")
            end
            return nil
        end
    end

	if _G.autoSellMythic 
		and method == "FireServer"
		and self == _G.REEquipItem 
		and typeof(args[1]) == "string"
		and args[2] == "Fishes" then

		local uuid = args[1]

		task.delay(1, function()
			pcall(function()
				local result = RFSellItem:InvokeServer(uuid)
				if result then
					NotifySuccess("AutoSellMythic", "Items Sold!!")
				else
					NotifyError("AutoSellMythic", "Failed to sell item!!")
				end
			end)
		end)
	end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Implementasi Auto Accept Trade
pcall(function()
    local PromptController = _G.PromptController or ReplicatedStorage:WaitForChild("Controllers").PromptController 
    local Promise = _G.Promise or require(ReplicatedStorage.Packages.Promise) 
    
    if PromptController and PromptController.FirePrompt then
        local oldFirePrompt = PromptController.FirePrompt
        PromptController.FirePrompt = function(self, promptText, ...)
            -- Cek apakah Auto Accept aktif dan prompt adalah Trade
            if _G.AutoAcceptTradeEnabled and type(promptText) == "string" and promptText:find("Accept") and promptText:find("from:") then
                -- Mengembalikan Promise yang otomatis me-resolve (menerima) setelah jeda.
                return Promise.new(function(resolve)
                    task.wait(2) -- Tunggu 2 detik
                    resolve(true)
                end)
            end
            return oldFirePrompt(self, promptText, ...)
        end
    end
end)


-- =======================================================
-- DEFINISI UI
-- =======================================================

Trade:Section({Title = "Trade Mode Selection"})

local modeDropdown = Trade:Dropdown({
    Title = "Select Trade Mode",
    Values = {"V1", "V2", "V3"},
    Callback = _G.ProtectCallback(function(v)
        tradeState.mode = v
        NotifySuccess("Mode Changed", "Trade mode set to: " .. v, 3)

        -- Logika Baru untuk Menampilkan/Menyembunyikan UI
        local isV1 = (v == "V1")
        local isV2 = (v == "V2")
        local isV3 = (v == "V3")

        -- Sembunyikan/Tampilkan Elemen V1
        if _G.TradeQuietElements then
            for _, element in ipairs(_G.TradeQuietElements) do
                if element.Element then element.Element.Visible = isV1 end
            end
        end
        
        -- Sembunyikan/Tampilkan Elemen V2
        if _G.TradeV2Elements then
            for _, element in ipairs(_G.TradeV2Elements) do
                if element.Element then element.Element.Visible = isV2 end
            end
        end

        -- Sembunyikan/Tampilkan Elemen V3
        if _G.TradeV3Elements then
            for _, element in ipairs(_G.TradeV3Elements) do
                if element.Element then element.Element.Visible = isV3 end
            end
        end
    end)
})

_G.PlayerDropdownTrade = Trade:Dropdown({
    Title = "Select Player",
    Values = getPlayerListV2(),
    SearchBarEnabled = true,
    AllowNone = true,
    Callback = function(name)
        if tradeState.selectedPlayerName == name then return end

        tradeState.selectedPlayerName = name

        local player = Players:FindFirstChild(name)
        tradeState.selectedPlayerId = player and player.UserId or nil
    end
})

Players.PlayerAdded:Connect(function()
    task.wait(0.1)
    refreshDropdownV2()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    refreshDropdownV2()
end)

Trade:Section({Title = "Auto Accept Trade"})

Trade:Toggle({
    Title = "Enable Auto Accept Trade",
    Desc = "Automatically accepts incoming trade requests.",
    Value = false,
    Callback = _G.ProtectCallback(function(value)
        _G.AutoAcceptTradeEnabled = value
        if value then
            NotifySuccess("Auto Accept", "Auto accept trade enabled.", 3)
        else
            NotifyWarning("Auto Accept", "Auto accept trade disabled.", 3)
        end
    end)
})

Trade:Section({Title = "Mode V1"})
_G.TradeQuietElements = {}

-- Toggle Mode Save Items (Mode V1)
local saveModeToggle = Trade:Toggle({
    Title = "Mode Save Items",
    Desc = "Click inventory item to add for Mass Trade",
    Value = false,
    Callback = _G.ProtectCallback(function(state)
        tradeState.saveTempMode = state
        if state then
            tradeState.TempTradeList = {}
            NotifySuccess("Save Mode", "Enabled - Click items to save")
        else
            NotifyInfo("Save Mode", "Disabled - "..#tradeState.TempTradeList.." items saved")
        end
    end)
})

table.insert(_G.TradeQuietElements, {Element = saveModeToggle})

-- Toggle Trade (Original Send) (V1)
local originalTradeToggle = Trade:Toggle({
    Title = "Trade (Original Send)",
    Desc = "Click inventory items to Send Trade",
    Value = false,
    Callback = _G.ProtectCallback(function(state)
        tradeState.onTrade = state
        if state then
            NotifySuccess("Trade", "Trade Mode Enabled. Click an item to send trade.")
        else
            NotifyWarning("Trade", "Trade Mode Disabled.")
        end
    end)
})
table.insert(_G.TradeQuietElements, {Element = originalTradeToggle})

-- Fungsi Trade All (Mode V1)
local function TradeAllQuiet()       
    if not tradeState.selectedPlayerId then    
        NotifyError("Mass Trade", "Set trade target first!")       
        return         
    end          
    if #tradeState.TempTradeList == 0 then       
        NotifyWarning("Mass Trade", "No items saved!")          
        return         
    end          
    
    NotifyInfo("Mass Trade", "Starting V1 trade of "..#tradeState.TempTradeList.." items...")      
    
    task.spawn(function()          
        for i, item in ipairs(tradeState.TempTradeList) do          
            if not tradeState.autoTradeV2 then
                NotifyWarning("Mass Trade", "V1 Trade stopped!")         
                break          
            end          
        
            local uuid = item.UUID          
            local category = item.Category          
        
            NotifyInfo("Mass Trade", "Trade item "..i.." of "..#tradeState.TempTradeList)          
            InitiateTrade:InvokeServer(tradeState.selectedPlayerId, uuid, category)          
        
            task.wait(6.5)       
        end          
    
        NotifySuccess("Mass Trade", "Finished V1 trading!")        
        tradeState.autoTradeV2 = false          
        tradeState.TempTradeList = {}          
    end)          
end

-- Toggle Auto Trade (Mode V1)
local autoTradeQuietToggle = Trade:Toggle({
    Title = "Start Mass Trade V1",
    Desc = "Trade all saved items automatically.",
    Value = false,
    Callback = function(state)
        tradeState.autoTradeV2 = state
        if tradeState.mode == "V1" and state then
            if #tradeState.TempTradeList == 0 then
                NotifyError("Mass Trade", "No items saved to trade!")
                tradeState.autoTradeV2 = false
                return
            end
            TradeAllQuiet()
            NotifySuccess("Mass Trade", "V1 Auto Trade Enabled")
        else
            NotifyWarning("Mass Trade", "V1 Auto Trade Disabled")
        end
    end
})
table.insert(_G.TradeQuietElements, {Element = autoTradeQuietToggle})

Trade:Section({Title = "V2"})
_G.TradeV2Elements = {}

local filterToggleV2 = Trade:Toggle({
    Title = "Filter Unfavorited Items Only",
    Value = false,
    Callback = function(val)
        tradeState.filterUnfavorited = val
        refreshInventory()
        NotifyInfo("Filter Updated", "Inventory list refreshed.", 3)
    end
})
table.insert(_G.TradeV2Elements, {Element = filterToggleV2})

_G.InventoryDropdown = Trade:Dropdown({
    Title = "Select Item from Inventory",
    Values = {"- Refresh to load -"},
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(val)
        tradeState.selectedItemName = val
    end
})
table.insert(_G.TradeV2Elements, {Element = _G.InventoryDropdown})

Trade:Button({ Title = "Refresh Inventory & Players", Icon = "refresh-cw", Callback = refreshInventory })

local amountInputV2 = Trade:Input({
    Title = "Amount to Trade",
    Placeholder = "Enter amount...",
    Type = "Input",
    Callback = function(val)
        tradeState.tradeAmount = tonumber(val) or 0
    end
})
table.insert(_G.TradeV2Elements, {Element = amountInputV2})

local statusParagraphV2 = Trade:Paragraph({ Title = "Status V2", Desc = "Waiting to start..." })
table.insert(_G.TradeV2Elements, {Element = statusParagraphV2})

Trade:Toggle({
    Title = "Start Mass Trade V2",
    Value = false,
    Callback = function(value)
        tradeState.autoTradeV2 = value

        if tradeState.mode == "V2" and value then
            task.spawn(function()
                if not tradeState.selectedItemName
                    or not tradeState.selectedPlayerId
                    or tradeState.tradeAmount <= 0
                then
                    statusParagraphV2:SetDesc("Error: Select item, amount, and player.")
                    tradeState.autoTradeV2 = false
                    return
                end

                -- 🧼 CLEAN NAME
                local cleanItemName =
                    tradeState.selectedItemName:match("^(.*) %((%d+)x%)$")
                if cleanItemName then
                    cleanItemName = cleanItemName:match("^(.*)")
                else
                    cleanItemName = tradeState.selectedItemName
                end

                local itemData = inventoryCache[cleanItemName]
                if not itemData then
                    statusParagraphV2:SetDesc("Error: Item not found. Refresh inventory.")
                    tradeState.autoTradeV2 = false
                    return
                end

                -- 📦 VALIDASI JUMLAH
                if itemData.Mode == "UUID" then
                    if #itemData.UUIDs < tradeState.tradeAmount then
                        statusParagraphV2:SetDesc("Error: Not enough items.")
                        tradeState.autoTradeV2 = false
                        return
                    end
                elseif itemData.Mode == "Quantity" then
                    if itemData.Quantity < tradeState.tradeAmount then
                        statusParagraphV2:SetDesc("Error: Not enough quantity.")
                        tradeState.autoTradeV2 = false
                        return
                    end
                end

                local successCount, failCount = 0, 0
                local targetName = tradeState.selectedPlayerName

                for i = 1, tradeState.tradeAmount do
                    if not tradeState.autoTradeV2 then
                        statusParagraphV2:SetDesc("Process stopped by user.")
                        break
                    end

                    -- 🎯 AMBIL UUID
                    local uuid
                    if itemData.Mode == "UUID" then
                        uuid = itemData.UUIDs[i]
                    else
                        uuid = itemData.UUID -- SAME UUID, MANY TIMES
                    end

                    statusParagraphV2:SetDesc(string.format(
                        "Progress: %d/%d | Sending to: %s | Status: <font color='#eab308'>Waiting...</font>",
                        i, tradeState.tradeAmount, targetName
                    ))

                    local success, result = pcall(
                        InitiateTrade.InvokeServer,
                        InitiateTrade,
                        tradeState.selectedPlayerId,
                        uuid
                    )

                    if success and result then
                        successCount = successCount + 1
                    else
                        failCount = failCount + 1
                    end

                    statusParagraphV2:SetDesc(string.format(
                        "Progress: %d/%d | Sent: %s | Success: %d | Failed: %d",
                        i,
                        tradeState.tradeAmount,
                        success and "✔" or "✖",
                        successCount,
                        failCount
                    ))

                    task.wait(5)
                end

                statusParagraphV2:SetDesc(string.format(
                    "Trade V2 Complete.\nSuccessful: %d | Failed: %d",
                    successCount,
                    failCount
                ))

                tradeState.autoTradeV2 = false
                refreshInventory()
            end)
        end
    end
})

-- Sembunyikan elemen GLua secara default, kecuali tombol refresh dan dropdown mode
for _, element in ipairs(_G.TradeV2Elements) do
    if element.Element then element.Element.Visible = false end
end

-- Pastikan elemen Quiet terlihat
for _, element in ipairs(_G.TradeQuietElements) do
    if element.Element then element.Element.Visible = true end
end

-------------------------------------------
----- ======= V3 - MASS TRADE BY CATEGORY
-------------------------------------------


if Trade and GlobalFav and GlobalFav.Variants and NotifyWarning and _G.Replion and _G.ItemUtility and _G.ItemStringUtility and InitiateTrade then
    
    _G.TradeV3Elements = {}

    local V3_Section = Trade:Section({Title = "V3 - Mass Trade by Category"})
    table.insert(_G.TradeV3Elements, {Element = V3_Section}) -- Daftarkan UI

    -- Data yang diperlukan untuk Tiers
    local tierMap = {
        ["Common"] = 1, ["Uncommon"] = 2, ["Rare"] = 3, ["Epic"] = 4,
        ["Legendary"] = 5, ["Mythic"] = 6, ["SECRET"] = 7
    }
    local tierNames = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET" }

    local variantNames = {}
    for vName, _ in pairs(GlobalFav.Variants) do
        table.insert(variantNames, vName)
    end
    table.sort(variantNames)
    
    -- State untuk V3
    -- State untuk V3
    local categoryTradeState = {
        selectedTiers = {}, selectedVariants = {},
        filterUnfavorited = false, autoTrade = false,
        tradeAmount = 0 -- TAMBAHKAN BARIS INI
    }
    -- UI V3
    local V3_TierDropdown = Trade:Dropdown({
        Title = "Select Tiers (Rarity) to Trade",
        Values = tierNames, Multi = true, AllowNone = true,
        Callback = _G.ProtectCallback(function(selectedNames)
            categoryTradeState.selectedTiers = {}
            for _, name in ipairs(selectedNames or {}) do
                if tierMap[name] then table.insert(categoryTradeState.selectedTiers, tierMap[name]) end
            end
            NotifyInfo("Trade V3", "Tiers to trade: " .. table.concat(selectedNames, ", "))
        end)
    })

    table.insert(_G.TradeV3Elements, {Element = V3_TierDropdown}) -- Daftarkan UI

    local V3_VariantDropdown = Trade:Dropdown({
        Title = "Select Mutations (Variants) to Trade",
        Values = variantNames, 
        Multi = true, 
        AllowNone = true,
        Callback = _G.ProtectCallback(function(selectedNames)
            categoryTradeState.selectedVariants = selectedNames or {}
            NotifyInfo("Trade V3", "Mutations to trade: " .. table.concat(selectedNames, ", "))
        end)
    })

    V3_VariantDropdown:Refresh(variantNames)

    local V3_FilterToggle = Trade:Toggle({
        Title = "Filter Unfavorited Items Only",
        Desc = "Hanya mengirim item yang tidak di-lock (favorite).",
        Value = false,
        Callback = _G.ProtectCallback(function(val)
            categoryTradeState.filterUnfavorited = val
            NotifyInfo("Trade V3", "Filter Unfavorited: " .. tostring(val))
        end)
    })
    table.insert(_G.TradeV3Elements, {Element = V3_FilterToggle}) -- Daftarkan UI
    
    -- ===================================
    -- == [BARU] INPUT AMOUNT UNTUK V3
    -- ===================================
    local V3_AmountInput = Trade:Input({
        Title = "Amount to Trade",
        Placeholder = "Enter amount...",
        Type = "Input",
        Callback = function(val)
            categoryTradeState.tradeAmount = tonumber(val) or 0
        end
    })
    table.insert(_G.TradeV3Elements, {Element = V3_AmountInput})

    local V3_StatusParagraph = Trade:Paragraph({
        Title = "Status V3", Desc = "Waiting to start..."
    })
    table.insert(_G.TradeV3Elements, {Element = V3_StatusParagraph}) -- Daftarkan UI

    local V3_StartToggle = Trade:Toggle({
        Title = "Start Mass Category Trade", Value = false,
        Callback = function(value)
            categoryTradeState.autoTrade = value
            if not value then V3_StatusParagraph:SetDesc("Stopping..."); return end

            task.spawn(function()
                -- 1. Validasi
                if not tradeState.selectedPlayerId then
                    V3_StatusParagraph:SetDesc("Error: Please select a player from the 'Select Trade Target' dropdown above.")
                    pcall(V3_StartToggle.SetValue, V3_StartToggle, false); return
                end
                if #categoryTradeState.selectedTiers == 0 and #categoryTradeState.selectedVariants == 0 then
                    V3_StatusParagraph:SetDesc("Error: Select at least one Tier or Mutation to trade.")
                    pcall(V3_StartToggle.SetValue, V3_StartToggle, false); return
                end
                
                -- ===================================
                -- == [BARU] VALIDASI AMOUNT V3
                -- ===================================
                if categoryTradeState.tradeAmount <= 0 then
                    V3_StatusParagraph:SetDesc("Error: Please enter a valid amount in the 'Amount to Trade (V3)' input.")
                    pcall(V3_StartToggle.SetValue, V3_StartToggle, false); return
                end
                -- ===================================

                local DataReplion = _G.Replion.Client:WaitReplion("Data")
                if not DataReplion then
                    V3_StatusParagraph:SetDesc("Error: Could not get player data (Replion).")
                    pcall(V3_StartToggle.SetValue, V3_StartToggle, false); return
                end

                -- 2. Scan inventaris
                V3_StatusParagraph:SetDesc("Scanning inventory for matching items..."); task.wait(0.5)
                local uuidsToSend, itemNamesSummary = {}, {}
                local inventoryItems = DataReplion:Get({ "Inventory", "Items" })
                if not inventoryItems then
                    V3_StatusParagraph:SetDesc("Error: Inventory is empty.")
                    pcall(V3_StartToggle.SetValue, V3_StartToggle, false); return
                end

                -- 3. Filter item (Logika ini tetap sama)
                for _, itemData in ipairs(inventoryItems) do
                    if not categoryTradeState.autoTrade then break end
                    if not (categoryTradeState.filterUnfavorited and itemData.Favorited) then
                        local baseItemData = _G.ItemUtility:GetItemData(itemData.Id)
                        if baseItemData and baseItemData.Data and baseItemData.Data.Type == "Fish" then
                            local match = false
                            if #categoryTradeState.selectedTiers > 0 then
                                if baseItemData.Data.Tier and table.find(categoryTradeState.selectedTiers, baseItemData.Data.Tier) then match = true end
                            end
                            if not match and #categoryTradeState.selectedVariants > 0 then
                                if itemData.Metadata and type(itemData.Metadata) == "table" then
                                    local itemMutations = {}
                                    if itemData.Metadata.VariantId then table.insert(itemMutations, itemData.Metadata.VariantId) end
                                    if itemData.Metadata.Shiny == true then table.insert(itemMutations, "Shiny") end
                                    for _, itemMutationName in ipairs(itemMutations) do
                                        if table.find(categoryTradeState.selectedVariants, itemMutationName) then match = true; break end
                                    end
                                end
                            end
                            if match then
                                table.insert(uuidsToSend, itemData.UUID)
                                local simpleName = _G.ItemStringUtility.GetItemName(itemData, baseItemData)
                                itemNamesSummary[simpleName] = (itemNamesSummary[simpleName] or 0) + 1
                            end
                        end
                    end
                end

                if not categoryTradeState.autoTrade then V3_StatusParagraph:SetDesc("Trade stopped during scan."); return end
                if #uuidsToSend == 0 then
                    V3_StatusParagraph:SetDesc("Complete: No matching items found to trade.")
                    pcall(V3_StartToggle.SetValue, V3_StartToggle, false); return
                end

                -- ===================================
                -- == [DIUBAH] LOGIKA PENGIRIMAN ITEM DENGAN AMOUNT
                -- ===================================
                
                -- 4. Kirim item
                local totalFound = #uuidsToSend
                -- Gunakan math.min untuk mengambil jumlah yang lebih kecil antara yang ditemukan dan yang diminta
                local amountToSend = math.min(totalFound, categoryTradeState.tradeAmount) 
                local successCount, failCount = 0, 0
                local targetName = tradeState.selectedPlayerName

                -- Ubah loop dari 'ipairs' menjadi loop numerik sampai 'amountToSend'
                for i = 1, amountToSend do
                    if not categoryTradeState.autoTrade then V3_StatusParagraph:SetDesc("Trade stopped by user."); break end
                    
                    local uuid = uuidsToSend[i] -- Ambil UUID berdasarkan index
                    
                    -- Update status untuk menunjukkan progress, amount, dan total yang ditemukan
                    V3_StatusParagraph:SetDesc(string.format(
                        "Progress: %d/%d (Found: %d)\nSending to: %s\nSuccess: %d | Failed: %d", 
                        i, amountToSend, totalFound, targetName, successCount, failCount
                    ))
                    
                    local success, result = pcall(InitiateTrade.InvokeServer, InitiateTrade, tradeState.selectedPlayerId, uuid)
                    if success and result then successCount = successCount + 1 else failCount = failCount + 1 end
                    task.wait(5)
                end

                -- 5. Laporan akhir
                local finalSummary = string.format(
                    "Process Complete.\nTotal Attempted: %d of %d found.\nSuccessful: %d | Failed: %d", 
                    amountToSend, totalFound, successCount, failCount
                )
                -- ===================================

                V3_StatusParagraph:SetDesc(finalSummary)
                NotifySuccess("Mass Category Trade", finalSummary, 7)
                pcall(V3_StartToggle.SetValue, V3_StartToggle, false)
            end)
        end
    })
    table.insert(_G.TradeV3Elements, {Element = V3_StartToggle}) -- Daftarkan UI


else
    task.spawn(function()
        task.wait(2)
        NotifyError("Trade V3 Load Error", "Gagal memuat fitur Trade V3. Dependensi penting (seperti Trade atau GlobalFav) tidak ditemukan. Anda mungkin salah menempelkan kode atau skrip QuietXHub Anda tidak lengkap.", 10)
    end)
end

-------------------------------------------
----- =======[ PLAYER TAB ]
-------------------------------------------

local currentDropdown = nil

local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.DisplayName)
        end
    end
    return list
end


local function teleportToPlayerExact(target)
    local characters = workspace:FindFirstChild("Characters")
    if not characters then return end

    local targetChar = characters:FindFirstChild(target)
    local myChar = characters:FindFirstChild(LocalPlayer.Name)

    if targetChar and myChar then
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            myHRP.CFrame = targetHRP.CFrame + Vector3.new(2, 0, 0)
        end
    end
end

local function refreshDropdown()
    if currentDropdown then
        currentDropdown:Refresh(getPlayerList())
    end
end

currentDropdown = Player:Dropdown({
    Title = "Teleport to Player",
    Desc = "Select player to teleport",
    Values = getPlayerList(),
    Callback = function(selectedDisplayName)
        for _, p in pairs(Players:GetPlayers()) do
            if p.DisplayName == selectedDisplayName then
                teleportToPlayerExact(p.Name)
                NotifySuccess("Teleport Successfully", "Successfully Teleported to " .. p.DisplayName .. "!", 3)
                break
            end
        end
    end
})

Players.PlayerAdded:Connect(function()
    task.delay(0.1, refreshDropdown)
end)

Players.PlayerRemoving:Connect(function()
    task.delay(0.1, refreshDropdown)
end)

refreshDropdown()


local defaultMinZoom = LocalPlayer.CameraMinZoomDistance
local defaultMaxZoom = LocalPlayer.CameraMaxZoomDistance

Player:Toggle({
    Title = "Unlimited Zoom",
    Desc = "Unlimited Camera Zoom for take a Picture",
    Value = false,
    Callback = function(state)
        if state then
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 9999
        else
            LocalPlayer.CameraMinZoomDistance = defaultMinZoom
            LocalPlayer.CameraMaxZoomDistance = defaultMaxZoom
        end
    end
})


Player:Space()

Player:Toggle({
	Title = "Infinity Jump",
	Callback = function(val)
		ijump = val
	end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
	if ijump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end
end)

local EnableFloat = Player:Toggle({
	Title = "Enable Float",
	Value = false,
	Callback = function(enabled)
			floatingPlat(enabled)
	end,
})

myConfig:Register("ActiveFloat", EnableFloat)

local universalNoclip = false
local originalCollisionState = {}

local NoClip = Player:Toggle({
	Title = "Universal No Clip",
	Value = false,
	Callback = function(val)
		universalNoclip = val

		if val then
			NotifySuccess("Universal Noclip Active", "You & your vehicle can penetrate all objects.", 3)
		else

			for part, state in pairs(originalCollisionState) do
				if part and part:IsA("BasePart") then
					part.CanCollide = state
				end
			end
			originalCollisionState = {}
			NotifyWarning("Universal Noclip Disabled", "All collisions are returned to their original state.", 3)
		end
	end,
})

game:GetService("RunService").Stepped:Connect(function()
	if not universalNoclip then return end

	local char = LocalPlayer.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide == true then
				originalCollisionState[part] = true
				part.CanCollide = false
			end
		end
	end

	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChildWhichIsA("VehicleSeat", true) then
			for _, part in ipairs(model:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide == true then
					originalCollisionState[part] = true
					part.CanCollide = false
				end
			end
		end
	end
end)

myConfig:Register("NoClip", NoClip)

local AntiDrown_Enabled = false
local rawmt = getrawmetatable(game)
setreadonly(rawmt, false)
local oldNamecall = rawmt.__namecall

rawmt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if tostring(self) == "URE/UpdateOxygen" and method == "FireServer" and AntiDrown_Enabled then
        return nil
    end

    return oldNamecall(self, ...)
end)

local DrownBN = true

local ADrown = Player:Toggle({
	Title = "Anti Drown (Oxygen Bypass)",
	Callback = function(state)
		AntiDrown_Enabled = state
		if DrownBN then
			DrownBN = false
			return
		end
		if state then
			NotifySuccess("Anti Drown Active", "Oxygen loss has been blocked.", 3)
		else
			NotifyWarning("Anti Drown Disabled", "You're vulnerable to drowning again.", 3)
		end
	end,
})

myConfig:Register("AntiDrown", ADrown)

local Speed = Player:Slider({
	Title = "WalkSpeed",
	Value = {
	    Min = 16,
	    Max = 200,
	    Default = 20
	},
	Step = 1,
	Callback = function(val)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val end
	end,
})

myConfig:Register("PlayerSpeed", Speed)

local Jp = Player:Slider({
	Title = "Jump Power",
	Value = {
	    Min = 50, 
	    Max = 500,
	    Default = 35
	},
	Step = 10,
	Callback = function(val)
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.UseJumpPower = true
				hum.JumpPower = val
			end
		end
	end,
})

myConfig:Register("JumpPower", Jp)

-------------------------------------------
----- =======[ UTILITY TAB ]
-------------------------------------------

_G.CharmShop = Utils:Section({
    Title = "Charm Shop",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

--------------------------------------------------------------------
-- ========== [ CHARM SHOP ] ==========
--------------------------------------------------------------------

_G.CharmIndex = {}         -- name -> data
_G.CharmIdIndex = {}      -- id -> name
_G.CharmNames = {}        -- dropdown list

_G.selectedCharmName = nil
_G.buyCharmAmount = 1

_G.TIER_LABELS = {
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "SECRET"
}

for _, charmModule in ipairs(ReplicatedStorage.Charms:GetChildren()) do
    local ok, charmData = pcall(require, charmModule)
    if ok and charmData and charmData.Data then
        local name = charmData.Data.Name
        local id = charmData.Data.Id

        _G.CharmIndex[name] = charmData
        _G.CharmIdIndex[id] = name
        table.insert(_G.CharmNames, name)
    end
end

table.sort(_G.CharmNames)

_G.CharmDetailParagraph = _G.CharmShop:Paragraph({
    Title = "Charm Detail",
    Desc = "Select a charm to view details"
})

_G.getCharmData = function()
    local replion = _G.Replion.Client:WaitReplion("Data")
    local inv = replion:Get({"Inventory","Charms"}) or {}

    local owned = {}

    for _, c in ipairs(inv) do
        local name = _G.CharmIdIndex[c.Id]
        if name then
            owned[name] = {
                Quantity = c.Quantity,
                UUID = c.UUID
            }
        end
    end

    return owned
end

_G.updateCharmParagraph = function()
    local owned = _G.getCharmData()

    local lines = {}
    for name, charm in pairs(_G.CharmIndex) do
        local qty = owned[name] and owned[name].Quantity or 0
        local price = charm.Price or 0
        local tier = charm.Data.Tier or "?"

        table.insert(lines,
            string.format(
                "%s | Owned: %d | Tier: %s | Price: %s",
                name,
                qty,
                tier,
                tostring(price)
            )
        )
    end

    _G.CharmInfoParagraph:SetDesc(table.concat(lines, "\n"))
end

_G.PurchaseCharmRF = Net:RemoteFunction("PurchaseCharm")

_G.EquipCharmRE = Net:RemoteEvent("EquipCharm")
    
--------------------------------------------------------------------
-- ========== [ CHARM DETAIL DROPDOWN ] ==========
--------------------------------------------------------------------

_G.getCharmBonus = function(name)
    local replion = _G.Replion.Client:WaitReplion("Data")
    local mods = replion:Get({"CharmModifiers"}) or {}
    return mods[name] or 0
end

_G.selectedCharmName = nil

_G.CharmDropdown = _G.CharmShop:Dropdown({
    Title = "Select Charm",
    Values = _G.CharmNames,
    AllowNone = true,
    Callback = function(name)
        _G.selectedCharmName = name
        if not name then return end

        local charm = _G.CharmIndex[name]
        if not charm then return end

        local owned = _G.getCharmData()[name]
        local qty = owned and owned.Quantity or 0
        local bonus = _G.getCharmBonus(name)

        local tierNum = charm.Data.Tier
        local tierLabel = _G.TIER_LABELS[tierNum] or ("Tier " .. tostring(tierNum))

        local fishMods = {}
        if charm.FishModifiers then
            for fish, val in pairs(charm.FishModifiers) do
                table.insert(fishMods, fish .. " +" .. math.floor(val * 100) .. "%")
            end
        end

        _G.CharmDetailParagraph:SetDesc(string.format(
            [[Name : %s
Rarity : %s
Price : %s
Owned : %d
Bonus : %d

Description:
%s

Fish Buffs:
%s]],
            name,
            tierLabel,
            tostring(charm.Price),
            qty,
            bonus,
            charm.Data.Description or "-",
            #fishMods > 0 and table.concat(fishMods, "\n") or "None"
        ))
    end
})

--------------------------------------------------------------------
-- 🔄 AUTO UPDATE BONUS REAL-TIME
--------------------------------------------------------------------
_G.CharmReplion = _G.Replion.Client:WaitReplion("Data")
_G.CharmReplion:OnChange({"CharmModifiers"}, function()
    if not _G.selectedCharmName then return end

    local name = _G.selectedCharmName
    local charm = _G.CharmIndex[name]
    if not charm then return end

    local owned = _G.getCharmData()[name]
    local qty = owned and owned.Quantity or 0
    local bonus = _G.getCharmBonus(name)

    local tierNum = charm.Data.Tier
    local tierLabel = _G.TIER_LABELS[tierNum] or ("Tier " .. tostring(tierNum))

    local fishMods = {}
    if charm.FishModifiers then
        for fish, val in pairs(charm.FishModifiers) do
            table.insert(fishMods, fish .. " +" .. math.floor(val * 100) .. "%")
        end
    end

    _G.CharmDetailParagraph:SetDesc(string.format(
        [[Name : %s
Rarity : %s
Price : %s
Owned : %d
Bonus : %d

Description:
%s

Fish Buffs:
%s]],
        name,
        tierLabel,
        tostring(charm.Price),
        qty,
        bonus,
        charm.Data.Description or "-",
        #fishMods > 0 and table.concat(fishMods, "\n") or "None"
    ))
end)

_G.CharmShop:Input({
    Title = "Buy Amount",
    Placeholder = "Enter amount",
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            _G.buyCharmAmount = math.floor(num)
        else
            _G.buyCharmAmount = 1
        end
    end
})

_G.CharmShop:Button({
    Title = "Buy & Auto Equip Charm",
    Callback = function()
        if not _G.selectedCharmName then
            NotifyError("Charm", "Select charm first")
            return
        end

        local charm = _G.CharmIndex[_G.selectedCharmName]
        if not charm then return end

        local id = charm.Data.Id

        for i = 1, _G.buyCharmAmount do
            local ok = pcall(function()
                _G.PurchaseCharmRF:InvokeServer(id)
            end)

            if not ok then
                NotifyError("Charm", "Purchase failed at #" .. i)
                break
            end

            task.wait(0.25)
        end

        task.wait(0.3)
        pcall(function()
            _G.EquipCharmRE:FireServer(_G.selectedCharmName)
        end)

        NotifySuccess("Charm", "Purchased x" .. _G.buyCharmAmount .. " & Equipped")

        task.wait(0.6)
        _G.updateCharmParagraph()
    end
})

_G.CharmReplion:OnChange({"Inventory","Charms"}, function()
    _G.updateCharmParagraph()
end)

--------------------------------------------------------------------
-- ========== [ TRAVELING MERCHANT DISPLAY V1 (Clean UI) ] ==========
--------------------------------------------------------------------

_G.MarketItemData = require(ReplicatedStorage.Shared.MarketItemData)
_G.MerchantReplion = _G.Replion.Client:WaitReplion("Merchant")
_G.RFPurchaseMarketItem = Net:RemoteFunction("PurchaseMarketItem")
    
_G.MarketById = {}
for _, item in ipairs(_G.MarketItemData) do
    _G.MarketById[item.Id] = item
end

_G.MerchantUIState = {
    CurrentItemIds = {},      
    SelectedItemId = nil,      
}

_G.MerchantStatus = Utils:Paragraph({
    Title = "Merchant Status",
    Desc = "Waiting merchant update..."
})

_G.MerchantDropdown = Utils:Dropdown({
    Title = "Merchant Items",
    Values = { "Waiting data..." },
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(str)
        if not str or str == "" then
            _G.MerchantUIState.SelectedItemId = nil
            return
        end

        -- Ambil ID dari mapping internal
        local id = _G.DropdownNameToId[str]
        _G.MerchantUIState.SelectedItemId = id

        if id then
            local item = _G.MarketById[id]
            _G.MerchantStatus:SetDesc("Selected: " .. (item.Identifier or "Unknown"))
        end
    end
})

Utils:Button({
    Title = "Buy Selected Item",
    Callback = function()
        local id = _G.MerchantUIState.SelectedItemId
        if not id then
            return NotifyError("Merchant", "No item selected.")
        end

        local ok, result = pcall(
            _G.RFPurchaseMarketItem.InvokeServer,
            _G.RFPurchaseMarketItem,
            id
        )

        if ok and result then
            NotifySuccess("Merchant", "Purchase Success!")
        else
            NotifyError("Merchant", "Purchase Failed.")
        end
    end
})

function RefreshMerchantItems()
    local data = _G.MerchantReplion:Get({"Items"})

    if not data then
        _G.MerchantDropdown:Refresh({"Empty"})
        _G.MerchantStatus:SetDesc("Merchant empty.")
        return
    end

    local dropdownList = {}
    _G.DropdownNameToId = {} 

    _G.MerchantUIState.CurrentItemIds = data

    for _, id in ipairs(data) do
        local item = _G.MarketById[id]

        -- FILTER: Only Coins
        if item and item.Currency == "Coins" then
            local display = string.format(
                "%s | %s Coins",
                item.Identifier,
                tostring(item.Price or "?")
            )

            table.insert(dropdownList, display)
            _G.DropdownNameToId[display] = id
        end
    end

    table.sort(dropdownList)

    if #dropdownList == 0 then
        table.insert(dropdownList, "No Coin Items")
    end

    _G.MerchantDropdown:Refresh(dropdownList)
    _G.MerchantStatus:SetDesc("Merchant Updated. (" .. #dropdownList .. " items)")
end

_G.MerchantReplion:OnDataChange(function()
    task.delay(0.2, RefreshMerchantItems)
end)

task.delay(0.5, RefreshMerchantItems)


Utils:Space()


_G.RFRedeemCode = Net:RemoteFunction("RedeemCode")

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
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.RedeemAllCodes()
    end
})

Utils:Space()


-- =================================================================
-- LIBRARY & DEPENDENCIES
-- =================================================================
_G.ItemUtilityModule = require(ReplicatedStorage.Shared.ItemUtility)
_G.ClientReplionModule = require(ReplicatedStorage.Packages._Index["ytrev_replion@2.0.0-rc.3"].replion.Client.ClientReplion)

-- Menyimpan Remote Event
_G.RESpawnTotem = Net:RemoteEvent("SpawnTotem")

-- Mencoba mencari Remote Oxygen Tank (Untuk Anti-Drown)
pcall(function()
    local packages = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
    if packages then
        for _, v in pairs(packages:GetDescendants()) do
            if v.Name == "RF/EquipOxygenTank" then _G.RF_EquipOxygenTank = v end
            if v.Name == "RF/UnequipOxygenTank" then _G.RF_UnequipOxygenTank = v end
        end
    end
end)

-- =================================================================
-- VARIABLES & CONFIGURATION
-- =================================================================
_G.TotemInventoryCache = {} 
_G.TotemsList = {}
_G.AutoTotemState = {
    IsRunning = false,
    DelayMinutes = 10,
    SelectedTotemName = nil,
    LoopThread = nil,
}

_G.AUTO_9_TOTEM_ACTIVE = false
_G.AUTO_9_TOTEM_THREAD = nil
_G.stateConnection = nil
_G.RunService = game:GetService("RunService")

-- [CONFIG] Koordinat Formasi V3 (Relative Offsets)
-- Ini memastikan formasi tetap rapi (3 Bawah, 3 Tengah, 3 Atas)
_G.REF_CENTER = Vector3.new(93.932, 9.532, 2684.134)
_G.REF_SPOTS = {
    -- TENGAH (Y ~ 9.5)
    Vector3.new(45.0468979, 9.51625347, 2730.19067),   -- 1
    Vector3.new(145.644608, 9.51625347, 2721.90747),   -- 2
    Vector3.new(84.6406631, 10.2174253, 2636.05786),   -- 3
    -- ATAS (Y ~ 109.5)
    Vector3.new(45.0468979, 110.516253, 2730.19067),   -- 4
    Vector3.new(145.644608, 110.516253, 2721.90747),   -- 5
    Vector3.new(84.6406631, 111.217425, 2636.05786),   -- 6
    -- BAWAH (Y ~ -90.5)
    Vector3.new(45.0468979, -92.483747, 2730.19067),   -- 7
    Vector3.new(145.644608, -92.483747, 2721.90747),   -- 8
    Vector3.new(84.6406631, -93.782575, 2636.05786),   -- 9
}

-- =================================================================
-- INVENTORY FUNCTIONS
-- =================================================================
function _G.RefreshTotemInventory()
    if not _G.DataReplion then return end

    _G.TotemInventoryCache = {}
    _G.TotemsList = {}

    local items = _G.DataReplion:Get({ "Inventory", "Totems" })

    if not items then
        if _G.TotemDropdown then _G.TotemDropdown:Refresh({}) end
        if _G.TotemStatusParagraph then
            _G.TotemStatusParagraph:SetDesc("Inventory refreshed. Found 0 types of totems.")
        end
        return
    end

    for _, item in ipairs(items) do
        local totemData = _G.ItemUtilityModule:GetTotemsData(item.Id)
        if totemData and totemData.Data then
            local name = totemData.Data.Name
            if not _G.TotemInventoryCache[name] then
                _G.TotemInventoryCache[name] = {}
            end
            table.insert(_G.TotemInventoryCache[name], item.UUID)
        end
    end

    for name, list in pairs(_G.TotemInventoryCache) do
        local count = #list 
        table.insert(_G.TotemsList, string.format("%s (x%d)", name, count))
    end

    table.sort(_G.TotemsList)

    if _G.TotemDropdown then
        _G.TotemDropdown:Refresh(_G.TotemsList)
    end

    if _G.TotemStatusParagraph then
        _G.TotemStatusParagraph:SetDesc(
            string.format("Inventory refreshed. Found %d types of totems.", #_G.TotemsList)
        )
    end
end

function _G.ConsumeTotemUUID(totemName)
    if not _G.TotemInventoryCache then return nil end
    -- Bersihkan nama dari "(x5)" -> "Luck Totem"
    local cleanName = totemName:match("^(.-) %(") or totemName
    
    local list = _G.TotemInventoryCache[cleanName]
    if list and #list > 0 then
        return table.remove(list, 1)
    end
    return nil
end

-- =================================================================
-- PHYSICS V3 ENGINE (Anti-Fall & Smooth Fly)
-- =================================================================
function _G.GetFlyPart()
    local char = game.Players.LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
end

function _G.MaintainAntiFallState(enable)
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end

    if enable then
        -- Matikan state jatuh agar server tidak menolak posisi
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)

        if not _G.stateConnection then
            _G.stateConnection = _G.RunService.Heartbeat:Connect(function()
                if hum and _G.AUTO_9_TOTEM_ACTIVE then
                    -- Paksa swimming agar stabil di udara
                    hum:ChangeState(Enum.HumanoidStateType.Swimming)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                end
            end)
        end
    else
        if _G.stateConnection then _G.stateConnection:Disconnect(); _G.stateConnection = nil end
        -- Kembalikan normal
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
end

function _G.EnableV3Physics()
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local mainPart = _G.GetFlyPart()
    
    if not mainPart or not hum then return end

    if char:FindFirstChild("Animate") then char.Animate.Disabled = true end
    hum.PlatformStand = true
    
    _G.MaintainAntiFallState(true)

    local bg = mainPart:FindFirstChild("FlyGuiGyro") or Instance.new("BodyGyro")
    bg.Name = "FlyGuiGyro"; bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = mainPart.CFrame; bg.Parent = mainPart

    local bv = mainPart:FindFirstChild("FlyGuiVelocity") or Instance.new("BodyVelocity")
    bv.Name = "FlyGuiVelocity"; bv.velocity = Vector3.new(0, 0.1, 0); bv.maxForce = Vector3.new(9e9, 9e9, 9e9); bv.Parent = mainPart

    task.spawn(function()
        while _G.AUTO_9_TOTEM_ACTIVE and char do
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            task.wait(0.1)
        end
    end)
end

function _G.DisableV3Physics()
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local mainPart = _G.GetFlyPart()

    if mainPart then
        if mainPart:FindFirstChild("FlyGuiGyro") then mainPart.FlyGuiGyro:Destroy() end
        if mainPart:FindFirstChild("FlyGuiVelocity") then mainPart.FlyGuiVelocity:Destroy() end

        mainPart.Velocity = Vector3.zero
        mainPart.RotVelocity = Vector3.zero
        mainPart.AssemblyLinearVelocity = Vector3.zero
        mainPart.AssemblyAngularVelocity = Vector3.zero

        local _, y, _ = mainPart.CFrame:ToEulerAnglesYXZ()
        mainPart.CFrame = CFrame.new(mainPart.Position) * CFrame.fromEulerAnglesYXZ(0, y, 0)

        -- Anti nyangkut lantai
        local ray = Ray.new(mainPart.Position, Vector3.new(0, -5, 0))
        local hit = workspace:FindPartOnRay(ray, char)
        if hit then mainPart.CFrame = mainPart.CFrame + Vector3.new(0, 3, 0) end
    end

    if hum then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    _G.MaintainAntiFallState(false)

    if char and char:FindFirstChild("Animate") then char.Animate.Disabled = false end

    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

function _G.FlyPhysicsTo(targetPos)
    local mainPart = _G.GetFlyPart()
    if not mainPart then return end
    
    local bv = mainPart:FindFirstChild("FlyGuiVelocity")
    local bg = mainPart:FindFirstChild("FlyGuiGyro")
    
    local SPEED = 120
    
    while _G.AUTO_9_TOTEM_ACTIVE do
        local currentPos = mainPart.Position
        local diff = targetPos - currentPos
        local dist = diff.Magnitude
        
        if bg then bg.CFrame = CFrame.lookAt(currentPos, targetPos) end

        if dist < 1.0 then 
            if bv then bv.velocity = Vector3.new(0, 0.1, 0) end
            break
        else
            if bv then bv.velocity = diff.Unit * SPEED end
        end
        _G.RunService.Heartbeat:Wait()
    end
end

-- =================================================================
-- LOGIC 9 TOTEM (Pause Fish -> Oxygen -> Spawn -> Resume)
-- =================================================================
function _G.Run9TotemLoop()
    if _G.AUTO_9_TOTEM_ACTIVE then return end
    
    if not _G.AutoTotemState.SelectedTotemName then 
        NotifyError("Error", "Select a totem first!")
        return 
    end

    _G.AUTO_9_TOTEM_ACTIVE = true

    task.spawn(function()
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")

        -- 1. Pause Auto Fish (Simpan state kalau gagal deteksi, asumsikan jalan kalau mau resume)
        
        local wasFishing = true
        pcall(function()
            StopAutoFish5X()
        end)

        local myStartPos = hrp.Position
        local firstPost = hrp.CFrame
        
        if _G.TotemStatusParagraph then _G.TotemStatusParagraph:SetDesc("Starting V3 Engine...") end

        -- 2. Equip Oxygen (Anti-Drown)
        if _G.RF_EquipOxygenTank then 
            pcall(function() _G.RF_EquipOxygenTank:InvokeServer(105) end) 
        end

        _G.EnableV3Physics()

        for i, refSpot in ipairs(_G.REF_SPOTS) do
            if not _G.AUTO_9_TOTEM_ACTIVE then break end

            local uuid = _G.ConsumeTotemUUID(_G.AutoTotemState.SelectedTotemName)
            if not uuid then 
                NotifyError("Error", "Ran out of totems at stack #"..i)
                break 
            end

            -- Hitung Posisi Relative
            local relativePos = refSpot - _G.REF_CENTER
            local targetPos = myStartPos + relativePos

            -- Terbang ke posisi
            if _G.TotemStatusParagraph then _G.TotemStatusParagraph:SetDesc("Flying to spot #"..i) end
            _G.FlyPhysicsTo(targetPos)

            -- Stabilisasi (0.6s)
            task.wait(0.6)

            -- Spawn Totem
            _G.RESpawnTotem:FireServer(uuid)
            if _G.TotemStatusParagraph then _G.TotemStatusParagraph:SetDesc("Spawning #"..i) end

            -- Jeda antar spawn (1.5s)
            task.wait(1.5)
        end

        -- 3. Kembali ke posisi awal
        if _G.AUTO_9_TOTEM_ACTIVE then
            if _G.TotemStatusParagraph then _G.TotemStatusParagraph:SetDesc("Returning...") end
            hrp.CFrame = firstPost
            task.wait(0.5)
        end

        -- 4. Cleanup & Landing
        if _G.RF_UnequipOxygenTank then 
            pcall(function() _G.RF_UnequipOxygenTank:InvokeServer() end) 
        end

        _G.DisableV3Physics()
        _G.AUTO_9_TOTEM_ACTIVE = false
        
        if _G.TotemStatusParagraph then _G.TotemStatusParagraph:SetDesc("Landing & Stabilizing...") end
        
        -- FIX: Tunggu sampai karakter menyentuh tanah dan animasi "GettingUp" selesai
        task.wait(1.5) 

        -- Paksa Equip Rod (Pancingan) agar AutoFish tidak error
        pcall(function()
            local bp = player.Backpack
            local rod = bp:FindFirstChild("Rod") or bp:FindFirstChild("Fishing Rod")
            if rod and hum then hum:EquipTool(rod) end
        end)
        task.wait(0.5)

        -- 5. Resume Fishing
        if wasFishing then
            if _G.TotemStatusParagraph then _G.TotemStatusParagraph:SetDesc("Resuming Auto Fish...") end
            pcall(function() StartAutoFish5X() end)
        end
        
        NotifySuccess("Success", "9 Totem Stack")
    end)
end

-- =================================================================
-- LOGIC AUTO TOTEM BIASA (SINGLE LOOP)
-- =================================================================
function _G.StopAutoTotem()
    _G.AutoTotemState.IsRunning = false
    if _G.AutoTotemState.LoopThread then
        task.cancel(_G.AutoTotemState.LoopThread)
        _G.AutoTotemState.LoopThread = nil
    end
    if _G.TotemStatusParagraph then
        _G.TotemStatusParagraph:SetDesc("Auto Totem Stopped.")
    end
    NotifyWarning("Auto Totem", "Stopped.")
end

function _G.StartAutoTotem()
    _G.AutoTotemState.IsRunning = true

    _G.AutoTotemState.LoopThread = task.spawn(function()
        while _G.AutoTotemState.IsRunning do
            local rawName = _G.AutoTotemState.SelectedTotemName
            if not rawName or rawName == "" then
                NotifyError("Auto Totem", "No totem selected.")
                return _G.StopAutoTotem()
            end

            -- Clean name
            local cleanName = rawName:match("^(.-) %(") or rawName

            -- Cek Stok
            local totemList = _G.TotemInventoryCache[cleanName]
            if not totemList or #totemList == 0 then
                _G.RefreshTotemInventory()
                task.wait(1)
                totemList = _G.TotemInventoryCache[cleanName]
                if not totemList or #totemList == 0 then
                    NotifyError("Auto Totem", "No more '" .. cleanName .. "'.")
                    return _G.StopAutoTotem()
                end
            end

            -- Pause Fishing
            pcall(function() StopAutoFish5X() end)
            task.wait(1)

            -- Spawn Totem
            local uuid = table.remove(totemList, 1)
            if uuid then
                _G.RESpawnTotem:FireServer(uuid)
                NotifySuccess("Auto Totem", "Spawned 1x " .. cleanName)
            end
            
            -- Resume Fishing
            task.wait(1)
            pcall(function() StartAutoFish5X() end)

            -- Delay Countdown
            local delaySeconds = _G.AutoTotemState.DelayMinutes * 60
            local waited = 0
            
            while waited < delaySeconds and _G.AutoTotemState.IsRunning do
                local remaining = delaySeconds - waited
                local minutes = math.floor(remaining / 60)
                local seconds = remaining % 60
            
                if _G.TotemStatusParagraph then
                    _G.TotemStatusParagraph:SetDesc(
                        string.format("Waiting %02d:%02d...", minutes, seconds)
                    )
                end
                
                local step = math.min(5, remaining)
                task.wait(step)
                waited = waited + step
            end
        end
    end)
end

-- =======================================================
-- UI SETUP
-- =======================================================

_G.TotemStatusParagraph = Utils:Paragraph({
    Title = "Auto Totem Status",
    Desc = "Waiting for data..."
})

_G.TotemDropdown = Utils:Dropdown({
    Title = "Select Totem",
    Values = {"Loading inventory..."},
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(val)
        if not val then
            _G.AutoTotemState.SelectedTotemName = nil
            return
        end
        local clean = val:match("^(.-) %(") or val
        _G.AutoTotemState.SelectedTotemName = clean
    end
})

_G.TotemDelayInput = Utils:Input({
    Title = "Delay",
    Placeholder = "Enter minutes...",
    Default = 10,
    Callback = function(val)
        _G.AutoTotemState.DelayMinutes = tonumber(val) or 10
    end
})

Utils:Button({ Title = "Refresh Totems", Icon = "refresh-cw", Callback = _G.RefreshTotemInventory })

Utils:Toggle({
    Title = "Enable Auto Totem",
    Value = false,
    Callback = function(state)
        if state then _G.StartAutoTotem() else _G.StopAutoTotem() end
    end
})

Utils:Space()

Utils:Button({
    Title = "Spawn 9 Totems",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.Run9TotemLoop()
    end
})

task.spawn(function()
    while not _G.Replion do 
        if _G.TotemStatusParagraph then _G.TotemStatusParagraph:SetDesc("Waiting for _G.Replion...") end
        task.wait(2) 
    end
    
    _G.DataReplion = _G.Replion.Client:WaitReplion("Data")
    if not _G.DataReplion then
        if _G.TotemStatusParagraph then _G.TotemStatusParagraph:SetDesc("Error: Failed to connect to Server Data.") end
        return
    end

    _G.RefreshTotemInventory()
end)


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
    local purchaseRemote = Net:RemoteFunction("PurchaseWeatherEvent")

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

local WeatherDropdown = Utils:Dropdown({
    Title = "Auto Buy Weather",
    Values = { "Storm", "Cloudy", "Snow", "Wind", "Radiant" },
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
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

Utils:Space()

local islandCoords = {
	["01"] = { name = "Weather Machine", position = Vector3.new(-1471, -3, 1929) },
	["02"] = { name = "Esoteric Depths", position = Vector3.new(3157, -1303, 1439) },
	["03"] = { name = "Tropical Grove", position = Vector3.new(-2038, 3, 3650) },
	["04"] = { name = "Stingray Shores", position = Vector3.new(-32, 4, 2773) },
	["05"] = { name = "Kohana Volcano", position = Vector3.new(-519, 24, 189) },
	["06"] = { name = "Coral Reefs", position = Vector3.new(-3095, 1, 2177) },
	["07"] = { name = "Crater Island", position = Vector3.new(968, 1, 4854) },
	["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
	["09"] = { name = "Winter Fest", position = Vector3.new(1611, 4, 3280) },
	["10"] = { name = "Isoteric Island", position = Vector3.new(1987, 4, 1400) },
	["11"] = { name = "Treasure Hall", position = Vector3.new(-3600, -267, -1558) },
	["12"] = { name = "Lost Shore", position = Vector3.new(-3663, 38, -989 ) },
	["13"] = { name = "Sishypus Statue", position = Vector3.new(-3792, -135, -986) },
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
                    hrp.CFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
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

local eventsList = { 
    "Shark Hunt", 
    "Ghost Shark Hunt", 
    "Worm Hunt", 
    "Black Hole", 
    "Shocked", 
    "Ghost Worm", 
    "Meteor Rain", 
    "Megalodon Hunt" 
}

Utils:Dropdown({
    Title = "Teleport Event",
    Values = eventsList,
    Value = "Shark Hunt",
    Callback = function(option)
        local props = workspace:FindFirstChild("Props")
        if props and props:FindFirstChild(option) then
            local targetModel
            if option == "Worm Hunt" or option == "Ghost Worm" then
                targetModel = props:FindFirstChild("Model")
            else
                targetModel = props[option]
            end

            if targetModel then
                local pivot = targetModel:GetPivot()
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = pivot + Vector3.new(0, 15, 0)
                    WindUI:Notify({
                        Title = "Event Available!",
                        Content = "Teleported To " .. option,
                        Icon = "circle-check",
                        Duration = 3
                    })
                end
            else
                WindUI:Notify({
                    Title = "Event Not Found",
                    Content = option .. " Not Found!",
                    Icon = "ban",
                    Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "Event Not Found",
                Content = option .. " Not Found!",
                Icon = "ban",
                Duration = 3
            })
        end
    end
})

local TweenService = game:GetService("TweenService")

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
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 0.1

	local tweenIn = TweenService:Create(frame, TweenInfo.new(0.2), { BackgroundTransparency = 0.1 })
	tweenIn:Play()
	tweenIn.Completed:Wait()

	wait(duration)

	local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.1 })
	tweenOut:Play()
	tweenOut.Completed:Wait()
	gui:Destroy()
end

local function SafePurchase(callback)
	local originalCFrame = HRP.CFrame
	HRP.CFrame = npcCFrame
	FadeScreen(0.2)
	pcall(callback)
	wait(0.1)
	HRP.CFrame = originalCFrame
end

local rodOptions = {}
local rodData = {}

for _, rod in ipairs(Items:GetChildren()) do
	if rod:IsA("ModuleScript") and rod.Name:find("!!!") then
		local success, module = pcall(require, rod)
		if success and module and module.Data then
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
			Net:RemoteFunction("PurchaseFishingRod"):InvokeServer(id)
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

--[[
    =====================================================================
    WEBHOOK SCRIPT UPDATE
    - Added Rod Name detection to Fish Notification.
    - Added Disconnect Notification webhook.
    - UPDATED: getValidRodName now uses the specific path structure provided:
      ...Backpack.Display.Tile.Inner.Tags.ItemName
    =====================================================================
--]]

local RodDelays = {
    ["Ares Rod"] = true,
    ["Angler Rod"] = true,
    ["Ghostfinn Rod"] = true,
    ["Bamboo Rod"] = true,
    ["Element Rod"] = true,

    ["Fluorescent Rod"] = true,
    ["Astral Rod"] = true,
    ["Hazmat Rod"] = true,
    ["Chrome Rod"] = true,
    ["Steampunk Rod"] = true,

    ["Lucky Rod"] = true,
    ["Midnight Rod"] = true,
    ["Demascus Rod"] = true,
    ["Grass Rod"] = true,
    ["Luck Rod"] = true,
    ["Carbon Rod"] = true,
    ["Lava Rod"] = true,
    ["Starter Rod"] = true,
}

local UserInputService = game:GetService("UserInputService")

local REObtainedNewFishNotification = Net:RemoteEvent("ObtainedNewFishNotification")

local webhookPath = nil
local FishWebhookEnabled = true
local LastCatchData = {}
local SelectedCategories = { "Secret" }

-------------------------------------------
----- =======[ HELPER FUNCTIONS ]
-------------------------------------------

-- FUNGSI UNTUK MENDAPATKAN NAMA EXECUTOR
local function getExecutorName()
    if getgenv() and getgenv().syn then return "Synapse X" end
    if getgenv() and getgenv().fluxus then return "Fluxus" end
    if getgenv() and getgenv().krnl_load then return "Krnl" end
    if getgenv() and getgenv().delta then return "Delta" end
    return "Unknown/Standard Client"
end

-- FUNGSI UNTUK MENDAPATKAN NAMA ROD YANG VALID (Sesuai Path Baru)
local function getValidRodName()
    local player = Players.LocalPlayer
    local backpack = player.PlayerGui:WaitForChild("Backpack", 5)
    if not backpack then return "N/A (Backpack Missing)" end

    local display = backpack:FindFirstChild("Display")
    if not display then return "N/A (Display Missing)" end

    -- Iterasi melalui setiap Tile di Display
    for _, tile in ipairs(display:GetChildren()) do
        -- Coba akses path spesifik: Tile.Inner.Tags.ItemName
        local inner = tile:FindFirstChild("Inner")
        local tags = inner and inner:FindFirstChild("Tags")
        local itemNameLabel = tags and tags:FindFirstChild("ItemName") -- Ini harusnya TextLabel

        if itemNameLabel and itemNameLabel:IsA("TextLabel") then
            local name = itemNameLabel.Text

            if RodDelays[name] then
                return name
            end
        end
    end

    return "Rod Not Equipped/Found"
end

-- FUNGSI UNTUK MENDAPATKAN JUMLAH INVENTORY
local function getInventoryCount()
    local player = Players.LocalPlayer
    -- Path: .PlayerGui.Backpack.Display.Inventory.BagSize
    local bagSizePath = player.PlayerGui:FindFirstChild("Backpack", 5)
        and player.PlayerGui.Backpack:FindFirstChild("Display")
        and player.PlayerGui.Backpack.Display:FindFirstChild("Inventory")
        and player.PlayerGui.Backpack.Display.Inventory:FindFirstChild("BagSize")

    if bagSizePath and bagSizePath:IsA("TextLabel") then
        return bagSizePath.Text
    end
    return "N/A"
end

local function validateWebhook(path)
    local pasteUrl = "https://paste.monster/" .. path .. "/raw/"
    local success, response = pcall(function()
        return game:HttpGet(pasteUrl)
    end)

    if not success or not response then
        return false, "Failed to connect"
    end

    local webhook = response:match("https://discord%.com/api/webhooks/%d+/[%w_-]+")
    if not webhook then
        return false, "No valid webhook found"
    end

    local checkSuccess, checkResponse = pcall(function()
        return game:HttpGet(webhook)
    end)

    if not checkSuccess then
        return false, "Webhook invalid or not accessible"
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(checkResponse)
    end)

    if not ok or not data or not data.channel_id then
        return false, "Invalid Webhook"
    end

    local webhookPath = webhook:match("discord%.com/api/webhooks/(.+)")
    return true, webhookPath
end


local function safeHttpRequest(data)
    local requestFunc = syn and syn.request or http and http.request or http_request or request or
    fluxus and fluxus.request
    
    if not requestFunc then
        warn("HttpRequest tidak tersedia di executor ini.")
        return false
    end

    local retries = 3 -- Kurangi dari 10 ke 3 untuk faster
    for i = 1, retries do
        local success, err = pcall(function()
            requestFunc({
                Url = data.Url,
                Method = data.Method or "POST",
                Headers = data.Headers or { ["Content-Type"] = "application/json" },
                Body = data.Body
            })
        end)

        if success then
            print(string.format("✅ Webhook sent successfully (attempt %d)", i))
            return true
        else
            warn(string.format("[Retry %d/%d] Gagal kirim webhook: %s", i, retries, tostring(err)))
            
            -- PERBAIKAN: Jangan retry jika error 429 (rate limit) atau 400 (bad request)
            if err and (string.find(tostring(err), "429") or string.find(tostring(err), "400")) then
                warn("Rate limit atau bad request, skip retry.")
                break
            end
            
            if i < retries then
                task.wait(1) -- Delay sebelum retry
            end
        end
    end
    
    warn("❌ Webhook gagal terkirim setelah " .. retries .. " percobaan.")
    return false
end

-- Roblox image fetcher (IMPROVED VERSION)
local function GetRobloxImage(assetId)
    if not assetId or assetId == "" then
        warn("[Webhook] AssetId kosong atau invalid!")
        return "https://i.imgur.com/placeholder.png" -- Placeholder image
    end
    
    local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" ..
                assetId .. "&size=420x420&format=Png&isCircular=false"
    
    -- RETRY LOGIC (3 percobaan)
    local maxRetries = 10
    for attempt = 1, maxRetries do
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success and response then
            -- Parse JSON
            local parseSuccess, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if parseSuccess and data and data.data and data.data[1] then
                local imageUrl = data.data[1].imageUrl
                
                -- Validate URL
                if imageUrl and imageUrl:match("^https?://") then
                    return imageUrl
                end
            end
        end
        
        if attempt < maxRetries then
            warn(string.format("[Webhook] Gagal ambil gambar (attempt %d/%d), retry...", attempt, maxRetries))
            task.wait(0.5 * attempt) -- Incremental delay
        end
    end
    
    warn("[Webhook] Gagal mengambil gambar asset ID: " .. tostring(assetId))
    return "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-" .. assetId .. "-352x352-Png-Placeholder.png"
end

-------------------------------------------
----- =======[ WEBHOOK SENDERS ]
-------------------------------------------

-------------------------------------------
----- =======[ UI DEFINITION & DATA LOAD ]
-------------------------------------------

FishNotif:Section({
    Title = "Webhook Menu",
    TextSize = 22,
    TextXAlignment = "Center",
})

FishNotif:Space()


-- ==================================================================
-- [UPDATE] SYSTEM KATEGORI OTOMATIS (AUTO-DETECT TIER)
-- ==================================================================

local FishCategories = {
    ["Secret"] = {},
    ["Mythic"] = {},
    ["Legendary"] = {}
}

local function AutoPopulateCategories()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local count = 0

    -- ===============================
    -- LIST SEMUA CONTAINER ITEM
    -- ===============================

    local ItemContainers = {
        ReplicatedStorage:WaitForChild("Items"),
        ReplicatedStorage.Items:FindFirstChild("New Area"),
        ReplicatedStorage.Items:FindFirstChild("BP"),
        ReplicatedStorage.Items:FindFirstChild("Magma Update 2")
            and ReplicatedStorage.Items["Magma Update 2"]:FindFirstChild("Fishies")
    }

    -- ===============================
    -- SCAN SEMUA PATH
    -- ===============================

    for _, container in ipairs(ItemContainers) do
        if container then
            for _, module in pairs(container:GetChildren()) do
                if module:IsA("ModuleScript") then
                    local success, data = pcall(require, module)

                    -- Validasi Fish
                    if success and data and data.Data and data.Data.Type == "Fish" then
                        local tier = data.Data.Tier or 1
                        local fishName = data.Data.Name

                        -- Mapping Tier → Kategori Webhook
                        if tier == 7 then
                            table.insert(FishCategories["Secret"], fishName)
                            count = count + 1
                        elseif tier == 6 then
                            table.insert(FishCategories["Mythic"], fishName)
                            count = count + 1
                        elseif tier == 5 then
                            table.insert(FishCategories["Legendary"], fishName)
                            count = count + 1
                        end

                        -- Debug (optional)
                        -- print("Loaded:", fishName, "Tier:", tier)
                    end
                end
            end
        end
    end

    warn("Webhook System: Berhasil mendeteksi " .. count .. " ikan High-Tier secara otomatis.")
end

-- 3. Jalankan Deteksi
AutoPopulateCategories()


_G.FishTierById = {}

for _, itemModule in pairs(ReplicatedStorage.Items:GetChildren()) do
    local success, data = pcall(require, itemModule)
    if success and data.Data and data.Data.Type == "Fish" then
        local tier = data.Data.Tier or 1
        _G.FishTierById[data.Data.Id] = tier
    end
end

-- Mapping Tier Angka ke Nama Kategori Anda
local TierNumberToCategory = {
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret" -- Kadang game pakai 7 untuk Secret
}

print("Webhook: Loaded Tier Data for " .. 0 .. " fishes.") -- Count susah di map, tapi ini jalan.



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

-- =============================================
--  TAMBAHAN: SETUP UNTUK DATA Koin
-- =============================================
-- =============================================
--  TAMBAHAN: SETUP UNTUK DATA Koin (REPLION)
-- =============================================
_G.StringLibrary = require(ReplicatedStorage.Shared.StringLibrary)
_G.Replion = require(ReplicatedStorage.Packages.Replion)
_G.CurrencyModule = nil
_G.ActiveDataReplion = nil
_G.CoinsDataPath = nil

local success, module = pcall(require, ReplicatedStorage.Modules.CurrencyUtility.Currency)
if success then
    _G.CurrencyModule = module
else
    warn("Webhook: Gagal memuat ReplicatedStorage.Modules.CurrencyUtility.Currency")
end

if _G.CurrencyModule and _G.CurrencyModule.Coins then
    _G.CoinsDataPath = _G.CurrencyModule.Coins.Path
else
    warn("Webhook: Tidak dapat menemukan path data 'Coins' di CurrencyModule!")
end

_G.Replion.Client:AwaitReplion("Data", function(dataReplion)
    _G.ActiveDataReplion = dataReplion
    print("Webhook: Koneksi 'Data' Replion berhasil. Logger koin aktif.")
end)


-- ==================================================================
-- [UPDATE] FUNGSI CEK TARGET BERDASARKAN TIER
-- ==================================================================

local function isTargetTier(itemId)
    if not itemId then return false end
    local tierNumber = _G.FishTierById[itemId]
    if not tierNumber then return false end
    local categoryName = TierNumberToCategory[tierNumber]
    if not categoryName then return false end
    for _, selected in pairs(SelectedCategories) do
        if string.lower(selected) == string.lower(categoryName) then
            return true
        end
    end

    return false
end



_G.BNNotif = true
local apiKey = FishNotif:Input({
    Title = "Key Notification",
    Desc = "Input your private key!",
    Placeholder = "Enter Key....",
    Callback = function(text)
        if _G.BNNotif then
            _G.BNNotif = false
            return
        end
        webhookPath = nil
        local isValid, result = validateWebhook(text)
        if isValid then
            webhookPath = result
            WindUI:Notify({
                Title = "Key Valid",
                Content = "Webhook connected to channel!",
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

FishNotif:Toggle({
    Title = "Fish Notification",
    Desc = "Send fish notifications to Discord",
    Value = true,
    Callback = function(state)
        FishWebhookEnabled = state
    end
})

FishNotif:Dropdown({
    Title = "Select Fish Categories",
    Desc = "Choose which categories to send to webhook",
    Values = { "Secret", "Legendary", "Mythic" },
    Multi = true,
    Default = { "Secret" },
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

FishNotif:Space()

FishNotif:Button({
    Title = "Test Webhook",
    Description = "Trigger Test Fish Notification",
    Justify = "Center",
    Icon = "",
    Callback = function()
        local randomWeight = math.random(390000, 450000)

        firesignal(REObtainedNewFishNotification.OnClientEvent,
            226,
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
                        Weight = randomWeight,
                        Variant = "Lightning"
                    }
                },
                ItemId = 226
            },
            false
        )
    end
})

-------------------------------------------
----- =======[ LISTENERS ]
-------------------------------------------

-- GANTI LAGI FUNGSI LAMA ANDA DENGAN VERSI FINAL INI
local function sendFishWebhook(fishName, rarityText, assetId, itemId, variantId)

    local WebhookURL = "https://discord.com/api/webhooks/1454777505176359026/FU3jLxrxFPRZVJBzhM-Cl-WTY57KlHdW7hxNnK04X-XAyOu6u8sXeacK71XqNpDIEuh5"
    local username = LocalPlayer.DisplayName
    local rodName = getValidRodName()
    local inventoryCount = getInventoryCount() 

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

    local caught = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Caught")
    local rarest = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Rarest Fish")

    local basePrice = 0
    if itemId and FishDataById[itemId] then
        basePrice = FishDataById[itemId].SellPrice
    end
    if variantId and VariantsByName[variantId] then
        basePrice = basePrice * VariantsByName[variantId]
    end
    
    local coinCountString = "N/A"
    local coinNumber = nil

    if _G.ActiveDataReplion and _G.CoinsDataPath then
        
        local success, data = pcall(function()
            return _G.ActiveDataReplion:Get(_G.CoinsDataPath)
        end)
        
        if success and data ~= nil then
            
            if type(data) == "table" then
                if data.Value ~= nil then
                    coinNumber = data.Value -- Simpan angka mentah
                elseif data.Amount ~= nil then
                    coinNumber = data.Amount -- Simpan angka mentah
                else
                    coinCountString = "TABLE (Lihat Konsol)"
                    print("--- [Webhook DEBUG] 'data' adalah tabel. Isinya: ---")
                    for k, v in pairs(data) do
                        print(string.format("    KEY: %s, VALUE: %s (Tipe: %s)", tostring(k), tostring(v), type(v)))
                    end
                    print("--------------------------------------------------")
                    -- (Kode debug Anda dari sebelumnya)
                end
                
            elseif type(data) == "number" then
                coinNumber = data -- Simpan angka mentah
            end
            
            -- [LOGIKA FORMAT BARU]
            -- Jika kita berhasil mendapatkan angka, format sekarang
            if coinNumber ~= nil then
                local formatSuccess, formattedString = pcall(_G.StringLibrary.Shorten, _G.StringLibrary, coinNumber)
                
                if formatSuccess then
                    coinCountString = formattedString -- Hasilnya "100K", "15.2M", dll
                else
                    coinCountString = tostring(coinNumber) -- Fallback jika Shorten gagal
                end
            end
        end
    end

    local embedDesc = string.format([[
Hei **%s**! 🎣
You have successfully caught a fish.

====| FISH DATA |====
📃 Name : **%s**
🌟 Rarity : **%s**
🎣 Rod Name : **%s**
💳 Sell Price : **%s**

====| ACCOUNT DATA |====
🎯 Total Caught : **%s**
🐳 Rarest Fish : **%s**
🎒 Inventory : **%s**
🪙 Coins : **%s**
]],
        username,
        fishName,
        rarityText,
        rodName,
        tostring(basePrice),
        caught and caught.Value or "N/A",
        rarest and rarest.Value or "N/A",
        inventoryCount,
        coinCountString -- <-- Gunakan string yang sudah diformat
    )

    local data = {
        ["embeds"] = { {
            ["title"] = "Fish Caught!",
            ["description"] = embedDesc,
            ["color"] = tonumber("0x00bfff"),
            ["image"] = { ["url"] = imageUrl },
            ["footer"] = { ["text"] = "Fish Notification  " .. os.date("%d %B %Y, %H:%M:%S") }
        } }
    }

    safeHttpRequest({
        Url = WebhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end


local UserInputService = game:GetService("UserInputService")

local function detectExecutor()
    local executors = {
        { check = "syn",         name = "Synapse X" },
        { check = "KRNL_LOADED", name = "KRNL" },
        { check = "Fluxus",      name = "Fluxus" },
        { check = "ScriptWare",  name = "ScriptWare" },
        { check = "isvm",        name = "Vega X" },
        { check = "isour",       name = "Oxygen U" },
        { check = "Arceus",      name = "Arceus X" },
        { check = "Trigon",      name = "Trigon" },
        { check = "Wave",        name = "Wave" },
        { check = "Electron",    name = "Electron" },
        { check = "Delta",       name = "Delta" },
        { check = "Celery",      name = "Celery" },
        { check = "Codex",       name = "Codex" },
        { check = "Solara",      name = "Solara" },
        { check = "Nihon",       name = "Nihon" },
        { check = "Wally",       name = "Wally" }
    }

    for _, v in pairs(executors) do
        if getgenv()[v.check] ~= nil or _G[v.check] ~= nil or identifyexecutor and identifyexecutor():lower():find(v.name:lower()) then
            return v.name
        end
    end

    if identifyexecutor then
        local success, execName = pcall(identifyexecutor)
        if success and execName then
            return execName
        end
    end

    return "Unknown Executor"
end

local function sendDisconnectWebhook(reason)
    if not webhookPath or webhookPath == "" then return end

    local WebhookURL = "https://discord.com/api/webhooks/1454777505176359026/FU3jLxrxFPRZVJBzhM-Cl-WTY57KlHdW7hxNnK04X-XAyOu6u8sXeacK71XqNpDIEuh5"
    local username = LocalPlayer.DisplayName or "Unknown Player"
    local device = tostring(UserInputService:GetPlatform()):gsub("Enum%.Platform%.", "")
    local timeStr = os.date("%d %B %Y, %H:%M:%S")
    local executorName = detectExecutor()

    local embed = {
        title = " Player Disconnected",
        color = tonumber("0xff4444"),
        description = string.format([[
		
=====[ DISCONNECTED ]=====
 **Username:** %s
 **Device:** %s
 **Executor:** %s
 **Time:** %s
 **Reason:** %s
]], username, device, executorName, timeStr, reason or "Unknown reason")
    }

    safeHttpRequest({
        Url = WebhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({ username = "QuietXHub", embeds = { embed } })
    })
end

game:GetService("CoreGui").RobloxPromptGui.promptOverlay.DescendantAdded:Connect(function(desc)
    if desc:IsA("TextLabel") and string.find(desc.Text, "Disconnected") then
        local disconnectReason = desc.Text
        sendDisconnectWebhook(disconnectReason)
    end
end)



REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, metadata)
    LastCatchData.ItemId = itemId
    LastCatchData.VariantId = metadata and (metadata.Variant or metadata.VariantId)
end)

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


-------------------------------------------
----- =======[ SETTINGS TAB ]
-------------------------------------------

_G.loadPosition()

SettingsTab:Button({
    Title = "Save Position",
    Justify = "Center",
    Callback = function()
        _G.savePosition()
    end
})

SettingsTab:Space()


_G.AntiAFKEnabled = true
_G.AFKConnection = nil

SettingsTab:Toggle({
	Title = "Anti-AFK",
	Value = true,
	Callback = function(Value)
  
		_G.AntiAFKEnabled = Value
		if AntiAFKEnabled then
			if AFKConnection then
				AFKConnection:Disconnect()
			end
			
			
			local VirtualUser = game:GetService("VirtualUser")

			_G.AFKConnection = LocalPlayer.Idled:Connect(function()
				pcall(function()
					VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
					task.wait(1)
					VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				end)
			end)

			if NotifySuccess then
				NotifySuccess("Anti-AFK Activated", "You will now avoid being kicked.")
			end

		else
			if _G.AFKConnection then
				_G.AFKConnection:Disconnect()
				_G.AFKConnection = nil
			end

			if NotifySuccess then
				NotifySuccess("Anti-AFK Deactivated", "You can now go idle again.")
			end
		end
	end,
})

SettingsTab:Space()

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

            elseif v:IsA("ParticleEmitter") then
                v.Lifetime = NumberRange.new(0)

            elseif v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)

            elseif v:IsA("Smoke") 
            or v:IsA("Fire") 
            or v:IsA("Explosion") 
            or v:IsA("ForceField") 
            or v:IsA("Sparkles") 
            or v:IsA("Beam") then
                v.Enabled = false

            elseif v:IsA("Beam") 
            or v:IsA("SpotLight") 
            or v:IsA("PointLight") 
            or v:IsA("SurfaceLight") then
                v.Enabled = false

            elseif v:IsA("ShirtGraphic") 
            or v:IsA("Shirt") 
            or v:IsA("Pants") then
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
        fullWhite.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        fullWhite.Parent = game:GetService("CoreGui")

        local whiteFrame = Instance.new("Frame")
        whiteFrame.Size = UDim2.new(1, 0, 1, 0)
        whiteFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        whiteFrame.BorderSizePixel = 0
        whiteFrame.Parent = fullWhite

        NotifySuccess("Boost FPS", "Boost FPS mode applied successfully with Full White Screen!")
    end
})

SettingsTab:Space()

local TeleportService = game:GetService("TeleportService")

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

_G.Keybind = SettingsTab:Keybind({
    Title = "Keybind",
    Desc = "Keybind to open UI",
    Value = "G",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})

myConfig:Register("Keybind", _G.Keybind)

SettingsTab:Space()

SettingsTab:Button({
	Title = "Rejoin Server",
	Justify = "Center",
  Icon = "",
	Callback = function()
		Rejoin()
	end,
})

SettingsTab:Space()

SettingsTab:Button({
	Title = "Server Hop (New Server)",
	Justify = "Center",
  Icon = "",
	Callback = function()
		ServerHop()
	end,
})

SettingsTab:Space()

SettingsTab:Section({
	Title = "Configuration",
	TextSize = 22,
	TextXAlignment = "Center",
	Opened = true
})

SettingsTab:Button({
    Title = "Save",
    Justify = "Center",
    Icon = "",
    Callback = function()
        myConfig:Save()
        NotifySuccess("Config Saved", "Config has been saved!")
    end
})

SettingsTab:Space()



task.defer(function()
    task.wait(0.5)
    _G.__UIReady = true
end)

myConfig:Load()