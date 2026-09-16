--[[
    SELL LEMONS — Standalone Automation Script
    MCP-verified against PlaceId 79268393072444
]]

if game.PlaceId ~= 79268393072444 then
    warn("[Sell Lemons] Wrong place. Detected: " .. tostring(game.PlaceId))
    return
end

local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- ============================================================
-- CINEMATIC & POPUP BYPASSES (Hooked immediately)
-- ============================================================
local skipCinematics = true
task.spawn(function()
    local ok1, CinematicTrack = pcall(require, RS:WaitForChild("Core"):WaitForChild("CinematicTrack"))
    if ok1 and CinematicTrack then
        local oldPlay = CinematicTrack.Play
        local oldPlayAsync = CinematicTrack.PlayAsync
        
        if oldPlay and hookfunction then
            pcall(hookfunction, oldPlay, function(self, ...)
                if skipCinematics then
                    self.Stopped:Fire()
                    return
                end
                return oldPlay(self, ...)
            end)
        elseif oldPlay then
            pcall(function()
                CinematicTrack.Play = function(self, ...)
                    if skipCinematics then
                        self.Stopped:Fire()
                        return
                    end
                    return oldPlay(self, ...)
                end
            end)
        end
        
        if oldPlayAsync and hookfunction then
            pcall(hookfunction, oldPlayAsync, function(self, ...)
                if skipCinematics then
                    self.Stopped:Fire()
                    return true
                end
                return oldPlayAsync(self, ...)
            end)
        elseif oldPlayAsync then
            pcall(function()
                CinematicTrack.PlayAsync = function(self, ...)
                    if skipCinematics then
                        self.Stopped:Fire()
                        return true
                    end
                    return oldPlayAsync(self, ...)
                end
            end)
        end
    end

    local ok2, UIRevealPopup = pcall(require, RS:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("Layers"):WaitForChild("Popup"):WaitForChild("UIRevealPopup"))
    if ok2 and UIRevealPopup then
        local oldReveal = UIRevealPopup.RevealAsync
        if oldReveal and hookfunction then
            pcall(hookfunction, oldReveal, function(self, ...)
                if skipCinematics then
                    return true
                end
                return oldReveal(self, ...)
            end)
        elseif oldReveal then
            pcall(function()
                UIRevealPopup.RevealAsync = function(self, ...)
                    if skipCinematics then
                        return true
                    end
                    return oldReveal(self, ...)
                end
            end)
        end
    end
end)

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

local SESSION_KEY = "ECCOHUB-LEMONS"

local Window = Luna:CreateWindow({
    Name = "Ecco Hub",
    Subtitle = "Sell Lemons",
    LoadingEnabled = true,
    LoadingTitle = "Ecco Hub",
    LoadingSubtitle = "Sell Lemons",
    ConfigSettings = {
        RootFolder = "SellLemons",
        ConfigFolder = "Config",
    },
    KeySystem = false,
})

Window:CreateHomeTab({
    SupportedExecutors = {
        -- Raw names for matching
        "Volt", "Potassium", "Seliware", "Medium", "Wave", "Synapse Z", "Velocity", "Solara", "SirHurt", "Delta", "Codex", "Mac",
        -- Beautiful list display
        "🟢 Volt",
        "🟢 Potassium",
        "🟢 Seliware",
        "🟢 Medium",
        "🟢 Wave",
        "🟢 Synapse Z",
        "🟡 Velocity (Untested)",
        "🟡 Solara (Untested)",
        "🟡 SirHurt (Untested)",
        "🔴 Xeno (Not Supported)",
        "🟢 All Mac Executors",
        "🟢 Delta (Android/iOS Rec)",
        "🟢 Codex (Android/iOS Rec)"
    },
    DiscordInvite = "ecc00",
    Icon = "home",
    ImageSource = "Material",
})

-- Parent UI to PlayerGui to prevent permission errors
task.spawn(function()
    for i = 1, 50 do
        local ui = game:GetService("CoreGui"):FindFirstChild("Luna UI")
        if not ui and gethui then
            ui = gethui():FindFirstChild("Luna UI")
        end
        if ui then
            local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pgui then
                pcall(function() ui.Parent = pgui end)
                break
            end
        end
        task.wait(0.1)
    end
end)

-- Fix Luna UI's executor support display bug asynchronously
task.spawn(function()
    local currentExecutor = identifyexecutor and identifyexecutor() or "Unknown"
    local greenExecutors = {"Volt", "Potassium", "Seliware", "Medium", "Wave", "Synapse Z", "Delta", "Codex", "Mac"}
    local yellowExecutors = {"Velocity", "Solara", "SirHurt"}
    
    local isGreen = false
    local isYellow = false
    for _, name in ipairs(greenExecutors) do
        if currentExecutor:lower():find(name:lower()) or name:lower():find(currentExecutor:lower()) then
            isGreen = true
            break
        end
    end
    if not isGreen then
        for _, name in ipairs(yellowExecutors) do
            if currentExecutor:lower():find(name:lower()) or name:lower():find(currentExecutor:lower()) then
                isYellow = true
                break
            end
        end
    end

    for i = 1, 100 do
        local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local ui = pgui and pgui:FindFirstChild("Luna UI")
        local clientCard = ui and ui:FindFirstChild("SmartWindow")
            and ui.SmartWindow:FindFirstChild("Elements")
            and ui.SmartWindow.Elements:FindFirstChild("Interactions")
            and ui.SmartWindow.Elements.Interactions:FindFirstChild("Home")
            and ui.SmartWindow.Elements.Interactions.Home:FindFirstChild("detailsholder")
            and ui.SmartWindow.Elements.Interactions.Home.detailsholder:FindFirstChild("dashboard")
            and ui.SmartWindow.Elements.Interactions.Home.detailsholder.dashboard:FindFirstChild("Client")
        
        if clientCard and clientCard:FindFirstChild("Subtitle") then
            local stroke = clientCard:FindFirstChild("UIStroke")
            local strokeGrad = stroke and stroke:FindFirstChild("UIGradient")
            local fillGrad = clientCard:FindFirstChild("UIGradient")
            
            if isGreen then
                clientCard.Subtitle.Text = "Your Executor is Fully Supported!"
                clientCard.Subtitle.TextColor3 = Color3.fromRGB(0, 220, 110)
                pcall(function()
                    if strokeGrad then
                        strokeGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 60, 30)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 220, 110))
                        })
                    end
                    if fillGrad then
                        fillGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 30, 15)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 110, 55))
                        })
                    end
                end)
            elseif isYellow then
                clientCard.Subtitle.Text = "Your Executor is Partially Supported."
                clientCard.Subtitle.TextColor3 = Color3.fromRGB(255, 200, 0)
                pcall(function()
                    if strokeGrad then
                        strokeGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 50, 20)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 0))
                        })
                    end
                    if fillGrad then
                        fillGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 25, 10)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 100, 0))
                        })
                    end
                end)
            else
                clientCard.Subtitle.Text = "Your Executor Isn't Officially Supported By This Script."
                clientCard.Subtitle.TextColor3 = Color3.fromRGB(255, 80, 80)
                pcall(function()
                    if strokeGrad then
                        strokeGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 20, 20)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 80))
                        })
                    end
                    if fillGrad then
                        fillGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 10, 10)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 30, 30))
                        })
                    end
                end)
            end
            break
        end
        task.wait(0.1)
    end
end)

-- ============================================================
-- MODULE LOADING
-- ============================================================
local modules = {}
local modulesReady = false

pcall(function()
    modules.LocalTycoon      = require(RS.Modules.Tycoon.LocalTycoon)
    modules.ClientPurchase   = require(RS.Modules.Tycoon.Entity.Client.ClientTycoonPurchase)
    modules.ClientEarner     = require(RS.Modules.Tycoon.Entity.Client.ClientTycoonEarner)
    modules.ClientCashVine   = require(RS.Modules.Entity.Client.ClientCashVine)
    modules.ClientRebirth    = require(RS.Modules.Tycoon.Component.Client.ClientTycoonRebirth)
    modules.ClientEvolution  = require(RS.Modules.Tycoon.Component.Client.ClientTycoonEvolution)
    modules.ClientAscension  = require(RS.Modules.Tycoon.Component.Client.ClientTycoonAscension)
    modules.ClientPhoneOffers= require(RS.Modules.Tycoon.Component.Client.ClientTycoonPhoneOffers)
    modules.TycoonBalances   = require(RS.Modules.Tycoon.Component.TycoonBalances)
    modules.ClientPowers     = require(RS.Modules.Tycoon.Component.Client.ClientTycoonPowers)
    modules.ClientValues     = require(RS.Modules.Tycoon.Component.Client.ClientTycoonValues)
    modules.ClientIncome     = require(RS.Modules.Tycoon.Component.Client.ClientTycoonIncome)
    modules.Huge             = require(RS.Modules.Huge)
    modules.RemoteRequest    = require(RS.Core.RemoteRequest)
    modules.RemoteSignal     = require(RS.Core.RemoteSignal)
    modules.OrchardFruit     = require(RS.Modules.Tycoon.Orchard.OrchardFruit)

    if modules.RemoteRequest then
        pcall(function() modules.raceStart   = modules.RemoteRequest.new("MinigameRaceService.Start") end)
        pcall(function() modules.raceEnd     = modules.RemoteRequest.new("MinigameRaceService.End") end)
        pcall(function() modules.tradeStart  = modules.RemoteRequest.new("MinigameTradeService.Start") end)
        pcall(function() modules.tradeEnd    = modules.RemoteRequest.new("MinigameTradeService.End") end)
        pcall(function() modules.cashRedeem  = modules.RemoteRequest.new("CashDropService.Redeem") end)
    end

    if modules.RemoteSignal and modules.cashRedeem then
        pcall(function()
            local sig = modules.RemoteSignal.new("CashDropService.New")
            sig:Connect(function(id)
                if runners["cashDrops"] then
                    task.wait(0.2)
                    pcall(function() modules.cashRedeem:InvokeServer(id) end)
                    stats.cashDrops = (stats.cashDrops or 0) + 1
                end
            end)
        end)
    end

    modulesReady = modules.LocalTycoon ~= nil
end)

