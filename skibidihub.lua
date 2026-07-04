-- ============================================================
-- SKIBIDI HUB PREMIUM - PHẦN 1
-- KHỞI TẠO + SERVICES + BIẾN TOÀN CỤC
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ChatService = game:GetService("Chat")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- ============================================================
-- BIẾN TOÀN CỤC
-- ============================================================
local Settings = {
    Farm = { Enabled = false, Mode = "Normal", Distance = 200, Delay = 500, MultiTarget = false },
    Quest = { Enabled = false, NPC = "Monkey", AutoTurnIn = false, AutoAccept = false, StopLevel = 2550 },
    Combat = { KillAura = false, Range = 150, AutoAim = false, AutoDodge = false, AutoCombo = false },
    Haki = { Enabled = false, Ken = false },
    Stats = { Enabled = false, Type = "Melee", Points = 10, AutoAssign = false },
    ESP = { Player = false, Fruit = false, Chest = false, NPC = false, Boss = false, Color = Color3.new(1,0,0), Range = 500 },
    Teleport = { Target = nil },
    Raid = { Enabled = false, Type = "Flame", AutoBuyChip = false, AutoAwaken = false, StopFragments = 10000 },
    Sea = { SeaBeast = false, Leviathan = false, TerrorShark = false, Prehistoric = false, Mirage = false, FullMoon = false, SharkAnchor = false },
    Boss = { Enabled = false },
    Fruit = { Sniper = false, AutoBuy = false, AutoStore = false, AutoEat = false, Priority = "All" },
    Misc = { NoClip = false, Tween = false, WalkWater = false, NoCooldown = false, AntiBan = false, FPSBoost = false, AutoCollect = false, AutoReset = false, AutoHop = false },
    Player = { AntiAFK = false, Spectate = false },
    Shop = { AutoBuyFighting = false, AutoBuySword = false, AutoBuyAbility = false, AutoBuyEnhancement = false, AutoBuyAccessories = false, AutoBuyMaterials = false, MaterialToBuy = "Scrap Metal", BuyAmount = 10 },
    Dungeon = { AutoEnter = false, AutoClear = false, Type = "Cave" },
    Webhook = { Enabled = false, URL = "", Interval = 600 },
    Race = { AutoV2 = false, AutoV3 = false, AutoV4 = false, AutoBuyGear = false, RaceTracker = false, SelectedRace = "Human" },
    Materials = { AutoFarm = false, Type = "Scrap Metal", Target = 100, AutoSellExcess = false },
    Main = { AutoLevel = false, AutoMastery = false, MasteryTarget = 300, AutoBone = false, AutoFrag = false, AutoEcto = false, AutoDarkFrag = false }
}

local ServerStartTime = os.time()
local PlayerData = {}
local ESPObjects = {}
local RunningCoroutines = {}

-- ============================================================
-- HÀM LOG
-- ============================================================
local function log(msg, level)
    level = level or "INFO"
    print(string.format("[Skibidi] [%s] %s", level, msg))
end

-- ============================================================
-- HÀM XỬ LÝ LỖI
-- ============================================================
local function safeCall(func)
    pcall(func)
end

-- ============================================================
-- HÀM LẤY DỮ LIỆU NGƯỜI CHƠI
-- ============================================================
local function updatePlayerData()
    safeCall(function()
        local data = {}
        local pd = LP:FindFirstChild("Data")
        if pd then
            data.Level = pd:FindFirstChild("Level") and pd.Level.Value or 0
            data.Exp = pd:FindFirstChild("Exp") and pd.Exp.Value or 0
            data.MaxExp = pd:FindFirstChild("MaxExp") and pd.MaxExp.Value or 1
            data.Beli = pd:FindFirstChild("Beli") and pd.Beli.Value or 0
            data.Fragment = pd:FindFirstChild("Fragment") and pd.Fragment.Value or 0
            data.KenLevel = pd:FindFirstChild("KenLevel") and pd.KenLevel.Value or 0
            data.Race = pd:FindFirstChild("Race") and pd.Race.Value or "N/A"
        end
        data.EliteProgress = getgenv().EliteProgress or 0
        data.CakeKills = getgenv().CakePrinceKills or 0
        data.MysticIsland = Workspace:FindFirstChild("MysticIsland") ~= nil
        data.PrehistoricIsland = Workspace:FindFirstChild("PrehistoricIsland") ~= nil
        data.DragonEvent = Workspace:FindFirstChild("DragonEvent") ~= nil
        data.MoonPhase = Lighting:GetMoonPhase() and math.floor(Lighting:GetMoonPhase() * 8) + 1 or 0
        data.MoonTime = getgenv().MoonTime or 0
        data.RaidLevel = getgenv().RaidLevel or 0
        data.RaidMaxLevel = getgenv().RaidMaxLevel or 10
        data.RaidFragments = getgenv().RaidFragments or 0
        data.RaceV4Unlocked = getgenv().RaceV4Unlocked or false
        data.RaceV4Progress = getgenv().RaceV4Progress or 0
        data.LastFruitSpawn = getgenv().LastFruitSpawn or "None"
        data.SpyTrade = getgenv().CanTrade or false
        data.PullLevel = getgenv().PullLevel or false
        data.LeviathanActive = getgenv().LeviathanActive or false
        data.TerrorSharkActive = getgenv().TerrorSharkActive or false
        data.FruitSniperActive = getgenv().FruitSniperActive or false
        data.AutoStatsActive = getgenv().AutoStatsActive or false
        data.CurrentStatBuild = getgenv().CurrentStatBuild or "Melee"
        data.AntiBanActive = getgenv().AntiBanActive or false
        data.BanRisk = getgenv().BanRisk or "Low"
        data.NoCooldownActive = getgenv().NoCooldownActive or false
        PlayerData = data
    end)
end

-- ============================================================
-- HÀM TELEPORT
-- ============================================================
local function teleportTo(pos, tween)
    safeCall(function()
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        if tween and Settings.Misc.Tween then
            TweenService:Create(hrp, TweenInfo.new(1), {CFrame = CFrame.new(pos)}):Play()
        else
            hrp.CFrame = CFrame.new(pos)
        end
    end)
end

-- ============================================================
-- HÀM LẤY OBJECT GẦN NHẤT
-- ============================================================
local function getNearestObject(folder, filter)
    local nearest, minDist = nil, math.huge
    safeCall(function()
        local container = Workspace:FindFirstChild(folder)
        if not container then return end
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local rootPos = char.HumanoidRootPart.Position
        for _, obj in ipairs(container:GetChildren()) do
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj
            if hrp and hrp:IsA("BasePart") then
                if filter and not filter(obj) then continue end
                local dist = (hrp.Position - rootPos).magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end)
    return nearest, minDist
