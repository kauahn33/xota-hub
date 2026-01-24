--[[
    ═══════════════════════════════════════════════════════════════
    ██╗  ██╗    ██╗  ██╗██╗   ██╗██████╗ 
    ╚██╗██╔╝    ██║  ██║██║   ██║██╔══██╗
     ╚███╔╝     ███████║██║   ██║██████╔╝
     ██╔██╗     ██╔══██║██║   ██║██╔══██╗
    ██╔╝ ██╗    ██║  ██║╚██████╔╝██████╔╝
    ╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    ═══════════════════════════════════════════════════════════════
    Versão Standalone - Compatível com Arceus X NEO
    v2.0.0
    ═══════════════════════════════════════════════════════════════
]]

print("[Xota Hub] Iniciando...")

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES
-- ═══════════════════════════════════════════════════════════════
local CONFIG = {
    VERSION = "2.0.0",
    
    -- Cores do Tema
    THEME = {
        MainBackground = Color3.fromRGB(35, 10, 10),
        HeaderBackground = Color3.fromRGB(20, 5, 5),
        SidebarBackground = Color3.fromRGB(30, 8, 8),
        ButtonNormal = Color3.fromRGB(80, 20, 20),
        ButtonHover = Color3.fromRGB(120, 30, 30),
        ButtonActive = Color3.fromRGB(150, 40, 40),
        TextLight = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(255, 50, 50),
        SliderBackground = Color3.fromRGB(50, 15, 15),
        SliderFill = Color3.fromRGB(200, 30, 30),
        SliderKnob = Color3.fromRGB(255, 255, 255),
    },
    
    -- Dimensões
    UI = {
        MainSize = UDim2.new(0, 580, 0, 420),
        SidebarWidth = 140,
        TopBarHeight = 50,
        ButtonHeight = 35,
        SliderHeight = 45,
        MinimizedSize = UDim2.new(0, 65, 0, 65),
    },
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITÁRIOS
-- ═══════════════════════════════════════════════════════════════
local Utils = {}

function Utils.AddCorner(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = element
    return corner
end

function Utils.AddPadding(element, padding)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, padding)
    pad.PaddingBottom = UDim.new(0, padding)
    pad.PaddingLeft = UDim.new(0, padding)
    pad.PaddingRight = UDim.new(0, padding)
    pad.Parent = element
    return pad
end

function Utils.ToggleControls(enable)
    if enable then
        ContextActionService:UnbindAction("XHub_Freeze")
    else
        ContextActionService:BindAction("XHub_Freeze", function()
            return Enum.ContextActionResult.Sink
        end, false, unpack(Enum.PlayerActions:GetEnumItems()))
    end
end

function Utils.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Utils.MakeDraggableWithClick(frame, button, callback)
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = frame.Position
            Utils.ToggleControls(false)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                moved = true
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            Utils.ToggleControls(true)
            if not moved and callback then callback() end
        end
    end)
end

function Utils.Tween(instance, props, duration)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.2), props)
    tween:Play()
    return tween
end

function Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.Normalize(value, min, max)
    return (value - min) / (max - min)
end

function Utils.Map(value, inMin, inMax, outMin, outMax)
    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

-- ═══════════════════════════════════════════════════════════════
-- ESP SYSTEM
-- ═══════════════════════════════════════════════════════════════
local ESP = {
    Enabled = false,
    ShowDistance = false,
    ShowHealth = false,
    Highlights = {},
    Connections = {},
}

function ESP.Toggle(state)
    ESP.Enabled = state
    if state then ESP.Enable() else ESP.Disable() end
end

function ESP.Enable()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then ESP.AddToPlayer(player) end
    end
    
    ESP.Connections.Added = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            ESP.AddToCharacter(char, player)
        end)
        if player.Character then ESP.AddToCharacter(player.Character, player) end
    end)
    
    ESP.Connections.Removing = Players.PlayerRemoving:Connect(function(player)
        ESP.RemoveFromPlayer(player)
    end)
end

function ESP.Disable()
    for _, conn in pairs(ESP.Connections) do conn:Disconnect() end
    ESP.Connections = {}
    
    for player, data in pairs(ESP.Highlights) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    ESP.Highlights = {}
end

function ESP.AddToPlayer(player)
    if player.Character then ESP.AddToCharacter(player.Character, player) end
    player.CharacterAdded:Connect(function(char) ESP.AddToCharacter(char, player) end)
end

