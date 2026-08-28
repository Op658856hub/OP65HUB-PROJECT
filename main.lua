-- ========================================================
--                OP65HUB - ANIME FIGHTING
-- ========================================================

-- 1. LOAD UI LIBRARY (Fluent UI - Tampilan Modern & Rapi)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- 2. BIKIN WINDOW UTAMA OP65HUB
local Window = Fluent:CreateWindow({
    Title = "OP65HUB | Anime Fight",
    SubTitle = "by OP65 Guild",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Darker",
    Acrylic = true -- Efek transparan kaca
})

-- 3. BIKIN TAB MENU
local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "rbxassetid://6031280882" }),
    Roll = Window:AddTab({ Title = "Auto Roll", Icon = "rbxassetid://6031265976" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- ========================================================
--                    VARIABLE / STATE
-- ========================================================
local Toggles = {}

-- ========================================================
--                FITUR TAB 1: MAIN FARM
-- ========================================================
Tabs.Main:AddParagraph({
    Title = "Auto Farm Section",
    Content = "Fitur otomatisasi untuk meningkatkan stats karakter lu."
})

-- Toggle Auto Click / Attack
local ToggleClick = Tabs.Main:AddToggle("AutoClick", {Title = "Auto Click / Attack", Default = false })
ToggleClick:OnChanged(function()
    Toggles.AutoClick = Fluent.Options.AutoClick.Value
    task.spawn(function()
        while Toggles.AutoClick do
            -- ISI KODE REMOTE ATTACK GAME DISINI
            -- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Attack"):FireServer()
            task.wait(0.1)
        end
    end)
end)

-- ========================================================
--                FITUR TAB 2: AUTO ROLL
-- ========================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteRoll = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Characters"):WaitForChild("Roll")
local RemoteBuy = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Characters"):WaitForChild("Buy")

Tabs.Roll:AddParagraph({
    Title = "Auto Roll & Buy Target",
    Content = "Otomatis Roll dan langsung beli karakter impian kamu!"
})

local TargetCharacter = "Saitomo"
local CurrentRollId = nil
local CurrentCharacters = {}

RemoteRoll.OnClientEvent:Connect(function(player, base, charData, delayTime, rollId)
    if player == game.Players.LocalPlayer then
        CurrentRollId = rollId
        CurrentCharacters = charData
    end
end)

local TargetDropdown = Tabs.Roll:AddDropdown("TargetSelect", {
    Title = "Pilih Karakter Impian",
    Values = {"Saitomo", "Mobi", "Zero", "Luppi", "Shikamura"}, 
    Default = "Saitomo",
})

TargetDropdown:OnChanged(function(Value)
    TargetCharacter = Value
end)

-- KODE BARU (SUDAH FIX ERROR OPTIONS):
local ToggleAutoRoll = Tabs.Roll:AddToggle("AutoRollTarget", {Title = "Mulai Auto Roll & Buy", Default = false })

ToggleAutoRoll:OnChanged(function(Value)
    task.spawn(function()
        while ToggleAutoRoll.Value do
            CurrentRollId = nil
            CurrentCharacters = nil

            -- 1. Trigger Roll
            pcall(function()
                RemoteRoll:FireServer()
            end)
            
            -- Wait balasan server
            task.wait(0.4)
            
            -- 2. Cek apakah ada target di hasil roll ini
            local foundTarget = false
            local targetSlot = nil
            
            if CurrentRollId and CurrentCharacters then
                for slotIndex, charInfo in pairs(CurrentCharacters) do
                    if charInfo.Name == TargetCharacter or TargetCharacter == "All" then
                        foundTarget = true
                        targetSlot = slotIndex
                        break
                    end
                end
            end

            -- 3. Eksekusi Pembelian Jika Target Ditemukan
            if foundTarget and CurrentRollId and targetSlot then
                -- Tunggu delay cooldown internal server (0.6s)
                task.wait(0.6) 

                -- Tembak RemoteBuy berulang kali agar pasti terdaftar
                for i = 1, 5 do
                    pcall(function()
                        RemoteBuy:FireServer(CurrentRollId, targetSlot)
                    end)
                    task.wait(0.1)
                end
                
                task.wait(0.5)
            else
                task.wait(0.2)
            end
        end
    end)
end)

-- ========================================================
--                NOTIFIKASI SAAT SUCCESS LOAD
-- ========================================================
Fluent:Notify({
    Title = "OP65HUB Active!",
    Content = "Script Anime Fight berhasil di-load.",
    Duration = 5
})