--[[
    ==============================================================================
    ECCO HUB V3 - AMBER ALERT 3.0 (1990 HOUSE & MALL)
    ==============================================================================
    Architecture : Modular Feature Pipeline, Combat, Movement & Troll Suite
    UI Framework : Obsidian Reborn (deividcomsono/Obsidian)
    Target Game  : Amber Alert 3.0 / 1990 House (PlaceId: 109324041251039)
    Keybind      : RightShift (Configurable in Settings)
    ==============================================================================
]]

-- Hot-Reload & Previous Instance Cleanup
if _G.AmberAlertSuiteUnload then
    pcall(_G.AmberAlertSuiteUnload)
end

pcall(function()
    for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if g.Name == "Obsidian" then
            g:Destroy()
        end
    end
end)

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.2)
    LocalPlayer = Players.LocalPlayer
end

-- Global Engine Bypasses
_G.AA_AllowJump = true
_G.AA_WeatherDrainMul = 0

-- Safe Remotes & Config Resolution
local AmberAlertFolder = ReplicatedStorage:WaitForChild("AmberAlert", 10)
local RemotesModule = AmberAlertFolder and AmberAlertFolder:WaitForChild("Remotes", 10)
local Remotes = RemotesModule and require(RemotesModule)
local ConfigModule = AmberAlertFolder and AmberAlertFolder:WaitForChild("Config", 10)
local Config = ConfigModule and require(ConfigModule)

-- Global Engine Bypasses & Stamina Hardening
_G.AA_AllowJump = true
_G.AA_WeatherDrainMul = 0
_G.AA_WeatherSpeedMul = 1
_G.AA_ChannelSpeedMul = 1

if Config then
    if Config.Stamina then
        Config.Stamina.DrainPerSecond = 0
        Config.Stamina.RegenDelay = 0
        Config.Stamina.RegenPerSecond = 9999
        Config.Stamina.MinToSprint = 0
        Config.Stamina.Max = 99999
    end
    if Config.BrokenBone then
        Config.BrokenBone.MinFallStuds = 999999
        Config.BrokenBone.Duration = 0
        Config.BrokenBone.SpeedMult = 1
        Config.BrokenBone.StaminaDrainMult = 1
    end
end

local function getRemote(name)
    if Remotes and Remotes.Get then
        local ok, rem = pcall(function() return Remotes.Get(name) end)
        if ok and rem then return rem end
    end
    if AmberAlertFolder then
        local remoteEvents = AmberAlertFolder:FindFirstChild("RemoteEvents")
        if remoteEvents and remoteEvents:FindFirstChild(name) then
            return remoteEvents[name]
        end
    end
    return ReplicatedStorage:FindFirstChild(name)
end

-- Resolve Core Remotes
local ShopBuyRemote = getRemote("ShopBuy")
local GardenBuyRemote = getRemote("GardenBuy")
local UpgradeBuyRemote = getRemote("UpgradeBuy")
local JumpscareRemote = getRemote("Jumpscare")
local JumpscareCancelRemote = getRemote("JumpscareCancel")
local WeaponFireRemote = getRemote("WeaponFire")
local WeaponReloadRemote = getRemote("WeaponReload")
local UseItemRemote = getRemote("UseItem")
local ClownStruggleRemote = getRemote("ClownStruggle")
local ChoreDishesStartRemote = getRemote("ChoreDishesStart")
local ChoreDishesDoneRemote = getRemote("ChoreDishesDone")
local RevivedRemote = getRemote("Revived") or getRemote("Revive")
local BreakGlassRemote = getRemote("BreakGlass")
local TvToggleRemote = getRemote("TvToggle")

-- Central State Configuration
local State = {
    -- Auto-Farm Settings
    AutoFarmApples = false,
    TurboHarvest = false,
    AutoSellApples = false,
    SellThreshold = 3,
    FarmDelay = 0.35,
    SafeSellOnly = true,
    AlwaysAnchorRoof = true,
    SafetyClearance = 50,
    AutoPickUpHouseMoney = true,

    -- Auto Purchases
    AutoBuyTrees = true,
    AutoBuyGarden = true,
    AutoBuyAppleUpgrades = false,
    AutoBuyWeapons = false,
    AutoBuyAmmo = false,

    -- Combat Settings
    KillAura = false,
    KillAuraRange = 60,
    KillAuraDelay = 0.2,
    AutoTaser = true,
    AutoTrapPatrols = false,
    AutoReload = true,

    -- Locomotion & Flight
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    InfiniteStamina = true,

    -- Survival & Automation
    MonsterEvasion = true,
    EvasionDistance = 25,
    EvasionLockout = 6,
    AutoHideCloset = false,
    AutoHideDistance = 30,
    AutoSkillCheck = true,
    AutoStruggle = true,
    AutoChoresBackground = true,
    AntiJumpscare = true,

    -- Teammate Revive Suite
    AutoRevive = false,
    SelectedPlayer = "",

    -- Troll Suite
    SpamDoors = false,
    SpamWindows = false,
    SpamDrawers = false,
    SpamAll = false,
    SpamInterval = 0.15,
    SpamTv = false,

    -- ESP & Visuals
    MonsterESP = true,
    AppleESP = true,
    PlayerESP = true,
    LootESP = true,
    WaypointESP = false,
    Fullbright = true,

    -- UI & System
    UnlockCursor = true,

    -- Safe Anchors
    SafeAnchorCFrame = CFrame.new(-430, 68, 320),
    SellStandGroundCFrame = CFrame.new(-470.44, 21.5, 566.2)
}

local TreePriceTable = (Config and Config.AppleTree and Config.AppleTree.PriceTable) or {
    0, 400, 1250, 2500, 5000, 7500, 10000, 13000, 16500, 20000
}

local GardenUpgradeList = {
    "Sprinklers", "Rake", "BiggerHarvest", "Greenhouse", "Compost", "PlantSeeds", "GoldenTouch"
}

local AppleUpgradeList = {
    "BloxyCola", "MedicBook", "GunSmith", "Boots"
}

-- Helpers
local function getCharacter()
    return LocalPlayer.Character
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function tapSpace()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.025)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    if #names == 0 then
        table.insert(names, "No Teammates Present")
    end
    return names
end

local function findPlayerBySelection(str)
    if not str or str == "" or str == "No Teammates Present" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local tag = p.DisplayName .. " (@" .. p.Name .. ")"
            if tag == str or p.Name == str or p.DisplayName == str then
                return p
            end
        end
    end
    return nil
end

-- ==============================================================================
-- THREAT SENSORS & SAFETY EVALUATION
-- ==============================================================================
local function getNearestMonsterDist(pos)
    if not pos then return 9999 end
    local activeMonsters = workspace:FindFirstChild("ActiveMonsters")
    if not activeMonsters then return 9999 end
    local minD = 9999
    for _, m in ipairs(activeMonsters:GetChildren()) do
        local mRoot = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
        if mRoot then
            local d = (mRoot.Position - pos).Magnitude
            if d < minD then minD = d end
        end
    end
    return minD
end

local function isMonsterNear(pos, radius)
    return getNearestMonsterDist(pos) <= radius
end

local function canSellSafely()
    local phase = workspace:GetAttribute("AA_Phase") or "DAY"
    local shopClosed = workspace:GetAttribute("AA_ShopClosed")
    if phase ~= "DAY" or shopClosed == true then
        return false
    end
    local sellPart = workspace:FindFirstChild("AppleSell", true)
    if not sellPart then return false end
    if isMonsterNear(sellPart.Position, State.SafetyClearance) then
        return false
    end
    local root = getRoot()
    if root and isMonsterNear(root.Position, State.SafetyClearance) then
        return false
    end
    return true
end

local function canHarvestSafely(applePart)
    if not applePart or not applePart.Parent then return false end
    return not isMonsterNear(applePart.Position, State.SafetyClearance)
end

-- Forward Declarations
local collectAvailableApples
local sellApplesRoutine
local collectHouseMoney
local processAutoPurchases
local runKillAura
local placeTrapsOnWaypoints
local applyFullbright
local cleanAllESP
local reviveCharacter
local processAutoChoresBackground
local checkAutoHideCloset
local runTrollSpam

-- ==============================================================================
-- LOAD OBSIDIAN REBORN UI FRAMEWORK
-- ==============================================================================
local oldGethui = gethui
getgenv().gethui = nil