end

local function getNearestEnemy()
    return getNearestObject("Enemies", function(o)
        return o:FindFirstChild("Humanoid") and o.Humanoid.Health > 0
    end)
end

local function getNearestBoss()
    return getNearestObject("Bosses", function(o)
        return o:FindFirstChild("Humanoid") and o.Humanoid.Health > 0
    end)
end

local function getNearestNPC(name)
    return getNearestObject("NPCs", function(o)
        return name and o.Name:find(name) or true
    end)
end

local function getNearestChest()
    return getNearestObject("Chests", function(o)
        return o:IsA("BasePart") and o:FindFirstChild("TouchInterest")
    end)
end

local function getNearestFruit()
    local nearest, minDist = nil, math.huge
    safeCall(function()
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local rootPos = char.HumanoidRootPart.Position
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:find("Fruit") or obj.Name:find("fruit") or obj.Name == "Fruit ") then
                local dist = (obj.Position - rootPos).magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end)
    return nearest, minDist
end

local function getNearestPlayer()
    local nearest, minDist = nil, math.huge
    safeCall(function()
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local rootPos = char.HumanoidRootPart.Position
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local pChar = plr.Character
                if pChar and pChar:FindFirstChild("HumanoidRootPart") then
                    local dist = (pChar.HumanoidRootPart.Position - rootPos).magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = pChar
                    end
                end
            end
        end
    end)
    return nearest, minDist
end
-- ============================================================
-- PHẦN 2: HÀM TẤN CÔNG + TƯƠNG TÁC
-- ============================================================

-- === HÀM TẤN CÔNG ===
local function attack(target)
    safeCall(function()
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
        if hrp then
            char.HumanoidRootPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 0, 5))
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            wait(Settings.Farm.Delay / 1000)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end)
end

-- === HÀM TẤN CÔNG BẰNG KỸ NĂNG ===
local function attackWithSkill(skillKey)
    safeCall(function()
        VirtualInputManager:SendKeyEvent(true, skillKey, false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, skillKey, false, game)
    end)
end

-- === HÀM TẤN CÔNG BẰNG SÚNG ===
local function shootGun()
    safeCall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- === HÀM TƯƠNG TÁC NPC ===
local function interactNPC(npc)
    safeCall(function()
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
        if hrp then
            char.HumanoidRootPart.CFrame = CFrame.new(hrp.Position)
            wait(0.3)
            VirtualInputManager:SendKeyEvent(true, "E", false, game)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, "E", false, game)
        end
    end)
end

-- === HÀM KIỂM TRA COOLDOWN ===
local function checkCooldown(key, duration)
    if Cooldowns[key] and os.time() - Cooldowns[key] < duration then
        return true
    end
    Cooldowns[key] = os.time()
    return false
end

-- === HÀM DELAY NGẪU NHIÊN ===
local function randomDelay(min, max)
    return math.random(min, max) / 1000
end

-- === HÀM LẤY THÔNG TIN SERVER ===
local function getServerInfo()
    return {
        Players = #Players:GetPlayers(),
        MaxPlayers = game.Players.MaxPlayers
    }
end

-- === HÀM LẤY THỜI GIAN SERVER ===
local function getServerTime()
    local distTime = Workspace:FindFirstChild("DistributedGameTime")
    if distTime then
        local totalSec = distTime.Value
        return math.floor(totalSec / 60), math.floor(totalSec % 60)
    else
        local elapsed = os.difftime(os.time(), ServerStartTime)
        return math.floor(elapsed / 60), math.floor(elapsed % 60)
    end
end

-- === HÀM LẤY TRẠNG THÁI TRĂNG ===
local function getMoonPhase()
    local phase = Lighting:GetMoonPhase()
    if phase then
        return math.floor(phase * 8) + 1
    end
    return 0
end

-- === HÀM KIỂM TRA TRĂNG TRÒN ===
local function isFullMoon()
    return getMoonPhase() == 8
end

-- === HÀM LẤY LEVEL HIỆN TẠI ===
local function getCurrentLevel()
    return PlayerData.Level or 0
end

-- === HÀM LẤY EXP HIỆN TẠI ===
local function getCurrentExp()
    return PlayerData.Exp or 0
end

-- === HÀM LẤY MAX EXP ===
local function getMaxExp()
    return PlayerData.MaxExp or 1
end

-- === HÀM LẤY BELI ===
local function getBeli()
    return PlayerData.Beli or 0
end

-- === HÀM LẤY FRAGMENT ===
local function getFragment()
    return PlayerData.Fragment or 0
end

-- === HÀM LẤY RACE ===
local function getRace()
    return PlayerData.Race or "N/A"
end

-- === HÀM LẤY KEN LEVEL ===
local function getKenLevel()
    return PlayerData.KenLevel or 0
end

-- === HÀM LẤY ELITE PROGRESS ===
local function getEliteProgress()
    return PlayerData.EliteProgress or 0
end

-- === HÀM LẤY CAKE KILLS ===
local function getCakeKills()
    return PlayerData.CakeKills or 0
end

-- === HÀM LẤY RAID LEVEL ===
local function getRaidLevel()
    return PlayerData.RaidLevel or 0
end

-- === HÀM LẤY RAID FRAGMENTS ===
local function getRaidFragments()
    return PlayerData.RaidFragments or 0
end

-- === HÀM LẤY RACE V4 PROGRESS ===
local function getRaceV4Progress()
    return PlayerData.RaceV4Progress or 0
end

-- === CẬP NHẬT DỮ LIỆU ĐỊNH KỲ ===
spawn(function()
    while task.wait(5) do
        updatePlayerData()
    end
end)
-- ============================================================
-- PHẦN 3: TẠO WINDOW + TAB STATUS
-- ============================================================

