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
local Net = require(ReplicatedStorage.Packages.Net)
local VirtualUser = game:GetService("VirtualUser")
local rodRemote = Net:RemoteFunction("ChargeFishingRod")
local miniGameRemote = Net:RemoteFunction("RequestFishingMinigameStarted")
local finishRemote = Net:RemoteFunction("CatchFishCompleted")
local Constants = require(ReplicatedStorage:WaitForChild("Shared", 20):WaitForChild("Constants"))
local UserInputService = game:GetService("UserInputService")
_G.Characters = workspace:FindFirstChild("Characters"):WaitForChild(LocalPlayer.Name)
_G.HRP = _G.Characters:WaitForChild("HumanoidRootPart")
_G.Overhead = _G.HRP:WaitForChild("Overhead")
_G.Header = _G.Overhead:WaitForChild("Content"):WaitForChild("Header")
_G.LevelLabel = _G.Overhead:WaitForChild("LevelContainer"):WaitForChild("Label")
local Player = Players.LocalPlayer
_G.XPBar = Player:WaitForChild("PlayerGui"):WaitForChild("XP")
_G.XPLevel = _G.XPBar:WaitForChild("Frame"):WaitForChild("LevelCount")
_G.Title = _G.Overhead:WaitForChild("TitleContainer"):WaitForChild("Label")
_G.TitleEnabled = _G.Overhead:WaitForChild("TitleContainer")
_G.DisplayNotif = game:GetService("Players").LocalPlayer.PlayerGui["Small Notification"].Display

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
    if _G.XPBar then
        _G.XPBar.Enabled = true
    end
end)

_G.TeleportService = game:GetService("TeleportService")
_G.PlaceId = game.PlaceId

local function AutoReconnect()
    while task.wait(5) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            _G.TeleportService:Teleport(_G.PlaceId)
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
-----------------------------------------------------
-- SERVICES
-----------------------------------------------------

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
    Name = "QuietOcean",
    Accent = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#2DD4FF"), Transparency = 0 }, -- Aqua Accent
        ["100"] = { Color = Color3.fromHex("#0A2E47"), Transparency = 0 }, -- Abyss Glow
    }, {
        Rotation = 35,
    }),

    Dialog = Color3.fromHex("#031624"),        -- Deep Ocean
    Outline = Color3.fromHex("#0F3F56"),       -- Dark Cyan Edge
    Text = Color3.fromHex("#E9F7FF"),          -- Soft White
    Placeholder = Color3.fromHex("#5C7C91"),   -- Subtle Grey-Blue
    Background = Color3.fromHex("#021019"),    -- Darker Ocean Depth
    Button = Color3.fromHex("#08304A"),        -- Calm Navy Blue
    Icon = Color3.fromHex("#2DD4FF")           -- Aqua Highlight
})

_G.THEME_RAW_URL = "https://pastebin.com/raw/KfJ0jGmL"

function LoadThemesFromRaw(url)
    local success, themes = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not success or type(themes) ~= "table" then
        warn("[Theme] Failed to load raw themes")
        return {}
    end

    for _, theme in ipairs(themes) do
        local data = { Name = theme.Name }

        for k, v in pairs(theme) do
            if k ~= "Name" then
                if k == "Accent" and type(v) == "table" and v.Type == "Gradient" then
                    local grad = {}
                    for pos, info in pairs(v.Data) do
                        grad[pos] = {
                            Color = Color3.fromHex(info.Color),
                            Transparency = info.Transparency
                        }
                    end

                    data.Accent = WindUI:Gradient(grad, {
                        Rotation = v.Rotation or 0
                    })
                elseif type(v) == "string" and v:sub(1,1) == "#" then
                    data[k] = Color3.fromHex(v)
                end
            end
        end

        WindUI:AddTheme(data)
    end

    return themes
end

_G.RawThemes = LoadThemesFromRaw(_G.THEME_RAW_URL)

WindUI.TransparencyValue = 0.15

local Window = WindUI:CreateWindow({
    Title = "Fish It",
    Icon = "https://i.ibb.co.com/1f7VL9vB/20251225-155001.png",
    IconSize = 18*2,
    Size = UDim2.fromOffset(580, 460),
    Author = "by OmBerry",
    Folder = "OmBerry",
    Transparent = true,
    Theme = "QuietOcean",
    ToggleKey = Enum.KeyCode.G,
    KeySystem = false,
    ScrollBarEnabled = true,
    HideSearchBar = false,
    NewElements = true,
    User = {
        Enabled = true,
        Anonymous = false
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default", -- Default or Mac
    },
})

Window:EditOpenButton({
    Title = "OmBerry",
    Icon = "https://i.ibb.co.com/1f7VL9vB/20251225-155001.png",
    IconSize = 18*2,
    CornerRadius = UDim.new(0, 28),
    StrokeThickness = 0.5,
    Color = ColorSequence.new(
        Color3.fromHex("#2DD4FF"),
        Color3.fromHex("#0A2E47")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

Window:Tag({
    Title = "PREMIUM",
    Color = Color3.fromHex("#F6D87B") -- Gold Pearl
})

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("QuietXConfig")


WindUI:Notify({
    Title = "OmBerry",
    Content = "All Features Loaded!",
    Duration = 5,
    Image = "square-check-big"
})


-------------------------------------------
----- =======[ ALL TAB ]
-------------------------------------------

Window:Divider()

_G.AccConfig = Window:Tab({
    Title = "Account Settings",
    Icon = "solar:user-rounded-bold"
})

_G.Pirate = Window:Tab({
    Title = "New Pirate Island",
    Icon = "anchor"
})

Window:Divider()

local AllMenu = Window:Section({
    Title = "All Menu Here",
    Icon = "solar:list-down-outline",
    Opened = false,
})

Window:Divider()

local AutoFish = AllMenu:Tab({
    Title = "Menu Fishing",
    Icon = "shrimp"
})

local AutoFarmTab = AllMenu:Tab({
    Title = "Menu Farming",
    Icon = "ghost"
})


local AutoFav = AllMenu:Tab({
    Title = "Menu Favorite",
    Icon = "star"
})

local Trade = AllMenu:Tab({
    Title = "Menu Trade",
    Icon = "chart-candlestick"
})

local Player = AllMenu:Tab({
    Title = "Menu Player",
    Icon = "user-cog"
})

local Utils = AllMenu:Tab({
    Title = "Menu Utility",
    Icon = "wrench"
})

local FishNotif = AllMenu:Tab({
    Title = "Fish Notification",
    Icon = "bell-ring"
})

local SettingsTab = AllMenu:Tab({
    Title = "Settings",
    Icon = "cog"
})

------------------------------------------

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


if getgenv().AutoRejoinConnection then
    getgenv().AutoRejoinConnection:Disconnect()
    getgenv().AutoRejoinConnection = nil
end

getgenv().AutoRejoinConnection = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(
    child)
    task.wait()
    if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") and child.MessageArea:FindFirstChild("ErrorFrame") then
        local TeleportService = game:GetService("TeleportService")
        local Player = game.Players.LocalPlayer
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, Player)
    end
end)

-- ======================================================
-- FPS & PING HUD (FINAL CLEAN COMPACT VERSION)
-- ======================================================

local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

_G.FPSPingEnabled = false
_G.__FPSPingLoop = nil
_G.__FPSPingGui = nil
_G.__FPSLabel = nil
_G.__PingLabel = nil

-- ======================================================
-- CREATE HUD
-- ======================================================

local function createFPSPingHUD()
    if _G.__FPSPingGui then return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FPSPingHUD"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = CoreGui

    -- ================= PANEL =================

    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.fromOffset(200, 78)
    Panel.Position = UDim2.fromScale(0.02, 0.45)
    Panel.BackgroundTransparency = 1
    Panel.Parent = ScreenGui

    -- ================= BACKGROUND =================

    local Background = Instance.new("Frame")
    Background.Size = UDim2.fromScale(1, 1)
    Background.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
    Background.BackgroundTransparency = 0.18
    Background.BorderSizePixel = 0
    Background.Parent = Panel

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Background

    -- ================= CONTENT =================

    local Content = Instance.new("Frame")
    Content.Size = UDim2.fromScale(1, 1)
    Content.BackgroundTransparency = 1
    Content.Parent = Background

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.PaddingRight = UDim.new(0, 12)
    Padding.PaddingTop = UDim.new(0, 8)
    Padding.PaddingBottom = UDim.new(0, 8)
    Padding.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 4)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Layout.Parent = Content

    -- ================= TITLE =================

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 14)
    Title.BackgroundTransparency = 1
    Title.Text = "PERFORMANCE"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 11
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = Color3.fromRGB(170, 190, 210)
    Title.Parent = Content

    -- ================= VALUE LABELS =================

    local function makeValueLabel(defaultText)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = 15
        lbl.Text = defaultText
        lbl.TextColor3 = Color3.fromRGB(235, 245, 255)
        lbl.TextStrokeTransparency = 0.85
        lbl.Parent = Content
        return lbl
    end

    _G.__FPSLabel = makeValueLabel("FPS: --")
    _G.__PingLabel = makeValueLabel("Ping: -- ms")

    -- ================= FADE IN =================

    Background.BackgroundTransparency = 1
    task.spawn(function()
        for i = 1, 10 do
            Background.BackgroundTransparency = 1 - (i * 0.08)
            task.wait(0.015)
        end
    end)

    _G.__FPSPingGui = ScreenGui
end

-- ======================================================
-- LOOP
-- ======================================================

local function startFPSPingLoop()
    if _G.__FPSPingLoop then return end
    createFPSPingHUD()

    _G.__FPSPingLoop = task.spawn(function()
        local frames = 0
        local last = tick()

        while _G.FPSPingEnabled do
            RunService.RenderStepped:Wait()
            frames = frames + 1

            if tick() - last >= 1 then
                local fps = frames
                frames = 0
                last = tick()

                local ping = math.floor(
                    Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                )

                if _G.__FPSLabel then
                    _G.__FPSLabel.Text = "FPS: " .. fps
                end
                if _G.__PingLabel then
                    _G.__PingLabel.Text = "Ping: " .. ping .. " ms"
                end
            end
        end
    end)
end

local function stopFPSPingLoop()
    if _G.__FPSPingLoop then
        task.cancel(_G.__FPSPingLoop)
        _G.__FPSPingLoop = nil
    end
    if _G.__FPSPingGui then
        _G.__FPSPingGui:Destroy()
        _G.__FPSPingGui = nil
    end
end

-- ======================================================
-- TOGGLE
-- ======================================================

_G.AccConfig:Toggle({
    Title = "FPS & Ping Counter",
    Desc = "Compact realtime FPS & Ping HUD",
    Value = false,
    Callback = function(state)
        _G.FPSPingEnabled = state
        if state then
            startFPSPingLoop()
        else
            stopFPSPingLoop()
        end
    end
})

_G.AccConfig:Space()

function _G.getHeader()
    local Character = workspace:WaitForChild("Characters"):FindFirstChild(LocalPlayer.Name)
    if not Character then return nil end

    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return nil end

    local Overhead = HRP:FindFirstChild("Overhead")
    if not Overhead then return nil end

    local Header = Overhead:FindFirstChild("Content") and Overhead.Content:FindFirstChild("Header")
    return Header
end

_G.AccConfig:Colorpicker({
    Title = "Color Name",
    Default = _G.getHeader().TextColor3,
    Callback = function(color)
        local Header = _G.getHeader()
        if Header and Header:IsA("TextLabel") then
            Header.TextColor3 = color
        else
            warn("[Overhead] Header tidak ditemukan untuk LocalPlayer.")
        end
    end
})

_G.AccConfig:Input({
    Title = "Display Name",
    Placeholder = "Display Name...",
    Callback = function(input)
        if _G.Header and typeof(input) == "string" and input ~= "" then
            _G.Header.Text = input
        end
    end
})

_G.AccConfig:Input({
    Title = "Level",
    Placeholder = "Level.",
    Callback = function(input)
        local num = tonumber(input)
        if _G.LevelLabel and num then
            _G.LevelLabel.Text = "Lvl: " .. num
            _G.XPLevel.Text = "Lvl " .. num
        end
    end
})

function _G.HideIdentity(enabled)
    if enabled then
        _G.Header.Visible = false
        _G.LevelLabel.Visible = false
        _G.TitleEnabled.Visible = false
    else
        _G.Header.Visible = true
        _G.LevelLabel.Visible = true
        _G.TitleEnabled.Visible = true
    end
end

_G.AccConfig:Toggle({
    Title = "Hide Identity",
    Value = false,
    Callback = function(state)
        _G.HideIdentity(state)
    end
})

_G.AccConfig:Space()

_G.AccConfig:Divider()

_G.AccConfig:Section({
    Title = "Menu Gifting",
    TextSize = 22,
    TextXAlignment = "Center",
})

_G.AccConfig:Divider()

_G.GiftingController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("GiftingController"))

_G.LastGiftSkin = nil

_G.AccConfig:Input({
    Title = "Custom Gift Skin",
    Placeholder = "Enter skin name...",
    Callback = _G.ProtectCallback(function(inputText)
        if inputText and inputText ~= "" then
            _G.LastGiftSkin = inputText
            NotifyInfo("Gift Menu", ("Skin '%s' is ready to gift. Press the Gift button to open!"):format(inputText))
        else
            _G.LastGiftSkin = nil
            NotifyWarning("Gift Menu", "Skin name cannot be empty!")
        end
    end)
})

_G.AccConfig:Space()

_G.AccConfig:Button({
    Title = "Gift",
    Justify = "Center",
    Icon = "",
    Callback = _G.ProtectCallback(function()
        if _G.LastGiftSkin then
            _G.GiftingController:Open(_G.LastGiftSkin)
            NotifySuccess("Gift Menu", ("Gift '%s' opened!"):format(_G.LastGiftSkin))
        else
            NotifyWarning("Gift Menu", "No valid skin to gift. Please enter a skin name first!")
        end
    end)
})

_G.AccConfig:Space()

-------------------------------------------
----- =======[ PIRATE ISSLAND ]
-------------------------------------------

_G.Pirate:Divider()

_G.Pirate:Section({
    Title = "Pirate Island",
    TextSize = 22,
    TextXAlignment = "Center",
})

_G.Pirate:Divider()

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

