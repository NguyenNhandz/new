--[[
    Grow a Garden – FULL Stock Bot
    Author  : depso (depthso)
    Mod by  : Nguyen Nhan
    Game ID : 126884695634066
    Features: Stock reporting • Weather log • Anti‑AFK • Auto‑Rejoin • Dual‑Webhook
]]

type table = { [any]: any }

--// USER CONFIG ----------------------------------------------------------------
_G.Configuration = {
    -- Reporting
    ["Enabled"]          = true,
    ["Webhook_Stock"]    = "https://discord.com/api/webhooks/1388136766648746145/A8as0rs5kUSWxMQQLagMbrc41Ef3tyoer8YR25tvVk0i3guNkEiiWnhooj4YP6COuVbj",
    ["Webhook_Log"]      = "https://discord.com/api/webhooks/1388136802342146208/LqqE8pdN3JyzX2EXt4rf282ewLGClVPtnE2jZhq7KyzTfDiY5-r_sYr3RdzMq-TMHRql",
    ["Weather Reporting"]= true,

    -- Client
    ["Anti-AFK"]         = true,
    ["Auto-Reconnect"]   = true,
    ["Rendering Enabled"]= false,  -- tắt 3D để tiết kiệm tài nguyên executor

    -- Embed layouts / colours
    ["AlertLayouts"] = {
        ["Weather"] = {
            WebhookTarget = "Webhook_Log",
            EmbedColor    = Color3.fromRGB( 42,109,255)
        },
        ["SeedsAndGears"] = {
            WebhookTarget = "Webhook_Stock",
            EmbedColor    = Color3.fromRGB( 56,238, 23),
            Layout = {
                ["ROOT/SeedStock/Stocks"] = "SEEDS STOCK",
                ["ROOT/GearStock/Stocks"] = "GEAR STOCK"
            }
        },
        ["EventShop"] = {
            WebhookTarget = "Webhook_Stock",
            EmbedColor    = Color3.fromRGB(212, 42,255),
            Layout = {
                ["ROOT/EventShopStock/Stocks"] = "EVENT STOCK"
            }
        },
        ["Eggs"] = {
            WebhookTarget = "Webhook_Stock",
            EmbedColor    = Color3.fromRGB(251,255, 14),
            Layout = {
                ["ROOT/PetEggStock/Stocks"] = "EGG STOCK"
            }
        },
        ["CosmeticStock"] = {
            WebhookTarget = "Webhook_Stock",
            EmbedColor    = Color3.fromRGB(255,106, 42),
            Layout = {
                ["ROOT/CosmeticStock/ItemStocks"] = "COSMETIC ITEMS STOCK"
            }
        }
    }
}
--// ---------------------------------------------------------------------------


--// SERVICES -------------------------------------------------------------------
local Players          = game:GetService("Players")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local GuiService       = game:GetService("GuiService")
local TeleportService  = game:GetService("TeleportService")
local VirtualUser      = cloneref(game:GetService("VirtualUser"))

local DataStream           = ReplicatedStorage.GameEvents.DataStream     -- RemoteEvent
local WeatherEventStarted  = ReplicatedStorage.GameEvents.WeatherEventStarted

local LocalPlayer  = Players.LocalPlayer
local PlaceId      = game.PlaceId
local JobId        = game.JobId
--// ---------------------------------------------------------------------------


--// HELPER FUNCTIONS -----------------------------------------------------------
local function cfg(key:string)  return _G.Configuration[key] end
local function hex(c:Color3)    return tonumber(c:ToHex(),16) end

local function getPacket(list, target:string)
    for _, p in list do
        if p[1]==target then return p[2] end
    end
end

local function webhookSend(layoutType:string, fields:table)
    if not cfg"Enabled" then return end
    local layout = cfg"AlertLayouts"[layoutType]; if not layout then return end
    local url    = cfg(layout.WebhookTarget or "Webhook_Log")
    local body   = {
        embeds = {{
            color     = hex(layout.EmbedColor),
            fields    = fields,
            footer    = { text = "Made by depso • Mod by Nguyen Nhan" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    task.spawn(request, {
        Url     = url,
        Method  = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body    = HttpService:JSONEncode(body)
    })
end

local function simpleLog(txt:string)
    task.spawn(request,{
        Url     = cfg"Webhook_Log",
        Method  = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body    = HttpService:JSONEncode({content="**[LOG]** "..txt})
    })
end

local function stockString(stock:table):string
    local s=""; for name,data in stock do
        local amount,alt = data.Stock, data.EggName
        s ..= (alt or name).." **x"..amount.."**\n"
    end; return s
end
--// ---------------------------------------------------------------------------


--// ONE‑TIME INITIALISATION ----------------------------------------------------
if _G.StockBot then return end  -- tránh chạy file hai lần
_G.StockBot = true

RunService:Set3dRenderingEnabled(cfg"Rendering Enabled") -- giảm lag

simpleLog(LocalPlayer.Name.." đã vào game • Job: "..JobId)
--// ---------------------------------------------------------------------------


--// DATA HANDLERS --------------------------------------------------------------
local layouts = cfg"AlertLayouts"

local function processStock(data, lType:string, layout)
    if not layout.Layout then return end
    local fields={}
    for path,title in layout.Layout do
        local packet = getPacket(data,path); if not packet then return end
        table.insert(fields,{name=title,value=stockString(packet),inline=true})
    end
    webhookSend(lType, fields)
end

DataStream.OnClientEvent:Connect(function(kind, profile, data)
    if kind~="UpdateData" or not profile:find(LocalPlayer.Name) then return end
    for lType,layout in layouts do processStock(data,lType,layout) end
end)

WeatherEventStarted.OnClientEvent:Connect(function(event,len)
    if not cfg"Weather Reporting" then return end
    local endUnix = math.round(workspace:GetServerTimeNow())+len
    webhookSend("Weather",{{
        name  ="WEATHER",
        value = event.."\nKết thúc: <t:"..endUnix..":R>",
        inline=true
    }})
end)
--// ---------------------------------------------------------------------------


--// ANTI‑AFK -------------------------------------------------------------------
if cfg"Anti-AFK" then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        simpleLog(LocalPlayer.Name.." • Anti‑AFK kích hoạt lúc "..os.date("%X"))
    end)
end
--// ---------------------------------------------------------------------------


--// AUTO‑REJOIN ----------------------------------------------------------------
if cfg"Auto-Reconnect" then
    GuiService.ErrorMessageChanged:Connect(function()
        simpleLog(LocalPlayer.Name.." bị disconnect • Rejoin sau 5s…")
        queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/NguyenNhandz/new/main/demo.lua'))()")
        wait(5)
        if #Players:GetPlayers()<=1 then
            TeleportService:Teleport(PlaceId,LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(PlaceId,JobId,LocalPlayer)
        end
    end)
end
--// ---------------------------------------------------------------------------

--=== END OF SCRIPT ===--