-- === TẠO WINDOW ===
local Window = Rayfield:CreateWindow({
    Name = "Skibidi Hub Premium",
    LoadingTitle = "Skibidi Hub Premium",
    LoadingSubtitle = "by Skibidi Team | Dragon Update 2026",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SkibidiHub",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

-- ============================================================
-- TAB 1: STATUS
-- ============================================================
local StatusTab = Window:CreateTab("⌛ Status", nil)

-- Server Stats
StatusTab:CreateSection("📊 Server Stats")
local ServerTimeLabel = StatusTab:CreateLabel("⏱ Server Time: 0 Minute(s), 0 Second(s)")
local ServerPlayersLabel = StatusTab:CreateLabel("👥 Players: 0/" .. game.Players.MaxPlayers)

-- Player Stats
StatusTab:CreateSection("👤 Player Stats")
local LevelLabel = StatusTab:CreateLabel("📈 Level: 0")
local ExpLabel = StatusTab:CreateLabel("⭐ Exp: 0 / 0")
local BeliLabel = StatusTab:CreateLabel("💰 Beli: 0")
local FragLabel = StatusTab:CreateLabel("💎 Fragment: 0")
local RaceLabel = StatusTab:CreateLabel("🏁 Race: N/A")

-- Local Stats
StatusTab:CreateSection("📌 Local Stats")
local EliteLabel = StatusTab:CreateLabel("🎯 Elite Progress: 0")
local KenLabel = StatusTab:CreateLabel("👁 Ken Level: 0 / 5000")
local CakeLabel = StatusTab:CreateLabel("🎂 Cake Prince: 0 / 500")
local MysticLabel = StatusTab:CreateLabel("🏝️ Mystic Island: 🔴")
local MoonLabel = StatusTab:CreateLabel("🌙 Moon Status: Phase 0/8")
local PrehistoricLabel = StatusTab:CreateLabel("🦕 Prehistoric Island: 🔴")
local SpyLabel = StatusTab:CreateLabel("🕵️ Spy Status: Don't trade Yet")
local PullLabel = StatusTab:CreateLabel("💪 Pull level: 🔴")
local RaceTierLabel = StatusTab:CreateLabel("👑 Race Tier: N/A")

-- Dragon Update 2026
StatusTab:CreateSection("🐉 Dragon Update 2026")
local DragonLabel = StatusTab:CreateLabel("🐉 Dragon Event: 🔴")

-- Sea Events
StatusTab:CreateSection("🌊 Sea Events")
local LeviathanLabel = StatusTab:CreateLabel("🐋 Leviathan: 🔴")
local TerrorSharkLabel = StatusTab:CreateLabel("🦈 Terror Shark: 🔴")

-- Raid Progress
StatusTab:CreateSection("⚔️ Raid Progress")
local RaidLevelLabel = StatusTab:CreateLabel("⚔️ Raid Level: 0 / 10")
local RaidFragLabel = StatusTab:CreateLabel("💎 Raid Fragments: 0")

-- Race V4
StatusTab:CreateSection("👑 Race V4")
local RaceV4Label = StatusTab:CreateLabel("👑 Race V4 Unlocked: 🔴")
local RaceV4ProgLabel = StatusTab:CreateLabel("📈 Race V4 Progress: 0%")

-- Fruit System
StatusTab:CreateSection("🍎 Fruit System")
local FruitSniperLabel = StatusTab:CreateLabel("🍎 Fruit Sniper: 🔴")
local LastFruitLabel = StatusTab:CreateLabel("📦 Last Fruit Spawn: None")

-- Auto System
StatusTab:CreateSection("⚙️ Auto System")
local AutoStatsLabel = StatusTab:CreateLabel("📊 Auto Stats: 🔴")
local StatBuildLabel = StatusTab:CreateLabel("🛠️ Current Build: Melee")

-- Protection
StatusTab:CreateSection("🛡️ Protection")
local AntiBanLabel = StatusTab:CreateLabel("🛡️ Anti-Ban: 🔴")
local BanRiskLabel = StatusTab:CreateLabel("⚠️ Ban Risk: Low")
local NoCooldownLabel = StatusTab:CreateLabel("⏳ No Cooldown: 🔴")

-- === CẬP NHẬT STATUS ===
local startTime = os.time()
spawn(function()
    while task.wait(1) do
        safeCall(function()
            updatePlayerData()
            local d = PlayerData
            
            local minutes, seconds = getServerTime()
            ServerTimeLabel:Set(string.format("⏱ Server Time: %d Minute(s), %d Second(s)", minutes, seconds))
            local serverInfo = getServerInfo()
            ServerPlayersLabel:Set("👥 Players: " .. serverInfo.Players .. "/" .. serverInfo.MaxPlayers)
            
            LevelLabel:Set("📈 Level: " .. (d.Level or 0))
            ExpLabel:Set(string.format("⭐ Exp: %d / %d", d.Exp or 0, d.MaxExp or 1))
            BeliLabel:Set("💰 Beli: " .. (d.Beli or 0))
            FragLabel:Set("💎 Fragment: " .. (d.Fragment or 0))
            RaceLabel:Set("🏁 Race: " .. (d.Race or "N/A"))
            
            EliteLabel:Set("🎯 Elite Progress: " .. (d.EliteProgress or 0))
            KenLabel:Set(string.format("👁 Ken Level: %d / %d", d.KenLevel or 0, 5000))
            CakeLabel:Set(string.format("🎂 Cake Prince: %d / %d", d.CakeKills or 0, 500))
            MysticLabel:Set("🏝️ Mystic Island: " .. (d.MysticIsland and "🟢" or "🔴"))
            MoonLabel:Set(string.format("🌙 Moon Status: Phase %d/8", d.MoonPhase or 0))
            PrehistoricLabel:Set("🦕 Prehistoric Island: " .. (d.PrehistoricIsland and "🟢" or "🔴"))
            SpyLabel:Set("🕵️ Spy Status: " .. (d.SpyTrade and "Trade 🟢" or "Don't trade Yet"))
            PullLabel:Set("💪 Pull level: " .. (d.PullLevel and "🟢" or "🔴"))
            RaceTierLabel:Set("👑 Race Tier: " .. (d.Race or "N/A"))
            
            DragonLabel:Set("🐉 Dragon Event: " .. (d.DragonEvent and "🟢" or "🔴"))
            LeviathanLabel:Set("🐋 Leviathan: " .. (d.LeviathanActive and "🟢" or "🔴"))
            TerrorSharkLabel:Set("🦈 Terror Shark: " .. (d.TerrorSharkActive and "🟢" or "🔴"))
            RaidLevelLabel:Set(string.format("⚔️ Raid Level: %d / %d", d.RaidLevel or 0, d.RaidMaxLevel or 10))
            RaidFragLabel:Set("💎 Raid Fragments: " .. (d.RaidFragments or 0))
            RaceV4Label:Set("👑 Race V4 Unlocked: " .. (d.RaceV4Unlocked and "✅ Unlocked" or "🔴 Locked"))
            RaceV4ProgLabel:Set(string.format("📈 Race V4 Progress: %d%%", d.RaceV4Progress or 0))
            FruitSniperLabel:Set("🍎 Fruit Sniper: " .. (d.FruitSniperActive and "🟢 Active" or "🔴 Inactive"))
            LastFruitLabel:Set("📦 Last Fruit Spawn: " .. (d.LastFruitSpawn or "None"))
            AutoStatsLabel:Set("📊 Auto Stats: " .. (d.AutoStatsActive and "🟢 Active" or "🔴 Inactive"))
            StatBuildLabel:Set("🛠️ Current Build: " .. (d.CurrentStatBuild or "Melee"))
            AntiBanLabel:Set("🛡️ Anti-Ban: " .. (d.AntiBanActive and "🟢 Active" or "🔴 Inactive"))
            BanRiskLabel:Set("⚠️ Ban Risk: " .. (d.BanRisk or "Low"))
            NoCooldownLabel:Set("⏳ No Cooldown: " .. (d.NoCooldownActive and "🟢 Active" or "🔴 Inactive"))
        end)
    end
end)
-- ============================================================
-- PHẦN 4: TAB AUTO FARM
-- ============================================================

-- === TAB: AUTO FARM ===
local FarmTab = Window:CreateTab("⚙ Auto Farm", nil)

FarmTab:CreateSection("🎯 Main")
FarmTab:CreateToggle({
    Name = "Auto Farm Level",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(v)
        Settings.Farm.Enabled = v
        if v then
            spawn(function()
                while Settings.Farm.Enabled do
                    safeCall(function()
                        local enemy = getNearestEnemy()
                        if enemy then
                            attack(enemy)
                        else
                            local char = LP.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.Humanoid:MoveTo(char.HumanoidRootPart.Position + Vector3.new(math.random(-50,50),0,math.random(-50,50)))
                            end
                        end
                    end)
                    wait(Settings.Farm.Delay/1000 + randomDelay(50,200))
                end
            end)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Haki",
    CurrentValue = false,
    Flag = "AutoHaki",
    Callback = function(v)
        Settings.Haki.Enabled = v
        if v then
            spawn(function()
                while Settings.Haki.Enabled do
                    safeCall(function()
                        local char = LP.Character
                        if char then
                            for _, child in pairs(char:GetChildren()) do
                                if child.Name == "Haki" then child.Value = true end
                            end
                        end
                    end)
                    wait(1)
                end
            end)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Ken",
    CurrentValue = false,
    Flag = "AutoKen",
    Callback = function(v)
        Settings.Haki.Ken = v
        if v then
            spawn(function()
                while Settings.Haki.Ken do
                    safeCall(function()
                        local char = LP.Character
                        if char then
                            for _, child in pairs(char:GetChildren()) do
                                if child.Name == "Ken" then child.Value = true end
                            end
                        end
                    end)
                    wait(1)
                end
            end)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Superhuman",
    CurrentValue = false,
    Flag = "Superhuman",
    Callback = function(v)
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local npc = getNearestNPC("Superhuman")
                        if npc then interactNPC(npc) end
                        local enemy = getNearestEnemy()
                        if enemy then attack(enemy) end
                    end)
                    wait(2)
                end
            end)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Death Step",
    CurrentValue = false,
    Flag = "DeathStep",
    Callback = function(v)
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local npc = getNearestNPC("DeathStep")
                        if npc then interactNPC(npc) end
                        local enemy = getNearestEnemy()
                        if enemy then attack(enemy) end
                    end)
                    wait(2)
                end
            end)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Electric Claw",
    CurrentValue = false,
    Flag = "ElectricClaw",
    Callback = function(v)
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local npc = getNearestNPC("ElectricClaw")
                        if npc then interactNPC(npc) end
                        local enemy = getNearestEnemy()
                        if enemy then attack(enemy) end
                    end)
                    wait(2)
                end
            end)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Dragon Talon",
    CurrentValue = false,
    Flag = "DragonTalon",
    Callback = function(v)
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local npc = getNearestNPC("DragonTalon")
                        if npc then interactNPC(npc) end
                        local enemy = getNearestEnemy()
                        if enemy then attack(enemy) end
                    end)
                    wait(2)
                end
            end)
        end
    end
})