local ObsidianRepo = "https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/lib/"
local Library = loadstring(game:HttpGet(ObsidianRepo .. "Library.lua", true))()
Library.SetNotifySide = function() end
Library.AddDraggableMenu = function(self, name)
    local f = Instance.new("Frame")
    local c = Instance.new("Frame")
    c.Parent = f
    return f, c
end
local ThemeManager = loadstring(game:HttpGet(ObsidianRepo .. "addons/ThemeManager.lua", true))()
local SaveManager = loadstring(game:HttpGet(ObsidianRepo .. "addons/SaveManager.lua", true))()

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Footer = "Ecco Hub V3 • eccohub.xyz",
    Title = "Ecco Hub V3 - Amber Alert 3.0",
    ShowCustomCursor = false
})

-- TAB 1: AUTO FARM & MONEY
local TabFarm = Window:AddTab("Auto Farm")
local LeftColFarm = TabFarm:AddLeftGroupbox("Apple Harvesting & Safe Sell")
local RightColFarm = TabFarm:AddRightGroupbox("House Cash & Economy")

LeftColFarm:AddToggle("AutoCollectApples", {
    Text = "Auto Collect Apples",
    Default = false,
    Tooltip = "Gathers spawned apples across trees. Skips any apple with monsters nearby."
}):OnChanged(function(val)
    State.AutoFarmApples = val
end)

LeftColFarm:AddToggle("TurboHarvest", {
    Text = "Turbo Apple Farm (Zero Delay)",
    Default = false,
    Tooltip = "Instantly collects all apples across the map with zero delay cycles."
}):OnChanged(function(val)
    State.TurboHarvest = val
end)

LeftColFarm:AddToggle("AutoSellApples", {
    Text = "Auto Sell Apples",
    Default = false,
    Tooltip = "Reliably teleports to ground counter with replication dwell, sells, and returns to roof."
}):OnChanged(function(val)
    State.AutoSellApples = val
end)

LeftColFarm:AddToggle("SafeSellOnly", {
    Text = "Safe Sell Only (Day / Threat Free)",
    Default = true,
    Tooltip = "Strict safety: NEVER teleports to store at Night or if monsters are near the storefront."
}):OnChanged(function(val)
    State.SafeSellOnly = val
end)

LeftColFarm:AddToggle("AlwaysAnchorRoof", {
    Text = "Anchor to Safe Roof",
    Default = true,
    Tooltip = "Immediately returns and anchors character to high roof after every harvest/sell."
}):OnChanged(function(val)
    State.AlwaysAnchorRoof = val
end)

