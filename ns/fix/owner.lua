local Version = "1.6.53"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" ..
Version .. "/main.lua"))()

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
local VirtualUser = game:GetService("VirtualUser")
local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RF/CatchFishCompleted")
local Constants = require(ReplicatedStorage:WaitForChild("Shared", 20):WaitForChild("Constants"))

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

if Player and VirtualUser then
    Player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

task.spawn(function()
    if _G.XPBar then
        _G.XPBar.Enabled = true
    end
end)

task.spawn(function()
    if _G.TitleEnabled then
        _G.TitleEnabled.Visible = true
        _G.Title.TextScaled = false
        _G.Title.TextColor3 = Color3.fromRGB(170, 0, 255)
        _G.Title.TextSize = 10
        _G.Title.Text = "QuietXHub"
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
    Author = "by Prince",
    Folder = "QuietXHub",
    Size = UDim2.fromOffset(600, 400),
    Transparent = true,
    Theme = "Deep Sea Dawn",
    ToggleKey = Enum.KeyCode.K,
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
    Title = "QuietXHub",
    Icon = "crown",
    CornerRadius = UDim.new(0, 30),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FFD75F"),
        Color3.fromHex("082A4D")
    ),
    Draggable = true,
})

Window:Tag({
    Title = "PREMIUM VERSION",
    Color = Color3.fromHex("#30ff6a")
})



local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("QuietXConfig")


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
    Title = "Christmas Event",
    Icon = "solar:stars-bold",
})

local AllMenu = Window:Section({
    Title = "All Menu Here",
    Icon = "tally-3",
    Opened = false,
})

local AutoFish = AllMenu:Tab({
    Title = "Menu Fishing",
    Icon = "fish"
})

local AutoFarmTab = AllMenu:Tab({
    Title = "Menu Farming",
    Icon = "leaf"
})

_G.AutoQuestTab = AllMenu:Tab({
    Title = "Auto Quest",
    Icon = "notebook"
})

