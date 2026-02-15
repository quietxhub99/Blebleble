local Version = "1.6.53"
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Madindun/Loader/refs/heads/shibal/ui.lua"))()

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
WindUI.TransparencyValue = 0

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

_G.ServerPage = Window:Tab({
    Title = "Server List",
    Icon = "server"
})

_G.CEvent = Window:Tab({
    Title = "Christmas Event",
    Icon = "candy-cane",
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
    if item and item.Id then
        local base = _G.ItemUtility:GetItemData(item.Id)
        if base and base.Data then
            if base.Data.Type == "Gears" then
                local name = _G.ItemStringUtility.GetItemName(item, base)
                if name then
                    if string.find(string.lower(name), "present") then
                        table.insert(result, {
                            Name = name,
                            UUID = item.UUID
                        })
                    end
                end
            end
        end
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

_G.Players = game:GetService("Players")
_G.LocalPlayer = _G.Players.LocalPlayer
_G.Workspace = game:GetService("Workspace")

_G.AutoClaimPresent = {
    enabled = false,
    loop = nil
}

_G.PresentCounter = {
    total = 0,
    connAdd = nil,
    connRemove = nil,
    loop = nil
}

_G.CEvent:Space()

_G.CEvent:Divider()

_G.PresentParaTwo = _G.CEvent:Paragraph({
    Title = "Christmas Present Monitor",
    Desc = "Available Presents : 0\nAuto Claim : OFF",
    Locked = true
})


_G.countPresents = function()
    local folder = _G.getChristmasFolder()
    if not folder then
        return 0
    end

    local count = 0
    for _, v in ipairs(folder:GetChildren()) do
        if v:IsA("Model") then
            count = count + 1
        end
    end

    return count
end

_G.startPresentFallbackLoop = function()
    if _G.PresentCounter.loop then return end

    _G.PresentCounter.loop = task.spawn(function()
        while true do
            _G.updatePresentParagraph()
            task.wait(2)
        end
    end)
end

_G.startPresentMonitor = function()
    local folder = _G.getChristmasFolder()
    if not folder then return end

    -- Bersihkan listener lama
    if _G.PresentCounter.connAdd then
        _G.PresentCounter.connAdd:Disconnect()
    end
    if _G.PresentCounter.connRemove then
        _G.PresentCounter.connRemove:Disconnect()
    end

    -- Initial update
    _G.updatePresentParagraph()

    -- Realtime ADD
    _G.PresentCounter.connAdd = folder.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            task.defer(_G.updatePresentParagraph)
        end
    end)

    -- Realtime REMOVE
    _G.PresentCounter.connRemove = folder.ChildRemoved:Connect(function(child)
        if child:IsA("Model") then
            task.defer(_G.updatePresentParagraph)
        end
    end)
end

_G.updatePresentParagraph = function()
    if not _G.PresentParaTwo then return end

    local total = _G.countPresents()
    _G.PresentCounter.total = total

    _G.PresentParaTwo:SetDesc(
        ("Available Presents : %d\nAuto Claim : %s"):format(
            total,
            _G.AutoClaimPresent.enabled and "ON" or "OFF"
        )
    )
end

_G.getHRP = function()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

_G.getChristmasFolder = function()
    return Workspace:FindFirstChild("ChristmasPresents")
end

_G.claimAllPresents = function()
    local hrp = _G.getHRP()
    local folder = _G.getChristmasFolder()
    if not (hrp and folder) then return end

    for _, present in ipairs(folder:GetChildren()) do
        if not _G.AutoClaimPresent.enabled then break end
        if present:IsA("Model") then
            local prompt =
                present:FindFirstChildWhichIsA("ProximityPrompt", true)

            if prompt and prompt.Parent then
                local part =
                    prompt.Parent:IsA("BasePart")
                    and prompt.Parent
                    or present:FindFirstChildWhichIsA("BasePart", true)

                if part then
                    -- 🚀 Teleport ke present
                    hrp.CFrame = part.CFrame * CFrame.new(0, 0, -2)

                    task.wait(0.1)

                    -- 🔔 Fire ProximityPrompt
                    pcall(function()
                        fireproximityprompt(prompt)
                    end)

                    task.wait(0.15)
                end
            end
        end
    end
end

_G.startAutoClaimPresent = function()
    if _G.AutoClaimPresent.loop then return end

    _G.AutoClaimPresent.loop = task.spawn(function()
        while _G.AutoClaimPresent.enabled do
            _G.claimAllPresents()
            task.wait(1) -- ulangi jika ada drop baru
        end
    end)
end

_G.stopAutoClaimPresent = function()
    if _G.AutoClaimPresent.loop then
        task.cancel(_G.AutoClaimPresent.loop)
        _G.AutoClaimPresent.loop = nil
    end
end

_G.CEvent:Toggle({
    Title = "Auto Claim Drop Present",
    Value = false,
    Callback = function(state)
        _G.AutoClaimPresent.enabled = state
        _G.updatePresentParagraph()
    
        if state then
            _G.startAutoClaimPresent()
        else
            _G.stopAutoClaimPresent()
        end
    end
})

task.spawn(function()
    task.wait(1)
    _G.startPresentMonitor()
    _G.startPresentFallbackLoop()
end)

_G.CEvent:Divider()

_G.CEvent:Section({
    Title = "New Years Event Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.CEvent:Divider()

-- =====================================================
-- AUTO NEW YEARS WHALE (BLACK HOLE TRACKER)
-- Stable | WorldPivot | Respawn Safe | Y Offset Fix
-- =====================================================

do
    _G.AutoNewYearsWhale = {
        enabled = false,
        thread = nil,
        lastPivot = nil,
        currentModel = nil
    }

    --------------------------------------------------
    -- CONFIG
    --------------------------------------------------
    local CHECK_INTERVAL = 0.25
    local TELEPORT_THRESHOLD = 5 -- studs
    local Y_OFFSET = 115 -- 🔽 turunkan posisi (15–30 rekomendasi)

    --------------------------------------------------
    -- SAFE TELEPORT (WITH OFFSET)
    --------------------------------------------------
    local function SafeTeleportWithOffset(pivot)
        local char = _G.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = pivot * CFrame.new(0, Y_OFFSET, 0)
        end
    end

    --------------------------------------------------
    -- FIND BLACK HOLE MODEL (SAFE)
    --------------------------------------------------
    local function FindBlackHole()
        local props = workspace:FindFirstChild("Props")
        if not props then return nil end
        return props:FindFirstChild("Black Hole")
    end

    --------------------------------------------------
    -- MAIN MONITOR LOOP
    --------------------------------------------------
    local function AutoWhaleLoop()
        while _G.AutoNewYearsWhale.enabled do
            local model = FindBlackHole()

            if model and model:IsA("Model") then
                _G.AutoNewYearsWhale.currentModel = model

                local pivot = model:GetPivot()

                if not _G.AutoNewYearsWhale.lastPivot then
                    _G.AutoNewYearsWhale.lastPivot = pivot
                    SafeTeleportWithOffset(pivot)

                    _G.ToggleBlockOnce(true)
                else
                    local dist =
                        (pivot.Position - _G.AutoNewYearsWhale.lastPivot.Position).Magnitude

                    if dist >= TELEPORT_THRESHOLD then
                        _G.AutoNewYearsWhale.lastPivot = pivot
                        SafeTeleportWithOffset(pivot)

                        _G.ToggleBlockOnce(true)
                    end
                end
            else
                -- Event refresh / object hilang
                _G.AutoNewYearsWhale.currentModel = nil
                _G.AutoNewYearsWhale.lastPivot = nil
            end

            task.wait(CHECK_INTERVAL)
        end
    end

    --------------------------------------------------
    -- TOGGLE HANDLER
    --------------------------------------------------
    _G.ToggleAutoNewYearsWhale = function(state)
        _G.AutoNewYearsWhale.enabled = state

        if state then
            if _G.AutoNewYearsWhale.thread then return end
            _G.AutoNewYearsWhale.thread = task.spawn(AutoWhaleLoop)
        else
            if _G.AutoNewYearsWhale.thread then
                task.cancel(_G.AutoNewYearsWhale.thread)
                _G.AutoNewYearsWhale.thread = nil
            end
            _G.AutoNewYearsWhale.lastPivot = nil
            _G.AutoNewYearsWhale.currentModel = nil
        end
    end
end

_G.CEvent:Toggle({
    Title = "Auto New Years Whale",
    Value = false,
    Callback = function(v)
        _G.ToggleAutoNewYearsWhale(v)
    end
})

-------------------------------------------
----- =======[ SERVER PAGE TAB ]
-------------------------------------------

_G.ServerList = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" ..
game.PlaceId .. "/servers/Private?sortOrder=Asc&limit=100"))

_G.ButtonList = {}

_G.ServerListAll = _G.ServerPage:Section({
    Title = "All Server List",
    TextSize = 22,
    TextXAlignment = "Center"
})

_G.ShowServersButton = _G.ServerListAll:Button({
    Title = "Show Server List",
    Desc = "Klik untuk menampilkan daftar server yang tersedia.",
    Locked = false,
    Icon = "",
    Callback = function()
        if _G.ServersShown then return end
        _G.ServersShown = true

        for _, server in ipairs(_G.ServerList.data) do
            _G.playerCount = string.format("%d/%d", server.playing, server.maxPlayers)
            _G.ping = server.ping
            _G.id = server.id

            local buttonServer = _G.ServerListAll:Button({
                Title = "Server",
                Desc = "Player: " .. tostring(_G.playerCount) .. "\nPing: " .. tostring(_G.ping),
                Locked = false,
                Icon = "",
                Callback = function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, _G.id,
                        game.Players.LocalPlayer)
                end
            })

            buttonServer:SetTitle("Server")
            buttonServer:SetDesc("Player: " .. tostring(_G.playerCount) .. "\nPing: " .. tostring(_G.ping))

            table.insert(_G.ButtonList, buttonServer)
        end

        if #_G.ButtonList == 0 then
            _G.ServerListAll:Button({
                Title = "No Servers Found",
                Desc = "Tidak ada server yang ditemukan.",
                Locked = true,
                Callback = function() end
            })
        end
    end
})

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
_G.sellThreshold = 5
_G.sellActive = false
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
    FuncAutoFish.autofish5x = true
    _G.AntiStuckEnabled = true
    lastEventTime = tick()
    _G.lastFishTime = tick()
    _G.equipRemote:FireServer(1)
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