LeftColFarm:AddSlider("SellThreshold", {
    Text = "Sell Threshold (Apples)",
    Default = 3,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.SellThreshold = val
end)

LeftColFarm:AddSlider("FarmDelay", {
    Text = "Cycle Interval (Sec)",
    Default = 0.35,
    Min = 0.1,
    Max = 2.0,
    Rounding = 2,
    Compact = false
}):OnChanged(function(val)
    State.FarmDelay = val
end)

LeftColFarm:AddButton({
    Text = "Instant Safe Harvest & Cashout",
    Func = function()
        if collectAvailableApples then collectAvailableApples() end
        if sellApplesRoutine then sellApplesRoutine() end
        Library:Notify("Safe harvest cycle executed!", 2)
    end
})

-- House Cash Controls
RightColFarm:AddToggle("AutoPickUpHouseMoney", {
    Text = "Auto-Pick Up All House Cash",
    Default = true,
    Tooltip = "Continuously sweeps all Cash and Coin bundles spawning in rooms across the house."
}):OnChanged(function(val)
    State.AutoPickUpHouseMoney = val
end)

RightColFarm:AddButton({
    Text = "Instant Sweep All House Cash",
    Func = function()
        if collectHouseMoney then
            local count = collectHouseMoney()
            Library:Notify("Collected " .. count .. " cash bundles from the house!", 2.5)
        end
    end
})

RightColFarm:AddToggle("AutoBuyTrees", {
    Text = "Auto Buy Apple Trees",
    Default = true,
    Tooltip = "Purchases next tree from server remotes without moving your character."
}):OnChanged(function(val)
    State.AutoBuyTrees = val
end)

RightColFarm:AddToggle("AutoBuyGarden", {
    Text = "Auto Buy Garden Upgrades",
    Default = true,
    Tooltip = "Auto-levels Sprinklers, Rake, Bigger Harvest, Greenhouse, Compost."
}):OnChanged(function(val)
    State.AutoBuyGarden = val
end)

RightColFarm:AddToggle("AutoBuyAppleUpgrades", {
    Text = "Auto Buy Stat Upgrades",
    Default = false,
    Tooltip = "Auto-purchases Bloxy Cola, Boots, Medic Book, Gunsmith."
}):OnChanged(function(val)
    State.AutoBuyAppleUpgrades = val
end)

RightColFarm:AddToggle("AutoBuyWeapons", {
    Text = "Auto Buy Guns",
    Default = false,
    Tooltip = "Automatically purchases Shotgun & Double Shotgun when cash permits."
}):OnChanged(function(val)
    State.AutoBuyWeapons = val
end)

RightColFarm:AddToggle("AutoBuyAmmo", {
    Text = "Auto Buy Ammo",
    Default = false,
    Tooltip = "Automatically restocks Shotgun Shells and Regular Bullets."
}):OnChanged(function(val)
    State.AutoBuyAmmo = val
end)

RightColFarm:AddButton({
    Text = "Trigger All Auto-Purchases Now",
    Func = function()
        if processAutoPurchases then
            processAutoPurchases()
            Library:Notify("Auto-purchase pass completed!", 2)
        end
    end
})

-- TAB 2: COMBAT
local TabCombat = Window:AddTab("Combat")
local LeftColCombat = TabCombat:AddLeftGroupbox("Kill Aura & Gun Suite")
local RightColCombat = TabCombat:AddRightGroupbox("Traps & Patrol Control")

LeftColCombat:AddToggle("KillAura", {
    Text = "Monster Kill Aura / Instant Hit",
    Default = false,
    Tooltip = "Auto-equips weapon from inventory and fires directly at nearest monster."
}):OnChanged(function(val)
    State.KillAura = val
end)

LeftColCombat:AddSlider("KillAuraRange", {
    Text = "Kill Aura Range (Studs)",
    Default = 60,
    Min = 15,
    Max = 150,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.KillAuraRange = val
end)

LeftColCombat:AddSlider("KillAuraDelay", {
    Text = "Fire Rate Delay (Sec)",
    Default = 0.2,
    Min = 0.05,
    Max = 1.0,
    Rounding = 2,
    Compact = false
}):OnChanged(function(val)
    State.KillAuraDelay = val
end)

LeftColCombat:AddToggle("AutoTaser", {
    Text = "Auto-Stun / Auto-Taser",
    Default = true,
    Tooltip = "Instantly stuns monsters with Taser/Stungun/Pepper Spray when they enter range."
}):OnChanged(function(val)
    State.AutoTaser = val
end)

LeftColCombat:AddToggle("AutoReload", {
    Text = "Auto-Reload Empty Guns",
    Default = true,
    Tooltip = "Automatically sends reload packets whenever gun magazine drops to 0."
}):OnChanged(function(val)
    State.AutoReload = val
end)

RightColCombat:AddToggle("AutoTrapPatrols", {
    Text = "Auto-Trap Patrol Routes",
    Default = false,
    Tooltip = "Periodically deploys inventory traps along monster patrol nodes in Workspace.Waypoints."
}):OnChanged(function(val)
    State.AutoTrapPatrols = val
end)

RightColCombat:AddButton({
    Text = "Deploy All Traps on Killer Routes",
    Func = function()
        if placeTrapsOnWaypoints then
            placeTrapsOnWaypoints()
        end
    end
})

-- TAB 3: MOVEMENT & FLIGHT
local TabMove = Window:AddTab("Movement")
local LeftColMove = TabMove:AddLeftGroupbox("Character Locomotion")
local RightColMove = TabMove:AddRightGroupbox("Flight Engine")

LeftColMove:AddSlider("WalkSpeed", {
    Text = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 120,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.WalkSpeed = val
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = val end
end)

LeftColMove:AddSlider("JumpPower", {
    Text = "JumpPower",
    Default = 50,
    Min = 30,
    Max = 200,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.JumpPower = val
    _G.AA_AllowJump = true
    local hum = getHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = val
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
end)

LeftColMove:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
    Tooltip = "Enables jump capability in mid-air and bypasses game jumping restrictions."
}):OnChanged(function(val)
    State.InfiniteJump = val
    _G.AA_AllowJump = true
    local hum = getHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = State.JumpPower
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
end)

LeftColMove:AddToggle("Noclip", {
    Text = "Noclip (Walk Through Walls)",
    Default = false,
    Tooltip = "Disables collision on your character to pass through locked doors and walls."
}):OnChanged(function(val)
    State.Noclip = val
end)

LeftColMove:AddToggle("InfiniteStamina", {
    Text = "Infinite Stamina",
    Default = true,
    Tooltip = "Zero stamina depletion and instant infinite recovery."
}):OnChanged(function(val)
    State.InfiniteStamina = val
    if val and Config and Config.Stamina then
        Config.Stamina.DrainPerSecond = 0
        Config.Stamina.RegenDelay = 0
        Config.Stamina.RegenPerSecond = 9999
        _G.AA_WeatherDrainMul = 0
    end
end)

LeftColMove:AddButton({
    Text = "Reset Movement Defaults",
    Func = function()
        State.WalkSpeed = 16
        State.JumpPower = 50
        State.InfiniteJump = false
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        Library:Notify("Movement reset to standard values.", 2)
    end
})

RightColMove:AddToggle("Fly", {
    Text = "Flight Mode",
    Default = false,
    Tooltip = "Smooth 3D flight with camera-oriented directional controls."
}):OnChanged(function(val)
    State.Fly = val
end)

RightColMove:AddSlider("FlySpeed", {
    Text = "Flight Speed",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.FlySpeed = val
end)

RightColMove:AddLabel("Controls:")
RightColMove:AddLabel("• W / A / S / D : Move In Camera View")
RightColMove:AddLabel("• Space : Ascend Vertically")
RightColMove:AddLabel("• LeftShift / LeftCtrl : Descend")

-- TAB 4: SURVIVAL & AUTOMATION
local TabSurv = Window:AddTab("Survival")
local LeftColSurv = TabSurv:AddLeftGroupbox("Defensive Shield & Closet Hide")
local RightColSurv = TabSurv:AddRightGroupbox("Chores & Teammate Revive")

LeftColSurv:AddToggle("MonsterEvasion", {
    Text = "Auto Monster Evasion (Roof Shield)",
    Default = true,
    Tooltip = "Priority 1 Shield: Teleports you to safe roof whenever a monster enters range."
}):OnChanged(function(val)
    State.MonsterEvasion = val
end)

LeftColSurv:AddSlider("EvasionDistance", {
    Text = "Evasion Trigger Range (Studs)",
    Default = 25,
    Min = 10,
    Max = 60,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.EvasionDistance = val
end)

LeftColSurv:AddSlider("SafetyClearance", {
    Text = "Monster Danger Buffer (Studs)",
    Default = 50,
    Min = 20,
    Max = 80,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.SafetyClearance = val
end)

LeftColSurv:AddSlider("EvasionLockout", {
    Text = "Post-Evasion Lockout (Sec)",
    Default = 6,
    Min = 2,
    Max = 15,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.EvasionLockout = val
end)

-- Closet Auto Hide Feature
LeftColSurv:AddToggle("AutoHideCloset", {
    Text = "Auto-Hide in Closet on Threat",
    Default = false,
    Tooltip = "Automatically teleports into the nearest closet/hiding spot and hides when a monster approaches."
}):OnChanged(function(val)
    State.AutoHideCloset = val
end)

LeftColSurv:AddSlider("AutoHideDistance", {
    Text = "Closet Hide Trigger Range (Studs)",
    Default = 30,
    Min = 10,
    Max = 60,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.AutoHideDistance = val
end)

LeftColSurv:AddToggle("AntiJumpscare", {
    Text = "Anti-Jumpscare Shield",
    Default = true,
    Tooltip = "Instantly cancels server jumpscares and destroys screamer overlays."
}):OnChanged(function(val)
    State.AntiJumpscare = val
end)

-- Chores Background Automation
RightColSurv:AddToggle("AutoChoresBackground", {
    Text = "Auto Chores in Background",
    Default = true,
    Tooltip = "Silently completes Dishes and Trash Bag chores in the background whenever assigned."
}):OnChanged(function(val)
    State.AutoChoresBackground = val
end)

RightColSurv:AddToggle("AutoSkillCheck", {
    Text = "100% Win Hiding Skill Checks",
    Default = true,
    Tooltip = "Perfect auto-hit on Heartbeat pulse and Sweep Bar markers while hiding in closets."
}):OnChanged(function(val)
    State.AutoSkillCheck = val
end)

RightColSurv:AddToggle("AutoStruggle", {
    Text = "Auto-Struggle / Anti-Grab",
    Default = true,
    Tooltip = "Instantly breaks clown/monster grabs and spam-fires struggle remote."
}):OnChanged(function(val)
    State.AutoStruggle = val
end)

-- Teammate Revive Controls
RightColSurv:AddToggle("AutoRevive", {
    Text = "Auto-Revive Downed Teammates",
    Default = false,
    Tooltip = "Continuously scans and teleports to revive downed teammates when safe from monsters."
}):OnChanged(function(val)
    State.AutoRevive = val
end)

local initialPlayers = getPlayerNames()
State.SelectedPlayer = initialPlayers[1] or ""

local RevivePlayerDropdown = RightColSurv:AddDropdown("RevivePlayerSelect", {
    Values = initialPlayers,
    Default = 1,
    Multi = false,
    Text = "Select Teammate to Revive",
    Tooltip = "Choose a downed teammate to instantly revive."
})
RevivePlayerDropdown:OnChanged(function(val)
    State.SelectedPlayer = val
end)

RightColSurv:AddButton({
    Text = "Revive Selected Player",
    Func = function()
        local target = findPlayerBySelection(State.SelectedPlayer)
        if target and target.Character then
            local success = reviveCharacter(target.Character)
            if success then
                Library:Notify("Revive executed on " .. target.DisplayName .. "!", 3)
            else
                Library:Notify("Could not reach " .. target.DisplayName, 3)
            end
        else
            Library:Notify("No character found for " .. tostring(State.SelectedPlayer), 2.5)
        end
    end
})

RightColSurv:AddButton({
    Text = "Refresh Player List",
    Func = function()
        local list = getPlayerNames()
        RevivePlayerDropdown:SetValues(list)
        if #list > 0 then
            RevivePlayerDropdown:SetValue(list[1])
            State.SelectedPlayer = list[1]
        end
        Library:Notify("Teammate list updated!", 2)
    end
})

-- TAB 5: TROLL (DOORS, WINDOWS, DRAWERS, TV, GLASS SPAM)
local TabTroll = Window:AddTab("Troll")
local LeftColTroll = TabTroll:AddLeftGroupbox("Interactable Spam Engines")
local RightColTroll = TabTroll:AddRightGroupbox("House Chaos Tools")

LeftColTroll:AddToggle("SpamDoors", {
    Text = "Spam Open/Close All Doors",
    Default = false,
    Tooltip = "Continuously flips all door prompts across the house rapidly."
}):OnChanged(function(val)
    State.SpamDoors = val
end)

LeftColTroll:AddToggle("SpamWindows", {
    Text = "Spam Open/Close All Windows",
    Default = false,
    Tooltip = "Rapidly slides every window in the house open and shut."
}):OnChanged(function(val)
    State.SpamWindows = val
end)

LeftColTroll:AddToggle("SpamDrawers", {
    Text = "Spam Open/Close All Drawers",
    Default = false,
    Tooltip = "Rapidly cycles all dresser and nightstand drawer clickers."
}):OnChanged(function(val)
    State.SpamDrawers = val
end)

LeftColTroll:AddSlider("SpamInterval", {
    Text = "Spam Delay (Sec)",
    Default = 0.15,
    Min = 0.05,
    Max = 1.0,
    Rounding = 2,
    Compact = false
}):OnChanged(function(val)
    State.SpamInterval = val
end)

LeftColTroll:AddButton({
    Text = "Open All Doors & Windows Once",
    Func = function()
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                local act = (p.ActionText or ""):lower()
                if act == "open" or p.Parent.Name == "DoorFrame" then
                    p.HoldDuration = 0
                    fireproximityprompt(p)
                end
            end
        end
        Library:Notify("Opened all doors and windows!", 2)
    end
})

LeftColTroll:AddButton({
    Text = "Close All Doors & Windows Once",
    Func = function()
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                local act = (p.ActionText or ""):lower()
                if act == "close" or p.Parent.Name == "DoorFrame" then
                    p.HoldDuration = 0
                    fireproximityprompt(p)
                end
            end
        end
        Library:Notify("Closed all doors and windows!", 2)
    end
})

RightColTroll:AddToggle("SpamAll", {
    Text = "Spam Everything (Doors + Windows + Drawers)",
    Default = false,
    Tooltip = "Maximum house chaos: cycles all interactable furniture simultaneously."
}):OnChanged(function(val)
    State.SpamAll = val
end)

RightColTroll:AddToggle("SpamTv", {
    Text = "Spam TV Power Remote",
    Default = false,
    Tooltip = "Spam toggles television power via server remotes."
}):OnChanged(function(val)
    State.SpamTv = val
end)

RightColTroll:AddButton({
    Text = "Shatter All Windows (Break Glass)",
    Func = function()
        if BreakGlassRemote then
            local CollectionService = game:GetService("CollectionService")
            for _, win in ipairs(CollectionService:GetTagged("Window")) do
                BreakGlassRemote:FireServer(win)
            end
            Library:Notify("Sent shatter packets for all windows!", 2)
        end
    end
})

-- TAB 6: VISUALS & ESP
local TabESP = Window:AddTab("Visuals")
local LeftColESP = TabESP:AddLeftGroupbox("ESP Sensors")
local RightColESP = TabESP:AddRightGroupbox("Environment Visuals")

LeftColESP:AddToggle("MonsterESP", {
    Text = "Monster ESP (Chams & Distance)",
    Default = true,
    Tooltip = "Highlights all active monsters through walls with real-time distance trackers."
}):OnChanged(function(val)
    State.MonsterESP = val
end)

LeftColESP:AddToggle("AppleESP", {
    Text = "Apple ESP",
    Default = true,
    Tooltip = "Shows golden outlines and distance on all spawned CashApples."
}):OnChanged(function(val)
    State.AppleESP = val
end)

LeftColESP:AddToggle("LootESP", {
    Text = "Loot & Weapon ESP",
    Default = true,
    Tooltip = "Highlights weapons, ammunition, NVGs, lighters, barricades, and traps in cyan."
}):OnChanged(function(val)
    State.LootESP = val
end)

LeftColESP:AddToggle("PlayerESP", {
    Text = "Player & Downed ESP",
    Default = true,
    Tooltip = "Displays player health % and highlights downed players in orange."
}):OnChanged(function(val)
    State.PlayerESP = val
end)

LeftColESP:AddToggle("WaypointESP", {
    Text = "Killer Route Waypoints ESP",
    Default = false,
    Tooltip = "Highlights the 19 monster patrol nodes across the house and grounds."
}):OnChanged(function(val)
    State.WaypointESP = val
end)

RightColESP:AddToggle("Fullbright", {
    Text = "Fullbright (Clear Vision)",
    Default = true,
    Tooltip = "Eliminates pitch darkness and fog, allowing full map illumination."
}):OnChanged(function(val)
    State.Fullbright = val
    if applyFullbright then applyFullbright(val) end
end)

-- TAB 7: TELEPORTS
local TabTP = Window:AddTab("Teleports")
local ColTP = TabTP:AddLeftGroupbox("Map Anchors")
local ColTPRight = TabTP:AddRightGroupbox("Player Teleport")

ColTP:AddButton({
    Text = "Teleport to Safe Roof (Anti-Monster)",
    Func = function()
        local root = getRoot()
        if root then
            root.CFrame = State.SafeAnchorCFrame
            Library:Notify("Teleported to Safe Roof!", 2)
        end
    end
})

ColTP:AddButton({
    Text = "Teleport to Apple Buyer (Sell Stand)",
    Func = function()
        local root = getRoot()
        if root then
            root.CFrame = State.SellStandGroundCFrame
            Library:Notify("Teleported to Apple Buyer!", 2)
        end
    end
})

ColTP:AddButton({
    Text = "Teleport to Apple Trees Garden",
    Func = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(-514.06, 20.28, 369.31)
            Library:Notify("Teleported to Apple Garden!", 2)
        end
    end
})

ColTP:AddButton({
    Text = "Teleport to Kitchen / Sink (Dishes)",
    Func = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(-447.8, 18.6, 381.5)
            Library:Notify("Teleported to Kitchen Sink!", 2)
        end
    end
})

ColTP:AddButton({
    Text = "Teleport to Attic",
    Func = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(-427.16, 45.02, 319.77)
            Library:Notify("Teleported to Attic!", 2)
        end
    end
})

ColTP:AddButton({
    Text = "Teleport to Living Room",
    Func = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(-455, 22, 335)
            Library:Notify("Teleported to Living Room!", 2)
        end
    end
})

ColTPRight:AddButton({
    Text = "Teleport to Selected Teammate",
    Func = function()
        local target = findPlayerBySelection(State.SelectedPlayer)
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChildWhichIsA("BasePart")
            local root = getRoot()
            if root and tRoot then
                root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
                Library:Notify("Teleported to " .. target.DisplayName .. "!", 2)
            end
        else
            Library:Notify("Player not found!", 2)
        end
    end
})

-- TAB 8: SETTINGS & THEMES
local TabSettings = Window:AddTab("Settings")
local LeftColSettings = TabSettings:AddLeftGroupbox("Input & Controls")

LeftColSettings:AddToggle("UnlockCursor", {
    Text = "Unlock Cursor on GUI",
    Default = true,
    Tooltip = "Ensures cursor is always unlocked and visible whenever the interface is open."
}):OnChanged(function(val)
    State.UnlockCursor = val
end)

LeftColSettings:AddLabel("Keybind: RightShift to Toggle"):SetText("Toggle Key: RightShift")

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("EccoHubV3")
SaveManager:SetFolder("EccoHubV3/AmberAlert")
SaveManager:BuildConfigSection(TabSettings)
ThemeManager:ApplyToTab(TabSettings)

_G.EccoTabs = {
    Farm = TabFarm,
    Combat = TabCombat,
    Movement = TabMove,
    Survival = TabSurv,
    Troll = TabTroll,
    Visuals = TabESP,
    Teleports = TabTP,
    Settings = TabSettings
}

getgenv().gethui = oldGethui

-- Auto-refresh players when they join/leave
Players.PlayerAdded:Connect(function()
    task.wait(1)
    pcall(function()
        local list = getPlayerNames()
        RevivePlayerDropdown:SetValues(list)
    end)
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    pcall(function()
        local list = getPlayerNames()
        RevivePlayerDropdown:SetValues(list)
    end)
end)

-- ==============================================================================
-- INPUT HOOKS & DISCRETE CURSOR MANAGEMENT
-- ==============================================================================
local function updateMouseState()
    if Library.Toggled then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        pcall(function() LocalPlayer:SetAttribute("AA_MouseFree", true) end)
    else
        pcall(function() LocalPlayer:SetAttribute("AA_MouseFree", false) end)
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
    end
end
updateMouseState()

local KeybindConnection = UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Library:Toggle()
        updateMouseState()
    end
end)

_G.EccoHubToggle = function()
    Library:Toggle()
    updateMouseState()
end

-- ==============================================================================
-- CORE LOGIC HOOKS & CONNECTIONS
-- ==============================================================================
local EvasionLockTime = 0

local function checkMonsterEvasion()
    if not State.MonsterEvasion then return end
    local root = getRoot()
    if not root then return end

    local dist = getNearestMonsterDist(root.Position)
    if dist <= State.EvasionDistance then
        root.CFrame = State.SafeAnchorCFrame
        EvasionLockTime = tick() + State.EvasionLockout
        Library:Notify("Threat within " .. math.floor(dist) .. " studs! Evaded to Safe Roof.", 2.5)
    end
end

-- Closet Auto Hide & Safe Exit Routine
local IsHiding = false
local CurrentHidingSpot = nil
local LastHideActionTime = 0

function checkAutoHideCloset()
    if not State.AutoHideCloset or tick() < EvasionLockTime then return end
    local root = getRoot()
    if not root then return end

    local dist = getNearestMonsterDist(root.Position)

    if dist <= State.AutoHideDistance then
        if not IsHiding and (tick() - LastHideActionTime) > 1.5 then
            -- Find nearest HidingSpot that is not on cooldown
            local nearestSpot, nearestTrigger, nearestD = nil, nil, 9999
            for _, inst in ipairs(workspace:GetDescendants()) do
                if inst:IsA("Folder") and string.match(inst.Name, "^HidingSpot%d+$") then
                    local trig = inst:FindFirstChild("HideTrigger")
                    if trig and trig:IsA("BasePart") then
                        local prompt = trig:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt and prompt.Enabled and not (prompt.ActionText or ""):lower():find("cooldown") then
                            local d = (trig.Position - root.Position).Magnitude
                            if d < nearestD then
                                nearestD = d
                                nearestTrigger = trig
                                nearestSpot = inst
                            end
                        end
                    end
                end
            end

            if nearestTrigger and nearestSpot then
                local prompt = nearestTrigger:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    IsHiding = true
                    CurrentHidingSpot = nearestSpot
                    LastHideActionTime = tick()

                    root.CFrame = nearestTrigger.CFrame + Vector3.new(0, 1.5, 0)
                    task.wait(0.05)
                    prompt.HoldDuration = 0
                    fireproximityprompt(prompt)
                    Library:Notify("Threat within " .. math.floor(dist) .. " studs! Hid in " .. nearestSpot.Name, 3)
                end
            end
        end
    else
        -- Threat has retreated! Safely exit closet
        if IsHiding and dist > (State.AutoHideDistance + 12) and (tick() - LastHideActionTime) > 1.5 then
            local trig = CurrentHidingSpot and CurrentHidingSpot:FindFirstChild("HideTrigger")
            local prompt = trig and trig:FindFirstChildWhichIsA("ProximityPrompt")
            if not prompt then
                -- Fallback: check any spot with prompt ActionText == "Exit"
                for _, inst in ipairs(workspace:GetDescendants()) do
                    if inst:IsA("Folder") and string.match(inst.Name, "^HidingSpot%d+$") then
                        local t = inst:FindFirstChild("HideTrigger")
                        local p = t and t:FindFirstChildWhichIsA("ProximityPrompt")
                        if p and (p.ActionText or ""):lower():find("exit") then
                            prompt = p
                            break
                        end
                    end
                end
            end

            if prompt then
                prompt.HoldDuration = 0
                fireproximityprompt(prompt)
                task.wait(0.08)
            end

            IsHiding = false
            CurrentHidingSpot = nil
            LastHideActionTime = tick()

            if State.AlwaysAnchorRoof then
                root.CFrame = State.SafeAnchorCFrame
            end
            Library:Notify("Monster retreated (" .. math.floor(dist) .. " studs). Safely exited closet!", 2.5)
        end
    end
end

-- Flight Engine Implementation
local FlyVelocity = nil

local function updateFlight()
    if not State.Fly then
        if FlyVelocity then
            pcall(function() FlyVelocity:Destroy() end)
            FlyVelocity = nil
        end
        return
    end

    local root = getRoot()
    local hum = getHumanoid()
    local cam = workspace.CurrentCamera
    if not root or not hum or not cam then return end

    if not FlyVelocity or FlyVelocity.Parent ~= root then
        if FlyVelocity then pcall(function() FlyVelocity:Destroy() end) end
        FlyVelocity = Instance.new("BodyVelocity")
        FlyVelocity.Name = "EccoFlyVelocity"
        FlyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        FlyVelocity.Velocity = Vector3.zero
        FlyVelocity.Parent = root
    end

    local moveDir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDir = moveDir + cam.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDir = moveDir - cam.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDir = moveDir - cam.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDir = moveDir + cam.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDir = moveDir + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        moveDir = moveDir - Vector3.new(0, 1, 0)
    end

    if moveDir.Magnitude > 0 then
        FlyVelocity.Velocity = moveDir.Unit * State.FlySpeed
    else
        FlyVelocity.Velocity = Vector3.zero
    end
end

-- Infinite Jump Hook
local JumpRequestConnection = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        _G.AA_AllowJump = true
        local hum = getHumanoid()
        local root = getRoot()
        if hum and root then
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X,
                State.JumpPower > 0 and State.JumpPower or 50,
                root.AssemblyLinearVelocity.Z
            )
        end
    end
end)

local EvasionConnection = RunService.Heartbeat:Connect(function()
    pcall(checkMonsterEvasion)
    pcall(checkAutoHideCloset)
    pcall(updateFlight)
end)

local QTESkillCheckConnection = RunService.RenderStepped:Connect(function()
    pcall(processSkillChecksAndStruggle)
end)

local NoclipConnection = RunService.Stepped:Connect(function()
    if State.Noclip then
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Bulletproof Infinite Stamina & Speed Enforcer
local SpeedConnection = RunService.Heartbeat:Connect(function()
    local hum = getHumanoid()
    if hum then
        if State.WalkSpeed > 16 then
            if hum.WalkSpeed ~= State.WalkSpeed then
                hum.WalkSpeed = State.WalkSpeed
            end
        end
        if State.JumpPower ~= 50 or State.InfiniteJump then
            _G.AA_AllowJump = true
            hum.UseJumpPower = true
            if hum.JumpPower ~= State.JumpPower then
                hum.JumpPower = State.JumpPower
            end
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
    end

    if State.InfiniteStamina then
        _G.AA_WeatherDrainMul = 0
        if Config and Config.Stamina then
            Config.Stamina.DrainPerSecond = 0
            Config.Stamina.RegenDelay = 0
            Config.Stamina.RegenPerSecond = 9999
        end
        pcall(function()
            LocalPlayer:SetAttribute("Stamina", 100)
            LocalPlayer:SetAttribute("AA_Stamina", 100)
        end)
    end
end)

local JumpscareConnection
if JumpscareRemote then
    JumpscareConnection = JumpscareRemote.OnClientEvent:Connect(function()
        if State.AntiJumpscare then
            if JumpscareCancelRemote then
                JumpscareCancelRemote:FireServer()
            end
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, g in ipairs(pg:GetChildren()) do
                    if g.Name:lower():find("jumpscare") or g.Name:lower():find("screamer") then
                        g:Destroy()
                    end
                end
            end
        end
    end)
end

-- ==============================================================================
-- COMBAT ENGINE: KILL AURA, AUTO-STUN, AUTO-TRAP
-- ==============================================================================
local function getActiveGun()
    local char = getCharacter()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local gunNames = {"shotgun", "doubleshotgun", "revolver", "taser", "stungun"}
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                for _, name in ipairs(gunNames) do
                    if tool.Name:lower():find(name) then return tool end
                end
            end
        end
    end
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                for _, name in ipairs(gunNames) do
                    if tool.Name:lower():find(name) then
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then hum:EquipTool(tool) end
                        return tool
                    end
                end
            end
        end
    end
    return nil
end

function runKillAura()
    if not State.KillAura then return end
    local root = getRoot()
    if not root then return end
    local activeMonsters = workspace:FindFirstChild("ActiveMonsters")
    if not activeMonsters then return end

    local gun = getActiveGun()
    if not gun or not WeaponFireRemote then return end

    if State.AutoReload and WeaponReloadRemote then
        local mag = gun:GetAttribute("Mag")
        if mag and mag <= 0 then
            WeaponReloadRemote:FireServer(gun)
        end
    end

    local nearestTarget, nearestDist = nil, State.KillAuraRange
    for _, m in ipairs(activeMonsters:GetChildren()) do
        local mRoot = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head") or m:FindFirstChildWhichIsA("BasePart")
        if mRoot then
            local d = (mRoot.Position - root.Position).Magnitude
            if d < nearestDist then
                nearestDist = d
                nearestTarget = mRoot
            end
        end
    end

    if nearestTarget then
        WeaponFireRemote:FireServer(gun, nearestTarget.Position)
    end
end

local function runAutoTaser()
    if not State.AutoTaser or not WeaponFireRemote then return end
    local root = getRoot()
    if not root then return end
    local activeMonsters = workspace:FindFirstChild("ActiveMonsters")
    if not activeMonsters then return end

    local char = getCharacter()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local stunNames = {"taser", "stungun", "pepper spray"}
    local stunTool = nil

    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then
                for _, sn in ipairs(stunNames) do
                    if t.Name:lower():find(sn) then stunTool = t break end
                end
            end
            if stunTool then break end
        end
    end
    if not stunTool and bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                for _, sn in ipairs(stunNames) do
                    if t.Name:lower():find(sn) then
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then hum:EquipTool(t) end
                        stunTool = t
                        break
                    end
                end
            end
            if stunTool then break end
        end
    end

    if not stunTool then return end

    for _, m in ipairs(activeMonsters:GetChildren()) do
        local mRoot = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
        if mRoot and (mRoot.Position - root.Position).Magnitude <= 35 then
            WeaponFireRemote:FireServer(stunTool, mRoot.Position)
            task.wait(0.3)
            break
        end
    end
end

function placeTrapsOnWaypoints()
    local wpFolder = workspace:FindFirstChild("Waypoints")
    if not wpFolder or not UseItemRemote then return end
    local char = getCharacter()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local trapNames = {"beartrap", "landmine", "glue", "shotgun trap", "electric trap"}
    
    local trapTool = nil
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then
                for _, tn in ipairs(trapNames) do
                    if t.Name:lower():find(tn) then trapTool = t break end
                end
            end
            if trapTool then break end
        end
    end
    if not trapTool and bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                for _, tn in ipairs(trapNames) do
                    if t.Name:lower():find(tn) then trapTool = t break end
                end
            end
            if trapTool then break end
        end
    end

    if not trapTool then
        Library:Notify("No trap tools in inventory! Auto-Buy or buy traps in shop.", 2.5)
        return
    end

    local count = 0
    for _, wp in ipairs(wpFolder:GetChildren()) do
        if wp:IsA("BasePart") then
            UseItemRemote:FireServer(trapTool, wp.Position + Vector3.new(0, 0.2, 0), 0, Vector3.new(0, 1, 0))
            count = count + 1
            task.wait(0.06)
        end
    end
    Library:Notify("Placed traps at " .. count .. " killer patrol routes!", 3)
end

-- ==============================================================================
-- TEAMMATE REVIVE ENGINE
-- ==============================================================================
function reviveCharacter(targetChar)
    if not targetChar or not targetChar.Parent then return false end
    local root = getRoot()
    local tRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChildWhichIsA("BasePart")
    if not root or not tRoot then return false end

    local prompt = nil
    for _, desc in ipairs(targetChar:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            prompt = desc
            break
        end
    end

    if not prompt then
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Parent and p.Parent:IsA("BasePart") then
                if (p.Parent.Position - tRoot.Position).Magnitude <= 10 then
                    prompt = p
                    break
                end
            end
        end
    end

    local originalCFrame = root.CFrame
    root.CFrame = tRoot.CFrame + Vector3.new(0, 1.5, 0)
    task.wait(0.12)

    if prompt then
        prompt.HoldDuration = 0
        fireproximityprompt(prompt)
    end

    if RevivedRemote then
        local targetPlr = Players:GetPlayerFromCharacter(targetChar)
        pcall(function() RevivedRemote:FireServer(targetPlr or targetChar) end)
    end

    task.wait(0.25)
    root.CFrame = State.AlwaysAnchorRoof and State.SafeAnchorCFrame or originalCFrame
    return true
end

local function processAutoRevive()
    if not State.AutoRevive or tick() < EvasionLockTime then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character.Parent then
            local c = plr.Character
            local isDowned = c:GetAttribute("AA_Downed") == true or c:GetAttribute("Downed") == true
            local hasPrompt = false
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("ProximityPrompt") then hasPrompt = true break end
            end
            if isDowned or hasPrompt then
                local cRoot = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChildWhichIsA("BasePart")
                if cRoot and not isMonsterNear(cRoot.Position, State.SafetyClearance) then
                    reviveCharacter(c)
                    task.wait(0.5)
                    break
                end
            end
        end
    end
end

-- ==============================================================================
-- AUTOMATION ENGINE: CHORES (BACKGROUND), TRASH, DISHES & SKILL-CHECKS
-- ==============================================================================
function processAutoChoresBackground()
    if not State.AutoChoresBackground or tick() < EvasionLockTime then return end
    local phase = workspace:GetAttribute("AA_Phase") or "DAY"
    if phase ~= "DAY" then return end

    local root = getRoot()
    if not root then return end

    local currentChore = LocalPlayer:GetAttribute("AA_Chore") or workspace:GetAttribute("AA_ChoreToday")
    local origCFrame = State.AlwaysAnchorRoof and State.SafeAnchorCFrame or root.CFrame

    -- 1. Dish Washing Chore
    if currentChore == "dishes" or workspace:FindFirstChild("AA_DishPrompt", true) then
        if ChoreDishesStartRemote then
            ChoreDishesStartRemote:FireServer()
        end
        local dishPrompt = workspace:FindFirstChild("AA_DishPrompt", true)
        if dishPrompt and dishPrompt.Parent and dishPrompt.Parent:IsA("BasePart") then
            if not isMonsterNear(dishPrompt.Parent.Position, State.SafetyClearance) then
                root.CFrame = dishPrompt.Parent.CFrame + Vector3.new(0, 1.5, 0)
                dishPrompt.HoldDuration = 0
                fireproximityprompt(dishPrompt)
                task.wait(0.15)
            end
        end
        if ChoreDishesDoneRemote then
            ChoreDishesDoneRemote:FireServer()
        end
        root.CFrame = origCFrame
    end

    -- 2. Trash Bag Chore (Single-bag grab-then-dump pipeline)
    local trashPrompts = {}
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Name == "GrabTrash" and p.Enabled then
            if p.Parent and p.Parent:IsA("BasePart") and not isMonsterNear(p.Parent.Position, State.SafetyClearance) then
                table.insert(trashPrompts, p)
            end
        end
    end

    if #trashPrompts > 0 then
        -- Find DumpTrash prompt
        local dumpPrompt = nil
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Name == "DumpTrash" and p.Enabled then
                dumpPrompt = p
                break
            end
        end

        for _, tp in ipairs(trashPrompts) do
            if not State.AutoChoresBackground or tick() < EvasionLockTime then break end
            if tp.Parent and tp.Parent:IsA("BasePart") then
                -- Grab bag
                root.CFrame = tp.Parent.CFrame + Vector3.new(0, 1.5, 0)
                tp.HoldDuration = 0
                fireproximityprompt(tp)
                task.wait(0.12)

                -- Dump bag immediately
                if dumpPrompt and dumpPrompt.Parent and dumpPrompt.Parent:IsA("BasePart") then
                    if not isMonsterNear(dumpPrompt.Parent.Position, State.SafetyClearance) then
                        root.CFrame = dumpPrompt.Parent.CFrame + Vector3.new(0, 1.5, 0)
                        dumpPrompt.HoldDuration = 0
                        fireproximityprompt(dumpPrompt)
                        task.wait(0.12)
                    end
                end
            end
        end

        root.CFrame = origCFrame
    end
end

local LastHeartbeatTap = 0
local LastSweepMarker = nil

local function processSkillChecksAndStruggle()
    -- 1. Clown Struggle
    if State.AutoStruggle then
        local char = getCharacter()
        local isGrabbed = char and char:GetAttribute("AA_ClownGrabbed") == true
        local csGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ClownStruggleGui")
        if isGrabbed or (csGui and csGui.Enabled) then
            if ClownStruggleRemote then
                ClownStruggleRemote:FireServer()
            end
            tapSpace()
        end
    end

    -- 2. Hiding QTE Skill Check (Heartbeat & SweepBar Frame-Perfect Solver)
    if State.AutoSkillCheck then
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local scGui = pg and pg:FindFirstChild("SkillCheckGui")
        if scGui then
            -- Heartbeat QTE
            local hb = scGui:FindFirstChild("HeartbeatQTE")
            if hb and hb.Visible then
                for _, child in ipairs(hb:GetChildren()) do
                    local stroke = child:FindFirstChildOfClass("UIStroke")
                    if stroke and stroke.Color == Color3.fromRGB(90, 220, 120) then
                        if tick() - LastHeartbeatTap > 0.25 then
                            LastHeartbeatTap = tick()
                            tapSpace()
                        end
                        break
                    end
                end
            end

            -- Sweep Bar QTE
            local sb = scGui:FindFirstChild("SweepBarQTE")
            if sb and sb.Visible then
                local cursor = sb:FindFirstChild("Cursor")
                local container = sb:FindFirstChildWhichIsA("Frame")
                if cursor and container then
                    local curX = cursor.Position.X.Scale
                    for _, marker in ipairs(container:GetChildren()) do
                        if marker:IsA("Frame") and marker.BackgroundColor3 == Color3.fromRGB(75, 185, 105) then
                            local lo = marker.Position.X.Scale
                            local hi = lo + marker.Size.X.Scale
                            -- Strict center hit detection
                            if curX >= (lo + 0.005) and curX <= (hi - 0.005) then
                                if LastSweepMarker ~= marker then
                                    LastSweepMarker = marker
                                    tapSpace()
                                end
                                break
                            end
                        end
                    end
                end
            else
                LastSweepMarker = nil
            end
        end
    end
end

-- ==============================================================================
-- TROLL SPAM ENGINE (DOORS, WINDOWS, DRAWERS, TV)
-- ==============================================================================
local CachedDoors = {}
local CachedWindows = {}
local CachedDrawers = {}
local LastTrollCacheTime = 0

local function refreshTrollCache()
    if tick() - LastTrollCacheTime < 6 then return end
    LastTrollCacheTime = tick()
    local doors, windows, drawers = {}, {}, {}
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Parent then
            local pName = p.Parent.Name
            if pName == "DoorFrame" then
                table.insert(doors, p)
            elseif pName == "windowmove" then
                table.insert(windows, p)
            elseif pName == "Clicker" then
                table.insert(drawers, p)
            end
        end
    end
    CachedDoors = doors
    CachedWindows = windows
    CachedDrawers = drawers
end

function runTrollSpam()
    refreshTrollCache()

    -- 1. Door Spam
    if State.SpamDoors or State.SpamAll then
        for _, p in ipairs(CachedDoors) do
            if p.Parent then
                p.HoldDuration = 0
                fireproximityprompt(p)
            end
        end
    end

    -- 2. Window Spam
    if State.SpamWindows or State.SpamAll then
        for _, p in ipairs(CachedWindows) do
            if p.Parent then
                p.HoldDuration = 0
                fireproximityprompt(p)
            end
        end
    end

    -- 3. Drawer Spam
    if State.SpamDrawers or State.SpamAll then
        for _, p in ipairs(CachedDrawers) do
            if p.Parent then
                p.HoldDuration = 0
                fireproximityprompt(p)
            end
        end
    end

    -- 4. TV Spam
    if State.SpamTv and TvToggleRemote then
        TvToggleRemote:FireServer()
    end
end

-- ==============================================================================
-- HOUSE CASH EXTRACTION ENGINE
-- ==============================================================================
function collectHouseMoney()
    if tick() < EvasionLockTime then return 0 end
    local root = getRoot()
    if not root then return 0 end

    local origCFrame = State.AlwaysAnchorRoof and State.SafeAnchorCFrame or root.CFrame
    local collected = 0

    local cashParts = {}
    for _, inst in ipairs(workspace:GetChildren()) do
        if (inst.Name == "Cash" or inst.Name == "Coin") and inst:IsA("BasePart") then
            local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt and not isMonsterNear(inst.Position, State.SafetyClearance) then
                table.insert(cashParts, {Part = inst, Prompt = prompt})
            end
        end
    end

    for _, c in ipairs(cashParts) do
        if c.Part and c.Part.Parent and c.Prompt and c.Prompt.Parent then
            root.CFrame = c.Part.CFrame + Vector3.new(0, 1.5, 0)
            c.Prompt.HoldDuration = 0
            fireproximityprompt(c.Prompt)
            collected = collected + 1
            task.wait(0.06)
        end
    end

    root.CFrame = origCFrame
    return collected
end

-- ==============================================================================
-- ESP ENGINE
-- ==============================================================================
local safeParent = LocalPlayer:WaitForChild("PlayerGui")
local ESPFolder = safeParent:FindFirstChild("Ecco_ESP_Cache")
if not ESPFolder then
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "Ecco_ESP_Cache"
    pcall(function() ESPFolder.Parent = safeParent end)
else
    ESPFolder:ClearAllChildren()
end

local ActiveHighlights = {}

local function createESP(target, color, text, isEntity)
    if not target or not target.Parent then return end
    local tag = target:GetDebugId()
    if ActiveHighlights[tag] then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = target
    hl.FillColor = color
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = ESPFolder

    local adornPart = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart")
    local bb = nil
    if adornPart then
        bb = Instance.new("BillboardGui")
        bb.Adornee = adornPart
        bb.Size = UDim2.new(0, 140, 0, 30)
        bb.StudsOffset = Vector3.new(0, isEntity and 2.8 or 1.2, 0)
        bb.AlwaysOnTop = true
        bb.Parent = ESPFolder

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = color
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextStrokeTransparency = 0.2
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        lbl.Text = text
        lbl.Parent = bb
    end

    ActiveHighlights[tag] = {
        Highlight = hl,
        Billboard = bb,
        Label = bb and bb:FindFirstChildOfClass("TextLabel"),
        Target = target
    }
end

local function cleanESP(tag)
    if ActiveHighlights[tag] then
        pcall(function()
            if ActiveHighlights[tag].Highlight then ActiveHighlights[tag].Highlight:Destroy() end
            if ActiveHighlights[tag].Billboard then ActiveHighlights[tag].Billboard:Destroy() end
        end)
        ActiveHighlights[tag] = nil
    end
end

function cleanAllESP()
    for tag, _ in pairs(ActiveHighlights) do
        cleanESP(tag)
    end
end

local Running = true

task.spawn(function()
    while Running do
        task.wait(0.6)
        local root = getRoot()
        local rootPos = root and root.Position

        -- 1. Monster ESP
        if State.MonsterESP then
            local activeMonsters = workspace:FindFirstChild("ActiveMonsters")
            local list = activeMonsters and activeMonsters:GetChildren() or {}
            for _, mon in ipairs(list) do
                if mon and mon.Parent then
                    local tag = mon:GetDebugId()
                    local monRoot = mon:FindFirstChild("HumanoidRootPart") or mon:FindFirstChildWhichIsA("BasePart")
                    local dist = (monRoot and rootPos) and math.floor((monRoot.Position - rootPos).Magnitude) or 0
                    local text = mon.Name .. " [" .. dist .. "m]"

                    if not ActiveHighlights[tag] then
                        createESP(mon, Color3.fromRGB(255, 45, 45), text, true)
                    else
                        local data = ActiveHighlights[tag]
                        if data and data.Label then data.Label.Text = text end
                    end
                end
            end
        else
            for tag, data in pairs(ActiveHighlights) do
                if data.Target and data.Target:IsA("Model") and data.Target.Parent and data.Target.Parent.Name == "ActiveMonsters" then
                    cleanESP(tag)
                end
            end
        end

        -- 2. Apple ESP
        if State.AppleESP then
            for _, inst in ipairs(workspace:GetChildren()) do
                if inst.Name == "CashApple" and inst:IsA("BasePart") then
                    local tag = inst:GetDebugId()
                    local dist = rootPos and math.floor((inst.Position - rootPos).Magnitude) or 0

                    if not ActiveHighlights[tag] then
                        createESP(inst, Color3.fromRGB(255, 215, 0), "Apple [" .. dist .. "m]", false)
                    else
                        local data = ActiveHighlights[tag]
                        if data and data.Label then data.Label.Text = "Apple [" .. dist .. "m]" end
                    end
                end
            end
        else
            for tag, data in pairs(ActiveHighlights) do
                if data.Target and data.Target.Name == "CashApple" then cleanESP(tag) end
            end
        end

        -- 3. Player ESP
        if State.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                local char = plr ~= LocalPlayer and plr.Character
                if char and char.Parent then
                    local pRoot = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local tag = char:GetDebugId()
                    local dist = (pRoot and rootPos) and math.floor((pRoot.Position - rootPos).Magnitude) or 0
                    local isDowned = char:GetAttribute("AA_Downed") or false
                    local text = plr.DisplayName .. (isDowned and " [DOWNED!]" or " [" .. math.floor(hum and hum.Health or 100) .. "%]")
                    local col = isDowned and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(80, 255, 140)

                    if not ActiveHighlights[tag] then
                        createESP(char, col, text, true)
                    else
                        local data = ActiveHighlights[tag]
                        if data and data.Label then
                            data.Label.Text = text
                            data.Label.TextColor3 = col
                        end
                    end
                end
            end
        else
            for tag, data in pairs(ActiveHighlights) do
                if data.Target and Players:GetPlayerFromCharacter(data.Target) then cleanESP(tag) end
            end
        end

        -- 4. Loot & Cash ESP
        if State.LootESP then
            local lootKeywords = {"cash", "coin", "shotgun", "ammo", "taser", "flashlight", "lighter", "trap", "cola", "key", "landmine"}
            for _, item in ipairs(workspace:GetChildren()) do
                if (item:IsA("Tool") or item:IsA("BasePart")) and not item:IsDescendantOf(LocalPlayer.Character) then
                    local nameLow = item.Name:lower()
                    local matched = false
                    for _, kw in ipairs(lootKeywords) do
                        if nameLow:find(kw) then matched = true break end
                    end
                    if matched then
                        local tag = item:GetDebugId()
                        local iPos = item:IsA("BasePart") and item.Position or (item:FindFirstChildWhichIsA("BasePart") and item:FindFirstChildWhichIsA("BasePart").Position)
                        local dist = (iPos and rootPos) and math.floor((iPos - rootPos).Magnitude) or 0
                        local isCash = nameLow:find("cash") or nameLow:find("coin")
                        local col = isCash and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(0, 220, 255)
                        local text = item.Name .. " [" .. dist .. "m]"

                        if not ActiveHighlights[tag] then
                            createESP(item, col, text, false)
                        else
                            local data = ActiveHighlights[tag]
                            if data and data.Label then data.Label.Text = text end
                        end
                    end
                end
            end
        end

        -- Clean up dead ESP entries
        for tag, data in pairs(ActiveHighlights) do
            if not data.Target or not data.Target.Parent then cleanESP(tag) end
        end
    end
end)

-- Fullbright Cycle
local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd
}

function applyFullbright(enabled)
    if enabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
    else
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.FogEnd = OriginalLighting.FogEnd
    end
end

-- ==============================================================================
-- AUTOMATED FARM & PROGRESSION ENGINE
-- ==============================================================================
function collectAvailableApples()
    if tick() < EvasionLockTime then return end
    local root = getRoot()
    if not root then return end

    local safeReturnCFrame = State.AlwaysAnchorRoof and State.SafeAnchorCFrame or root.CFrame

    local apples = {}
    for _, inst in ipairs(workspace:GetChildren()) do
        if inst.Name == "CashApple" and inst:IsA("BasePart") then
            local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt and (State.TurboHarvest or canHarvestSafely(inst)) then
                table.insert(apples, {Part = inst, Prompt = prompt})
            end
        end
    end

    if #apples == 0 then return end

    for _, apple in ipairs(apples) do
        if not State.AutoFarmApples or tick() < EvasionLockTime then break end
        if apple.Part and apple.Part.Parent and apple.Prompt and apple.Prompt.Parent then
            if State.TurboHarvest or canHarvestSafely(apple.Part) then
                root.CFrame = apple.Part.CFrame + Vector3.new(0, 1.5, 0)
                apple.Prompt.HoldDuration = 0
                fireproximityprompt(apple.Prompt)
                if not State.TurboHarvest then
                    task.wait(0.08)
                end
            end
        end
    end

    root.CFrame = safeReturnCFrame
end

function sellApplesRoutine()
    if tick() < EvasionLockTime then return end
    local root = getRoot()
    if not root then return end

    local currentApples = LocalPlayer:GetAttribute("Apples") or 0
    if currentApples < State.SellThreshold then return end

    if State.SafeSellOnly and not canSellSafely() then return end

    local sellPart = workspace:FindFirstChild("AppleSell", true)
    if not sellPart then return end

    local prompt = sellPart:FindFirstChildWhichIsA("ProximityPrompt")
    if not prompt then return end

    local safeReturnCFrame = State.AlwaysAnchorRoof and State.SafeAnchorCFrame or root.CFrame

    root.CFrame = State.SellStandGroundCFrame
    task.wait(0.2)
    prompt.HoldDuration = 0
    fireproximityprompt(prompt)
    task.wait(0.35)
    root.CFrame = safeReturnCFrame
end

function processAutoPurchases()
    local cash = LocalPlayer:GetAttribute("Cash") or 0

    if State.AutoBuyTrees and ShopBuyRemote then
        local bought = workspace:GetAttribute("AA_AppleTreesBought") or 0
        local nextPrice = TreePriceTable[bought + 1]
        if nextPrice and cash >= nextPrice and bought < 10 then
            ShopBuyRemote:FireServer("AppleTree")
            task.wait(0.3)
        end
    end

    if State.AutoBuyGarden and GardenBuyRemote then
        for _, upg in ipairs(GardenUpgradeList) do
            GardenBuyRemote:FireServer(upg)
            task.wait(0.1)
        end
    end

    if State.AutoBuyAppleUpgrades and UpgradeBuyRemote then
        for _, upg in ipairs(AppleUpgradeList) do
            UpgradeBuyRemote:FireServer(upg)
            task.wait(0.1)
        end
    end

    if State.AutoBuyWeapons and ShopBuyRemote then
        if cash >= 2700 then
            ShopBuyRemote:FireServer("Shotgun")
        elseif cash >= 500 then
            ShopBuyRemote:FireServer("DoubleShotgun")
        end
    end

    if State.AutoBuyAmmo and ShopBuyRemote then
        if cash >= 600 then
            ShopBuyRemote:FireServer("ShotgunShells")
        end
        if cash >= 260 then
            ShopBuyRemote:FireServer("AmmoRegular")
        end
    end
end

-- Main Farm & Chores Loop
task.spawn(function()
    while Running do
        task.wait(State.FarmDelay)
        if State.AutoFarmApples then
            pcall(collectAvailableApples)
        end
        if State.AutoSellApples then
            pcall(sellApplesRoutine)
        end
        if State.AutoPickUpHouseMoney then
            pcall(collectHouseMoney)
        end
        pcall(processAutoPurchases)
        pcall(processSkillChecksAndStruggle)
        pcall(processAutoRevive)
        pcall(processAutoChoresBackground)
    end
end)

-- Combat Fast Loop
task.spawn(function()
    while Running do
        task.wait(State.KillAuraDelay)
        if State.KillAura then
            pcall(runKillAura)
        end
        if State.AutoTaser then
            pcall(runAutoTaser)
        end
    end
end)

-- Troll Spam Loop
task.spawn(function()
    while Running do
        task.wait(State.SpamInterval)
        if State.SpamDoors or State.SpamWindows or State.SpamDrawers or State.SpamAll or State.SpamTv then
            pcall(runTrollSpam)
        end
    end
end)

-- Trap Patrol Loop
task.spawn(function()
    while Running do
        task.wait(10)
        if State.AutoTrapPatrols then
            pcall(placeTrapsOnWaypoints)
        end
    end
end)

-- Clean Unload Hook
local function unloadSuite()
    Running = false
    if EvasionConnection then EvasionConnection:Disconnect() end
    if QTESkillCheckConnection then QTESkillCheckConnection:Disconnect() end
    if NoclipConnection then NoclipConnection:Disconnect() end
    if SpeedConnection then SpeedConnection:Disconnect() end
    if JumpscareConnection then JumpscareConnection:Disconnect() end
    if KeybindConnection then KeybindConnection:Disconnect() end
    if JumpRequestConnection then JumpRequestConnection:Disconnect() end
    if FlyVelocity then
        pcall(function() FlyVelocity:Destroy() end)
        FlyVelocity = nil
    end
    cleanAllESP()
    applyFullbright(false)
    pcall(function() LocalPlayer:SetAttribute("AA_MouseFree", false) end)
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false
    pcall(function() Library:Unload() end)
    pcall(function() if Library.ScreenGui then Library.ScreenGui:Destroy() end end)
    _G.AmberAlertSuiteUnload = nil
end

Library:OnUnload(unloadSuite)
_G.AmberAlertSuiteUnload = unloadSuite

applyFullbright(true)

Library:Notify("Ecco Hub V3 loaded successfully! Press RightShift to toggle.", 4)
