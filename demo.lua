-- growagarden.lua | FULL AUTO SCRIPT by Nguyễn Trung Nhân

-- ✅ Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🌿 Grow A Garden - FULL AUTO", "BloodTheme")

-- Tabs
local autoTab = Window:NewTab("Auto")
local visualTab = Window:NewTab("ESP & HUD")
local settingTab = Window:NewTab("Tùy chọn")
local creditTab = Window:NewTab("Credits")

-- Biến toàn cục
_G.autoWater = false
_G.autoHarvest = false
_G.autoPlant = false
_G.autoSell = false
_G.autoSeed = false
_G.espEnabled = false
_G.antiAfk = false
_G.showStats = false
_G.selectedSeed = "Carrot"

local harvestedCount = 0

-- 💧 Auto Water
function doWater()
    while _G.autoWater and task.wait(1) do
        for _, v in pairs(workspace.Plots:GetChildren()) do
            if v:FindFirstChild("WaterPrompt") then
                fireproximityprompt(v.WaterPrompt)
            end
        end
    end
end

-- 🌾 Auto Harvest
function doHarvest()
    while _G.autoHarvest and task.wait(1) do
        for _, v in pairs(workspace.Plots:GetChildren()) do
            if v:FindFirstChild("HarvestPrompt") then
                fireproximityprompt(v.HarvestPrompt)
                harvestedCount += 1
            end
        end
    end
end

-- 🌱 Auto Plant
function doPlant()
    while _G.autoPlant and task.wait(1.2) do
        for _, v in pairs(workspace.Plots:GetChildren()) do
            if v:FindFirstChild("PlantPrompt") then
                fireproximityprompt(v.PlantPrompt)
                task.wait(0.3)
                game:GetService("ReplicatedStorage").Remotes.PlantSeed:FireServer(_G.selectedSeed)
            end
        end
    end
end

-- 📦 Auto mở seed pack
function autoSeed()
    while _G.autoSeed and task.wait(3) do
        game:GetService("ReplicatedStorage").Remotes.OpenSeedPack:FireServer()
    end
end

-- 💰 Auto Sell
function doSell()
    while _G.autoSell and task.wait(2) do
        local pad = workspace:FindFirstChild("SellPart") or workspace:FindFirstChild("Sell")
        if pad then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pad.CFrame + Vector3.new(0, 3, 0)
        end
    end
end

-- 👁️ ESP cây
function enableESP()
    while _G.espEnabled and task.wait(1) do
        for _, plot in pairs(workspace.Plots:GetChildren()) do
            if plot:FindFirstChild("Plant") and plot.Plant:FindFirstChild("Stage") then
                local stage = plot.Plant.Stage.Value
                if stage == "Harvestable" and not plot:FindFirstChild("ESP") then
                    local esp = Instance.new("BillboardGui", plot)
                    esp.Name = "ESP"
                    esp.Size = UDim2.new(0, 100, 0, 40)
                    esp.StudsOffset = Vector3.new(0, 3, 0)
                    esp.AlwaysOnTop = true

                    local text = Instance.new("TextLabel", esp)
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.Text = "🌾 READY"
                    text.TextColor3 = Color3.new(0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.TextScaled = true
                elseif stage ~= "Harvestable" and plot:FindFirstChild("ESP") then
                    plot.ESP:Destroy()
                end
            end
        end
    end
end

-- 🔄 Anti-AFK
function antiAFK()
    while _G.antiAfk and task.wait(60) do
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "W", false, game)
        task.wait(0.2)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "W", false, game)
    end
end

-- 📊 Thống kê
local statGui = Instance.new("ScreenGui", game.CoreGui)
statGui.Name = "StatsGUI"
local label = Instance.new("TextLabel", statGui)
label.Size = UDim2.new(0, 200, 0, 50)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 0.5
label.BackgroundColor3 = Color3.new(0, 0, 0)
label.TextColor3 = Color3.new(0, 1, 0)
label.TextScaled = true
label.Text = "Đã thu hoạch: 0"
label.Visible = false

function updateStats()
    while _G.showStats and task.wait(1) do
        label.Text = "🌾 Đã thu hoạch: " .. harvestedCount
        label.Visible = true
    end
    label.Visible = false
end

-- Giao diện
autoTab:NewToggle("💧 Auto Water", "Tưới cây", function(v) _G.autoWater = v if v then doWater() end end)
autoTab:NewToggle("🌾 Auto Harvest", "Thu hoạch", function(v) _G.autoHarvest = v if v then doHarvest() end end)
autoTab:NewToggle("🌱 Auto Plant", "Trồng cây", function(v) _G.autoPlant = v if v then doPlant() end end)
autoTab:NewToggle("💰 Auto Sell", "Tự bán cây", function(v) _G.autoSell = v if v then doSell() end end)
autoTab:NewToggle("📦 Auto mở seed pack", "Tự động mở hạt giống", function(v) _G.autoSeed = v if v then autoSeed() end end)

visualTab:NewToggle("👁️ ESP Cây READY", "Hiển thị khi cây sẵn sàng", function(v) _G.espEnabled = v if v then enableESP() end end)
visualTab:NewToggle("📊 Hiện thống kê", "Hiển thị số cây thu hoạch", function(v) _G.showStats = v updateStats() end)
visualTab:NewToggle("🔄 Anti-AFK", "Chống bị kick do AFK", function(v) _G.antiAfk = v if v then antiAFK() end end)

settingTab:NewDropdown("🌰 Chọn Hạt Giống", "Chọn loại cây trồng", {"Carrot", "Tomato", "Potato", "Lettuce", "Corn"}, function(val)
    _G.selectedSeed = val
end)

creditTab:NewSection("🧠 Script by Nguyễn Trung Nhân")