local AutoFav = AllMenu:Tab({
    Title = "Auto Favorite",
    Icon = "star"
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

-------------------------------------------
----- =======[ HOME TAB ]
-------------------------------------------

local InviteAPI = "https://discord.com/api/v10/invites/"

local function LookupDiscordInvite(inviteCode)
    local url = InviteAPI .. inviteCode .. "?with_counts=true"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        return {
            name = data.guild and data.guild.name or "Unknown",
            id = data.guild and data.guild.id or "Unknown",
            online = data.approximate_presence_count or 0,
            members = data.approximate_member_count or 0,
            icon = data.guild and data.guild.icon
                and "https://cdn.discordapp.com/icons/" .. data.guild.id .. "/" .. data.guild.icon .. ".png"
                or "",
        }
    else
        warn("Gagal mendapatkan data invite.")
        return nil
    end
end

local inviteCode = "vf5nUduRxq"
local inviteData = LookupDiscordInvite(inviteCode)

if inviteData then
    Home:Paragraph({
        Title = string.format("[DISCORD] %s", inviteData.name),
        Desc = string.format("Members: %d\nOnline: %d", inviteData.members, inviteData.online),
        Image = inviteData.icon,
        ImageSize = 50,
        Locked = true,
    })
else
    warn("Invite tidak valid.")
end

local GitHubAPI = "https://api.github.com/users/"

local function LookupGitHubUser(username)
    local url = GitHubAPI .. username
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        return {
            login = data.login or username,
            name = data.name or "No Name",
            bio = data.bio or "No bio available",
            followers = data.followers or 0,
            following = data.following or 0,
            repos = data.public_repos or 0,
            avatar = data.avatar_url or "",
            html_url = data.html_url or "",
        }
    else
        warn("Gagal mendapatkan data GitHub.")
        return nil
    end
end

local githubUsername = "ohmygod-king"
local githubData = LookupGitHubUser(githubUsername)

if githubData then
    Home:Paragraph({
        Title = string.format("[GITHUB] %s", githubData.name),
        Desc = string.format(
            "Username: %s\nRepos: %d",
            githubData.login,
            githubData.repos
        ),
        Image = githubData.avatar,
        ImageSize = 50,
        Locked = true,
    })
else
    warn("GitHub user tidak ditemukan.")
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

-------------------------------------------
-- =======[ CHRISTMAS EVENT - FINAL ]
-------------------------------------------

_G.CEvent:Divider()

_G.CEvent:Section({
    Title = "Christmas Event Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.CEvent:Divider()

_G.PresentParagraph = _G.CEvent:Paragraph({
    Title = "Auto Christmas Event",
    Desc = "Idle",
    Thumbnail = "https://i.ibb.co.com/DP3Rx9Kt/Pngtree-free-christmas-tree-with-gift-15824230.jpg",
    ThumbnailSize = 80
})

function setUI(text)
    if _G.PresentParagraph then
        _G.PresentParagraph:SetDesc(text)
    end
end

-------------------------------------------------
-- LIBRARIES
-------------------------------------------------
_G.Replion = require(
    ReplicatedStorage.Packages._Index["ytrev_replion@2.0.0-rc.3"].replion
)

_G.ItemUtility = require(
    ReplicatedStorage.Shared.ItemUtility
)

_G.ItemStringUtility = require(
    ReplicatedStorage.Modules.ItemStringUtility
)

-------------------------------------------------
-- REMOTES
-------------------------------------------------
_G.RFSpecialDialogueEvent =
    ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"]
        .net["RF/SpecialDialogueEvent"]

_G.REEquipItem =
    ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"]
        .net["RE/EquipItem"]

_G.REEquipToolFromHotbar =
    ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"]
        .net["RE/EquipToolFromHotbar"]

_G.RFRedeemGift =
    ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"]
        .net["RF/RedeemGift"]

-------------------------------------------------
-- GLOBAL STATE
-------------------------------------------------
_G.AutoChristmasEvent = false
_G.__ChristmasThread = nil
_G.RedeemDelay = 2

-------------------------------------------------
-- INVENTORY SCAN (GEARS PRESENT ONLY)
-------------------------------------------------
_G.GetPresentItems = function()
    local DataReplion = _G.Replion.Client:WaitReplion("Data")
    if not DataReplion then return {} end

    local items = DataReplion:Get({ "Inventory", "Items" }) or {}
    local result = {}

    for _, item in ipairs(items) do
        if not item or not item.Id then continue end

        local base = _G.ItemUtility:GetItemData(item.Id)
        if not base or not base.Data then continue end
        if base.Data.Type ~= "Gears" then continue end

        local name = _G.ItemStringUtility.GetItemName(item, base)
        if not name then continue end

        if string.find(string.lower(name), "present") then
            table.insert(result, {
                Name = name,
                UUID = item.UUID
            })
        end
    end

    return result
end

-------------------------------------------------
-- CLAIM ALL CHRISTMAS DOORS
-------------------------------------------------
_G.ClaimDoors = function()
    local folder = workspace:FindFirstChild("ChristmasDoors")
    if not folder then return end

    for _, door in ipairs(folder:GetChildren()) do
        pcall(function()
            _G.RFSpecialDialogueEvent:InvokeServer(
                door.Name,
                "PresentChristmasDoor"
            )
        end)
        task.wait(0.4)
    end
end

-------------------------------------------------
-- REDEEM PRESENTS
-------------------------------------------------
_G.RedeemAllPresents = function()
    local presents = _G.GetPresentItems()

    if #presents == 0 then
        setUI("No Present found in inventory.")
        return false
    end

    for i, item in ipairs(presents) do
        if not _G.AutoChristmasEvent then return false end

        setUI(string.format(
            "[%d/%d]\nRedeeming %s",
            i, #presents, item.Name
        ))

        pcall(function()
            _G.REEquipItem:FireServer(item.UUID, "Gears")
        end)

        task.wait(0.6)

        pcall(function()
            _G.REEquipToolFromHotbar:FireServer(6)
        end)

        task.wait(0.6)

        pcall(function()
            _G.RFRedeemGift:InvokeServer()
        end)

        task.wait(_G.RedeemDelay)
    end

    return true
end

-------------------------------------------------
-- MAIN LOOP
-------------------------------------------------
_G.StartChristmasLoop = function()
    if _G.__ChristmasThread then return end

    _G.__ChristmasThread = task.spawn(function()
        while _G.AutoChristmasEvent do
            -- =========================
            -- STEP 1: CLAIM DOORS
            -- =========================
            setUI("Claiming Christmas Presents...")
            pcall(_G.ClaimDoors)

            -- =========================
            -- STEP 2: WAIT SERVER SYNC
            -- =========================
            setUI("Syncing inventory...")
            for i = 1, 6 do
                if not _G.AutoChristmasEvent then break end
                task.wait(1)
            end

            -- =========================
            -- STEP 3: SCAN & REDEEM
            -- =========================
            local count = #_G.GetPresentItems()

            if count > 0 then
                setUI(("Found %d Present(s).\nRedeeming..."):format(count))
                _G.RedeemAllPresents()
                setUI("Redeem finished.")
            else
                setUI("No Present available this cycle.")
            end
            
            task.wait(1)

            -- =========================
            -- STEP 4: COOLDOWN
            -- =========================
            
            setUI("Cooldown... Next check in 1 hour.")
            local start = tick()
            while _G.AutoChristmasEvent and (tick() - start) < 3600 do
                task.wait(1)
            end
        end

        _G.__ChristmasThread = nil
    end)
end

_G.StopChristmasLoop = function()
    _G.AutoChristmasEvent = false
end

-------------------------------------------------
-- TOGGLE
-------------------------------------------------
_G.CEvent:Toggle({
    Title = "Auto Christmas Event (Claim + Redeem)",
    Value = false,
    Callback = function(state)
        _G.AutoChristmasEvent = state

        if state then
            setUI("Starting...")
            _G.StartChristmasLoop()
        else
            setUI("Disabled.")
            _G.StopChristmasLoop()
        end
    end
})

_G.CEvent:Divider()

_G.CEvent:Section({
    Title = "1x1x1x1 Admin Evenr",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.CEvent:Divider()


-- =====================================================
-- AUTO EVENT 1x1x1x1 (BLACK HOLE - MODEL / WORLDPIVOT)
-- =====================================================

do
    _G.AutoBlackHole = {
        enabled = false,
        lastPivot = nil,
        conn = nil,
        loop = nil
    }

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local function getHRP()
        local char = LocalPlayer.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getBlackHole()
        return workspace:FindFirstChild("Props")
            and workspace.Props:FindFirstChild("Black Hole")
    end

    local function teleportToBlackHole()
        local bh = getBlackHole()
        local hrp = getHRP()
        if not (bh and hrp) then return end

        local pivot = bh:GetPivot()
        hrp.CFrame = pivot
        _G.AutoBlackHole.lastPivot = pivot

        -- Aktifkan OnceBlock jika ada
        if _G.ToggleBlockOnce then
            _G.ToggleBlockOnce(true)
        end
    end

    -------------------------------------------------
    -- START MONITOR
    -------------------------------------------------
    local function startMonitor()
        local bh = getBlackHole()
        if not bh then
            warn("Black Hole model not found")
            return
        end

        -- Teleport langsung saat toggle ON
        teleportToBlackHole()

        -- 1️⃣ EVENT-BASED (jika WorldPivot berubah)
        pcall(function()
            _G.AutoBlackHole.conn =
                bh:GetPropertyChangedSignal("WorldPivot"):Connect(function()
                    if not _G.AutoBlackHole.enabled then return end
                    teleportToBlackHole()
                end)
        end)

        -- 2️⃣ FALLBACK POLLING (aman, ringan)
        _G.AutoBlackHole.loop = task.spawn(function()
            while _G.AutoBlackHole.enabled do
                local current = bh:GetPivot()
                if not _G.AutoBlackHole.lastPivot
                    or (current.Position - _G.AutoBlackHole.lastPivot.Position).Magnitude > 1
                then
                    teleportToBlackHole()
                end
                task.wait(2) -- cukup 2 detik, event ini jam-an
            end
        end)
    end

    -------------------------------------------------
    -- STOP MONITOR
    -------------------------------------------------
    local function stopMonitor()
        if _G.AutoBlackHole.conn then
            _G.AutoBlackHole.conn:Disconnect()
            _G.AutoBlackHole.conn = nil
        end

        if _G.AutoBlackHole.loop then
            task.cancel(_G.AutoBlackHole.loop)
            _G.AutoBlackHole.loop = nil
        end
    end

    -------------------------------------------------
    -- UI TOGGLE
    -------------------------------------------------
    if _G.CEvent then
        _G.CEvent:Toggle({
            Title = "Auto Event 1x1x1x1",
            Value = false,
            Callback = function(state)
                _G.AutoBlackHole.enabled = state
                if state then
                    startMonitor()
                else
                    stopMonitor()
                end
            end
        })
    else
        warn("EventTab not found")
    end
end

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
_G.DELAY_ANTISTUCK = 7
_G.isRecasting5x = false
_G.STUCK_TIMEOUT = 10
_G.AntiStuckEnabled = true
_G.lastFishTime = tick()
_G.FINISH_DELAY = 1.4
_G.fishCounter = 0
_G.sellThreshold = 50
_G.sellActive = true
_G.AutoFishHighQuality = false
_G.CastTimeoutMode = "Fast"
_G.CastTimeoutValue = 0.01

-- [[ KONFIGURASI DELAY ]] --


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

function InitialCast5X()
    _G.StopFishing()
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
        task.wait(0)
    end
    miniGameRemote:InvokeServer(-1.25, 1.0, workspace:GetServerTimeNow())
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
				task.wait(0.5)
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

_G.FishAdvenc = AutoFish:Section({
    Title = "Adcenced Settings",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

_G.FishSec = AutoFish:Section({
    Title = "Auto Fishing Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.DelayFinish = _G.FishAdvenc:Input({
    Title = "Delay Finish",
    Desc = [[
High Rod = 1
Medium Rod = 1.5 - 1.7
Low Rod = 2 - 3
]],
    Value = _G.FINISH_DELAY,
    Type = "Input",
    Placeholder = "Input Delay Finish..",
    Callback = function(input)
        fDelays = tonumber(input)
        if not fDelays then
            NotifyWarning("Please Input Valid Number")
        end
        _G.FINISH_DELAY = fDelays
    end
})

myConfig:Register("DelayFinish", _G.DelayFinish)

_G.SpeedLegit = _G.FishAdvenc:Input({
    Title = "Speed Legit",
    Desc = "Speed Click for Auto Fish Legit",
    Value = _G.SPEED_LEGIT,
    Type = "Input",
    Placeholder = "Input Speed..",
    Callback = function(input)
        DelayLegit = tonumber(input)
        if not DelayLegit then
            NotifyWarning("Please Input Valid Number")
        end
        _G.SPEED_LEGIT = DelayLegit
    end
})

myConfig:Register("SpeedLegit", _G.SpeedLegit)

_G.SellThress = _G.FishAdvenc:Input({
    Title = "Sell Threesold",
    Value = _G.sellThreshold,
    Type = "Input",
    Placeholder = "Input Delay Finish..",
    Callback = function(input)
        thresold = tonumber(input)
        if not thresold then
            NotifyWarning("Please Input Valid Number")
        end
        _G.sellThreshold = thresold
    end
})

myConfig:Register("SellThresold", _G.SellThress)

_G.StuckDelay = _G.FishAdvenc:Input({
    Title = "Anti Stuck Delay",
    Desc = "Cooldown for anti stuck Auto Fish",
    Value = _G.STUCK_TIMEOUT,
    Type = "Input",
    Placeholder = "Input Delay Finish..",
    Callback = function(input)
        stuck = tonumber(input)
        if not stuck then
            NotifyWarning("Please Input Valid Number")
        end
        _G.STUCK_TIMEOUT = stuck
    end
})

myConfig:Register("StuckDelay", _G.StuckDelay)

_G.AutoSell = _G.FishSec:Toggle({
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
    Values = {"Perfect", "Fast"},
    Value = "Fast",
    Multi = false,
    Callback = function(selected)
        _G.CastTimeoutMode = selected
        if selected == "Perfect" then
            _G.CastTimeoutValue = 1
        elseif selected == "Fast" then
            _G.CastTimeoutValue = 0.01
        end
    end
})

myConfig:Register("SetCast", _G.SetCast)

_G.HighFish = _G.FishSec:Toggle({
    Title = "Fish High Quality",
    Desc = "Only Legendary, Mythic, & SECRET",
    Value = _G.AutoFishHighQuality,
    Callback = function(state)
        _G.AutoFishHighQuality = state
    end
})

myConfig:Register("FishHigh", _G.HighFish)

_G.FishLegit = _G.FishSec:Toggle({
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

myConfig:Register("FishLegit", _G.FishLegit)


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

_G.FishAdvenc:Toggle({
    Title = "Auto Skip Cutscenes",
    Value = false,
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

_G.InvenSize = _G.FishAdvenc:Input({
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

myConfig:Register("InventorySize", _G.InvenSize)

local REEquipItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]
local RFSellItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellItem"]

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

_G.FishAdvenc:Toggle({
    Title = "Auto Sell Mythic",
    Desc = "Automatically sells clicked fish",
    Default = false,
    Callback = function(state)
        ToggleAutoSellMythic(state)
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

-- =======================================================
-- == FAKE FISHING: VISUAL + INVENTORY UI FIX
-- =======================================================

-- 1. SERVICES & PLAYERS
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.Players = game:GetService("Players")
_G.HttpService = game:GetService("HttpService")
_G.LocalPlayer = _G.Players.LocalPlayer

-------------------------------------------
----- =======[ SUPER FISHING (FAKE) ]
-------------------------------------------

_G.FakeFishSection = AutoFish:Section({ 
    Title = "Super Fishing (Developer Only)", 
    TextSize = 22, 
    TextXAlignment = "Center", 
    Opened = false 
})

local fakeFishState = {
    enabled = false,
    thread = nil,
    delay = 0.05,
    stepDelay = 0.05,
    FishDB_List = {},
    FishDB_ByName = {},
    Area_FishMap = {},
    loaded = false,
    selectedRarities = {},
    injectToInventory = true,
    useGolden = true,
    useRainbow = true,
    useVisualEffects = true
}

-- [HELPER] Load Data Ikan
local function ensureFakeDataLoaded()
    if fakeFishState.loaded then return end
    
    fakeFishState.FishDB_List = {}
    fakeFishState.FishDB_ByName = {}
    
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if not itemsFolder then return end
    
    for _, module in pairs(itemsFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            local success, data = pcall(require, module)
            if success and data and data.Data and data.Data.Type == "Fish" then
                local detectedTier = data.Data.Tier or data.Data.Rarity or 1
                if type(detectedTier) == "number" then
                    local tierMap = { [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic", [5] = "Legendary", [6] = "Mythic", [7] = "SECRET" }
                    detectedTier = tierMap[detectedTier] or "Common"
                end

                local fishData = {
                    Name = data.Data.Name,
                    Id = data.Data.Id,
                    WeightMin = (data.Weight and data.Weight.Default and data.Weight.Default.Min) or 1,
                    WeightMax = (data.Weight and data.Weight.Default and data.Weight.Default.Max) or 10,
                    Tier = tostring(detectedTier),
                    TierNum = data.Data.Tier or 1
                }
                
                table.insert(fakeFishState.FishDB_List, fishData)
                fakeFishState.FishDB_ByName[data.Data.Name] = fishData
            end
        end
    end

    local areasSuccess, AreasData = pcall(function() return require(ReplicatedStorage:WaitForChild("Areas")) end)
    if areasSuccess and type(AreasData) == "table" then
        for areaName, areaData in pairs(AreasData) do
            if areaData.Items then fakeFishState.Area_FishMap[areaName] = areaData.Items end
        end
    end
    
    fakeFishState.loaded = true
end

-- [LOGIC] Pilih Ikan Smart
local function getSmartFishFake()
    local currentZone = Players.LocalPlayer:GetAttribute("LocationName") or "Fisherman Island"
    local validFishList = {}

    local function isTierMatch(fishTier)
        if #fakeFishState.selectedRarities == 0 then return true end
        return table.find(fakeFishState.selectedRarities, fishTier) ~= nil
    end

    local areaItemNames = fakeFishState.Area_FishMap[currentZone]
    if areaItemNames then
        for _, itemName in ipairs(areaItemNames) do
            local fish = fakeFishState.FishDB_ByName[itemName]
            if fish and isTierMatch(fish.Tier) then table.insert(validFishList, fish) end
        end
    end

    if #validFishList == 0 then
        for _, fish in ipairs(fakeFishState.FishDB_List) do
            if isTierMatch(fish.Tier) then table.insert(validFishList, fish) end
        end
    end

    if #validFishList > 0 then return validFishList[math.random(1, #validFishList)] end
    return nil
end

-- [UI UPDATE] Modifier Bars (Golden/Rainbow)
local function updateModifierUI_Fake()
    pcall(function()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local backpack = pg:FindFirstChild("Backpack")
        if not backpack then return end
        local modifiers = backpack:FindFirstChild("Modifiers")
        if not modifiers then return end
        
        -- Golden Logic
        if fakeFishState.useGolden then
            local golden = modifiers:FindFirstChild("Golden")
            if golden and golden:FindFirstChild("Label") then
                local maxGolden = 10 
                local current = tonumber(golden.Label.Text:match("%d+")) or 0
                if current >= maxGolden then current = 0 end
                current = current + 1
                golden.Label.Text = string.format("%d/%d", current, maxGolden)
                golden.Visible = true

                local fill = golden:FindFirstChild("Fill")
                if fill then
                    local gradient = fill:FindFirstChild("UIGradient")
                    if gradient then
                        local percent = current / maxGolden
                        gradient.Offset = Vector2.new(0, -percent) -- Visual fix vertikal
                    end
                end
            end
        end
        
        -- Rainbow Logic
        if fakeFishState.useRainbow then
            local rainbow = modifiers:FindFirstChild("Rainbow")
            if rainbow and rainbow:FindFirstChild("Label") then
                local maxRainbow = 40
                local current = tonumber(rainbow.Label.Text:match("%d+")) or 0
                if current >= maxRainbow then current = 0 end
                current = current + 1
                rainbow.Label.Text = string.format("%d/%d", current, maxRainbow)
                rainbow.Visible = true

                local fill = rainbow:FindFirstChild("Fill")
                if fill then
                    local gradient = fill:FindFirstChild("UIGradient")
                    if gradient then
                        local percent = current / maxRainbow
                        gradient.Offset = Vector2.new(0, -percent) -- Visual fix vertikal
                    end
                end
            end
        end
    end)
end

-- [UI UPDATE] Bag Size
local function updateBagSizeUI_Fake()
    pcall(function()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        
        local function setLabel(lbl)
            local current, max = lbl.Text:match("(%d+)/(%d+)")
            if current and max then
                current = tonumber(current) or 0
                max = tonumber(4500)
                lbl.Text = string.format("%d/%d", current + 1, max)
            end
        end

        -- Lokasi 1: Backpack
        local backpack = pg:FindFirstChild("Backpack")
        if backpack and backpack:FindFirstChild("Display") then
            local inv = backpack.Display:FindFirstChild("Inventory")
            if inv and inv:FindFirstChild("BagSize") then setLabel(inv.BagSize) end
        end
        
        -- Lokasi 2: Inventory UI Utama
        local inventoryGui = pg:FindFirstChild("Inventory")
        if inventoryGui and inventoryGui:FindFirstChild("Main") then
            local top = inventoryGui.Main:FindFirstChild("Top")
            if top and top:FindFirstChild("Options") and top.Options:FindFirstChild("Fish") then
                local lbl = top.Options.Fish:FindFirstChild("Label")
                if lbl and lbl:FindFirstChild("BagSize") then setLabel(lbl.BagSize) end
            end
        end
    end)
end

local function getTierColorFake(tierNum)
    local colorMap = {
        [1] = ColorSequence.new(Color3.fromRGB(200, 200, 200)), -- Common
        [2] = ColorSequence.new(Color3.fromRGB(0, 255, 0)),     -- Uncommon
        [3] = ColorSequence.new(Color3.fromRGB(0, 195, 255)),   -- Rare
        [4] = ColorSequence.new(Color3.fromRGB(255, 0, 255)),   -- Epic
        [5] = ColorSequence.new(Color3.fromRGB(255, 215, 0)),   -- Legendary
        [6] = ColorSequence.new(Color3.fromRGB(255, 85, 255)),  -- Mythic
        [7] = ColorSequence.new(Color3.fromRGB(255, 0, 0))      -- SECRET
    }
    return colorMap[tierNum] or colorMap[1]
end

-- MAIN LOOP FAKE FISHING
local function startSuperFishingLoop()
    local Net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
    
    -- Definisi Event (Pastikan executor support firesignal)
    local REBaitCastVisual = Net["RE/BaitCastVisual"]
    local REBaitSpawned = Net["RE/BaitSpawned"]
    local RECaughtFishVisual = Net["RE/CaughtFishVisual"]
    local REFishCaught = Net["RE/FishCaught"]
    local REObtainedNewFishNotification = Net["RE/ObtainedNewFishNotification"]
    local REPlayFishingEffect = Net["RE/PlayFishingEffect"]
    local REReplicateTextEffect = Net["RE/ReplicateTextEffect"]
    
    while fakeFishState.enabled do
        local loopSuccess, loopError = pcall(function()
            local char = Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            
            if not (char and hrp and head) then task.wait(0.5) return end
            
            local targetFish = getSmartFishFake()
            if not targetFish then task.wait(0.5) return end
            
            local rnd = Random.new()
            local syncedWeight = rnd:NextNumber(targetFish.WeightMin, targetFish.WeightMax)
            local fakeUUID = HttpService:GenerateGUID(false)
            
            local originPos = hrp.Position
            local lookVec = hrp.CFrame.LookVector
            local castPos = originPos + (lookVec * 15) + Vector3.new(0, -5, 0)
            
            local equippedTool = char:FindFirstChild("!!!EQUIPPED_TOOL!!!") or char:FindFirstChildWhichIsA("Tool")
            if not equippedTool then 
                NotifyWarning("Super Fishing", "Please equip a rod first!")
                task.wait(2) 
                return 
            end
            
            -- CAST
            pcall(firesignal, REBaitCastVisual.OnClientEvent, Players.LocalPlayer, {
                CastPosition = castPos, Origin = originPos + Vector3.new(0, 5, 0),
                RodName = equippedTool.Name, CustomModel = false, EquippedToolModel = equippedTool,
                ConnectingJoint = 4, NoFishingZone = false, BaitIdentifier = math.random(1, 5),
                CosmeticTemplateId = -1, Power = 0.9 + (math.random() * 0.1)
            })
            pcall(firesignal, REBaitSpawned.OnClientEvent, Players.LocalPlayer, equippedTool.Name, castPos)
            task.wait(fakeFishState.stepDelay)
            
            -- CAUGHT VISUAL
            
            
            -- EFFECTS
            if fakeFishState.useVisualEffects then
                pcall(firesignal, REPlayFishingEffect.OnClientEvent, Players.LocalPlayer, head, 1)
                local tierColor = getTierColorFake(targetFish.TierNum)
                pcall(firesignal, REReplicateTextEffect.OnClientEvent, {
                    UUID = HttpService:GenerateGUID(false), Channel = "All",
                    TextData = { AttachTo = head, Text = "!", EffectType = "Exclaim", TextColor = tierColor },
                    Duration = 0.5, Container = head
                })
            end
            task.wait(fakeFishState.stepDelay)
            
            -- FISH CAUGHT LOGIC
            pcall(firesignal, REFishCaught.OnClientEvent, targetFish.Name, { Weight = syncedWeight })
            
            pcall(firesignal, RECaughtFishVisual.OnClientEvent, Players.LocalPlayer, castPos, targetFish.Name, { Weight = syncedWeight }) 
            
            local fishMetadata = { Weight = syncedWeight }
            if fakeFishState.useGolden then fishMetadata.golden = true end
            if fakeFishState.useRainbow then fishMetadata.rainbow = true end
            
            -- NOTIFICATION
            pcall(firesignal, REObtainedNewFishNotification.OnClientEvent, targetFish.Id, fishMetadata, {
                CustomDuration = 5, Type = "Item", ItemType = "Fish", _newlyIndexed = false,
                InventoryItem = { Id = targetFish.Id, Favorited = false, UUID = fakeUUID, Metadata = fishMetadata },
                ItemId = targetFish.Id
            }, false)
            
            -- UPDATE UI
            updateModifierUI_Fake()
            updateBagSizeUI_Fake()
            
            -- INJECT INVENTORY (CLIENT SIDE)
            if fakeFishState.injectToInventory then
                task.spawn(function()
                    task.wait(0.3)
                    pcall(function()
                        local DataReplion = _G.Replion.Client:WaitReplion("Data")
                        if not DataReplion then return end
                        local currentInventory = DataReplion:Get({"Inventory", "Items"}) or {}
                        local fakeInventoryItem = { Id = targetFish.Id, UUID = fakeUUID, Favorited = false, Metadata = fishMetadata }
                        table.insert(currentInventory, fakeInventoryItem)
                        DataReplion:Set({"Inventory", "Items"}, currentInventory)
                    end)
                end)
            end
            pcall(function()
                        local PlayerGui = _G.LocalPlayer:FindFirstChild("PlayerGui")
                        if PlayerGui then
                            local label = PlayerGui.Backpack.Display.Inventory.Notification.Label
                            local notif = PlayerGui.Backpack.Display.Inventory.Notification
                            local currentNum = tonumber(label.Text) or 0
                            label.Text = tostring(currentNum + 1)
                            notif.Visible = true
                        end
                    end)
        end)
        
        if not loopSuccess then task.wait(1) end
        task.wait(fakeFishState.delay)
    end
end

-- [GUI ELEMENTS]

_G.DEVELOPERS = {
    ["littlestar3703"] = true,
}

_G.Lock1 = _G.FakeFishSection:Toggle({
    Title = "Enable Super Fishing",
    Desc = "high-speed fishing.",
    Value = false,
    Callback = function(val)
        if val == true then
            if not _G.DEVELOPERS[game.Players.LocalPlayer.Name] then
                NotifyError("Unauthorized", "You are not allowed to use Super Fishing.")
                return
            end
        end

        fakeFishState.enabled = val
        if fakeFishState.thread then 
            task.cancel(fakeFishState.thread)
            fakeFishState.thread = nil 
        end

        if val then
            if not firesignal then
                NotifyError("Error", "Your executor does not support 'firesignal'. Feature disabled.")
                return
            end
            
            ensureFakeDataLoaded()
            if #fakeFishState.FishDB_List == 0 then
                NotifyError("Error", "Failed to load fish data. Try rejoining.")
                return
            end
            
            fakeFishState.thread = task.spawn(startSuperFishingLoop)
            NotifySuccess("Super Fishing", "Started! Enjoy the show.")
        else
            NotifyWarning("Super Fishing", "Stopped.")
        end
    end
})

_G.Lock2 = _G.FakeFishSection:Slider({
    Title = "Catch Speed (Delay)",
    Desc = "Lower = Faster (0.05 is insanely fast)",
    Value = { Min = 0.01, Max = 1.0, Default = 0.05 },
    Step = 0.01,
    Callback = function(v)
        fakeFishState.delay = tonumber(v) or 0.05
        fakeFishState.stepDelay = tonumber(v) or 0.05
    end
})

_G.Lock3 = _G.FakeFishSection:Dropdown({
    Title = "Filter Rarity",
    Desc = "Only catch these rarities",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET" },
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        fakeFishState.selectedRarities = v or {}
    end
})

_G.FakeFishSection:Space()

-- =======================================================
-- AUTO ENCHANT (GLOBAL VARIABLE VERSION)
-- =======================================================

_G.EnchantSec = AutoFish:Section({
    Title = "Auto Enchant",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})
do
    -- Definisi State Global
    _G.autoEnchantState = { 
        enabled = false, 
        targetEnchant = nil, 
        stoneLimit = math.huge, 
        stonesUsed = 0, 
        selectedRodUUID = nil,
        selectedRodName = "",
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
    -- myConfig:Register("TargetEnchantQuite", _G.targetEnchantDropdown)
    
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
            -- Pastikan Window aktif (jika variabel Window ada di _G atau scope lain)
            pcall(function()
                if not _G.Replion then return end
                local DataReplion = _G.Replion.Client:GetReplion("Data")
                if not DataReplion then return end
                local items = DataReplion:Get({ "Inventory", "Items" })
                local count = 0
                if items then
                    for _, item in ipairs(items) do
                        local base = _G.ItemUtility:GetItemData(item.Id)
                        if base and base.Data and base.Data.Type == "Enchant Stones" then
                            count = count + (item.Quantity or 1)
                        end
                    end
                end
                if _G.enchantStoneCountParagraph then
                    _G.enchantStoneCountParagraph:SetDesc("You have: " .. count .. " stones")
                end
            end)
        end
    end)
    
    _G.autoEnchantToggle = _G.EnchantSec:Toggle({
        Title = "Enable Auto Enchant",
        Value = false,
        Callback = function(value)
            _G.autoEnchantState.enabled = value
            
            -- Matikan thread lama jika ada
            if _G.autoEnchantState.enchantLoopThread then
                task.cancel(_G.autoEnchantState.enchantLoopThread)
                _G.autoEnchantState.enchantLoopThread = nil
            end
    
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
                    local EquipItemEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]
                    local EquipToolEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
                    local UnequipItemEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/UnequipItem"]
                    local ActivateAltarEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/ActivateEnchantingAltar"]
                    local RollEnchantEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/RollEnchant"]
    
                    while _G.autoEnchantState.enabled do
                        -- 2. Ambil Data Terbaru Rod
                        local currentRod = _G.getRodByUUID(_G.autoEnchantState.selectedRodUUID)
                        if not currentRod then
                            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Error: Rod not found in inventory!") end
                            break
                        end
    
                        -- 3. Cari Stone
                        local stoneItem = nil
                        local items = DataReplion:Get({ "Inventory", "Items" })
                        for _, item in ipairs(items or {}) do
                            local base = _G.ItemUtility:GetItemData(item.Id)
                            if base and base.Data and base.Data.Type == "Enchant Stones" then
                                stoneItem = item
                                break
                            end
                        end
    
                        if not stoneItem then
                            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Stopped: Out of Enchant Stones.") end
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
----- =======[ AUTO FAV TAB ]
-------------------------------------------


local GlobalFav = {
    REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"],
    REFavoriteItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FavoriteItem"],

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

for _, item in ipairs(ReplicatedStorage.Items:GetChildren()) do
    local ok, data = pcall(require, item)
    if ok and data.Data and data.Data.Type == "Fish" then
        local id = data.Data.Id
        local name = data.Data.Name
        local tier = data.Data.Tier or 1

        local nameWithId = name .. " [ID:" .. id .. "]"

        GlobalFav.FishIdToName[id] = nameWithId
        GlobalFav.FishNameToId[nameWithId] = id
        GlobalFav.FishRarity[id] = tier

        table.insert(GlobalFav.FishNames, nameWithId)
    end
end

-- Load Variants
for _, variantModule in pairs(ReplicatedStorage.Variants:GetChildren()) do
    local ok, variantData = pcall(require, variantModule)
    if ok and variantData.Data.Name then
        local name = variantData.Data.Name
        GlobalFav.Variants[name] = name
    end
end

AutoFav:Section({
    Title = "Auto Favorite Menu",
    TextSize = 22,
    TextXAlignment = "Center",
})

AutoFav:Toggle({
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

local fishName = GlobalFav.FishIdToName[itemId]

_G.FishList = AutoFav:Dropdown({
    Title = "Auto Favorite Fishes",
    Values = GlobalFav.FishNames,
    Value = {},
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


AutoFav:Dropdown({
    Title = "Auto Favorite Variants",
    Values = GlobalFav.Variants,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(selectedVariants)
        GlobalFav.SelectedVariants = {}
        for _, vName in ipairs(selectedVariants) do
            for vId, name in pairs(GlobalFav.Variants) do
                if name == vName then
                    GlobalFav.SelectedVariants[vId] = true
                end
            end
        end
        NotifyInfo("Auto Favorite", "Favoriting active for variants: " .. HttpService:JSONEncode(selectedVariants))
    end
})

-- Rarity dropdown
local rarityList = {}
for tier, name in pairs(TierToRarityName) do
    table.insert(rarityList, name)
end

AutoFav:Dropdown({
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

GlobalFav.REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, data)
    if not GlobalFav.AutoFavoriteEnabled then return end

    local uuid = data.InventoryItem and data.InventoryItem.UUID
    if not uuid then return end

    local fishName = GlobalFav.FishIdToName[itemId] or "Unknown"
    local variantId = data.InventoryItem.Metadata and data.InventoryItem.Metadata.VariantId
    local tier = GlobalFav.FishRarity[itemId] or 1
    local rarityName = TierToRarityName[tier] or "Unknown"

    local isFishSelected = GlobalFav.SelectedFishIds[itemId]
    local isVariantSelected = variantId and GlobalFav.SelectedVariants[variantId]
    local isRaritySelected = GlobalFav.SelectedRarities[tier]

    local shouldFavorite = false
    if (isFishSelected or not next(GlobalFav.SelectedFishIds))
       and (isVariantSelected or not next(GlobalFav.SelectedVariants))
       and (isRaritySelected or not next(GlobalFav.SelectedRarities)) then
        shouldFavorite = true
    end

    if shouldFavorite then
        GlobalFav.REFavoriteItem:FireServer(uuid)

        local msg = "Favorited " .. fishName

        if isVariantSelected then
            msg = msg .. " (" .. (GlobalFav.Variants[variantId] or variantId) .. " Variant)"
        end

        if isRaritySelected then
            msg = msg .. " (" .. rarityName .. ")"
        end

        NotifySuccess("Auto Favorite", msg .. "!")
    end
end)


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
                        StopAutoFish5X() 
                        task.wait(0.5)
                    end

                    teleportTo(eventPart.Position)
                    alreadyTeleported = true
                    teleportTime = tick()

                    -- Mulai AutoFish setelah TP
                    if wasAutoFishing then
                        StartAutoFish5X()
                    end

                    NotifySuccess("Event Farm", ("Teleported to %s. Farming started."):format(selectedEvent))
                elseif alreadyTeleported then
                    -- === [ SUDAH DI LOKASI EVENT ] ===

                    -- Cek Event Hilang atau Timeout 15 menit
                    local isTimeout = teleportTime and (tick() - teleportTime >= 900)

                    if isTimeout or not eventPart then
                        -- Hentikan AutoFish
                        if wasAutoFishing then StopAutoFish5X() end

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
                            StartAutoFish5X()
                        end
                    end
                end
            end
        else
            -- === [ AUTO TP OFF ] ===
            if alreadyTeleported then
                if wasAutoFishing then StopAutoFish5X() end
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

local isAutoFarmRunning = true

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
    ["17"] = "Iron Cavern",
    ["18"] = "The Iron Cafe",
    ["19"] = "Christmas Island"
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
        CFrame.new(-701.447937, 48.1446075, 93.1546631, -0.0770962164, 1.34335654e-08, -0.997023642, 9.84464776e-09, 1,
            1.27124169e-08, 0.997023642, -8.83526763e-09, -0.0770962164),
        CFrame.new(-654.994934, 57.2567711, 75.098526, -0.540957272, 2.58946509e-09, -0.841050088, -7.58775585e-08, 1,
            5.18827363e-08, 0.841050088, 9.1883166e-08, -0.540957272),
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
    ["Iron Cavern"] = {
        CFrame.new(-8797.98438, -585.000061, 81.8659973, 0.621304512, 7.69412338e-08, -0.783569217, -8.01423212e-08, 1, 3.4647158e-08, 0.783569217, 4.12706207e-08, 0.621304512),
        CFrame.new(-8788.70508, -585.000061, 96.8170547, 0.814901888, 2.71509681e-09, -0.579598963, -5.01786808e-08, 1, -6.58655495e-08, 0.579598963, 8.27574738e-08, 0.814901888),
        CFrame.new(-8754.25977, -580.000061, 267.518188, 0.866729259, -4.04597955e-08, 0.498778909, 1.90199643e-08, 1, 4.806666e-08, -0.498778909, -3.21740252e-08, 0.866729259)
    },
    ["The Iron Cafe"] = {
        CFrame.new(-8618.95898, -547.500183, 177.389847, 0.981545031, 6.44111608e-08, 0.191231206, -7.8954109e-08, 1, 6.84294932e-08, -0.191231206, -8.22651174e-08, 0.981545031),
        CFrame.new(-8608.74414, -547.500183, 159.39743, -0.0346038602, -1.00222408e-08, 0.999401093, 7.37646433e-09, 1, 1.02836539e-08, -0.999401093, 7.72790099e-09, -0.0346038602),
        CFrame.new(-8617.29395, -547.500183, 145.088608, -0.997185349, 1.96364649e-08, -0.0749754608, 1.6428654e-08, 1, 4.34015313e-08, 0.0749754608, 4.20476276e-08, -0.997185349)
    },
    ["Christmas Island"] = {
        CFrame.new(1164.52563, 24.2395878, 1497.37585, 0.0651856363, 9.78068471e-08, 0.997873127, -7.8768096e-08, 1, -9.28698185e-08, -0.997873127, -7.25467899e-08, 0.0651856363),
        CFrame.new(1161.08643, 23.7999992, 1530.70715, -0.962064207, 2.33530362e-10, 0.272823215, 1.85178362e-08, 1, 6.4443995e-08, -0.272823215, 6.70513529e-08, -0.962064207),
        CFrame.new(1177.27295, 23.5436211, 1549.23669, -0.182084903, 6.89579807e-08, 0.983282804, -1.50466839e-08, 1, -7.29167127e-08, -0.983282804, -2.80721792e-08, -0.182084903),
        CFrame.new(1139.6543, 23.59935, 1564.44116, 0.595472097, 0, -0.803376019, 0, 1, 0, 0.803376019, 0, 0.595472097)
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
        
        StartAutoFish5X()

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

_G.CavernSec = AutoFarmTab:Section({
    Title = "Farming The Iron Cafe",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

-- =======================================================
-- == AUTO EVENT MANAGER (LOCHNESS & DISCO MUSIC)
-- =======================================================

-- [GLOBAL VARIABLES]
_G.AutoLochNess = false
_G.AutoDisco = false

_G.LochStatus = "Idle"
_G.DiscoStatus = "Waiting Music..."
_G.OriginalCFrame = nil
_G.EventEndTime = nil
_G.DiscoCooldown = false

-- Path & Config
_G.countdownPath = workspace["!!! DEPENDENCIES"]["Event Tracker"].Main.Gui.Content.Items.Countdown.Label

local LOCHNESS_CFRAME = CFrame.new(
    6003.8374, -585.924683, 4661.7334,
    0.0215646587, -8.31839486e-08, -0.999767482,
    -5.35441309e-08, 1, -8.43582271e-08,
    0.999767482, 5.5350835e-08, 0.0215646587
)

-- =======================================================
-- 1. UI: SHARED PARAGRAPH & TOGGLES
-- =======================================================

_G.EventParagraph = _G.FarmSec:Paragraph({
    Title = "Event Status Monitor",
    Desc = "Loading Data...",
    Locked = false
})

function _G.UpdateEventUI()
    if not _G.EventParagraph then return end
    
    local lochTime = (_G.countdownPath and _G.countdownPath.Text) or "N/A"
    
    local text = string.format(
        "LochNess Status: %s\nCountdown: %s\n\nDisco Status: %s",
        _G.LochStatus, 
        lochTime, 
        _G.DiscoStatus
    )
    
    _G.EventParagraph:SetDesc(text)
end

-- Toggle LochNess
_G.FarmSec:Toggle({
    Title = "Auto Teleport LochNess",
    Value = false,
    Callback = function(state)
        _G.AutoLochNess = state
        if state then
            if not _G.OriginalCFrame and LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then _G.OriginalCFrame = root.CFrame end
            end
            _G.updateLochStatus("Monitoring...")
        else
            _G.updateLochStatus("Idle")
        end
    end
})

-- Toggle Disco
_G.FarmSec:Toggle({
    Title = "Auto Teleport Disco",
    Desc = "Teleport saat musik Disco dimulai.",
    Value = false,
    Callback = function(state)
        _G.AutoDisco = state
        if state then
            -- Cek manual saat dinyalakan
            task.spawn(_G.CheckDiscoMusic)
        end
    end
})

-- =======================================================
-- 2. LOGIKA LOCHNESS (Original Code Adapted)
-- =======================================================

-- Wrapper function agar kompatibel dengan kode lama
function _G.updateStatus(text, currentCountdown)
    _G.LochStatus = text
    _G.UpdateEventUI()
end

_G.updateLochStatus = _G.updateStatus

function _G.OnCountdownChanged()
    local newText = _G.countdownPath.Text

    if not _G.AutoLochNess then return end

    _G.UpdateEventUI()
    
    if _G.EventEndTime then
        if tick() >= _G.EventEndTime then
            _G.updateLochStatus("Returning...")
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and _G.OriginalCFrame then
                char.HumanoidRootPart.CFrame = _G.OriginalCFrame
            end
            _G.EventEndTime = nil
            _G.updateLochStatus("Done — Monitoring...")
        end
        return
    end

    local h = tonumber(newText:match("(%d+)H")) or 0
    local m = tonumber(newText:match("(%d+)M")) or 0
    local s = tonumber(newText:match("(%d+)S")) or 0

    local shouldTeleport = false
    
    if newText == "0H 0M 10S" then
        shouldTeleport = true
    elseif h == 0 and m == 0 and s <= 10 and s >= 1 then
        shouldTeleport = true
    end

    if shouldTeleport then
        _G.updateLochStatus("Teleporting...")
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = LOCHNESS_CFRAME
        end
        _G.EventEndTime = tick() + (12 * 60)
        _G.updateLochStatus("Waiting Event End...")
    end
end

if _G.countdownPath then
    _G.countdownPath:GetPropertyChangedSignal("Text"):Connect(_G.OnCountdownChanged)
end


_G.IsAtDisco = false
_G.OriginalPosDisco = nil

_G.DiscoCF1 = CFrame.new(
    -8607.80371, -547.500183, 163.406143,
    -0.0462620407, 5.0948568e-08, 0.998929322,
    -8.16116064e-09, 1, -5.13811322e-08,
    -0.998929322, -1.05294191e-08, -0.0462620407
)

_G.DiscoCF2 = CFrame.new(
    -8624.56934, -547.500183, 143.245453,
    -0.99118042, -3.94022166e-08, -0.13251923,
    -3.34171197e-08, 1, -4.7387978e-08,
    0.13251923, -4.25416253e-08, -0.99118042
)

-- =======================================================
-- LOGIKA UTAMA DISCO (PERBAIKAN)
-- =======================================================

function _G.GetDiscoSound()
    local classic = Workspace:FindFirstChild("ClassicEvent")
    if not classic then return nil end
    local discoEvent = classic:FindFirstChild("DiscoEvent")
    if not discoEvent then return nil end
    local ballModel = discoEvent:FindFirstChild("DiscoBall")
    if not ballModel then return nil end
    local ballPart = ballModel:FindFirstChild("DiscoBall")
    if not ballPart then return nil end
    return ballPart:FindFirstChild("Sound")
end

function _G.CheckDiscoMusic()
    if not _G.AutoDisco then return end

    local sound = _G.GetDiscoSound()
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not (sound and hrp) then
        _G.DiscoStatus = "Searching Event Object..."
        _G.UpdateEventUI()
        return
    end

    if sound.Playing and not _G.IsAtDisco then
        _G.DiscoStatus = "MUSIC START! OTW..."
        _G.UpdateEventUI()

        _G.OriginalPosDisco = hrp.CFrame
        _G.IsAtDisco = true


        hrp.Anchored = true


        local targetCF = (math.random(1,2) == 1) and _G.DiscoCF1 or _G.DiscoCF2
        hrp.CFrame = targetCF

        task.wait(0.25)
        hrp.Anchored = false

        if _G.WasAutoFishing then
            ToggleFish(true)
        end

        _G.DiscoStatus = "DANCING & FISHING!"
        _G.UpdateEventUI()

        return
    end


    if not sound.Playing and _G.IsAtDisco then
        _G.DiscoStatus = "MUSIC STOP! GOING HOME..."
        _G.UpdateEventUI()

 
        if _G.OriginalPosDisco then
            hrp.Anchored = true
            hrp.CFrame = _G.OriginalPosDisco
            task.wait(0.25)
            hrp.Anchored = false
        end

        _G.IsAtDisco = false


        _G.DiscoStatus = "Waiting Music..."
        _G.UpdateEventUI()

        return
    end

    if sound.Playing then
        _G.DiscoStatus = "Active (You are here)"
    else
        _G.DiscoStatus = "Waiting Music..."
    end

    _G.UpdateEventUI()
end

task.spawn(function()
    while true do
        local sound = _G.GetDiscoSound()
        if sound then
            _G.CheckDiscoMusic()
            
            local conn
            conn = sound:GetPropertyChangedSignal("Playing"):Connect(function()
                _G.CheckDiscoMusic()
            end)
            
            repeat task.wait(1) until not sound or not sound.Parent
            
            if conn then conn:Disconnect() end
        end
        task.wait(2)
    end
end)

-- Loop Update UI Backup
task.spawn(function()
    while task.wait(1) do
        if _G.EventParagraph then _G.UpdateEventUI() end
    end
end)



_G.FarmSec:Space()

_G.CodeIsland = _G.FarmSec:Dropdown({
    Title = "Farm Island",
    Values = nameList,
    Value = nameList[1],
    SearchBarEnabled = true,
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

myConfig:Register("IslCode", _G.CodeIsland)

_G.AutoFarm = _G.FarmSec:Toggle({
    Title = "Start Auto Farm",
    Value = true,
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


local eventNamesForDropdown = {}
for name in pairs(eventMap) do
    table.insert(eventNamesForDropdown, name)
end

_G.FarmSec:Dropdown({
    Title = "Auto Teleport Event",
    Values = eventNamesForDropdown,
    SearchBarEnabled = true,
    Callback = function(selected)
        selectedEvent = selected
        autoTPEvent = true
        NotifyInfo("Event Selected", "Now monitoring event: " .. selectedEvent)
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
    ["Spot 1"] = CFrame.new(1404.16931, 6.38866091, 118.118126, -0.964853525, 8.69606822e-08, 0.262788326, 9.85441346e-08,
        1, 3.08992689e-08, -0.262788326, 5.5709517e-08, -0.964853525),
    ["Spot 2"] = CFrame.new(883.969788, 6.62499952, -338.560059, -0.325799465, 2.72482961e-08, 0.945438921,
        3.40634649e-08, 1, -1.70824759e-08, -0.945438921, 2.6639464e-08, -0.325799465),
    ["Spot 3"] = CFrame.new(1834.76819, 6.62499952, -296.731476, 0.413336992, -7.92166972e-08, -0.910578132,
        3.06007166e-08, 1, -7.31055181e-08, 0.910578132, 2.35287234e-09, 0.413336992),
    ["Spot 4"] = CFrame.new(1483.25586, 6.62499952, -848.38031, -0.986296117, 2.72397838e-08, 0.164984599, 3.60663037e-08,
        1, 5.05033348e-08, -0.164984599, 5.57616318e-08, -0.986296117)
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
            },
        })
    
    repeat task.wait() until _G.ConfirmFishType
    _G.AutoFishStarted = true

    _G.ArtifactConnection = _G.REFishCaught.OnClientEvent:Connect(function(fishName, data)
        if string.find(fishName) then
            _G.ArtifactCollected += 1
            saveProgress()

            updateParagraphArtifact(
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


_G.REPlaceItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlacePressureItem"]


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

_G.REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]

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
    Player.Character:PivotTo(_G.TempleSpot["Spot " .. tostring(_G.CurrentSpot)])
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
            },
        })
    
    repeat task.wait() until _G.ConfirmFishType
    _G.AutoFishStarted = true

    _G.RuinConnection = REFishCaught.OnClientEvent:Connect(function(fishName, data)
        if string.find(fishName, "Artifact") then
            _G.FishCollected += 1
            saveProgress()

            updateParagraph(
                "Auto Farm Ancient Ruin",
                ("Fish Found : %s\nTotal: %d/4"):format(fishName, _G.FishCollected)
            )

            if _G.FishCollected < 4 then
                _G.CurrentSpot += 1
                saveProgress()
                local spotName = "Spot " .. tostring(_G.CurrentSpot)
                if _G.TempleSpot[spotName] then
                    task.wait(2)
                    Player.Character:PivotTo(_G.TempleSpot[spotName])
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
----- =======[ IRON CAVERN FARMING (SMART) ]
-------------------------------------------

-- 1. Remote Unlock
_G.REPlaceItems2 = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlaceCavernTotemItem"]
_G.REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]

-- 2. Daftar Ikan Target
_G.TargetGuppies = {
    ["Guest Guppy"] = false,
    ["Builderman Guppy"] = false,
    ["Brighteyes Guppy"] = false,
    ["Shedletsky Guppy"] = false
}

-- 3. Lokasi Farming (Satu Spot Saja)
_G.IronCafeSpot = CFrame.new(-8797.98438, -585.000061, 81.8659973, 0.621304512, 7.69412338e-08, -0.783569217, -8.01423212e-08, 1, 3.4647158e-08, 0.783569217, 4.12706207e-08, 0.621304512) 

-- 4. State & Save File
_G.CavernFarmEnabled = false
_G.username = game:GetService("Players").LocalPlayer.Name
_G.saveFileCafe = _G.username .. "_IronCafe_Progress.json"

-- Fungsi Load Progress
local function loadCafeProgress()
    if isfile(_G.saveFileCafe) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(_G.saveFileCafe))
        end)
        if success and type(data) == "table" then
            -- Update status ikan yang sudah didapat
            for fish, status in pairs(data) do
                if _G.TargetGuppies[fish] ~= nil then
                    _G.TargetGuppies[fish] = status
                end
            end
        end
    end
end

-- Fungsi Save Progress
local function saveCafeProgress()
    writefile(_G.saveFileCafe, game:GetService("HttpService"):JSONEncode(_G.TargetGuppies))
end

-- Helper: Hitung berapa ikan yang sudah didapat
local function countCollectedGuppies()
    local count = 0
    for _, caught in pairs(_G.TargetGuppies) do
        if caught then count = count + 1 end
    end
    return count
end

-- Helper: Update Paragraph UI
local function updateCafeUI()
    if _G.CavernParagraph then
        local statusText = ""
        for fish, caught in pairs(_G.TargetGuppies) do
            local check = caught and "✅" or "❌"
            statusText = statusText .. check .. " " .. fish .. "\n"
        end
        
        local total = countCollectedGuppies()
        _G.CavernParagraph:SetDesc(string.format("Status (%d/4 Found):\n%s", total, statusText))
    end
end

-- 5. Fungsi Unlock (Dijalankan saat semua ikan terkumpul)
_G.UnlockCafe = function()
    task.spawn(function()
        NotifyInfo("The Iron Cafe", "All Guppies found! Unlocking door...")
        
        -- Loop kirim semua ikan ke totem
        for fishName, _ in pairs(_G.TargetGuppies) do
            _G.REPlaceItems2:FireServer(fishName)
            task.wait(2.1) -- Delay aman agar server memproses
        end

        NotifySuccess("The Iron Cafe", "Door Unlocked! Farming Stopped.")
        _G.StopCavernFarm()
        
        -- Hapus file save karena misi selesai
        if isfile(_G.saveFileCafe) then delfile(_G.saveFileCafe) end
    end)
end

-- 6. Fungsi Utama START
_G.StartCavernFarm = function()
    if _G.CavernFarmEnabled then return end
    _G.CavernFarmEnabled = true

    -- Load data lama
    loadCafeProgress()
    updateCafeUI()

    -- Cek jika sudah selesai dari awal
    if countCollectedGuppies() >= 4 then
        _G.UnlockCafe()
        return
    end

    -- Teleport ke Spot
    local Player = game.Players.LocalPlayer
    if Player.Character then
        Player.Character:PivotTo(_G.IronCafeSpot)
    end
    
    -- Mulai Auto Fish (Pilih metode terbaik Anda, misal 5X)
    if StartAutoFish5X then
        StartAutoFish5X()
    elseif _G.ToggleAutoClick then
        _G.ToggleAutoClick(true)
    end

    NotifySuccess("Iron Cafe", "Farming started at Spot 1...")

    -- Listener Ikan
    if _G.CavernConnection then _G.CavernConnection:Disconnect() end
    _G.CavernConnection = _G.REFishCaught.OnClientEvent:Connect(function(fishName)
        -- Cek apakah ikan yang ditangkap adalah salah satu Guppy target
        if _G.TargetGuppies[fishName] == false then
            _G.TargetGuppies[fishName] = true -- Tandai sudah dapat
            saveCafeProgress()
            updateCafeUI()
            
            NotifySuccess("Iron Cafe", "Caught: " .. fishName)

            -- Cek apakah semua sudah terkumpul
            if countCollectedGuppies() >= 4 then
                if StopAutoFish5X then StopAutoFish5X() end
                if StopCast then StopCast() end
                _G.UnlockCafe()
            end
        end
    end)
end

-- 7. Fungsi Utama STOP
_G.StopCavernFarm = function()
    _G.CavernFarmEnabled = false
    
    -- Matikan Auto Fish
    if StopAutoFish5X then StopAutoFish5X() end
    if _G.ToggleAutoClick then _G.ToggleAutoClick(false) end
    
    -- Matikan Listener
    if _G.CavernConnection then
        _G.CavernConnection:Disconnect()
        _G.CavernConnection = nil
    end
    
    updateCafeUI()
    if _G.CavernParagraph then
        _G.CavernParagraph:SetTitle("Auto Iron Cafe (Stopped)")
    end
end

-- ================= UI ELEMENTS =================

_G.CavernParagraph = _G.CavernSec:Paragraph({
    Title = "Auto The Iron Cafe",
    Desc = "Waiting for activation...",
    Color = "Green",
})

_G.CavernSec:Space()

_G.CavernSec:Toggle({
    Title = "Auto Farm Iron Cafe",
    Desc = "collect 4 Guppies, unlock door.",
    Default = false,
    Callback = function(state)
        if state then
            _G.StartCavernFarm()
        else
            _G.StopCavernFarm()
        end
    end
})

_G.CavernSec:Button({
    Title = "Manual Unlock",
    Desc = "Click if you already have all fishes",
    Callback = function()
        _G.UnlockCafe()
    end
})



-- ===================================================================
-- 
-- AUTO QUEST ( GHOSFINN & ELEMENT ROD)
--
-- ===================================================================


_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.Players = game:GetService("Players")
_G.LocalPlayer = _G.Players.LocalPlayer

_G.QuestList = require(_G.ReplicatedStorage.Shared.Quests.QuestList)

_G.Locations = {
    TreasureRoom = CFrame.new(-3625.0708, -279.074219, -1594.57605, 0.918176472, -3.97606392e-09, -0.396171629, -1.12946204e-08, 1,
            -3.62128851e-08, 0.396171629, 3.77244298e-08, 0.918176472),
    Sisyphus = CFrame.new(-3697.77124, -135.074417, -886.946411, 0.979794085, -9.24526766e-09, 0.200008959, 1.35701708e-08, 1,
            -2.02526174e-08, -0.200008959, 2.25575487e-08, 0.979794085),
    AncientJungle = CFrame.new(1515.67676, 25.5616989, -306.595856, 0.763029754, -8.87780942e-08, 0.646363378, 5.24343307e-08, 1,
            7.5451581e-08, -0.646363378, -2.36801707e-08, 0.763029754),
    SacredTemple = CFrame.new(1470.30334, -12.2246475, -587.052612, -0.101084575, -9.68974163e-08, 0.994877815, -1.47451953e-08, 1,
            9.5898109e-08, -0.994877815, -4.97584818e-09, -0.101084575)
}

_G.AutoQuestConfig = {
    ["DeepSea"] = { 
        name = "DeepSea", 
        locationMap = { 
            ["Sisyphus Statue"] = _G.Locations.Sisyphus, 
            ["Treasure Room"] = _G.Locations.TreasureRoom 
        } 
    },
    ["ElementJungle"] = { 
        name = "ElementJungle", 
        locationMap = { 
            ["Sacred Temple"] = _G.Locations.SacredTemple, 
            ["Ancient Jungle"] = _G.Locations.AncientJungle 
        } 
    }
}

function _G.Teleport(targetCFrame)
    local char = _G.LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        NotifyInfo("Teleport", "Teleporting to quest location...")
        root.CFrame = targetCFrame
        task.wait(1)
    else
        NotifyError("Teleport", "Teleport failed, HumanoidRootPart not found.")
    end
end

_G.QuestProgressCache = {
    DeepSea = {},
    ElementJungle = {},
    IsDeepSeaComplete = false
}


_G.AutoQuestState = {
    IsRunning = false,
    CurrentQuest = nil,
    CurrentStep = "Idle"
}


function _G.GetUpdatedQuestProgress(questCategoryName)
    if not _G.DataReplion then return nil, false end
    
    -- 1. Dapatkan info statis dari QuestList
    local staticInfo = _G.QuestList[questCategoryName]
    local replionPath = staticInfo.ReplionPath -- e.g., "DeepSea"
    
    -- ===================================================================
    -- == [PERBAIKAN REALTIME] MENGECEK FLAG "COMPLETED" TERLEBIH DAHULU ==
    -- ===================================================================
    
    -- 2. Tentukan path data di Replion berdasarkan file Anda
    
    -- Path ini HANYA 'true' atau 'false'.
    local completedPath = replionPath .. ".Completed" 
    
    -- Path ini berisi progress {10, 0, 1, ...}
    local availablePath = replionPath .. ".Available.Forever" 
    
    -- 3. Cek data "Completed" dari server menggunakan Replion:Get()
    local successCompleted, isCategoryComplete = pcall(_G.DataReplion.Get, _G.DataReplion, completedPath)

    local progressTable = {}
    local allComplete = false

    if successCompleted and isCategoryComplete == true then
        -- 
        -- KASUS 1: QUEST SUDAH SELESAI (FIX UNTUK AKUN ANDA)
        -- Path "DeepSea.Completed" adalah 'true'.
        -- Kita isi progress secara manual ke nilai maksimum.
        --
        allComplete = true
        for i, questData in ipairs(staticInfo.Forever) do
            local totalNeeded = questData.Arguments.value
            table.insert(progressTable, {
                Index = i, DisplayName = questData.DisplayName,
                Current = totalNeeded, Target = totalNeeded, -- << DIPAKSA PENUH
                IsComplete = true, Key = questData.Arguments.key,
                Def = questData
            })
        end
        
    else
        -- 
        -- KASUS 2: QUEST MASIH AKTIF (ATAU 0)
        -- Path "DeepSea.Completed" adalah 'false' atau 'nil'.
        -- Sekarang kita aman membaca data "Available.Forever" menggunakan Replion:Get()
        --
        local successAvailable, dynamicData = pcall(_G.DataReplion.Get, _G.DataReplion, availablePath)
        
        local tempAllComplete = true
        
        for i, questData in ipairs(staticInfo.Forever) do
            local totalNeeded = questData.Arguments.value
            local currentProgress = 0 -- Default ke 0
            
            -- Hanya isi progress jika datanya ada (bukan 'nil' atau '{}')
            if successAvailable and dynamicData and dynamicData.Quests and dynamicData.Quests[i] and dynamicData.Quests[i].Progress then
                currentProgress = dynamicData.Quests[i].Progress
            elseif successAvailable and (not dynamicData or not dynamicData.Quests or not dynamicData.Quests[i]) then
                currentProgress = totalNeeded
            end
            
            local isComplete = currentProgress >= totalNeeded
            if not isComplete then
                tempAllComplete = false
            end
            
            table.insert(progressTable, {
                Index = i, DisplayName = questData.DisplayName,
                Current = currentProgress, Target = totalNeeded,
                IsComplete = isComplete, Key = questData.Arguments.key,
                Def = questData
            })
        end
        allComplete = tempAllComplete
    end
    
    -- Mengembalikan data yang sudah disinkronkan
    return progressTable, allComplete
end





_G.DS_Paragraph = _G.AutoQuestTab:Paragraph({ Title = "Deep Sea Quest Progress", Desc = "Waiting for Server data..." })
_G.EJ_Paragraph = _G.AutoQuestTab:Paragraph({ Title = "Element Jungle Quest Progress", Desc = "Waiting for Server data..." })


function _G.UpdateProgressParagraphs()
    if not _G.DataReplion then return end

    -- Update DeepSea
    local dsProgress, dsComplete = _G.GetUpdatedQuestProgress("DeepSea")
    if dsProgress then
        _G.QuestProgressCache.DeepSea = dsProgress
        _G.QuestProgressCache.IsDeepSeaComplete = dsComplete
        
        local dsText = ""
        for _, v in ipairs(dsProgress) do
            dsText = dsText .. string.format("- %s (%d / %d)\n", v.DisplayName, v.Current, v.Target)
        end
        if dsComplete then dsText = "== ALL QUESTS COMPLETE ==\n\n" .. dsText end
        _G.DS_Paragraph:SetDesc(dsText)
    end
    
    -- Update ElementJungle
    local ejProgress, ejComplete = _G.GetUpdatedQuestProgress("ElementJungle")
    if ejProgress then
        _G.QuestProgressCache.ElementJungle = ejProgress
        
        local ejText = ""
        for _, v in ipairs(ejProgress) do
            ejText = ejText .. string.format("- %s (%d / %d)\n", v.DisplayName, v.Current, v.Target)
        end
        if ejComplete then ejText = "== ALL QUESTS COMPLETE ==\n\n" .. ejText end
        _G.EJ_Paragraph:SetDesc(ejText)
    end
end

-- ===================================================================
-- 6. LOGIKA AUTO QUEST (The "Brain")
-- ===================================================================

function _G.StopAutoQuest()
    if _G.AutoQuestState.IsRunning then
        NotifyWarning("Auto Quest", "Auto Quest Stopped.")
        StopAutoFish5X()
        _G.AutoQuestState.IsRunning = false
        _G.AutoQuestState.CurrentQuest = nil
        _G.AutoQuestState.CurrentStep = "Idle"
    end
end

function _G.CheckAndRunAutoQuest()
    if not _G.AutoQuestState.IsRunning then return end

    local currentQuestName = _G.AutoQuestState.CurrentQuest
    local currentQuestConfig = _G.AutoQuestConfig[currentQuestName]

    if not currentQuestConfig then
        NotifyError("Auto Quest", "Config not found for: " .. currentQuestName)
        _G.StopAutoQuest()
        return
    end

    local progressCache, isAllComplete
    if currentQuestName == "DeepSea" then
        progressCache = _G.QuestProgressCache.DeepSea
        isAllComplete = _G.QuestProgressCache.IsDeepSeaComplete
    elseif currentQuestName == "ElementJungle" then
        if not _G.QuestProgressCache.IsDeepSeaComplete then
            NotifyError("Auto Quest", "You must complete the Ghostfinn Rod quest first!")
            _G.StopAutoQuest()
            return
        end
        progressCache = _G.QuestProgressCache.ElementJungle
        local allDone = true
        for _, v in ipairs(progressCache) do if not v.IsComplete then allDone = false; break end end
        isAllComplete = allDone
    end

    if not progressCache or #progressCache == 0 then return end

    local targetObjective, targetLocationCFrame, locationName = nil, nil, nil

    for _, objective in ipairs(progressCache) do
        if not objective.IsComplete and objective.Def then
            local areaName
            local conditions = objective.Def.Arguments.conditions
            if conditions then
                areaName = conditions.AreaName
            end

            if currentQuestName == "DeepSea" and not areaName then
                if objective.Key == "CatchRareTreasureRoom" then
                    areaName = "Treasure Room"
                end
            end

            if areaName and currentQuestConfig.locationMap[areaName] then
                targetObjective = objective
                targetLocationCFrame = currentQuestConfig.locationMap[areaName]
                locationName = areaName
                break
            end
        end
    end

    if targetObjective then
        local statusText = string.format("Running: %s (%d/%d)", 
            targetObjective.DisplayName, targetObjective.Current, targetObjective.Target)

        if _G.AutoQuestState.CurrentStep ~= locationName then
            NotifyInfo("Auto Quest", statusText .. " | Teleporting to: " .. locationName)
            _G.AutoQuestState.CurrentStep = locationName
            StopAutoFish5X()
            _G.Teleport(targetLocationCFrame)
            StartAutoFish5X()
        else
            if not _G.IsAutoFishRunning() then
                StartAutoFish5X()
            end
        end
    else
        if isAllComplete then
            NotifySuccess("Auto Quest", "All " .. currentQuestName .. " quests are complete!")
            _G.StopAutoQuest()
        else
            NotifyError("Auto Quest", "Cannot find location for next quest. Stopping.")
            _G.StopAutoQuest()
        end
    end
end

-- ===================================================================
-- 7. UI TOGGLES & FUNGSI INISIALISASI (FIXED LISTENERS)
-- ===================================================================

_G.AutoQuestTab:Toggle({
    Title = "Auto Quest - Ghosfinn Rod",
    Desc = "Automatically farm the Ghostfinn Rod quest.",
    Value = false,
    Callback = function(state)
        if state then
            if _G.AutoQuestState.IsRunning then
                NotifyWarning("Auto Quest", "One auto quest is already running.")
                return false
            end
            NotifySuccess("Auto Quest", "Starting Auto Quest DeepSea...")
            _G.AutoQuestState.IsRunning = true
            _G.AutoQuestState.CurrentQuest = "DeepSea"
            _G.CheckAndRunAutoQuest()
        else
            _G.StopAutoQuest()
        end
    end
})

_G.AutoQuestTab:Toggle({
    Title = "Auto Quest - Element Rod",
    Desc = "Automatically farm the Element Rod quest. (Requires Ghostfinn Rod).",
    Value = false,
    Callback = function(state)
        if state then
            if _G.AutoQuestState.IsRunning then
                NotifyWarning("Auto Quest", "One auto quest is already running.")
                return false
            end
            NotifySuccess("Auto Quest", "Starting Auto Quest Element Rod...")
            _G.AutoQuestState.IsRunning = true
            _G.AutoQuestState.CurrentQuest = "ElementJungle"
            _G.CheckAndRunAutoQuest()
        else
            _G.StopAutoQuest()
        end
    end
})

task.spawn(function()
    while not _G.Replion do 
        task.wait(2) 
    end
    
    _G.DataReplion = _G.Replion.Client:WaitReplion("Data")
    if not _G.DataReplion then
        _G.EJ_Paragraph:SetDesc("Error: Failed to connect to Server.")
        _G.DS_Paragraph:SetDesc("Error: Failed to connect to Server.")
        return
    end

    _G.UpdateProgressParagraphs() -- Panggil sekali saat start

    -- ===================================================================
    -- == [PERBAIKAN REALTIME]
    -- == Kita sekarang mendengarkan SEMUA path data yang 
    -- == digunakan oleh _G.GetUpdatedQuestProgress
    -- ===================================================================

    -- 1. Tentukan SEMUA path yang perlu dipantau
    local ejAvailablePath = _G.QuestList.ElementJungle.ReplionPath .. ".Available.Forever.Quests"
    local dsAvailablePath = _G.QuestList.DeepSea.ReplionPath .. ".Available.Forever.Quests"
    local ejCompletedPath = _G.QuestList.ElementJungle.ReplionPath .. ".Completed"
    local dsCompletedPath = _G.QuestList.DeepSea.ReplionPath .. ".Completed"

    -- 2. Buat listener untuk SEMUA path
    
    -- Listener untuk quest aktif (logika lama Anda, sudah benar)
    _G.DataReplion:OnChange(ejAvailablePath, function()
        _G.UpdateProgressParagraphs()
        _G.CheckAndRunAutoQuest()
    end)
    
    _G.DataReplion:OnChange(dsAvailablePath, function()
        _G.UpdateProgressParagraphs()
        _G.CheckAndRunAutoQuest()
    end)
    
    -- [BARU] Listener untuk status "Completed"
    -- Ini akan memicu update paragraf saat quest selesai
    _G.DataReplion:OnChange(ejCompletedPath, function()
        _G.UpdateProgressParagraphs()
        _G.CheckAndRunAutoQuest()
    end)
    
    _G.DataReplion:OnChange(dsCompletedPath, function()
        _G.UpdateProgressParagraphs()
        _G.CheckAndRunAutoQuest()
    end)
end)


task.spawn(function()
    -- wait minimal sampai everything loaded
    for i = 1, 40 do
        if _G.UpdateProgressParagraphs and _G.QuestList then break end
        task.wait(0.1)
    end

    -- Safety: ensure paragraphs exist, otherwise bail quietly
    if not _G.DS_Paragraph or not _G.EJ_Paragraph then
        -- try to wait a bit more
        for i = 1, 20 do
            if _G.DS_Paragraph and _G.EJ_Paragraph then break end
            task.wait(0.1)
        end
    end

    if not _G.UpdateProgressParagraphs then
        warn("[AutoQuest Sync] _G.UpdateProgressParagraphs not found; realtime sync cancelled.")
        return
    end

    local watchPaths = {}
    pcall(function()
        for key, info in pairs(_G.QuestList or {}) do
            if info and info.ReplionPath then
                table.insert(watchPaths, info.ReplionPath .. ".Available.Forever.Quests")
                table.insert(watchPaths, info.ReplionPath .. ".Completed")
            end
        end
    end)

    pcall(function()
        if _G.DataReplion and type(_G.DataReplion.OnChange) == "function" then
            for _, p in ipairs(watchPaths) do
                -- wrap in pcall to avoid duplicate errors
                pcall(function()
                    _G.DataReplion:OnChange(p, function()
                        -- quick, reactive update
                        pcall(function()
                            _G.UpdateProgressParagraphs()
                            _G.CheckAndRunAutoQuest()
                        end)
                    end)
                end)
            end
        end
    end)

    while task.wait(0.5) do
        pcall(function()
            _G.UpdateProgressParagraphs()
        end)
        pcall(function()
            if _G.AutoQuestState and _G.AutoQuestState.IsRunning then
                _G.CheckAndRunAutoQuest()
            end
        end)
    end
end)







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
    SearchBarEnabled = true,
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


local function accessAllBoats()
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
                count += 1
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


_G.RFRedeemCode = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RedeemCode"]

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

_G.ItemUtilityModule = require(ReplicatedStorage.Shared.ItemUtility)
_G.ClientReplionModule = require(ReplicatedStorage.Packages._Index["ytrev_replion@2.0.0-rc.3"].replion.Client.ClientReplion)

-- Menyimpan Remote Event
_G.RESpawnTotem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/SpawnTotem"]

-- Variabel Global untuk data & status
 -- Akan diisi saat inisialisasi
_G.TotemInventoryCache = {} -- Cache untuk menyimpan UUID {["Luck Totem"] = {UUIDs = {"uuid1", ...}}}
_G.TotemsList = {}
_G.AutoTotemState = {
    IsRunning = false,
    DelayMinutes = 10,
    SelectedTotemName = {},
    LoopThread = nil,
}


function _G.RefreshTotemInventory()
    if not _G.DataReplion then return end

    -- Reset Cache dengan benar
    _G.TotemInventoryCache = {}
    _G.TotemsList = {}

    -- Ambil item dari Replion
    local items = _G.DataReplion:Get({ "Inventory", "Totems" })

    if not items then
        if _G.TotemDropdown then _G.TotemDropdown:Refresh({}) end
        if _G.TotemStatusParagraph then
            _G.TotemStatusParagraph:SetDesc("Inventory refreshed. Found 0 types of totems.")
        end
        return
    end

    -- Loop isi cache
    for _, item in ipairs(items) do
        local totemData = _G.ItemUtilityModule:GetTotemsData(item.Id)

        if totemData and totemData.Data then
            local name = totemData.Data.Name

            -- Jika belum ada, buat array
            if not _G.TotemInventoryCache[name] then
                _G.TotemInventoryCache[name] = {}
            end

            -- Masukkan UUID
            table.insert(_G.TotemInventoryCache[name], item.UUID)
        end
    end

    -- Bangun dropdown list
    for name, list in pairs(_G.TotemInventoryCache) do
        local count = #list  -- FIX: tidak lagi memakai list.UUIDs
        table.insert(_G.TotemsList, string.format("%s (x%d)", name, count))
    end

    table.sort(_G.TotemsList)

    -- Update dropdown
    if _G.TotemDropdown then
        _G.TotemDropdown:Refresh(_G.TotemsList)
    end

    -- Update status
    if _G.TotemStatusParagraph then
        _G.TotemStatusParagraph:SetDesc(
            string.format("Inventory refreshed. Found %d types of totems.", #_G.TotemsList)
        )
    end
end



-- Fungsi untuk menghentikan loop
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

            -- ============================
            -- 1. Validasi pilihan totem
            -- ============================
            local rawName = _G.AutoTotemState.SelectedTotemName
            if not rawName or rawName == "" then
                NotifyError("Auto Totem", "No totem selected from dropdown.")
                return _G.StopAutoTotem()
            end

            -- Clean name dari "(x5)" → "Luck Totem"
            local cleanName = rawName:match("^(.-) %(")
            cleanName = cleanName or rawName -- fallback seluruh name

            -- ============================
            -- 2. Ambil data totem
            -- ============================
            local totemList = _G.TotemInventoryCache[cleanName]

            if not totemList or #totemList == 0 then
                NotifyError("Auto Totem", "No more '" .. cleanName .. "' left in inventory.")
                _G.RefreshTotemInventory()
                return _G.StopAutoTotem()
            end

            -- ============================
            -- 3. Ambil UUID & FireServer
            -- ============================
            local uuid = table.remove(totemList, 1)
            if uuid then
                _G.RESpawnTotem:FireServer(uuid)
                NotifySuccess("Auto Totem", "Spawned 1x " .. cleanName)
            end

            -- ============================
            -- 4. Refresh UI
            -- ============================
            
            if FuncAutoFish.autofish5x then
                _G.StopFishing()
                StopAutoFish5X()
                task.wait(1)
                StartAutoFish5X()
            end

            -- ============================
            -- 5. Delay (with countdown)
            -- ============================
            local delaySeconds = _G.AutoTotemState.DelayMinutes * 60
            local waited = 0
            
            while waited < delaySeconds and _G.AutoTotemState.IsRunning do
                local remaining = delaySeconds - waited
                
                local minutes = math.floor(remaining / 60)
                local seconds = remaining % 60
            
                _G.TotemStatusParagraph:SetDesc(
                    string.format("Spawned %s. Waiting %02d:%02d...", cleanName, minutes, seconds)
                )
                
                local step = math.min(5, remaining)
                task.wait(step)
                waited += step
            end
        end
    end)
end

-- =======================================================
-- 3. UI (DROPDOWN, INPUT, TOGGLE)
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
    Title = "Delay (Minutes)",
    Placeholder = "Enter minutes...",
    Default = 10,
    Type = "Input",
    Callback = function(val)
        _G.AutoTotemState.DelayMinutes = tonumber(val) or 10
    end
})

Utils:Button({ Title = "Refresh Totems", Icon = "refresh-cw", Callback = _G.RefreshTotemInventory })

Utils:Toggle({
    Title = "Enable Auto Totem",
    Value = false,
    Callback = function(state)
        if state then
            _G.StartAutoTotem()
        else
            _G.StopAutoTotem()
        end
    end
})

task.spawn(function()
    while not _G.Replion do 
        _G.TotemStatusParagraph:SetDesc("Waiting for _G.Replion...")
        task.wait(2) 
    end
    
    _G.DataReplion = _G.Replion.Client:WaitReplion("Data")
    if not _G.DataReplion then
        _G.TotemStatusParagraph:SetDesc("Error: Failed to connect to Server Data.")
        return
    end

    -- Panggil fungsi (yang sudah diperbaiki) untuk pertama kali
    _G.RefreshTotemInventory()
    
end)

Utils:Space()


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
    ["12"] = { name = "Lost Shore", position = Vector3.new(-3663, 38, -989) },
    ["13"] = { name = "Sishypus Statue", position = Vector3.new(-3792, -135, -986) },
    ["14"] = { name = "Ancient Jungle", position = Vector3.new(1478, 131, -613) },
    ["15"] = { name = "The Temple", position = Vector3.new(1477, -22, -631) },
    ["16"] = { name = "Underground Cellar", position = Vector3.new(2133, -91, -674) },
    ["17"] = {name = "Ancient Ruin", position = Vector3.new(6052, -546, 4427) },
    ["18"] = {name = "Iron Cavern", position = Vector3.new(-8873, -582, 157) },
    ["19"] = {name = "Iron Cafe", position = Vector3.new(-8668, -549, 161) },
    ["20"] = {name = "Classic Island", position = Vector3.new(1259, 10, 2824) }
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
    SearchBarEnabled = true,
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
    SearchBarEnabled = true,
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
    SearchBarEnabled = true,
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


Utils:Dropdown({
    Title = "NPC",
    Desc = "Select NPC to Teleport",
    Values = npcList,
    Value = nil,
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

local REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
["RE/ObtainedNewFishNotification"]

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

    local retries = 10
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
            return true
        else
            warn(string.format("[Retry %d/%d] Gagal kirim webhook: %s", i, retries, err))
            task.wait(1.5)
        end
    end
    return false
end

-- Roblox image fetcher
local function GetRobloxImage(assetId)
    local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" ..
    assetId .. "&size=420x420&format=Png&isCircular=false"
    local success, response = pcall(game.HttpGet, game, url)
    if success and response then
        local data = HttpService:JSONDecode(response)
        if data and data.data and data.data[1] and data.data[1].imageUrl then
            return data.data[1].imageUrl
        end
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
    if not webhookPath or webhookPath == "" or not FishWebhookEnabled then
        warn("Webhook disabled or path invalid.")
        return
    end

    local WebhookURL = "https://discord.com/api/webhooks/" .. webhookPath
    local username = LocalPlayer.DisplayName
    local rodName = getValidRodName()
    local inventoryCount = getInventoryCount() 

    local imageUrl = GetRobloxImage(assetId)
    
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

    -- Listener perubahan Text (Visual Trigger)
    fishText:GetPropertyChangedSignal("Text"):Connect(function()
        local fishName = fishText.Text
        
        -- [PERBAIKAN UTAMA]
        -- Kita gunakan 'LastCatchData.ItemId' yang sudah ditangkap dari RemoteEvent
        -- sebelumnya (baris REObtainedNewFishNotification.OnClientEvent).
        -- Ini menjamin kita mengecek DATA server, bukan cuma nama di layar.
        
        local currentItemId = LastCatchData.ItemId
        
        -- Validasi: Pastikan ID ada dan Nama di UI cocok dengan data ID (Optional safety)
        -- Tapi yang terpenting adalah cek Tier dari ID.
        
        if currentItemId and isTargetTier(currentItemId) then
            local rarity = rarityText.Text
            local assetId = string.match(imageFrame.Image, "%d+")
            
            if assetId then
                sendFishWebhook(fishName, rarity, assetId, LastCatchData.ItemId, LastCatchData.VariantId)
            end
        else
            -- Debugging (Opsional, hapus nanti)
            -- warn("Ikan ditangkap tapi tidak masuk filter Tier:", fishName)
        end
    end)
end

startFishDetection()


-------------------------------------------
----- =======[ SETTINGS TAB ]
-------------------------------------------


_G.AccConfig = SettingsTab:Section({
    Title = "Account Configuration",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})


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