-- ============================================================
-- STATE CONFIGURATIONS
-- ============================================================
local progressionConfig = {
    MinInvestorsToRebirth = 1,
    StopRebirthAtInvestors = false,
    TargetInvestors = "10",
    StopRebirthAtEvolution = false,
    TargetEvolutionProgress = 90,
    MinCashBeforeRebirth = "0",
    MaxRebirths = 9999,
    RebirthDelay = 0.5,
    BuyProgressionOnly = false,
    HaggleOffers = false,
    MaxEvolutionLevel = 10,
    UpgradeDelay = 0.1,
    BuyDelay = 0.1,
    AutoPermanentBuy = false,
    AutoPermanentBuyBest = false,
    PriorityPermanentBuy = "",
    RebirthMultiplier = 1,
    SelectedPowersOrder = {
        "UpgradeStack",
        "BuyNext",
        "Manage",
        "WalkSpeed",
        "ClickFruitValue",
        "AutoFruit"
    }
}

local perfConfig = {
    LoopInterval = 0.4,
    TeleportFruitPicking = true,
    TPWaitTime = 0.05,
    LighterPerformance = false,
    DisableCinematics = true
}

local orchardConfig = {
    AutoBuyOrchard = false,
    AutoExpandPlots = false,
    AutoPlantTrees = false,
    AutoPlantBetterSeed = false,
    AutoReplaceLesserTrees = false,
    AutoHarvestTrees = false,
    AutoSellFruits = false,
    AutoEatFruits = false,
    AutoBuyPlotUpgrades = false,
    AvoidBadMutations = false,
    RerollTargetMutations = false,
    TargetMutations = {},
    SelectedFertilizer = "None",
    AntiFall = false,
    NoCollision = false,
    TeleportPlots = false
}

local stats = {
    fruitsPicked = 0,
    streamsWoken = 0,
    itemsBought = 0,
    itemsUpgraded = 0,
    rebirths = 0,
    evolves = 0,
    ascends = 0,
    totalRebirths = 0,
    totalEvolves = 0,
    totalAscends = 0,
    sessionRebirths = 0,
    sessionEvolves = 0,
    sessionAscends = 0,
    cashDrops = 0,
    raceWins = 0,
    tradeWins = 0,
    powersBought = 0,
    sessionEarned = nil,
    lastCash = nil,
    rateStr = "...",
    rateWindow = nil,
    investors = "...",
    raceNextAt = 0,
    tradeNextAt = 0,
}

local webhookURL = ""
local webhookInputRef = nil
local webhookEvents = { Rebirth = true, Evolve = true, Ascend = true }

local runners = {}

local function getCurrentWebhookURL()
    if webhookInputRef and webhookInputRef.CurrentValue and webhookInputRef.CurrentValue ~= "" then
        return webhookInputRef.CurrentValue
    end
    return webhookURL
end

-- ============================================================
-- WEBHOOKS
-- ============================================================
local function sendWebhook(title, description, color, fields)
    local url = getCurrentWebhookURL()
    if url == "" then return end
    local requestFn = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
    if not requestFn then
        Luna:Notification({Title = "Webhook", Content = "Executor doesn't expose HTTP requests."})
        return
    end
    local totalFruits = 0
    pcall(function()
        totalFruits = LocalPlayer.Values:GetAttribute("FruitsClicked") or 0
    end)
    local embedFields = fields or {}
    table.insert(embedFields, { name = "💰 Session Earned", value = stats.sessionEarned and ("$" .. fmt(stats.sessionEarned)) or "$0", inline = true })
    table.insert(embedFields, { name = "📈 Earn Rate",      value = stats.rateStr or "—",          inline = true })
    table.insert(embedFields, { name = "🔄 Rebirths",       value = string.format("Total: %d\nSession: %d", stats.totalRebirths, stats.sessionRebirths), inline = true })
    table.insert(embedFields, { name = "⬆️ Evolves",        value = string.format("Total: %d\nSession: %d", stats.totalEvolves, stats.sessionEvolves), inline = true })
    table.insert(embedFields, { name = "✨ Ascends",        value = string.format("Total: %d\nSession: %d", stats.totalAscends, stats.sessionAscends), inline = true })
    table.insert(embedFields, { name = "🍋 Fruits Picked",  value = string.format("Total: %s\nSession: %d", tostring(totalFruits), stats.fruitsPicked), inline = true })
    local ok, err = pcall(function()
        local HttpService = game:GetService("HttpService")
        local response = requestFn({
            Url = url, Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "🍋 " .. title,
                    description = description,
                    color = color or 16776960,
                    fields = embedFields,
                    timestamp = DateTime.now():ToIsoDate(),
                    footer = { text = "Ecco Hub • Sell Lemons" },
                }},
            }),
        })
        if response and response.StatusCode and (response.StatusCode < 200 or response.StatusCode >= 300) then
            error("Discord returned " .. tostring(response.StatusCode))
        end
    end)
    if not ok then Luna:Notification({Title = "Webhook Failed", Content = tostring(err)}) end
end

-- ============================================================
-- ECONOMY HELPERS (Logarithmic scaling)
-- ============================================================
local function getTycoon()
    if modules.LocalTycoon then return modules.LocalTycoon.get() end
end

local function getCash(tycoon)
    local cash = 0
    pcall(function() cash = tycoon:GetComponent(modules.TycoonBalances):GetCash() end)
    return cash
end

local function ctx()
    if not modules.LocalTycoon then return nil end
    local ok, c = pcall(function()
        local t = modules.LocalTycoon.get()
        if not t then return nil end
        return {
            t    = t,
            inst = t.Instance,
            bal  = modules.TycoonBalances    and t:GetComponent(modules.TycoonBalances)    or nil,
            reb  = modules.ClientRebirth     and t:GetComponent(modules.ClientRebirth)     or nil,
            evo  = modules.ClientEvolution   and t:GetComponent(modules.ClientEvolution)   or nil,
            asc  = modules.ClientAscension   and t:GetComponent(modules.ClientAscension)   or nil,
            pow  = modules.ClientPowers      and t:GetComponent(modules.ClientPowers)      or nil,
            pho  = modules.ClientPhoneOffers and t:GetComponent(modules.ClientPhoneOffers) or nil,
            inc  = modules.ClientIncome      and t:GetComponent(modules.ClientIncome)      or nil,
            val  = modules.ClientValues      and t:GetComponent(modules.ClientValues)      or nil,
        }
    end)
    return ok and c or nil
end

local function fmt(v)
    if modules.Huge then
        local ok, s = pcall(modules.Huge.formatAbbreviated, v)
        if ok and s then return tostring(s) end
    end
    return tostring(v)
end

local function parseToHuge(valStr)
    local num = tonumber(valStr)
    if num then
        return math.log10(num)
    end
    local exp = valStr:match("[eE](%d+)")
    if exp then
        return tonumber(exp) or -math.huge
    end
    return -math.huge
end

local function logAdd(a, b)
    if not a or a == -math.huge then return b end
    if not b or b == -math.huge then return a end
    local maxVal = math.max(a, b)
    local minVal = math.min(a, b)
    return maxVal + math.log10(1 + 10^(minVal - maxVal))
end

local function logSubtract(a, b)
    if not b or b == -math.huge then return a end
    if not a or a <= b then return -math.huge end
    return a + math.log10(1 - 10^(b - a))
end

-- Evolution Progress logic (Logarithmic)
local function getEvoProgress(currentInvestors)
    local u2 = 17.7
    local u3 = 13.6
    if currentInvestors < u2 then
        return 0, math.clamp((currentInvestors / u2) * 100, 0, 100)
    else
        local continuous = (currentInvestors - u2) / u3
        local level = math.floor(continuous) + 1
        local rem = continuous - math.floor(continuous)
        return level, math.clamp(rem * 100, 0, 100)
    end
end

-- ============================================================
-- PROGRESS OVERLAY HUD
-- ============================================================
local overlaySG, overlayEvo, overlayAsc, overlayStats = nil, nil, nil, nil
local overlayStartTime = os.time()

local function createProgressBar(parent, titleText, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Text = titleText .. ": 0%"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Roboto
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame

    local bgBar = Instance.new("Frame")
    bgBar.Size = UDim2.new(1, 0, 0, 8)
    bgBar.Position = UDim2.new(0, 0, 0, 18)
    bgBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    bgBar.BorderSizePixel = 0
    bgBar.Parent = frame

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = bgBar

    local fillBar = Instance.new("Frame")
    fillBar.Size = UDim2.new(0, 0, 1, 0)
    fillBar.BackgroundColor3 = color
    fillBar.BorderSizePixel = 0
    fillBar.Parent = bgBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fillBar

    return {
        SetProgress = function(pct)
            label.Text = string.format("%s: %.1f%%", titleText, pct)
            TweenService:Create(fillBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(math.clamp(pct/100, 0, 1), 0, 1, 0)
            }):Play()
        end
    }
end

local cardLabels = {}

