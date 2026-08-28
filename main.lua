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
Tabs.Roll:AddParagraph({
    Title = "Auto Roll & Buy Target",
    Content = "Otomatis Roll dan langsung beli karakter impian kamu!"
})

local TargetCharacter = "All"

-- 1. SCAN SEMUA KARAKTER OTOMATIS DARI REPLICATEDSTORAGE
local characterList = {"All"}
pcall(function()
    local charFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Assets") and game:GetService("ReplicatedStorage").Assets:FindFirstChild("Characters")
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

ToggleAutoRoll:OnChanged(function(State)
    if State then
        task.spawn(function()
            while ToggleAutoRoll.Value do
                -- Step 1: Fire Roll Remote
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.Characters.Roll:FireServer()
                end)
                
                -- Jeda untuk spawn
                task.wait(0.4)
                
                -- Step 2: Cek ProximityPrompt di Pod/Podium buat Auto Buy
                pcall(function()
                    for _, prompt in pairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Name == "BuyPrompt" then
                            local charModel = prompt.Parent and prompt.Parent.Parent
                            local shouldBuy = false

                            if charModel then
                                if TargetCharacter == "All" or string.find(charModel.Name:lower(), TargetCharacter:lower()) then
                                    shouldBuy = true
                                end
                            else
                                shouldBuy = true
                            end

                            if shouldBuy then
                                local firePrompt = fireproximityprompt or (debug and debug.getupvalue)
                                if fireproximityprompt then
                                    fireproximityprompt(prompt)
                                elseif prompt.InputHoldBegin then
                                    prompt:InputHoldBegin()
                                    prompt:InputHoldEnd()
                                end
                            end
                        end
                    end
                end)
                
                task.wait(0.3)
            end
        end)
    end
end)

-- ========================================================
--                NOTIFIKASI SAAT SUCCESS LOAD
-- ========================================================
Fluent:Notify({
    Title = "OP65HUB Active!",
    Content = "Script Anime Fight berhasil di-load.",
    Duration = 5
})