FarmTab:CreateSection("⚡ Kill Aura")
FarmTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(v)
        Settings.Combat.KillAura = v
        if v then
            spawn(function()
                while Settings.Combat.KillAura do
                    safeCall(function()
                        local enemy = getNearestEnemy()
                        if enemy then
                            local char = LP.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                local dist = (enemy.HumanoidRootPart.Position - char.HumanoidRootPart.Position).magnitude
                                if dist <= Settings.Combat.Range then
                                    attack(enemy)
                                end
                            end
                        end
                    end)
                    wait(0.2 + randomDelay(50,150))
                end
            end)
        end
    end
})

FarmTab:CreateSlider({
    Name = "Kill Aura Range",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Flag = "KillAuraRange",
    Callback = function(v)
        Settings.Combat.Range = v
    end
})

FarmTab:CreateSection("📋 Quests")
FarmTab:CreateToggle({
    Name = "Auto Quest",
    CurrentValue = false,
    Flag = "AutoQuest",
    Callback = function(v)
        Settings.Quest.Enabled = v
        if v then
            spawn(function()
                while Settings.Quest.Enabled do
                    safeCall(function()
                        local npc = getNearestNPC(Settings.Quest.NPC)
                        if npc then
                            interactNPC(npc)
                            wait(0.5)
                            if Settings.Quest.AutoAccept then
                                VirtualInputManager:SendKeyEvent(true,"E",false,game)
                                wait(0.1)
                                VirtualInputManager:SendKeyEvent(false,"E",false,game)
                            end
                            if Settings.Quest.AutoTurnIn then
                                wait(0.5)
                                VirtualInputManager:SendKeyEvent(true,"E",false,game)
                                wait(0.1)
                                VirtualInputManager:SendKeyEvent(false,"E",false,game)
                            end
                        end
                    end)
                    wait(5 + randomDelay(1000,3000))
                end
            end)
        end
    end
})

FarmTab:CreateDropdown({
    Name = "Quest NPC",
    Options = {"Monkey","Gorilla","Yeti","Dragon","Elite","Raid","Cake Prince","Rip Indra","Dough King","Darkbeard"},
    CurrentOption = "Monkey",
    Flag = "QuestNPC",
    Callback = function(v)
        Settings.Quest.NPC = v
    end
})

