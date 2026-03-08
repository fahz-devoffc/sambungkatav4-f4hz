--[[ 
    FAHZHUB | SAMBUNG KATA V3 ULTIMATE
    - Auto-detect huruf awal dari UI
    - Auto-cari kata yang cocok dari wordlist
    - Auto-klik keyboard virtual
    - Dual mode: NATURAL (manusiawi) & FAST (cepat)
    - UI premium dengan RGB effect
    - Ukuran 250x400 (lebih gede)
    - Modified by Lisa
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== SETUP AWAL ====================
local wordList = {}           -- Semua kata dari wordlist
local usedWords = {}          -- Kata yang udah dipake
local currentMode = "NATURAL" -- NATURAL atau FAST
local isActive = false        -- Status auto-type
local currentPage = 1
local typingSpeed = {
    NATURAL = {min = 0.08, max = 0.25}, -- Kecepatan ngetik ala manusia (variatif)
    FAST = {min = 0.02, max = 0.04}      -- Kecepatan ngetik cepet
}
local startTime = tick()
local rgbHue = 0

-- ==================== GUI UTAMA (UKURAN 250x400) ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FahzHub_SambungKata_V3"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999

-- Frame utama (lebih gede: 250x400)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
mainFrame.Position = UDim2.new(0.5, -125, 0.4, -50) -- Tengah
mainFrame.Size = UDim2.new(0, 250, 0, 400)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true

-- Shadow premium
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Parent = mainFrame
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Image = "rbxassetid://6015897843"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ZIndex = -1
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 10, 10)

-- Corner radius
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 16)

-- Stroke RGB (akan dianimasi)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- ==================== TITLE BAR ====================
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.ZIndex = 2

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 16)

local titleGradient = Instance.new("UIGradient", titleBar)
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 255))
})
titleGradient.Rotation = 45

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "⚡ FAHZHUB | SAMBUNG KATA V3"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextStrokeTransparency = 0.5

local closeButton = Instance.new("TextButton")
closeButton.Parent = titleBar
closeButton.BackgroundTransparency = 1
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Text = "−"
closeButton.TextColor3 = Color3.fromRGB(255, 150, 150)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold

-- ==================== CONTENT SCROLLING FRAME ====================
local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Name = "ContentContainer"
contentContainer.Parent = mainFrame
contentContainer.BackgroundTransparency = 1
contentContainer.Position = UDim2.new(0, 5, 0, 50)
contentContainer.Size = UDim2.new(1, -10, 1, -55)
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
contentContainer.ScrollBarThickness = 5
contentContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
contentContainer.ElasticBehavior = Enum.ElasticBehavior.Always
contentContainer.ScrollingDirection = Enum.ScrollingDirection.Y
contentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local contentList = Instance.new("UIListLayout")
contentList.Parent = contentContainer
contentList.Padding = UDim.new(0, 8)
contentList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local padding = Instance.new("UIPadding", contentContainer)
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)

-- ==================== STATUS SECTION ====================
local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusFrame"
statusFrame.Parent = contentContainer
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusFrame.Size = UDim2.new(1, -10, 0, 70)
statusFrame.AutomaticSize = Enum.AutomaticSize.Y

local statusCorner = Instance.new("UICorner", statusFrame)
statusCorner.CornerRadius = UDim.new(0, 10)

local statusPadding = Instance.new("UIPadding", statusFrame)
statusPadding.PaddingLeft = UDim.new(0, 10)
statusPadding.PaddingRight = UDim.new(0, 10)
statusPadding.PaddingTop = UDim.new(0, 8)
statusPadding.PaddingBottom = UDim.new(0, 8)

local statusList = Instance.new("UIListLayout")
statusList.Parent = statusFrame
statusList.Padding = UDim.new(0, 5)
statusList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Huruf awal terdeteksi
local hurufAwalFrame = Instance.new("Frame")
hurufAwalFrame.Parent = statusFrame
hurufAwalFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
hurufAwalFrame.Size = UDim2.new(1, 0, 0, 30)
hurufAwalFrame.AutomaticSize = Enum.AutomaticSize.Y