function ESP.AddToCharacter(char, player)
    if not ESP.Enabled then return end
    ESP.RemoveFromPlayer(player)
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "XHub_HL"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(139, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
    
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "XHub_Info"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = billboard
    
    ESP.Highlights[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Character = char
    }
end

function ESP.RemoveFromPlayer(player)
    if ESP.Highlights[player] then
        if ESP.Highlights[player].Highlight then ESP.Highlights[player].Highlight:Destroy() end
        if ESP.Highlights[player].Billboard then ESP.Highlights[player].Billboard:Destroy() end
        ESP.Highlights[player] = nil
    end
end

function ESP.UpdateInfo(player)
    if not ESP.Highlights[player] then return end
    local data = ESP.Highlights[player]
    local char = data.Character
    local humanoid = char:FindFirstChild("Humanoid")
    
    local text = player.Name
    
    if ESP.ShowHealth and humanoid then
        text = text .. "\n❤ " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
    end
    
    if ESP.ShowDistance then
        local localChar = LocalPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
            local dist = (localChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            text = text .. "\n📍 " .. math.floor(dist) .. "m"
        end
    end
    
    data.Label.Text = text
end

-- ═══════════════════════════════════════════════════════════════
-- AIMBOT SYSTEM
-- ═══════════════════════════════════════════════════════════════
local Aimbot = {
    Enabled = false,
    FOVVisible = false,
    FOVSize = 200,
    Smoothness = 50,
    Strength = 75,
    WallCheck = true,
    TeamCheck = true,
    RGB = false,
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2.5
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)

local hue = 0

local function isVisible(targetPart)
    if not Aimbot.WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 500
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(origin, direction, rayParams)
    return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function getClosestPlayer()
    local closest, shortestDist = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local char = player.Character
        if not char then continue end
        
        local head = char:FindFirstChild("Head")
        if not head then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist > Aimbot.FOVSize then continue end
        if not isVisible(head) then continue end
        
        if dist < shortestDist then
            shortestDist = dist
            closest = head
        end
    end
    
    return closest
end

local function smoothAim(targetPos)
    local smoothFactor = 1 - (Aimbot.Smoothness / 100 * 0.95)
    local strengthMult = Aimbot.Strength / 100
    
    local currentLook = Camera.CFrame.LookVector
    local targetLook = (targetPos - Camera.CFrame.Position).Unit
    local smoothedLook = currentLook:Lerp(targetLook, smoothFactor)
    local finalLook = currentLook:Lerp(smoothedLook, strengthMult)
    
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + finalLook)
end

-- ═══════════════════════════════════════════════════════════════
-- UI SYSTEM
-- ═══════════════════════════════════════════════════════════════
local UI = {
    ScreenGui = nil,
    MainFrame = nil,
    ContentArea = nil,
    Sidebar = nil,
    Categories = {},
    CurrentCategory = nil,
}

function UI.Create()
    -- ScreenGui
    UI.ScreenGui = Instance.new("ScreenGui")
    UI.ScreenGui.Name = "XHub_UI"
    UI.ScreenGui.ResetOnSpawn = false
    UI.ScreenGui.DisplayOrder = 999
    UI.ScreenGui.Parent = PlayerGui
    
    UI.CreateMainFrame()
    UI.CreateMinimized()
    
    print("[Xota Hub] ✓ Interface criada!")
end

function UI.CreateMainFrame()
    -- Main Frame
    UI.MainFrame = Instance.new("Frame")
    UI.MainFrame.Name = "MainFrame"
    UI.MainFrame.Size = CONFIG.UI.MainSize
    UI.MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
    UI.MainFrame.BackgroundColor3 = CONFIG.THEME.MainBackground
    UI.MainFrame.BackgroundTransparency = 0.1
    UI.MainFrame.BorderSizePixel = 0
    UI.MainFrame.Active = true
    UI.MainFrame.Parent = UI.ScreenGui
    Utils.AddCorner(UI.MainFrame, 12)
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, CONFIG.UI.TopBarHeight)
    topBar.BackgroundColor3 = CONFIG.THEME.HeaderBackground
    topBar.BorderSizePixel = 0
    topBar.Parent = UI.MainFrame
    Utils.AddCorner(topBar, 12)
    Utils.MakeDraggable(UI.MainFrame, topBar)
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "Xota Hub v" .. CONFIG.VERSION
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = CONFIG.THEME.TextLight
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Text = "—"
    minBtn.Size = UDim2.new(0, 50, 1, 0)
    minBtn.Position = UDim2.new(1, -100, 0, 0)
    minBtn.BackgroundTransparency = 1
    minBtn.TextColor3 = CONFIG.THEME.TextLight
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.Parent = topBar
    minBtn.MouseButton1Click:Connect(function() UI.MainFrame.Visible = false end)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 50, 1, 0)
    closeBtn.Position = UDim2.new(1, -50, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = CONFIG.THEME.TextLight
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = topBar
    closeBtn.MouseButton1Click:Connect(function() UI.ShowConfirm() end)
    
    -- Sidebar
    UI.Sidebar = Instance.new("ScrollingFrame")
    UI.Sidebar.Size = UDim2.new(0, CONFIG.UI.SidebarWidth, 1, -60)
    UI.Sidebar.Position = UDim2.new(0, 10, 0, CONFIG.UI.TopBarHeight + 5)
    UI.Sidebar.BackgroundColor3 = CONFIG.THEME.SidebarBackground
    UI.Sidebar.BackgroundTransparency = 0.2
    UI.Sidebar.BorderSizePixel = 0
    UI.Sidebar.ScrollBarThickness = 4
    UI.Sidebar.Parent = UI.MainFrame
    Utils.AddCorner(UI.Sidebar, 8)
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 8)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.Parent = UI.Sidebar
    
    -- Content Area
    UI.ContentArea = Instance.new("ScrollingFrame")
    UI.ContentArea.Size = UDim2.new(1, -(CONFIG.UI.SidebarWidth + 30), 1, -60)
    UI.ContentArea.Position = UDim2.new(0, CONFIG.UI.SidebarWidth + 20, 0, CONFIG.UI.TopBarHeight + 5)
    UI.ContentArea.BackgroundTransparency = 1
    UI.ContentArea.BorderSizePixel = 0
    UI.ContentArea.ScrollBarThickness = 4
    UI.ContentArea.Parent = UI.MainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = UI.ContentArea
    
    Utils.AddPadding(UI.ContentArea, 10)
