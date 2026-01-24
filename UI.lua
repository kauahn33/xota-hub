--[[
    Xota Hub - Sistema de Interface
    Gerencia toda a criação e interação da UI
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UI = {}
local ActiveElements = {}
local Categories = {}
local CurrentCategory = nil

-- Referências principais
local ScreenGui, MainFrame, ContentArea, Sidebar, MinimizedButton

function UI.Create(theme)
    UI.Theme = theme
    
    -- ScreenGui principal
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XHub_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = PlayerGui
    
    UI.CreateMainFrame()
    UI.CreateMinimizedButton()
    
    return ScreenGui
end

function UI.CreateMainFrame()
    local Utils = require(script.Parent.Utils)
    local Config = require(script.Parent.Config)
    
    -- Frame principal
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Config.UI.MainFrameSize
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
    MainFrame.BackgroundColor3 = UI.Theme.MainBackground
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    Utils.AddCorner(MainFrame, Config.UI.CornerRadius)
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, Config.UI.TopBarHeight)
    topBar.BackgroundColor3 = UI.Theme.HeaderBackground
    topBar.BorderSizePixel = 0
    topBar.Parent = MainFrame
    Utils.AddCorner(topBar, Config.UI.CornerRadius)
    Utils.MakeDraggable(MainFrame, topBar)
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Text = Config.SCRIPT_NAME:upper() .. " v" .. Config.VERSION
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = UI.Theme.TextLight
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar
    
    -- Botão Minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Text = "—"
    minimizeBtn.Size = UDim2.new(0, 50, 1, 0)
    minimizeBtn.Position = UDim2.new(1, -100, 0, 0)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.TextColor3 = UI.Theme.TextLight
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 20
    minimizeBtn.Parent = topBar
    
    minimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    
    -- Botão Fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 50, 1, 0)
    closeBtn.Position = UDim2.new(1, -50, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = UI.Theme.TextLight
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = topBar
    
    closeBtn.MouseButton1Click:Connect(function()
        UI.ShowConfirmDialog("Deseja realmente fechar o Xota Hub?", function()
            ScreenGui:Destroy()
        end)
    end)
    
    -- Sidebar
    Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, Config.UI.SidebarWidth, 1, -(Config.UI.TopBarHeight + 20))
    Sidebar.Position = UDim2.new(0, 10, 0, Config.UI.TopBarHeight + 10)
    Sidebar.BackgroundColor3 = UI.Theme.SidebarBackground
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 4
    Sidebar.ScrollBarImageColor3 = UI.Theme.Accent
    Sidebar.Parent = MainFrame
    Utils.AddCorner(Sidebar, 8)
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 8)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.Parent = Sidebar
    
    -- Content Area
    ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -(Config.UI.SidebarWidth + 30), 1, -(Config.UI.TopBarHeight + 20))
    ContentArea.Position = UDim2.new(0, Config.UI.SidebarWidth + 20, 0, Config.UI.TopBarHeight + 10)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ScrollBarThickness = 4
    ContentArea.ScrollBarImageColor3 = UI.Theme.Accent
    ContentArea.Parent = MainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, Config.UI.Padding)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = ContentArea
    
    Utils.AddPadding(ContentArea, Config.UI.Padding)
end

function UI.CreateMinimizedButton()
    local Utils = require(script.Parent.Utils)
    local Config = require(script.Parent.Config)
    
    MinimizedButton = Instance.new("Frame")
    MinimizedButton.Name = "MinimizedButton"
    MinimizedButton.Size = Config.UI.MinimizedSize
    MinimizedButton.Position = UDim2.new(0.5, -32, 0.1, 0)
    MinimizedButton.BackgroundColor3 = UI.Theme.SidebarBackground
    MinimizedButton.BorderSizePixel = 0
    MinimizedButton.ZIndex = 1000
    MinimizedButton.Parent = ScreenGui
    Utils.AddCorner(MinimizedButton, 14)
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = "XH"
    button.TextColor3 = UI.Theme.TextLight
    button.Font = Enum.Font.GothamBold
    button.TextSize = 24
    button.ZIndex = 1001
    button.Parent = MinimizedButton
    
    Utils.MakeDraggableWithClick(MinimizedButton, button, function()
        MainFrame.Visible = not MainFrame.Visible
    end)
end

function UI.AddCategory(name, loadFunction)
    Categories[name] = loadFunction
    
    local Utils = require(script.Parent.Utils)
    local Config = require(script.Parent.Config)
    
    local btn = Instance.new("TextButton")
    btn.Name = "Cat_" .. name
    btn.Size = UDim2.new(0, Config.UI.SidebarWidth - 20, 0, Config.UI.ButtonHeight)
    btn.BackgroundColor3 = UI.Theme.ButtonNormal
    btn.Text = name
    btn.TextColor3 = UI.Theme.TextLight
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = Sidebar
    Utils.AddCorner(btn, 6)
    
    Utils.AddHoverEffect(btn, UI.Theme.ButtonNormal, UI.Theme.ButtonHover)
    
    btn.MouseButton1Click:Connect(function()
        UI.LoadCategory(name)
    end)
end