local v5 = {
    Net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net,
    FishingController = require(ReplicatedStorage.Controllers.FishingController),
}

-------------------------------------------------
-- FORCE EQUIP SLOT 1 (AUTO)
-------------------------------------------------

local v6 = {
    Events = {
        REFishDone = v5.Net["RF/CatchFishCompleted"],
        REEquip = v5.Net["RE/EquipToolFromHotbar"],
    },
    Functions = {
        ChargeRod = v5.Net["RF/ChargeFishingRod"],
        StartMini = v5.Net["RF/RequestFishingMinigameStarted"],
        Cancel = v5.Net["RF/CancelFishingInputs"],
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

function Fastest()
    task.spawn(function()
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

_G.FishAdvenc = AutoFish:Section({
    Title = "Advenced Settings",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

_G.FishSec = AutoFish:Section({
    Title = "Auto Fishing Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

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
    ["18"] = "Pirate Cove",
    ["18"] = "Pirate Treasure Room",
    ["19"] = "Crystal Depths",
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

_G.FarmSec:Space()

_G.CodeIsland = _G.FarmSec:Dropdown({
    Title = "Farm Island",
    Values = nameList,
    Value = nameList[9],
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



-- ===================================================================
-- 
-- FIXED AUTO QUEST (NO GOTO - UNIVERSAL SUPPORT)
--
-- ===================================================================

do
    _G.AutoQuestState = {
        enabled = false,
        loopThread = nil,
        selectedQuest = "Deep Sea Quest",
        currentStepName = "Idle"
    }
    
    local autoQuestToggle
    local statusParagraph
    local questDropdown
    local Modules = {} 

    _G.QuestLocations = {
        ["Treasure Room"] = CFrame.new(-3600, -270, -1642),
        ["Sisyphus Statue"] = CFrame.new(-3742, -136, -1033),
        ["Ancient Jungle"] = CFrame.new(1508, 4, -298),
        ["Underground Cellar"] = CFrame.new(2137, -91, -700),
        ["Sacred Temple"] = CFrame.new(1499, -22, -641),
        ["Altar"] = CFrame.new(1491.477, 127.5, -593.159),
        ["Kohana"] = CFrame.new(-582, 48, 226),
        ["Kohana Volcano"] = CFrame.new(-602, 54, 119)
    }

    local tierMapIndex = {
        [1] = "Common", [2] = "Uncommon", [3] = "Rare", 
        [4] = "Epic", [5] = "Legendary", [6] = "Mythic", [7] = "SECRET"
    }

    local function teleportTo(cframe)
        local char = _G.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            if StopAutoFish5X then StopAutoFish5X() end 
            root.CFrame = cframe
            task.wait(1) 
        end
    end

    local function getActiveQuestData(questName)
        if not Modules.QuestDefinitions then 
            local s, r = pcall(function() 
                return require(game:GetService("ReplicatedStorage").Modules.Quests) 
            end)
            if s then Modules.QuestDefinitions = r end
        end

        if not Modules.Replion then
            local s, r = pcall(function()
                return require(game:GetService("ReplicatedStorage").Packages.Replion)
            end)
            if s then Modules.Replion = r end
        end

        if not _G.DataReplion and Modules.Replion then 
             _G.DataReplion = Modules.Replion.Client:WaitReplion("Data")
        end
        
        if not _G.DataReplion then return nil end
        
        local activeQuests = _G.DataReplion:Get({"Quests", "Mainline"}) 
        if not activeQuests then return nil end

        local playerQuestData = activeQuests[questName]
        local questDef = Modules.QuestDefinitions.Mainline and Modules.QuestDefinitions.Mainline[questName]
        
        if not (playerQuestData and questDef) then return nil end

        return { def = questDef, progress = playerQuestData }
    end

    local function runAutoQuestLoop()
        while _G.AutoQuestState.enabled do
            task.wait(0.5) 

            -- [FIX GOTO] Menggunakan IF block biasa
            local char = _G.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                local questName = _G.AutoQuestState.selectedQuest
                local questData = getActiveQuestData(questName)

                if questData then
                    local objectives = questData.def.Objectives
                    local progressData = questData.progress.Objectives
                    
                    local statusTextFull = ""
                    local activeObjective = nil

                    for i, objDef in ipairs(objectives) do
                        local currentProg = 0
                        if progressData and progressData[i] then
                            currentProg = progressData[i].Progress or 0
                        end
                        local goal = objDef.Goal or 1 -- [FIX NIL CHECK] Tambahan or 1
                        local name = objDef.Name

                        if currentProg >= goal then
                            statusTextFull = statusTextFull .. "✅ " .. name .. "\n"
                        else
                            if activeObjective == nil then
                                activeObjective = objDef
                                activeObjective._currentProgress = currentProg 
                                statusTextFull = statusTextFull .. "🎣 " .. name .. " ("..currentProg.."/"..goal..") [Active]\n"
                            else
                                statusTextFull = statusTextFull .. "🔴 " .. name .. " ("..currentProg.."/"..goal..") [Wait]\n"
                            end
                        end
                    end

                    if statusParagraph then
                        statusParagraph:SetDesc(statusTextFull)
                    end

                    if activeObjective then
                        local objType = activeObjective.Type
                        local reqs = activeObjective.Requirements
                        
                        if objType == "Catch" then
                            local targetLocName = nil
                            local targetTierName = nil

                            if reqs then
                                if reqs.Location then targetLocName = reqs.Location
                                elseif reqs.Locations and #reqs.Locations > 0 then targetLocName = reqs.Locations[1] end
                                
                                if reqs.Tier then targetTierName = tierMapIndex[reqs.Tier] end
                            end

                            if targetLocName and _G.QuestLocations[targetLocName] then
                                local targetCFrame = _G.QuestLocations[targetLocName]
                                if (hrp.Position - targetCFrame.Position).Magnitude > 50 then
                                    if StopAutoFish5X then StopAutoFish5X() end
                                    teleportTo(targetCFrame)
                                    task.wait(1.5)
                                end
                            end

                            if StartAutoFish5X then
                                -- Cek apakah perlu restart fishing
                                if not FuncAutoFish.autofish5x then
                                    StartAutoFish5X()
                                end
                            end

                        elseif objType == "CreateTranscendedStone" then
                            local altarPos = _G.QuestLocations["Altar"]
                            if (hrp.Position - altarPos.Position).Magnitude > 30 then
                                teleportTo(altarPos)
                                task.wait(1)
                            else
                                -- Remote aktivasi altar bisa dipanggil di sini jika ada
                                task.wait(2)
                            end

                        elseif objType == "EarnedCoins" then
                             if StartAutoFish5X and (not FuncAutoFish.autofish5x) then
                                StartAutoFish5X()
                            end
                        else
                            task.wait(1)
                        end
                    else
                        -- Quest Selesai
                        if statusParagraph then statusParagraph:SetDesc("QUEST COMPLETED!\nAll objectives finished.") end
                        
                        _G.AutoQuestState.enabled = false
                        if StopAutoFish5X then StopAutoFish5X() end
                        
                        pcall(function() 
                            if autoQuestToggle then autoQuestToggle:SetValue(false) end 
                        end)
                    end
                else
                    if statusParagraph then statusParagraph:SetDesc("Quest not active/found.\nPlease talk to NPC.") end
                end
            end
        end
    end

    local function startOrStopAutoQuest(shouldStart)
        _G.AutoQuestState.enabled = shouldStart

        if _G.AutoQuestState.loopThread then
            task.cancel(_G.AutoQuestState.loopThread)
            _G.AutoQuestState.loopThread = nil
        end

        if shouldStart then
            if statusParagraph then statusParagraph:SetDesc("Starting...") end
            _G.AutoQuestState.loopThread = task.spawn(runAutoQuestLoop)
        else
            if statusParagraph then statusParagraph:SetDesc("Idle (Stopped).") end
            if StopAutoFish5X then StopAutoFish5X() end
            
            local char = _G.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Anchored = false
            end
        end
    end

    if _G.AutoQuestTab then
        local questSection = _G.AutoQuestTab:Section({ Title = "Mainline Auto Quest", TextXAlignment = "Center", Opened = true })
        
        statusParagraph = questSection:Paragraph({ Title = "Quest Status", Desc = "Idle." })

        questDropdown = questSection:Dropdown({
            Title = "Select Quest Line",
            Values = { "Deep Sea Quest", "Element Quest", "Aura Quest" }, 
            Value = "Deep Sea Quest",
            Callback = function(v)
                _G.AutoQuestState.selectedQuest = v
                if statusParagraph then statusParagraph:SetDesc("Selected: " .. v) end
            end
        })

        autoQuestToggle = questSection:Toggle({
            Title = "Enable Auto Quest",
            Value = false,
            Callback = startOrStopAutoQuest
        })
    else
        warn("UI Tab '_G.AutoQuestTab' not found.")
    end
end



-------------------------------------------
----- =======[ MASS TRADE TAB ]
-------------------------------------------

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
local InitiateTrade = net:WaitForChild("RF/InitiateTrade") 
local RFAwaitTradeResponse = net:WaitForChild("RF/AwaitTradeResponse") 

-- Fungsi utilitas untuk mendapatkan daftar pemain
local function getPlayerListV2()
    local list = {}; 
    for _, p in ipairs(Players:GetPlayers()) do 
        if p ~= LocalPlayer then 
            table.insert(list, p.Name) 
        end 
    end; 
    table.sort(list); 
    return list
end

local function refreshDropdownV2()
    if _G.PlayerDropdownTrade then
        _G.PlayerDropdownTrade:Refresh(getPlayerListV2())
    end
end

-- =======================================================
-- LOGIKA PEMBARUAN INVENTARIS 
-- =======================================================

local function refreshInventory()
    local DataReplion = _G.Replion.Client:WaitReplion("Data")
    if not DataReplion or not ItemUtility or not ItemStringUtility then 
        warn("Cannot refresh inventory: Missing modules.")
        return 
    end
    
    local inventoryItems = DataReplion:Get({ "Inventory", "Items" })
    local groupedItems = {}
    inventoryCache = {}
    fullInventoryDropdownList = {}

    if not inventoryItems then return end

    for _, itemData in ipairs(inventoryItems) do
        local baseItemData = ItemUtility:GetItemData(itemData.Id)
        
        if baseItemData and baseItemData.Data and (baseItemData.Data.Type == "Fish" or baseItemData.Data.Type == "Enchant Stones") then
            -- Filter Unfavorited (Mode V2)
            if not (tradeState.filterUnfavorited and itemData.Favorited) then
                local dynamicName = ItemStringUtility.GetItemName(itemData, baseItemData)
                if not groupedItems[dynamicName] then
                    groupedItems[dynamicName] = 0
                    inventoryCache[dynamicName] = {}
                end
                groupedItems[dynamicName] = (groupedItems[dynamicName] or 0) + 1
                table.insert(inventoryCache[dynamicName], itemData.UUID)
            end
        end
    end

    for name, count in pairs(groupedItems) do
        table.insert(fullInventoryDropdownList, string.format("%s (%dx)", name, count))
    end
    table.sort(fullInventoryDropdownList)

    -- Perbarui Dropdown Item dan Pemain
    if _G.InventoryDropdown then _G.InventoryDropdown:Refresh(fullInventoryDropdownList) end
    if _G.PlayerDropdownTrade then _G.PlayerDropdownTrade:Refresh(getPlayerListV2()) end
end

-- =======================================================
-- LOGIKA HOOKING
-- =======================================================

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
_G.REEquipItem = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]


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
    Value = "V1",
    Callback = function(v)
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
    end
})

local playerDropdown = Trade:Dropdown({
    Title = "Select Trade Target",
    Values = getPlayerListV2(),
    Value = getPlayerListV2()[1] or nil,
    SearchBarEnabled = true,
    Callback = function(selected)
        tradeState.selectedPlayerName = selected
        local player = Players:FindFirstChild(selected)
        if player then
            tradeState.selectedPlayerId = player.UserId
            NotifySuccess("Target Selected", "Target set to: " .. player.Name, 3)
        else
            tradeState.selectedPlayerId = nil
            NotifyError("Target Error", "Player not found!", 3)
        end
    end
})
_G.PlayerDropdownTrade = playerDropdown -- Simpan referensi untuk refresh

Players.PlayerAdded:Connect(function()
    task.delay(0.1, refreshDropdownV2)
end)

Players.PlayerRemoving:Connect(function()
    task.delay(0.1, refreshDropdownV2)
end)

refreshDropdownV2()

Trade:Section({Title = "Auto Accept Trade"})

Trade:Toggle({
    Title = "Enable Auto Accept Trade",
    Desc = "Automatically accepts incoming trade requests.",
    Value = false,
    Callback = function(value)
        _G.AutoAcceptTradeEnabled = value
        if value then
            NotifySuccess("Auto Accept", "Auto accept trade enabled.", 3)
        else
            NotifyWarning("Auto Accept", "Auto accept trade disabled.", 3)
        end
    end
})

Trade:Section({Title = "Mode V1"})
_G.TradeQuietElements = {}

-- Toggle Mode Save Items (Mode V1)
local saveModeToggle = Trade:Toggle({
    Title = "Mode Save Items",
    Desc = "Click inventory item to add for Mass Trade",
    Value = false,
    Callback = function(state)
        tradeState.saveTempMode = state
        if state then
            tradeState.TempTradeList = {}
            NotifySuccess("Save Mode", "Enabled - Click items to save")
        else
            NotifyInfo("Save Mode", "Disabled - "..#tradeState.TempTradeList.." items saved")
        end
    end
})
table.insert(_G.TradeQuietElements, {Element = saveModeToggle})

-- Toggle Trade (Original Send) (V1)
local originalTradeToggle = Trade:Toggle({
    Title = "Trade (Original Send)",
    Desc = "Click inventory items to Send Trade",
    Value = false,
    Callback = function(state)
        tradeState.onTrade = state
        if state then
            NotifySuccess("Trade", "Trade Mode Enabled. Click an item to send trade.")
        else
            NotifyWarning("Trade", "Trade Mode Disabled.")
        end
    end
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

-- Toggle Start Mass Trade (V2)
Trade:Toggle({
    Title = "Start Mass Trade V2",
    Value = false,
    Callback = function(value)
        tradeState.autoTradeV2 = value
        if tradeState.mode == "V2" and value then
            task.spawn(function()
                if not tradeState.selectedItemName or not tradeState.selectedPlayerId or tradeState.tradeAmount <= 0 then
                    statusParagraphV2:SetDesc("Error: Select item, amount, and player.")
                    tradeState.autoTradeV2 = false
                    return
                end

                local cleanItemName = tradeState.selectedItemName:match("^(.*) %((%d+)x%)$")
                if cleanItemName then cleanItemName = cleanItemName:match("^(.*)") end 
                if not cleanItemName then cleanItemName = tradeState.selectedItemName end

                local uuidsToSend = inventoryCache[cleanItemName]

                if not uuidsToSend or #uuidsToSend < tradeState.tradeAmount then
                    statusParagraphV2:SetDesc("Error: Not enough items. Refresh inventory.")
                    tradeState.autoTradeV2 = false
                    return
                end

                local successCount, failCount = 0, 0
                local targetName = tradeState.selectedPlayerName

                for i = 1, tradeState.tradeAmount do 
                    if not tradeState.autoTradeV2 then
                        statusParagraphV2:SetDesc("Process stopped by user.")
                        break
                    end

                    local uuid = uuidsToSend[i]
                    statusParagraphV2:SetDesc(string.format(
                        "Progress: %d/%d | Sending to: %s | Status: <font color='#eab308'>Waiting...</font>",
                        i, tradeState.tradeAmount, targetName))

                    local success, result = pcall(InitiateTrade.InvokeServer, InitiateTrade, tradeState.selectedPlayerId, uuid)

                    if success and result then
                        successCount = successCount + 1
                    else
                        failCount = failCount + 1
                    end

                    statusParagraphV2:SetDesc(string.format(
                        "Progress: %d/%d | Sent: %s | Success: %d | Failed: %d",
                        i, tradeState.tradeAmount, success and "âœ…" or "âŒ", successCount, failCount))
                    
                    task.wait(5) 
                end

                statusParagraphV2:SetDesc(string.format(
                    "Trade V2 Process Complete.\nSuccessful: %d | Failed: %d",
                    successCount, failCount))

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

    -- Data yang diperlukan untuk Variants (Mutasi)
    local variantNames = {}
    for vName, _ in pairs(GlobalFav.Variants) do
        table.insert(variantNames, vName)
    end
    if not table.find(variantNames, "Shiny") then
        table.insert(variantNames, "Shiny")
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
        Callback = function(selectedNames)
            categoryTradeState.selectedTiers = {}
            for _, name in ipairs(selectedNames or {}) do
                if tierMap[name] then table.insert(categoryTradeState.selectedTiers, tierMap[name]) end
            end
            NotifyInfo("Trade V3", "Tiers to trade: " .. table.concat(selectedNames, ", "))
        end
    })
    table.insert(_G.TradeV3Elements, {Element = V3_TierDropdown}) -- Daftarkan UI

    local V3_VariantDropdown = Trade:Dropdown({
        Title = "Select Mutations (Variants) to Trade",
        Values = variantNames, Multi = true, AllowNone = true,
        Callback = function(selectedNames)
            categoryTradeState.selectedVariants = selectedNames or {}
            NotifyInfo("Trade V3", "Mutations to trade: " .. table.concat(selectedNames, ", "))
        end
    })
    table.insert(_G.TradeV3Elements, {Element = V3_VariantDropdown}) -- Daftarkan UI

    local V3_FilterToggle = Trade:Toggle({
        Title = "Filter Unfavorited Items Only",
        Desc = "Hanya mengirim item yang tidak di-lock (favorite).", Value = false,
        Callback = function(val)
            categoryTradeState.filterUnfavorited = val
            NotifyInfo("Trade V3", "Filter Unfavorited: " .. tostring(val))
        end
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

_G.RadarRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/UpdateFishingRadar"]
_G.EquipTankRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/EquipOxygenTank"]
_G.UnequipTankRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/UnequipOxygenTank"]


_G.RadarEnabled = false

Player:Toggle({
    Title = "Fishing Radar",
    Value = false,
    Callback = function(state)
        _G.RadarEnabled = state

        pcall(function()
            _G.RadarRemote:InvokeServer(state)
        end)

        if state then
            NotifySuccess("Divine Radar", "Fishing Radar Activated!")
        else
            NotifyWarning("Divine Radar", "Fishing Radar Deactivated.")
        end
    end
})

_G.DivineGear = false

Player:Toggle({
    Title = "Divine Gear (Oxygen Tank)",
    Value = false,
    Callback = function(state)
        _G.DivineGear = state

        pcall(function()
            if state then
                _G.EquipTankRemote:InvokeServer(105)
                NotifySuccess("Divine Gear", "Oxygen Tank Equipped!")
            else
                _G.UnequipTankRemote:InvokeServer()
                NotifyWarning("Divine Gear", "Oxygen Tank Unequipped.")
            end
        end)
    end
})

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

_G.PurchaseCharmRF = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseCharm"]

_G.EquipCharmRE = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipCharm"]
    
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

_G.AutoSellEnchantState = {
    Enabled = false,
    Amount = 1,
    LoopThread = nil
}

_G.RFSellItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellItem"]


_G.AutoSellProgressParagraph = Utils:Paragraph({
    Title = "Auto Sell Status",
    Desc = "Idle..."
})

function _G.CheckEnchantStone()
    refreshInventory()

    local total = 0

    for name, list in pairs(inventoryCache) do
        if string.find(string.lower(name), "stone") then
            total += #list
        end
    end

    if total == 0 then
        _G.AutoSellProgressParagraph:SetDesc("You have 0 Enchant Stones.")
        NotifyWarning("Enchant Stone", "No stones found.")
        return 0
    end

    local msg = string.format("Total Enchant Stones Available: %d", total)
    _G.AutoSellProgressParagraph:SetDesc(msg)
    NotifySuccess("Enchant Stone", msg)
    return total
end


function _G.StartAutoSellEnchant()
    if _G.AutoSellEnchantState.Enabled then return end

    _G.AutoSellEnchantState.Enabled = true
    _G.AutoSellProgressParagraph:SetDesc("Preparing inventory...")

    _G.AutoSellEnchantState.LoopThread = task.spawn(function()

        refreshInventory()

        local stoneUUIDs = {}
        for name, list in pairs(inventoryCache) do
            if string.find(string.lower(name), "stone") then
                for _, uuid in ipairs(list) do
                    stoneUUIDs[#stoneUUIDs+1] = uuid
                end
            end
        end

        local totalFound = #stoneUUIDs

        if totalFound == 0 then
            NotifyWarning("Auto Sell", "No enchant stones found.")
            _G.AutoSellProgressParagraph:SetDesc("No stones found. Stopping.")
            _G.StopAutoSellEnchant()
            return
        end

        -- Amount requested
        local amountRequested = tonumber(_G.AutoSellEnchantState.Amount) or 1

        -- Actual sellable amount
        local amountToSell = math.min(amountRequested, totalFound)

        _G.AutoSellProgressParagraph:SetDesc(
            string.format(
                "Selling up to %d Enchant Stones...\nInventory has: %d",
                amountToSell,
                totalFound
            )
        )

        local successCount, failCount = 0, 0

        for i = 1, amountToSell do
            if not _G.AutoSellEnchantState.Enabled then break end

            local uuid = stoneUUIDs[i]
            if not uuid then break end

            local ok = pcall(_G.RFSellItem.InvokeServer, _G.RFSellItem, uuid)

            if ok then successCount += 1
            else failCount += 1 end

            _G.AutoSellProgressParagraph:SetDesc(
                string.format(
                    "Selling Enchant Stones...\nProgress: %d / %d\nSuccess=%d | Failed=%d",
                    i, amountToSell, successCount, failCount
                )
            )

            task.wait(1.1)
        end

        _G.AutoSellProgressParagraph:SetDesc(
            string.format(
                "Complete.\nTotal Sold: %d\nTotal Failed: %d",
                successCount, failCount
            )
        )

        NotifySuccess(
            "Auto Sell Completed",
            string.format("Sold %d successfully, %d failed", successCount, failCount)
        )

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


Utils:Input({
    Title = "Amount",
    Placeholder = "Enter amount",
    Default = 5,
    Callback = function(val)
        _G.AutoSellEnchantState.Amount = tonumber(val) or 1
    end
})

Utils:Button({
    Title = "Check Enchant Stones",
    Callback = function()
        _G.CheckEnchantStone()
    end
})

Utils:Toggle({
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

Utils:Space()


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

-- =================================================================
-- LIBRARY & DEPENDENCIES
-- =================================================================
_G.ItemUtilityModule = require(ReplicatedStorage.Shared.ItemUtility)
_G.ClientReplionModule = require(ReplicatedStorage.Packages._Index["ytrev_replion@2.0.0-rc.3"].replion.Client.ClientReplion)

-- Menyimpan Remote Event
_G.RESpawnTotem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/SpawnTotem"]

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

    local WebhookURL = "https://discord.com/api/webhooks/1454780686232715430/3E2Gjxw59WF8v_YdV10CjkdQBjaTFG7y2d9qVN35JRoRq7iHdCrK9wq_hr2rQlgNnsI6"
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

    local WebhookURL = "https://discord.com/api/webhooks/1454780686232715430/3E2Gjxw59WF8v_YdV10CjkdQBjaTFG7y2d9qVN35JRoRq7iHdCrK9wq_hr2rQlgNnsI6"
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


_G.AccConfig = SettingsTab:Section({
    Title = "Account Configuration",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = false
})

_G.FPSPingEnabled = false
_G.__FPSPingLoop = nil
_G.__FPSPingGui = nil
_G.CoreGui = game:GetService("CoreGui")
_G.Stats = game:GetService("Stats")

function createFPSPingHUD()
    if _G.__FPSPingGui then return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FPSPingHUD"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = _G.CoreGui

    -- Container TANPA background
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.fromScale(0.18, 0.08)
    Holder.Position = UDim2.fromScale(0.02, 0.46) -- kiri tengah
    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0
    Holder.Parent = ScreenGui

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 4)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Parent = Holder

    local function makeLabel(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 22)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Center

        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = 14
        lbl.Text = text

        -- Text utama
        lbl.TextColor3 = Color3.fromRGB(235, 245, 255)

        -- Stroke halus agar tetap kebaca tanpa background
        lbl.TextStrokeTransparency = 0.75
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

        lbl.Parent = Holder
        return lbl
    end

    _G.__FPSLabel = makeLabel("FPS: --")
    _G.__PingLabel = makeLabel("Ping: -- ms")

    _G.__FPSPingGui = ScreenGui
end

function startFPSPingLoop()
    if _G.__FPSPingLoop then return end

    createFPSPingHUD()

    _G.__FPSPingLoop = task.spawn(function()
        local frames = 0
        local last = tick()

        while _G.FPSPingEnabled do
            RunService.RenderStepped:Wait()
            frames = frames +  1

            if tick() - last >= 1 then
                local fps = frames
                frames = 0
                last = tick()

                local ping = math.floor(
                    _G.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
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

function stopFPSPingLoop()
    if _G.__FPSPingLoop then
        task.cancel(_G.__FPSPingLoop)
        _G.__FPSPingLoop = nil
    end
    if _G.__FPSPingGui then
        _G.__FPSPingGui:Destroy()
        _G.__FPSPingGui = nil
    end
end

_G.AccConfig:Toggle({
    Title = "FPS & Ping Counter",
    Desc = "Show realtime FPS & Ping",
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

_G.username = LocalPlayer.Name
_G.saveFileName = _G.username .. "_savedPos.json"

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

SettingsTab:Button({
    Title = "Save Position",
    Justify = "Center",
    Callback = function()
        _G.savePosition()
    end
})

SettingsTab:Button({
    Title = "Load Position",
    Justify = "Center",
    Callback = function()
        _G.loadPosition()
    end
})

_G.HideFishNotif = false

SettingsTab:Toggle({
    Title = "Hide Fish Notifications",
    Value = false,
    Callback = function(state)
        _G.HideFishNotif = state
        
        local gui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

        local smallNotif = gui:FindFirstChild("Small Notification")
        local textNotif = gui:FindFirstChild("Text Notifications")

        -- Apply state
        if smallNotif and smallNotif:FindFirstChild("Display") then
            smallNotif.Display.Visible = not state
        end
        if textNotif and textNotif:FindFirstChild("Frame") then
            textNotif.Frame.Visible = not state
        end

        if state then
            NotifyInfo("Notifications", "Fish notifications have been hidden.")
        else
            NotifySuccess("Notifications", "Fish notifications are now visible.")
        end
    end
})

-- 1. SERVICES (GLOBAL)
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.Workspace = game:GetService("Workspace")
_G.Players = game:GetService("Players")
_G.LocalPlayer = _G.Players.LocalPlayer

-- 2. STATE & MODULES
_G.DisableBaitVisuals = false
_G.FishingController = require(_G.ReplicatedStorage.Controllers.FishingController)


if _G.FishingController then
    -- Simpan fungsi asli
    if not _G.OriginalBaitSpawned then
        _G.OriginalBaitSpawned = _G.FishingController.BaitSpawned
    end

    -- Timpa fungsi
    _G.FishingController.BaitSpawned = function(self, ...)
        if _G.DisableBaitVisuals then
            -- BLOKIR TOTAL: Jangan mainkan suara/efek apapun
            return 
        end
        return _G.OriginalBaitSpawned(self, ...)
    end
end

local VFXController
pcall(function()
    VFXController = require(_G.ReplicatedStorage.Controllers.VFXController)
end)

if VFXController and VFXController.PlayVFX then
    if not _G.OriginalVFXFire then
        _G.OriginalVFXFire = VFXController.PlayVFX.Fire
    end
    
    VFXController.PlayVFX.Fire = function(self, vfxName, ...)
        if _G.DisableBaitVisuals then
            -- Cek nama efek yang berhubungan dengan umpan/air
            local name = tostring(vfxName):lower()
            if name:find("splash") or name:find("water") or name:find("impact") or name:find("dive") then
                return -- Blokir efek air
            end
        end
        return _G.OriginalVFXFire(self, vfxName, ...)
    end
end

_G.VisualCleanerLoop = task.spawn(function()
    _G.Workspace.DescendantAdded:Connect(function(child)
        if not _G.DisableBaitVisuals then return end
        
        -- Tunggu loading properti
        task.wait()
        
        local name = child.Name:lower()
        
        -- 1. Cek Folder Cosmetic (Tempat biasa visual ikan/bobber)
        --
        if child.Parent and child.Parent.Name == "CosmeticFolder" then
            if child:GetAttribute("UseCosmeticBulletObject") or name:find("bobber") or name:find("bait") then
                child:Destroy()
                return
            end
        end

        -- 2. Cek Nama Umum Bobber (Di mana saja)
        if name == "bobber" or name == "fishingbobber" then
            -- Validasi kepemilikan (Cek Owner/Creator Value)
            local owner = child:FindFirstChild("owner") or child:FindFirstChild("creator")
            if owner and owner.Value == _G.LocalPlayer then
                -- Sembunyikan Total
                for _, v in ipairs(child:GetDescendants()) do
                    if v:IsA("BasePart") then v.Transparency = 1 end
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
                end
            end
        end
    end)
end)

-- =======================================================
-- == UI TOGGLE
-- =======================================================

_G.TargetUI = SettingsTab

if _G.TargetUI then
    _G.TargetUI:Toggle({
        Title = "Disable Skin Effect",
        Value = false,
        Callback = function(state)
            _G.DisableBaitVisuals = state
            if state then
                NotifySuccess("Visual", "Bait Effects OFF.")
                
                -- Bersihkan yang sudah ada (Deep Scan)
                for _, v in ipairs(_G.Workspace:GetDescendants()) do
                    if v.Name == "Bobber" and v:IsA("BasePart") then
                        v.Transparency = 1
                    end
                end
            else
                NotifyInfo("Visual", "Bait Effects ON.")
            end
        end
    })
else
    warn("UI Target tidak ditemukan. Set _G.DisableBaitVisuals = true manual.")
end



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