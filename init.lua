-- Sell Lemons Hub | Ecco Loader
-- Target Hub Script: https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/hub.lua
-- Key Database: https://jsonblob.com/api/jsonBlob/019f332a-96d1-7a6c-9719-94f351396b5b

local HttpService  = game:GetService("HttpService")
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

local DATABASE_URL = "https://jsonblob.com/api/jsonBlob/019f332a-96d1-7a6c-9719-94f351396b5b"
local SCRIPT_URL   = "https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/hub.lua"
local KEY_FILE     = "ecco_hub_key.txt"

-- =========================================
-- Parent Selection
-- =========================================
local parent = CoreGui
if gethui then parent = gethui() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "EccoLoader"
ScreenGui.ResetOnSpawn   = false
ScreenGui.DisplayOrder   = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = parent

-- =========================================
-- Full-screen dim overlay
-- =========================================
local Dim = Instance.new("Frame", ScreenGui)
Dim.Size                 = UDim2.fromScale(1, 1)
Dim.BackgroundColor3     = Color3.fromRGB(0, 0, 0)
Dim.BackgroundTransparency = 1
Dim.BorderSizePixel      = 0
Dim.ZIndex               = 1

-- Fade in dim
TweenService:Create(Dim, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.4}):Play()

-- =========================================
-- Main Card Frame
-- =========================================
local Card = Instance.new("Frame", ScreenGui)
Card.Name                = "Card"
Card.Size                = UDim2.new(0, 360, 0, 220)
Card.Position            = UDim2.new(0.5, -180, 0.6, -110) -- Start low
Card.BackgroundColor3    = Color3.fromRGB(12, 12, 12)
Card.BackgroundTransparency = 1
Card.BorderSizePixel     = 0
Card.ZIndex              = 2
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 16)

local CardStroke = Instance.new("UIStroke", Card)
CardStroke.Thickness = 1.5
CardStroke.Color     = Color3.fromRGB(55, 55, 55)
CardStroke.Transparency = 1

-- Animate card up and fade in
TweenService:Create(Card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -180, 0.5, -110),
    BackgroundTransparency = 0,
}):Play()
TweenService:Create(CardStroke, TweenInfo.new(0.45), {Transparency = 0}):Play()

-- =========================================
-- Top Accent Gradient Bar
-- =========================================
local TopBar = Instance.new("Frame", Card)
TopBar.Size             = UDim2.new(1, 0, 0, 4)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 210, 50)
TopBar.BorderSizePixel  = 0
TopBar.ZIndex           = 3
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)
local TBGrad = Instance.new("UIGradient", TopBar)
TBGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 230, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 140, 20)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(230, 60,  20)),
})

-- =========================================
-- Diamond Icon (Bouncing Animation)
-- =========================================
local Lemon = Instance.new("TextLabel", Card)
Lemon.Size                = UDim2.new(0, 60, 0, 60)
Lemon.Position            = UDim2.new(0.5, -30, 0, 18)
Lemon.BackgroundTransparency = 1
Lemon.Text                = "ðŸ’Ž"
Lemon.TextSize            = 48
Lemon.Font                = Enum.Font.Gotham
Lemon.ZIndex              = 3

local bounceUp = true
local function bounceLemon()
    if not Lemon or not Lemon.Parent then return end
    local target = bounceUp
        and UDim2.new(0.5, -30, 0, 10)
        or  UDim2.new(0.5, -30, 0, 22)
    bounceUp = not bounceUp
    TweenService:Create(Lemon, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        Position = target
    }):Play()
end

task.spawn(function()
    while Lemon and Lemon.Parent do
        bounceLemon()
        task.wait(0.5)
    end
end)

-- =========================================
-- Title Labels
-- =========================================
local Title = Instance.new("TextLabel", Card)
Title.Size                = UDim2.new(1, -20, 0, 28)
Title.Position            = UDim2.new(0, 10, 0, 86)
Title.BackgroundTransparency = 1
Title.Text                = "ecco loader"
Title.TextColor3          = Color3.fromRGB(255, 235, 59)
Title.TextSize            = 22
Title.Font                = Enum.Font.GothamBold
Title.ZIndex              = 3

local StatusLabel = Instance.new("TextLabel", Card)
StatusLabel.Size                = UDim2.new(1, -30, 0, 22)
StatusLabel.Position            = UDim2.new(0, 15, 0, 120)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text                = "Connecting to cloud..."
StatusLabel.TextColor3          = Color3.fromRGB(160, 160, 160)
StatusLabel.TextSize            = 13
StatusLabel.Font                = Enum.Font.Gotham
StatusLabel.ZIndex              = 3