local hurufCorner = Instance.new("UICorner", hurufAwalFrame)
hurufCorner.CornerRadius = UDim.new(0, 8)

local hurufLabel = Instance.new("TextLabel")
hurufLabel.Parent = hurufAwalFrame
hurufLabel.BackgroundTransparency = 1
hurufLabel.Size = UDim2.new(1, -10, 1, 0)
hurufLabel.Position = UDim2.new(0, 5, 0, 0)
hurufLabel.Font = Enum.Font.GothamBold
hurufLabel.Text = "🔍 HURUF AWAL: [BELUM TERDETEKSI]"
hurufLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
hurufLabel.TextSize = 13
hurufLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Status auto-type
local autoStatusFrame = Instance.new("Frame")
autoStatusFrame.Parent = statusFrame
autoStatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
autoStatusFrame.Size = UDim2.new(1, 0, 0, 30)

local autoCorner = Instance.new("UICorner", autoStatusFrame)
autoCorner.CornerRadius = UDim.new(0, 8)

local autoStatusLabel = Instance.new("TextLabel")
autoStatusLabel.Parent = autoStatusFrame
autoStatusLabel.BackgroundTransparency = 1
autoStatusLabel.Size = UDim2.new(0.7, -5, 1, 0)
autoStatusLabel.Position = UDim2.new(0, 5, 0, 0)
autoStatusLabel.Font = Enum.Font.Gotham
autoStatusLabel.Text = "⏸️ AUTO-TYPE: OFF"
autoStatusLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
autoStatusLabel.TextSize = 13
autoStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local modeButton = Instance.new("TextButton")
modeButton.Parent = autoStatusFrame
modeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
modeButton.Position = UDim2.new(0.7, 0, 0, 3)
modeButton.Size = UDim2.new(0.3, -8, 0, 24)
modeButton.Text = "NATURAL"
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.TextSize = 11
modeButton.Font = Enum.Font.GothamBold

local modeCorner = Instance.new("UICorner", modeButton)
modeCorner.CornerRadius = UDim.new(0, 6)

-- ==================== KEYBOARD VISUALIZER ====================
local keyboardFrame = Instance.new("Frame")
keyboardFrame.Name = "KeyboardFrame"
keyboardFrame.Parent = contentContainer
keyboardFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
keyboardFrame.Size = UDim2.new(1, -10, 0, 130)

local keyboardCorner = Instance.new("UICorner", keyboardFrame)
keyboardCorner.CornerRadius = UDim.new(0, 10)

local keyboardTitle = Instance.new("TextLabel")
keyboardTitle.Parent = keyboardFrame
keyboardTitle.BackgroundTransparency = 1
keyboardTitle.Position = UDim2.new(0, 10, 0, 5)
keyboardTitle.Size = UDim2.new(1, -20, 0, 20)
keyboardTitle.Font = Enum.Font.GothamBold
keyboardTitle.Text = "⌨️ KEYBOARD VIRTUAL"
keyboardTitle.TextColor3 = Color3.fromRGB(150, 150, 255)
keyboardTitle.TextSize = 11
keyboardTitle.TextXAlignment = Enum.TextXAlignment.Left

local keyboardGrid = Instance.new("Frame")
keyboardGrid.Parent = keyboardFrame
keyboardGrid.BackgroundTransparency = 1
keyboardGrid.Position = UDim2.new(0, 5, 0, 25)
keyboardGrid.Size = UDim2.new(1, -10, 1, -30)

-- Baris keyboard
local baris1 = {"Q","W","E","R","T","Y","U","I","O","P"}
local baris2 = {"A","S","D","F","G","H","J","K","L"}
local baris3 = {"Z","X","C","V","B","N","M"}

local function buatTombolKeyboard(huruf, parent, posX, posY, sizeX)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Name = "Key_"..huruf
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Position = UDim2.new(posX, 0, posY, 0)
    btn.Size = UDim2.new(sizeX, 0, 0, 25)
    btn.Text = huruf
    btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.ZIndex = 5
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    return btn
end

-- Buat baris 1
for i, huruf in ipairs(baris1) do
    buatTombolKeyboard(huruf, keyboardGrid, (i-1)*0.1, 0, 0.095)
end