local function toggleOverlay(enabled)
    if not enabled then
        if overlaySG then
            overlaySG:Destroy()
            overlaySG = nil
            cardLabels = {}
        end
        return
    end

    if overlaySG then return end
    local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pgui then return end

    overlaySG = Instance.new("ScreenGui")
    overlaySG.Name = "EccoFullscreenOverlay"
    overlaySG.ResetOnSpawn = false
    overlaySG.Parent = pgui

    -- Full Screen Frame
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    bg.BackgroundTransparency = 0.15
    bg.BorderSizePixel = 0
    bg.Parent = overlaySG

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 120, 0, 35)
    closeBtn.Position = UDim2.new(0.9, -10, 0.02, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Text = "Minimize HUD"
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 13
    closeBtn.Parent = bg
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        toggleOverlay(false)
        Luna:Notification({Title = "Overlay", Content = "Minimized! You can re-enable it from the Stats tab."})
    end)

    -- Top Header Panel
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 80)
    header.BackgroundTransparency = 1
    header.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.Text = "ECCO OVERLAY"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = header

    local uptimeLabel = Instance.new("TextLabel")
    uptimeLabel.Size = UDim2.new(0.3, 0, 1, 0)
    uptimeLabel.Position = UDim2.new(0.65, 0, 0, 0)
    uptimeLabel.Text = "Uptime: 00:00:00"
    uptimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    uptimeLabel.Font = Enum.Font.SourceSansBold
    uptimeLabel.TextSize = 16
    uptimeLabel.TextXAlignment = Enum.TextXAlignment.Right
    uptimeLabel.BackgroundTransparency = 1
    uptimeLabel.Parent = header
    cardLabels.Uptime = uptimeLabel

    -- Grid Container for Cards
    local gridFrame = Instance.new("Frame")
    gridFrame.Size = UDim2.new(0.9, 0, 0.78, 0)
    gridFrame.Position = UDim2.new(0.05, 0, 0.16, 0)
    gridFrame.BackgroundTransparency = 1
    gridFrame.Parent = bg

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.31, 0, 0.45, 0) -- 3 columns, 2 rows
    gridLayout.CellPadding = UDim2.new(0.02, 0, 0.03, 0)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = gridFrame

    -- Function to create a gorgeous card
    local function createCard(titleText, layoutOrder)
        local card = Instance.new("Frame")
        card.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        card.BackgroundTransparency = 0.1
        card.BorderSizePixel = 0
        card.LayoutOrder = layoutOrder
        card.Parent = gridFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = card

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(60, 60, 80)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.3
        stroke.Parent = card

        local cardTitle = Instance.new("TextLabel")
        cardTitle.Size = UDim2.new(1, 0, 0, 30)
        cardTitle.Position = UDim2.new(0, 15, 0, 10)
        cardTitle.Text = titleText
        cardTitle.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold title
        cardTitle.Font = Enum.Font.SourceSansBold
        cardTitle.TextSize = 15
        cardTitle.TextXAlignment = Enum.TextXAlignment.Left
        cardTitle.BackgroundTransparency = 1
        cardTitle.Parent = card

        local listContainer = Instance.new("Frame")
        listContainer.Size = UDim2.new(1, -30, 1, -50)
        listContainer.Position = UDim2.new(0, 15, 0, 45)
        listContainer.BackgroundTransparency = 1
        listContainer.Parent = card

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 6)
        listLayout.Parent = listContainer

        return listContainer
    end

    -- Card 1: Economy
    local c1 = createCard("💰 Economy & Earnings", 1)
    local function createStatLabel(parent, labelKey, defaultText)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.Text = defaultText
        lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        lbl.Font = Enum.Font.Roboto
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Parent = parent
        cardLabels[labelKey] = lbl
        return lbl
    end

    createStatLabel(c1, "Cash", "Cash: $0")
    createStatLabel(c1, "SessionEarned", "Session Earned: $0")
    createStatLabel(c1, "EarnRate", "Earn Rate: $0/min")

    -- Card 2: Rebirth
    local c2 = createCard("🔄 Rebirth Status", 2)
    createStatLabel(c2, "Rebirths", "Total Rebirths: 0 (Session: 0)")
    createStatLabel(c2, "PotentialInvestors", "Potential Investors: 0")
    createStatLabel(c2, "Investors", "Current Investors: 0")

    -- Card 3: Evolution
    local c3 = createCard("🧬 Evolution Tiers", 3)
    createStatLabel(c3, "Evolves", "Total Evolves: 0 (Session: 0)")
    createStatLabel(c3, "CurrentFruit", "Current Fruit: Lemon (Tier 0)")
    cardLabels.EvoProgress = createProgressBar(c3, "Evo Progress", Color3.fromRGB(0, 190, 255))

    -- Card 4: Ascension
    local c4 = createCard("Ascensions", 4)
    createStatLabel(c4, "Ascends", "Total Ascends: 0 (Session: 0)")
    cardLabels.AscProgress = createProgressBar(c4, "Ascension Progress", Color3.fromRGB(180, 80, 250))

    -- Card 5: Harvesting
    local c5 = createCard("🚜 Harvest & Stands", 5)
    createStatLabel(c5, "FruitsPicked", "Fruits Harvested: 0 (Session: 0)")
    createStatLabel(c5, "StandsCollected", "Stands Collected: 0")
    createStatLabel(c5, "CashDrops", "Cash Drops Claimed: 0")

    -- Card 6: Activities
    local c6 = createCard("🎮 Activity Stats", 6)
    createStatLabel(c6, "RaceWins", "Lemon Dash Wins: 0")
    createStatLabel(c6, "TradeWins", "Trade Wins: 0")
    createStatLabel(c6, "ItemsBought", "Tycoon Upgrades: 0")
end

local function updateOverlayUI()
    if not overlaySG then return end
    local c = ctx()
    if not c or not c.bal then return end

    pcall(function()
        local Huge = modules.Huge
        local cash = c.bal:GetCash()
        local currentInvestors = c.val.Values:Get("Investors") or 0
        local potential = c.reb and c.reb:GetPotentialInvestors() or 0
        local inv = c.bal:GetInvestors()

        -- Uptime
        local elapsed = os.time() - overlayStartTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = elapsed % 60
        if cardLabels.Uptime then
            cardLabels.Uptime.Text = string.format("Uptime: %02d:%02d:%02d", h, m, s)
        end

        -- Economy card
        if cardLabels.Cash then
            cardLabels.Cash.Text = "Cash: $" .. fmt(cash)
        end
        if cardLabels.SessionEarned then
            cardLabels.SessionEarned.Text = "Session Earned: $" .. (stats.sessionEarned and fmt(stats.sessionEarned) or "0")
        end
        if cardLabels.EarnRate then
            cardLabels.EarnRate.Text = "Earn Rate: " .. (stats.rateStr or "0/min")
        end

        -- Rebirth card
        if cardLabels.Rebirths then
            cardLabels.Rebirths.Text = string.format("Total Rebirths: %d (Session: %d)", stats.totalRebirths, stats.sessionRebirths)
        end
        if cardLabels.PotentialInvestors then
            cardLabels.PotentialInvestors.Text = "Potential Investors: " .. fmt(potential)
        end
        if cardLabels.Investors then
            cardLabels.Investors.Text = "Current Investors: " .. fmt(inv)
        end

        -- Evolution card
        if cardLabels.Evolves then
            cardLabels.Evolves.Text = string.format("Total Evolves: %d (Session: %d)", stats.totalEvolves, stats.sessionEvolves)
        end
        local currentEvo = c.val.Values:Get("Evolution") or 0
        local fruitNames = {"Lemon", "Orange", "Grapefruit", "Lime", "Strawberry", "Blueberry", "Cherry", "Apple", "Banana", "Coconut"}
        local fruitName = fruitNames[currentEvo + 1] or "Unknown Fruit"
        if cardLabels.CurrentFruit then
            cardLabels.CurrentFruit.Text = string.format("Current Fruit: %s (Tier %d)", fruitName, currentEvo)
        end
        local _, evoPct = getEvoProgress(currentInvestors)
        if cardLabels.EvoProgress then
            cardLabels.EvoProgress.SetProgress(evoPct)
        end

        -- Ascension card
        if cardLabels.Ascends then
            cardLabels.Ascends.Text = string.format("Total Ascends: %d (Session: %d)", stats.totalAscends, stats.sessionAscends)
        end
        local ascPct = c.asc and c.asc:GetAscensionProgress() * 100 or 0
        if cardLabels.AscProgress then
            cardLabels.AscProgress.SetProgress(ascPct)
        end

        -- Harvest card
        local totalFruits = LocalPlayer.Values:GetAttribute("FruitsClicked") or 0
        if cardLabels.FruitsPicked then
            cardLabels.FruitsPicked.Text = string.format("Fruits Harvested: %d (Session: %d)", totalFruits, stats.fruitsPicked)
        end
        if cardLabels.StandsCollected then
            cardLabels.StandsCollected.Text = "Stands Collected: " .. tostring(stats.streamsWoken)
        end
        if cardLabels.CashDrops then
            cardLabels.CashDrops.Text = "Cash Drops Claimed: " .. tostring(stats.cashDrops)
        end

        -- Activity card
        if cardLabels.RaceWins then
            cardLabels.RaceWins.Text = "Lemon Dash Wins: " .. tostring(stats.raceWins)
        end
        if cardLabels.TradeWins then
            cardLabels.TradeWins.Text = "Trade Wins: " .. tostring(stats.tradeWins)
        end
        if cardLabels.ItemsBought then
            cardLabels.ItemsBought.Text = "Tycoon Upgrades: " .. tostring(stats.itemsBought)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(1)
        if overlaySG then updateOverlayUI() end
    end
end)

-- ============================================================
-- AUTOMATION FEATURE IMPLEMENTATIONS
-- ============================================================