-- =========================================
-- Progress Bar
-- =========================================
local Track = Instance.new("Frame", Card)
Track.Size             = UDim2.new(1, -40, 0, 6)
Track.Position         = UDim2.new(0, 20, 0, 152)
Track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Track.BorderSizePixel  = 0
Track.ZIndex           = 3
Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

local Bar = Instance.new("Frame", Track)
Bar.Size             = UDim2.new(0, 0, 1, 0)
Bar.BackgroundColor3 = Color3.fromRGB(255, 200, 30)
Bar.BorderSizePixel  = 0
Bar.ZIndex           = 4
Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

local BarGrad = Instance.new("UIGradient", Bar)
BarGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 230, 50)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 120, 0)),
})

-- Shimmer Rotation Loop
task.spawn(function()
    local rot = 0
    while Bar and Bar.Parent do
        rot = (rot + 3) % 360
        BarGrad.Rotation = rot
        task.wait(0.016)
    end
end)

-- Credit Label
local Credit = Instance.new("TextLabel", Card)
Credit.Size                = UDim2.new(1, -20, 0, 18)
Credit.Position            = UDim2.new(0, 10, 0, 190)
Credit.BackgroundTransparency = 1
Credit.Text                = "ecco hub v1.0 â€¢ diamond edition"
Credit.TextColor3          = Color3.fromRGB(70, 70, 70)
Credit.TextSize            = 11
Credit.Font                = Enum.Font.Gotham
Credit.ZIndex              = 3

-- =========================================
-- Custom Hashing & Expiration Logic
-- =========================================
local function hashKey(str)
    local h = 5381
    for i = 1, #str do
        h = (bit32.lshift(h, 5) + h) + str:byte(i)
    end
    return tostring(h)
end

local function parseDate(dateStr)
    local y, m, d = dateStr:match("(%d+)-(%d+)-(%d+)")
    if y and m and d then
        return os.time({year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 23, min = 59, sec = 59})
    end
    return 0
end

local function checkKey(key, db)
    if not key or key == "" then return false end
    local hashed = hashKey(key)
    local keyData = db.keys[hashed]
    if keyData then
        if keyData == "permanent" then
            return true
        else
            local expiry = parseDate(keyData)
            if os.time() <= expiry then
                return true
            end
        end
    end
    return false
end

-- =========================================
-- Load & Fade Out Transition
-- =========================================
local function setProgress(pct, msg)
    if not Bar or not Bar.Parent then return end
    TweenService:Create(Bar, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        Size = UDim2.new(pct, 0, 1, 0)
    }):Play()
    if StatusLabel and StatusLabel.Parent then
        StatusLabel.Text = msg
    end
end

