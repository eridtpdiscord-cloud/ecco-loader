-- ECCO HUB v7.0 MASTER OVERHAUL - Storage Hunters: Open World
-- Built automatically by Python
local __MODULES = {}
local function require(name)
    if not __MODULES[name] then error('Module not found: ' .. name) end
    if type(__MODULES[name]) == 'function' then
        __MODULES[name] = __MODULES[name]()
    end
    return __MODULES[name]
end

__MODULES['main'] = function()
local StateMod = require("core/state")
local Window = require("ui/window")
local AutoFarm = require("features/autofarm")
local ESP = require("features/esp")
local PlayerMods = require("features/player")
local Auction = require("features/auction")
local Workshop = require("features/workshop")
local Utils = require("core/utils")

local Main = {}

function Main.init()
    -- Load saved config if any
    StateMod.LoadConfig()

    -- Initialize UI
    local win = Window.init()

    -- Start background features
    AutoFarm.start()
    ESP.start()
    PlayerMods.start()
    Auction.start()
    Workshop.start()

    -- Global keybind to toggle UI
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == StateMod.STATE.Keybind then
            local targetSG = win and win.SG
            if not targetSG or not targetSG.Parent then
                local gethuiFn = gethui or function() return nil end
                targetSG = gethuiFn() and gethuiFn():FindFirstChild("EccoHub_Overhauled")
                    or game:GetService("CoreGui"):FindFirstChild("EccoHub_Overhauled")
                    or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("EccoHub_Overhauled")
            end
            if targetSG and targetSG:FindFirstChild("MainFrame") then
                targetSG.MainFrame.Visible = not targetSG.MainFrame.Visible
            end
        end
    end)

    Utils.notify("Ecco Hub - Storage Hunters v7.0 (Overhauled) Loaded!")
    print("[EccoHub] Modular engine initialized successfully.")
end

Main.init()
return Main

end

__MODULES['core/remotes'] = function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")

local Remotes = {}

local function safeGet(parent, name)
    if parent then
        return parent:FindFirstChild(name)
    end
    return nil
end

-- Auction
local Auction = safeGet(Events, "Auction")
Remotes.Bid = safeGet(Auction, "Bid")
Remotes.WinningBid = safeGet(Auction, "UpdateCurrentWinningBid")
Remotes.ToggleBiddingUI = safeGet(Auction, "ToggleBiddingUI")
Remotes.LeaveAuction = safeGet(Auction, "LeaveAuction")

-- Dragging & Inventory
Remotes.PickUpItem = safeGet(safeGet(Events, "Dragging"), "PickUpItem")
Remotes.GetInventory = safeGet(safeGet(Events, "Inventory"), "GetPlayerInventory")

-- Vehicles
local Vehicles = safeGet(Events, "Vehicles")
Remotes.GetOwnedVehicles = safeGet(Vehicles, "GetOwnedVehicles")
Remotes.SpawnVehicle = safeGet(Vehicles, "RequestSpawn")
Remotes.GetVehicleItems = safeGet(Vehicles, "GetVehicleItems")
Remotes.TransferToVehicle = safeGet(Vehicles, "TransferInventoryItemToVehicle")
Remotes.TransferToInv = safeGet(Vehicles, "TransferVehicleItemsToInventory")
Remotes.TransferVehicleFull = safeGet(Vehicles, "TransferVehicleToInventory")

-- Plot
local Plot = safeGet(Events, "Plot")
Remotes.PlaceStock = safeGet(Plot, "PlaceStockItem")
Remotes.SellItem = safeGet(Plot, "SellItem")
Remotes.ChangeStockPrice = safeGet(Plot, "ChangeStockPrice")
Remotes.RequestPlotData = safeGet(Plot, "RequestPlotData")

-- UI & Pawn
local UI = safeGet(Events, "UI")
Remotes.ClaimLostItem = safeGet(UI, "ClaimLostItem")
Remotes.GetLostItems = safeGet(UI, "GetLostItems")
Remotes.QuestTriggered = safeGet(UI, "QuestPromptTriggered")
Remotes.QuestDialogResult = safeGet(UI, "SendQuestDialogResult")
Remotes.PawnSell = safeGet(safeGet(Events, "Pawn"), "SellItems")

-- NPC Offers
local NPCShopper = safeGet(Events, "NPCShopper")
Remotes.RespondOffer = safeGet(NPCShopper, "RespondOffer")
Remotes.ShowOffer = safeGet(NPCShopper, "ShowOffer")

-- Workshops
Remotes.Workshops = {
    Wash = {},
    Repair = {},
    Grading = {},
    Locksmith = {}
}

local function mapWorkshop(category)
    local folder = safeGet(Events, category)
    if not folder then return end
    
    local map = Remotes.Workshops[category]
    if category == "Wash" then
        map.GetItems = safeGet(folder, "GetWashableItems")
        map.GetSlots = safeGet(folder, "GetSlotState")
        map.Start = safeGet(folder, "StartWash")
        map.Claim = safeGet(folder, "ClaimWashedItem")
        map.Unlock = safeGet(folder, "UnlockSlot")
        map.SpeedUp = safeGet(folder, "SpeedUpWash")
    elseif category == "Repair" then
        map.GetItems = safeGet(folder, "GetRepairableItems")
        map.GetSlots = safeGet(folder, "GetSlotState")
        map.Start = safeGet(folder, "StartRepair")
        map.Claim = safeGet(folder, "ClaimRepairedItem")
        map.Unlock = safeGet(folder, "UnlockSlot")
        map.SpeedUp = safeGet(folder, "SpeedUpRepair")
    elseif category == "Grading" then
        map.GetItems = safeGet(folder, "GetGradableItems")
        map.GetSlots = safeGet(folder, "GetSlotState")
        map.Start = safeGet(folder, "StartGrading")
        map.Claim = safeGet(folder, "ClaimGradedItem")
        map.Unlock = safeGet(folder, "UnlockSlot")
        map.SpeedUp = safeGet(folder, "SpeedUpGrading")
    elseif category == "Locksmith" then
        map.GetItems = safeGet(folder, "GetLockableItems")
        map.GetSlots = safeGet(folder, "GetSlotState")
        map.Start = safeGet(folder, "StartLocksmith")
        map.Claim = safeGet(folder, "ClaimItem")
        map.Unlock = safeGet(folder, "UnlockSlot")
        map.SpeedUp = safeGet(folder, "SpeedUp")
    end
