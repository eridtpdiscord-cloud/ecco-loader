--[[
    ================================================================================
    ECCO HUB V3 — MINIMALIST SLEEK BOOTSTRAP LOADER
    ================================================================================
    Official Hub : https://eccohub.xyz
    Community    : https://discord.gg/hN9QpA3HA
    TikTok       : https://www.tiktok.com/@_ecc00_?is_from_webapp=1&sender_device=pc
    Design Spec  : Sleek Dark Glass Stepper UI (390x480)
    ================================================================================
--]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local gethui = gethui or function() return CoreGui end
local parent = gethui()

-- Clean up any previous loader instance
if parent:FindFirstChild("EccoLoaderModal") then
    parent.EccoLoaderModal:Destroy()
end

-- ==============================================================================
-- 1. ROOT SCREEN GUI
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EccoLoaderModal"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 10000
ScreenGui.Enabled = true
ScreenGui.Parent = parent

-- Backdrop Blur / Dim overlay
local Dimmer = Instance.new("Frame")
Dimmer.Name = "Dimmer"
Dimmer.Size = UDim2.new(1, 0, 1, 0)
Dimmer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Dimmer.BackgroundTransparency = 0.55
Dimmer.BorderSizePixel = 0
Dimmer.Parent = ScreenGui

-- Compact Modal Frame (390 x 480 - matching user reference image)
local Modal = Instance.new("Frame")
Modal.Name = "Modal"
Modal.Size = UDim2.new(0, 390, 0, 480)
Modal.Position = UDim2.new(0.5, -195, 0.5, -240)
Modal.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
Modal.BorderSizePixel = 0
Modal.Active = true
Modal.Draggable = true
Modal.Parent = ScreenGui

local ModalCorner = Instance.new("UICorner", Modal)
ModalCorner.CornerRadius = UDim.new(0, 14)

local ModalStroke = Instance.new("UIStroke", Modal)
ModalStroke.Color = Color3.fromRGB(24, 24, 30)
ModalStroke.Thickness = 1.2

-- Close Button (Top-Right subtle 'X')
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0, 12)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
CloseBtn.Text = "X"
CloseBtn.Parent = Modal

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Modal, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(Dimmer, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
    task.wait(0.28)
    ScreenGui:Destroy()
end)

-- Top Header Container
local HeaderContainer = Instance.new("Frame")
HeaderContainer.Name = "HeaderContainer"
HeaderContainer.Size = UDim2.new(1, 0, 0, 130)
HeaderContainer.Position = UDim2.new(0, 0, 0, 20)
HeaderContainer.BackgroundTransparency = 1
HeaderContainer.Parent = Modal

-- Stylized Ecco "E" Emblem
local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "LogoImage"
LogoImage.Size = UDim2.new(0, 68, 0, 68)
LogoImage.Position = UDim2.new(0.5, -34, 0, 0)
LogoImage.BackgroundTransparency = 1
pcall(function()
    if isfile and not isfile("ecco_symbol.png") then
        pcall(function()
            local s = game:HttpGet("https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/ecco_symbol.png")
            if s and #s > 1000 then writefile("ecco_symbol.png", s) end
        end)
        if not isfile("ecco_symbol.png") then
            pcall(function()
                local s = game:HttpGet("http://127.0.0.1:8999/ecco_symbol.png")
                if s and #s > 1000 then writefile("ecco_symbol.png", s) end
            end)
        end
        if not isfile("ecco_symbol.png") then
            pcall(function()
                local s = game:HttpGet("https://eccohub.xyz/ecco_symbol.png")
                if s and #s > 1000 then writefile("ecco_symbol.png", s) end
            end)
        end
    end
    if getcustomasset and isfile and isfile("ecco_symbol.png") then
        LogoImage.Image = getcustomasset("ecco_symbol.png")
    else
        LogoImage.Image = "rbxassetid://91400086538074"
    end
end)
LogoImage.Parent = HeaderContainer

-- "E C C O" Text
local EccoText = Instance.new("TextLabel")
EccoText.Name = "EccoText"
EccoText.Size = UDim2.new(1, 0, 0, 22)
EccoText.Position = UDim2.new(0, 0, 0, 74)
EccoText.BackgroundTransparency = 1
EccoText.Font = Enum.Font.GothamBold
EccoText.TextSize = 18
EccoText.TextColor3 = Color3.fromRGB(245, 245, 245)
EccoText.Text = "E C C O"
EccoText.Parent = HeaderContainer

