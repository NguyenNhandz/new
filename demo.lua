-- GUI nhập key
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", gui)
local textbox = Instance.new("TextBox", frame)
local button = Instance.new("TextButton", frame)
local status = Instance.new("TextLabel", frame)

frame.Size = UDim2.new(0, 300, 0, 160)
frame.Position = UDim2.new(0.5, -150, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2

textbox.PlaceholderText = "Nhập key từ trang nguyentrungnhan.xyz"
textbox.Size = UDim2.new(1, -20, 0, 40)
textbox.Position = UDim2.new(0, 10, 0, 10)
textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textbox.TextColor3 = Color3.new(1, 1, 1)

button.Text = "✅ Xác minh"
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.new(0, 10, 0, 60)
button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
button.TextColor3 = Color3.new(1, 1, 1)

status.Text = ""
status.Size = UDim2.new(1, -20, 0, 40)
status.Position = UDim2.new(0, 10, 0, 110)
status.TextColor3 = Color3.new(1, 1, 1)
status.BackgroundTransparency = 1

-- Xác minh key
button.MouseButton1Click:Connect(function()
    local key = textbox.Text
    status.Text = "🔄 Đang xác minh key..."
    local success, response = pcall(function()
        return game:HttpGet("https://nguyentrungnhan.xyz/verify.php?key=" .. key)
    end)

    if success and response:find("true") then
        status.Text = "✅ Key đúng! Đang tải script..."
        wait(1)
        loadstring(game:HttpGet("https://nguyentrungnhan.xyz/script.lua"))()
        gui:Destroy()
    else
        status.Text = "❌ Key không hợp lệ! Vui lòng thử lại."
    end
end)