end

mapWorkshop("Wash")
mapWorkshop("Repair")
mapWorkshop("Grading")
mapWorkshop("Locksmith")

return Remotes

end

__MODULES['core/state'] = function()
local HttpService = game:GetService("HttpService")

local STATE = {
    AutoFarmEnabled     = false,
    FarmPreset          = "Everything",
    FarmModes           = {
        AutoAuction         = false,
        AutoLoad            = false,
        AutoUnload          = false,
        AutoPlace           = false,
        AutoSell            = false,
        AutoOffers          = false,
        AutoQuests          = false,
        WorkshopCollection  = false,
        WorkshopAutoStart   = false,
        AutoLostItems       = false,
        AutoStaff           = false,
        AutoUpgrades        = false,
        AutoClaims          = false,
        AutoMuseum          = false,
    },
    TransportMethod     = "Teleport Truck to Me",
    QuestPriority       = "All NPCs (Auto)",
    BlacklistRarity     = "None",
    MaxPriceFilter      = 0,
    AutoLoad            = false,
    AutoUnload          = false,
    AutoSell            = false,
    AutoPlace           = false,
    AutoAcceptOffers    = false,
    PriceMultiplier     = 20,
    AutoWash            = false,
    AutoRepair          = false,
    AutoGrading         = false,
    AutoLocksmith       = false,
    AutoCollectWorkshop = false,
    AutoStaff           = false,
    AutoStaffTargetLevel= 5,
    AutoUpgrades        = false,
    UpgradeRoute        = "Optimal All-Round",
    PriorityUpgrade     = "InventorySpace",
    AutoClaimAchievements  = false,
    AutoClaimCollections   = false,
    AutoClaimDailyRewards  = false,
    AutoMuseum             = false,
    MuseumMinRarity        = "Uncommon",
    MuseumMaxValue         = 5000,
    AutoBid             = false,
    AutoAuction         = false,
    PrioritizeAuction   = false,
    AutoAuctionPriority = "Default (All)",
    BidMode             = "Budget",
    MaxBudget           = 5000,
    BidDelay            = 0.3,
    CurrentAuctionBid   = 0,
    AuctionActive       = false,
    WalkSpeedMult       = 1,
    JumpPowerMult       = 1,
    InfiniteJump        = false,
    Noclip              = false,
    FlyEnabled          = false,
    FlySpeed            = 50,
    AntiAFK             = false,
    FpsBoost            = false,
    DisableShadows      = false,
    Fullbright          = false,
    RemoveFOG           = false,
    Keybind             = Enum.KeyCode.RightShift,
    Binding             = false,
    Minimized           = false,
    ESPEnabled          = false,
    ESPShowPrice        = true,
    ESPShowRarity       = true,
    ESPShowDistance     = true,
    ESPRenderDistance   = 500,
    ESPColorTiers       = {
        Common            = Color3.fromRGB(180, 180, 180),
        Uncommon          = Color3.fromRGB(80, 220, 100),
        Rare              = Color3.fromRGB(60, 150, 255),
        Epic              = Color3.fromRGB(170, 70, 240),
        Legendary         = Color3.fromRGB(255, 170, 30),
        ExtremelyValuable = Color3.fromRGB(240, 50, 60),
    },
    Busy                = false,
    Status              = "Idle",
}

local ConfigModule = {}
ConfigModule.STATE = STATE

function ConfigModule.SaveConfig()
    local c = {}
    for k, v in pairs(STATE) do
        if type(v) ~= "function" and k ~= "Busy" and k ~= "Status" and k ~= "AuctionActive" and k ~= "CurrentAuctionBid" then
            if typeof(v) == "Color3" then
                c[k] = { r = math.floor(v.R * 255), g = math.floor(v.G * 255), b = math.floor(v.B * 255) }
            elseif typeof(v) == "EnumItem" then
                c[k] = v.Name
            elseif type(v) == "table" then
                local tbl = {}
                for subK, subV in pairs(v) do
                    if typeof(subV) == "Color3" then
                        tbl[subK] = { r = math.floor(subV.R * 255), g = math.floor(subV.G * 255), b = math.floor(subV.B * 255) }
                    else
                        tbl[subK] = subV
                    end
                end
                c[k] = tbl
            else
                c[k] = v
            end
        end
    end
    pcall(function()
        if writefile then
            writefile("EccoHub_StorageHunters_Config.json", HttpService:JSONEncode(c))
        end
    end)
end

function ConfigModule.LoadConfig()
    pcall(function()
        if readfile and isfile and isfile("EccoHub_StorageHunters_Config.json") then
            local dec = HttpService:JSONDecode(readfile("EccoHub_StorageHunters_Config.json"))
            if type(dec) == "table" then
                for k, v in pairs(dec) do
                    if STATE[k] ~= nil then
                        if k == "Keybind" and type(v) == "string" and Enum.KeyCode[v] then
                            STATE[k] = Enum.KeyCode[v]
                        elseif k == "ESPColorTiers" and type(v) == "table" then
                            for tier, colorData in pairs(v) do
                                if type(colorData) == "table" and colorData.r and colorData.g and colorData.b then
                                    STATE.ESPColorTiers[tier] = Color3.fromRGB(colorData.r, colorData.g, colorData.b)
                                end
                            end
                        else
                            STATE[k] = v
                        end
                    end
                end
            end
        end
    end)
