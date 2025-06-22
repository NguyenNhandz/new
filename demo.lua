local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Cấu hình
local apiUrl = "http://5.231.28.109:22060/checkkey?key="  -- ⚠️ Đổi IP

-- UI chính
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "KeyAuthGui"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 180)
Frame.Position = UDim2.new(0.5, -150, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5, 0.5)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🔑 Nhập Key từ Discord"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(0.9, 0, 0, 30)
TextBox.Position = UDim2.new(0.05, 0, 0.4, 0)
TextBox.PlaceholderText = "Nhập key tại đây..."
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 16
TextBox.Text = ""
TextBox.ClearTextOnFocus = false
TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextBox.TextColor3 = Color3.new(1,1,1)
TextBox.BorderSizePixel = 0

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(0.9, 0, 0, 30)
Button.Position = UDim2.new(0.05, 0, 0.7, 0)
Button.Text = "🔓 Kiểm Tra Key"
Button.Font = Enum.Font.GothamSemibold
Button.TextSize = 16
Button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
Button.TextColor3 = Color3.new(1, 1, 1)
Button.BorderSizePixel = 0

local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 1, -20)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.Text = ""
Status.Font = Enum.Font.Gotham
Status.TextSize = 14

-- Kiểm tra key
Button.MouseButton1Click:Connect(function()
	local key = TextBox.Text
	if key == "" then
		Status.Text = "⚠️ Bạn chưa nhập key."
		return
	end

	Status.Text = "⏳ Đang kiểm tra..."

	local success, response = pcall(function()
		return HttpService:GetAsync(apiUrl .. key)
	end)

	if success then
		local data = HttpService:JSONDecode(response)
		if data.valid then
			Status.Text = "✅ Key hợp lệ. Đang tải script..."

			-- Gọi script thật từ link
			wait(1)
			pcall(function()
				loadstring(game:HttpGet("https://your-link.com/script.lua"))()
			end)

			ScreenGui:Destroy()
		else
			Status.Text = "❌ Key sai: " .. (data.reason or "Không xác định")
		end
	else
		Status.Text = "❌ Lỗi kết nối tới server."
	end
end)

