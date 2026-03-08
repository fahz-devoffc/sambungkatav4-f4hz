--[[ 
    FAHZHUB | SAMBUNG KATA V4 - EXPLOIT EDITION
    - Kirim langsung ke server via RemoteEvent
    - Dual mode dengan timing realistis
    - Auto-reset wordlist
    - Wordlist dari GitHub pribadi
    - UI minimalis, DRAGGABLE, dan ada MINIMIZE
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==================== KONFIGURASI ====================
local wordList = {}        -- Semua kata dari URL
local usedWords = {}        -- Kata yang udah dipake
local Mode = "Natural"      -- Natural / Fast
local isActive = false      -- Status auto-type
local isMinimized = false   -- Status minimize
local currentWordIndex = 1  -- Index kata yang akan dipake
local startTime = tick()

-- URL wordlist lo
local WORDLIST_URL = "https://raw.githubusercontent.com/fahz-devoffc/kbbi.txt/refs/heads/main/kamus%20besar/kbbi.lua"

-- ==================== FUNGSI CORE ====================

-- Fungsi submit langsung ke server (EXPLOIT INI!)
local function AutoSubmit(kata)
    -- Cari remote event KirimKata
    local remote = ReplicatedStorage:FindFirstChild("KirimKata", true)
    
    if remote then
        -- KIRIM LANGSUNG KE SERVER! Gak perlu ngetik manual
        remote:FireServer(kata)
        return true
    else
        -- Fallback: pake chat system kalo remote gak ada
        local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatRemote then
            local sayRequest = chatRemote:FindFirstChild("SayMessageRequest")
            if sayRequest then
                sayRequest:FireServer(kata, "All")
                return true
            end
        end
    end
    return false
end

-- Fungsi logic mode
local function SubmitWithMode(kata)
    if Mode == "Natural" then
        -- Jeda acak 2-4 detik (simulasi mikir)
        local jeda = math.random(200, 400) / 100
        task.wait(jeda)
        AutoSubmit(kata)
    else -- Fast mode
        -- Langsung kirim tanpa jeda
        AutoSubmit(kata)
    end
end

-- Reset kata yang udah dipake
local function ResetUsedWords()
    -- Method 1: pake table.clear (kalo environment support)
    if table.clear then
        table.clear(usedWords)
    else
        -- Method 2: manual
        usedWords = {}
    end
    currentWordIndex = 1
    print("✅ Reset Done - Semua kata siap dipake lagi")
end

-- Cari kata yang belum dipake berdasarkan huruf awal
local function FindUnusedWord(hurufAwal)
    hurufAwal = string.upper(hurufAwal)
    
    -- Cari kata dengan huruf awal yang sesuai dan belum dipake
    for i = currentWordIndex, #wordList do
        local kata = wordList[i]
        local kataUpper = string.upper(kata)
        
        if string.sub(kataUpper, 1, 1) == hurufAwal and not usedWords[kata] then
            usedWords[kata] = true
            currentWordIndex = i + 1
            return kata
        end
    end
    
    -- Kalo udah keabisan, reset index
    for i = 1, currentWordIndex - 1 do
        local kata = wordList[i]
        local kataUpper = string.upper(kata)
        
        if string.sub(kataUpper, 1, 1) == hurufAwal and not usedWords[kata] then
            usedWords[kata] = true
            currentWordIndex = i + 1
            return kata
        end
    end
    
    return nil -- Gak ada kata yang cocok
end

-- Deteksi huruf awal dari UI game
local function DetectHurufAwal()
    -- Coba cari di semua GUI
    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, child in pairs(gui:GetDescendants()) do
                if child:IsA("TextLabel") then
                    local text = child.Text or ""
                    -- Cari pola "Hurufnya adalah: X" atau "Huruf: X"
                    local match = string.match(text, "Huruf.-:.-(%a)")
                    if match then
                        return string.upper(match)
                    end
                end
            end
        end
    end
    return nil
end

-- Main loop auto-type
local function AutoTypeLoop()
    while isActive do
        local hurufAwal = DetectHurufAwal()
        
        if hurufAwal then
            local kata = FindUnusedWord(hurufAwal)
            
            if kata then
                print("📤 Mengirim: " .. kata .. " (Huruf: " .. hurufAwal .. ")")
                SubmitWithMode(kata)
            else
                print("⚠️ Gak ada kata untuk huruf " .. hurufAwal)
                task.wait(1)
            end
        else
            -- Kalo gak ketemu huruf, tunggu bentar
            task.wait(0.5)
        end
        
        -- Cek setiap 0.5 detik (bisa diatur)
        task.wait(0.5)
    end
end

-- ==================== LOAD WORDLIST ====================
print("📥 Loading wordlist dari GitHub...")

local success, response = pcall(function()
    return game:HttpGet(WORDLIST_URL)
end)

if success then
    -- Parse wordlist (format bisa disesuaikan)
    for line in string.gmatch(response, "[^\r\n]+") do
        -- Bersihin line dari karakter aneh
        local kata = string.match(line, "([%a%s%-]+)")
        if kata then
            kata = string.gsub(kata, "%s+", "") -- Hapus spasi
            if #kata > 1 then -- Minimal 2 huruf
                table.insert(wordList, string.lower(kata))
            end
        end
    end
    
    print("✅ Loaded " .. #wordList .. " kata!")
else
    print("❌ Gagal load wordlist! Pake contoh kata...")
    -- Fallback wordlist
    wordList = {
        "aku", "kamu", "dia", "mereka", "kami", "kalian",
        "makan", "minum", "tidur", "jalan", "lari", "duduk",
        "besar", "kecil", "panjang", "pendek", "tinggi", "rendah",
        "merah", "biru", "hijau", "kuning", "hitam", "putih",
        "rumah", "sekolah", "kantor", "pasar", "toko", "gedung"
    }
end

-- ==================== UI DENGAN DRAG & MINIMIZE ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FahzHub_V4"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME - BISA DI-DRAG!
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.Position = UDim2.new(0.5, -150, 0.4, -75)
mainFrame.Size = UDim2.new(0, 300, 0, 180)  -- Ukuran normal
mainFrame.Active = true
mainFrame.Draggable = true  -- <--- INI DIA! BISA DI-DRAG!
mainFrame.BackgroundTransparency = 0.1
mainFrame.ClipsDescendants = true

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

local uiStroke = Instance.new("UIStroke", mainFrame)
uiStroke.Thickness = 1.5
uiStroke.Color = Color3.fromRGB(80, 80, 200)
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- TITLE BAR (buat drag area)
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.ZIndex = 2

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Parent = titleBar
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 0)
title.Size = UDim2.new(1, -50, 1, 0)
title.Text = "⚡ FAHZHUB V4 - EXPLOIT"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left

-- TOMBOL MINIMIZE (+/-)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = titleBar
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Position = UDim2.new(1, -30, 0, 5)
minimizeBtn.Size = UDim2.new(0, 20, 0, 20)
minimizeBtn.Text = "−"  -- Simbol minus
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.ZIndex = 3

-- CONTENT FRAME (yang bakal dihide kalo minimize)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Parent = mainFrame
contentFrame.BackgroundTransparency = 1
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.ClipsDescendants = true

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = contentFrame
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 10, 0, 5)
statusLabel.Size = UDim2.new(0.5, -5, 0, 20)
statusLabel.Text = "⏸️ STOPPED"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Mode label
local modeLabel = Instance.new("TextLabel")
modeLabel.Parent = contentFrame
modeLabel.BackgroundTransparency = 1
modeLabel.Position = UDim2.new(0.5, 0, 0, 5)
modeLabel.Size = UDim2.new(0.5, -10, 0, 20)
modeLabel.Text = "MODE: NATURAL"
modeLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
modeLabel.Font = Enum.Font.Gotham
modeLabel.TextSize = 12
modeLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Tombol START/STOP
local startBtn = Instance.new("TextButton")
startBtn.Parent = contentFrame
startBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
startBtn.Position = UDim2.new(0, 10, 0, 30)
startBtn.Size = UDim2.new(0.5, -5, 0, 30)
startBtn.Text = "▶️ START"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 12

local startCorner = Instance.new("UICorner", startBtn)
startCorner.CornerRadius = UDim.new(0, 5)

-- Tombol RESET
local resetBtn = Instance.new("TextButton")
resetBtn.Parent = contentFrame
resetBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
resetBtn.Position = UDim2.new(0.5, 5, 0, 30)
resetBtn.Size = UDim2.new(0.5, -10, 0, 30)
resetBtn.Text = "🔄 RESET"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 12

local resetCorner = Instance.new("UICorner", resetBtn)
resetCorner.CornerRadius = UDim.new(0, 5)

-- Tombol SWITCH MODE
local modeBtn = Instance.new("TextButton")
modeBtn.Parent = contentFrame
modeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
modeBtn.Position = UDim2.new(0, 10, 0, 70)
modeBtn.Size = UDim2.new(1, -20, 0, 30)
modeBtn.Text = "🔁 SWITCH MODE (NATURAL)"
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 12

local modeCorner = Instance.new("UICorner", modeBtn)
modeCorner.CornerRadius = UDim.new(0, 5)

-- Stats label
local statsLabel = Instance.new("TextLabel")
statsLabel.Parent = contentFrame
statsLabel.BackgroundTransparency = 1
statsLabel.Position = UDim2.new(0, 10, 0, 110)
statsLabel.Size = UDim2.new(1, -20, 0, 20)
statsLabel.Text = "📊 Total Kata: " .. #wordList .. " | Terpakai: 0"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.Font = Enum.Font.Code
statsLabel.TextSize = 10
statsLabel.TextXAlignment = Enum.TextXAlignment.Center

-- ==================== EVENT HANDLERS ====================

-- MINIMIZE FUNCTION
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Mode minimize: kecilin frame, hide content
        mainFrame.Size = UDim2.new(0, 300, 0, 30)  -- Tinggal title bar doang
        contentFrame.Visible = false
        minimizeBtn.Text = "+"  -- Simbol plus
    else
        -- Mode normal: balikin ukuran, show content
        mainFrame.Size = UDim2.new(0, 300, 0, 180)
        contentFrame.Visible = true
        minimizeBtn.Text = "−"  -- Simbol minus
    end
end)