end

return ConfigModule

end

__MODULES['core/utils'] = function()
local Players = game:GetService("Players")

local Utils = {}

function Utils.getLocalPlayer()
    return Players.LocalPlayer
end

function Utils.getCharacter()
    local lp = Utils.getLocalPlayer()
    if lp then
        return lp.Character
    end
    return nil
end

function Utils.getHumanoid()
    local char = Utils.getCharacter()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

function Utils.getHRP()
    local char = Utils.getCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function Utils.fireProximityPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        if fireproximityprompt then
            pcall(function() fireproximityprompt(prompt) end)
        else
            local oldLine = prompt.LineOfSight
            prompt.LineOfSight = false
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(prompt.HoldDuration + 0.05)
                prompt:InputHoldEnd()
            end)
            prompt.LineOfSight = oldLine
        end
    end
end

function Utils.notify(text)
    -- Could hook up to Roblox's StarterGui SetCore("SendNotification")
    local sg = game:GetService("StarterGui")
    pcall(function()
        sg:SetCore("SendNotification", {
            Title = "Ecco Hub",
            Text = text,
            Duration = 3
        })
    end)
end

return Utils

end

__MODULES['features/auction'] = function()
local RunService = game:GetService("RunService")
local Remotes = require("core/remotes")
local StateMod = require("core/state")
local Utils = require("core/utils")
local STATE = StateMod.STATE

local Auction = {}

-- Safely resolve GaragesDB once to avoid constant requiring
local RS = game:GetService("ReplicatedStorage")
local GaragesDB
pcall(function()
    GaragesDB = require(RS.Modules.Garages)
end)

local function getAuctionProfitability(auctionData)
    -- Stub for analyzing GaragesDB against auctionData to determine ROI
    -- For now, return a high number to bid if it's within budget
    return 999999 
end