FarmTab:CreateToggle({
    Name = "Auto Turn In",
    CurrentValue = false,
    Flag = "AutoTurnIn",
    Callback = function(v)
        Settings.Quest.AutoTurnIn = v
    end
})

FarmTab:CreateToggle({
    Name = "Auto Accept",
    CurrentValue = false,
    Flag = "AutoAccept",
    Callback = function(v)
        Settings.Quest.AutoAccept = v
    end
})

FarmTab:CreateSection("📦 Items")
FarmTab:CreateToggle({
    Name = "Auto Collect Items",
    CurrentValue = false,
    Flag = "AutoCollect",
    Callback = function(v)
        Settings.Misc.AutoCollect = v
        if v then
            spawn(function()
                while Settings.Misc.AutoCollect do
                    safeCall(function()
                        local chest = getNearestChest()
                        if chest then
                            local char = LP.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.Humanoid:MoveTo(chest.Position)
                                wait(1)
                            end
                        end
                    end)
                    wait(2 + randomDelay(500,1500))
                end
            end)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Sell Items",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(v)
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local backpack = LP:FindFirstChild("Backpack")
                        if backpack then
                            for _, item in ipairs(backpack:GetChildren()) do
                                if item:IsA("Tool") and item:FindFirstChild("Value") then
                                    item:Destroy()
                                end
                            end
                        end
                    end)
                    wait(30)
                end
            end)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Auto Store Items",
    CurrentValue = false,
    Flag = "AutoStore",
    Callback = function(v)
        -- Logic auto store
    end
})

FarmTab:CreateToggle({
    Name = "Auto Drop Useless",
    CurrentValue = false,
    Flag = "AutoDrop",
    Callback = function(v)
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local backpack = LP:FindFirstChild("Backpack")
                        if backpack then
                            for _, item in ipairs(backpack:GetChildren()) do
                                if item:IsA("Tool") and item.Name:find("Common") then
                                    item:Destroy()
                                end
                            end
                        end
                    end)
                    wait(10)
                end
            end)
        end
    end
})

FarmTab:CreateDropdown({
    Name = "Item Priority",
    Options = {"All","Common","Rare","Legendary","Mythical"},
    CurrentOption = "All",
    Flag = "ItemPriority",
    Callback = function(v)
        -- Logic item priority
    end
})
-- ============================================================
-- PHẦN 5: TAB AUTO BOSS ĐẦY ĐỦ
-- ============================================================

-- === TAB: AUTO BOSS ===
local BossTab = Window:CreateTab("👑 Auto Boss", nil)

BossTab:CreateSection("⚔️ Boss Farm")
BossTab:CreateToggle({
    Name = "Auto Farm Boss",
    CurrentValue = false,
    Flag = "AutoBoss",
    Callback = function(v)
        Settings.Boss.Enabled = v
        if v then
            spawn(function()
                while Settings.Boss.Enabled do
                    safeCall(function()
                        local boss = getNearestBoss()
                        if boss then
                            attack(boss)
                        end
                    end)
                    wait(0.5 + randomDelay(100,300))
                end
            end)
        end
    end
})

BossTab:CreateSection("👑 First Sea Bosses")
local FirstSeaBosses = {
    "Gorilla King", "Bobby", "The Saw", "Yeti", "Mob Leader",
    "Vice Admiral", "Saber Expert", "Warden", "Chief Warden",
    "Swan", "Magma Admiral", "Fishman Lord", "Wysper",
    "Thunder God", "Cyborg", "Ice Admiral", "Greybeard"
}
for _, name in ipairs(FirstSeaBosses) do
    BossTab:CreateButton({
        Name = "Auto " .. name,
        Callback = function()
            log("Starting Auto " .. name)
            spawn(function()
                while true do
                    safeCall(function()
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj.Name:find(name) and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                                attack(obj)
                            end
                        end
                    end)
                    wait(0.5)
                end
            end)
        end
    })
end

BossTab:CreateSection("👑 Second Sea Bosses")
local SecondSeaBosses = {
    "Diamond", "Jeremy", "Orbitus", "Don Swan", "Smoke Admiral",
    "Order", "Cursed Captain", "Awakened Ice Admiral",
    "Tide Keeper", "Darkbeard", "rip_indra"
}
for _, name in ipairs(SecondSeaBosses) do
    BossTab:CreateButton({
        Name = "Auto " .. name,
        Callback = function()
            log("Starting Auto " .. name)
            spawn(function()
                while true do
                    safeCall(function()
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj.Name:find(name) and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                                attack(obj)
                            end
                        end
                    end)
                    wait(0.5)
                end
            end)
        end
    })
end

BossTab:CreateSection("👑 Third Sea Bosses")
local ThirdSeaBosses = {
    "Stone", "Island Empress", "Kilo Admiral", "Captain Elephant",
    "Beautiful Pirate", "Longma", "Soul Reaper", "Cake Queen",
    "Cake Prince", "Dough King", "Rip Indra", "Dragon"
}
for _, name in ipairs(ThirdSeaBosses) do
    BossTab:CreateButton({
        Name = "Auto " .. name,
        Callback = function()
            log("Starting Auto " .. name)
            spawn(function()
                while true do
                    safeCall(function()
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj.Name:find(name) and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                                attack(obj)
                            end
                        end
                    end)
                    wait(0.5)
                end
            end)
        end
    })
end
-- ============================================================
-- PHẦN 6: TAB RAID + SEA EVENT
-- ============================================================

-- === TAB: RAID ===
local RaidTab = Window:CreateTab("⚔️ Raid", nil)

RaidTab:CreateSection("⚔️ Raid Settings")
RaidTab:CreateToggle({
    Name = "Auto Buy Chip",
    CurrentValue = false,
    Flag = "BuyChip",
    Callback = function(v)
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local npc = getNearestNPC("Chip")
                        if npc then interactNPC(npc) end
                    end)
                    wait(60)
                end
            end)
        end
    end
})

RaidTab:CreateToggle({
    Name = "Auto Raid",
    CurrentValue = false,
    Flag = "AutoRaid",
    Callback = function(v)
        Settings.Raid.Enabled = v
        if v then
            spawn(function()
                while Settings.Raid.Enabled do
                    safeCall(function()
                        local npc = getNearestNPC("Raid")
                        if npc then interactNPC(npc) end
                    end)
                    wait(10 + randomDelay(2000,5000))
                end
            end)
        end
    end
})

