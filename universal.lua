--[[
    ================================================================================
    ECCO HUB V3 — UNIVERSAL GAME ENGINE & COMMUNITY FALLBACK
    ================================================================================
    Platform : https://eccohub.xyz
    Discord  : https://discord.gg/hN9QpA3HA
    TikTok   : https://www.tiktok.com/@_ecc00_?is_from_webapp=1&sender_device=pc
    Theme    : Midnight Cyan / Dark Obsidian
    ================================================================================
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local gethui = gethui or function() return game:GetService("CoreGui") end
local parent = gethui()

-- Clean up any existing instance
if parent:FindFirstChild("EccoHubV3Universal") then
    parent.EccoHubV3Universal:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EccoHubV3Universal"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = parent

-- Notification System
local function Notify(title, message, duration)
    duration = duration or 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 260, 0, 56)
    notif.Position = UDim2.new(1, -275, 1, -70)
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    notif.BorderSizePixel = 0
    notif.ZIndex = 100
    
    local c = Instance.new("UICorner", notif)
    c.CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", notif)
    s.Color = Color3.fromRGB(0, 200, 255)
    s.Thickness = 1
    
    local t = Instance.new("TextLabel", notif)
    t.Size = UDim2.new(1, -16, 0, 20)
    t.Position = UDim2.new(0, 10, 0, 6)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextColor3 = Color3.fromRGB(0, 200, 255)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Text = title
    
    local m = Instance.new("TextLabel", notif)
    m.Size = UDim2.new(1, -16, 0, 24)
    m.Position = UDim2.new(0, 10, 0, 26)
    m.BackgroundTransparency = 1
    m.Font = Enum.Font.Gotham
    m.TextSize = 11
    m.TextColor3 = Color3.fromRGB(220, 220, 220)
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.Text = message
    
    notif.Parent = ScreenGui
    task.delay(duration, function()
        pcall(function()
            TweenService:Create(notif, TweenInfo.new(0.3), { Position = UDim2.new(1, 10, 1, -70) }):Play()
            task.wait(0.35)
            notif:Destroy()
        end)
    end)
end

-- Ensure symbol logo is present
pcall(function()
    if isfile and not isfile("ecco_symbol.png") then
        pcall(function()
            local s = game:HttpGet("http://127.0.0.1:8999/ecco_symbol.png")
            writefile("ecco_symbol.png", s)
        end)
    end
end)

-- Main Frame Proportions
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 380)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 50)
MainStroke.Thickness = 1.5

-- Top Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10)

-- Header Logo Icon (Ecco Symbol Only)
local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "LogoImage"
LogoImage.Size = UDim2.new(0, 26, 0, 26)
LogoImage.Position = UDim2.new(0, 10, 0, 7)
LogoImage.BackgroundTransparency = 1
pcall(function()
    if getcustomasset and isfile and isfile("ecco_symbol.png") then
        LogoImage.Image = getcustomasset("ecco_symbol.png")
    else
        LogoImage.Image = "rbxassetid://91400086538074"
    end
end)
LogoImage.Parent = Header

-- Title Text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(0, 300, 1, 0)
TitleLabel.Position = UDim2.new(0, 42, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "Ecco Hub V3 • Universal Engine"
TitleLabel.Parent = Header

-- Subtitle Tag
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 120, 0, 18)
Subtitle.Position = UDim2.new(0, 280, 0.5, -9)
Subtitle.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
Subtitle.BackgroundTransparency = 0.8
Subtitle.Font = Enum.Font.GothamBold
Subtitle.TextSize = 10
Subtitle.TextColor3 = Color3.fromRGB(0, 200, 255)
Subtitle.Text = "UNMAPPED GAME"
local subCorner = Instance.new("UICorner", Subtitle)
subCorner.CornerRadius = UDim.new(0, 4)
Subtitle.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Text = "X"
local closeCorner = Instance.new("UICorner", CloseBtn)
closeCorner.CornerRadius = UDim.new(0, 6)
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    Notify("Ecco Hub V3", "Minimized! Click floating toggle to reopen.", 2.5)
end)

-- Tab Selector
local TabHolder = Instance.new("Frame")
TabHolder.Name = "TabHolder"
TabHolder.Size = UDim2.new(0, 130, 1, -50)
TabHolder.Position = UDim2.new(0, 10, 0, 45)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = MainFrame

local TabList = Instance.new("UIListLayout", TabHolder)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 6)