local function executeHub()
    setProgress(1.0, "Launching hub...")
    task.wait(0.6)
    
    TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -180, 0.45, -110),
    }):Play()
    TweenService:Create(CardStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
    TweenService:Create(Dim, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    
    task.wait(0.45)
    ScreenGui:Destroy()
    
    local ok, err = pcall(function()
        loadstring(game:HttpGet(SCRIPT_URL))()
    end)
    if not ok then
        warn("[ecco loader] Error: " .. tostring(err))
    end
end

-- =========================================
-- Main Logic Loop (Cloud Verification)
-- =========================================
task.spawn(function()
    task.wait(0.5)
    setProgress(0.3, "Connecting to database...")
    
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(DATABASE_URL))
    end)
    
    if not success or not response then
        setProgress(0.3, "Database offline. Retrying...")
        task.wait(2)
        success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(DATABASE_URL))
        end)
    end
    
    if not success or not response then
        StatusLabel.Text = "Connection error. Re-execute script."
        StatusLabel.TextColor3 = Color3.fromRGB(220, 20, 60)
        return
    end
    
    setProgress(0.6, "Validating parameters...")
    task.wait(0.3)
    
    -- Check Keyless
    if response.keyless then
        setProgress(0.9, "Keyless bypass verified...")
        task.wait(0.4)
        executeHub()
        return
    end
    
    -- Read local saved key
    local savedKey = ""
    pcall(function()
        if isfile(KEY_FILE) then
            savedKey = readfile(KEY_FILE)
        end
    end)
    
    if checkKey(savedKey, response) then
        setProgress(0.9, "Saved key authenticated...")
        task.wait(0.4)
        executeHub()
        return
    end
    
    -- Expose Submit Key UI
    setProgress(0.8, "Key validation required.")
    task.wait(0.4)
    
    -- Transition UI Elements to Key Entry form
    TweenService:Create(StatusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(Track, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Bar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Credit, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    task.wait(0.3)
    
    StatusLabel:Destroy()
    Track:Destroy()
    Credit:Destroy()
    
    -- Resize Main card to fit Key submission UI
    TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 360, 0, 240)
    }):Play()
    task.wait(0.4)
    
    -- Create TextBox
    local KeyInput = Instance.new("TextBox", Card)
    KeyInput.Name = "KeyInput"
    KeyInput.Size = UDim2.new(0, 300, 0, 36)
    KeyInput.Position = UDim2.new(0.5, -150, 0, 80)
    KeyInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    KeyInput.BorderSizePixel = 0
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "Enter key here..."
    KeyInput.TextColor3 = Color3.fromRGB(240, 240, 240)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    KeyInput.TextSize = 14
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.ZIndex = 3
    Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
    
    local KeyInputStroke = Instance.new("UIStroke", KeyInput)
    KeyInputStroke.Thickness = 1
    KeyInputStroke.Color = Color3.fromRGB(45, 45, 45)
    
    -- Submit Button
    local SubmitBtn = Instance.new("TextButton", Card)
    SubmitBtn.Name = "SubmitBtn"
    SubmitBtn.Size = UDim2.new(0, 140, 0, 34)
    SubmitBtn.Position = UDim2.new(0.5, -150, 0, 130)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.Text = "Submit Key"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 14
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.ZIndex = 3
    Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)
    
    -- Get Key Button
    local GetKeyBtn = Instance.new("TextButton", Card)
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.Size = UDim2.new(0, 140, 0, 34)
    GetKeyBtn.Position = UDim2.new(0.5, 10, 0, 130)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    GetKeyBtn.TextSize = 14
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.ZIndex = 3
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)
    
    -- Info Status
    local InfoStatus = Instance.new("TextLabel", Card)
    InfoStatus.Name = "InfoStatus"
    InfoStatus.Size = UDim2.new(1, 0, 0, 26)
    InfoStatus.Position = UDim2.new(0, 0, 0, 185)
    InfoStatus.BackgroundTransparency = 1
    InfoStatus.Text = "Need a key? Click 'Get Key' to copy link"
    InfoStatus.TextColor3 = Color3.fromRGB(130, 130, 130)
    InfoStatus.TextSize = 12
    InfoStatus.Font = Enum.Font.Gotham
    InfoStatus.ZIndex = 3
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton", Card)
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 6)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "âœ•"
    CloseBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.ZIndex = 3
    
    -- Hover effect
    local function connectHover(btn, hoverCol, defaultCol)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverCol}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = defaultCol}):Play()
        end)
    end
    
    connectHover(SubmitBtn, Color3.fromRGB(46, 175, 46), Color3.fromRGB(34, 139, 34))
    connectHover(GetKeyBtn, Color3.fromRGB(55, 55, 55), Color3.fromRGB(40, 40, 40))
    
    -- Buttons logic
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    GetKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard or toclipboard then
            local copy = setclipboard or toclipboard
            copy(response.key_link)
            InfoStatus.Text = "Key link copied to clipboard!"
            InfoStatus.TextColor3 = Color3.fromRGB(255, 235, 59)
        else
            InfoStatus.Text = "Link: " .. response.key_link
            InfoStatus.TextColor3 = Color3.fromRGB(255, 235, 59)
        end
    end)
    
    local submitting = false
    SubmitBtn.MouseButton1Click:Connect(function()
        if submitting then return end
        submitting = true
        local key = KeyInput.Text
        InfoStatus.Text = "Checking key..."
        InfoStatus.TextColor3 = Color3.fromRGB(255, 235, 59)
        task.wait(0.5)
        
        if checkKey(key, response) then
            InfoStatus.Text = "Key accepted! Loading..."
            InfoStatus.TextColor3 = Color3.fromRGB(50, 205, 50)
            pcall(function()
                writefile(KEY_FILE, key)
            end)
            task.wait(1)
            
            -- Transition card out
            TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -180, 0.45, -110),
            }):Play()
            TweenService:Create(CardStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
            TweenService:Create(Dim, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            
            task.wait(0.45)
            ScreenGui:Destroy()
            
            local ok, err = pcall(function()
                loadstring(game:HttpGet(SCRIPT_URL))()
            end)
            if not ok then
                warn("[ecco loader] Error: " .. tostring(err))
            end
        else
            InfoStatus.Text = "Invalid or expired key!"
            InfoStatus.TextColor3 = Color3.fromRGB(220, 20, 60)
            submitting = false
        end
    end)
end)