RaidTab:CreateToggle({
    Name = "Auto Next Island",
    CurrentValue = false,
    Flag = "NextIsland",
    Callback = function(v)
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local enemy = getNearestEnemy()
                        if not enemy then
                            local islands = Workspace:FindFirstChild("Islands")
                            if islands then
                                for _, island in ipairs(islands:GetChildren()) do
                                    if island:FindFirstChild("HumanoidRootPart") then
                                        teleportTo(island.HumanoidRootPart.Position)
                                        break
                                    end
                                end
                            end
                        end
                    end)
                    wait(10)
                end
            end)
        end
    end
})

RaidTab:CreateDropdown({
    Name = "Select Raid Type",
    Options = {"Flame","Ice","Quake","Light","Dark","Dragon","Leopard","Kitsune"},
    CurrentOption = "Flame",
    Flag = "RaidType",
    Callback = function(v)
        Settings.Raid.Type = v
    end
})

RaidTab:CreateToggle({
    Name = "Auto Awakening",
    CurrentValue = false,
    Flag = "AutoAwaken",
    Callback = function(v)
        Settings.Raid.AutoAwaken = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local npc = getNearestNPC("Awaken")
                        if npc then interactNPC(npc) end
                    end)
                    wait(300)
                end
            end)
        end
    end
})

RaidTab:CreateSlider({
    Name = "Stop Raid at Fragments",
    Range = {1000, 50000},
    Increment = 1000,
    CurrentValue = 10000,
    Flag = "RaidFragStop",
    Callback = function(v)
        Settings.Raid.StopFragments = v
    end
})

-- === TAB: SEA EVENT ===
local SeaTab = Window:CreateTab("🌊 Sea Event", nil)

SeaTab:CreateSection("🌊 Sea Events")
SeaTab:CreateToggle({
    Name = "Auto Sea Beast",
    CurrentValue = false,
    Flag = "SeaBeast",
    Callback = function(v)
        Settings.Sea.SeaBeast = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local beast = Workspace:FindFirstChild("SeaBeast")
                        if beast then
                            local char = LP.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.Humanoid:MoveTo(beast.Position)
                            end
                        end
                    end)
                    wait(3 + randomDelay(1000,3000))
                end
            end)
        end
    end
})

SeaTab:CreateToggle({
    Name = "Auto Leviathan",
    CurrentValue = false,
    Flag = "Leviathan",
    Callback = function(v)
        Settings.Sea.Leviathan = v
        getgenv().LeviathanActive = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local leviathan = Workspace:FindFirstChild("Leviathan")
                        if leviathan then
                            local char = LP.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.Humanoid:MoveTo(leviathan.Position)
                            end
                        end
                    end)
                    wait(3 + randomDelay(1000,3000))
                end
            end)
        end
    end
})

SeaTab:CreateToggle({
    Name = "Auto Terror Shark",
    CurrentValue = false,
    Flag = "TerrorShark",
    Callback = function(v)
        Settings.Sea.TerrorShark = v
        getgenv().TerrorSharkActive = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local shark = Workspace:FindFirstChild("TerrorShark")
                        if shark then
                            local char = LP.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.Humanoid:MoveTo(shark.Position)
                            end
                        end
                    end)
                    wait(3 + randomDelay(1000,3000))
                end
            end)
        end
    end
})

SeaTab:CreateToggle({
    Name = "Auto Shark Anchor",
    CurrentValue = false,
    Flag = "SharkAnchor",
    Callback = function(v)
        Settings.Sea.SharkAnchor = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local anchor = Workspace:FindFirstChild("SharkAnchor")
                        if anchor then
                            teleportTo(anchor.Position, true)
                            wait(0.5)
                        end
                    end)
                    wait(5)
                end
            end)
        end
    end
})

SeaTab:CreateToggle({
    Name = "Auto Prehistoric Island",
    CurrentValue = false,
    Flag = "Prehistoric",
    Callback = function(v)
        Settings.Sea.Prehistoric = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local island = Workspace:FindFirstChild("PrehistoricIsland")
                        if island then
                            local char = LP.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.Humanoid:MoveTo(island.Position)
                            end
                        end
                    end)
                    wait(3 + randomDelay(1000,3000))
                end
            end)
        end
    end
})

SeaTab:CreateToggle({
    Name = "Auto Mirage Island",
    CurrentValue = false,
    Flag = "Mirage",
    Callback = function(v)
        Settings.Sea.Mirage = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local island = Workspace:FindFirstChild("MirageIsland")
                        if island then
                            local char = LP.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.Humanoid:MoveTo(island.Position)
                            end
                        end
                    end)
                    wait(3 + randomDelay(1000,3000))
                end
            end)
        end
    end
})

SeaTab:CreateToggle({
    Name = "Auto Full Moon Tracker",
    CurrentValue = false,
    Flag = "FullMoon",
    Callback = function(v)
        Settings.Sea.FullMoon = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        if isFullMoon() then
                            log("🌕 Full Moon detected!")
                        end
                    end)
                    wait(60)
                end
            end)
        end
    end
})
-- ============================================================
-- PHẦN 7: TAB TELEPORT + ISLAND ĐẦY ĐỦ
-- ============================================================

-- === TAB: TELEPORT ===
local TeleportTab = Window:CreateTab("📍 Teleport", nil)

-- First Sea Islands
TeleportTab:CreateSection("🏝️ First Sea")
local FirstSeaIslands = {
    "Jungle", "Pirate Village", "Desert", "Frozen Village",
    "Marine Fortress", "Middle Island", "Magma Village",
    "Underwater City", "Upper Skylands", "Middle Skylands",
    "Fountain City", "Prison", "JeanLuc Island", "Dark Arena"
}
for _, name in ipairs(FirstSeaIslands) do
    TeleportTab:CreateButton({
        Name = name,
        Callback = function()
            safeCall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == name and obj:FindFirstChild("HumanoidRootPart") then
                        teleportTo(obj.HumanoidRootPart.Position, true)
                        log("Teleported to " .. name)
                        break
                    end
                end
            end)
        end
    })
end

-- Second Sea Islands
TeleportTab:CreateSection("🏝️ Second Sea")
local SecondSeaIslands = {
    "Kingdom of Rose", "Green Zone", "Mansion", "Hot and Cold",
    "Cursed Ship", "Ice Castle", "Forgotten Island",
    "Graveyard", "Dragon Island"
}
for _, name in ipairs(SecondSeaIslands) do
    TeleportTab:CreateButton({
        Name = name,
        Callback = function()
            safeCall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == name and obj:FindFirstChild("HumanoidRootPart") then
                        teleportTo(obj.HumanoidRootPart.Position, true)
                        log("Teleported to " .. name)
                        break
                    end
                end
            end)
        end
    })