-- AUTO COLLECT STANDS
local function autoCollectStands(tycoon)
    for _, inst in ipairs(CollectionService:GetTagged("Tycoon.Earner")) do
        if inst:IsDescendantOf(tycoon.Instance) then
            for _, desc in ipairs(inst:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    pcall(function()
                        if fireproximityprompt then
                            fireproximityprompt(desc)
                            stats.streamsWoken = stats.streamsWoken + 1
                        end
                    end)
                end
            end
        end
    end
end

-- AUTO FRUIT PICKER & TREE COLLISION/ANTI-FALL
local function autoPickFruit(tycoon)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local originalCFrame = root.CFrame
    for _, inst in ipairs(CollectionService:GetTagged("ClickFruit")) do
        for _, desc in ipairs(inst:GetDescendants()) do
            if desc:IsA("ClickDetector") then
                pcall(function()
                    local clickPart = desc.Parent
                    if clickPart and clickPart:IsA("BasePart") then
                        if perfConfig.TeleportFruitPicking then
                            root.CFrame = CFrame.new(clickPart.Position + Vector3.new(0, 2, 2))
                            task.wait(perfConfig.TPWaitTime or 0.05)
                        end
                        if fireclickdetector then
                            fireclickdetector(desc, 0)
                            stats.fruitsPicked = stats.fruitsPicked + 1
                        end
                    end
                end)
            end
        end
    end
    if perfConfig.TeleportFruitPicking then
        pcall(function() root.CFrame = originalCFrame end)
    end
end

-- SEWER & UFO AUTO UNLOCK
local function autoSewerUnlock()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local sewer = workspace.Map:FindFirstChild("Sewer")
    if not sewer then return end

    local vineKey, ufoKey, unlockPrompt, alienPrompt, boPrompt
    local pullPrompts = {}
    for _, desc in ipairs(sewer:GetDescendants()) do
        if desc.Name == "VineKey" and desc:IsA("BasePart") then
            vineKey = desc
        elseif desc.Name == "UFOKey" and desc:IsA("BasePart") then
            ufoKey = desc
        elseif desc.Name == "UnlockPrompt" and desc:IsA("ProximityPrompt") then
            unlockPrompt = desc
        elseif desc.Name == "PullPrompt" and desc:IsA("ProximityPrompt") then
            table.insert(pullPrompts, desc)
        elseif desc.Name == "Prompt" and desc:IsA("ProximityPrompt") then
            if desc:GetFullName():find("SewerAlien") then
                alienPrompt = desc
            elseif desc:GetFullName():find("Bo") then
                boPrompt = desc
            end
        end
    end

    if vineKey and firetouchinterest then
        firetouchinterest(vineKey, hrp, 0)
        task.wait(0.05)
        firetouchinterest(vineKey, hrp, 1)
    end
    if unlockPrompt and fireproximityprompt then
        local oldCF = hrp.CFrame
        hrp.CFrame = CFrame.new(unlockPrompt.Parent.Position)
        task.wait(0.1)
        fireproximityprompt(unlockPrompt)
        task.wait(0.1)
        hrp.CFrame = oldCF
    end
    if ufoKey and firetouchinterest then
        firetouchinterest(ufoKey, hrp, 0)
        task.wait(0.05)
        firetouchinterest(ufoKey, hrp, 1)
    end
    if alienPrompt and fireproximityprompt then
        local oldCF = hrp.CFrame
        hrp.CFrame = CFrame.new(alienPrompt.Parent.Position)
        task.wait(0.1)
        fireproximityprompt(alienPrompt)
        task.wait(0.1)
        hrp.CFrame = oldCF
    end
    if boPrompt and fireproximityprompt then
        local oldCF = hrp.CFrame
        hrp.CFrame = CFrame.new(boPrompt.Parent.Position)
        task.wait(0.1)
        fireproximityprompt(boPrompt)
        task.wait(0.1)
        hrp.CFrame = oldCF
    end
    for _, prompt in ipairs(pullPrompts) do
        if fireproximityprompt then
            local oldCF = hrp.CFrame
            hrp.CFrame = CFrame.new(prompt.Parent.Position)
            task.wait(0.1)
            fireproximityprompt(prompt)
            task.wait(0.1)
            hrp.CFrame = oldCF
        end
    end
end

-- AUTO PHONE OFFERS & HAGGLE
local function autoPhoneOffers(tycoon)
    pcall(function()
        local phone = tycoon:GetComponent(modules.ClientPhoneOffers)
        if phone and phone:GetCurrentOffer() then
            if phone._HasHaggled then
                phone:AcceptOffer()
                phone._HasHaggled = nil
            elseif progressionConfig.HaggleOffers then
                phone._HasHaggled = true
                phone:RaiseOffer()
            else
                phone:AcceptOffer()
            end
        end
    end)
end

-- AUTO POWERS UPGRADER
local function autoPowers(tycoon)
    local c = ctx()
    if not c or not c.pow or not c.bal then return end
    local ok, investors = pcall(function() return c.bal:GetInvestors() end)
    if not ok then return end
    
    local remainingInvestors = investors
    for _, name in ipairs(progressionConfig.SelectedPowersOrder) do
        pcall(function()
            local lvl = c.pow:GetLevel(name)
            local maxLvl = c.pow:GetMaxLevel(name)
            if lvl and maxLvl and lvl < maxLvl then
                local price = c.pow:GetUpgradePrice(name)
                if price and price <= remainingInvestors then
                    local success = c.pow:UpgradeAsync(name)
                    if success then
                        remainingInvestors = logSubtract(remainingInvestors, price)
                        stats.powersBought = stats.powersBought + 1
                    end
                end
            end
        end)
    end
end

-- AUTO RACE DASH MINIGAME
local function autoRace()
    if not modules.raceStart or not modules.raceEnd then return end
    if os.clock() < stats.raceNextAt then return end
    stats.raceNextAt = os.clock() + 20
    task.spawn(function()
        local ok, res = pcall(function() return modules.raceStart:InvokeServer() end)
        if ok and res ~= nil then
            task.wait(0.4)
            pcall(function() modules.raceEnd:InvokeServer(1) end)
            stats.raceNextAt = os.clock() + 310
            stats.raceWins = stats.raceWins + 1
        end
    end)
end

-- AUTO LEMON TRADE MINIGAME EXPLOIT
local function autoLemonTrade()
    if not modules.tradeStart or not modules.tradeEnd then return end
    if os.clock() < stats.tradeNextAt then return end
    stats.tradeNextAt = os.clock() + 10
    task.spawn(function()
        local readyTime = 0
        pcall(function()
            local TradeSvc = require(RS.Modules.Service.MinigameTradeService)
            readyTime = TradeSvc:GetTradingAvailableTime()
        end)
        if workspace:GetServerTimeNow() >= readyTime then
            local ok, config = pcall(function() return modules.tradeStart:InvokeServer() end)
            if ok and config and config.MaxEarnings then
                task.wait(0.5)
                pcall(function() modules.tradeEnd:InvokeServer(config.MaxEarnings) end)
                stats.tradeNextAt = os.clock() + 310
                stats.tradeWins = stats.tradeWins + 1
            end
        end
    end)
end

-- AUTO PERMANENT BUY ALL BUTTON FUNCTION
local function autoPermanentBuyAll(tycoon)
    local asc = tycoon:GetComponent(modules.ClientAscension)
    if not asc then return end
    
    local remaining = asc:GetAscensionPermanentPurchasesRemaining()
    if remaining <= 0 then
        Luna:Notification({Title = "Ecco Hub", Content = "No permanent purchase credits remaining!"})
        return
    end

    local ClientPurchases = require(RS.Modules.Tycoon.Component.Client.ClientTycoonPurchases)
    local comp = tycoon:GetComponent(ClientPurchases)
    if not comp then return end

    local count = 0
    for _, inst in ipairs(CollectionService:GetTagged("Tycoon.Purchase")) do
        if inst:IsDescendantOf(tycoon.Instance) then
            local p = modules.ClientPurchase:get(inst)
            if p and not p.Special then
                local isPurchased, isPermanent = comp:IsPurchased(p.Name)
                if isPurchased and not isPermanent then
                    pcall(function()
                        p.PurchaseRemote:InvokeServer(true)
                        count = count + 1
                        remaining = remaining - 1
                    end)
                    if remaining <= 0 then break end
                    task.wait(0.05)
                end
            end
        end
    end
    Luna:Notification({Title = "Ecco Hub", Content = "Permanently upgraded " .. tostring(count) .. " buttons!"})
end

-- AUTO PERMANENT BUY LOOP FUNCTION (Periodic Runner)
local function autoPermanentBuyLoop(tycoon)
    local asc = tycoon:GetComponent(modules.ClientAscension)
    if not asc then return end
    
    local remaining = asc:GetAscensionPermanentPurchasesRemaining()
    if remaining <= 0 then return end

    local ClientPurchases = require(RS.Modules.Tycoon.Component.Client.ClientTycoonPurchases)
    local comp = tycoon:GetComponent(ClientPurchases)
    if not comp then return end

    -- 1. Check priority first
    if progressionConfig.PriorityPermanentBuy and progressionConfig.PriorityPermanentBuy ~= "" and progressionConfig.PriorityPermanentBuy ~= "None" then
        local targetName = progressionConfig.PriorityPermanentBuy:gsub("%s+", ""):lower()
        for _, inst in ipairs(CollectionService:GetTagged("Tycoon.Purchase")) do
            if inst:IsDescendantOf(tycoon.Instance) then
                local p = modules.ClientPurchase:get(inst)
                if p and not p.Special then
                    local pName = p.Name and p.Name:gsub("%s+", ""):lower()
                    local pDisp = p.DisplayName and p.DisplayName:gsub("%s+", ""):lower()
                    if pName == targetName or pDisp == targetName then
                        local isPurchased, isPermanent = comp:IsPurchased(p.Name)
                        if isPurchased and not isPermanent then
                            pcall(function()
                                p.PurchaseRemote:InvokeServer(true)
                                remaining = remaining - 1
                            end)
                            if remaining <= 0 then return end
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end

    -- 2. Check Best Permanent Buy
    if progressionConfig.AutoPermanentBuyBest then
        local bestPurchase = nil
        local bestPrice = -1
        for _, inst in ipairs(CollectionService:GetTagged("Tycoon.Purchase")) do
            if inst:IsDescendantOf(tycoon.Instance) then
                local p = modules.ClientPurchase:get(inst)
                if p and not p.Special then
                    local isPurchased, isPermanent = comp:IsPurchased(p.Name)
                    if isPurchased and not isPermanent then
                        local price = p:GetPrice() or 0
                        if price > bestPrice then
                            bestPrice = price
                            bestPurchase = p
                        end
                    end
                end
            end
        end
        if bestPurchase then
            pcall(function()
                bestPurchase.PurchaseRemote:InvokeServer(true)
                remaining = remaining - 1
            end)
            if remaining <= 0 then return end
            task.wait(0.05)
        end
    end

    -- 3. Check Auto Buy All
    if progressionConfig.AutoPermanentBuy or progressionConfig.AutoPermanentBuyAll then
        for _, inst in ipairs(CollectionService:GetTagged("Tycoon.Purchase")) do
            if inst:IsDescendantOf(tycoon.Instance) then
                local p = modules.ClientPurchase:get(inst)
                if p and not p.Special then
                    local isPurchased, isPermanent = comp:IsPurchased(p.Name)
                    if isPurchased and not isPermanent then
                        pcall(function()
                            p.PurchaseRemote:InvokeServer(true)
                            remaining = remaining - 1
                        end)
                        if remaining <= 0 then return end
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end

-- AUTO BUY TYCOON
local function autoBuyTycoon(tycoon)
    local cash = getCash(tycoon)
    local ClientPurchases = require(RS.Modules.Tycoon.Component.Client.ClientTycoonPurchases)
    local comp = tycoon:GetComponent(ClientPurchases)
    if not comp then return end

    for _, inst in ipairs(CollectionService:GetTagged("Tycoon.Purchase")) do
        if inst:IsDescendantOf(tycoon.Instance) then
            local isDecor = inst.Parent and inst.Parent.Name == "Decor"
            if not (progressionConfig.BuyProgressionOnly and isDecor) then
                local ok, didBuy = pcall(function()
                    local purchase = modules.ClientPurchase:get(inst)
                    if purchase and purchase:IsEnabled() and not purchase:IsPurchased() then
                        local price = purchase:GetPrice()
                        if price and price <= cash then
                            local buyPermanent = false
                            if (progressionConfig.AutoPermanentBuy or progressionConfig.AutoPermanentBuyAll) and not purchase.Special then
                                local asc = tycoon:GetComponent(modules.ClientAscension)
                                if asc and asc:GetAscensionPermanentPurchasesRemaining() > 0 then
                                    buyPermanent = true
                                end
                            end
                            local stripped = purchase.Name:gsub("%s+", "")
                            if progressionConfig.PriorityPermanentBuy and progressionConfig.PriorityPermanentBuy ~= "" and progressionConfig.PriorityPermanentBuy ~= "None" then
                                local targetName = progressionConfig.PriorityPermanentBuy:gsub("%s+", "")
                                if stripped == targetName then
                                    local asc = tycoon:GetComponent(modules.ClientAscension)
                                    if asc and asc:GetAscensionPermanentPurchasesRemaining() > 0 then
                                        buyPermanent = true
                                    end
                                end
                            end
                            purchase.PurchaseRemote:InvokeServer(buyPermanent)
                            stats.itemsBought = stats.itemsBought + 1
                            cash = logSubtract(cash, price)
                            return true
                        end
                    end
                end)
                if ok and didBuy and progressionConfig.BuyDelay > 0 then
                    task.wait(progressionConfig.BuyDelay)
                end
            end
        end
    end
    
    -- Periodically perform permanent purchases if any flags are enabled
    if progressionConfig.AutoPermanentBuy or progressionConfig.AutoPermanentBuyAll or progressionConfig.AutoPermanentBuyBest or (progressionConfig.PriorityPermanentBuy and progressionConfig.PriorityPermanentBuy ~= "" and progressionConfig.PriorityPermanentBuy ~= "None") then
        pcall(autoPermanentBuyLoop, tycoon)
    end
end

-- AUTO UPGRADE EARNERS
local function autoUpgradeEarners(tycoon)
    local cash = getCash(tycoon)
    for _, inst in ipairs(CollectionService:GetTagged("Tycoon.Earner")) do
        if inst:IsDescendantOf(tycoon.Instance) then
            local ok, didBuy = pcall(function()
                local earner = modules.ClientEarner:get(inst)
                if earner then
                    local info = earner:GetNextUpgradeInfo()
                    if info and not info.Max and info.Price and info.Price <= cash then
                        earner:Upgrade(nil, info.Count)
                        stats.itemsUpgraded = stats.itemsUpgraded + 1
                        cash = logSubtract(cash, info.Price)
                        return true
                    end
                end
            end)
            if ok and didBuy and progressionConfig.UpgradeDelay > 0 then
                task.wait(progressionConfig.UpgradeDelay)
            end
        end
    end
end

-- ============================================================
-- STATS LOOP
-- ============================================================
local _statsWindowT = os.clock()
task.spawn(function()
    while true do
        task.wait(1)
        if not modulesReady then continue end
        local c = ctx()
        if not c or not c.bal then continue end
        pcall(function()
            local cash = c.bal:GetCash()

            if stats.lastCash ~= nil and cash > stats.lastCash then
                local delta = logSubtract(cash, stats.lastCash)
                if delta and delta ~= -math.huge then
                    stats.sessionEarned = logAdd(stats.sessionEarned, delta)
                end
            end
            stats.lastCash = cash

            if stats.sessionEarned then
                if os.clock() - _statsWindowT >= 60 then
                    if stats.rateWindow ~= nil then
                        local rateDelta = logSubtract(stats.sessionEarned, stats.rateWindow)
                        if rateDelta and rateDelta ~= -math.huge then
                            stats.rateStr = fmt(rateDelta) .. "/min"
                        end
                    end
                    stats.rateWindow = stats.sessionEarned
                    _statsWindowT = os.clock()
                end
            end

            pcall(function()
                local inv = c.bal:GetInvestors()
                if inv > (modules.Huge and modules.Huge.zero or -math.huge) then
                    stats.investors = fmt(inv)
                else
                    stats.investors = "0"
                end
            end)

            pcall(function()
                stats.totalRebirths = (c.val and c.val.Values and c.val.Values:Get("TotalRebirths")) or (c.reb and c.reb:GetTotalRebirths()) or 0
                stats.totalEvolves = (c.val and c.val.Values and c.val.Values:Get("Evolution")) or (c.evo and c.evo:GetEvolution()) or 0
                stats.totalAscends = (c.val and c.val.Values and c.val.Values:Get("Ascension")) or (c.asc and c.asc:GetAscension()) or 0
                
                -- Ensure session variables are used for actions
                stats.rebirths = stats.sessionRebirths
                stats.evolves = stats.sessionEvolves
                stats.ascends = stats.sessionAscends
            end)
        end)
    end
end)

-- ============================================================
-- RUNNER ENGINE (Loop throttle control)
-- ============================================================
local function startRunner(key, loopFn)
    if runners[key] then return end
    runners[key] = true
    task.spawn(function()
        while runners[key] do
            if not modulesReady then task.wait(0.5) continue end
            local tycoon = getTycoon()
            if not tycoon then task.wait(0.5) continue end
            loopFn(tycoon)
            task.wait(perfConfig.LighterPerformance and (perfConfig.LoopInterval * 2) or perfConfig.LoopInterval)
        end
    end)
end

local function stopRunner(key) runners[key] = nil end
local function setFeature(key, loopFn, enabled)
    if enabled then startRunner(key, loopFn) else stopRunner(key) end
end

local OrchardConfig
pcall(function()
    OrchardConfig = require(RS.Modules.Tycoon.Orchard.OrchardConfig) or require(RS.Modules.Tycoon.Orchard.OrchardMutations)
end)

local function checkMutations(fruit)
    if not fruit then return true end
    local mutations = fruit:GetMutations() or {}
    
    if orchardConfig.AvoidBadMutations then
        for mutName, _ in pairs(mutations) do
            local mutConfig = OrchardConfig and OrchardConfig.Orchard and OrchardConfig.Orchard.Mutations and OrchardConfig.Orchard.Mutations[mutName]
            if mutConfig and mutConfig.Good == false then
                return false
            end
        end
    end
    
    if orchardConfig.RerollTargetMutations and next(orchardConfig.TargetMutations) then
        local hasTarget = false
        for mutName, _ in pairs(mutations) do
            if orchardConfig.TargetMutations[mutName] then
                hasTarget = true
                break
            end
        end
        if not hasTarget then
            return false
        end
    end
    
    return true
end

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            if not modulesReady then return end
            local tycoon = getTycoon()
            if not tycoon then return end
            local c = ctx()
            if not c or not c.bal then return end

            local cash = c.bal:GetCash()
            local ClientOrchard = require(RS.Modules.Tycoon.Orchard.Client.ClientOrchard)
            local orchard = ClientOrchard.getFromTycoon(tycoon)
            if not orchard then return end

            -- 1. Anti-Fall & No Collision
            if orchardConfig.AntiFall or orchardConfig.NoCollision then
                local plots = tycoon.Instance:FindFirstChild("Orchard") and tycoon.Instance.Orchard:FindFirstChild("Plots")
                if plots then
                    for _, plotInst in ipairs(plots:GetChildren()) do
                        for _, child in ipairs(plotInst:GetDescendants()) do
                            if child:IsA("BasePart") then
                                if orchardConfig.AntiFall then child.Anchored = true end
                                if orchardConfig.NoCollision then child.CanCollide = false end
                            end
                        end
                    end
                end
            end

            -- 2. Auto Buy Orchard
            if orchardConfig.AutoBuyOrchard and not orchard:IsUnlocked() then
                local price = orchard:GetUnlockCashPrice()
                if cash >= price then
                    local btn = tycoon.Instance:FindFirstChild("Orchard") and tycoon.Instance.Orchard:FindFirstChild("OrchardPurchase")
                    if btn and btn:FindFirstChild("Button") then
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and firetouchinterest then
                            firetouchinterest(btn.Button, hrp, 0)
                            task.wait(0.1)
                            firetouchinterest(btn.Button, hrp, 1)
                        end
                    end
                end
            end

            if not orchard:IsUnlocked() then return end

            -- 3. Auto Expand Plots
            local ClientOrchardPlots = require(RS.Modules.Tycoon.Orchard.Client.ClientOrchardPlots)
            local plotsComp = orchard:GetComponent(ClientOrchardPlots)
            if orchardConfig.AutoExpandPlots and plotsComp then
                local price = plotsComp:GetNextPlotUnlockPrice()
                if price and cash >= price then
                    plotsComp:UnlockPlotAsync(false)
                end
            end

            -- 4. Auto Plot Upgrades (Irrigation, Clover, Soil Enricher, etc.)
            local ClientOrchardItems = require(RS.Modules.Tycoon.Orchard.Client.ClientOrchardItems)
            local itemsComp = orchard:GetComponent(ClientOrchardItems)
            local ClientOrchardPlot = require(RS.Modules.Tycoon.Orchard.Client.ClientOrchardPlot)
            local plotsFolder = tycoon.Instance:FindFirstChild("Orchard") and tycoon.Instance.Orchard:FindFirstChild("Plots")

            if orchardConfig.AutoBuyPlotUpgrades and itemsComp and plotsFolder then
                local upgradesList = {"Irrigation", "Enricher", "Clover", "Radioactive"}
                for _, plotInst in ipairs(plotsFolder:GetChildren()) do
                    local plot = ClientOrchardPlot:getFromDescendant(plotInst)
                    if plot and plot:IsEnabled() then
                        for _, upgradeName in ipairs(upgradesList) do
                            if not plot.Instance:GetAttribute(upgradeName .. "Unlocked") then
                                local itemsInfo = require(RS.Modules.Tycoon.Orchard.OrchardItems):getItemsInfo()
                                local price = itemsInfo[upgradeName] and itemsInfo[upgradeName].Price
                                if price and cash >= price then
                                    local owned = itemsComp:GetCounts()[upgradeName] or 0
                                    if owned <= 0 then
                                        itemsComp:BuyItemsAsync(upgradeName, 1)
                                        task.wait(0.1)
                                    end
                                    plot:UseItemAsync(upgradeName)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
            end

            -- 5. Auto Plant, Harvest, Reroll Mutations, Replace Lesser Trees
            if plotsFolder then
                local maxEvo = c.val.Values:Get("Evolution") or 0
                for _, plotInst in ipairs(plotsFolder:GetChildren()) do
                    local plot = ClientOrchardPlot:getFromDescendant(plotInst)
                    if plot and plot:IsEnabled() then
                        local state = plot:GetState()
                        
                        -- Teleport option
                        if orchardConfig.TeleportPlots and (state == 0 or state == 3) then
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.CFrame = CFrame.new(plotInst.Position + Vector3.new(0, 3, 0)) end
                        end

                        if state == 0 then -- Empty
                            if orchardConfig.AutoPlantTrees then
                                local seed = modules.OrchardFruit.new(0, {})
                                if orchardConfig.AutoPlantBetterSeed then
                                    seed = modules.OrchardFruit.new(maxEvo, {})
                                end
                                plot:PlantAsync(seed)
                            end
                        elseif state == 1 then -- TreeGrowing (Apply Fertilizer)
                            if orchardConfig.SelectedFertilizer ~= "None" and not plot:GetPendingMutationItem() then
                                local fertName = (orchardConfig.SelectedFertilizer == "Mysterious") and "FertilizerMutate" or "FertilizerAscend"
                                local itemsInfo = require(RS.Modules.Tycoon.Orchard.OrchardItems):getItemsInfo()
                                local price = itemsInfo[fertName] and itemsInfo[fertName].Price
                                if price and cash >= price then
                                    local owned = itemsComp:GetCounts()[fertName] or 0
                                    if owned <= 0 then
                                        itemsComp:BuyItemsAsync(fertName, 1)
                                        task.wait(0.1)
                                    end
                                    plot:UseItemAsync(fertName)
                                end
                            end
                        elseif state == 2 or state == 3 then -- Growing or Ready
                            local fruit = plot:GetFruitAsync()
                            if fruit then
                                -- Check for lesser trees
                                if orchardConfig.AutoReplaceLesserTrees and fruit:GetEvolution() < maxEvo then
                                    plot:DestroyTreeAsync()
                                    continue
                                end

                                -- Check mutations rerolling
                                if state == 3 and (orchardConfig.AvoidBadMutations or orchardConfig.RerollTargetMutations) then
                                    if not checkMutations(fruit) then
                                        plot:DestroyTreeAsync()
                                        continue
                                    end
                                end
                            end

                            -- Harvest if ready
                            if state == 3 and orchardConfig.AutoHarvestTrees then
                                plot:HarvestAsync()
                                stats.fruitsPicked = stats.fruitsPicked + 1
                            end
                        end
                    end
                end
            end

            -- 6. Auto Sell Orchard Fruits
            local ClientOrchardFruits = require(RS.Modules.Tycoon.Orchard.Client.ClientOrchardFruits)
            local fruitsComp = orchard:GetComponent(ClientOrchardFruits)
            if orchardConfig.AutoSellFruits and fruitsComp then
                fruitsComp:SellFruitsAsync()
            end

            -- 7. Auto Eat Best Orchard Fruits (Supports native auto-eat power and fast manual fallback)
            if orchardConfig.AutoEatFruits then
                local ClientAutoEat = require(RS.Modules.Tycoon.Orchard.Client.ClientOrchardAutoEatFruitPower)
                local autoEatComp = orchard:GetComponent(ClientAutoEat)
                
                if autoEatComp then
                    -- Configure and enable native auto-eat power
                    if not autoEatComp:IsEnabled() then
                        pcall(function() autoEatComp:EnableAutoEat(true) end)
                    end
                    local order = autoEatComp:GetAutoEatFruitOrder()
                    if not order or #order == 0 then
                        pcall(function()
                            autoEatComp:SetAutoEatOrderAsync({"Voidlemon", "Grapefruit", "Purity", "Abyssalime", "Lime", "Lemon"})
                        end)
                    end
                else
                    -- Fast manual eating loop fallback (eats all available fruits instantly)
                    local ClientOrchardEatFruit = require(RS.Modules.Tycoon.Orchard.Client.ClientOrchardEatFruit)
                    local eatComp = orchard:GetComponent(ClientOrchardEatFruit)
                    if eatComp and fruitsComp then
                        local FRUIT_TIERS = {"Voidlemon", "Grapefruit", "Purity", "Abyssalime", "Lime", "Lemon"}
                        for _, fName in ipairs(FRUIT_TIERS) do
                            local count = fruitsComp:GetCount(fName)
                            if count and count > 0 then
                                for i = 1, count do
                                    pcall(function() eatComp:EatFruitAsync(fName) end)
                                end
                            end
                        end
                    end
                end
            else
                -- Disable native auto-eat if toggled off
                local ClientAutoEat = require(RS.Modules.Tycoon.Orchard.Client.ClientOrchardAutoEatFruitPower)
                local autoEatComp = orchard:GetComponent(ClientAutoEat)
                if autoEatComp and autoEatComp:IsEnabled() then
                    pcall(function() autoEatComp:EnableAutoEat(false) end)
                end
            end
        end)
    end
