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
    Content = "Otomatis Roll via Remote Storage (Bisa dari mana saja & Aman)!"
})

local TargetCharacter = "All"
local AutoRollActive = false

-- 1. DROPDOWN TARGET
local TargetDropdown = Tabs.Roll:AddDropdown("TargetSelect", {
    Title = "Pilih Karakter Impian",
    Values = {
        "All",
        "Choji",
        "Sakamoto", 
        "Saitama", 
        "Madara", 
        "Goku", 
        "Gojo", 
        "Sukuna", 
        "Ussop"
    },
    Default = "Choji",
})

TargetDropdown:OnChanged(function(Value)
    TargetCharacter = Value
end)

-- 2. TOGGLE AUTO ROLL & BUY
local ToggleAutoRoll = Tabs.Roll:AddToggle("AutoRollTarget", {Title = "Mulai Auto Roll & Buy", Default = false })

ToggleAutoRoll:OnChanged(function(State)
    AutoRollActive = State
    
    if AutoRollActive then
        task.spawn(function()
            while AutoRollActive do
                -- Step 1: Fire Remote Roll Asli (Bisa dari jarak jauh)
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.Characters.Roll:FireServer()
                end)
                
                -- Step 2: Jeda Cooldown Server (1.8 Detik)
                task.wait(1.8)
                
                -- Step 3: Auto Buy Karakter jika sesuai Target
                if AutoRollActive then
                    pcall(function()
                        for _, prompt in pairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Name == "BuyPrompt" then
                                local charModel = prompt.Parent and prompt.Parent.Parent
                                if charModel then
                                    local cName = charModel.Name:lower()
                                    if TargetCharacter == "All" or string.find(cName, TargetCharacter:lower()) then
                                        fireproximityprompt(prompt)
                                        task.wait(0.2)
                                    end
                                end
                            end
                        end
                    end)
                end
                
                task.wait(0.2)
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