end

-- Third Sea Islands
TeleportTab:CreateSection("🏝️ Third Sea")
local ThirdSeaIslands = {
    "Port Town", "Hydra Island", "Great Tree", "Floating Turtle",
    "Sea of Treats", "Castle on the Sea", "Haunted Castle",
    "Mirage Island", "Prehistoric Island", "Dragon Island"
}
for _, name in ipairs(ThirdSeaIslands) do
    TeleportTab:CreateButton({
        Name = name,
        Callback = function()
            safeCall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == name and obj:FindFirstChild("HumanoidRootPart") then
                        teleportTo(obj.HumanoidRootPart.Position, true)
                        log("Teleported to " .. name)
                        break
                    end
                end
            end)
        end
    })
end

-- Teleport to NPCs
TeleportTab:CreateSection("👤 Teleport to NPCs")
local NPCs = {
    "Monkey", "Gorilla", "Yeti", "Elite", "Raid",
    "Cake Prince", "Rip Indra", "Dough King", "Darkbeard",
    "Dragon", "Leviathan", "Sea Beast"
}
for _, name in ipairs(NPCs) do
    TeleportTab:CreateButton({
        Name = name,
        Callback = function()
            safeCall(function()
                local npc = getNearestNPC(name)
                if npc then
                    local hrp = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
                    if hrp then
                        teleportTo(hrp.Position, true)
                        log("Teleported to " .. name)
                    end
                end
            end)
        end
    })
end

-- Other Teleports
TeleportTab:CreateSection("📍 Other")
TeleportTab:CreateButton({
    Name = "Teleport to Fruit",
    Callback = function()
        local fruit = getNearestFruit()
        if fruit then
            teleportTo(fruit.Position, true)
            log("Teleported to fruit")
        else
            log("No fruit found")
        end
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        local player = getNearestPlayer()
        if player then
            teleportTo(player.Position, true)
            log("Teleported to player")
        end
    end
})

TeleportTab:CreateButton({
    Name = "Teleport Sea 1/2/3",
    Callback = function()
        safeCall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name:find("Sea") and obj:FindFirstChild("HumanoidRootPart") then
                    teleportTo(obj.HumanoidRootPart.Position, true)
                    log("Teleported to Sea")
                    break
                end
            end
        end)
    end
})
-- ============================================================
-- PHẦN 8: TAB FRUITS + STATS + PLAYER + SETTINGS + MISC
-- ============================================================

-- === TAB: FRUITS ===
local FruitTab = Window:CreateTab("🍎 Fruits", nil)

FruitTab:CreateSection("🍎 Fruit Settings")
FruitTab:CreateToggle({
    Name = "Fruit Sniper",
    CurrentValue = false,
    Flag = "FruitSniper",
    Callback = function(v)
        Settings.Fruit.Sniper = v
        getgenv().FruitSniperActive = v
        if v then
            spawn(function()
                while Settings.Fruit.Sniper do
                    safeCall(function()
                        local fruit = getNearestFruit()
                        if fruit then
                            teleportTo(fruit.Position, true)
                            getgenv().LastFruitSpawn = "Found at " .. os.date("%H:%M:%S")
                            wait(0.5)
                        end
                    end)
                    wait(1 + randomDelay(500,1500))
                end
            end)
        end
    end
})

FruitTab:CreateToggle({
    Name = "Fruit ESP",
    CurrentValue = false,
    Flag = "FruitESP",
    Callback = function(v)
        Settings.ESP.Fruit = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and (obj.Name:find("Fruit") or obj.Name:find("fruit") or obj.Name == "Fruit ") then
                                local highlight = Instance.new("Highlight")
                                highlight.Parent = obj
                                highlight.FillColor = Color3.new(1,0,0)
                                highlight.OutlineColor = Color3.new(1,1,0)
                                table.insert(ESPObjects, highlight)
                            end
                        end
                    end)
                    wait(5)
                end
            end)
        else
            for _, obj in ipairs(ESPObjects) do
                safeCall(function() obj:Destroy() end)
            end
            ESPObjects = {}
        end
    end
})

FruitTab:CreateToggle({
    Name = "Auto Buy Random Fruit",
    CurrentValue = false,
    Flag = "AutoBuyFruit",
    Callback = function(v)
        Settings.Fruit.AutoBuy = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local npc = getNearestNPC("FruitDealer")
                        if npc then interactNPC(npc) end
                    end)
                    wait(30)
                end
            end)
        end
    end
})

FruitTab:CreateToggle({
    Name = "Auto Store Fruit",
    CurrentValue = false,
    Flag = "AutoStoreFruit",
    Callback = function(v)
        Settings.Fruit.AutoStore = v
    end
})

FruitTab:CreateToggle({
    Name = "Auto Eat Fruit",
    CurrentValue = false,
    Flag = "AutoEatFruit",
    Callback = function(v)
        Settings.Fruit.AutoEat = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        local backpack = LP:FindFirstChild("Backpack")
                        if backpack then
                            for _, item in ipairs(backpack:GetChildren()) do
                                if item.Name:find("Fruit") then
                                    LP.Character.Humanoid:EquipTool(item)
                                    wait(0.5)
                                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                                    wait(0.1)
                                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                                end
                            end
                        end
                    end)
                    wait(30)
                end
            end)
        end
    end
})

FruitTab:CreateButton({
    Name = "🔍 Fruit Finder",
    Callback = function()
        local fruit = getNearestFruit()
        if fruit then
            teleportTo(fruit.Position, true)
            log("Found fruit at " .. tostring(fruit.Position))
        else
            log("No fruit found")
        end
    end
})

FruitTab:CreateDropdown({
    Name = "Fruit Priority",
    Options = {"All","Common","Rare","Legendary","Mythical"},
    CurrentOption = "All",
    Flag = "FruitPriority",
    Callback = function(v)
        Settings.Fruit.Priority = v
    end
})

-- === TAB: STATS ===
local StatsTab = Window:CreateTab("📊 Stats", nil)

StatsTab:CreateSection("📊 Auto Stats")
StatsTab:CreateDropdown({
    Name = "Select Stat",
    Options = {"Melee","Defense","Sword","Gun","Fruit"},
    CurrentOption = "Melee",
    Flag = "StatSelect",
    Callback = function(v)
        Settings.Stats.Type = v
        getgenv().CurrentStatBuild = v
    end
})