end)

-- ============================================================
-- TAB: FARMING
-- ============================================================
local FarmingTab = Window:CreateTab({
    Name = "🌾 Farming",
    Icon = "grass",
    ImageSource = "Material",
    ShowTitle = true,
})

FarmingTab:CreateSection("Auto Harvest & Actions")
FarmingTab:CreateToggle({
    Name = "Auto Fruit Picker",
    CurrentValue = false,
    Callback = function(v) setFeature("fruit", autoPickFruit, v) end,
})
FarmingTab:CreateToggle({
    Name = "Teleport to Fruits",
    CurrentValue = true,
    Callback = function(v) perfConfig.TeleportFruitPicking = v end,
})
FarmingTab:CreateSlider({
    Name = "TP Wait Time",
    Range = {0, 0.2},
    Increment = 0.01,
    CurrentValue = 0.05,
    Callback = function(v) perfConfig.TPWaitTime = v end,
})
FarmingTab:CreateToggle({
    Name = "Auto Collect Stands",
    CurrentValue = false,
    Callback = function(v) setFeature("stands", autoCollectStands, v) end,
})
FarmingTab:CreateToggle({
    Name = "Auto Cash Drops",
    CurrentValue = false,
    Callback = function(v)
        if v then runners["cashDrops"] = true else runners["cashDrops"] = nil end
    end,
})