end

function UI.CreateMinimized()
    local minimized = Instance.new("Frame")
    minimized.Name = "MinimizedBtn"
    minimized.Size = CONFIG.UI.MinimizedSize
    minimized.Position = UDim2.new(0.5, -32, 0.1, 0)
    minimized.BackgroundColor3 = CONFIG.THEME.SidebarBackground
    minimized.BorderSizePixel = 0
    minimized.ZIndex = 1000
    minimized.Parent = UI.ScreenGui
    Utils.AddCorner(minimized, 14)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "XH"
    btn.TextColor3 = CONFIG.THEME.TextLight
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    btn.ZIndex = 1001
    btn.Parent = minimized
    
    Utils.MakeDraggableWithClick(minimized, btn, function()
        UI.MainFrame.Visible = not UI.MainFrame.Visible
    end)
end

function UI.AddCategory(name, loadFunc)
    UI.Categories[name] = loadFunc
    
    local btn = Instance.new("TextButton")
    btn.Name = "Cat_" .. name
    btn.Size = UDim2.new(0, CONFIG.UI.SidebarWidth - 20, 0, CONFIG.UI.ButtonHeight)
    btn.BackgroundColor3 = CONFIG.THEME.ButtonNormal
    btn.Text = name
    btn.TextColor3 = CONFIG.THEME.TextLight
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = UI.Sidebar
    Utils.AddCorner(btn, 6)
    
    btn.MouseButton1Click:Connect(function() UI.LoadCategory(name) end)
end

function UI.LoadCategory(name)
    if not UI.Categories[name] then return end
    
    for _, child in ipairs(UI.ContentArea:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
            child:Destroy()
        end
    end
    
    UI.CurrentCategory = name
    UI.Categories[name]()
    
    for _, btn in ipairs(UI.Sidebar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3 = btn.Text == name and CONFIG.THEME.ButtonActive or CONFIG.THEME.ButtonNormal
        end
    end
end

function UI.AddToggle(text, default, callback)
    local state = default
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, CONFIG.UI.ButtonHeight)
    btn.BackgroundColor3 = state and CONFIG.THEME.ButtonActive or CONFIG.THEME.ButtonNormal
    btn.Text = text .. (state and " [ON]" or " [OFF]")
    btn.TextColor3 = CONFIG.THEME.TextLight
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = UI.ContentArea
    Utils.AddCorner(btn, 6)
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and CONFIG.THEME.ButtonActive or CONFIG.THEME.ButtonNormal
        callback(state)
    end)
end

function UI.AddSlider(text, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, CONFIG.UI.SliderHeight)
    container.BackgroundTransparency = 1
    container.Parent = UI.ContentArea
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = CONFIG.THEME.TextLight
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 22)
    sliderBg.BackgroundColor3 = CONFIG.THEME.SliderBackground
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    Utils.AddCorner(sliderBg, 4)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(Utils.Normalize(default, min, max), 0, 1, 0)
    fill.BackgroundColor3 = CO
