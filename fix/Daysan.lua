------------------------------------------
----- =======[ Load WindUI ]
-------------------------------------------

local Version = "1.6.53"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"))()

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
local finishRemote = net:WaitForChild("RE/FishingCompleted")

local Player = Players.LocalPlayer
local XPBar = Player:WaitForChild("PlayerGui"):WaitForChild("XP")

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

for i,v in next, getconnections(game:GetService("Players").LocalPlayer.Idled) do
                    v:Disable()
end

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


------------------------------------------
----- =======[ CHECK DATA ]
-----------------------------------------

local CheckData = {
	pasteURL = "https://raw.githubusercontent.com/quietxhub99/raul/refs/heads/main/upd.txt",
	interval = 30,
	kicked = false,
	notified = false
}

local function checkStatus()
	local success, result = pcall(function()
		return game:HttpGet(CheckData.pasteURL)
	end)

	if not success or typeof(result) ~= "string" then
		return
	end

	local response = result:upper():gsub("%s+", "")

	if response == "UPDATE" then
		if not CheckData.kicked then
			CheckData.kicked = true
			LocalPlayer:Kick("QuietXHub Premium Update Available!.")
		end
	elseif response == "LATEST" then
		if not CheckData.notified then
			CheckData.notified = true
			warn("[QuietXHub] Status: Latest version")
		end
	else
		warn("[QuietXHub] Status unknown:", response)
	end
end

checkStatus()

task.spawn(function()
	while not CheckData.kicked do
		task.wait(CheckData.interval)
		checkStatus()
	end
end)