-- Buat baris 2
for i, huruf in ipairs(baris2) do
    buatTombolKeyboard(huruf, keyboardGrid, 0.05 + (i-1)*0.1, 0.33, 0.095)
end

-- Buat baris 3
for i, huruf in ipairs(baris3) do
    buatTombolKeyboard(huruf, keyboardGrid, 0.15 + (i-1)*0.1, 0.66, 0.095)
end

-- Tombol Masuk
local enterButton = Instance.new("TextButton")
enterButton.Parent = keyboardGrid
enterButton.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
enterButton.Position = UDim2.new(0.7, 0, 0.66, 0)
enterButton.Size = UDim2.new(0.25, 0, 0, 25)
enterButton.Text = "↵ MASUK"
enterButton.TextColor3 = Color3.fromRGB(255, 255, 255)
enterButton.Font = Enum.Font.GothamBold
enterButton.TextSize = 10

local enterCorner = Instance.new("UICorner", enterButton)
enterCorner.CornerRadius = UDim.new(0, 5)

-- ==================== WORD LIST SECTION ====================
local wordlistFrame = Instance.new("Frame")
wordlistFrame.Name = "WordlistFrame"
wordlistFrame.Parent = contentContainer
wordlistFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
wordlistFrame.Size = UDim2.new(1, -10, 0, 150)

local wordlistCorner = Instance.new("UICorner", wordlistFrame)
wordlistCorner.CornerRadius = UDim.new(0, 10)

local wordlistTitle = Instance.new("TextLabel")
wordlistTitle.Parent = wordlistFrame
wordlistTitle.BackgroundTransparency = 1
wordlistTitle.Position = UDim2.new(0, 10, 0, 5)
wordlistTitle.Size = UDim2.new(1, -20, 0, 20)
wordlistTitle.Font = Enum.Font.GothamBold
wordlistTitle.Text = "📋 DAFTAR KATA (SWIPE DOWN)"
wordlistTitle.TextColor3 = Color3.fromRGB(150, 150, 255)
wordlistTitle.TextSize = 11
wordlistTitle.TextXAlignment = Enum.TextXAlignment.Left

local wordContainer = Instance.new("ScrollingFrame")
wordContainer.Name = "WordContainer"
wordContainer.Parent = wordlistFrame
wordContainer.BackgroundTransparency = 1
wordContainer.Position = UDim2.new(0, 5, 0, 25)
wordContainer.Size = UDim2.new(1, -10, 1, -30)
wordContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
wordContainer.ScrollBarThickness = 4
wordContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
wordContainer.ElasticBehavior = Enum.ElasticBehavior.Always
wordContainer.ScrollingDirection = Enum.ScrollingDirection.Y

local wordLayout = Instance.new("UIListLayout")
wordLayout.Parent = wordContainer
wordLayout.Padding = UDim.new(0, 3)
wordLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ==================== BUTTON CONTROL ====================
local controlFrame = Instance.new("Frame")
controlFrame.Name = "ControlFrame"
controlFrame.Parent = contentContainer
controlFrame.BackgroundTransparency = 1
controlFrame.Size = UDim2.new(1, -10, 0, 35)