FarmingTab:CreateSection("Special Yields")
FarmingTab:CreateToggle({
    Name = "Auto Cash Vine",
    CurrentValue = false,
    Callback = function(v)
        setFeature("cashvine", function(tycoon)
            for _, inst in ipairs(CollectionService:GetTagged("CashVine")) do
                pcall(function()
                    local vine = modules.ClientCashVine:get(inst)
                    if vine then
                        if vine:GetAvailableTime() - workspace:GetServerTimeNow() <= 0 then
                            vine:UseAsync()
                        end
                    end
                end)
            end
        end, v)
    end,
})
FarmingTab:CreateToggle({
    Name = "Auto Sewer & 2x Investor Unlock",
    CurrentValue = false,
    Callback = function(v)
        setFeature("sewerUnlock", function() autoSewerUnlock() end, v)
    end,
})

FarmingTab:CreateSection("Minigames")
FarmingTab:CreateToggle({
    Name = "Auto Lemon Dash (Race)",
    CurrentValue = false,
    Callback = function(v) setFeature("race", function() autoRace() end, v) end,
})
FarmingTab:CreateToggle({
    Name = "Auto Lemon Trade",
    CurrentValue = false,
    Callback = function(v) setFeature("trade", function() autoLemonTrade() end, v) end,
})

-- ============================================================
-- TAB: TYCOON
-- ============================================================
local TycoonTab = Window:CreateTab({
    Name = "🏗️ Tycoon",
    Icon = "home_work",
    ImageSource = "Material",
    ShowTitle = true,
})

TycoonTab:CreateSection("Tycoon Upgrades")
TycoonTab:CreateToggle({
    Name = "Auto Buy Buttons",
    CurrentValue = false,
    Callback = function(v) setFeature("buy", autoBuyTycoon, v) end,
})
TycoonTab:CreateToggle({
    Name = "Buy Progression Needed Only",
    CurrentValue = false,
    Callback = function(v) progressionConfig.BuyProgressionOnly = v end,
})
TycoonTab:CreateToggle({
    Name = "Auto Upgrade Earners",
    CurrentValue = false,
    Callback = function(v) setFeature("upgrade", autoUpgradeEarners, v) end,
})
TycoonTab:CreateSlider({
    Name = "Upgrade Delay",
    Range = {0, 1.0},
    Increment = 0.05,
    CurrentValue = 0.1,
    Callback = function(v) progressionConfig.UpgradeDelay = v end,
})
TycoonTab:CreateSlider({
    Name = "Buy Delay",
    Range = {0, 1.0},
    Increment = 0.05,
    CurrentValue = 0.1,
    Callback = function(v) progressionConfig.BuyDelay = v end,
})

TycoonTab:CreateSection("Permanent Purchases")
TycoonTab:CreateToggle({
    Name = "Auto Permanent Buy Best",
    CurrentValue = false,
    Callback = function(v) progressionConfig.AutoPermanentBuyBest = v end,
})
TycoonTab:CreateToggle({
    Name = "Auto Permanent Buy All",
    CurrentValue = false,
    Callback = function(v) progressionConfig.AutoPermanentBuyAll = v end,
})
TycoonTab:CreateDropdown({
    Name = "Prioritize Permanent Buy",
    Options = {
        "None",
        "AI Researchers", "Agriculture Expansion", "Alien Negotiators", "Automated Boxing", "Automated Loading", 
        "Automatic Voting", "BOGO Deals", "Bank Expansion", "Bigger Fleet", "Billboard", "Cash Register", 
        "Celebrity Pumpers", "Central Bank", "Centralized Power", "Citrus Based Fuel", "Citrus Fuel Lines", 
        "Citrus Lubricant", "Citrus Thrusters", "Climate Control", "Company Vehicle", "Corporate Lobbying", 
        "Crypto Miners", "Cup Stand", "Cyber Lemons", "Delivery Insurance", "Interdimensional Markets", 
        "Lemon Singularity", "Lemon Tourism", "Quantum Lemon Tech", "Sentient Lemons", "Wormhole Development"
    },
    CurrentOption = "None",
    MultipleOptions = false,
    Callback = function(v) progressionConfig.PriorityPermanentBuy = v end,
})
TycoonTab:CreateButton({
    Name = "⚡ Permanent Buy All Owned",
    Callback = function()
        local tycoon = getTycoon()
        if tycoon then autoPermanentBuyAll(tycoon) end
    end,
})

-- ============================================================
-- TAB: PROGRESSION
-- ============================================================
local ProgressionTab = Window:CreateTab({
    Name = "📈 Progression",
    Icon = "trending_up",
    ImageSource = "Material",
    ShowTitle = true,
})