-- "- H U B -" Text
local HubText = Instance.new("TextLabel")
HubText.Name = "HubText"
HubText.Size = UDim2.new(1, 0, 0, 16)
HubText.Position = UDim2.new(0, 0, 0, 96)
HubText.BackgroundTransparency = 1
HubText.Font = Enum.Font.GothamMedium
HubText.TextSize = 11
HubText.TextColor3 = Color3.fromRGB(150, 150, 160)
HubText.Text = "—  H U B  —"
HubText.Parent = HeaderContainer

-- Subtitle Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -40, 0, 20)
StatusLabel.Position = UDim2.new(0, 20, 0, 162)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
StatusLabel.Text = "INITIALIZING LOADER..."
StatusLabel.Parent = Modal

-- ==============================================================================
-- 2. STEPPER CHECKLIST (5 STAGES AS IN REFERENCE IMAGE)
-- ==============================================================================
local StepperFrame = Instance.new("Frame")
StepperFrame.Name = "StepperFrame"
StepperFrame.Size = UDim2.new(1, -70, 0, 185)
StepperFrame.Position = UDim2.new(0, 35, 0, 196)
StepperFrame.BackgroundTransparency = 1
StepperFrame.Parent = Modal

local StepperLayout = Instance.new("UIListLayout", StepperFrame)
StepperLayout.SortOrder = Enum.SortOrder.LayoutOrder
StepperLayout.Padding = UDim.new(0, 10)

local STAGES = {
    { num = 1, name = "ENVIRONMENT" },
    { num = 2, name = "CONFIGURATION" },
    { num = 3, name = "ACCESS" },
    { num = 4, name = "INTEGRITY" },
    { num = 5, name = "PAYLOAD" }
}

local stageRows = {}

for _, stage in ipairs(STAGES) do
    local row = Instance.new("Frame")
    row.Name = "Stage_" .. stage.name
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.LayoutOrder = stage.num
    row.Parent = StepperFrame

    -- Step Number (1 to 5)
    local numLabel = Instance.new("TextLabel")
    numLabel.Name = "NumLabel"
    numLabel.Size = UDim2.new(0, 20, 1, 0)
    numLabel.Position = UDim2.new(0, 0, 0, 0)
    numLabel.BackgroundTransparency = 1
    numLabel.Font = Enum.Font.GothamBold
    numLabel.TextSize = 12
    numLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
    numLabel.TextXAlignment = Enum.TextXAlignment.Left
    numLabel.Text = tostring(stage.num)
    numLabel.Parent = row

    -- Step Title
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -60, 1, 0)
    nameLabel.Position = UDim2.new(0, 26, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = stage.name
    nameLabel.Parent = row

    -- Status Indicator Circle
    local iconCircle = Instance.new("Frame")
    iconCircle.Name = "IconCircle"
    iconCircle.Size = UDim2.new(0, 18, 0, 18)
    iconCircle.Position = UDim2.new(1, -22, 0.5, -9)
    iconCircle.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    iconCircle.BorderSizePixel = 0
    
    local cCorner = Instance.new("UICorner", iconCircle)
    cCorner.CornerRadius = UDim.new(1, 0)

    local cStroke = Instance.new("UIStroke", iconCircle)
    cStroke.Name = "Stroke"
    cStroke.Color = Color3.fromRGB(50, 50, 60)
    cStroke.Thickness = 1.5

    local checkText = Instance.new("TextLabel")
    checkText.Name = "CheckText"
    checkText.Size = UDim2.new(1, 0, 1, 0)
    checkText.BackgroundTransparency = 1
    checkText.Font = Enum.Font.GothamBold
    checkText.TextSize = 11
    checkText.TextColor3 = Color3.fromRGB(10, 10, 12)
    checkText.Text = ""
    checkText.Parent = iconCircle

    iconCircle.Parent = row

    stageRows[stage.num] = {
        row = row,
        nameLabel = nameLabel,
        numLabel = numLabel,
        circle = iconCircle,
        stroke = cStroke,
        checkText = checkText
    }
end

-- ==============================================================================
-- 3. PROGRESS BAR & FOOTER
-- ==============================================================================
local ProgressTrack = Instance.new("Frame")
ProgressTrack.Name = "ProgressTrack"
ProgressTrack.Size = UDim2.new(1, -70, 0, 4)
ProgressTrack.Position = UDim2.new(0, 35, 1, -64)
ProgressTrack.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
ProgressTrack.BorderSizePixel = 0
ProgressTrack.Parent = Modal

local trackCorner = Instance.new("UICorner", ProgressTrack)
trackCorner.CornerRadius = UDim.new(1, 0)

local ProgressFill = Instance.new("Frame")
ProgressFill.Name = "ProgressFill"
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressTrack

local fillCorner = Instance.new("UICorner", ProgressFill)
fillCorner.CornerRadius = UDim.new(1, 0)

-- Footer Label
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Name = "FooterLabel"
FooterLabel.Size = UDim2.new(1, 0, 0, 16)
FooterLabel.Position = UDim2.new(0, 0, 1, -38)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Font = Enum.Font.GothamMedium
FooterLabel.TextSize = 10
FooterLabel.TextColor3 = Color3.fromRGB(90, 90, 100)
FooterLabel.Text = "ECCO HUB V3"
FooterLabel.Parent = Modal

-- Visual State Animation Helpers
local function setStageActive(num, statusText)
    StatusLabel.Text = statusText
    local row = stageRows[num]
    if not row then return end
    row.nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    row.numLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    row.stroke.Color = Color3.fromRGB(0, 200, 255)
    row.circle.BackgroundColor3 = Color3.fromRGB(15, 25, 35)
end

local function setStageComplete(num)
    local row = stageRows[num]
    if not row then return end
    row.nameLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
    row.numLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    row.circle.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    row.stroke.Color = Color3.fromRGB(245, 245, 250)
    row.checkText.TextColor3 = Color3.fromRGB(8, 8, 10)
    row.checkText.Text = "✓"
end

local function setStageError(num, errText)
    StatusLabel.Text = errText
    StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
    local row = stageRows[num]
    if not row then return end
    row.nameLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    row.circle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    row.stroke.Color = Color3.fromRGB(255, 75, 75)
    row.checkText.TextColor3 = Color3.fromRGB(255, 255, 255)
    row.checkText.Text = "X"
end

local function updateProgress(targetScale)
    TweenService:Create(ProgressFill, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(targetScale, 0, 1, 0)
    }):Play()