function Auction.start()
    -- Event-Driven Bid Engine
    if Remotes.WinningBid then
        Remotes.WinningBid.OnClientEvent:Connect(function(newBid, bidderName)
            STATE.CurrentAuctionBid = tonumber(newBid) or 0
            
            -- If we are in an active auction and AutoBid is enabled
            if STATE.AutoBid and STATE.AuctionActive then
                local lp = Utils.getLocalPlayer()
                if bidderName and lp and bidderName == lp.Name then return end -- Don't outbid ourselves
                
                -- Event-driven fast reaction
                local targetBid = STATE.CurrentAuctionBid + 50
                if targetBid <= STATE.MaxBudget then
                    -- Intentional micro-delay to simulate human reaction and prevent immediate ratelimiting
                    task.delay(math.random() * 0.2 + 0.1, function()
                        if STATE.CurrentAuctionBid < targetBid then
                            pcall(function()
                                if Remotes.Bid then Remotes.Bid:FireServer(targetBid) end
                            end)
                        end
                    end)
                else
                    Utils.notify("Auction exceeded Max Budget ($" .. STATE.MaxBudget .. ")")
                end
            end
        end)
    end

    if Remotes.ToggleBiddingUI then
        Remotes.ToggleBiddingUI.OnClientEvent:Connect(function(visible)
            STATE.AuctionActive = visible and true or false
        end)
    end

    -- State Poller for Auction Auto-Join
    task.spawn(function()
        while task.wait(1) do
            if STATE.AutoAuction and not STATE.AuctionActive then
                -- Logic to find the active garage by checking Garages folder in workspace
                local garagesFolder = workspace:FindFirstChild("Garages") or workspace:FindFirstChild("Lucky Bay Beach Garages")
                if garagesFolder then
                    for _, g in ipairs(garagesFolder:GetChildren()) do
                        local active = g:FindFirstChild("Active")
                        if active and active.Value == true then
                            local pp = g:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if pp and pp.ActionText and tostring(pp.ActionText):find("Join") then
                                Utils.fireProximityPrompt(pp)
                                STATE.AuctionActive = true
                                Utils.notify("Auto-joined Auction: " .. g.Name)
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
end

return Auction

end

__MODULES['features/autofarm'] = function()
local RunService = game:GetService("RunService")
local Remotes = require("core/remotes")
local StateMod = require("core/state")
local Utils = require("core/utils")
local STATE = StateMod.STATE

local AutoFarm = {}

-- Finite State Machine states
local FSM_STATES = {
    IDLE = "IDLE",
    LOADING = "LOADING",
    UNLOADING = "UNLOADING",
    PLACING = "PLACING",
    SELLING = "SELLING"
}
local currentState = FSM_STATES.IDLE

local cachedVehicle = nil
local lastVehicleFetch = 0

local function getActiveVehicle()
    if not Remotes.GetOwnedVehicles then return nil end
    local now = os.clock()
    if cachedVehicle and (now - lastVehicleFetch < 3) then
        return cachedVehicle
    end
    local ok, vehicles = pcall(function() return Remotes.GetOwnedVehicles:InvokeServer() end)
    if ok and type(vehicles) == "table" and vehicles[1] then
        cachedVehicle = vehicles[1]
        lastVehicleFetch = now
        return cachedVehicle
    end
    return nil
end

local function getClosestCarryable(radius)
    local hrp = Utils.getHRP()
    if not hrp then return nil end
    local folder = workspace:FindFirstChild("_Carryables")
    if not folder then return nil end

    local closest, minDist = nil, radius
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") and item.PrimaryPart then
            local dist = (item.PrimaryPart.Position - hrp.Position).Magnitude
            if dist < minDist then
                local pp = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                if pp and pp.ActionText and tostring(pp.ActionText):find("Pick") then
                    closest = item
                    minDist = dist
                end
            end
        end
    end
    return closest
end

local function handleLoading()
    if not STATE.AutoLoad then return false end
    
    local vehicle = getActiveVehicle()
    if not vehicle then return false end

    local vId = vehicle.InstanceId or vehicle.Id or vehicle.Name
    local item = getClosestCarryable(50)
    if item and Remotes.PickUpItem and Remotes.TransferToVehicle then
        local ok1 = pcall(function() Remotes.PickUpItem:FireServer(item) end)
        if ok1 then
            task.wait(0.2) -- Network latency buffer
            pcall(function() Remotes.TransferToVehicle:InvokeServer(vId) end)
            return true -- Did work
        end
    end
    return false
end

local function handleUnloading()
    if not STATE.AutoUnload then return false end
    
    local vehicle = getActiveVehicle()
    if not vehicle then return false end

    local vId = vehicle.InstanceId or vehicle.Id or vehicle.Name
    if Remotes.TransferToInv then
        local ok, success = pcall(function() return Remotes.TransferToInv:InvokeServer(vId) end)
        if ok and success then
            task.wait(0.5)
            return true
        end
    end
    return false
end

local function handlePlacing()
    if not STATE.AutoPlace or not Remotes.PlaceStock then return false end
    local ok, success = pcall(function() return Remotes.PlaceStock:InvokeServer() end)
    if ok and success then
        task.wait(0.4)
        return true
    end
    return false
end

local function handleSelling()
    if not STATE.AutoSell then return false end
    if Remotes.PawnSell then
        local ok, success = pcall(function() return Remotes.PawnSell:InvokeServer() end)
        if ok and success then
            task.wait(0.5)
            return true
        end
    elseif Remotes.SellItem then
        local ok, success = pcall(function() return Remotes.SellItem:InvokeServer() end)
        if ok and success then
            task.wait(0.5)
            return true
        end
    end
    return false
end

function AutoFarm.start()
    task.spawn(function()
        while true do
            task.wait(0.1) -- Fast poll

            if not STATE.AutoFarmEnabled then
                currentState = FSM_STATES.IDLE
                task.wait(1)
                continue
            end

            -- Determine state transitions based on priorities
            if STATE.AutoLoad and getClosestCarryable(50) then
                currentState = FSM_STATES.LOADING
            elseif STATE.AutoUnload then
                currentState = FSM_STATES.UNLOADING
            elseif STATE.AutoPlace then
                currentState = FSM_STATES.PLACING
            elseif STATE.AutoSell then
                currentState = FSM_STATES.SELLING
            else
                currentState = FSM_STATES.IDLE
            end

            -- Execute state
            if currentState == FSM_STATES.LOADING then
                local worked = handleLoading()
                if not worked then task.wait(0.5) end
            elseif currentState == FSM_STATES.UNLOADING then
                local worked = handleUnloading()
                if not worked then task.wait(0.5) end
            elseif currentState == FSM_STATES.PLACING then
                local worked = handlePlacing()
                if not worked then task.wait(0.5) end
            elseif currentState == FSM_STATES.SELLING then
                local worked = handleSelling()
                if not worked then task.wait(0.5) end
            else
                task.wait(0.5)
            end
        end
    end)
end

return AutoFarm

end

__MODULES['features/esp'] = function()
local RunService = game:GetService("RunService")
local Utils = require("core/utils")
local StateMod = require("core/state")
local STATE = StateMod.STATE

local ESP = {}
local espCache = {}

local function cleanEspForModel(model)
    if espCache[model] then
        if espCache[model].bb then espCache[model].bb:Destroy() end
        if espCache[model].hl then espCache[model].hl:Destroy() end
        espCache[model] = nil
    end
end

function ESP.start()
    RunService.RenderStepped:Connect(function()
        if not STATE.ESPEnabled then
            for m, _ in pairs(espCache) do cleanEspForModel(m) end
            return
        end

        local hrpPart = Utils.getHRP()
        if not hrpPart then return end
        local myPos = hrpPart.Position

        local targets = {}
        for _, fName in ipairs({"_Carryables", "_LostItems"}) do
            local folder = workspace:FindFirstChild(fName)
            if folder then
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") or child:IsA("BasePart") then table.insert(targets, child) end
                end
            end
        end

        local currentValid = {}
        for _, target in ipairs(targets) do
            local p = target:IsA("BasePart") and target or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
            if p then
                local dist = (p.Position - myPos).Magnitude
                if dist <= STATE.ESPRenderDistance then
                    currentValid[target] = true
                    local itemName = target.Name
                    local color = Color3.fromRGB(0, 140, 255)

                    local entry = espCache[target]
                    if not entry then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "EccoESP"
                        bb.AlwaysOnTop = true
                        bb.Size = UDim2.new(0, 160, 0, 40)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 11
                        txt.TextStrokeTransparency = 0.3
                        txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        txt.Parent = bb
                        
                        local hl = Instance.new("Highlight")
                        hl.FillTransparency = 0.85
                        hl.OutlineTransparency = 0.25
                        
                        bb.Parent = p
                        hl.Parent = target
                        entry = { bb = bb, txt = txt, hl = hl }
                        espCache[target] = entry
                    end

                    local labelStr = itemName
                    
                    if STATE.ESPShowRarity then
                        local rarity = target:GetAttribute("Rarity") or (target:FindFirstChild("Rarity") and target.Rarity.Value)
                        if rarity then
                            labelStr = labelStr .. " [" .. tostring(rarity) .. "]"
                            if STATE.ESPColorTiers and STATE.ESPColorTiers[tostring(rarity)] then
                                color = STATE.ESPColorTiers[tostring(rarity)]
                            end
                        end
                    end

                    if STATE.ESPShowPrice then
                        local price = target:GetAttribute("Price") or (target:FindFirstChild("Price") and target.Price.Value)
                        if price then
                            labelStr = labelStr .. " | $" .. tostring(price)
                        end
                    end

                    if STATE.ESPShowDistance then labelStr = labelStr .. "\n" .. math.floor(dist) .. " studs" end

                    entry.txt.Text = labelStr
                    entry.txt.TextColor3 = color
                    entry.hl.FillColor = color
                    entry.hl.OutlineColor = color
                end
            end
        end

        for m, _ in pairs(espCache) do
            if not currentValid[m] then cleanEspForModel(m) end
        end
    end)
end

return ESP

end

__MODULES['features/player'] = function()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Utils = require("core/utils")
local StateMod = require("core/state")
local STATE = StateMod.STATE

local PlayerMods = {}
local flyBV, flyBG = nil, nil

function PlayerMods.start()
    RunService.RenderStepped:Connect(function()
        local p = Utils.getHRP()
        local hum = Utils.getHumanoid()
        
        if STATE.FlyEnabled and p and hum then
            if not flyBV then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBV.Parent = p
            end
            if not flyBG then
                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                flyBG.P = 9e4
                flyBG.Parent = p
            end

            local cam = workspace.CurrentCamera
            local moveVec = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec = moveVec - Vector3.new(0, 1, 0) end

            if moveVec.Magnitude > 0 then
                flyBV.Velocity = moveVec.Unit * (STATE.FlySpeed or 50)
            else
                flyBV.Velocity = Vector3.zero
            end
            flyBG.CFrame = cam.CFrame
        else
            if flyBV then flyBV:Destroy(); flyBV = nil end
            if flyBG then flyBG:Destroy(); flyBG = nil end
        end
        
        -- WalkSpeed and JumpPower are handled on change via the UI slider callbacks, 
        -- but we can enforce them here if they get reset by the game
        if hum then
            if STATE.WalkSpeedMult > 1 then
                hum.WalkSpeed = 16 * STATE.WalkSpeedMult
            end
            if STATE.JumpPowerMult > 1 then
                hum.JumpPower = 50 * STATE.JumpPowerMult
            end
        end
    end)
    
    UserInputService.JumpRequest:Connect(function()
        if STATE.InfiniteJump then
            local hum = Utils.getHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

return PlayerMods

end

__MODULES['features/workshop'] = function()
local RunService = game:GetService("RunService")
local Remotes = require("core/remotes")
local StateMod = require("core/state")
local Utils = require("core/utils")
local STATE = StateMod.STATE

local Workshop = {}
local SlotCache = {
    Wash = {},
    Repair = {},
    Grading = {},
    Locksmith = {}
}

local function processCategory(category, rMap)
    if not rMap.GetSlots or not rMap.Claim then return end
    
    local ok, sData = pcall(function() return rMap.GetSlots:InvokeServer() end)
    if not ok or type(sData) ~= "table" or type(sData.slots) ~= "table" then return end

    local maxUnlocked = tonumber(sData.unlockedCount) or 1
    local now = os.time()

    for i = 1, maxUnlocked do
        local slotInfo = sData.slots[tostring(i)] or sData.slots[i]
        if slotInfo and not slotInfo.Empty then
            -- Determine if ready
            local isReady = false
            if slotInfo.State == "Finished" or slotInfo.State == 2 then
                isReady = true
            elseif slotInfo.StartTime and slotInfo.Duration then
                -- Check against our local cache to avoid server-lag drift
                local expectedFinish = slotInfo.StartTime + slotInfo.Duration
                if now >= expectedFinish then
                    isReady = true
                end
            end

            -- Only claim if ready AND we haven't already marked it pending claim in this loop iteration
            if isReady then
                local claimOk, result = pcall(function() return rMap.Claim:InvokeServer(i) end)
                if claimOk then
                    Utils.notify("Claimed " .. category .. " item from Slot " .. i)
                end
            end
        elseif slotInfo and slotInfo.Empty then
            -- Auto-start job if enabled
            local shouldStart = (category == "Wash" and STATE.AutoWash) or
                                (category == "Repair" and STATE.AutoRepair) or
                                (category == "Grading" and STATE.AutoGrading) or
                                (category == "Locksmith" and STATE.AutoLocksmith) or
                                STATE.AutoCollectWorkshop
            if shouldStart and rMap.GetItems and rMap.Start then
                local okItems, items = pcall(function() return rMap.GetItems:InvokeServer() end)
                if okItems and type(items) == "table" and #items > 0 then
                    local targetItem = items[1]
                    local itemId = type(targetItem) == "table" and (targetItem.Id or targetItem.InstanceId or targetItem[1]) or targetItem
                    if itemId then
                        local startOk = pcall(function() return rMap.Start:InvokeServer(i, itemId) end)
                        if startOk then
                            Utils.notify("Started " .. category .. " on Slot " .. i)
                        end
                    end
                end
            end
        end
    end
end

function Workshop.start()
    task.spawn(function()
        while task.wait(1.5) do
            if STATE.AutoCollectWorkshop then
                for category, rMap in pairs(Remotes.Workshops) do
                    processCategory(category, rMap)
                end
            end
        end
    end)
end

return Workshop

end

__MODULES['ui/library'] = function()
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local UILibrary = {}
local TWEENS = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
}

local COLORS = {
    Background = Color3.fromRGB(12, 14, 20),
    Container = Color3.fromRGB(18, 20, 28),
    Primary = Color3.fromRGB(0, 220, 255),
    Text = Color3.fromRGB(245, 248, 255),
    TextDim = Color3.fromRGB(140, 155, 175),
    Stroke = Color3.fromRGB(30, 42, 60),
    Notification = Color3.fromRGB(16, 20, 30)
}

function UILibrary.create(class, properties)
    local inst = Instance.new(class)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

function UILibrary:CreateWindow(titleText)
    -- Clean up previous instances for clean hot-reloads
    pcall(function()
        local parent = gethui and gethui() or (CoreGui:FindFirstChild("RobloxGui") and CoreGui) or Players.LocalPlayer:WaitForChild("PlayerGui")
        local old = parent:FindFirstChild("EccoHub_Overhauled")
        if old then old:Destroy() end
    end)

    local sg = self.create("ScreenGui", {
        Name = "EccoHub_Overhauled",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    pcall(function()
        if gethui then sg.Parent = gethui()
        elseif CoreGui:FindFirstChild("RobloxGui") then sg.Parent = CoreGui
        else sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    end)

    local mainFrame = self.create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 700, 0, 520),
        Position = UDim2.new(0.5, -350, 0.5, -260),
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        Parent = sg,
        ClipsDescendants = false
    })

    -- Add constraints for responsive/premium scaling
    self.create("UISizeConstraint", {
        Parent = mainFrame,
        MinSize = Vector2.new(600, 400),
        MaxSize = Vector2.new(1000, 800)
    })

    self.create("UIStroke", {
        Parent = mainFrame,
        Color = Color3.fromRGB(0, 220, 255),
        Thickness = 1.5
    })
    
    self.create("UICorner", {
        Parent = mainFrame,
        CornerRadius = UDim.new(0, 8)
    })

    local header = self.create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = COLORS.Container,
        BorderSizePixel = 0,
        Parent = mainFrame
    })

    self.create("TextLabel", {
        Text = "  " .. titleText,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = COLORS.Text,
        Size = UDim2.new(1, -190, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })

    local tabBar = self.create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.new(0, 10, 0, 46),
        BackgroundColor3 = COLORS.Container,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    self.create("UICorner", { Parent = tabBar, CornerRadius = UDim.new(0, 6) })
    self.create("UIStroke", { Parent = tabBar, Color = COLORS.Stroke, Thickness = 1 })
    
    self.create("UIListLayout", {
        Parent = tabBar,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    local bodyArea = self.create("Frame", {
        Name = "BodyArea",
        Size = UDim2.new(1, -20, 1, -90),
        Position = UDim2.new(0, 10, 0, 86),
        BackgroundTransparency = 1,
        Parent = mainFrame
    })

    -- Notification Container
    local notifArea = self.create("Frame", {
        Name = "NotificationArea",
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -310, 0, 10),
        BackgroundTransparency = 1,
        Parent = sg
    })
    self.create("UIListLayout", {
        Parent = notifArea,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8)
    })

    local windowState = {
        Tabs = {},
        TabButtons = {},
        CurrentTab = nil,
        SG = sg
    }

    function windowState:Notify(msg, duration)
        duration = duration or 3
        local note = UILibrary.create("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = COLORS.Notification,
            BackgroundTransparency = 1,
            Parent = notifArea
        })
        UILibrary.create("UICorner", { Parent = note, CornerRadius = UDim.new(0, 6) })
        local stroke = UILibrary.create("UIStroke", { Parent = note, Color = COLORS.Stroke, Thickness = 1, Transparency = 1 })
        
        local text = UILibrary.create("TextLabel", {
            Text = " " .. msg,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = COLORS.Text,
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1,
            Parent = note
        })

        local bar = UILibrary.create("Frame", {
            Size = UDim2.new(0, 4, 1, 0),
            BackgroundColor3 = COLORS.Primary,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Parent = note
        })
        UILibrary.create("UICorner", { Parent = bar, CornerRadius = UDim.new(0, 6) })

        TweenService:Create(note, TWEENS.Fast, {BackgroundTransparency = 0}):Play()
        TweenService:Create(stroke, TWEENS.Fast, {Transparency = 0}):Play()
        TweenService:Create(text, TWEENS.Fast, {TextTransparency = 0}):Play()
        TweenService:Create(bar, TWEENS.Fast, {BackgroundTransparency = 0}):Play()

        task.delay(duration, function()
            TweenService:Create(note, TWEENS.Fast, {BackgroundTransparency = 1}):Play()
            TweenService:Create(stroke, TWEENS.Fast, {Transparency = 1}):Play()
            TweenService:Create(text, TWEENS.Fast, {TextTransparency = 1}):Play()
            TweenService:Create(bar, TWEENS.Fast, {BackgroundTransparency = 1}):Play()
            task.wait(0.2)
            note:Destroy()
        end)
    end

    function windowState:AddTab(name)
        local btn = UILibrary.create("TextButton", {
            Text = name,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = COLORS.TextDim,
            Size = UDim2.new(0, 60, 1, 0),
            BackgroundColor3 = COLORS.Container,
            BorderSizePixel = 0,
            Parent = tabBar
        })
        UILibrary.create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })

        local container = UILibrary.create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = COLORS.Primary,
            Visible = false,
            Parent = bodyArea,
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        UILibrary.create("UIListLayout", {
            Parent = container,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })

        self.Tabs[name] = container
        self.TabButtons[name] = btn

        btn.MouseButton1Click:Connect(function()
            self:SelectTab(name)
        end)

        local tabState = {
            Container = container
        }

        function tabState:AddSection(title)
            local section = UILibrary.create("Frame", {
                Size = UDim2.new(1, -8, 0, 30),
                BackgroundColor3 = COLORS.Container,
                BorderSizePixel = 0,
                Parent = self.Container
            })
            UILibrary.create("UICorner", { Parent = section, CornerRadius = UDim.new(0, 6) })
            UILibrary.create("UIStroke", { Parent = section, Color = COLORS.Stroke, Thickness = 1 })
            
            UILibrary.create("UIListLayout", {
                Parent = section,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            })
            UILibrary.create("UIPadding", {
                Parent = section,
                PaddingTop = UDim.new(0, 26),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })

            UILibrary.create("TextLabel", {
                Text = "  " .. title .. "  ",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = COLORS.Primary,
                Position = UDim2.new(0, 10, 0, 4),
                Size = UDim2.new(0, 0, 0, 16),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Parent = section
            })

            local secLayout = section:FindFirstChildOfClass("UIListLayout")
            secLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                section.Size = UDim2.new(1, -8, 0, secLayout.AbsoluteContentSize.Y + 36)
            end)

            local sectionState = {}
            function sectionState:AddToggle(text, default, callback)
                local row = UILibrary.create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = section
                })
                local toggleBtn = UILibrary.create("TextButton", {
                    Text = "",
                    Size = UDim2.new(0, 44, 0, 22),
                    Position = UDim2.new(1, -46, 0.5, -11),
                    BackgroundColor3 = default and COLORS.Primary or Color3.fromRGB(24, 28, 38),
                    AutoButtonColor = false,
                    Parent = row
                })
                UILibrary.create("UICorner", { Parent = toggleBtn, CornerRadius = UDim.new(1, 0) })
                local toggleStroke = UILibrary.create("UIStroke", {
                    Parent = toggleBtn,
                    Color = default and COLORS.Primary or COLORS.Stroke,
                    Thickness = 1.2
                })
                
                local circle = UILibrary.create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = toggleBtn
                })
                UILibrary.create("UICorner", { Parent = circle, CornerRadius = UDim.new(1, 0) })

                UILibrary.create("TextLabel", {
                    Text = text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = COLORS.Text,
                    Size = UDim2.new(1, -55, 1, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row
                })

                local state = default
                toggleBtn.MouseButton1Click:Connect(function()
                    state = not state
                    TweenService:Create(toggleBtn, TWEENS.Fast, {
                        BackgroundColor3 = state and COLORS.Primary or Color3.fromRGB(24, 28, 38)
                    }):Play()
                    TweenService:Create(toggleStroke, TWEENS.Fast, {
                        Color = state and COLORS.Primary or COLORS.Stroke
                    }):Play()
                    TweenService:Create(circle, TWEENS.Fast, {
                        Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                    }):Play()
                    if callback then callback(state) end
                end)
            end

            function sectionState:AddButton(text, callback)
                local btn = UILibrary.create("TextButton", {
                    Text = text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = COLORS.Text,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Color3.fromRGB(24, 28, 38),
                    Parent = section
                })
                UILibrary.create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })
                UILibrary.create("UIStroke", { Parent = btn, Color = COLORS.Stroke, Thickness = 1 })

                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TWEENS.Fast, {BackgroundColor3 = Color3.fromRGB(34, 40, 56)}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TWEENS.Fast, {BackgroundColor3 = Color3.fromRGB(24, 28, 38)}):Play()
                end)
                btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end

            function sectionState:AddSlider(text, min, max, default, callback)
                local row = UILibrary.create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    Parent = section
                })
                
                UILibrary.create("TextLabel", {
                    Text = text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = COLORS.Text,
                    Size = UDim2.new(0.7, 0, 0, 20),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row
                })

                local valLbl = UILibrary.create("TextLabel", {
                    Text = tostring(default),
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = COLORS.Primary,
                    Position = UDim2.new(1, -60, 0, 0),
                    Size = UDim2.new(0, 60, 0, 20),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = row
                })

                local track = UILibrary.create("Frame", {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 1, -10),
                    BackgroundColor3 = Color3.fromRGB(24, 28, 38),
                    Parent = row
                })
                UILibrary.create("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })
                UILibrary.create("UIStroke", { Parent = track, Color = COLORS.Stroke, Thickness = 1 })
                
                local initialPct = math.clamp((default - min) / (max - min), 0, 1)
                local fill = UILibrary.create("Frame", {
                    Size = UDim2.new(initialPct, 0, 1, 0),
                    BackgroundColor3 = COLORS.Primary,
                    Parent = track
                })
                UILibrary.create("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })

                -- Modern circular thumb knob
                local knob = UILibrary.create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(initialPct, 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = track
                })
                UILibrary.create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })
                UILibrary.create("UIStroke", {
                    Parent = knob,
                    Color = COLORS.Primary,
                    Thickness = 2
                })

                local UserInputService = game:GetService("UserInputService")
                local dragging = false
                
                local function update(input)
                    local trackWidth = track.AbsoluteSize.X
                    if trackWidth <= 0 then return end
                    local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / trackWidth, 0, 1)
                    local val = math.floor(min + (max - min) * pos)
                    valLbl.Text = tostring(val)
                    TweenService:Create(fill, TWEENS.Fast, {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                    TweenService:Create(knob, TWEENS.Fast, {Position = UDim2.new(pos, 0, 0.5, 0)}):Play()
                    if callback then callback(val) end
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        TweenService:Create(knob, TWEENS.Fast, {Size = UDim2.new(0, 18, 0, 18)}):Play()
                        update(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        TweenService:Create(knob, TWEENS.Fast, {Size = UDim2.new(0, 14, 0, 14)}):Play()
                    end
                end)
            end

            return sectionState
        end
        return tabState
    end

    function windowState:SelectTab(name)
        if self.CurrentTab == name then return end
        self.CurrentTab = name
        for tName, tFrame in pairs(self.Tabs) do
            tFrame.Visible = (tName == name)
            local btn = self.TabButtons[tName]
            TweenService:Create(btn, TWEENS.Fast, {
                BackgroundColor3 = (tName == name) and COLORS.Primary or COLORS.Container,
                TextColor3 = (tName == name) and Color3.fromRGB(255, 255, 255) or COLORS.TextDim
            }):Play()
        end
    end
    
    return windowState
end

return UILibrary

end

__MODULES['ui/window'] = function()
local Library = require("ui/library")
local StateMod = require("core/state")
local STATE = StateMod.STATE

local WindowModule = {}

function WindowModule.init()
    local win = Library:CreateWindow("ECCO HUB - Storage Hunters")
    
    local tabMain = win:AddTab("Main")
    local secAuto = tabMain:AddSection("Tycoon Automation")
    secAuto:AddToggle("Auto Load Truck", STATE.AutoLoad, function(v) STATE.AutoLoad = v end)
    secAuto:AddToggle("Auto Unload Store", STATE.AutoUnload, function(v) STATE.AutoUnload = v end)
    secAuto:AddToggle("Auto Place Shelves", STATE.AutoPlace, function(v) STATE.AutoPlace = v end)
    secAuto:AddToggle("Auto Sell Inventory", STATE.AutoSell, function(v) STATE.AutoSell = v end)
    
    local secOffers = tabMain:AddSection("NPC Offers")
    secOffers:AddToggle("Auto Accept Offers", STATE.AutoAcceptOffers, function(v) STATE.AutoAcceptOffers = v end)
    secOffers:AddSlider("Margin Threshold %", 0, 100, STATE.PriceMultiplier, function(v) STATE.PriceMultiplier = v end)

    local tabBuy = win:AddTab("Buy")
    local secStaff = tabBuy:AddSection("Staff Management")
    secStaff:AddToggle("Auto Hire & Upgrade Staff", STATE.AutoStaff, function(v) STATE.AutoStaff = v end)
    secStaff:AddSlider("Target Level", 1, 10, STATE.AutoStaffTargetLevel, function(v) STATE.AutoStaffTargetLevel = v end)
    local secUpg = tabBuy:AddSection("Upgrades")
    secUpg:AddToggle("Auto Purchase Upgrades", STATE.AutoUpgrades, function(v) STATE.AutoUpgrades = v end)

    local tabAuction = win:AddTab("Auction")
    local secAuc = tabAuction:AddSection("Auction Automation")
    secAuc:AddToggle("Auto Bid Active Auction", STATE.AutoBid, function(v) STATE.AutoBid = v end)
    secAuc:AddToggle("Auto Join Garages", STATE.AutoAuction, function(v) STATE.AutoAuction = v end)
    secAuc:AddSlider("Max Budget ($)", 0, 50000, STATE.MaxBudget, function(v) STATE.MaxBudget = v end)

    local tabESP = win:AddTab("Visuals")
    local secESP = tabESP:AddSection("ESP Engine")
    secESP:AddToggle("Enable ESP", STATE.ESPEnabled, function(v) STATE.ESPEnabled = v end)
    secESP:AddToggle("Show Prices", STATE.ESPShowPrice, function(v) STATE.ESPShowPrice = v end)
    secESP:AddToggle("Show Rarity", STATE.ESPShowRarity, function(v) STATE.ESPShowRarity = v end)

    local tabPlayer = win:AddTab("Player")
    local secChar = tabPlayer:AddSection("Character Modifiers")
    secChar:AddSlider("WalkSpeed Multiplier", 1, 5, STATE.WalkSpeedMult, function(v) STATE.WalkSpeedMult = v end)
    secChar:AddSlider("JumpPower Multiplier", 1, 5, STATE.JumpPowerMult, function(v) STATE.JumpPowerMult = v end)
    secChar:AddToggle("Infinite Jump", STATE.InfiniteJump, function(v) STATE.InfiniteJump = v end)
    secChar:AddToggle("Fly Mode", STATE.FlyEnabled, function(v) STATE.FlyEnabled = v end)
    secChar:AddSlider("Fly Speed", 20, 200, STATE.FlySpeed, function(v) STATE.FlySpeed = v end)

    local tabSettings = win:AddTab("Settings")
    local secCfg = tabSettings:AddSection("Configuration")
    secCfg:AddButton("Save Config", function() StateMod.SaveConfig() end)
    secCfg:AddButton("Load Config", function() StateMod.LoadConfig() end)

    local tabNotif = win:AddTab("Notifications")
    local secNotifs = tabNotif:AddSection("Ecco Cloud Broadcasts & Alerts")
    secNotifs:AddButton("📢 Welcome to Ecco Hub V3 - Keyless Suite Online", function()
        win:Notify("Ecco Hub V3 is operational across 327 games!")
    end)
    secNotifs:AddButton("🔔 Dupe & Exploits Alert - Pushed to discord.gg/ecc00", function()
        win:Notify("Join discord.gg/ecc00 for announcements!")
    end)
    secNotifs:AddButton("🔄 Refresh Cloud Broadcasts", function()
        win:Notify("Cloud broadcasts updated from eccohub.xyz")
    end)
    secNotifs:AddButton("📋 Copy Community Discord (discord.gg/ecc00)", function()
        pcall(function() setclipboard("https://discord.gg/ecc00") end)
        win:Notify("Copied discord.gg/ecc00 to clipboard!")
    end)

    win:SelectTab("Main")
    return win
end

return WindowModule

end

require('main')