-- Content Area
local ContentHolder = Instance.new("Frame")
ContentHolder.Name = "ContentHolder"
ContentHolder.Size = UDim2.new(1, -160, 1, -50)
ContentHolder.Position = UDim2.new(0, 150, 0, 45)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = MainFrame

local pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    page.Visible = false
    page.Parent = ContentHolder
    
    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)
    
    pages[name] = page
    return page
end

local function selectTab(targetName)
    for name, page in pairs(pages) do
        page.Visible = (name == targetName)
    end
    for _, btn in ipairs(TabHolder:GetChildren()) do
        if btn:IsA("TextButton") then
            if btn.Name == targetName .. "TabBtn" then
                btn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
    end
end

local function addTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "TabBtn"
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Text = name
    btn.LayoutOrder = order
    
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    btn.Parent = TabHolder
    
    btn.MouseButton1Click:Connect(function()
        selectTab(name)
    end)
    return btn
end

-- UI Component Helpers
local function createCard(parent, title, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -8, 0, height or 70)
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    card.BorderSizePixel = 0
    local c = Instance.new("UICorner", card)
    c.CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", card)
    s.Color = Color3.fromRGB(40, 40, 50)
    
    local t = Instance.new("TextLabel", card)
    t.Size = UDim2.new(1, -16, 0, 22)
    t.Position = UDim2.new(0, 10, 0, 6)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextColor3 = Color3.fromRGB(0, 200, 255)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Text = title
    
    card.Parent = parent
    return card
end

local function createActionRow(card, desc, btnText, callback)
    local d = Instance.new("TextLabel", card)
    d.Size = UDim2.new(1, -120, 0, 20)
    d.Position = UDim2.new(0, 10, 1, -30)
    d.BackgroundTransparency = 1
    d.Font = Enum.Font.Gotham
    d.TextSize = 11
    d.TextColor3 = Color3.fromRGB(180, 180, 180)
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.Text = desc
    
    local b = Instance.new("TextButton", card)
    b.Size = UDim2.new(0, 95, 0, 26)
    b.Position = UDim2.new(1, -105, 1, -32)
    b.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = btnText
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 5)
    
    b.MouseButton1Click:Connect(callback)
    return b
end

-- ==============================================================================
-- 1. TAB: INFO (TOP / FIRST TAB)
-- ==============================================================================
addTabButton("Info", 1)
local infoPage = createPage("Info")

-- Game Info Card
local gameName = "Unknown Game"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then gameName = info.Name end
end)

local gCard = createCard(infoPage, "Game Information", 95)
local gDesc = Instance.new("TextLabel", gCard)
gDesc.Size = UDim2.new(1, -20, 0, 60)
gDesc.Position = UDim2.new(0, 10, 0, 28)
gDesc.BackgroundTransparency = 1
gDesc.Font = Enum.Font.Gotham
gDesc.TextSize = 11
gDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
gDesc.TextXAlignment = Enum.TextXAlignment.Left
gDesc.TextYAlignment = Enum.TextYAlignment.Top
gDesc.Text = string.format("Name: %s\nPlace ID: %s\nUniverse ID: %s\nJob ID: %s",
    gameName, tostring(game.PlaceId), tostring(game.GameId), tostring(game.JobId):sub(1, 20) .. "...")

-- Status / Queue Card
local qCard = createCard(infoPage, "Catalog Support Notice", 80)
local qDesc = Instance.new("TextLabel", qCard)
qDesc.Size = UDim2.new(1, -20, 0, 48)
qDesc.Position = UDim2.new(0, 10, 0, 26)
qDesc.BackgroundTransparency = 1
qDesc.Font = Enum.Font.Gotham
qDesc.TextSize = 11
qDesc.TextColor3 = Color3.fromRGB(240, 180, 0)
qDesc.TextXAlignment = Enum.TextXAlignment.Left
qDesc.TextYAlignment = Enum.TextYAlignment.Top
qDesc.TextWrapped = true
qDesc.Text = "This game does not have a bespoke Ecco Hub script yet. Join our Discord to request it, or use the Universal Movement and Server tools!"

-- Socials Card: Discord
local dCard = createCard(infoPage, "Official Discord Community", 65)
createActionRow(dCard, "https://discord.gg/hN9QpA3HA", "Copy Discord", function()
    local cb = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    if cb then cb("https://discord.gg/hN9QpA3HA") end
    Notify("Ecco Hub V3", "Discord invite copied to clipboard!", 2.5)
end)