ProgressionTab:CreateSection("Rebirth Limits")
ProgressionTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Callback = function(v)
        setFeature("rebirth", function(tycoon)
            local c = ctx()
            if not c or not c.bal or not c.reb then return end
            
            -- Rebirth constraints check
            if progressionConfig.StopRebirthAtInvestors then
                local currentInvestors = c.val.Values:Get("Investors") or 0
                local target = parseToHuge(progressionConfig.TargetInvestors)
                if currentInvestors >= target then
                    return
                end
            end
            
            if progressionConfig.StopRebirthAtEvolution then
                local currentInvestors = c.val.Values:Get("Investors") or 0
                local _, evoPct = getEvoProgress(currentInvestors)
                if evoPct >= progressionConfig.TargetEvolutionProgress then
                    return
                end
            end

            if progressionConfig.MinCashBeforeRebirth ~= "0" then
                local cash = getCash(tycoon)
                local targetCash = parseToHuge(progressionConfig.MinCashBeforeRebirth)
                if cash < targetCash then
                    return
                end
            end

            if stats.rebirths >= progressionConfig.MaxRebirths then
                return
            end

            pcall(function()
                local potential = c.reb:GetPotentialInvestors()
                local potNum = tonumber(tostring(potential))
                if potNum and potNum >= (progressionConfig.MinInvestorsToRebirth * progressionConfig.RebirthMultiplier) then
                    task.wait(progressionConfig.RebirthDelay)
                    local result = c.reb:RebirthAsync(false)
                    if result then
                        stats.sessionRebirths = stats.sessionRebirths + 1
                        stats.totalRebirths = stats.totalRebirths + 1
                        stats.rebirths = stats.sessionRebirths
                        if webhookEvents.Rebirth then
                            sendWebhook("Rebirth #" .. stats.sessionRebirths, "Successfully rebirthed!", 3066993, {
                                { name = "⚡ Investors Gained", value = tostring(potential),     inline = true },
                                { name = "🔢 Session Rebirths",  value = tostring(stats.sessionRebirths), inline = true },
                            })
                        end
                    end
                end
            end)
        end, v)
    end,
})
ProgressionTab:CreateSlider({
    Name = "Min Investors to Rebirth",
    Range = {1, 500},
    Increment = 1,
    CurrentValue = 1,
    Callback = function(v) progressionConfig.MinInvestorsToRebirth = v end,
})
ProgressionTab:CreateToggle({
    Name = "Stop Rebirth at Investors",
    CurrentValue = false,
    Callback = function(v) progressionConfig.StopRebirthAtInvestors = v end,
})
ProgressionTab:CreateInput({
    Name = "Target Investors",
    PlaceholderText = "e.g. 1e15 or 1000",
    CurrentValue = "10",
    Enter = true,
    Callback = function(v) progressionConfig.TargetInvestors = v end,
})
ProgressionTab:CreateToggle({
    Name = "Stop Rebirth at Evolution %",
    CurrentValue = false,
    Callback = function(v) progressionConfig.StopRebirthAtEvolution = v end,
})
ProgressionTab:CreateSlider({
    Name = "Target Evolution %",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 90,
    Callback = function(v) progressionConfig.TargetEvolutionProgress = v end,
})
ProgressionTab:CreateInput({
    Name = "Min Cash Before Rebirth",
    PlaceholderText = "e.g. 1e50",
    CurrentValue = "0",
    Enter = true,
    Callback = function(v) progressionConfig.MinCashBeforeRebirth = v end,
})
ProgressionTab:CreateSlider({
    Name = "Max Rebirths Limit",
    Range = {1, 10000},
    Increment = 10,
    CurrentValue = 9999,
    Callback = function(v) progressionConfig.MaxRebirths = v end,
})
ProgressionTab:CreateSlider({
    Name = "Rebirth Pause Delay",
    Range = {0, 5},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(v) progressionConfig.RebirthDelay = v end,
})

ProgressionTab:CreateSection("Evolution & Ascension")
ProgressionTab:CreateToggle({
    Name = "Auto Evolve",
    CurrentValue = false,
    Callback = function(v)
        setFeature("evolve", function(tycoon)
            local c = ctx()
            if not c or not c.evo then return end
            local currentEvo = c.val.Values:Get("Evolution") or 0
            if currentEvo >= progressionConfig.MaxEvolutionLevel then return end

            pcall(function()
                local result = c.evo:EvolveAsync(false)
                if result then
                    stats.sessionEvolves = stats.sessionEvolves + 1
                    stats.totalEvolves = stats.totalEvolves + 1
                    stats.evolves = stats.sessionEvolves
                    if webhookEvents.Evolve then
                        sendWebhook("Evolved! #" .. stats.sessionEvolves, "Successfully evolved to the next tier.", 3447003, {
                            { name = "🔢 Session Evolves",  value = tostring(stats.sessionEvolves),  inline = true },
                            { name = "🔄 Session Rebirths Done",  value = tostring(stats.sessionRebirths), inline = true },
                        })
                    end
                end
            end)
        end, v)
    end,
})
ProgressionTab:CreateSlider({
    Name = "Max Evolution Level Limit",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(v) progressionConfig.MaxEvolutionLevel = v end,
})
ProgressionTab:CreateToggle({
    Name = "Auto Ascend",
    CurrentValue = false,
    Callback = function(v)
        setFeature("ascend", function(tycoon)
            local c = ctx()
            if not c or not c.asc then return end
            pcall(function()
                local result = c.asc:AscendAsync()
                if result then
                    stats.sessionAscends = stats.sessionAscends + 1
                    stats.totalAscends = stats.totalAscends + 1
                    stats.ascends = stats.sessionAscends
                    if webhookEvents.Ascend then
                        sendWebhook("Ascended! #" .. stats.sessionAscends, "Successfully ascended!", 15844367, {
                            { name = "✨ Session Ascends",  value = tostring(stats.sessionAscends),  inline = true },
                            { name = "⬆️ Session Evolves",  value = tostring(stats.sessionEvolves),  inline = true },
                            { name = "🔄 Session Rebirths", value = tostring(stats.sessionRebirths), inline = true },
                        })
                    end
                end
            end)
        end, v)
    end,
})

ProgressionTab:CreateSection("Auto Upgrade Powers")
ProgressionTab:CreateToggle({
    Name = "Auto Powers Upgrader",
    CurrentValue = false,
    Callback = function(v) setFeature("powers", autoPowers, v) end,
})
ProgressionTab:CreateDropdown({
    Name = "Prioritized Powers",
    Options = {"UpgradeStack", "BuyNext", "Manage", "WalkSpeed", "ClickFruitValue", "AutoFruit"},
    CurrentOption = {"UpgradeStack", "BuyNext", "Manage", "WalkSpeed", "ClickFruitValue", "AutoFruit"},
    MultipleOptions = true,
    Callback = function(list)
        table.clear(progressionConfig.SelectedPowersOrder)
        local selectedList = {}
        if type(list) == "table" then
            selectedList = list
        elseif type(list) == "string" then
            selectedList = {list}
        end
        for _, power in ipairs(selectedList) do
            table.insert(progressionConfig.SelectedPowersOrder, power)
        end
    end,
})

ProgressionTab:CreateSection("Phone Offers")
ProgressionTab:CreateToggle({
    Name = "Auto Phone Offers",
    CurrentValue = false,
    Callback = function(v) setFeature("phone", autoPhoneOffers, v) end,
})
ProgressionTab:CreateToggle({
    Name = "Auto Haggle (Optional)",
    CurrentValue = false,
    Callback = function(v) progressionConfig.HaggleOffers = v end,
})

-- ============================================================
-- TAB: ORCHARD
-- ============================================================
local OrchardTab = Window:CreateTab({
    Name = "🏡 Orchard",
    Icon = "park",
    ImageSource = "Material",
    ShowTitle = true,
})

OrchardTab:CreateSection("Orchard Expansion")
OrchardTab:CreateToggle({
    Name = "Auto Buy Orchard Area",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AutoBuyOrchard = v end,
})
OrchardTab:CreateToggle({
    Name = "Auto Expand Plot Fields",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AutoExpandPlots = v end,
})
OrchardTab:CreateToggle({
    Name = "Auto Buy Plot Upgrades",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AutoBuyPlotUpgrades = v end,
})

OrchardTab:CreateSection("Farming & Planting")
OrchardTab:CreateToggle({
    Name = "Auto Plant Trees",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AutoPlantTrees = v end,
})
OrchardTab:CreateToggle({
    Name = "Auto Plant Best Seed",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AutoPlantBetterSeed = v end,
})
OrchardTab:CreateToggle({
    Name = "Auto Replace Lesser Trees",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AutoReplaceLesserTrees = v end,
})
OrchardTab:CreateToggle({
    Name = "Auto Harvest All",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AutoHarvestTrees = v end,
})
OrchardTab:CreateToggle({
    Name = "Auto Sell Orchard Fruits",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AutoSellFruits = v end,
})
OrchardTab:CreateToggle({
    Name = "Auto Eat Best Fruit",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AutoEatFruits = v end,
})

OrchardTab:CreateSection("Mutations & Fertilizers")
OrchardTab:CreateToggle({
    Name = "Avoid Bad Mutations",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AvoidBadMutations = v end,
})
OrchardTab:CreateToggle({
    Name = "Reroll Target Mutations",
    CurrentValue = false,
    Callback = function(v) orchardConfig.RerollTargetMutations = v end,
})
OrchardTab:CreateDropdown({
    Name = "Target Mutations",
    Options = {"Perfect", "Blessed", "Zesty", "Exotic", "Tasty", "Juicy", "Lucky", "Fast", "Giant", "Slimy", "Voided"},
    CurrentOption = {"Perfect"},
    MultipleOptions = true,
    Callback = function(list)
        table.clear(orchardConfig.TargetMutations)
        local nameMap = {
            Perfect = "Value4", Blessed = "Rate4", Zesty = "Rate2", Exotic = "Value3",
            Tasty = "Value1", Juicy = "Value2", Lucky = "Luck1", Fast = "GrowthRate1",
            Giant = "Giant", Slimy = "Slimy", Voided = "Void"
        }
        local selectedList = {}
        if type(list) == "table" then
            selectedList = list
        elseif type(list) == "string" then
            selectedList = {list}
        end
        for _, disp in ipairs(selectedList) do
            local key = nameMap[disp]
            if key then orchardConfig.TargetMutations[key] = true end
        end
    end,
})
OrchardTab:CreateDropdown({
    Name = "Fertilizer Selector",
    Options = {"None", "Mysterious", "Ascendant"},
    CurrentOption = "None",
    MultipleOptions = false,
    Callback = function(v) orchardConfig.SelectedFertilizer = v end,
})

OrchardTab:CreateSection("Orchard Physics")
OrchardTab:CreateToggle({
    Name = "Lemon Tree Anti Fall",
    CurrentValue = false,
    Callback = function(v) orchardConfig.AntiFall = v end,
})
OrchardTab:CreateToggle({
    Name = "No Tree Collision",
    CurrentValue = false,
    Callback = function(v) orchardConfig.NoCollision = v end,
})
OrchardTab:CreateToggle({
    Name = "Teleport to Plots",
    CurrentValue = false,
    Callback = function(v) orchardConfig.TeleportPlots = v end,
})

