--[[
    Grow a Garden – System Monitor Bot
    Author : depso (gốc) | Mod : Nguyen Nhan
    Tính năng: Weather + Anti-AFK + Rejoin + Webhook + System Status cập nhật mỗi 1s
]]

local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local VirtualUser      = cloneref(game:GetService("VirtualUser"))
local GuiService       = game:GetService("GuiService")
local TeleportService  = game:GetService("TeleportService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local Stats            = game:GetService("Stats")

local LP = Players.LocalPlayer
local JobId = game.JobId
local PlaceId = game.PlaceId

-- CONFIG
local WEBHOOK = "https://discord.com/api/webhooks/1388136802342146208/LqqE8pdN3JyzX2EXt4rf282ewLGClVPtnE2jZhq7KyzTfDiY5-r_sYr3RdzMq-TMHRql"
local SCRIPT_URL = "https://raw.githubusercontent.com/NguyenNhandz/new/main/demo.lua"

-- FUNCTIONS
local function sendEmbed(title, desc, color)
    local data = {
        embeds = {{
            title = title,
            description = desc,
            color = color or 16777215,
            footer = { text = "Nguyen Nhan • Roblox Auto Monitor" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    task.spawn(request, {
        Url = WEBHOOK,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end

-- Startup
sendEmbed("✅ Bắt đầu giám sát", LP.Name .. " đã vào game!\nJobId: `" .. JobId .. "`", 0x2ecc71)

-- Anti-AFK
LP.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    sendEmbed("💤 Anti-AFK", LP.Name .. " đã được cứu khỏi AFK!", 0x3498db)
end)

-- Auto Rejoin
GuiService.ErrorMessageChanged:Connect(function()
    sendEmbed("🔁 Rejoin", LP.Name .. " bị disconnect, đang vào lại...", 0xe67e22)
    queue_on_teleport("loadstring(game:HttpGet('" .. SCRIPT_URL .. "'))()")
    wait(5)
    TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LP)
end)

-- Weather
ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("WeatherEventStarted").OnClientEvent:Connect(function(Event, Length)
    local endUnix = math.floor(workspace:GetServerTimeNow()) + Length
    sendEmbed("⛅ Weather", "**" .. Event .. "**\nKết thúc: <t:" .. endUnix .. ":R>", 0x9b59b6)
end)

-- SYSTEM STATUS REPORT (1s/lần)
task.spawn(function()
    local startTime = os.clock()
    while true do
        pcall(function()
            local uptime = os.clock() - startTime
            local mem = math.floor(Stats:GetTotalMemoryUsageMb())
            local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            local cpu = math.clamp((mem / 2048) * 100, 1, 100)
            local is_exe = identifyexecutor and identifyexecutor() or "Không rõ"

            local desc = table.concat({
                "👤 **Account**: `" .. LP.Name .. "` (" .. LP.DisplayName .. ")",
                "🌐 **Ping**: `" .. ping .. "ms`",
                "💾 **Memory**: `" .. mem .. " MB`",
                "⚙️ **CPU Ước lượng**: `" .. math.floor(cpu) .. "%`",
                "📊 **FPS**: `" .. fps .. "`",
                "🕒 **Thời gian online**: `" .. math.floor(uptime) .. " giây`",
                "🖥️ **Executor**: `" .. tostring(is_exe) .. "`",
                "📡 **JobId**: `" .. JobId .. "`"
            }, "\n")

            sendEmbed("📟 Trạng thái hệ thống (1s)", desc, 0x1abc9c)
        end)
        wait(1)
    end
end)