-- Socials Card: TikTok
local ttCard = createCard(infoPage, "Official TikTok", 65)
createActionRow(ttCard, "@_ecc00_", "Copy TikTok", function()
    local cb = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    if cb then cb("https://www.tiktok.com/@_ecc00_?is_from_webapp=1&sender_device=pc") end
    Notify("Ecco Hub V3", "TikTok profile copied to clipboard!", 2.5)
end)

-- Copy Details Card
local reqCard = createCard(infoPage, "Request Game Support", 65)
createActionRow(reqCard, "Copy PlaceId & Game Name", "Copy Details", function()
    local cb = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    if cb then
        cb(string.format("Ecco Hub Game Request: %s (PlaceId: %s, GameId: %s)", gameName, tostring(game.PlaceId), tostring(game.GameId)))
    end
    Notify("Ecco Hub V3", "Game details copied! Paste in Discord to request.", 3)
end)

-- ==============================================================================
-- 2. TAB: UNIVERSAL TOOLS
-- ==============================================================================
addTabButton("Universal", 2)
local uniPage = createPage("Universal")

-- WalkSpeed Card
local wsCard = createCard(uniPage, "WalkSpeed Modifier", 70)
createActionRow(wsCard, "Set humanoid speed to 60", "Speed 60", function()
    pcall(function()
        LocalPlayer.Character.Humanoid.WalkSpeed = 60
    end)
    Notify("Universal", "WalkSpeed set to 60", 2)
end)

-- JumpPower Card
local jpCard = createCard(uniPage, "JumpPower Modifier", 70)
createActionRow(jpCard, "Set humanoid JumpPower to 120", "Jump 120", function()
    pcall(function()
        LocalPlayer.Character.Humanoid.JumpPower = 120
    end)
    Notify("Universal", "JumpPower set to 120", 2)
end)

-- Infinite Jump Card
local infJumpActive = false
local ijCard = createCard(uniPage, "Infinite Jump", 70)
local ijBtn = createActionRow(ijCard, "Jump continuously in mid-air", "Toggle Jump", function()
    infJumpActive = not infJumpActive
    Notify("Universal", "Infinite Jump: " .. (infJumpActive and "ON" or "OFF"), 2)
end)

UserInputService.JumpRequest:Connect(function()
    if infJumpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Fullbright Card
local fullbrightActive = false
local fbCard = createCard(uniPage, "Fullbright", 70)
createActionRow(fbCard, "Max lighting brightness", "Toggle Light", function()
    fullbrightActive = not fullbrightActive
    if fullbrightActive then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
    end
    Notify("Universal", "Fullbright: " .. (fullbrightActive and "ON" or "OFF"), 2)
end)

-- Anti-AFK Card
local afkCard = createCard(uniPage, "Anti-AFK Protection", 70)
createActionRow(afkCard, "Prevent idle disconnection (20m limit)", "Enable AFK", function()
    LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
    Notify("Universal", "Anti-AFK Active! You will not disconnect.", 3)
end)

-- ==============================================================================
-- 3. TAB: SERVER TOOLS
-- ==============================================================================
addTabButton("Server", 3)
local srvPage = createPage("Server")

-- Rejoin Server Card
local rjCard = createCard(srvPage, "Rejoin Current Server", 70)
createActionRow(rjCard, "Reconnect to same instance (JobId)", "Rejoin", function()
    Notify("Server", "Reconnecting to instance...", 2)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

-- Server Hop Card
local shCard = createCard(srvPage, "Server Hop", 70)
createActionRow(shCard, "Teleport to a new game server", "Hop Server", function()
    Notify("Server", "Searching for available server...", 2)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- Select first tab (Info) by default
selectTab("Info")

-- ==============================================================================
-- 4. FLOATING TOGGLE BUTTON (CROPPED ECCO EMBLEM ONLY)
-- ==============================================================================
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "EccoUniversalToggle"
ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 10000
ToggleGui.Parent = parent

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -24)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local tCorner = Instance.new("UICorner", ToggleBtn)
tCorner.CornerRadius = UDim.new(0, 10)
local tStroke = Instance.new("UIStroke", ToggleBtn)
tStroke.Color = Color3.fromRGB(0, 200, 255)
tStroke.Thickness = 1.5

pcall(function()
    if getcustomasset and isfile and isfile("ecco_symbol.png") then
        ToggleBtn.Image = getcustomasset("ecco_symbol.png")
    else
        ToggleBtn.Image = "rbxassetid://91400086538074"
    end
end)
ToggleBtn.Parent = ToggleGui

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

Notify("Ecco Hub V3", "Universal Module Loaded! Press floating icon to toggle.", 3)