local confirmed = false
WindUI:Popup({
    Title = "Important!",
    Icon = "rbxassetid://129260712070622",
    Content = [[
Thank you for using Premium script!.
Dont be a Stealer!
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

WindUI:AddTheme({
    Name = "Blue Ocean",
    Accent = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#5CC6FF"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#004E92"), Transparency = 0 },
    }, {
        Rotation = 90,
    }),
    Dialog = Color3.fromHex("#0B1E3F"),
    Outline = Color3.fromHex("#D0E7FF"),
    Text = Color3.fromHex("#E6F4FF"),
    Placeholder = Color3.fromHex("#94AFCB"),
    Background = Color3.fromHex("#0A192F"),
    Button = Color3.fromHex("#1E81CE"),
    Icon = Color3.fromHex("#B5DCFF")
})

WindUI.TransparencyValue = 0.3

local Window = WindUI:CreateWindow({
    Title = "Fish It",
    Icon = "crown",
    Author = "by Prince",
    Folder = "QuietXHub",
    Size = UDim2.fromOffset(600, 400),
    Transparent = true,
    Theme = "Blue Ocean",
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
    CornerRadius = UDim.new(0,19),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("21FFE0"), 
        Color3.fromHex("3C84FF")
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

local AllMenu = Window:Section({
	Title = "All Menu Here",
	Icon = "tally-3",
	Opened = false,
})

local AutoFish = AllMenu:Tab({ 
	Title = "Auto Fish", 
	Icon = "fish"
})

local AutoFarmTab = AllMenu:Tab({
	Title = "Auto Farm",
	Icon = "leaf"
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

-------------------------------------------  
    -------------------------------------------  
    ----- =======[ AUTO FISH TAB ]  
    -------------------------------------------
    
    _G.REFishingStopped = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingStopped"]
    _G.RFCancelFishingInputs = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]
    _G.REUpdateChargeState = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/UpdateChargeState"]
    
    
    _G.StopFishing = function()
        _G.RFCancelFishingInputs:InvokeServer()
    end
    
    local FuncAutoFish = {
    	REReplicateTextEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"],
    	autofish5x = false,
    	perfectCast5x = true,
    	fishingActive = false,
    	delayInitialized = false,
    	lastCatchTime5x = 0,
    	CatchLast = tick()
    }
    
    local obtainedFishUUIDs = {}
    local obtainedLimit = 30
    
    
    local RemoteFish = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]
    RemoteFish.OnClientEvent:Connect(function(_, _, data)
    	if data and data.InventoryItem and data.InventoryItem.UUID then
    		table.insert(obtainedFishUUIDs, data.InventoryItem.UUID)
    	end
    end)
    
    local function sellItems()
    	if #obtainedFishUUIDs > 0 then
    		ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]:InvokeServer()
    	end
    	obtainedFishUUIDs = {}
    end
    
    local function monitorFishThreshold5X()
    	task.spawn(function()
    		while FuncAutoFish.autofish5x do
    			if #obtainedFishUUIDs >= obtainedLimit then
    				NotifyInfo("Fish Threshold Reached", "Selling all fishes...")
    				sellItems()
    				task.wait(0.5)
    			end
    			task.wait(0.5)
    		end
    	end)
    end
    
    
    _G.REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]
    _G.REPlayFishingEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlayFishingEffect"]
    _G.equipRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
    
    _G.isSpamming = false
    _G.spamThread = nil 
    _G.COOLDOWN_SECONDS = 10
    _G.lastRecastTime = 0
    _G.DELAY_ANTISTUCK = 10
    _G.RECAST_DELAY = 0.9
    
    
    function _G.startSpam()
    	if _G.isSpamming then return end
    	_G.isSpamming = true
    	_G.spamThread = task.spawn(function()
    		while _G.isSpamming do
    			finishRemote:FireServer()
    			task.wait(0.01)
    		end
    	end)
    end
    
    function _G.stopSpam()
    	_G.isSpamming = false
    end
    
    
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
    	_G.stopSpam()
    end)
    
    
    _G.REFishCaught.OnClientEvent:Connect(function(fishName, info)
    	FuncAutoFish.lastCatchTime5x = tick()
    	FuncAutoFish.CatchLast5x = tick()	
        
    	if FuncAutoFish.autofish5x then
    		task.defer(function()
    			StartCast5X()
    		end)
    	end
    end)
    
    _G.REPlayFishingEffect.OnClientEvent:Connect(function(player, head, type)
        if FuncAutoFish.autofish5x and player == Players.LocalPlayer then
            
            task.spawn(function() 
    
                if tick() < _G.lastRecastTime + _G.COOLDOWN_SECONDS then
                    return 
                end
                
                _G.lastRecastTime = tick()
              
                
                task.wait(_G.RECAST_DELAY)
                StopCast()
                task.defer(StartCast5X)
    
            end)
        end
    end)
    
    
    
    
    function StartCast5X()
        task.spawn(function()
            local timestamp = workspace:GetServerTimeNow()
            
            _G.chargeRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
            
            local x, y
            local baseX, baseY = -0.7499996423721313, 1
            
            if FuncAutoFish.perfectCast5x then
                x, y = baseX, baseY
            else
                x = math.random(-1000, 1000) / 1000
                y = math.random(0, 1000) / 1000
            end
            
            for i = 1, 7 do
                _G.chargeRemote:InvokeServer(timestamp)
               task.wait(0.05) 
            end
            RodShake:Play()
            
            task.wait(0.05)
    
            for i = 1, 7 do
                miniGameRemote:InvokeServer(x, y)
                task.wait(0.05)
            end
            RodIdle:Play()
        end)
    end
    
    function StopCast()
    	_G.StopFishing()
    end
    
    
    function StartAutoFish5X()
    	FuncAutoFish.autofish5x = true
    	updateDelayBasedOnRod = true
    	monitorFishThreshold5X()
    	_G.lastRecastTime = tick()
    	_G.equipRemote:FireServer(1)
    	task.wait(0.05)
    	StartCast5X()
    	StartAutoFishMonitor5x()
    end
    
    function StopAutoFish5X()
    	FuncAutoFish.autofish5x = false
    	FuncAutoFish.delayInitialized = false
    	_G.StopFishing()
    	StopAutoFishMonitor5x()
    end
    
    
    
    _G.AutoFishMonitor5x = _G.AutoFishMonitor5x or { Running = false }
    
    function StartAutoFishMonitor5x()
    	if _G.AutoFishMonitor5x.Running then return end
    	_G.AutoFishMonitor5x.Running = true
    
    	task.spawn(function()
    		while _G.AutoFishMonitor5x.Running do
    			task.wait(1)
    
    			if FuncAutoFish and FuncAutoFish.autofish5x then
    				local idle = tick() - (FuncAutoFish.CatchLast5x or tick())
    				if idle >= _G.DELAY_ANTISTUCK then
    					NotifyWarning("Auto Fish", string.format("No fish caught for %.0f seconds, restarting...", idle))
    					StopAutoFish5X()
    					repeat task.wait(0.5)
    					until not FuncAutoFish.autofish5x
    
    					task.wait(3)
    					StartAutoFish5X()
    					FuncAutoFish.CatchLast5x = tick()
    					NotifySuccess("Auto Fish", "Restarted successfully")
    				end
    			else
    				task.wait(2)
    			end
    		end
    	end)
    end
    
    function StopAutoFishMonitor5x()
    	_G.AutoFishMonitor5x.Running = false
    end
    
    _G.FishSec = AutoFish:Section({
    	Title = "Auto Fishing 5X Speed",
    	TextSize = 22,
    	TextXAlignment = "Center",
    	Opened = true
    })
    
    _G.RecastCD = _G.FishSec:Slider({
        Title = "Recast Cooldown",
        Step = 1,
        Value = {
            Min = 5,
            Max = 100000000000,
            Default = _G.COOLDOWN_SECONDS,
        },
        Callback = function(value)
            _G.COOLDOWN_SECONDS = value
        end
    })
    
    myConfig:Register("CDRecast", _G.RecastCD)
    
    _G.Delay5X = _G.FishSec:Slider({
        Title = "Recast Delay",
        Step = 0.1,
        Value = {
            Min = 0.5,
            Max = 100000000,
            Default = _G.RECAST_DELAY,
        },
        Callback = function(value)
            _G.RECAST_DELAY_V2 = value
        end
    })
    
    myConfig:Register("DelaySpeed", _G.Delay5X)
    
    _G.Delay5X = _G.FishSec:Slider({
        Title = "Anti Stuck Delay",
        Step = 1,
        Value = {
            Min = 1,
            Max = 100,
            Default = _G.DELAY_ANTISTUCK,
        },
        Callback = function(value)
            _G.DELAY_ANTISTUCK = value
        end
    })

_G.BNSell = true
local FishThres = _G.FishSec:Input({
	Title = "Sell Threshold",
	Placeholder = "Example: 1500",
	Callback = function(value)
	  if _G.BNSell then
			_G.BNSell = false
			return
		end	
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

_G.AutoFishes = _G.FishSec:Toggle({
	Title = "Auto Fish",
	Callback = function(value)
		if value then
			StartAutoFish()
		else
			StopAutoFish()
		end
	end
})

myConfig:Register("AutoFish", _G.AutoFishes)

_G.FishSec:Space()

_G.REReplicateCutscene = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateCutscene"]

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
    end
})

_G.FishSec:Space()

local PerfectCast = _G.FishSec:Toggle({
    Title = "Auto Perfect Cast",
    Value = true,
    Callback = function(value)
        FuncAutoFish.perfectCast = value
    end
})
myConfig:Register("Prefect", PerfectCast)

local REEquipItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]
local RFSellItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellItem"]

