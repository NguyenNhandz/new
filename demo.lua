local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI nhập key
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", gui)
local textbox = Instance.new("TextBox", frame)
local button = Instance.new("TextButton", frame)
local status = Instance.new("TextLabel", frame)

frame.Size = UDim2.new(0, 300, 0, 160)
frame.Position = UDim2.new(0.5, -150, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
textbox.PlaceholderText = "Nhập key Roblox"
textbox.Size = UDim2.new(1, -20, 0, 40)
textbox.Position = UDim2.new(0, 10, 0, 10)
textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textbox.TextColor3 = Color3.new(1,1,1)
textbox.Parent = frame

button.Text = "Xác minh"
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.new(0, 10, 0, 60)
button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
button.TextColor3 = Color3.new(1,1,1)
button.Parent = frame

status.Text = ""
status.Size = UDim2.new(1, -20, 0, 40)
status.Position = UDim2.new(0, 10, 0, 110)
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1
status.Parent = frame

-- Xử lý khi bấm nút
button.MouseButton1Click:Connect(function()
    local key = textbox.Text
    status.Text = "🔍 Kiểm tra key..."
    
    local success, response = pcall(function()
        return game:HttpGet("https://nguyentrungnhan.xyz/verify.php?key=" .. key)
    end)

    if success and response:find('"valid":true') then
        status.Text = "✅ Key hợp lệ, đang tải script..."
        wait(1)
        loadstring(game:HttpGet("https://nguyentrungnhan.xyz/script.lua"))()
        gui:Destroy()
    elseif success and response:find("expired") then
        status.Text = "⏰ Key đã hết hạn!"
    else
        status.Text = "❌ Key không hợp lệ!"
    end
end)
