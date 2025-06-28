--[[
    @author depso (depthso)
    @modified Nguyen Nhan
    @description Grow a Garden stock bot full script with rejoin + AFK + 2 webhook log
    https://www.roblox.com/games/126884695634066
]]

type table = {
	[any]: any
}

_G.Configuration = {
	--// Reporting
	["Enabled"] = true,
	["Webhook_Stock"] = "https://discord.com/api/webhooks/1388136766648746145/A8as0rs5kUSWxMQQLagMbrc41Ef3tyoer8YR25tvVk0i3guNkEiiWnhooj4YP6COuVbj", -- Webhook 1: STOCK
	["Webhook_Log"] = "https://discord.com/api/webhooks/1388136802342146208/LqqE8pdN3JyzX2EXt4rf282ewLGClVPtnE2jZhq7KyzTfDiY5-r_sYr3RdzMq-TMHRql",     -- Webhook 2: Log (AFK/Rejoin)
	["Weather Reporting"] = true,

	--// User
	["Anti-AFK"] = true,
	["Auto-Reconnect"] = true,
	["Rendering Enabled"] = false,

	--// Embeds
	["AlertLayouts"] = {
		["Weather"] = {
			WebhookTarget = "Webhook_Log",
			EmbedColor = Color3.fromRGB(42, 109, 255),
		},
		["SeedsAndGears"] = {
			WebhookTarget = "Webhook_Stock",
			EmbedColor = Color3.fromRGB(56, 238, 23),
			Layout = {
				["ROOT/SeedStock/Stocks"] = "SEEDS STOCK",
				["ROOT/GearStock/Stocks"] = "GEAR STOCK"
			}
		},
		["EventShop"] = {
			WebhookTarget = "Webhook_Stock",
			EmbedColor = Color3.fromRGB(212, 42, 255),
			Layout = {
				["ROOT/EventShopStock/Stocks"] = "EVENT STOCK"
			}
		},
		["Eggs"] = {
			WebhookTarget = "Webhook_Stock",
			EmbedColor = Color3.fromRGB(251, 255, 14),
			Layout = {
				["ROOT/PetEggStock/Stocks"] = "EGG STOCK"
			}
		},
		["CosmeticStock"] = {
			WebhookTarget = "Webhook_Stock",
			EmbedColor = Color3.fromRGB(255, 106, 42),
			Layout = {
				["ROOT/CosmeticStock/ItemStocks"] = "COSMETIC ITEMS STOCK"
			}
		}
	}
}

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

--// Remotes
local DataStream = ReplicatedStorage.GameEvents.DataStream
local WeatherEventStarted = ReplicatedStorage.GameEvents.WeatherEventStarted

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

-- Prevent duplicate
if _G.StockBot then return end 
_G.StockBot = true

-- Set rendering
RunService:Set3dRenderingEnabled(_G.Configuration["Rendering Enabled"])

-- Get config value
local function GetConfigValue(Key: string)
	return _G.Configuration[Key]
end

-- Convert Color3 to Hex
local function ConvertColor3(Color: Color3): number
	return tonumber(Color:ToHex(), 16)
end

-- Get remote data
local function GetDataPacket(Data, Target: string)
	for _, Packet in Data do
		local Name, Content = Packet[1], Packet[2]
		if Name == Target then return Content end
	end
end

-- Send webhook
local function WebhookSend(TargetType: string, Fields: table)
	if not GetConfigValue("Enabled") then return end

	local Layout = _G.Configuration["AlertLayouts"][TargetType]
	if not Layout then return end

	local WebhookField = Layout.WebhookTarget or "Webhook_Log"
	local Webhook = GetConfigValue(WebhookField)
	local Color = ConvertColor3(Layout.EmbedColor)

	local Body = {
		embeds = {{
			color = Color,
			fields = Fields,
			footer = { text = "Made by depso - Modified by Nguyen Nhan" },
			timestamp = DateTime.now():ToIsoDate()
		}}
	}

	local RequestData = {
        Url = Webhook,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(Body)
    }

	task.spawn(request, RequestData)
end

-- Gửi log đơn giản (dạng 1 dòng)
local function SendSimpleLog(msg: string)
	local Webhook = GetConfigValue("Webhook_Log")
	local Body = { content = "**[LOG]** " .. msg }

	local RequestData = {
        Url = Webhook,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(Body)
    }

	task.spawn(request, RequestData)
end

-- Format stock string
local function MakeStockString(Stock: table): string
	local str = ""
	for Name, Data in Stock do 
		local Amount = Data.Stock
		local EggName = Data.EggName 
		Name = EggName or Name
		str ..= `{Name} **x{Amount}**\n`
	end
	return str
end

-- Process stock data
local function ProcessPacket(Data, Type: string, Layout)
	local Fields, FieldsLayout = {}, Layout.Layout
	if not FieldsLayout then return end

	for Packet, Title in FieldsLayout do 
		local Stock = GetDataPacket(Data, Packet)
		if not Stock then return end

		table.insert(Fields, {
			name = Title,
			value = MakeStockString(Stock),
			inline = true
		})
	end

	WebhookSend(Type, Fields)
end

-- Khi nhận packet stock
DataStream.OnClientEvent:Connect(function(Type: string, Profile: string, Data: table)
	if Type ~= "UpdateData" then return end
	if not Profile:find(LocalPlayer.Name) then return end

	for Name, Layout in _G.Configuration["AlertLayouts"] do
		ProcessPacket(Data, Name, Layout)
	end
end)

-- Khi có thời tiết
WeatherEventStarted.OnClientEvent:Connect(function(Event: string, Length: number)
	if not GetConfigValue("Weather Reporting") then return end

	local EndUnix = math.round(workspace:GetServerTimeNow()) + Length

	WebhookSend("Weather", {{
		name = "WEATHER",
		value = `{Event}\nKết thúc: <t:{EndUnix}:R>`,
		inline = true
	}})
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
	if not GetConfigValue("Anti-AFK") then return end
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
	SendSimpleLog(LocalPlayer.Name .. " đã được cứu khỏi AFK lúc " .. os.date("%X"))
end)

-- Auto reconnect
GuiService.ErrorMessageChanged:Connect(function()
	if not GetConfigValue("Auto-Reconnect") then return end
	SendSimpleLog(LocalPlayer.Name .. " bị disconnect. Tự động rejoin sau 5s...")

	queue_on_teleport("https://raw.githubusercontent.com/depthso/Grow-a-Garden/main/Stock%20bot.lua")

	wait(5)
	if #Players:GetPlayers() <= 1 then
		TeleportService:Teleport(PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
	end
end)

-- Gửi log vào game
SendSimpleLog(LocalPlayer.Name .. " đã vào game Grow a Garden | Server: " .. JobId)