local autoSellMythic = false
local SMBlockNotif = true

function ToggleAutoSellMythic(state)
	if SMBlockNotif then
		SMBlockNotif = false
		return
	end
	autoSellMythic = state
	if autoSellMythic then
		NotifySuccess("AutoSellMythic", "Status: ON")
	else
		NotifyWarning("AutoSellMythic", "Status: OFF")
	end
end

local oldFireServer
oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
	local args = {...}
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

_G.FishSec:Toggle({
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
    Title = "Auto Enchant Rod",
    Justify = "Center",
    Icon = "",
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

_G.FishSec:Space()

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
    part.Position = position or (LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, -3, 0)) or Vector3.new(0,5,0)    
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
        createLocalBlock(Vector3.new(6,1,6), hrp.Position - Vector3.new(0, 3, 0), Color3.fromRGB(0,0,255))    
    end    
end    


local function ToggleBlockOnce(state)
    BlockEnabled = state
    if state then
        createBlockUnderPlayer()
    else
        if workspace:FindFirstChild("LocalBlock") then
            workspace.LocalBlock:Destroy()
        end
    end
end

local knownEvents = {}

local eventCodes = {
	["1"] = "Ghost Shark Hunt",
	["2"] = "Shark Hunt",
	["3"] = "Worm Hunt",
	["4"] = "Black Hole",
	["5"] = "Meteor Rain",
	["6"] = "Ghost Worm",
	["7"] = "Shocked",
	["8"] = "Megalodon Hunt",
}

local autoTPEvent = false
local savedCFrame = nil
local alreadyTeleported = false
local teleportTime = nil
local selectedEvent = nil

local function teleportTo(position)
	local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 20, 0))
	end
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