StatsTab:CreateSlider({
    Name = "Points per cycle",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 10,
    Flag = "StatPoints",
    Callback = function(v)
        Settings.Stats.Points = v
    end
})

StatsTab:CreateToggle({
    Name = "Enable Auto Stats",
    CurrentValue = false,
    Flag = "AutoStats",
    Callback = function(v)
        Settings.Stats.Enabled = v
        getgenv().AutoStatsActive = v
        if v then
            spawn(function()
                while Settings.Stats.Enabled do
                    safeCall(function()
                        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                        if remote then
                            remote:FireServer(Settings.Stats.Type or "Melee", Settings.Stats.Points or 10)
                        end
                    end)
                    wait(5 + randomDelay(500,2000))
                end
            end)
        end
    end
})

StatsTab:CreateToggle({
    Name = "Auto Assign on Level Up",
    CurrentValue = false,
    Flag = "AutoAssign",
    Callback = function(v)
        Settings.Stats.AutoAssign = v
        if v then
            spawn(function()
                local lastLevel = getCurrentLevel()
                while v do
                    wait(1)
                    local currentLevel = getCurrentLevel()
                    if currentLevel > lastLevel then
                        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                        if remote then
                            remote:FireServer(Settings.Stats.Type or "Melee", Settings.Stats.Points or 10)
                        end
                        lastLevel = currentLevel
                    end
                end
            end)
        end
    end
})

-- === TAB: PLAYER ===
local PlayerTab = Window:CreateTab("👤 Player", nil)

PlayerTab:CreateSection("👤 Player Options")
PlayerTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(v)
        Settings.ESP.Player = v
        if v then
            spawn(function()
                while v do
                    safeCall(function()
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LP and plr.Character then
                                local highlight = Instance.new("Highlight")
                                highlight.Parent = plr.Character
                                highlight.FillColor = Color3.new(0,1,0)
                                highlight.OutlineColor = Color3.new(1,1,1)
                                table.insert(ESPObjects, highlight)
                            end
                        end
                    end)
                    wait(5)
                end
            end)
        else
            for _, obj in ipairs(ESPObjects) do
                safeCall(function() obj:Destroy() end)
            end
            ESPObjects = {}
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Spectate",
    CurrentValue = false,
    Flag = "Spectate",
    Callback = function(v)
        Settings.Player.Spectate = v
        if v then
            local target = Settings.Teleport.Target
            if target and target ~= "None" then
                local plr = Players:FindFirstChild(target)
                if plr and plr.Character then
                    Workspace.CurrentCamera.CameraSubject = plr.Character:FindFirstChild("Humanoid")
                end
            end
        else
            Workspace.CurrentCamera.CameraSubject = LP.Character and LP.Character:FindFirstChild("Humanoid")
        end
    end
})

PlayerTab:CreateButton({
    Name = "Player List",
    Callback = function()
        local list = ""
        for _, plr in ipairs(Players:GetPlayers()) do
            list = list .. plr.Name .. "\n"
        end
        log("Players:\n" .. list)
    end
})

PlayerTab:CreateDropdown({
    Name = "Target Player",
    Options = Players:GetPlayers(),
    CurrentOption = "None",
    Flag = "TargetPlayer",
    Callback = function(v)
        Settings.Teleport.Target = v
    end
})

PlayerTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(v)
        Settings.Player.AntiAFK = v
        if v then
            spawn(function()
                while Settings.Player.AntiAFK do
                    safeCall(function()
                        local char = LP.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local pos = char.HumanoidRootPart.Position
                            char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(math.random(-2,2),0,math.random(-2,2)))
                        end
                    end)
                    wait(60 + randomDelay(5000,10000))
                end
            end)
        end
    end
})

-- === TAB: SETTINGS ===
local SettingsTab = Window:CreateTab("⚙️ Settings", nil)

SettingsTab:CreateSection("⚙️ General")
SettingsTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(v)
        Settings.Misc.NoClip = v
        safeCall(function()
            local char = LP.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CanCollide = not v
            end
        end)
    end
})

SettingsTab:CreateToggle({
    Name = "Tween Movement",
    CurrentValue = false,
    Flag = "Tween",
    Callback = function(v)
        Settings.Misc.Tween = v
    end
})

SettingsTab:CreateToggle({
    Name = "Walk on Water",
    CurrentValue = false,
    Flag = "WalkWater",
    Callback = function(v)
        Settings.Misc.WalkWater = v
        safeCall(function()
            local char = LP.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, not v)
            end
        end)
    end
})

SettingsTab:CreateToggle({
    Name = "No Cooldown",
    CurrentValue = false,
    Flag = "NoCooldown",
    Callback = function(v)
        Settings.Misc.NoCooldown = v
        getgenv().NoCooldown = v
        getgenv().NoCooldownActive = v
    end
})

SettingsTab:CreateToggle({
    Name = "Anti-Ban",
    CurrentValue = false,
    Flag = "AntiBan",
    Callback = function(v)
        Settings.Misc.AntiBan = v
        getgenv().AntiBan = v
        getgenv().AntiBanActive = v
        getgenv().BanRisk = v and "Low" or "High"
    end
})

SettingsTab:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoost",
    Callback = function(v)
        Settings.Misc.FPSBoost = v
        safeCall(function()
            if v then
                settings().Rendering.QualityLevel = 1
            else
                settings().Rendering.QualityLevel = 10
            end
        end)
    end
})

SettingsTab:CreateSection("🔄 Server")
SettingsTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        TeleportService:Teleport(game.PlaceId)
    end
})

SettingsTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LP)
    end
})

SettingsTab:CreateButton({
    Name = "Auto Set Spawn",
    Callback = function()
        safeCall(function()
            local char = LP.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                getgenv().SpawnPoint = char.HumanoidRootPart.Position
                log("Spawn set!")
            end
        end)
    end
})

SettingsTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        safeCall(function()
            LP.Character:BreakJoints()
        end)
    end
})

SettingsTab:CreateSection("💾 Config")
SettingsTab:CreateButton({
    Name = "Save Config",
    Callback = function()
        Rayfield:SaveConfiguration()
        log("Config saved!")
    end
})

SettingsTab:CreateButton({
    Name = "Load Config",
    Callback = function()
        Rayfield:LoadConfiguration()
        log("Config loaded!")
    end
})

-- === KHỞI TẠO ===
Rayfield:LoadConfiguration()
log("Skibidi Hub Premium loaded successfully!")
log("Press Insert to toggle menu")