local controlLayout = Instance.new("UIListLayout")
controlLayout.Parent = controlFrame
controlLayout.FillDirection = Enum.FillDirection.Horizontal
controlLayout.Padding = UDim.new(0, 5)
controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function buatButtonControl(text, color)
    local btn = Instance.new("TextButton")
    btn.Parent = controlFrame
    btn.BackgroundColor3 = color
    btn.Size = UDim2.new(0, 70, 0, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    return btn
end

local startStopBtn = buatButtonControl("⏯️ START", Color3.fromRGB(40, 150, 80))
local resetBtn = buatButtonControl("🔄 RESET", Color3.fromRGB(200, 100, 50))
local loadMoreBtn = buatButtonControl("📥 LOAD", Color3.fromRGB(80, 80, 200))

-- ==================== STATS BAR ====================
local statsBar = Instance.new("Frame")
statsBar.Name = "StatsBar"
statsBar.Parent = contentContainer
statsBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
statsBar.Size = UDim2.new(1, -10, 0, 25)

local statsCorner = Instance.new("UICorner", statsBar)
statsCorner.CornerRadius = UDim.new(0, 8)

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Parent = statsBar
fpsLabel.BackgroundTransparency = 1
fpsLabel.Position = UDim2.new(0, 8, 0, 0)
fpsLabel.Size = UDim2.new(0.5, -4, 1, 0)
fpsLabel.Font = Enum.Font.Code
fpsLabel.Text = "⚡ FPS: 60"
fpsLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
fpsLabel.TextSize = 10
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left

local pingLabel = Instance.new("TextLabel")
pingLabel.Parent = statsBar
pingLabel.BackgroundTransparency = 1
pingLabel.Position = UDim2.new(0.5, 4, 0, 0)
pingLabel.Size = UDim2.new(0.5, -8, 1, 0)
pingLabel.Font = Enum.Font.Code
pingLabel.Text = "📶 PING: 20ms"
pingLabel.TextColor3 = Color3.fromRGB(150, 200, 200)
pingLabel.TextSize = 10
pingLabel.TextXAlignment = Enum.TextXAlignment.Right

-- ==================== FUNGSI CORE ====================

-- Fungsi deteksi huruf awal dari UI game
local function deteksiHurufAwal()
    -- Coba cari di PlayerGui
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, child in pairs(gui:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text or ""
                    -- Cari pola "Hurufnya adalah: X" atau "Huruf: X" atau "Huruf awal: X"
                    local pattern = "Huruf.-:.-(%a)"
                    local match = string.match(text, pattern)
                    if match then
                        hurufLabel.Text = "🔍 HURUF AWAL: " .. string.upper(match)
                        return string.upper(match)
                    end
                end
            end
        end
    end
    return nil
end

-- Fungsi klik tombol keyboard virtual
local function klikHuruf(huruf)
    huruf = string.upper(huruf)
    
    -- Cari tombol di semua GUI
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, child in pairs(gui:GetDescendants()) do
                if child:IsA("TextButton") and child.Visible then
                    local btnText = string.upper(child.Text or "")
                    if btnText == huruf or btnText == "HURUF "..huruf or child.Name:find(huruf) then
                        -- Simulasi klik dengan animasi
                        local originalColor = child.BackgroundColor3
                        child.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        task.wait(0.03)
                        
                        -- Fire click
                        child.MouseButton1Click:Fire()
                        
                        -- Kembalikan warna
                        task.wait(0.03)
                        child.BackgroundColor3 = originalColor
                        
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Fungsi klik tombol Masuk
local function klikMasuk()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, child in pairs(gui:GetDescendants()) do
                if child:IsA("TextButton") and child.Visible then
                    local btnText = string.lower(child.Text or "")
                    if btnText:find("masuk") or btnText:find("enter") or btnText:find("submit") then
                        child.MouseButton1Click:Fire()
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Fungsi ngetik kata dengan mode tertentu
local function ketikKata(kata)
    kata = string.upper(kata)
    local speed = typingSpeed[currentMode]
    
    for i = 1, #kata do
        local huruf = string.sub(kata, i, i)
        if not klikHuruf(huruf) then
            warn("Tombol " .. huruf .. " tidak ditemukan!")
            return false
        end
        
        -- Delay sesuai mode
        if currentMode == "NATURAL" then
            -- Variasi kecepatan ala manusia
            local delay = speed.min + math.random() * (speed.max - speed.min)
            task.wait(delay)
        else
            -- FAST: konsisten cepat
            task.wait(speed.min)
        end
    end
    
    -- Klik Masuk
    task.wait(currentMode == "NATURAL" and 0.2 or 0.05)
    klikMasuk()
    
    return true
end

-- Fungsi cari kata yang cocok
local function cariKataCocok(hurufAwal)
    local candidates = {}
    
    for _, word in ipairs(wordList) do
        local wordUpper = string.upper(word)
        if string.sub(wordUpper, 1, 1) == hurufAwal and not usedWords[word] then
            table.insert(candidates, word)
        end
    end
    
    if #candidates > 0 then
        -- Pilih kata terpanjang? Atau random?
        table.sort(candidates, function(a, b) return #a > #b end)
        return candidates[1] -- Ambil yang terpanjang
    end
    return nil
end

-- Update daftar kata di UI
local function updateWordList()
    for _, child in pairs(wordContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local count = 0
    for _, word in ipairs(wordList) do
        count = count + 1
        if count > 50 then break end -- Batasi tampilan
        
        local btn = Instance.new("TextButton")
        btn.Parent = wordContainer
        btn.Size = UDim2.new(1, -5, 0, 25)
        btn.BackgroundColor3 = (usedWords[word] and Color3.fromRGB(30, 30, 50)) or Color3.fromRGB(45, 45, 55)
        btn.Text = (usedWords[word] and "✓ " or "") .. string.upper(word)
        btn.TextColor3 = (usedWords[word] and Color3.fromRGB(100, 100, 255)) or Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 5)
        
        btn.MouseButton1Click:Connect(function()
            if not usedWords[word] then
                usedWords[word] = true
                ketikKata(word)
                updateWordList()
            end
        end)
    end
    
    wordContainer.CanvasSize = UDim2.new(0, 0, 0, count * 28)
end

-- Main loop auto-type
local function autoTypeLoop()
    while isActive do
        local hurufAwal = deteksiHurufAwal()
        
        if hurufAwal then
            local kata = cariKataCocok(hurufAwal)
            
            if kata then
                usedWords[kata] = true
                ketikKata(kata)
                updateWordList()
            end
        end
        
        -- Cek setiap 1 detik
        for i = 1, 10 do
            if not isActive then break end
            task.wait(0.1)
        end
    end
end

-- ==================== EVENT HANDLERS ====================

-- Start/Stop button
startStopBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    if isActive then
        startStopBtn.Text = "⏸️ STOP"
        startStopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        autoStatusLabel.Text = "▶️ AUTO-TYPE: ON"
        autoStatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        task.spawn(autoTypeLoop)
    else
        startStopBtn.Text = "⏯️ START"
        startStopBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
        autoStatusLabel.Text = "⏸️ AUTO-TYPE: OFF"
        autoStatusLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
    end
end)

-- Mode button
modeButton.MouseButton1Click:Connect(function()
    currentMode = (currentMode == "NATURAL" and "FAST" or "NATURAL")
    modeButton.Text = currentMode
    
    if currentMode == "NATURAL" then
        modeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    else
        modeButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    end
end)

-- Reset button
resetBtn.MouseButton1Click:Connect(function()
    usedWords = {}
    updateWordList()
    hurufLabel.Text = "🔍 HURUF AWAL: [BELUM TERDETEKSI]"
end)

-- Load more button
loadMoreBtn.MouseButton1Click:Connect(function()
    currentPage = currentPage + 1
    -- Implementasi load more dari wordlist
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    local isMinimized = mainFrame.Size == UDim2.new(0, 250, 0, 45)
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 250, 0, 400)
        contentContainer.Visible = true
        closeButton.Text = "−"
    else
        mainFrame.Size = UDim2.new(0, 250, 0, 45)
        contentContainer.Visible = false
        closeButton.Text = "+"
    end
end)

-- Load wordlist dari URL
task.spawn(function()
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/ZenoScripter/Script/refs/heads/main/Sambung%20Kata%20(%20indo%20)/wordlist_kbbi.lua")
    end)
    
    if success then
        for line in string.gmatch(response, "[^\r\n]+") do
            local word = string.match(line, "([%a%-]+)")
            if word and #word > 1 then
                table.insert(wordList, string.lower(word))
            end
        end
        updateWordList()
    end
end)

-- RGB animation loop
task.spawn(function()
    while true do
        rgbHue = (rgbHue + 0.002) % 1
        local rgbColor = Color3.fromHSV(rgbHue, 0.9, 1)
        mainStroke.Color = rgbColor
        
        -- Update FPS dan Ping
        local fps = 1 / (tick() - startTime)
        startTime = tick()
        fpsLabel.Text = "⚡ FPS: " .. math.floor(fps)
        pingLabel.Text = "📶 PING: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"
        
        task.wait(0.03)
    end
end)

-- Inisialisasi
updateWordList()