local function findEventModel(eventName)
    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
    if menuRings and menuRings:FindFirstChild("Props") then
        local props = menuRings.Props
        local eventModel = props:FindFirstChild(eventName)
        
        if eventModel and eventModel:IsA("Model") then
            if eventName == "Megalodon Hunt" then
                local colorPart = eventModel:FindFirstChild("Color")
                if colorPart and colorPart:IsA("BasePart") then
                    return colorPart
                end
            end

            if eventName == "Worm Hunt" or eventName == "Ghost Worm" then
                for _, part in ipairs(eventModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local linkedEvent = part:GetAttribute("LinkedEvent")
                        if linkedEvent and typeof(linkedEvent) == "string" then
                            if eventName:find("Ghost Worm") and linkedEvent:find("Admin - Ghost Worm") then
                                return part
                            elseif eventName == "Worm Hunt" and linkedEvent:find("Worm Hunt") then
                                return part
                            end
                        end
                    end
                end
            end

            if eventModel.PrimaryPart then
                return eventModel.PrimaryPart
            end
            local firstPart = eventModel:FindFirstChildWhichIsA("BasePart", true)
            if firstPart then
                return firstPart
            end
        end
    end


    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name:match("^Props") then
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("Model") and child.Name == eventName then
                    if eventName == "Megalodon Hunt" then
                        local colorPart = child:FindFirstChild("Color")
                        if colorPart and colorPart:IsA("BasePart") then
                            return colorPart
                        end
                    end
                    if eventName == "Worm Hunt" or eventName == "Ghost Worm" then
                        for _, part in ipairs(child:GetDescendants()) do
                            if part:IsA("BasePart") then
                                local linkedEvent = part:GetAttribute("LinkedEvent")
                                if linkedEvent and typeof(linkedEvent) == "string" then
                                    if eventName:find("Ghost Worm") and linkedEvent:find("Admin - Ghost Worm") then
                                        return part
                                    elseif eventName == "Worm Hunt" and linkedEvent:find("Worm Hunt") then
                                        return part
                                    end
                                end
                            end
                        end
                    end
                    if child.PrimaryPart then
                        return child.PrimaryPart
                    end
                    local firstPart = child:FindFirstChildWhichIsA("BasePart", true)
                    if firstPart then
                        return firstPart
                    end
                end
            end
        end
    end
    return nil
end

-- loop utama
local function monitorAutoTP()
	while true do
		if autoTPEvent and selectedEvent then
			local eventModel = findEventModel(selectedEvent)

			if eventModel and not alreadyTeleported then
				saveOriginalPosition()

				local targetPos
				if eventModel:IsA("BasePart") then
					targetPos = eventModel.Position
				elseif eventModel:IsA("Model") then
					targetPos = eventModel:GetPivot().Position
				end

				if targetPos then
					teleportTo(targetPos)
					if typeof(ToggleBlockOnce) == "function" then
						ToggleBlockOnce(true)
					end
					alreadyTeleported = true
					teleportTime = tick()
					NotifySuccess("Event Farm", "Teleported to: " .. selectedEvent)
				end

			elseif alreadyTeleported then
				-- timeout 15 menit
				if teleportTime and (tick() - teleportTime >= 900) then
					returnToOriginalPosition()
					if typeof(ToggleBlockOnce) == "function" then
						ToggleBlockOnce(false)
					end
					alreadyTeleported = false
					teleportTime = nil
					NotifyInfo("Event Timeout", "Returned after 15 minutes.")
				-- event hilang
				elseif not eventModel then
					returnToOriginalPosition()
					if typeof(ToggleBlockOnce) == "function" then
						ToggleBlockOnce(false)
					end
					alreadyTeleported = false
					teleportTime = nil
					NotifyInfo("Event Ended", "Returned to start position.")
				end
			end

		else
			-- autoTP mati
			if alreadyTeleported then
				returnToOriginalPosition()
				if typeof(ToggleBlockOnce) == "function" then
					ToggleBlockOnce(false)
				end
				alreadyTeleported = false
				teleportTime = nil
			end
		end
		task.wait(1)
	end
end

task.spawn(monitorAutoTP)

local selectedIsland = "09"
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
    ["16"] = "Hallowen Bay"
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
    	CFrame.new(1470.30334, -12.2246475, -587.052612, -0.101084575, -9.68974163e-08, 0.994877815, -1.47451953e-08, 1, 9.5898109e-08, -0.994877815, -4.97584818e-09, -0.101084575),
    	CFrame.new(1451.19983, -22.1250019, -621.852478, -0.986927867, 8.68970318e-09, -0.161162451, 9.61592317e-09, 1, -4.96716179e-09, 0.161162451, -6.4519563e-09, -0.986927867),
    	CFrame.new(1499.44788, -22.1250019, -628.441711, -0.985374331, 7.20484294e-08, -0.170403719, 8.45688035e-08, 1, -6.62162876e-08, 0.170403719, -7.9658669e-08, -0.985374331)
    },
    ["Hallowen Bay"] = {
    	CFrame.new(2105.58081, 81.0309219, 3298.1272, -0.224424303, 1.09558606e-07, -0.974491537, 4.02455669e-08, 1, 1.03157923e-07, 0.974491537, -1.60678173e-08, -0.224424303),
    	CFrame.new(2145.21313, 80.654747, 3337.37964, 0.95964092, 2.26037873e-08, 0.281228244, 8.77089373e-11, 1, -8.06745319e-08, -0.281228244, 7.74432465e-08, 0.95964092),
    	CFrame.new(2107.62061, 79.7328796, 3328.46313, 0.713486373, 4.63640433e-08, -0.70066911, -2.2098936e-08, 1, 4.36679102e-08, 0.70066911, -1.56724163e-08, 0.713486373)
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

AutoFarmTab:Section({
	Title = "Auto Farming Menu",
	TextSize = 22,
	TextXAlignment = "Center",
})

local CodeIsland = AutoFarmTab:Dropdown({
    Title = "Farm Island",
    Values = nameList,
    Value = nameList[9],
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

myConfig:Register("AutoFarmStart", AutoFarm)


local eventNames = {}
for _, name in pairs(eventCodes) do
	table.insert(eventNames, name)
end

AutoFarmTab:Dropdown({
	Title = "Auto Teleport Event",
	Desc = "Select event to auto teleport",
	Values = eventNames,
	Callback = function(selected)
		selectedEvent = selected
		autoTPEvent = true
		NotifyInfo("Event Selected", "Now monitoring event: " .. selectedEvent)
	end
})

-------------------------------------------
----- =======[ MASS TRADE TAB ]
-------------------------------------------

Trade:Section({
	Title = "Auto Trade Menu",
	TextSize = 22,
	TextXAlignment = "Center",
})

local TradeFunction = {
	TempTradeList = {},
	saveTempMode = false,
	onTrade = false,
	targetUserId = nil,
	tradingInProgress = false,
	autoAcceptTrade = false,
	AutoTrade = false
}

local RETextNotification = net["RE/TextNotification"]
local RFAwaitTradeResponse = net["RF/AwaitTradeResponse"]
local InitiateTrade = net["RF/InitiateTrade"]

local function getPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.DisplayName .. " (" .. player.Name .. ")")
        end
    end
    return list
end

local TradeTargetDropdown = Trade:Dropdown({
    Title = "Select Trade Target",
    Values = getPlayerList(),
    Value = getPlayerList()[1] or nil,
    Callback = function(selected)
        local username = selected:match("%((.-)%)")
        local player = Players:FindFirstChild(username)
        if player then
            TradeFunction.targetUserId = player.UserId
            NotifySuccess("Trade Target", "Target found: " .. player.Name)
        else
            NotifyError("Trade Target", "Player not found!")
        end
    end
})

local function refreshDropdown()
    local updatedList = getPlayerList()
    TradeTargetDropdown:Refresh(updatedList)
end

Players.PlayerAdded:Connect(refreshDropdown)
Players.PlayerRemoving:Connect(refreshDropdown)

refreshDropdown()

Trade:Toggle({
    Title = "Mode Save Items",
    Desc = "Click inventory item to add for Mass Trade",
    Value = false,
    Callback = function(state)
        TradeFunction.saveTempMode = state
        if state then
            TradeFunction.TempTradeList = {}
            NotifySuccess("Save Mode", "Enabled - Click items to save")
        else
            NotifyInfo("Save Mode", "Disabled - "..#TradeFunction.TempTradeList.." items saved")
        end
    end
})


_G.REEquipItem = game:GetService("ReplicatedStorage")
    .Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if method == "FireServer" and self == _G.REEquipItem then
        local uuid, categoryName = args[1], args[2]

        if TradeFunction.saveTempMode then
            if uuid and categoryName then
                table.insert(TradeFunction.TempTradeList, {
                    UUID = uuid,
                    Category = categoryName
                })
                NotifySuccess("Save Mode", "Added item: " .. uuid .. " (" .. categoryName .. ")")
            else
                NotifyError("Save Mode", "Invalid data received.")
            end
            return nil
        end

        -- Mode Trade
        if TradeFunction.onTrade then
            if uuid and TradeFunction.targetUserId then
                InitiateTrade:InvokeServer(TradeFunction.targetUserId, uuid)
                NotifySuccess("Trade Sent", "Trade sent to " .. TradeFunction.targetUserId)
            else
                NotifyError("Trade Error", "Invalid target or item.")
            end
            return nil
        end
    end

    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

local function TradeAll()        
    if TradeFunction.tradingInProgress then        
        NotifyWarning("Mass Trade", "Trade already in progress!")        
        return        
    end        
    if not TradeFunction.targetUserId then        
        NotifyError("Mass Trade", "Set trade target first!")        
        return        
    end        
    if #TradeFunction.TempTradeList == 0 then        
        NotifyWarning("Mass Trade", "No items saved!")        
        return        
    end        
        
    TradeFunction.tradingInProgress = true        
    NotifyInfo("Mass Trade", "Starting trade of "..#TradeFunction.TempTradeList.." items...")        
        
    task.spawn(function()        
        for i, item in ipairs(TradeFunction.TempTradeList) do        
            if not TradeFunction.AutoTrade then        
                NotifyWarning("Mass Trade", "Auto Trade stopped!")        
                break        
            end        
        
            local uuid = item.UUID        
            local category = item.Category        
        
            NotifyInfo("Mass Trade", "Trade item "..i.." of "..#TradeFunction.TempTradeList)        
            InitiateTrade:InvokeServer(TradeFunction.targetUserId, uuid, category)        
        
            local tradeCompleted = false        
            local timeout = 15        
            local elapsed = 0        
            local lastTrigger = 0
            local cooldown = 0.5        
        
            local notifGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Text Notifications")
            local connection
            connection = notifGui.Frame.ChildAdded:Connect(function(child)
                if child.Name == "TextTile" then
                    task.wait(0.5)
                    local header = child:FindFirstChild("Header")
                    if header and header:IsA("TextLabel") and header.Text == "Trade completed!" then
                        local now = tick()
                        if now - lastTrigger > cooldown then
                            lastTrigger = now
                            tradeCompleted = true
                            NotifySuccess("Mass Trade", "Success "..i.." of "..#TradeFunction.TempTradeList)
                        end
                    end
                end
            end)        
        
            repeat        
                task.wait(0.2)        
                elapsed += 0.2        
            until tradeCompleted or elapsed >= timeout        
        
            if connection then        
                connection:Disconnect()        
            end        
        
            if not tradeCompleted then        
                NotifyWarning("Mass Trade", "Trade timeout for item "..i)        
            else        
                task.wait(6.5)        
            end        
        end        
        
        NotifySuccess("Mass Trade", "Finished trading!")        
        TradeFunction.tradingInProgress = false        
        TradeFunction.TempTradeList = {}        
    end)        
end

Trade:Toggle({
    Title = "Auto Trade",
    Desc = "Trade all saved items automatically",
    Value = false,
    Callback = function(state)
        TradeFunction.AutoTrade = state
        if TradeFunction.AutoTrade then
            if #TradeFunction.TempTradeList == 0 then
                NotifyError("Mass Trade", "No items saved to trade!")
                TradeFunction.AutoTrade = false
                return
            end
            TradeAll()
            NotifySuccess("Mass Trade", "Auto Trade Enabled")
        else
            NotifyWarning("Mass Trade", "Auto Trade Disabled")
        end
    end
})

local OTBlockNotif = true

Trade:Toggle({
    Title = "Trade (Original)",
    Desc = "Click inventory items to Send Trade",
    Value = false,
    Callback = function(state)
				if OTBlockNotif then
					OTBlockNotif = false
					return
				end
        TradeFunction.onTrade = state
        if state then
            NotifySuccess("Trade", "Trade Mode Enabled. Click an item to send trade.")
        else
            NotifyWarning("Trade", "Trade Mode Disabled.")
        end
    end
})

local RFAwaitTradeResponse = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/AwaitTradeResponse"]

local autoAcceptTrade = false
local TRADE_DELAY = 3

RFAwaitTradeResponse.OnClientInvoke = function(fromPlayer, timeNow)
	if autoAcceptTrade then

		task.wait(TRADE_DELAY)

		local newTime = workspace:GetServerTimeNow() + TRADE_DELAY

		return true
	else
		return nil
	end
end

Trade:Toggle({
	Title = "Auto Accept Trade",
	Value = false,
	Callback = function(state)
		autoAcceptTrade = state
		if state then
			NotifySuccess("Trade", "Auto Accept Trade Enabled")
		else
			NotifyWarning("Trade", "Auto Accept Trade Disabled")
		end
	end
})

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

_G.RFUpdateFishingRadar = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/UpdateFishingRadar"]

_G.radarEnabled = false

Utils:Toggle({
    Title = "Fishing Radar",
    Value = false,
    Callback = function(state)
        _G.radarEnabled = state
        local success, result = pcall(function()
            return _G.RFUpdateFishingRadar:InvokeServer(_G.radarEnabled)
        end)
        if success then
            if _G.radarEnabled then
                NotifySuccess("Radar", "Enabled")
            else
                NotifySuccess("Radar", "Disabled")
            end
        else
            warn("[⚠️] Gagal memperbarui status radar:", result)
        end
    end
})


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
	["17"] = { name = "Hallowen Bay", position = Vector3.new(1875, 23, 3086) }
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


-------------------------------------------
----- =======[ FISH NOTIF TAB ]
-------------------------------------------

FishNotif:Section({
	Title = "Webhook Menu",
	TextSize = 22,
	TextXAlignment = "Center",
})

local LocalPlayer = game:GetService("Players").LocalPlayer
local REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]

local webhookPath = nil
local FishWebhookEnabled = true

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
	local requestFunc = syn and syn.request or http and http.request or http_request or request or fluxus and fluxus.request
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

local FishCategories = {
	["Secret"] = {
		"Blob Shark","Great Christmas Whale","Frostborn Shark","Great Whale","Worm Fish","Robot Kraken",
		"Giant Squid","Ghost Worm Fish","Ghost Shark","Queen Crab","Orca","Crystal Crab","Monster Shark","Eerie Shark", "Scare", "Thin Armor Shark", "Orca", "Lochness Monster", "Megalodon", "Phanter Eel", "Mosasaur Shark", "King Jelly", "Bone Whale", "Elshark Gran Maja", "Ancient Whale", "Zombie Megalodon", "Zombie Shark", "Dead Zombie Shark", 
	},
	["Mythic"] = {
		"Gingerbread Shark","Loving Shark","King Crab","Blob Fish","Luminous Fish",
		"Plasma Shark","Abyss Seahorse","Blueflame Ray","Hammerhead Shark","Hawks Turtle",
		"Manta Ray","Loggerhead Turtle","Prismy Seahorse","Gingerbread Turtle", "Armor Catfish", "Armor Thin Shark", "Strippled Seahorse","Thresher Shark","Dotted Stingray", "Sharp One", "Hybodius Shark", "Crocodile", "Ancient Relic Crocodile", "Mammoth Appafish", "Crystal Salamender", "Frankenstein Longsnapper", "Dark Pumpkin Appafish", "Pumpkin Ray", "Mythic Reaver Scythe",
	},
	["Legendary"] = {
		"Yellowfin Tuna","Lake Sturgeon","Lined Cardinal Fish","Saw Fish","Slurpfish Chromis","Chrome Tuna","Lobster", "Bumblebee Grouper","Lavafin Tuna","Blue Lobster","Greenbee Grouper","Starjam Tang","Magic Tang", "Enchanted Angelfish","Axolotl","Deep Sea Crab", "Temple Spokes Tuna", "Manoai Statue Fish", "Pumpkin Carved Shark", "Pumpkin StoneTrutle", "Wizard Stingray", "Pumpkin Jellyfish",
	},
}


local FishDataById = {}
for _, item in pairs(ReplicatedStorage.Items:GetChildren()) do
	local ok, data = pcall(require, item)
	if ok and data.Data and data.Data.Type == "Fishes" then
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

FishNotif:Dropdown({
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

local function sendFishWebhook(fishName, rarityText, assetId, itemId, variantId)
	if not webhookPath or webhookPath == "" then
		warn("Invalid Webhook Path")
		return
	end

	local WebhookURL = "https://discord.com/api/webhooks/" .. webhookPath
	local username = LocalPlayer.DisplayName
	local imageUrl = GetRobloxImage(assetId)
	if not imageUrl then return end

	local caught = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Caught")
	local rarest = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Rarest Fish")

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

	safeHttpRequest({
		Url = WebhookURL,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = HttpService:JSONEncode(data)
	})
end

local LastCatchData = {}

REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, metadata)
	LastCatchData.ItemId = itemId
	LastCatchData.VariantId = metadata and metadata.VariantId
end)

local function startFishDetection()
	local plr = LocalPlayer
	local guiNotif = plr.PlayerGui:WaitForChild("Small Notification"):WaitForChild("Display"):WaitForChild("Container")

	local fishText = guiNotif:WaitForChild("ItemName")
	local rarityText = guiNotif:WaitForChild("Rarity")
	local imageFrame = plr.PlayerGui["Small Notification"]:WaitForChild("Display"):WaitForChild("VectorFrame"):WaitForChild("Vector")

	fishText:GetPropertyChangedSignal("Text"):Connect(function()
		local fishName = fishText.Text
		if isTargetFish(fishName) then
			local rarity = rarityText.Text
			local assetId = string.match(imageFrame.Image, "%d+")
			if assetId then
				sendFishWebhook(fishName, rarity, assetId, LastCatchData.ItemId, LastCatchData.VariantId)
			end
		end
	end)
end

startFishDetection()


-------------------------------------------
----- =======[ SETTINGS TAB ]
-------------------------------------------


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

SettingsTab:Button({
    Title = "Load",
    Justify = "Center",
    Icon = "",
    Callback = function()
        myConfig:Load()
        NotifySuccess("Config Loaded", "Config has beed loaded!")
    end
})