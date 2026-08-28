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

local TargetCharacter = "All"
local CurrentRollId = nil
local CurrentCharacters = {}

RemoteRoll.OnClientEvent:Connect(function(player, base, charData, delayTime, rollId)
    if player == game.Players.LocalPlayer then
        CurrentRollId = rollId
        CurrentCharacters = charData
    end
end)

-- 1. SCAN SEMUA KARAKTER OTOMATIS DARI REPLICATEDSTORAGE
local characterList = {"All"}
pcall(function()
    local charFolder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Characters")
    if charFolder then
        for _, char in pairs(charFolder:GetChildren()) do
            table.insert(characterList, char.Name)
        end
        table.sort(characterList)
    end
end)

-- 2. DROPDOWN (PILIH KARAKTER IMPIAN)
local TargetDropdown = Tabs.Roll:AddDropdown("TargetSelect", {
    Title = "Pilih Karakter Impian",
    Values = characterList,
    Default = "All",
})

TargetDropdown:OnChanged(function(Value)
    TargetCharacter = Value
end)

-- 3. TOGGLE AUTO ROLL & BUY
local ToggleAutoRoll = Tabs.Roll:AddToggle("AutoRollTarget", {Title = "Mulai Auto Roll & Buy", Default = false })

ToggleAutoRoll:OnChanged(function(Value)
    task.spawn(function()
        while ToggleAutoRoll.Value do
            CurrentRollId = nil
            CurrentCharacters = nil

            -- Trigger Roll
            pcall(function()
                RemoteRoll:FireServer()
            end)
            
            task.wait(0.35)
            
            local foundSlot = nil
            
            -- Cek Karakter
            if CurrentRollId and CurrentCharacters then
                for slotIndex, charInfo in pairs(CurrentCharacters) do
                    local charName = charInfo.Name or ""
                    
                    if TargetCharacter == "All" then
                        foundSlot = slotIndex
                        break
                    elseif charName == TargetCharacter or string.find(charName:lower(), TargetCharacter:lower()) then
                        foundSlot = slotIndex
                        break
                    end
                end
            end

            -- Eksekusi Beli jika cocok
            if foundSlot and CurrentRollId then
                task.wait(0.5)

                for i = 1, 5 do
                    pcall(function()
                        RemoteBuy:FireServer(CurrentRollId, foundSlot)
                    end)
                    task.wait(0.08)
                end
                
                task.wait(0.4)
            else
                task.wait(0.15)
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