function UI.LoadCategory(name)
    if not Categories[name] then return end
    
    -- Limpar conteúdo anterior
    for _, child in ipairs(ContentArea:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
            child:Destroy()
        end
    end
    
    ActiveElements = {}
    CurrentCategory = name
    Categories[name]()
    
    -- Destacar botão ativo
    for _, btn in ipairs(Sidebar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3 = btn.Text == name and UI.Theme.ButtonActive or UI.Theme.ButtonNormal
        end
    end
end

function UI.AddToggle(text, defaultState, callback)
    local Utils = require(script.Parent.Utils)
    local Config = require(script.Parent.Config)
    
    local state = defaultState
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, Config.UI.ButtonHeight)
    btn.BackgroundColor3 = state and UI.Theme.ButtonActive or UI.Theme.ButtonNormal
    btn.Text = text .. (state and " [ON]" or " [OFF]")
    btn.TextColor3 = UI.Theme.TextLight
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = ContentArea
    Utils.AddCorner(btn, 6)
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and UI.Theme.ButtonActive or UI.Theme.ButtonNormal
        callback(state)
    end)
    
    table.insert(ActiveElements, btn)
end

function UI.AddSlider(text, min, max, default, callback)
    local Utils = require(script.Parent.Utils)
    local Config = require(script.Parent.Config)
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, Config.UI.SliderHeight)
    container.BackgroundTransparency = 1
    container.Parent = ContentArea
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = UI.Theme.TextLight
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 22)
    sliderBg.BackgroundColor3 = UI.Theme.SliderBackground
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    Utils.AddCorner(sliderBg, 4)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(Utils.Normalize(default, min, max), 0, 1, 0)
    sliderFill.BackgroundColor3 = UI.Theme.SliderFill
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    Utils.AddCorner(sliderFill, 4)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(Utils.Normalize(default, min, max), -8, 0.5, -8)
    knob.BackgroundColor3 = UI.Theme.SliderKnob
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = sliderBg
    Utils.AddCorner(knob, 8)
    
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
        local percent = relativeX / sliderBg.AbsoluteSize.X
        local value = Utils.Round(Utils.Map(percent, 0, 1, min, max))
        
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0.5, -8)
        label.Text = text .. ": " .. value
        
        callback(value)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
        end
    end)
    
    table.insert(ActiveElements, container)
end

function UI.AddButton(text, callback)
    local Utils = require(script.Parent.Utils)
    local Config = require(script.Parent.Config)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, Config.UI.ButtonHeight)
    btn.BackgroundColor3 = UI.Theme.ButtonNormal
    btn.Text = text
    btn.TextColor3 = UI.Theme.TextLight
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = ContentArea
    Utils.AddCorner(btn, 6)
    
    Utils.AddHoverEffect(btn, UI.Theme.ButtonNormal, UI.Theme.ButtonHover)
    
    btn.MouseButton1Click:Connect(callback)
    
    table.insert(ActiveElements, btn)
end

function UI.ShowConfirmDialog(message, onConfirm)
    local Utils = require(script.Parent.Utils)
    
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.ZIndex = 5000
    overlay.Parent = ScreenGui
    
    local dialog = Instance.new("Frame")
    dialog.Size = UDim2.new(0, 400, 0, 180)
    dialog.Position = UDim2.new(0.5, -200, 0.5, -90)
    dialog.BackgroundColor3 = UI.Theme.MainBackground
    dialog.ZIndex = 5001
    dialog.Parent = overlay
    Utils.AddCorner(dialog, 12)
    
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -40, 0, 80)
    msg.Position = UDim2.new(0, 20, 0, 20)
    msg.BackgroundTransparency = 1
    msg.Text = message
    msg.TextColor3 = UI.Theme.TextLight
    msg.Font = Enum.Font.GothamBold
    msg.TextSize = 16
    msg.TextWrapped = true
    msg.ZIndex = 5002
    msg.Parent = dialog
    
    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0, 150, 0, 45)
    yesBtn.Position = UDim2.new(0, 20, 1, -65)
    yesBtn.BackgroundColor3 = UI.Theme.ButtonActive
    yesBtn.Text = "SIM"
    yesBtn.TextColor3 = UI.Theme.TextLight
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.TextSize = 14
    yesBtn.ZIndex = 5002
    yesBtn.Parent = dialog
    Utils.AddCorner(yesBtn, 8)
    
    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0, 150, 0, 45)
    noBtn.Position = UDim2.new(1, -170, 1, -65)
    noBtn.BackgroundColor3 = UI.Theme.ButtonNormal
    noBtn.Text = "NÃO"
    noBtn.TextColor3 = UI.Theme.TextLight
    noBtn.Font = Enum.Font.GothamBold
    noBtn.TextSize = 14
    noBtn.ZIndex = 5002
    noBtn.Parent = dialog
    Utils.AddCorner(noBtn, 8)
    
    yesBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
        if onConfirm then onConfirm() end
    end)
    
    noBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
end

function UI.ResetPosition()
    local Config = require(script.Parent.Config)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
    MinimizedButton.Position = UDim2.new(0.5, -32, 0.1, 0)
end

return UI