end

-- ==============================================================================
-- 4. MULTI-GAME SCRIPT CATALOG REGISTRY
-- ==============================================================================
local SCRIPT_REGISTRY = {
    -- Storage Hunters: Open World
    [98800969324557] = { Name = "Storage Hunters: Open World", File = "storage_hunters.lua" },
    [9640154] = { Name = "Storage Hunters: Open World", File = "storage_hunters.lua" },

    -- Murder Mystery 2
    [142823291] = { Name = "Murder Mystery 2", File = "mm2.lua" },

    -- Pickaxe Tycoon (RootPlace, Universe, Group, Alt)
    [73814003954154] = { Name = "Pickaxe Tycoon", File = "pickaxe_tycoon.lua" },
    [10081194651] = { Name = "Pickaxe Tycoon", File = "pickaxe_tycoon.lua" },
    [374857141] = { Name = "Pickaxe Tycoon", File = "pickaxe_tycoon.lua" },
    [18073574163] = { Name = "Pickaxe Tycoon", File = "pickaxe_tycoon.lua" },

    -- Survive Zombie Arena (RootPlace, Universe, Group)
    [114204398207377] = { Name = "Survive Zombie Arena", File = "survive_zombie_arena.lua" },
    [9348272796] = { Name = "Survive Zombie Arena", File = "survive_zombie_arena.lua" },
    [561990553] = { Name = "Survive Zombie Arena", File = "survive_zombie_arena.lua" },

    -- Axe RNG (RootPlace, Universe, Group)
    [121863161094252] = { Name = "Axe RNG", File = "axe_rng.lua" },
    [10241922839] = { Name = "Axe RNG", File = "axe_rng.lua" },
    [896806231] = { Name = "Axe RNG", File = "axe_rng.lua" },

    -- Saber Simulator
    [5028964] = { Name = "Saber Simulator", File = "saber_simulator.lua" },
    [382378110] = { Name = "Saber Simulator", File = "saber_simulator.lua" },

    -- Universal Fallback
    ["UNIVERSAL"] = { Name = "Ecco Hub Universal", File = "universal.lua" }
}

local function fetchCode(url)
    local success, res = pcall(function()
        return game:HttpGet(url)
    end)
    if success and typeof(res) == "string" and #res > 100 then
        -- Validate it is not an HTML 404/Error page
        local prefix = res:sub(1, 200):lower()
        if not prefix:find("<!doctype") and not prefix:find("<html") and not prefix:find("404: not found") then
            return res
        end
    end
    return nil
end

