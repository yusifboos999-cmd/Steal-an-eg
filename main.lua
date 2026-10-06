-- // ===================================================== //
-- //   Steal An Egg - Main Menu & 5 Server Browser          //
-- // ===================================================== //

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

-- رابط السكربت الخاص بك
local RAW_SCRIPT_URL = "https://raw.githubusercontent.com/yusifboos999-cmd/Steal-an-eg/refs/heads/main/main.lua" 

-- التعرف على كافة دوال queue_on_teleport للمحققات
local queuer = queue_on_teleport or (syn and syn.queue_on_teleport) or queueonteleport or (fluxus and fluxus.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)

local function prepareAutoExecute()
    if queuer then
        pcall(function()
            queuer([=[
                repeat task.wait() until game:IsLoaded()
                task.wait(1)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/yusifboos999-cmd/Steal-an-eg/refs/heads/main/main.lua"))()
            ]=])
        end)
    end
end

pcall(function()
    LocalPlayer.OnTeleport:Connect(function(State)
        prepareAutoExecute()
    end)
end)

-- 1. إنشاء واجهة المستخدم (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealAnEgg_ServerBrowser"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui
end

-- زر فتح/إغلاق القائمة
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Menu"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = ScreenGui

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

-- الإطار الرئيسي للقائمة
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 310, 0, 360)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Steal An Egg - Server List"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- نص إظهار الحالة
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "الحالة: جاهز"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 13
StatusLabel.Parent = MainFrame

-- زر تحديث/جلب 5 سيرفرات
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.9, 0, 0, 32)
RefreshBtn.Position = UDim2.new(0.05, 0, 0.17, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Text = "تحديث قائمة 5 سيرفرات (< 5 لاعبين)"
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.TextSize = 14
RefreshBtn.Parent = MainFrame

Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)

-- حاوية قائمة السيرفرات (Container)
local ServerContainer = Instance.new("ScrollingFrame")
ServerContainer.Size = UDim2.new(0.9, 0, 0, 240)
ServerContainer.Position = UDim2.new(0.05, 0, 0.28, 0)
ServerContainer.BackgroundTransparency = 1
ServerContainer.BorderSizePixel = 0
ServerContainer.ScrollBarThickness = 4
ServerContainer.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)
UIList.Parent = ServerContainer

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 2. دالة جلب 5 سيرفرات
local function Fetch5Servers()
    StatusLabel.Text = "جاري جلب 5 سيرفرات..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    -- مسح السيرفرات السابقة من القائمة
    for _, child in ipairs(ServerContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local currentJobId = game.JobId
    local placeId = game.PlaceId
    local foundServers = {}

    local apiUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, response = pcall(function()
        return game:HttpGet(apiUrl)
    end)

    if success and response then
        local data = HttpService:JSONDecode(response)
        if data and data.data then
            for _, server in ipairs(data.data) do
                if tostring(server.id) ~= tostring(currentJobId) and server.playing < 5 and server.playing < server.maxPlayers then
                    table.insert(foundServers, server)
                    if #foundServers >= 5 then
                        break
                    end
                end
            end
        end
    end

    if #foundServers > 0 then
        StatusLabel.Text = "تم العثور على " .. tostring(#foundServers) .. " سيرفرات!"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)

        for i, server in ipairs(foundServers) do
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 42)
            Card.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            Card.Parent = ServerContainer
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

            local Info = Instance.new("TextLabel")
            Info.Size = UDim2.new(0.6, 0, 1, 0)
            Info.Position = UDim2.new(0.03, 0, 0, 0)
            Info.BackgroundTransparency = 1
            Info.Text = "سيرفر " .. tostring(i) .. " (" .. tostring(server.playing) .. " لاعبين)"
            Info.TextColor3 = Color3.fromRGB(255, 255, 255)
            Info.Font = Enum.Font.SourceSansBold
            Info.TextSize = 13
            Info.TextXAlignment = Enum.TextXAlignment.Left
            Info.Parent = Card

            local JoinBtn = Instance.new("TextButton")
            JoinBtn.Size = UDim2.new(0.33, 0, 0.7, 0)
            JoinBtn.Position = UDim2.new(0.64, 0, 0.15, 0)
            JoinBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
            JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            JoinBtn.Text = "Join Server"
            JoinBtn.Font = Enum.Font.SourceSansBold
            JoinBtn.TextSize = 13
            JoinBtn.Parent = Card
            Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 4)

            JoinBtn.MouseButton1Click:Connect(function()
                StatusLabel.Text = "جاري الانتقال إلى سيرفر " .. tostring(i) .. "..."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                prepareAutoExecute()
                task.wait(0.3)
                TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
            end)
        end
    else
        StatusLabel.Text = "لم يتم العثور على سيرفرات مناسية حالياً"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- 3. دالة فحص البيض النادر تلقائياً فور الدخول
local function AutoScanEggOnJoin()
    task.wait(2)
    local foundEgg = nil
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("StringValue") or obj:IsA("Model") or obj:IsA("MeshPart") then
            local name = string.lower(obj.Name)
            local text = obj:IsA("TextLabel") and string.lower(obj.Text) or ""
            
            if string.find(name, "secret") or string.find(text, "secret") or
               string.find(name, "divine") or string.find(text, "divine") or
               string.find(name, "eternal") or string.find(text, "eternal") then
                foundEgg = obj.Name
                break
            end
        end
    end
    
    if foundEgg then
        StatusLabel.Text = "🎉 تم العثور على بيضة نادرة! (" .. tostring(foundEgg) .. ")"
        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        
        local sound = Instance.new("Sound", Workspace)
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 2
        sound:Play()
    else
        StatusLabel.Text = "لا توجد بيضة نادرة في هذا السيرفر حالياً"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

RefreshBtn.MouseButton1Click:Connect(Fetch5Servers)

-- تشغيل الجلب والفحص فور تشغيل السكربت
Fetch5Servers()
task.spawn(AutoScanEggOnJoin)