_G.Pirate:Button({
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

_G.Pirate:Button({
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
_G.rStopSpam = false
_G.spamThread = nil
_G.rspamThread = nil
_G.stopThread = nil
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
_G.AutoFishHighQuality = false
_G.CastTimeoutMode = "Fast"
_G.CastTimeoutValue = 0.01

function RandomFloat()
    return 0.01 + math.random() * 0.99
end

-- [[ KONFIGURASI DELAY ]] --

_G.RemotePackage = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
_G.RemoteFish = Net:RemoteEvent("ObtainedNewFishNotification")
_G.RemoteSell = Net:RemoteFunction("SellAllItems")

_G.RemoteFish.OnClientEvent:Connect(function(_, _, data)
    if _G.sellActive and data then
        _G.fishCounter = _G.fishCounter + 1
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

function InitialCast5X()
    local getPowerFunction = Constants.GetPower
    local perfectThreshold = 0.99
    local chargeStartTime = workspace:GetServerTimeNow()
    rodRemote:InvokeServer(chargeStartTime)
    local calculationLoopStart = tick()

    local timeoutDuration = tonumber(_G.CastTimeoutValue)

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

function _G.StopSpam()
    if _G.rStopSpam then return end
    _G.rStopSpam = true
    _G.spamThread = task.spawn(function()
        for i = 1, 5 do
            task.wait(0.01) 
            _G.StopFishing()
        end
    end)
end


function _G.RecastSpam()
    if _G.rSpamming then return end
    _G.rSpamming = true
    
    _G.rspamThread = task.spawn(function()
        while _G.rSpamming do
            task.wait(0.01) 
            InitialCast5X()
        end
    end)
end

function _G.StopRecastSpam()
    _G.rSpamming = false
    if _G.rspamThread then
        task.cancel(_G.rspamThread) -- Membunuh thread
        _G.rspamThread = nil
    end
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
        _G.StopRecastSpam() -- Menghentikan spam cast (sudah di-fix)
        _G.stopSpam()
    end
end)



local lastEventTime = tick()

task.spawn(function()
    while task.wait(1) do
        if _G.AutoFishHighQuality and FuncAutoFish.autofish5x and FuncAutoFish.REReplicateTextEffect then
            if tick() - lastEventTime > 10 then
                _G.StopSpam()
				task.wait(0.1)
				_G.RecastSpam()
                lastEventTime = tick()
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



_G.REFishCaught.OnClientEvent:Connect(function(fishName, info)
    if FuncAutoFish.autofish5x then
        _G.stopSpam()
        _G.lastFishTime = tick()
        _G.RecastSpam()
    end
end)

task.spawn(function()
	while task.wait(1) do
		if _G.AntiStuckEnabled and FuncAutoFish.autofish5x and not _G.AutoFishHighQuality then
			if tick() - _G.lastFishTime > tonumber(_G.STUCK_TIMEOUT) then
				StopAutoFish5X()
				task.wait(1)
				StartAutoFish5X()
				_G.lastFishTime = tick()
			end
		end
	end
end)


function StartAutoFish5X()
    _G.equipRemote:FireServer(1)
    FuncAutoFish.autofish5x = true
    _G.AntiStuckEnabled = true
    lastEventTime = tick()
    _G.lastFishTime = tick()
    task.wait(0.5)
    InitialCast5X()
end


function StopAutoFish5X()
    FuncAutoFish.autofish5x = false
    _G.AntiStuckEnabled = false
    _G.StopFishing()
    _G.isRecasting5x = false
    _G.StopSpam()
    _G.stopSpam()
    _G.StopRecastSpam()
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

_G.SPEED_LEGIT = 0.5

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

_G.__RodEquipped = false

_G.ForceEquipRod = function()
    pcall(function()
        v6.Events.REEquip:FireServer(1)
    end)
    task.wait(0.25)
end

task.spawn(function()
    local lastState = false

    while true do
        local enabled = _G.BlatantState.enabled

        -- rising edge: OFF -> ON
        if enabled and not lastState then
            _G.__RodEquipped = false

            pcall(function()
                v6.Events.REEquip:FireServer(1)
            end)

            task.delay(0.3, function()
                _G.__RodEquipped = true
            end)
        end

        lastState = enabled
        task.wait(0.1)
    end
end)

_G._CancelCycleRunning = false
_G._CancelFirstRun = true
_G.CycleDelay = 10

_G.StartCancelCycle = function()
    if _G._CancelCycleRunning then return end
    _G._CancelCycleRunning = true
    _G._CancelFirstRun = true

    task.spawn(function()
        while _G.BlatantState.enabled do

            -- === FIRST EXECUTION ===
            if _G._CancelFirstRun then
                task.wait(math.random(1, 100) / 100) -- 1 - 2 detik

                pcall(function()
                    v6.Functions.Cancel:InvokeServer()
                end)

                _G._CancelFirstRun = false

            else
                -- === NEXT CYCLES ===
                task.wait(tonumber(_G.CycleDelay))

                task.wait(math.random(1, 100) / 100) -- 0.1 - 1 detik

                pcall(function()
                    v6.Functions.Cancel:InvokeServer()
                end)
            end
        end

        -- reset saat disabled
        _G._CancelCycleRunning = false
        _G._CancelFirstRun = true
    end)
end

function Fastest()
    task.spawn(function()

        pcall(function()
            firesignal(_G.REFishingStopped.OnClientEvent)
        end)
        
        _G.StartCancelCycle()

        local serverTime = workspace:GetServerTimeNow()

        pcall(function()
            v6.Functions.ChargeRod:InvokeServer(2)
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

AutoFish:Divider()

_G.FishAdvenc = AutoFish:Section({
    Title = "Advanced Settings",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

AutoFish:Divider()

_G.FishSec = AutoFish:Section({
    Title = "Auto Fishing Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

AutoFish:Divider()

_G.BlatantSec = AutoFish:Section({
    Title = "Blatant Fishing",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

AutoFish:Divider()

_G.AnimSec = AutoFish:Section({
    Title = "Animation Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

AutoFish:Divider()

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

_G.BlatantSec:Input({
    Title = "Cycle Delay",
    Value = tostring(_G.CycleDelay),
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then
            _G.CycleDelay = num
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

_G.DelayFinish = _G.FishAdvenc:Input({
    Title = "Delay Finish",
    Desc = [[
High Rod = 1
Medium Rod = 1.5 - 1.7
Low Rod = 2 - 3
]],
    Type = "Input",
    Value = _G.FINISH_DELAY,
    Placeholder = "Input Delay Finish..",
    Callback = function(input)
        fDelays = tonumber(input)
        _G.FINISH_DELAY = fDelays
    end
})

myConfig:Register("DelayFinish", _G.DelayFinish)

_G.SpeedLegit = _G.FishAdvenc:Input({
    Title = "Speed Legit",
    Desc = "Speed Click for Auto Fish Legit",
    Type = "Input",
    Placeholder = "Input Speed..",
    Value = _G.SPEED_LEGIT,
    Callback = function(input)
        DelayLegit = tonumber(input)
        _G.SPEED_LEGIT = DelayLegit
    end
})

myConfig:Register("SpeedLegit", _G.SpeedLegit)

_G.SellThress = _G.FishAdvenc:Input({
    Title = "Sell Threesold",
    Type = "Input",
    Placeholder = "Input Delay Finish..",
    Value = _G.sellThreshold,
    Callback = function(input)
        thresold = tonumber(input)
        _G.sellThreshold = thresold
    end
})

myConfig:Register("SellThresold", _G.SellThress)

_G.StuckDelay = _G.FishAdvenc:Input({
    Title = "Anti Stuck Delay",
    Desc = "Cooldown for anti stuck Auto Fish",
    Type = "Input",
    Value = _G.STUCK_TIMEOUT,
    Placeholder = "Input Delay Finish..",
    Callback = function(input)
        stuck = tonumber(input)
        _G.STUCK_TIMEOUT = stuck
    end
})

myConfig:Register("StuckDelay", _G.StuckDelay)

-- =======================================================
-- == AUTO CUTSCENE REMOVER (TOGGLE + HOOK)
-- =======================================================

_G.CutsceneController = require(ReplicatedStorage.Controllers.CutsceneController)
_G.GuiControl = require(ReplicatedStorage.Modules.GuiControl)
_G.ProximityPromptService = game:GetService("ProximityPromptService")

_G.AutoSkipCutscene = false

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

_G.HideNotif = _G.FishAdvenc:Toggle({
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

myConfig:Register("HideNotification", _G.HideNotif)

_G.FishAdvenc:Toggle({
    Title = "Auto Skip Cutscenes",
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

local REEquipItem = Net:RemoteEvent("EquipItem")
local RFSellItem = Net:RemoteFunction("SellItem")

function ToggleAutoSellMythic(state)
    autoSellMythic = state
    if autoSellMythic then
        NotifySuccess("AutoSellMythic", "Status: ON")
    else
        NotifyWarning("AutoSellMythic", "Status: OFF")
    end
end

local oldFireServer
oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()

    if autoSellMythic
        and method == "FireServer"
        and self == REEquipItem
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

    return oldFireServer(self, ...)
end)


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

_G.FishAdvenc:Button({
    Title = "Sell All Fishes",
    Locked = false,
    Justify = "Center",
    Icon = "",
    Callback = function()
        sellAllFishes()
    end
})

_G.FishSec:Space()

_G.AutoSell = _G.FishSec:Toggle({
    Title = "Auto Sell",
    Callback = function(state)
        _G.sellActive = state
        if state then
            NotifySuccess("Auto Sell", "Limit: " .. _G.sellThreshold)
        else
            NotifySuccess("Auto Sell", "Disabled")
        end
    end
})

myConfig:Register("AutoSell", _G.AutoSell)

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

myConfig:Register("AutoFishing", _G.AutoFishes)

_G.SetCast = _G.FishSec:Dropdown({
    Title = "Cast Mode",
    Desc = "Choose casting speed",
    Values = {"Perfect", "Fast", "Random"},
    Value = "Fast",
    Multi = false,
    Callback = function(selected)
        _G.CastTimeoutMode = selected
        if selected == "Perfect" then
            _G.CastTimeoutValue = 1
        elseif selected == "Random" then
            _G.CastTimeoutValue = RandomFloat()
        elseif selected == "Fast" then
            _G.CastTimeoutValue = 0.01
        end
    end
})

myConfig:Register("SetCast", _G.SetCast)

_G.Perfection = _G.FishSec:Toggle({
    Title = "PERFECTION!",
    Desc = "Need Enchant PERFECTION!\nDo Not Turn On Fish Legit",
    Value = false,
    Callback = function(state)
        local Players = game:GetService("Players") 
        local LocalPlayer = Players.LocalPlayer
        if state then
            LocalPlayer:SetAttribute("Loading", nil)
            Net:RemoteFunction("UpdateAutoFishingState"):InvokeServer(true)

        else
            Net:RemoteFunction("UpdateAutoFishingState"):InvokeServer(false)
            LocalPlayer:SetAttribute("Loading", true)
        end
    end
})

_G.HighFish = _G.FishSec:Toggle({
    Title = "Fish High Quality",
    Desc = "Only Legendary, Mythic, & SECRET",
    Callback = function(state)
        _G.AutoFishHighQuality = state
    end
})

myConfig:Register("FishHigh", _G.HighFish)

_G.FishLegit = _G.FishSec:Toggle({
    Title = "Auto Fish Legit",
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

myConfig:Register("FishLegit", _G.FishLegit)

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

_G.Animate = _G.FishSec:Toggle({
    Title = "Disable Animation",
    Desc = "Disable Rod Animation",
    Value = false,
    Callback = function(state)
        _G.DisableAnimations = state
    end
})

myConfig:Register("AnimationDisable", _G.Animate)


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
        _G.StopRecastSpam()
    end
})

_G.FishSec:Space()

-- =======================================================
-- AUTO ENCHANT (GLOBAL VARIABLE VERSION)
-- =======================================================

_G.EnchantSec = AutoFish:Section({
    Title = "Auto Enchant",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

AutoFish:Divider()

do
    -- Definisi State Global
    _G.autoEnchantState = { 
        enabled = false, 
        targetEnchant = nil, 
        stoneLimit = math.huge, 
        stonesUsed = 0, 
        selectedRodUUID = nil,
        selectedRodName = "",
        selectedStoneName = "Enchant Stone", -- 🔥 DEFAULT
        enchantLoopThread = nil 
    }
    
    -- Variabel UI Global (Disiapkan dulu agar tidak nil)
    _G.enchantStatusParagraph = nil
    _G.enchantStoneCountParagraph = nil
    _G.rodDropdown = nil
    _G.autoEnchantToggle = nil
    _G.targetEnchantDropdown = nil
    _G.stoneLimitInput = nil
    
    _G.altarPosition = Vector3.new(3234, -1300, 1401)
    
    -- Helper: Cari Data Rod berdasarkan UUID (Fresh Data)
    _G.getRodByUUID = function(uuid)
        if not (_G.Replion and _G.ItemUtility) then return nil end
        local DataReplion = _G.Replion.Client:GetReplion("Data")
        if not DataReplion then return nil end
    
        local rods = DataReplion:Get({ "Inventory", "Fishing Rods" })
        if rods then
            for _, rod in ipairs(rods) do
                if rod.UUID == uuid then return rod end
            end
        end
        return nil
    end
    
    -- Populate Dropdown Rod
    _G.populateRodDropdown = function()
        task.spawn(function()
            if not (_G.ItemUtility and _G.Replion) then return end
            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Loading rod list...") end
            
            local DataReplion = _G.Replion.Client:WaitReplion("Data")
            if not DataReplion then return end
    
            local rodList, uuidMap = { "Select a rod..." }, {}
            local rod_inventory = DataReplion:Get({ "Inventory", "Fishing Rods" })
            
            if rod_inventory then
                for i, rodItem in ipairs(rod_inventory) do
                    local itemData = _G.ItemUtility:GetItemData(rodItem.Id)
                    if itemData and itemData.Data then
                        local rodName = itemData.Data.Name or rodItem.Id
                        local enchantName = ""
                        
                        -- Cek metadata enchant saat ini
                        if rodItem.Metadata and rodItem.Metadata.EnchantId then
                            local enchantData = _G.ItemUtility:GetEnchantData(rodItem.Metadata.EnchantId)
                            if enchantData and enchantData.Data.Name then
                                enchantName = " [" .. enchantData.Data.Name .. "]"
                            end
                        end
    
                        local displayName = rodName .. enchantName
                        
                        -- Handle nama duplikat agar dropdown unik
                        local count = 2
                        local originalName = displayName
                        while uuidMap[displayName] do
                            displayName = originalName .. " #" .. count
                            count = count + 1
                        end
                        
                        table.insert(rodList, displayName)
                        uuidMap[displayName] = rodItem.UUID
                    end
                end
            end
            
            -- Simpan mapping di dropdown
            if _G.rodDropdown then
                _G.rodDropdown.UUIDMap = uuidMap
                pcall(_G.rodDropdown.Refresh, _G.rodDropdown, rodList)
            end
            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Rods loaded.") end
        end)
    end
    
    -- Get List Enchantment dari ReplicatedStorage
    _G.getEnchantmentList = function()
        local enchants = {}
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local success, enchantsModule = pcall(require, ReplicatedStorage:WaitForChild("Enchants"))
        if success then
            for name, data in pairs(enchantsModule) do
                if type(data) == "table" and data.Data and data.Data.Name then
                    table.insert(enchants, data.Data.Name)
                end
            end
        end
        table.sort(enchants)
        return enchants
    end
    
    -- === UI ELEMENTS ===
    
    _G.targetEnchantDropdown = _G.EnchantSec:Dropdown({
        Title = "Select Target Enchantment",
        Values = _G.getEnchantmentList(),
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(v) _G.autoEnchantState.targetEnchant = v end
    })
    
    myConfig:Register("TargetEnchant", _G.targetEnchantDropdown)
    
    _G.enchantStoneDropdown = _G.EnchantSec:Dropdown({
        Title = "Select Enchant Stone",
        Values = {
            "Enchant Stone",
            "Evolved Enchant Stone"
        },
        Value = "Enchant Stone",
        Callback = _G.ProtectCallback(function(v)
            _G.autoEnchantState.selectedStoneName = v
            if _G.enchantStatusParagraph then
                _G.enchantStatusParagraph:SetDesc("Using stone: " .. v)
            end
        end)
    })
    
    _G.rodDropdown = _G.EnchantSec:Dropdown({
        Title = "Select Rod to Enchant",
        Values = { "Click Refresh or wait..." },
        AllowNone = true,
        Callback = function(v)
            if _G.rodDropdown.UUIDMap and _G.rodDropdown.UUIDMap[v] then
                _G.autoEnchantState.selectedRodUUID = _G.rodDropdown.UUIDMap[v]
                _G.autoEnchantState.selectedRodName = v
                if _G.enchantStatusParagraph then
                    _G.enchantStatusParagraph:SetDesc("Selected: " .. v)
                end
            end
        end
    })
    -- myConfig:Register("SelectedRodToEnchantQuite", _G.rodDropdown)
    
    _G.EnchantSec:Button({ Title = "Refresh Rod List", Icon = "refresh-cw", Callback = _G.populateRodDropdown })
    
    _G.stoneLimitInput = _G.EnchantSec:Input({
        Title = "Max Enchant Stones to Use",
        Placeholder = "Empty for no limit",
        Type = "Input",
        Callback = function(v) _G.autoEnchantState.stoneLimit = tonumber(v) or math.huge end
    })
    -- myConfig:Register("StoneLimitQuite", _G.stoneLimitInput)
    
    _G.enchantStoneCountParagraph = _G.EnchantSec:Paragraph({ Title = "Stones Owned", Desc = "Loading..." })
    _G.enchantStatusParagraph = _G.EnchantSec:Paragraph({ Title = "Status", Desc = "Idle." })
    
    -- Thread Update Stone Count
    task.spawn(function()
        while task.wait(2) do
            pcall(function()
                if not _G.Replion then return end
                local DataReplion = _G.Replion.Client:GetReplion("Data")
                if not DataReplion then return end
    
                local items = DataReplion:Get({ "Inventory", "Items" })
                local count = 0
                local targetStone = _G.autoEnchantState.selectedStoneName
    
                if items then
                    for _, item in ipairs(items) do
                        local base = _G.ItemUtility:GetItemData(item.Id)
                        if base and base.Data
                            and base.Data.Type == "Enchant Stones"
                            and base.Data.Name == targetStone
                        then
                            count = count + (item.Quantity or 0)
                        end
                    end
                end
    
                if _G.enchantStoneCountParagraph then
                    _G.enchantStoneCountParagraph:SetDesc(
                        string.format("%s: %d", targetStone, count)
                    )
                end
            end)
        end
    end)
    
    _G.autoEnchantToggle = _G.EnchantSec:Toggle({
        Title = "Enable Auto Enchant",
        Value = false,
        Callback = function(value)
            _G.autoEnchantState.enabled = value
    
            if value then
                _G.autoEnchantState.enchantLoopThread = task.spawn(function()
                    if not _G.autoEnchantState.targetEnchant or not _G.autoEnchantState.selectedRodUUID then
                        if _G.enchantStatusParagraph then 
                            _G.enchantStatusParagraph:SetDesc("Error: Select Rod AND Target Enchant!") 
                        end
                        pcall(function() _G.autoEnchantToggle:SetValue(false) end)
                        return
                    end
    
                    -- 1. Teleport ke Altar
                    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - _G.altarPosition).Magnitude > 10 then
                        if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Teleporting to Altar...") end
                        hrp.CFrame = CFrame.new(_G.altarPosition) * CFrame.new(0, 5, 0)
                        task.wait(1.5)
                    end
    
                    _G.autoEnchantState.stonesUsed = 0
                    local DataReplion = _G.Replion.Client:WaitReplion("Data")
                    local EquipItemEvent = Net:RemoteEvent("EquipItem")
                    local EquipToolEvent = Net:RemoteEvent("EquipToolFromHotbar")
                    local UnequipItemEvent = Net:RemoteEvent("UnequipItem")
                    local ActivateAltarEvent = Net:RemoteEvent("ActivateEnchantingAltar")
                    local RollEnchantEvent = Net:RemoteEvent("RollEnchant")
    
                    while _G.autoEnchantState.enabled do
                        -- 2. Ambil Data Terbaru Rod
                        local currentRod = _G.getRodByUUID(_G.autoEnchantState.selectedRodUUID)
                        if not currentRod then
                            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Error: Rod not found in inventory!") end
                            break
                        end
    
                        -- 3. Cari Stone SESUAI PILIHAN
                        local stoneItem = nil
                        local items = DataReplion:Get({ "Inventory", "Items" })
                        local targetStone = _G.autoEnchantState.selectedStoneName
                        
                        for _, item in ipairs(items or {}) do
                            local base = _G.ItemUtility:GetItemData(item.Id)
                            if base and base.Data
                                and base.Data.Type == "Enchant Stones"
                                and base.Data.Name == targetStone
                                and (item.Quantity or 0) > 0
                            then
                                stoneItem = item
                                break
                            end
                        end
    
                        if not stoneItem then
                            if _G.enchantStatusParagraph then
                                _G.enchantStatusParagraph:SetDesc(
                                    "Stopped: Out of " .. targetStone
                                )
                            end
                            break
                        end
    
                        if _G.autoEnchantState.stonesUsed >= _G.autoEnchantState.stoneLimit then
                            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Stopped: Limit reached.") end
                            break
                        end
    
                        _G.autoEnchantState.stonesUsed = _G.autoEnchantState.stonesUsed + 1
                        if _G.enchantStatusParagraph then 
                            _G.enchantStatusParagraph:SetDesc(string.format("Rolling... (Stone #%d)", _G.autoEnchantState.stonesUsed)) 
                        end
    
                        -- 4. Proses Equip & Roll
                        local success, resultEnchantName = pcall(function()
                            -- Equip Rod
                            EquipItemEvent:FireServer(currentRod.UUID, "Fishing Rods")
                            task.wait(0.6)
    
                            -- Equip Stone
                            EquipItemEvent:FireServer(stoneItem.UUID, "Enchant Stones")
                            task.wait(0.6)
    
                            -- Equip Tool
                            EquipToolEvent:FireServer(6) 
                            task.wait(0.8)
    
                            -- Snapshot ID Enchant Lama
                            local oldEnchantId = currentRod.Metadata and currentRod.Metadata.EnchantId or nil
                            local gotResult = false
                            local resultName = "None"
    
                            -- Setup Listener Replion untuk deteksi perubahan
                            local connection
                            connection = DataReplion:OnChange({"Inventory", "Fishing Rods"}, function(newRods)
                                for _, rod in ipairs(newRods) do
                                    if rod.UUID == currentRod.UUID then
                                        local newEnchantId = rod.Metadata and rod.Metadata.EnchantId
                                        -- Jika ID berubah, berarti roll sukses
                                        if newEnchantId ~= oldEnchantId then
                                            if newEnchantId then
                                                local eData = _G.ItemUtility:GetEnchantData(newEnchantId)
                                                resultName = eData and eData.Data.Name or "Unknown"
                                            else
                                                resultName = "None"
                                            end
                                            gotResult = true
                                        end
                                        break
                                    end
                                end
                            end)
    
                            -- Trigger Roll
                            ActivateAltarEvent:FireServer(currentRod.UUID) -- Init
                            task.wait(0.5)
                            RollEnchantEvent:FireServer(currentRod.UUID) -- Confirm Roll
    
                            -- Tunggu hasil (Max 6 detik)
                            local timer = 0
                            while not gotResult and timer < 2 do
                                task.wait(0.7)
                                timer = timer + 0.7
                                if not _G.autoEnchantState.enabled then break end
                            end
    
                            if connection then connection:Disconnect() end
    
                            if not gotResult then
                                error("Timeout waiting for enchant result")
                            end
    
                            return resultName
                        end)
    
                        -- Unequip Tool Safety
                        pcall(function() UnequipItemEvent:FireServer(6) end)
    
                        if success then
                            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Rolled: " .. resultEnchantName) end
                            
                            -- Cek apakah sesuai target
                            if string.lower(resultEnchantName) == string.lower(_G.autoEnchantState.targetEnchant) then
                                if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("SUCCESS! Got " .. resultEnchantName) end
                                NotifySuccess("Auto Enchant", "Successfully got " .. resultEnchantName, 5)
                                _G.autoEnchantState.enabled = false
                                pcall(function() _G.autoEnchantToggle:SetValue(false) end)
                                _G.populateRodDropdown() -- Refresh nama rod
                                break
                            end
                        else
                            warn("Enchant fail/retry: " .. tostring(resultEnchantName))
                            _G.autoEnchantState.stonesUsed = _G.autoEnchantState.stonesUsed - 1 
                            task.wait(0.5)
                        end
    
                        task.wait(0.5) -- Delay aman antar roll agar tidak crash
                    end
    
                    pcall(function() _G.autoEnchantToggle:SetValue(false) end)
                    _G.autoEnchantState.enchantLoopThread = nil
                end)
            end
        end
    })
    task.delay(1, _G.populateRodDropdown)
end

-------------------------------------------
----- =======[ ANIMATION TAB ]
-------------------------------------------


_G.CustomAnimationEnabled = false
_G.SelectedAnimationWeapon = "Holy Trident"

_G.Animations = require(
    game:GetService("ReplicatedStorage").Modules.Animations
)

_G.OriginalGetAnimation = _G.Animations.GetAnimation

_G.AnimationPresets = {
    ["The Vanquisher"] = {
        StartRodCharge   = "The Vanquisher - StartRodCharge",
        RodThrow         = "The Vanquisher - RodThrow",
        ReelStart        = "The Vanquisher - ReelStart",
        ReelingIdle      = "The Vanquisher - ReelingIdle",
        ReelIntermission = "The Vanquisher - ReelIntermission",
        FishCaught       = "The Vanquisher - FishCaught",
        EquipIdle        = "The Vanquisher - EquipIdle",
    },

    ["Soul Scythe"] = {
        StartRodCharge   = "Soul Scythe - StartRodCharge",
        RodThrow         = "Soul Scythe - RodThrow",
        ReelStart        = "Soul Scythe - ReelStart",
        ReelingIdle      = "Soul Scythe - ReelingIdle",
        ReelIntermission = "Soul Scythe - ReelIntermission",
        FishCaught       = "Soul Scythe - FishCaught",
        EquipIdle        = "Soul Scythe - EquipIdle",
    },

    ["Princess Parasol"] = {
        StartRodCharge   = "Princess Parasol - StartRodCharge",
        RodThrow         = "Princess Parasol - RodThrow",
        ReelStart        = "Princess Parasol - ReelStart",
        ReelingIdle      = "Princess Parasol - ReelingIdle",
        ReelIntermission = "Princess Parasol - ReelIntermission",
        FishCaught       = "Princess Parasol - FishCaught",
        EquipIdle        = "Princess Parasol - EquipIdle",
    },

    ["Oceanic Harpoon"] = {
        StartRodCharge   = "Oceanic Harpoon - StartRodCharge",
        RodThrow         = "Oceanic Harpoon - RodThrow",
        ReelStart        = "Oceanic Harpoon - ReelStart",
        ReelingIdle      = "Oceanic Harpoon - ReelingIdle",
        ReelIntermission = "Oceanic Harpoon - ReelIntermission",
        FishCaught       = "Oceanic Harpoon - FishCaught",
        EquipIdle        = "Oceanic Harpoon - EquipIdle",
    },

    ["Holy Trident"] = {
        StartRodCharge   = "Holy Trident - StartRodCharge",
        RodThrow         = "Holy Trident - RodThrow",
        ReelStart        = "Holy Trident - ReelStart",
        ReelingIdle      = "Holy Trident - ReelingIdle",
        ReelIntermission = "Holy Trident - ReelIntermission",
        FishCaught       = "Holy Trident - FishCaught",
        EquipIdle        = "Holy Trident - EquipIdle",
    },

    ["Gingerbread Katana"] = {
        StartRodCharge   = "Gingerbread Katana - StartRodCharge",
        RodThrow         = "Gingerbread Katana - RodThrow",
        ReelStart        = "Gingerbread Katana - ReelStart",
        ReelingIdle      = "Gingerbread Katana - ReelingIdle",
        ReelIntermission = "Gingerbread Katana - ReelIntermission",
        FishCaught       = "Gingerbread Katana - FishCaught",
        EquipIdle        = "Gingerbread Katana - EquipIdle",
    },

    ["Frozen Krampus Scythe"] = {
        StartRodCharge   = "Frozen Krampus Scythe - StartRodCharge",
        RodThrow         = "Frozen Krampus Scythe - RodThrow",
        ReelStart        = "Frozen Krampus Scythe - ReelStart",
        ReelingIdle      = "Frozen Krampus Scythe - ReelingIdle",
        ReelIntermission = "Frozen Krampus Scythe - ReelIntermission",
        FishCaught       = "Frozen Krampus Scythe - FishCaught",
        EquipIdle        = "Frozen Krampus Scythe - EquipIdle",
    },

    ["Eternal Flower"] = {
        StartRodCharge   = "Eternal Flower - StartRodCharge",
        RodThrow         = "Eternal Flower - RodThrow",
        ReelStart        = "Eternal Flower - ReelStart",
        ReelingIdle      = "Eternal Flower - ReelingIdle",
        ReelIntermission = "Eternal Flower - ReelIntermission",
        FishCaught       = "Eternal Flower - FishCaught",
        EquipIdle        = "Eternal Flower - EquipIdle",
    },

    ["Eclipse Katana"] = {
        StartRodCharge   = "Eclipse Katana - StartRodCharge",
        RodThrow         = "Eclipse Katana - RodThrow",
        ReelStart        = "Eclipse Katana - ReelStart",
        ReelingIdle      = "Eclipse Katana - ReelingIdle",
        ReelIntermission = "Eclipse Katana - ReelIntermission",
        FishCaught       = "Eclipse Katana - FishCaught",
        EquipIdle        = "Eclipse Katana - EquipIdle",
    },

    ["Corruption Edge"] = {
        StartRodCharge   = "Corruption Edge - StartRodCharge",
        RodThrow         = "Corruption Edge - RodThrow",
        ReelStart        = "Corruption Edge - ReelStart",
        ReelingIdle      = "Corruption Edge - ReelingIdle",
        ReelIntermission = "Corruption Edge - ReelIntermission",
        FishCaught       = "Corruption Edge - FishCaught",
        EquipIdle        = "Corruption Edge - EquipIdle",
    },

    ["Christmas Parasol"] = {
        StartRodCharge   = "Christmas Parasol - StartRodCharge",
        RodThrow         = "Christmas Parasol - RodThrow",
        ReelStart        = "Christmas Parasol - ReelStart",
        ReelingIdle      = "Christmas Parasol - ReelingIdle",
        ReelIntermission = "Christmas Parasol - ReelIntermission",
        FishCaught       = "Christmas Parasol - FishCaught",
        EquipIdle        = "Christmas Parasol - EquipIdle",
    },

    ["Blackhole Sword"] = {
        StartRodCharge   = "Blackhole Sword - StartRodCharge",
        RodThrow         = "Blackhole Sword - RodThrow",
        ReelStart        = "Blackhole Sword - ReelStart",
        ReelingIdle      = "Blackhole Sword - ReelingIdle",
        ReelIntermission = "Blackhole Sword - ReelIntermission",
        FishCaught       = "Blackhole Sword - FishCaught",
        EquipIdle        = "Blackhole Sword - EquipIdle",
    },

    ["Eternal Flower"] = {
        StartRodCharge   = "Eternal Flower - StartRodCharge",
        RodThrow         = "Eternal Flower - RodThrow",
        ReelStart        = "Eternal Flower - ReelStart",
        ReelingIdle      = "Eternal Flower - ReelingIdle",
        ReelIntermission = "Eternal Flower - ReelIntermission",
        FishCaught       = "Eternal Flower - FishCaught",
        EquipIdle        = "Eternal Flower - EquipIdle",
    },

    ["Binary Edge"] = {
        StartRodCharge   = "Binary Edge - StartRodCharge",
        RodThrow         = "Binary Edge - RodThrow",
        ReelStart        = "Binary Edge - ReelStart",
        ReelingIdle      = "Binary Edge - ReelingIdle",
        ReelIntermission = "Binary Edge - ReelIntermission",
        FishCaught       = "Binary Edge - FishCaught",
        EquipIdle        = "Binary Edge - EquipIdle",
    },

    ["1x1x1x1 Ban Hammer"] = {
        StartRodCharge   = "1x1x1x1 Ban Hammer - StartRodCharge",
        RodThrow         = "1x1x1x1 Ban Hammer - RodThrow",
        ReelStart        = "1x1x1x1 Ban Hammer - ReelStart",
        ReelingIdle      = "1x1x1x1 Ban Hammer - ReelingIdle",
        ReelIntermission = "1x1x1x1 Ban Hammer - ReelIntermission",
        FishCaught       = "1x1x1x1 Ban Hammer - FishCaught",
        EquipIdle        = "1x1x1x1 Ban Hammer - EquipIdle",
    },
}

_G.AnimationBackup = _G.AnimationBackup or {}

for name, anim in pairs(_G.Animations) do
    if typeof(anim) == "Instance" then
        _G.AnimationBackup[name] = anim
    end
end

_G.ApplyAnimationPreset = function()
    -- restore dulu
    for name, anim in pairs(_G.AnimationBackup) do
        _G.Animations[name] = anim
    end

    if not _G.CustomAnimationEnabled then
        return
    end

    local preset = _G.AnimationPresets[_G.SelectedAnimationWeapon]
    if not preset then
        return
    end

    for defaultName, overrideName in pairs(preset) do
        if _G.Animations[overrideName] then
            _G.Animations[defaultName] = _G.Animations[overrideName]
        end
    end
end

_G.ResolveAnimation = function(name)
    if not _G.CustomAnimationEnabled then
        return _G.Animations[name]
    end

    local preset = _G.AnimationPresets[_G.SelectedAnimationWeapon]
    if not preset then
        return _G.Animations[name]
    end

    local overrideName = preset[name]
    if overrideName and _G.Animations[overrideName] then
        return _G.Animations[overrideName]
    end

    return _G.Animations[name]
end

if typeof(_G.OriginalGetAnimation) == "function" then
    _G.Animations.GetAnimation = function(self, name)
        return _G.ResolveAnimation(name)
    end
end

_G.AnimSec:Dropdown({
    Title = "Custom Animation Weapon",
    Values = {
        "The Vanquisher",
        "Soul Scythe",
        "Princess Parasol",
        "Oceanic Harpoon",
        "Holy Trident",
        "Gingerbread Katana",
        "Frozen Krampus Scythe",
        "Eternal Flower",
        "Eclipse Katana",
        "Corruption Edge",
        "Christmas Parasol",
        "Blackhole Sword",
        "Binary Edge",
        "1x1x1x1 Ban Hammer",
    },
    Value = "Holy Trident",
    Callback = _G.ProtectCallback(function(option)
        _G.SelectedAnimationWeapon = option
        _G.ApplyAnimationPreset()
    end)
})

_G.AnimSec:Toggle({
    Title = "Enable Custom Animations",
    Value = false,
    Callback = function(state)
        _G.CustomAnimationEnabled = state
        _G.ApplyAnimationPreset()
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

GlobalFav = GlobalFav or {}
GlobalFav.Variants = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VariantsFolder = ReplicatedStorage:WaitForChild("Variants", 10)

for _, variantModule in ipairs(VariantsFolder:GetChildren()) do
    local ok, variantData = pcall(require, variantModule)
    if ok and variantData then
        local name =
            (variantData.Data and (variantData.Data.Name or variantData.Data.DisplayName)) or
            variantData.Name or
            variantModule.Name

        if type(name) == "string" and name ~= "" then
            GlobalFav.Variants[name] = {
                Name = name,
                Id = variantModule.Name
            }
        end
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
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(selectedNames)
        GlobalFav.SelectedFishIds = {}

        for _, nameWithId in ipairs(selectedNames) do
            local id = GlobalFav.FishNameToId[nameWithId]
            if id then
                GlobalFav.SelectedFishIds[id] = true
            end
        end

        NotifyInfo("Auto Favorite", "Favoriting fish: " .. HttpService:JSONEncode(selectedNames))
    end
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
    Callback = function(selectedVariants)
        GlobalFav.SelectedVariants = {}

        for _, vName in ipairs(selectedVariants) do
            GlobalFav.SelectedVariants[vName] = true
        end

        NotifyInfo(
            "Auto Favorite",
            "Favoriting variants: " .. table.concat(selectedVariants, ", ")
        )
    end
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
    Callback = function(selectedRarities)
        GlobalFav.SelectedRarities = {}
        for _, rarityName in ipairs(selectedRarities) do
            for tier, name in pairs(TierToRarityName) do
                if name == rarityName then
                    GlobalFav.SelectedRarities[tier] = true
                end
            end
        end
        NotifyInfo("Auto Favorite", "Favoriting active for rarities: " .. HttpService:JSONEncode(selectedRarities))
    end
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
                count = count + 1
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
        
        _G.ConfirmFishType = false
        _G.DialogFish = Window:Dialog({
            Icon = "crown",
            Title = "Important!",
            Content = "Please select Auto Fish type!",
            Buttons = {
                {
                    Title = "Auto Fish",
                    Callback = function()
                        StartAutoFish5X()
                        _G.ConfirmFishType = true
                    end,
                },
                {
                    Title = "Auto Fish Legit",
                    Callback = function()
                        _G.ToggleAutoClick(true)
                        _G.ConfirmFishType = true
                    end,
                },
                {
                    Title = "Blatant",
                    Callback = function()
                        _G.BlatantState.enabled = true
                        _G.ConfirmFishType = true
                    end,
                },
            },
        })
    
        repeat task.wait() until _G.ConfirmFishType

        while isAutoFarmRunning do
            if not isAutoFarmRunning then
                StopAutoFish5X()
                _G.ToggleAutoClick(false)
                StopCast()
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

_G.FarmSec = AutoFarmTab:Section({
    Title = "Farming Island Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

_G.ArtSec = AutoFarmTab:Section({
    Title = "Farming Artifact Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

_G.RuinSec = AutoFarmTab:Section({
    Title = "Farming Ancient Ruin Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

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

_G.ChristmasCaveCFrames = {
    CFrame.new(605.692871, -580.58136, 8887.51074, 0.0267926417, -8.79793234e-08, 0.999641001, -2.50977159e-08, 1, 8.8683592e-08, -0.999641001, -2.74647753e-08, 0.0267926417),
    CFrame.new(576.37677, -580.58136, 8931.45312, 0.968435466, -5.87835451e-08, -0.249264464, 4.9410648e-08, 1, -4.38591208e-08, 0.249264464, 3.01584109e-08, 0.968435466),
    CFrame.new(694.887695, -487.111328, 8913.8877, 0.991148233, 3.50480462e-08, -0.132759795, -3.17826441e-08, 1, 2.67154086e-08, 0.132759795, -2.22594725e-08, 0.991148233),
    CFrame.new(746.483093, -487.112, 8926.44238, 0.689154983, -5.98709349e-09, -0.724613965, -4.31799663e-09, 1, -1.23691546e-08, 0.724613965, 1.16531451e-08, 0.689154983),
    CFrame.new(743.71759, -487.110687, 8862.72656, -0.911057472, 1.73095618e-08, -0.412279397, 1.06622533e-08, 1, 1.84235134e-08, 0.412279397, 1.23890525e-08, -0.911057472),
}

-------------------------------------------------
-- STATE
-------------------------------------------------
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
        "Lochness : %s\nCountdown: %s",
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


_G.FarmSec:Space()

_G.CodeIsland = _G.FarmSec:Dropdown({
    Title = "Farm Island",
    Values = nameList,
    Value = nameList[9],
    SearchBarEnabled = true,
    Callback = _G.ProtectCallback(function(selectedName)
        local code = islandNamesToCode[selectedName]
        local islandName = islandCodes[code]
        if islandName and farmLocations[islandName] then
            selectedIsland = islandName
            NotifySuccess("Island Selected", "Farming location set to " .. islandName)
        else
            NotifyError("Invalid Selection", "The island name is not recognized.")
        end
    end)
})

myConfig:Register("IslCode", _G.CodeIsland)

_G.AutoFarm = _G.FarmSec:Toggle({
    Title = "Start Auto Farm",
    Callback = function(state)
        isAutoFarmRunning = state
        if state then
            startAutoFarmLoop()
        else
            StopAutoFish5X()
        end
    end
})

myConfig:Register("AutoFarmStart", _G.AutoFarm)


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

    _G.AutoEventDropdown = _G.FarmSec:Dropdown({
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

local REPlaceLeverItem = Net:RemoteEvent("PlaceLeverItem")

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
    ["Spot 1"] = CFrame.new(1404.16931, 6.38866091, 118.118126, -0.964853525, 8.69606822e-08, 0.262788326, 9.85441346e-08,
        1, 3.08992689e-08, -0.262788326, 5.5709517e-08, -0.964853525),
    ["Spot 2"] = CFrame.new(883.969788, 6.62499952, -338.560059, -0.325799465, 2.72482961e-08, 0.945438921,
        3.40634649e-08, 1, -1.70824759e-08, -0.945438921, 2.6639464e-08, -0.325799465),
    ["Spot 3"] = CFrame.new(1834.76819, 6.62499952, -296.731476, 0.413336992, -7.92166972e-08, -0.910578132,
        3.06007166e-08, 1, -7.31055181e-08, 0.910578132, 2.35287234e-09, 0.413336992),
    ["Spot 4"] = CFrame.new(1483.25586, 6.62499952, -848.38031, -0.986296117, 2.72397838e-08, 0.164984599, 3.60663037e-08,
        1, 5.05033348e-08, -0.164984599, 5.57616318e-08, -0.986296117)
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

    updateParagraphArtifact("Auto Farm Artifact", ("Resuming from Spot %d..."):format(_G.CurrentSpot))

    local Player = game.Players.LocalPlayer
    task.wait(1)
    Player.Character:PivotTo(_G.ArtifactSpots["Spot " .. tostring(_G.CurrentSpot)])
    task.wait(1)

    _G.ConfirmFishType = false
    _G.DialogFish = Window:Dialog({
            Icon = "crown",
            Title = "Important!",
            Content = "Please select Auto Fish type!",
            Buttons = {
                {
                    Title = "Auto Fish",
                    Callback = function()
                        StartAutoFish5X()
                        _G.ConfirmFishType = true
                    end,
                },
                {
                    Title = "Auto Fish Legit",
                    Callback = function()
                        _G.ToggleAutoClick(true)
                        _G.ConfirmFishType = true
                    end,
                },
                {
                    Title = "Blatant",
                    Callback = function()
                        _G.BlatantState.enabled = true
                        _G.ConfirmFishType = true
                    end,
                },
            },
        })
    
    repeat task.wait() until _G.ConfirmFishType
    _G.AutoFishStarted = true

    _G.ArtifactConnection = _G.REFishCaught.OnClientEvent:Connect(function(fishName, data)
        if string.find(fishName) then
            _G.ArtifactCollected = _G.ArtifactCollected + 1
            saveProgress()

            updateParagraphArtifact(
                "Auto Farm Artifact",
                ("Artifact Found : %s\nTotal: %d/4"):format(fishName, _G.ArtifactCollected)
            )

            if _G.ArtifactCollected < 4 then
                _G.CurrentSpot = _G.CurrentSpot + 1
                saveProgress()
                local spotName = "Spot " .. tostring(_G.CurrentSpot)
                if _G.ArtifactSpots[spotName] then
                    task.wait(2)
                    Player.Character:PivotTo(_G.ArtifactSpots[spotName])
                    updateParagraphArtifact("Auto Farm Artifact",
                        ("Artifact Found : %s\nTotal : %d/4\n\nTeleporting to %s..."):format(
                            fishName,
                            _G.ArtifactCollected,
                            spotName
                        )
                    )
                    task.wait(1)
                end
            else
                updateParagraphArtifact("Auto Farm Artifact", "All Artifacts collected! Unlocking Temple...")
                StopAutoFish5X()
                _G.ToggleAutoClick(false)
                StopCast()
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
    updateParagraphArtifact("Auto Farm Artifact", "Auto Farm Artifact stopped. Progress saved.")
end

function updateParagraphArtifact(title, desc)
    if _G.ArtifactParagraph then
        _G.ArtifactParagraph:SetDesc(desc)
    end
end

_G.ArtifactParagraph = _G.ArtSec:Paragraph({
    Title = "Auto Farm Artifact",
    Desc = "Waiting for activation...",
    Color = "Green",
})

_G.ArtSec:Space()

_G.ArtSec:Toggle({
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

_G.ArtSec:Dropdown({
    Title = "Teleport to Lever Temple",
    Values = spotNames,
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

_G.ArtSec:Button({
    Title = "Unlock The Temple",
    Desc = "Still need Artifacts!",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.UnlockTemple()
    end
})

-------------------------------------------
----- =======[ ANCIENT RUIN FARMING ]
-------------------------------------------


_G.REPlaceItems = Net:RemoteEvent("PlacePressureItem")

_G.AncientRuinFish = {
    ["crocodile"] = true,
    ["goliath tiger"] = true,
    ["freshwater piranha"] = true,
    ["sacred guardian squid"] = true,
}

_G.UnlockRuin = function()
    task.spawn(function()
        local Ruins = {
            "Crocodile",
            "Goliath Tiger",
            "Freshwater Piranha",
            "Sacred Guardian Squid",
        }

        for _, ruins in ipairs(Ruins) do
            _G.REPlaceItems:FireServer(ruins)
            NotifyInfo("Ancient Ruin", "Placing: " .. ruins)
            task.wait(2.1)
        end

        NotifySuccess("Ancient Ruin", "All Fish placed successfully!")
    end)
end

_G.TempleSpot = {
    ["Spot 1"] = CFrame.new(1466.27673, -22.1250019, -658.204651, -0.0791874304, 1.48164281e-08, 0.996859729, -8.54522781e-08, 1, -2.16511644e-08, -0.996859729, -8.68984387e-08, -0.0791874304),
    ["Spot 2"] = CFrame.new(1502.93958, -22.1250019, -627.15155, -0.994363189, 2.65133604e-08, -0.106027618, 2.21884164e-08, 1, 4.19703348e-08, 0.106027618, 3.93811703e-08, -0.994363189),
    ["Spot 3"] = CFrame.new(1466.27673, -22.1250019, -658.204651, -0.0791874304, 1.48164281e-08, 0.996859729, -8.54522781e-08, 1, -2.16511644e-08, -0.996859729, -8.68984387e-08, -0.0791874304),
    ["Spot 4"] = CFrame.new(1502.93958, -22.1250019, -627.15155, -0.994363189, 2.65133604e-08, -0.106027618, 2.21884164e-08, 1, 4.19703348e-08, 0.106027618, 3.93811703e-08, -0.994363189),
}

-- FORCE ONLY ONE CFRAME (ANTI MOVE SPOT)
_G.CurrentSpot = 1

function GetFixedTempleCFrame()
    return _G.TempleSpot["Spot 1"]
end

_G.REFishCaught = Net:RemoteEvent("FishCaught")

_G.saveFile = "RuinsProgress.json"

if isfile(_G.saveFile) then
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(_G.saveFile))
    end)
    if success and type(data) == "table" then
        _G.FishCollected = data.FishCollected or 0
        _G.CurrentSpot = data.CurrentSpot or 1
    else
        _G.FishCollected = 0
        _G.CurrentSpot = 1
    end
else
    _G.FishCollected = 0
    _G.CurrentSpot = 1
end

_G.RuinFarmEnabled = false

local function saveProgress()
    local data = {
        FishCollected = _G.FishCollected,
        CurrentSpot = _G.CurrentSpot
    }
    writefile(_G.saveFile, game:GetService("HttpService"):JSONEncode(data))
end

_G.StartRuinFarm = function()
    if _G.RuinFarmEnabled then return end
    _G.RuinFarmEnabled = true

    updateParagraph("Auto Farm Ancient Ruin", ("Resuming from Spot %d..."):format(_G.CurrentSpot))

    local Player = game.Players.LocalPlayer
    task.wait(1)
    Player.Character:PivotTo(GetFixedTempleCFrame())
    task.wait(1)

    _G.ConfirmFishType = false
    _G.DialogFish = Window:Dialog({
            Icon = "crown",
            Title = "Important!",
            Content = "Please select Auto Fish type!",
            Buttons = {
                {
                    Title = "Auto Fish",
                    Callback = function()
                        StartAutoFish5X()
                        _G.ConfirmFishType = true
                    end,
                },
                {
                    Title = "Auto Fish Legit",
                    Callback = function()
                        _G.ToggleAutoClick(true)
                        _G.ConfirmFishType = true
                    end,
                },
                {
                    Title = "Blatant",
                    Callback = function()
                        _G.BlatantState.enabled = true
                        _G.ConfirmFishType = true
                    end,
                },
            },
        })
    
    repeat task.wait() until _G.ConfirmFishType
    _G.AutoFishStarted = true

    _G.RuinConnection = REFishCaught.OnClientEvent:Connect(function(fishName, data)
        local fishLower = string.lower(fishName)
        if _G.AncientRuinFish[fishLower] then
            _G.FishCollected = _G.FishCollected + 1
            saveProgress()

            updateParagraph(
                "Auto Farm Ancient Ruin",
                ("Fish Found : %s\nTotal: %d/4"):format(fishName, _G.FishCollected)
            )

            if _G.FishCollected < 4 then
                _G.CurrentSpot = _G.CurrentSpot + 1
                saveProgress()
                local spotName = "Spot " .. tostring(_G.CurrentSpot)
                if _G.TempleSpot[spotName] then
                    task.wait(2)
                    -- Disable spot switching, stay on one cframe
                    Player.Character:PivotTo(GetFixedTempleCFrame())
                    updateParagraph("Auto Farm Ancient Ruin",
                        ("Fish Found : %s\nTotal : %d/4\n\nTeleporting to %s..."):format(
                            fishName,
                            _G.FishCollected,
                            spotName
                        )
                    )
                    task.wait(1)
                end
            else
                updateParagraph("Auto Farm Ancient Ruin", "All Fish collected! Unlocking Ancient Ruin...")
                StopAutoFish5X()
                _G.ToggleAutoClick(false)
                StopCast()
                task.wait(1.5)
                if typeof(_G.UnlockRuin) == "function" then
                    _G.UnlockRuin()
                end
                _G.StopRuinFarm()
                delfile(_G.saveFile)
            end
        end
    end)
end

_G.StopRuinFarm = function()
    StopAutoFish5X()
    _G.RuinFarmEnabled = false
    _G.AutoFishStarted = false
    if _G.RuinConnection then
        _G.RuinConnection:Disconnect()
        _G.RuinConnection = nil
    end
    saveProgress()
    updateParagraph("Auto Farm Ancient Ruin", "Auto Farm stopped. Progress saved.")
end

function updateParagraph(title, desc)
    if _G.RuinParagraph then
        _G.RuinParagraph:SetDesc(desc)
    end
end

_G.RuinParagraph = _G.RuinSec:Paragraph({
    Title = "Auto Farm Ancient Ruin",
    Desc = "Waiting for activation...",
    Color = "Green",
})

_G.RuinSec:Space()

_G.RuinSec:Toggle({
    Title = "Auto Farm Ancient Ruin",
    Desc = "Automatically collects 4 Fish and unlocks Ancient Ruin.",
    Default = false,
    Callback = function(state)
        if state then
            _G.StartRuinFarm()
        else
            _G.StopRuinFarm()
        end
    end
})


_G.RuinSec:Button({
    Title = "Unlock Ancient Ruin",
    Desc = "Still need 4 Fish!",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.UnlockRuin()
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
    mode = "V2",
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

local function normalizeItemName(name)
    -- Hilangkan prefix variant umum
    name = name:gsub("^Shiny%s+", "")
    name = name:gsub("^Big%s+", "")

    return name
end

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

                    local rawName = ItemStringUtility.GetItemName(itemData, baseItemData)
                    local name = normalizeItemName(rawName)

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

        if value then
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


local inventoryCache = {}
local fullInventoryDropdownList = {}

-- Asumsi Modul game inti sudah tersedia (seperti Replion)
local ItemUtility = _G.ItemUtility or require(ReplicatedStorage.Shared.ItemUtility) 
local ItemStringUtility = _G.ItemStringUtility or require(ReplicatedStorage.Modules.ItemStringUtility)
local InitiateTrade = Net:RemoteFunction("InitiateTrade")
local RFAwaitTradeResponse = Net:RemoteFunction("AwaitTradeResponse") 

_G.TRADE_ACTIVE = false
_G.TRADE_TARGET_USERNAME "usrnrmae122"
_G.TRADE_TIER_FILTER = {}
_G.TRADE_FISH_NAME_FILTER = {} 
_G.TRADE_AMOUNT      = 0
_G.TRADE_AUTO_ACCEPT = false
_G.TRADE_LOG_FILE = "TradeLog.txt"
_G.TRADE_RETRY_UNLIMITED = true

function _G.TradeLogSummary(successCount, failCount)
    local ts = os.date("%Y-%m-%d %H:%M:%S")
    local line = string.format(
        "[%s] SUCCESS=%d | FAILED=%d\n",
        ts,
        successCount,
        failCount
    )

    if isfile(_G.TRADE_LOG_FILE) then
        appendfile(_G.TRADE_LOG_FILE, line)
    else
        writefile(_G.TRADE_LOG_FILE, line)
    end
end

function _G.IsTierAllowed(tierId)
    if not _G.TRADE_TIER_FILTER or #_G.TRADE_TIER_FILTER == 0 then
        return true
    end

    -- JIKA TIER TIDAK ADA, JANGAN BLOK
    if not tierId then
        return true
    end

    for _, allowed in ipairs(_G.TRADE_TIER_FILTER) do
        if tierId == allowed then
            return true
        end
    end

    return false
end

function _G.IsItemAllowed(itemData, baseItemData)
    local tierMatch = _G.IsTierAllowed(baseItemData.Data.Tier)
    local nameMatch = _G.IsFishNameAllowed(itemData, baseItemData)

    -- LOGIKA OR
    return tierMatch or nameMatch
end

function _G.IsFishNameAllowed(itemData, baseItemData)
    if type(_G.TRADE_FISH_NAME_FILTER) ~= "table" or #_G.TRADE_FISH_NAME_FILTER == 0 then
        return true
    end

    if not _G.ItemStringUtility or type(_G.ItemStringUtility.GetItemName) ~= "function" then
        return false
    end

    local itemName
    local ok = pcall(function()
        itemName = _G.ItemStringUtility.GetItemName(itemData, baseItemData)
    end)

    if not ok or type(itemName) ~= "string" then
        return false
    end

    itemName = string.lower(itemName)

    for _, allowedName in ipairs(_G.TRADE_FISH_NAME_FILTER) do
        if type(allowedName) == "string" then
            if itemName == string.lower(allowedName) then
                return true
            end
        end
    end

    -- ❗ FILTER ADA TAPI TIDAK MATCH → BLOCK
    return false
end

function _G.ResolveUsername(username)
    for _, plr in ipairs(Players:GetPlayers()) do
        if string.lower(plr.Name) == string.lower(username) then
            return plr.UserId, plr
        end
    end
    return nil, nil
end

function _G.GetTradeUUIDs()
    local DataReplion = _G.Replion.Client:WaitReplion("Data")
    if not DataReplion then
        warn("[AUTO TRADE] DataReplion missing")
        return {}
    end

    local items = DataReplion:Get({ "Inventory", "Items" })
    if type(items) ~= "table" then
        warn("[AUTO TRADE] Inventory empty")
        return {}
    end

    local result = {}
    local scanned, skipped = 0, 0

    for _, item in ipairs(items) do
        scanned = scanned + 1

        if not item.UUID then
            skipped = skipped + 1
            continue
        end

        local base = _G.ItemUtility:GetItemData(item.Id)
        if not base or not base.Data then
            skipped = skipped + 1
            continue
        end

        local itemType = base.Data.Type

        -- ==========================
        -- FISH (LOGIC LAMA)
        -- ==========================
        if itemType == "Fish" then
            if _G.IsItemAllowed(item, base) then
                table.insert(result, item.UUID)
            else
                skipped = skipped + 1
            end

        -- ==========================
        -- ENCHANT STONE (LOGIC BARU)
        -- ==========================
        elseif itemType == "Enchant Stones" then
            if not _G.ItemStringUtility then
                skipped = skipped + 1
                continue
            end

            local itemName
            local ok = pcall(function()
                itemName = _G.ItemStringUtility.GetItemName(item, base)
            end)

            -- HANYA EVOLVED ENCHANT STONE
            if not ok or itemName ~= "Evolved Enchant Stone" then
                skipped = skipped + 1
                continue
            end

            local qty = tonumber(item.Quantity) or 1

            -- UUID TETAP SAMA, DIULANG SESUAI QUANTITY
            for i = 1, qty do
                table.insert(result, item.UUID)
            end
        else
            skipped = skipped + 1
        end
    end

    warn(string.format(
        "[AUTO TRADE] Scan=%d | Valid=%d | Skipped=%d",
        scanned, #result, skipped
    ))

    return result
end


function _G.TeleportToTarget(targetPlayer)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 3)

    local tChar = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
    local tHrp = tChar:WaitForChild("HumanoidRootPart", 3)

    if not hrp or not tHrp then return end

    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, -4)
end


if not _G.__TRADE_ENGINE_RUNNING then
    _G.__TRADE_ENGINE_RUNNING = true

    task.spawn(function()
        while true do
            task.wait(1)

            if _G.TRADE_ACTIVE and not _G.__TRADE_IN_PROGRESS then
                _G.__TRADE_IN_PROGRESS = true

                local ok, err = pcall(function()
                    _G.StartAutoTradeV3()
                end)

                if not ok then
                    warn("[AUTO TRADE ERROR]", err)
                    _G.TRADE_ACTIVE = false
                end
            end
        end
    end)
end

-- Implementasi Auto Accept Trade
pcall(function()
    local PromptController = _G.PromptController or ReplicatedStorage:WaitForChild("Controllers").PromptController 
    local Promise = _G.Promise or require(ReplicatedStorage.Packages.Promise) 
    
    if PromptController and PromptController.FirePrompt then
        local oldFirePrompt = PromptController.FirePrompt
        PromptController.FirePrompt = function(self, promptText, ...)
            -- Cek apakah Auto Accept aktif dan prompt adalah Trade
            if _G.TRADE_AUTO_ACCEPT and type(promptText) == "string" and promptText:find("Accept") and promptText:find("from:") then
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


function _G.StartAutoTradeV3()
    if not _G.TRADE_ACTIVE then return end

    local successCount = 0
    local failCount = 0

    local userId, targetPlayer = _G.ResolveUsername(_G.TRADE_TARGET_USERNAME)
    if not userId or not targetPlayer then
        _G.TRADE_ACTIVE = false
        _G.__TRADE_IN_PROGRESS = false
        return
    end

    _G.TeleportToTarget(targetPlayer)
    task.wait(1)

    local queue = _G.GetTradeUUIDs()
    if #queue == 0 then
        _G.TradeLogSummary(0, 0)
        _G.TRADE_ACTIVE = false
        _G.__TRADE_IN_PROGRESS = false
        return
    end

    -- LIMIT MANUAL (LOGIC LAMA)
    if _G.TRADE_AMOUNT ~= 0 then
        while #queue > _G.TRADE_AMOUNT do
            table.remove(queue)
        end
    end

    -- ==========================
    -- RETRY UNLIMITED
    -- ==========================
    while _G.TRADE_ACTIVE and #queue > 0 do
        local uuid = table.remove(queue, 1)

        local ok, res = pcall(function()
            return InitiateTrade:InvokeServer(userId, uuid)
        end)

        if ok and res then
            successCount += 1
        else
            failCount += 1
            if _G.TRADE_RETRY_UNLIMITED then
                table.insert(queue, uuid)
            end
        end

        task.wait(5)
    end

    _G.TradeLogSummary(successCount, failCount)

    _G.TRADE_ACTIVE = false
    _G.__TRADE_IN_PROGRESS = false
end

Trade:Input({
    Title = "Target Username",
    Callback = function(text)
       _G.TRADE_TARGET_USERNAME = text
    end
)}

local V4_StartToggle
V4_StartToggle = Trade:Toggle({
    Title = "Start Trade Evo",
    Value = false,
    Callback = function(value)
        _G.TRADE_ACTIVE = value
    end
})


-------------------------------------------
----- =======[ PLAYER TAB ]
-------------------------------------------

local lastSelectedPlayer = nil
local isRefreshing = false

local currentDropdown = nil

function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.DisplayName)
        end
    end
    return list
end


function teleportToPlayerExact(target)
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

function refreshDropdown()
    if currentDropdown then
        isRefreshing = true
        currentDropdown:Refresh(getPlayerList())
        task.delay(0.1, function()
            isRefreshing = false
        end)
    end
end

currentDropdown = Player:Dropdown({
    Title = "Teleport to Player",
    Desc = "Select player to teleport",
    Values = getPlayerList(),
    SearchBarEnabled = true,
    Callback = _G.ProtectCallback(function(selectedDisplayName)
        -- ❌ Abaikan callback palsu
        if isRefreshing then return end
        if not selectedDisplayName then return end
        if selectedDisplayName == lastSelectedPlayer then return end

        lastSelectedPlayer = selectedDisplayName

        for _, p in ipairs(Players:GetPlayers()) do
            if p.DisplayName == selectedDisplayName then
                teleportToPlayerExact(p.Name)
                NotifySuccess(
                    "Teleport Successfully",
                    "Successfully Teleported to " .. p.DisplayName .. "!",
                    3
                )
                break
            end
        end
    end)
})

Players.PlayerAdded:Connect(function()
    task.delay(0.1, refreshDropdown)
end)

Players.PlayerRemoving:Connect(function()
    task.delay(0.1, refreshDropdown)
end)

refreshDropdown()

_G.HidePlayers = {
    Enabled = false,
    Cache = {},   -- [name] = clone
    Hidden = {},  -- [name] = true
    Characters = workspace:WaitForChild("Characters")
}

if not _G.HidePlayers.Folder then
    _G.HidePlayers.Folder = Instance.new("Folder")
    _G.HidePlayers.Folder.Name = "__HiddenCharacters"
    _G.HidePlayers.Folder.Parent = workspace
end

_G.HidePlayers.HideAll = function()
    if _G.HidePlayers.Enabled then return end
    _G.HidePlayers.Enabled = true

    local localName = game.Players.LocalPlayer.Name

    for _, model in ipairs(_G.HidePlayers.Characters:GetChildren()) do
        if model:IsA("Model") and model.Name ~= localName then
            if not _G.HidePlayers.Hidden[model.Name] then
                _G.HidePlayers.Cache[model.Name] = model:Clone()
                _G.HidePlayers.Hidden[model.Name] = true
                model:Destroy()
            end
        end
    end
end

_G.HidePlayers.ShowAll = function()
    if not _G.HidePlayers.Enabled then return end
    _G.HidePlayers.Enabled = false

    for name, clone in pairs(_G.HidePlayers.Cache) do
        if clone and not _G.HidePlayers.Characters:FindFirstChild(name) then
            clone.Parent = _G.HidePlayers.Characters
        end
    end

    _G.HidePlayers.Cache = {}
    _G.HidePlayers.Hidden = {}
end

if not _G.HidePlayers.CharConn then
    _G.HidePlayers.CharConn =
        _G.HidePlayers.Characters.ChildAdded:Connect(function(model)
            if not _G.HidePlayers.Enabled then return end
            if model:IsA("Model")
            and model.Name ~= game.Players.LocalPlayer.Name then

                if _G.HidePlayers.Hidden[model.Name] then
                    task.wait()
                    model:Destroy()
                end
            end
        end)
end

Player:Toggle({
    Title = "Hide All Players",
    Value = false,
    Callback = function(state)
        if state then
            _G.HidePlayers.HideAll()
        else
            _G.HidePlayers.ShowAll()
        end
    end
})

_G.VarWalkOnWater = {
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        Terrain = workspace:FindFirstChildOfClass("Terrain")
    },
    State = {},
    Objects = {},
    Ray = {}
}


_G.VarWalkOnWater.State.player =
    _G.VarWalkOnWater.Services.Players.LocalPlayer

_G.VarWalkOnWater.State.character =
    _G.VarWalkOnWater.State.player.Character
    or _G.VarWalkOnWater.State.player.CharacterAdded:Wait()

_G.VarWalkOnWater.State.hrp =
    _G.VarWalkOnWater.State.character:WaitForChild("HumanoidRootPart")

_G.VarWalkOnWater.State.humanoid =
    _G.VarWalkOnWater.State.character:WaitForChild("Humanoid")

----------------------------------------------------------------
-- WATER COLLISION PLANE
----------------------------------------------------------------
_G.VarWalkOnWater.Objects.waterPlane = Instance.new("Part")
_G.VarWalkOnWater.Objects.waterPlane.Name = "WaterCollisionPlane"
_G.VarWalkOnWater.Objects.waterPlane.Size = Vector3.new(200, 0.1, 200)
_G.VarWalkOnWater.Objects.waterPlane.Anchored = true
_G.VarWalkOnWater.Objects.waterPlane.CanCollide = false
_G.VarWalkOnWater.Objects.waterPlane.Transparency = 1
_G.VarWalkOnWater.Objects.waterPlane.Parent = workspace

_G.VarWalkOnWater.Ray.params = RaycastParams.new()
_G.VarWalkOnWater.Ray.params.FilterType = Enum.RaycastFilterType.Blacklist
_G.VarWalkOnWater.Ray.params.FilterDescendantsInstances = {
    _G.VarWalkOnWater.State.character,
    _G.VarWalkOnWater.Objects.waterPlane
}



_G.VarWalkOnWater.isWaterAt = function(position)
    local region = Region3.new(
        position - Vector3.new(4,4,4),
        position + Vector3.new(4,4,4)
    ):ExpandToGrid(4)

    local materials =
        _G.VarWalkOnWater.Services.Terrain:ReadVoxels(region, 4)

    if materials and materials[1] and materials[1][1] then
        return materials[1][1][1] == Enum.Material.Water
    end

    return false
end

_G.VarWalkOnWater.State.connection = nil
_G.VarWalkOnWater._heartbeatFunc = function()

    if not _G.VarWalkOnWater.State.hrp
        or not _G.VarWalkOnWater.State.hrp.Parent
    then
        return
    end

    local ray = workspace:Raycast(
        _G.VarWalkOnWater.State.hrp.Position,
        Vector3.new(0, -30, 0),
        _G.VarWalkOnWater.Ray.params
    )

    if ray and ray.Instance == _G.VarWalkOnWater.Services.Terrain then
        if _G.VarWalkOnWater.isWaterAt(ray.Position) then

            _G.VarWalkOnWater.Objects.waterPlane.CanCollide = true
            _G.VarWalkOnWater.Objects.waterPlane.Position =
                Vector3.new(
                    _G.VarWalkOnWater.State.hrp.Position.X,
                    ray.Position.Y + 0.2,
                    _G.VarWalkOnWater.State.hrp.Position.Z
                )

            _G.VarWalkOnWater.State.humanoid:ChangeState(
                Enum.HumanoidStateType.Running
            )
            return
        end
    end

    _G.VarWalkOnWater.Objects.waterPlane.CanCollide = false
end


_G.VarWalkOnWater.State.enabled = false

_G.VarWalkOnWater.Enable = function()
    if _G.VarWalkOnWater.State.enabled then return end
    _G.VarWalkOnWater.State.enabled = true

    _G.VarWalkOnWater.State.connection =
        _G.VarWalkOnWater.Services.RunService.Heartbeat:Connect(
            _G.VarWalkOnWater._heartbeatFunc
        )
end

_G.VarWalkOnWater.Disable = function()
    if not _G.VarWalkOnWater.State.enabled then return end
    _G.VarWalkOnWater.State.enabled = false

    if _G.VarWalkOnWater.State.connection then
        _G.VarWalkOnWater.State.connection:Disconnect()
        _G.VarWalkOnWater.State.connection = nil
    end

    _G.VarWalkOnWater.Objects.waterPlane.CanCollide = false
end

Player:Toggle({
    Title = "Walk On Water",
    Value = false,
    Callback = function(state)
        if state then
            _G.VarWalkOnWater.Enable()
        else
            _G.VarWalkOnWater.Disable()
        end
    end
})

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

function accessAllBoats()
    local vehicles = workspace:FindFirstChild("Vehicles")
    if not vehicles then
        NotifyError("Not Found", "Vehicles container not found.")
        return
    end

    local count = 0

    for _, boat in ipairs(vehicles:GetChildren()) do
        if boat:IsA("Model") and boat:GetAttribute("OwnerId") then
            local currentOwner = boat:GetAttribute("OwnerId")
            if currentOwner ~= LocalPlayer.UserId then
                boat:SetAttribute("OwnerId", LocalPlayer.UserId)
                count = count + 1
            end
        end
    end

    NotifySuccess("Access Granted", "You now own " .. count .. " boat(s).", 3)
end

Player:Space()

Player:Button({
    Title = "Access All Boats",
    Justify = "Center",
    Icon = "",
    Callback = accessAllBoats
})

Player:Space()

_G.FreezePlayerEnabled = false
_G.HideIslandEnabled = false
_G.__IslandVisualCache = _G.__IslandVisualCache or {}

_G.FreezePlayer = function(state)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer

    local function applyFreeze(char)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        if not hrp or not humanoid then return end

        if state then
            -- Freeze core
            hrp.Anchored = true
            humanoid.PlatformStand = true

            -- Kill physics forces
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

            -- Optional: anti collision with other players
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties =
                        PhysicalProperties.new(0, 0, 0, 0, 0)
                end
            end
        else
            -- Unfreeze
            hrp.Anchored = false
            humanoid.PlatformStand = false

            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = nil
                end
            end
        end
    end

    -- Apply immediately
    if player.Character then
        applyFreeze(player.Character)
    end

    -- Reapply if character respawns
    if not _G.__FreezeCharConn then
        _G.__FreezeCharConn = player.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart")
            task.wait(0.2)
            if _G.FreezePlayerEnabled then
                applyFreeze(char)
            end
        end)
    end

    -- Physics enforcement loop (anti exploit push)
    if state and not _G.__FreezeLoop then
        _G.__FreezeLoop = RunService.Heartbeat:Connect(function()
            if not _G.FreezePlayerEnabled then return end
            local char = player.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if hrp and humanoid then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    elseif not state and _G.__FreezeLoop then
        _G.__FreezeLoop:Disconnect()
        _G.__FreezeLoop = nil
    end

    _G.FreezePlayerEnabled = state
end

_G.SetIslandHidden = function(state)
    local Islands = workspace:FindFirstChild("Islands")
    if not Islands then
        warn("Islands folder not found!")
        return
    end

    for _, obj in ipairs(Islands:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- cache once
            if _G.__IslandVisualCache[obj] == nil then
                _G.__IslandVisualCache[obj] = obj.LocalTransparencyModifier
            end

            -- VISUAL ONLY (SAFE)
            obj.LocalTransparencyModifier = state and 1 or _G.__IslandVisualCache[obj]
            obj.CastShadow = not state

        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            -- Decal/Texture aman pakai Transparency
            obj.Transparency = state and 1 or 0

        elseif obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
            obj.Enabled = not state
        end
    end

    _G.HideIslandEnabled = state
end

Player:Toggle({
    Title = "Freeze Player",
    Justify = "Center",
    Icon = "",
    Value = false,
    Callback = function(state)
        _G.FreezePlayer(state)

        if state then
            NotifySuccess("Freeze", "Player Frozen")
        else
            NotifyInfo("Freeze", "Player Unfrozen")
        end
    end
})

_G.HideIsland = Player:Toggle({
    Title = "Hide All Island",
    Justify = "Center",
    Icon = "",
    Value = false,
    Callback = function(state)
        _G.SetIslandHidden(state)
        if state then
            NotifySuccess("Island", "All islands hidden")
        else
            NotifyInfo("Island", "All islands restored")
        end
    end
})

myConfig:Register("HideAllIsland", _G.HideIsland)

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
    local args = { ... }
    local method = getnamecallmethod()

    if tostring(self) == "URE/UpdateOxygen" and method == "FireServer" and AntiDrown_Enabled then
        return nil
    end

    return oldNamecall(self, ...)
end)

local ADrown = Player:Toggle({
    Title = "Anti Drown (Oxygen Bypass)",
    Callback = function(state)
        AntiDrown_Enabled = state
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

_G.TravelingSec = Utils:Section({
    Title = "Traveling Merchant",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

Utils:Space()

_G.TotemsSec = Utils:Section({
    Title = "Totems Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

Utils:Space()

_G.PotionsSec = Utils:Section({
    Title = "Potion Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false,
})

Utils:Space()

_G.Misc = Utils:Section({
    Title = "Teleport & Misc Menu",
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
_G.RFPurchaseMarketItem =
    Net:RemoteFunction("PurchaseMarketItem")
    
_G.MarketById = {}
for _, item in ipairs(_G.MarketItemData) do
    _G.MarketById[item.Id] = item
end

_G.MerchantUIState = {
    CurrentItemIds = {},      
    SelectedItemId = nil,      
}

_G.MerchantStatus = _G.TravelingSec:Paragraph({
    Title = "Merchant Status",
    Desc = "Waiting merchant update..."
})

_G.MerchantDropdown = _G.TravelingSec:Dropdown({
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

_G.TravelingSec:Button({
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

_G.MerchantReplion:OnDataChange(function()
    task.delay(0.2, RefreshMerchantItems)
end)

_G.MerchantReplion:OnDataChange({"Items"}, function()
    RefreshMerchantItems()
end)

task.delay(0.5, RefreshMerchantItems)


_G.TravelingSec:Space()


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
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local hum = char:WaitForChild("Humanoid")
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


            -- Spawn Totem
            local uuid = table.remove(totemList, 1)
            if uuid then
                _G.RESpawnTotem:FireServer(uuid)
                NotifySuccess("Auto Totem", "Spawned 1x " .. cleanName)
                task.wait(1)
                _G.StopFishing()
                pcall(function()
                    v6.Events.REEquip:FireServer(1)
                end)
            end
            
            
            task.wait(0.5)
                

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

_G.TotemStatusParagraph = _G.TotemsSec:Paragraph({
    Title = "Auto Totem Status",
    Desc = "Waiting for data..."
})

_G.TotemDropdown = _G.TotemsSec:Dropdown({
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

_G.TotemDelayInput = _G.TotemsSec:Input({
    Title = "Delay",
    Placeholder = "Enter minutes...",
    Default = 10,
    Callback = function(val)
        _G.AutoTotemState.DelayMinutes = tonumber(val) or 10
    end
})

_G.TotemsSec:Button({ Title = "Refresh Totems", Icon = "refresh-cw", Callback = _G.RefreshTotemInventory })

_G.TotemsSec:Toggle({
    Title = "Enable Auto Totem",
    Value = false,
    Callback = function(state)
        if state then _G.StartAutoTotem() else _G.StopAutoTotem() end
    end
})

_G.TotemsSec:Space()

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

_G.TotemsSec:Space()

-- Remote for consuming potions
_G.RFConsumePotion = Net:RemoteFunction("ConsumePotion")

-- Global states
_G.PotionInventoryCache = {} -- { ["Potion Name"] = {uuid1, uuid2, ...} }
_G.PotionList = {}

_G.AutoPotionState = {
    IsRunning = false,
    DelayMinutes = 5,
    Amount = 1,
    SelectedPotionName = nil,
    LoopThread = nil
}

function _G.RefreshPotionInventory()
    if not _G.DataReplion then return end

    _G.PotionInventoryCache = {}
    _G.PotionList = {}

    local potions = _G.DataReplion:Get({ "Inventory", "Potions" })
    if not potions then
        if _G.PotionDropdown then _G.PotionDropdown:Refresh({}) end
        return
    end

    for _, item in ipairs(potions) do
        local potionData = _G.ItemUtilityModule:GetPotionData(item.Id)
        if potionData and potionData.Data then
            local name = potionData.Data.Name

            -- Format baru: setiap nama menyimpan 1 UUID + Quantity
            _G.PotionInventoryCache[name] = {
                UUID = item.UUID,
                Quantity = item.Quantity or 1,
                Id = item.Id
            }

            table.insert(_G.PotionList, string.format("%s (x%d)", name, item.Quantity or 1))
        end
    end

    table.sort(_G.PotionList)
    if _G.PotionDropdown then
        _G.PotionDropdown:Refresh(_G.PotionList)
    end
    
    if _G.PotionStatusParagraph then
        _G.PotionStatusParagraph:SetDesc(
            string.format("Inventory refreshed. Found %d types of potions.", #_G.PotionList)
        )
    end
end

function _G.StopAutoPotion()
    _G.AutoPotionState.IsRunning = false
    if _G.AutoPotionState.LoopThread then
        task.cancel(_G.AutoPotionState.LoopThread)
        _G.AutoPotionState.LoopThread = nil
    end

    if _G.PotionStatusParagraph then
        _G.PotionStatusParagraph:SetDesc("Auto Potion Stopped.")
    end
end

function _G.StartAutoPotion()
    _G.AutoPotionState.IsRunning = true

    _G.AutoPotionState.LoopThread = task.spawn(function()
        while _G.AutoPotionState.IsRunning do

            -- Validasi pilihan
            local raw = _G.AutoPotionState.SelectedPotionName
            if not raw then
                NotifyError("Auto Potion", "No potion selected.")
                return _G.StopAutoPotion()
            end

            local cleanName = raw:match("^(.-) %(") or raw
            local potionInfo = _G.PotionInventoryCache[cleanName]

            if not potionInfo then
                NotifyError("Auto Potion", "Potion not found: " .. cleanName)
                _G.RefreshPotionInventory()
                return _G.StopAutoPotion()
            end

            local uuid = potionInfo.UUID
            local quantity = potionInfo.Quantity or 0
            local amount = tonumber(_G.AutoPotionState.Amount) or 1

            -- ============== PERBAIKAN UTAMA ==============
            -- amount tidak boleh lebih besar dari stack
            if amount > quantity then
                amount = quantity
            end
            -- =============================================

            if quantity <= 0 then
                NotifyError("Auto Potion", cleanName .. " is out of stock.")
                _G.RefreshPotionInventory()
                return _G.StopAutoPotion()
            end

            local success, result = pcall(function()
                return _G.RFConsumePotion:InvokeServer(uuid, amount)
            end)

            if success then
                NotifySuccess("Potion", "Consumed " .. amount .. "x " .. cleanName)
                potionInfo.Quantity = potionInfo.Quantity - amount
            else
                NotifyError("Potion", "Failed consuming potion.")
            end    

            -- Delay
            local delaySeconds = (_G.AutoPotionState.DelayMinutes or 1) * 60
            local waited = 0

            while waited < delaySeconds and _G.AutoPotionState.IsRunning do
                local remaining = delaySeconds - waited
                local m = math.floor(remaining / 60)
                local s = remaining % 60

                _G.PotionStatusParagraph:SetDesc(
                    string.format("Next: %02d:%02d | %s left: %d", 
                        m, s, cleanName, potionInfo.Quantity)
                )

                local step = math.min(5, remaining)
                task.wait(step)
                waited = waited + step
            end

            -- refresh supaya UI dan cache update benar setelah konsumsi
            _G.RefreshPotionInventory()
        end
    end)
end

_G.PotionStatusParagraph = _G.PotionsSec:Paragraph({
    Title = "Auto Potion Status",
    Desc = "Waiting for data..."
})

_G.PotionDropdown = _G.PotionsSec:Dropdown({
    Title = "Select Potion",
    Values = { "Loading..." },
    SearchBarEnabled = true,
    AllowNone = true,
    Callback = function(val)
        if not val then
            _G.AutoPotionState.SelectedPotionName = nil
            return
        end

        local clean = val:match("^(.-) %(") or val
        _G.AutoPotionState.SelectedPotionName = clean
    end
})

_G.PotionsSec:Input({
    Title = "Amount",
    Placeholder = "e.g. 1",
    Default = 1,
    Type = "Input",
    Callback = function(val)
        _G.AutoPotionState.Amount = tonumber(val) or 1
    end
})

_G.PotionsSec:Input({
    Title = "Delay (Minutes)",
    Placeholder = "e.g. 5",
    Default = 5,
    Type = "Input",
    Callback = function(val)
        _G.AutoPotionState.DelayMinutes = tonumber(val) or 5
    end
})

_G.PotionsSec:Button({
    Title = "Refresh Potions",
    Icon = "refresh-cw",
    Callback = _G.RefreshPotionInventory
})

_G.PotionsSec:Toggle({
    Title = "Enable Auto Potion",
    Value = false,
    Callback = function(state)
        if state then
            _G.StartAutoPotion()
        else
            _G.StopAutoPotion()
        end
    end
})

task.spawn(function()
    while not _G.Replion do
        _G.PotionStatusParagraph:SetDesc("Waiting for _G.Replion...")
        task.wait(1)
    end

    if not _G.DataReplion then
        _G.DataReplion = _G.Replion.Client:WaitReplion("Data")
    end

    if not _G.DataReplion then
        _G.PotionStatusParagraph:SetDesc("Failed to read inventory.")
        return
    end

    _G.RefreshPotionInventory()
end)

_G.PotionsSec:Space()

_G.AutoSellEnchantState = {
    Enabled = false,
    Amount = 1,
    LoopThread = nil
}

_G.RFSellItem = Net:RemoteFunction("SellItem")


_G.AutoSellProgressParagraph = _G.Misc:Paragraph({
    Title = "Auto Sell Status",
    Desc = "Idle..."
})

function isPureEnchantStone(name)
    return string.lower(name) == "enchant stone"
end

function _G.CheckEnchantStone()
    refreshInventory()

    local total = 0

    for name, data in pairs(inventoryCache) do
        if isPureEnchantStone(name) then
            if data.Mode == "Quantity" then
                total = total + data.Quantity
            elseif data.Mode == "UUID" then
                total = total + #data.UUIDs
            end
        end
    end

    if total == 0 then
        _G.AutoSellProgressParagraph:SetDesc("You have 0 Enchant Stones.")
        NotifyWarning("Enchant Stone", "No Enchant Stone found.")
        return 0
    end

    _G.AutoSellProgressParagraph:SetDesc("Total Enchant Stones: "..total)
    NotifySuccess("Enchant Stone", "Total: "..total)
    return total
end


function _G.StartAutoSellEnchant()
    if _G.AutoSellEnchantState.Enabled then return end
    _G.AutoSellEnchantState.Enabled = true

    _G.AutoSellEnchantState.LoopThread = task.spawn(function()
        refreshInventory()

        local remaining = tonumber(_G.AutoSellEnchantState.Amount) or 1
        local sold, failed = 0, 0

        for name, data in pairs(inventoryCache) do
            if remaining <= 0 or not _G.AutoSellEnchantState.Enabled then
                break
            end
        
            if isPureEnchantStone(name) then
        
                -- ===============================
                -- QUANTITY MODE
                -- ===============================
                if data.Mode == "Quantity" then
                    local qty = math.min(data.Quantity, remaining)
        
                    local ok = pcall(function()
                        _G.RFSellItem:InvokeServer(data.UUID, qty)
                    end)
        
                    if ok then
                        sold = sold + qty
                        remaining = remaining - qty
                    else
                        failed = failed + qty
                    end
        
                -- ===============================
                -- UUID MODE
                -- ===============================
                elseif data.Mode == "UUID" then
                    for _, uuid in ipairs(data.UUIDs) do
                        if remaining <= 0 then
                            break
                        end
        
                        local ok = pcall(function()
                            _G.RFSellItem:InvokeServer(uuid)
                        end)
        
                        if ok then
                            sold = sold + 1
                            remaining = remaining - 1
                        else
                            failed = failed + 1
                        end
        
                        task.wait(0.4)
                    end
                end
            end
        end

        _G.AutoSellProgressParagraph:SetDesc(
            ("Complete.\nSold: %d\nFailed: %d"):format(sold, failed)
        )

        NotifySuccess("Auto Sell Completed", "Sold "..sold.." Enchant Stones")
        _G.StopAutoSellEnchant()
    end)
end

function _G.StopAutoSellEnchant()
    _G.AutoSellEnchantState.Enabled = false
    if _G.AutoSellEnchantState.LoopThread then
        task.cancel(_G.AutoSellEnchantState.LoopThread)
    end
    _G.AutoSellEnchantState.LoopThread = nil
    _G.AutoSellProgressParagraph:SetDesc("Stopped.")
end


_G.Misc:Input({
    Title = "Amount",
    Placeholder = "Enter amount",
    Default = 5,
    Callback = function(val)
        _G.AutoSellEnchantState.Amount = tonumber(val) or 1
    end
})

_G.Misc:Button({
    Title = "Check Enchant Stones",
    Callback = function()
        _G.CheckEnchantStone()
    end
})

_G.Misc:Toggle({
    Title = "Sell Enchant Stones",
    Value = false,
    Callback = function(state)
        if state then
            _G.StartAutoSellEnchant()
        else
            _G.StopAutoSellEnchant()
        end
    end
})

_G.Misc:Space()

_G.RFRedeemCode = Net:RemoteFunction("RedeemCode")
_G.RedeemCodes = {
    "BLAMETALON",
    "FISHMAS2025",
    "GOLDENSHARK",
    "THANKYOU",
    "PURPLEMOON"
}


_G.RedeemAllCodes = function()
    for _, code in ipairs(_G.RedeemCodes) do
        local success, result = pcall(function()
            return _G.RFRedeemCode:InvokeServer(code)
        end)
        task.wait(1)
    end
end

_G.Misc:Button({
    Title = "Redeem All Codes",
    Locked = false,
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.RedeemAllCodes()
    end
})

_G.Misc:Space()

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

local WeatherDropdown = _G.Misc:Dropdown({
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

_G.Misc:Space()

local islandCoords = {
    ["01"] = { name = "Weather Machine", position = Vector3.new(-1471, -3, 1929) },
    ["02"] = { name = "Esoteric Depths", position = Vector3.new(3157, -1303, 1439) },
    ["03"] = { name = "Tropical Grove", position = Vector3.new(-2038, 3, 3650) },
    ["04"] = { name = "Fisherman Island", position = Vector3.new(-32, 4, 2773) },
    ["05"] = { name = "Kohana Volcano", position = Vector3.new(-519, 24, 189) },
    ["06"] = { name = "Coral Reefs", position = Vector3.new(-3095, 1, 2177) },
    ["07"] = { name = "Crater Island", position = Vector3.new(968, 1, 4854) },
    ["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
    ["09"] = { name = "Winter Fest", position = Vector3.new(1611, 4, 3280) },
    ["10"] = { name = "Isoteric Island", position = Vector3.new(1987, 4, 1400) },
    ["11"] = { name = "Treasure Hall", position = Vector3.new(-3600, -267, -1558) },
    ["12"] = { name = "Lost Shore", position = Vector3.new(-3663, 38, -989) },
    ["13"] = { name = "Sishypus Statue", position = Vector3.new(-3792, -135, -986) },
    ["14"] = { name = "Ancient Jungle", position = Vector3.new(1478, 131, -613) },
    ["15"] = { name = "The Temple", position = Vector3.new(1477, -22, -631) },
    ["16"] = { name = "Underground Cellar", position = Vector3.new(2133, -91, -674) },
    ["17"] = {name = "Ancient Ruin", position = Vector3.new(6052, -546, 4427) },
    ["21"] = {name = "Pirate Cove", position = Vector3.new(3497, 4, 3447) },
    ["99"] = {name = "Pirate Treasure Room", position = Vector3.new(3343, -298, 3118) },
    ["83"] = {name = "Crystal Pessage", position = Vector3.new(3433, -299, 3365) },
    ["72"] = {name = "Crystal Depths", position = Vector3.new(5494, -905, 15389) },
    ["22"] = {name = "Volcanic Cavern", position = Vector3.new(1146, 73, -10260)},
    ["39"] = {name = "Heartfelt Island", position = Vector3.new(1083, 5, 2721)},
}

local islandNames = {}
for _, data in pairs(islandCoords) do
    table.insert(islandNames, data.name)
end

_G.Misc:Dropdown({
    Title = "Island Selector",
    Desc = "Select island to teleport",
    Values = islandNames,
    SearchBarEnabled = true,
    Callback = _G.ProtectCallback(function(selectedName)
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
    end)
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

_G.Client = require(ReplicatedStorage.Packages.Replion).Client



function getPartRecursive(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        elseif child:IsA("Model") or child:IsA("Folder") then
            local found = getPartRecursive(child)
            if found then return found end
        end
    end
    return nil
end

_G.Misc:Dropdown({
    Title = "Teleport Event",
    Values = eventsList,
    Callback = function(option)
        local eventReplion = _G.Client:GetReplion("Events")
        local activeEvents = eventReplion and eventReplion:GetExpect("Events") or {}
        
        local isActive = false
        for _, name in ipairs(activeEvents) do
            if name == option then isActive = true break end
        end

        if not isActive then
            WindUI:Notify({Title = "Not Active", Content = option .. " Not yet started!", Icon = "clock"})
            return
        end

        local target = findEventPart(option)
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if target and hrp then
            hrp.CFrame = target:GetPivot() + Vector3.new(0, 15, 0)
            WindUI:Notify({
                Title = "Success",
                Content = "Teleported to " .. option,
                Icon = "circle-check"
            })
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Failed find the Event Path!",
                Icon = "ban"
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

_G.Misc:Dropdown({
    Title = "Rod Shop",
    Desc = "Select Rod to Buy",
    Values = rodOptions,
    SearchBarEnabled = true,
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

_G.Misc:Dropdown({
    Title = "Baits Shop",
    Desc = "Select Baits to Buy",
    Values = baitOptions,
    SearchBarEnabled = true,
    Callback = function(option)
        local selectedName = option:split(" |")[1]
        local id = baitData[selectedName]

        SafePurchase(function()
            Net:RemoteFunction("PurchaseBait"):InvokeServer(id)
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


_G.Misc:Dropdown({
    Title = "NPC",
    Desc = "Select NPC to Teleport",
    Values = npcList,
    SearchBarEnabled = true,
    Callback = function(selectedName)
        local npc = npcFolder:FindFirstChild(selectedName)
        if npc and npc:IsA("Model") then
            local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if hrp then
                local charFolder = workspace:FindFirstChild("Characters", 5)
                local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
                if not char then return end
                local myHRP = char:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    myHRP.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                    NotifySuccess("Teleported!", "You are now near: " .. selectedName)
                end
            end
        end
    end
})

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



local function extractAssetId(iconString)
    if type(iconString) ~= "string" then return nil end

    -- Format "rbxassetid://125463067542850"
    local id = iconString:match("rbxassetid://(%d+)")
    if id then return id end

    -- Format fallback, misal langsung angka
    local numeric = iconString:match("%d+")
    if numeric then return numeric end

    return nil
end


local ItemLookupCache = {}

local function getIconIdFromItem(itemId)
    if not itemId then return nil end
    if ItemLookupCache[itemId] then return ItemLookupCache[itemId] end

    for _, moduleScript in ipairs(ReplicatedStorage.Items:GetChildren()) do
        
        if moduleScript:IsA("ModuleScript") then
            local ok, data = pcall(require, moduleScript)
            
            if ok and data and data.Data and data.Data.Id == itemId then
                ItemLookupCache[itemId] = extractAssetId(data.Data.Icon)
                return ItemLookupCache[itemId]
            end
        end
    end

    return nil
end

local function resolveImage(assetId)
    local ok, response = pcall(function()
        local url =
            "https://thumbnails.roblox.com/v1/assets?assetIds=" ..
            assetId .. "&size=420x420&format=Png&isCircular=false"

        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if ok and response and response.data and response.data[1] then
        local img = response.data[1].imageUrl
        print("[resolveImage() FOUND URL]:", img)
        return img
    end

    return nil
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

FishNotif:Paragraph({
    Title = "Fish Notification",
    Color = "Green",
    Desc = [[
This is a Fish Notification that functions to display fish in the channel server.
You can buy a Key for the custom Channel you want.
Price : 50K IDR
]]
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

_G.NotifDrop = FishNotif:Dropdown({
    Title = "Select Fish Categories",
    Desc = "Choose which categories to send to webhook",
    Values = { "Secret", "Legendary", "Mythic" },
    Multi = true,
    Callback = function(selected)
        SelectedCategories = selected
    end
})

myConfig:Register("CategoryFish", _G.NotifDrop)

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
    if not webhookPath or webhookPath == "" or not FishWebhookEnabled then
        return
    end

    local WebhookURL = "https://discord.com/api/webhooks/" .. webhookPath
    local username = LocalPlayer.DisplayName or LocalPlayer.Name
    local rodName = getValidRodName()
    local inventoryCount = getInventoryCount()

    ------------------------------------------------------------
    -- STRICT IMAGE USING tr.rbxcdn.com ONLY
    ------------------------------------------------------------
    local extractedId = getIconIdFromItem(itemId)
    local imageUrl = nil

    if extractedId then
        local resolved = resolveImage(extractedId)

        if resolved then
            -- resolved always full URL, so do not reinterpret
            imageUrl = resolved:gsub("width=420&height=420&format=png", "420/420/Image/Png/noFilter")
            imageUrl = imageUrl:gsub("asset%-thumbnail/image%?assetId=" .. extractedId, extractedId)
        end
    end

    -- If resolveImage didn't return URL - force thumbnail direct format
    if not imageUrl and extractedId then
        imageUrl =
            "https://thumbnails.roblox.com/v1/assets?assetIds=" ..
            extractedId .. "&size=420x420&format=Png&isCircular=false"
    end
    
    print("[FINAL WEBHOOK IMAGE] →", imageUrl)

    ------------------------------------------------------------
    -- DATA SELEBIHNYA TETAP SAMA
    ------------------------------------------------------------

    local caught = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Caught")
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

        if success and data then
            if type(data) == "table" then
                coinNumber = data.Value or data.Amount
            elseif type(data) == "number" then
                coinNumber = data
            end

            if coinNumber then
                local okFmt, formatted = pcall(_G.StringLibrary.Shorten, _G.StringLibrary, coinNumber)
                coinCountString = okFmt and formatted or tostring(coinNumber)
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
        coinCountString
    )

    safeHttpRequest({
        Url = WebhookURL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            embeds = {{
                title = "Fish Caught!",
                description = embedDesc,
                color = tonumber("0x00bfff"),
                image = { url = imageUrl },
                footer = { text = "Fish Notification " .. os.date("%d %B %Y, %H:%M:%S") }
            }}
        })
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

    local WebhookURL = "https://discord.com/api/webhooks/" .. webhookPath
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
        local assetId = getIconIdFromItem(currentItemId)

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

SettingsTab:Button({
    Title = "Save Position",
    Justify = "Center",
    Callback = function()
        _G.savePosition()
    end
})

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

        for _, v in ipairs(game:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                    v.CastShadow = false
                    if v.Transparency > 0.5 then
                        v.Transparency = 1
                    end

                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1

                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)

                elseif v:IsA("Smoke")
                or v:IsA("Fire")
                or v:IsA("Explosion")
                or v:IsA("ForceField")
                or v:IsA("Sparkles")
                or v:IsA("Beam")
                or v:IsA("SpotLight")
                or v:IsA("PointLight")
                or v:IsA("SurfaceLight") then
                    v.Enabled = false

                elseif v:IsA("ShirtGraphic")
                or v:IsA("Shirt")
                or v:IsA("Pants") then
                    v:Destroy()
                end
            end)
        end

        -- Lighting optimization
        local Lighting = game:GetService("Lighting")
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ClockTime = 12
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)

        -- Terrain optimization
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
            Terrain.Decoration = false
        end

        -- Reduce loud sounds
        for _, s in ipairs(workspace:GetDescendants()) do
            if s:IsA("Sound") and s.Playing then
                s.Volume = 0
            end
        end

        -- Garbage collect (safe)
        pcall(function()
            collectgarbage("collect")
        end)

        -- Full white screen (safe for Velocity)
        local guiParent
        pcall(function()
            guiParent = game:GetService("CoreGui")
        end)
        if not guiParent then
            guiParent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        end

        local fullWhite = Instance.new("ScreenGui")
        fullWhite.Name = "FullWhiteScreen"
        fullWhite.IgnoreGuiInset = true
        fullWhite.ResetOnSpawn = false
        fullWhite.Parent = guiParent

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1,0,1,0)
        frame.BackgroundColor3 = Color3.new(1,1,1)
        frame.BorderSizePixel = 0
        frame.Parent = fullWhite

        NotifySuccess("Boost FPS", "Ultra Low Graphics applied (Velocity Safe)")
    end
})

SettingsTab:Space()

local TeleportService = game:GetService("TeleportService")

function _G.Rejoin()
    local player = Players.LocalPlayer
    if player then
        TeleportService:Teleport(game.PlaceId, player)
    end
end

function _G.ServerHop()
    local placeId = game.PlaceId
    local servers = {}
    local cursor = ""
    local found = false

    repeat
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
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
        _G.Rejoin()
    end,
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "Server Hop (New Server)",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.ServerHop()
    end,
})

SettingsTab:Space()

SettingsTab:Section({
    Title = "Configuration",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

local ThemeIcons = {
    QuietOcean = "waves",
    AbyssNeon = "zap",
    CyberAqua = "cpu",
    MidnightNavy = "moon",
    VoidPurple = "sparkles",
    BloodAbyss = "flame",
    IceFrost = "snowflake",
    ObsidianGreen = "leaf",
    SolarDark = "sun",
    DeepSeaEmerald = "anchor"
}

local ThemeDropdownValues = {
    { Title = "Default", Icon = "palette" }
}

for _, theme in ipairs(_G.RawThemes or {}) do
    table.insert(ThemeDropdownValues, {
        Title = theme.Name,
        Icon = ThemeIcons[theme.Name] or "droplet"
    })
end

SettingsTab:Dropdown({
    Title = "UI Theme",
    Values = ThemeDropdownValues,
    SearchBarEnabled = true,
    Value = "QuietOcean",
    Callback = function(option)
        if typeof(option) ~= "table" then return end
        if option.Title == "QuietOcean" then
            WindUI:SetTheme("QuietOcean")
            return
        end

        WindUI:SetTheme(option.Title)
    end
})

SettingsTab:Space()

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

SettingsTab:Button({
    Title = "Load",
    Justify = "Center",
    Icon = "",
    Callback = function()
        myConfig:Load()
        NotifySuccess("Config Loaded", "Config has beed loaded!")
    end
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "Delete",
    Justify = "Center",
    Icon = "",
    Callback = function()
        myConfig:Delete()
        NotifySuccess("Config Delete", "Config has beed Deleted!")
    end
})

myConfig:Load()

task.defer(function()
    task.wait(0.5)
    _G.__UIReady = true
end)