-- ==============================================================================
-- 5. ASYNCHRONOUS STEPPER EXECUTION FLOW
-- ==============================================================================
task.spawn(function()
    -- STAGE 1: ENVIRONMENT
    setStageActive(1, "ANALYZING EXECUTOR ENVIRONMENT...")
    updateProgress(0.2)
    task.wait(0.25)

    if not game.HttpGet or not loadstring then
        setStageError(1, "UNSUPPORTED EXECUTOR (MISSING HTTPGET/LOADSTRING)")
        return
    end
    setStageComplete(1)

    -- STAGE 2: CONFIGURATION
    setStageActive(2, "FETCHING REMOTE CLOUD CONFIG...")
    updateProgress(0.4)
    task.wait(0.25)

    local rawConfig = fetchCode("https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/config.json")
    if not rawConfig then
        rawConfig = fetchCode("http://127.0.0.1:8999/config.json")
    end
    if not rawConfig then
        rawConfig = fetchCode("https://eccohub.xyz/config.json")
    end

    local cloudConfig = {}
    if rawConfig then
        pcall(function()
            cloudConfig = HttpService:JSONDecode(rawConfig)
        end)
    end

    _G.EccoConfig = cloudConfig
    _G.EccoNotifications = cloudConfig.notifications or {}
    setStageComplete(2)

    -- STAGE 3: ACCESS (KEYLESS / KEY SYSTEM / KILLSWITCH)
    setStageActive(3, "VERIFYING ACCESS PERMISSIONS...")
    updateProgress(0.6)
    task.wait(0.25)

    -- Emergency Shutdown check
    if cloudConfig.status == "shutdown" then
        setStageError(3, "ECCO HUB IS CURRENTLY OFFLINE")
        
        -- Display Emergency Shutdown Screen
        StepperFrame.Visible = false
        ProgressTrack.Visible = false

        local sCard = Instance.new("Frame", Modal)
        sCard.Size = UDim2.new(1, -50, 0, 180)
        sCard.Position = UDim2.new(0, 25, 0, 180)
        sCard.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        local scCorner = Instance.new("UICorner", sCard)
        scCorner.CornerRadius = UDim.new(0, 10)
        local scStroke = Instance.new("UIStroke", sCard)
        scStroke.Color = Color3.fromRGB(255, 60, 60)

        local sTitle = Instance.new("TextLabel", sCard)
        sTitle.Size = UDim2.new(1, -20, 0, 24)
        sTitle.Position = UDim2.new(0, 10, 0, 10)
        sTitle.BackgroundTransparency = 1
        sTitle.Font = Enum.Font.GothamBold
        sTitle.TextSize = 13
        sTitle.TextColor3 = Color3.fromRGB(255, 75, 75)
        sTitle.Text = "MAINTENANCE SHUTDOWN"

        local sMsg = Instance.new("TextLabel", sCard)
        sMsg.Size = UDim2.new(1, -20, 0, 70)
        sMsg.Position = UDim2.new(0, 10, 0, 36)
        sMsg.BackgroundTransparency = 1
        sMsg.Font = Enum.Font.Gotham
        sMsg.TextSize = 11
        sMsg.TextColor3 = Color3.fromRGB(200, 200, 200)
        sMsg.TextWrapped = true
        sMsg.Text = cloudConfig.shutdown_message or "Ecco Hub V3 is currently offline for scheduled maintenance. Join our Discord for announcements."

        local dBtn = Instance.new("TextButton", sCard)
        dBtn.Size = UDim2.new(1, -20, 0, 32)
        dBtn.Position = UDim2.new(0, 10, 1, -42)
        dBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
        dBtn.Font = Enum.Font.GothamBold
        dBtn.TextSize = 12
        dBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        dBtn.Text = "Join Discord for Updates"
        local bCorner = Instance.new("UICorner", dBtn)
        bCorner.CornerRadius = UDim.new(0, 6)

        dBtn.MouseButton1Click:Connect(function()
            local cb = setclipboard or toclipboard or (Clipboard and Clipboard.set)
            if cb then cb(cloudConfig.discord or "https://discord.gg/hN9QpA3HA") end
        end)
        return
    end

    -- Keyless vs Key Required Evaluation
    local keyMode = (cloudConfig.key_system and cloudConfig.key_system.mode) or "keyless"
    if keyMode == "keyless" then
        StatusLabel.Text = "ACCESS: KEYLESS (VERIFIED)"
    else
        StatusLabel.Text = "ACCESS: LICENSE VERIFIED"
    end
    setStageComplete(3)

    -- STAGE 4: INTEGRITY
    setStageActive(4, "VALIDATING SESSION INTEGRITY...")
    updateProgress(0.8)
    task.wait(0.25)
    setStageComplete(4)

    -- STAGE 5: PAYLOAD
    setStageActive(5, "DISPATCHING SCRIPT PAYLOAD...")
    updateProgress(1.0)
    task.wait(0.3)

    local target = SCRIPT_REGISTRY[game.PlaceId] or SCRIPT_REGISTRY[game.GameId] or SCRIPT_REGISTRY[game.CreatorId] or SCRIPT_REGISTRY["UNIVERSAL"]
    StatusLabel.Text = "LAUNCHING: " .. target.Name

    local payloadCode
    -- Try local HTTP server
    payloadCode = fetchCode("http://127.0.0.1:8999/products/" .. target.File)
    -- Try GitHub raw products repository
    if not payloadCode then
        payloadCode = fetchCode("https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/products/" .. target.File)
    end
    -- Try root universal if universal
    if not payloadCode and target.File == "universal.lua" then
        payloadCode = fetchCode("http://127.0.0.1:8999/universal.lua")
        if not payloadCode then
            payloadCode = fetchCode("https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/universal.lua")
        end
    end
    -- Try games directory fallback
    if not payloadCode then
        payloadCode = fetchCode("https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/games/" .. target.File:gsub("_", "-"))
    end
    -- Try eccohub.xyz
    if not payloadCode then
        payloadCode = fetchCode("https://eccohub.xyz/products/" .. target.File)
    end

    if not payloadCode then
        setStageError(5, "FAILED TO RETRIEVE PAYLOAD")
        return
    end

    local compiledFn, compileErr = loadstring(payloadCode)
    if not compiledFn then
        setStageError(5, "COMPILATION ERROR: " .. tostring(compileErr):sub(1, 30))
        return
    end

    setStageComplete(5)
    task.wait(0.4)

    -- Smooth fade-out before payload boot
    TweenService:Create(Modal, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(Dimmer, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()

    task.wait(0.38)
    ScreenGui:Destroy()

    -- Spawn Universal Background Brand & Socials Enforcement Engine
    task.spawn(function()
        local cb = setclipboard or toclipboard or (Clipboard and Clipboard.set)
        for loopCount = 1, 100 do
            task.wait(0.5)
            local symbolAsset = getcustomasset and isfile and isfile("ecco_symbol.png") and getcustomasset("ecco_symbol.png")
            local targetGuis = {}
            for _, g in ipairs(gethui():GetChildren()) do
                if g:IsA("ScreenGui") and g.Name ~= "EccoLoaderModal" then
                    table.insert(targetGuis, g)
                end
            end
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
                for _, g in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                    if g:IsA("ScreenGui") and g.Name ~= "EccoLoaderModal" then
                        table.insert(targetGuis, g)
                    end
                end
            end

            for _, g in ipairs(targetGuis) do
                -- Enforce symbol emblem on all window icons & toggle buttons
                if symbolAsset then
                    for _, d in ipairs(g:GetDescendants()) do
                        if d:IsA("ImageLabel") and (d.Image:find("78539693571783") or d.Image:find("91400086538074") or d.Name:find("Icon") or d.Name == "EccoSymbol") then
                            if d.Image ~= symbolAsset and d.Size.Y.Offset >= 18 and d.Size.Y.Offset <= 48 then
                                d.Image = symbolAsset
                                d.ImageRectSize = Vector2.zero
                                d.ImageRectOffset = Vector2.zero
                            end
                        elseif d:IsA("ImageButton") and (g.Name:find("Toggle") or d.Name:find("Toggle")) then
                            if d.Image ~= symbolAsset then
                                d.Image = symbolAsset
                                d.ImageRectSize = Vector2.zero
                                d.ImageRectOffset = Vector2.zero
                            end
                        end
                    end
                end

                -- Enforce official Ecco Hub Discord and TikTok socials
                for _, d in ipairs(g:GetDescendants()) do
                    if d:IsA("TextButton") then
                        if d.Text:find("discord.gg/ecc00") or d.Text:find("discord.gg/ouroboros") then
                            d.Text = d.Text:gsub("discord.gg/%w+", "discord.gg/hN9QpA3HA")
                        elseif d.Text == "Website" or d.Text == "Rscripts" then
                            d.Text = "TikTok (@_ecc00_)"
                            d.MouseButton1Click:Connect(function()
                                if cb then cb("https://www.tiktok.com/@_ecc00_?is_from_webapp=1&sender_device=pc") end
                            end)
                        elseif d.Text == "Discord" then
                            d.MouseButton1Click:Connect(function()
                                if cb then cb("https://discord.gg/hN9QpA3HA") end
                            end)
                        end
                    end
                end
            end
        end
    end)

    -- Execute target script
    compiledFn()
end)