-- ============================================================
-- TAB: STATS & OVERLAYS
-- ============================================================
local StatsTab = Window:CreateTab({
    Name = "📊 Stats",
    Icon = "analytics",
    ImageSource = "Material",
    ShowTitle = true,
})

StatsTab:CreateToggle({
    Name = "Ecco Overlay",
    CurrentValue = false,
    Callback = function(v) toggleOverlay(v) end,
})

StatsTab:CreateSection("Economy")
local cashLabel      = StatsTab:CreateParagraph({Title = "Cash",           Text = "—"})
local investorsLabel = StatsTab:CreateParagraph({Title = "Investors",      Text = "—"})

StatsTab:CreateDivider()
StatsTab:CreateSection("Progression")
local rebirthsLabel = StatsTab:CreateParagraph({Title = "Rebirths", Text = "0"})
local evolvesLabel  = StatsTab:CreateParagraph({Title = "Evolves",  Text = "0"})
local ascendsLabel  = StatsTab:CreateParagraph({Title = "Ascends",  Text = "0"})

StatsTab:CreateDivider()
StatsTab:CreateSection("Script Actions")
local streamsLabel  = StatsTab:CreateParagraph({Title = "Stands Collected", Text = "0"})
local fruitsLabel   = StatsTab:CreateParagraph({Title = "Fruits Picked",    Text = "0"})
local boughtLabel   = StatsTab:CreateParagraph({Title = "Items Bought",     Text = "0"})

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if modulesReady then
                local c = ctx()
                if c then
                    if c.bal then
                        local cash = c.bal:GetCash()
                        cashLabel:Set({Title = "Cash", Text = "$" .. fmt(cash)})
                        local inv = c.bal:GetInvestors()
                        if inv > (modules.Huge and modules.Huge.zero or -math.huge) then
                            investorsLabel:Set({Title = "Investors", Text = fmt(inv)})
                        else
                            investorsLabel:Set({Title = "Investors", Text = "0"})
                        end
                    end
                end
            end
            rebirthsLabel:Set({Title = "Rebirths", Text = string.format("Total: %d | Session: %d", stats.totalRebirths, stats.sessionRebirths)})
            evolvesLabel:Set({Title  = "Evolves",  Text = string.format("Total: %d | Session: %d", stats.totalEvolves, stats.sessionEvolves)})
            ascendsLabel:Set({Title  = "Ascends",  Text = string.format("Total: %d | Session: %d", stats.totalAscends, stats.sessionAscends)})
            streamsLabel:Set({Title  = "Stands Collected", Text = tostring(stats.streamsWoken)})
            
            local totalFruits = 0
            pcall(function() totalFruits = LocalPlayer.Values:GetAttribute("FruitsClicked") or 0 end)
            fruitsLabel:Set({Title   = "Fruits Picked",    Text = string.format("Total: %d | Session: %d", totalFruits, stats.fruitsPicked)})
            boughtLabel:Set({Title   = "Items Bought",     Text = tostring(stats.itemsBought)})
        end)
    end
end)

-- ============================================================
-- TAB: WEBHOOK
-- ============================================================
local WebhookTab = Window:CreateTab({
    Name = "🔔 Webhook",
    Icon = "send",
    ImageSource = "Material",
    ShowTitle = true,
})

WebhookTab:CreateSection("Discord Webhook")
WebhookTab:CreateParagraph({
    Title = "Setup",
    Text = "Paste your Discord webhook URL below. Notifications fire automatically on Rebirth, Evolve, and Ascend with rich stat embeds including session earnings, earn rate, and action counts.",
})
webhookInputRef = WebhookTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    CurrentValue = "",
    Enter = true,
    Callback = function(value) webhookURL = value end,
}, "SLWebhookURL")
WebhookTab:CreateButton({
    Name = "💾 Save Webhook URL",
    Callback = function()
        webhookURL = webhookInputRef and webhookInputRef.CurrentValue or webhookURL
        if webhookURL == "" then
            Luna:Notification({Title = "Webhook", Content = "Field is empty."})
        else
            Luna:Notification({Title = "Webhook", Content = "Saved!"})
        end
    end,
})
WebhookTab:CreateDivider()
WebhookTab:CreateSection("Notify On")
WebhookTab:CreateToggle({
    Name = "Notify on Rebirth",
    CurrentValue = true,
    Callback = function(v) webhookEvents.Rebirth = v end,
})
WebhookTab:CreateToggle({
    Name = "Notify on Evolve",
    CurrentValue = true,
    Callback = function(v) webhookEvents.Evolve = v end,
})
WebhookTab:CreateToggle({
    Name = "Notify on Ascend",
    CurrentValue = true,
    Callback = function(v) webhookEvents.Ascend = v end,
})
WebhookTab:CreateDivider()
WebhookTab:CreateButton({
    Name = "🔔 Test Webhook",
    Callback = function()
        local url = getCurrentWebhookURL()
        if url == "" then
            Luna:Notification({Title = "Webhook", Content = "No webhook URL set — paste one above first."})
            return
        end
        sendWebhook("Test Notification", "✅ Your webhook is working correctly!", 5763719, {
            { name = "Status", value = "Connected", inline = true },
        })
        Luna:Notification({Title = "Webhook", Content = "Test sent!"})
    end,
})

-- ============================================================
-- TAB: PERFORMANCE
-- ============================================================
local PerformanceTab = Window:CreateTab({
    Name = "⚙️ Performance",
    Icon = "speed",
    ImageSource = "Material",
    ShowTitle = true,
})

PerformanceTab:CreateSection("Client Performance")
local Stats = game:GetService("Stats")
local perfLabel = PerformanceTab:CreateParagraph({Title = "FPS / Ping / Memory", Text = "Loading..."})

task.spawn(function()
    local frameCount, lastUpdate = 0, os.clock()
    RunService.RenderStepped:Connect(function() frameCount = frameCount + 1 end)
    while true do
        task.wait(1)
        local now = os.clock()
        local fps = math.floor(frameCount / (now - lastUpdate))
        frameCount = 0; lastUpdate = now
        local ping, mem = 0, 0
        pcall(function() ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        pcall(function() mem = Stats:GetTotalMemoryUsageMb() end)
        perfLabel:Set({Title = "FPS / Ping / Memory", Text = string.format("FPS: %d | Ping: %dms | Memory: %dMB", fps, ping, mem)})
    end
end)

PerformanceTab:CreateDivider()
PerformanceTab:CreateSection("Graphics & Settings")

local textureConns = {}
PerformanceTab:CreateToggle({
    Name = "No Textures",
    CurrentValue = false,
    Callback = function(v)
        if v then
            for _, inst in ipairs(workspace:GetDescendants()) do
                if inst:IsA("Texture") or inst:IsA("Decal") then inst.Transparency = 1 end
            end
            table.insert(textureConns, workspace.DescendantAdded:Connect(function(inst)
                if inst:IsA("Texture") or inst:IsA("Decal") then inst.Transparency = 1 end
            end))
        else
            for _, c in ipairs(textureConns) do c:Disconnect() end
            textureConns = {}
            for _, inst in ipairs(workspace:GetDescendants()) do
                if inst:IsA("Texture") or inst:IsA("Decal") then inst.Transparency = 0 end
            end
        end
    end,
})
PerformanceTab:CreateToggle({
    Name = "No Particles",
    CurrentValue = false,
    Callback = function(v)
        for _, inst in ipairs(workspace:GetDescendants()) do
            if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") then
                inst.Enabled = not v
            end
        end
    end,
})
PerformanceTab:CreateToggle({
    Name = "Low Quality Lighting",
    CurrentValue = false,
    Callback = function(v)
        local Lighting = game:GetService("Lighting")
        for _, inst in ipairs(Lighting:GetChildren()) do
            if inst:IsA("BloomEffect") or inst:IsA("SunRaysEffect") or inst:IsA("DepthOfFieldEffect") or inst:IsA("ColorCorrectionEffect") then
                inst.Enabled = not v
            end
        end
        local ok = pcall(function()
            settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        end)
        if not ok then
            Luna:Notification({Title = "Performance", Content = "QualityLevel blocked — lighting effects still toggled."})
        end
    end,
})
PerformanceTab:CreateButton({
    Name = "⚡ Uncap FPS",
    Callback = function()
        if setfpscap then setfpscap(0) Luna:Notification({Title = "Performance", Content = "FPS cap removed."})
        else Luna:Notification({Title = "Performance", Content = "setfpscap not supported."}) end
    end,
})
PerformanceTab:CreateButton({
    Name = "🐢 Limit 30 FPS",
    Callback = function()
        if setfpscap then setfpscap(30) Luna:Notification({Title = "Performance", Content = "FPS capped at 30."})
        else Luna:Notification({Title = "Performance", Content = "setfpscap not supported."}) end
    end,
})
PerformanceTab:CreateToggle({
    Name = "Disable 3D Rendering",
    CurrentValue = false,
    Callback = function(v)
        local ok = pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(not v) end)
        if not ok then Luna:Notification({Title = "Performance", Content = "Set3dRenderingEnabled blocked by executor."}) end
    end,
})
PerformanceTab:CreateToggle({
    Name = "Reduced Render Distance",
    CurrentValue = false,
    Callback = function(v)
        if v then
            workspace.StreamingEnabled = true
            workspace.StreamingTargetRadius = 128
            workspace.StreamingMinRadius = 64
        else
            workspace.StreamingTargetRadius = 1024
            workspace.StreamingMinRadius = 512
        end
    end,
})
PerformanceTab:CreateToggle({
    Name = "Disable Cutscenes & Reveal Popups",
    CurrentValue = true,
    Callback = function(v) skipCinematics = v end,
})
PerformanceTab:CreateToggle({
    Name = "Lighter CPU Performance Loop",
    CurrentValue = false,
    Callback = function(v) perfConfig.LighterPerformance = v end,
})
PerformanceTab:CreateSlider({
    Name = "Loop Interval Speed",
    Range = {0.05, 2.0},
    Increment = 0.05,
    CurrentValue = 0.4,
    Callback = function(v) perfConfig.LoopInterval = v end,
})

-- ============================================================
-- TAB: SETTINGS
-- ============================================================
local SettingsTab = Window:CreateTab({
    Name = "🔧 Settings",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true,
})

SettingsTab:BuildConfigSection()

Luna:Notification({Title = "Sell Lemons", Content = "Ecco Hub loaded! Flip any toggle to start."})
print("ecco hub - sell lemons - loaded")
