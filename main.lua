-- // ===================================================== //
-- //   Steal An Egg - Main Menu & Auto Low Server Hopper   //
-- // ===================================================== //

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- رابط السكربت الخاص بك
local RAW_SCRIPT_URL = "https://raw.githubusercontent.com/yusifboos999-cmd/Steal-an-eg/refs/heads/main/main.lua" 

-- التعرف على كافة دوال queue_on_teleport للمحققات المختلفة
local queuer = queue_on_teleport or (syn and syn.queue_on_teleport) or queueonteleport or (fluxus and fluxus.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)

-- دالة تجهيز السكربت للعمل بالسيرفر القادم بعد اكتمال التحميل
local function prepareAutoExecute()
    if queuer then
        pcall(function()
            queuer([=[
                repeat task.wait() until game:IsLoaded()
                task.wait(1.5)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/yusifboos999-cmd/Steal-an-eg/refs/heads/main/main.lua"))()
            ]=])
        end)
    end
end

-- ربط التجهيز بحدث الانتقال التلقائي للعبة لضمان عدم ضياع الأمر
pcall(function()
    LocalPlayer.OnTeleport:Connect(function(State)
        prepareAutoExecute()
    end)
end)

-- 2. إنشاء واجهة المستخدم (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealAnEgg_ServerHopper"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui
end

-- زر فتح/إغلاق القائمة (مخصص للجوال)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Menu"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = ScreenGui

local UICornerBtn = Instance.new("UICorner", ToggleBtn)
UICornerBtn.CornerRadius = UDim.new(0, 10)

-- الإطار الرئيسي للقائمة
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner", MainFrame)
UICornerMain.CornerRadius = UDim.new(0, 12)

-- العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Steal An Egg - Main Menu"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- نص إظهار الحالة
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "الحالة: جاهز"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- زر Change Server
local ChangeServerBtn = Instance.new("TextButton")
ChangeServerBtn.Size = UDim2.new(0.85, 0, 0, 45)
ChangeServerBtn.Position = UDim2.new(0.075, 0, 0.6, 0)
ChangeServerBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ChangeServerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ChangeServerBtn.Text = "Change Server (<= 3 Players)"
ChangeServerBtn.Font = Enum.Font.SourceSansBold
ChangeServerBtn.TextSize = 16
ChangeServerBtn.Parent = MainFrame

local UICornerBtn2 = Instance.new("UICorner", ChangeServerBtn)
UICornerBtn2.CornerRadius = UDim.new(0, 8)

-- إخفاء/إظهار القائمة
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 3. دالة البحث عن سيرفر يحتوي على 3 أشخاص أو أقل
local function HopToLowServer()
    StatusLabel.Text = "الحالة: جاري البحث عن سيرفر..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    local currentJobId = game.JobId
    local placeId = game.PlaceId
    local foundServer = nil

    local apiUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, response = pcall(function()
        return game:HttpGet(apiUrl)
    end)

    if success and response then
        local data = HttpService:JSONDecode(response)
        if data and data.data then
            for _, server in ipairs(data.data) do
                if tostring(server.id) ~= tostring(currentJobId) and server.playing <= 3 and server.playing < server.maxPlayers then
                    foundServer = server.id
                    break
                end
            end
        end
    end

    if foundServer then
        StatusLabel.Text = "تم العثور! جاري الانتقال..."
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- تجهيز التفعيل التلقائي قبل الانتقال مباشرة
        prepareAutoExecute()
        
        task.wait(0.5)
        
        -- الانتقال للسيرفر
        TeleportService:TeleportToPlaceInstance(placeId, foundServer, LocalPlayer)
    else
        StatusLabel.Text = "لم يتم العثور على سيرفر مناسب، حاول لاحقاً"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

ChangeServerBtn.MouseButton1Click:Connect(function()
    HopToLowServer()
end)