-- START/STOP button
startBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    
    if isActive then
        startBtn.Text = "⏸️ STOP"
        startBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "▶️ RUNNING"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Mulai loop auto-type di thread terpisah
        task.spawn(AutoTypeLoop)
    else
        startBtn.Text = "▶️ START"
        startBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
        statusLabel.Text = "⏸️ STOPPED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- RESET button
resetBtn.MouseButton1Click:Connect(function()
    ResetUsedWords()
    statsLabel.Text = "📊 Total Kata: " .. #wordList .. " | Terpakai: 0"
    print("✅ Script di-reset")
end)

-- MODE button
modeBtn.MouseButton1Click:Connect(function()
    if Mode == "Natural" then
        Mode = "Fast"
        modeBtn.Text = "🔁 SWITCH MODE (FAST)"
        modeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        modeLabel.Text = "MODE: FAST"
        modeLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
    else
        Mode = "Natural"
        modeBtn.Text = "🔁 SWITCH MODE (NATURAL)"
        modeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
        modeLabel.Text = "MODE: NATURAL"
        modeLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    end
end)

-- Update stats setiap detik
task.spawn(function()
    while true do
        local usedCount = 0
        for _, v in pairs(usedWords) do
            if v then usedCount = usedCount + 1 end
        end
        
        statsLabel.Text = "📊 Total Kata: " .. #wordList .. " | Terpakai: " .. usedCount
        task.wait(1)
    end
end)

print("✅ FAHZHUB V4 LOADED! Mode: " .. Mode .. " | Draggable: YES | Minimize: YES")
