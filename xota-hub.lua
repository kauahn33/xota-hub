--[[
    📌 SCRIPT: RED DARK UI - XH TOGGLE & DRAG FIX
    -------------------------------------------------------------------
    Ajustes:
    - Quadrado XH agora arrasta e clica perfeitamente.
    - Função Toggle: O quadrado abre E fecha a janela.
    - Janela de confirmação gigante sem fundo preto.
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configurações de Cores
local THEME = {
    MainBackground = Color3.fromRGB(35, 10, 10),
    HeaderBackground = Color3.fromRGB(20, 5, 5),
    SidebarBackground = Color3.fromRGB(30, 8, 8),
    ButtonNormal = Color3.fromRGB(80, 20, 20),
    ButtonHover = Color3.fromRGB(120, 30, 30),
    TextLight = Color3.fromRGB(255, 255, 255),
    HighlightFill = Color3.fromRGB(255, 0, 0),
    HighlightOutline = Color3.fromRGB(139, 0, 0)
}

local espEnabled = false
local espConnectionAdded = nil

--------------------------------------------------------------------------------
-- 1. SISTEMA DE CONTROLE (LOCK)
--------------------------------------------------------------------------------
local function toggleControls(enable)
    if enable then
        ContextActionService:UnbindAction("FreezeControls")
    else
        ContextActionService:BindAction("FreezeControls", function()
            return Enum.ContextActionResult.Sink
        end, false, unpack(Enum.PlayerActions:GetEnumItems()), Enum.UserInputType.MouseButton2, Enum.UserInputType.Touch)
    end
end

--------------------------------------------------------------------------------
-- 2. SISTEMA DE ARRASTE E CLIQUE (XH FIX)
--------------------------------------------------------------------------------
-- Função especial para o quadrado XH não bugar o clique com o arraste
local function makeDraggableAndClickable(frame, textButton, callback)
    local dragging = false
    local dragInput, dragStart, startPos
    local moved = false -- Verifica se o mouse se moveu para saber se foi arraste ou clique

    textButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = frame.Position
            toggleControls(false)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 3 then -- Se moveu mais de 3 pixels, é um arraste
                moved = true
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                toggleControls(true)
                if not moved then -- Se NÃO se moveu, foi apenas um clique!
                    callback()
                end
            end
        end
    end)
end

-- Arraste simples para a janela principal
local function makeSimpleDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

--------------------------------------------------------------------------------
-- 3. CONSTRUÇÃO DA INTERFACE
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RedDarkUI_Ultimate"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

-- == JANELA PRINCIPAL ==
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = THEME.MainBackground
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 12)
makeSimpleDraggable(MainFrame)

-- Barra Superior
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = THEME.HeaderBackground
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
addCorner(TopBar, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "RED DARK MENU"
TitleLabel.Size = UDim2.new(0, 250, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = THEME.TextLight
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 45, 0, 45)
CloseBtn.Position = UDim2.new(1, -45, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = THEME.TextLight
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Text = "-"
MinimizeBtn.Size = UDim2.new(0, 45, 0, 45)
MinimizeBtn.Position = UDim2.new(1, -90, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.TextColor3 = THEME.TextLight
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 22
MinimizeBtn.Parent = TopBar

-- Sidebar
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 130, 1, -70)
Sidebar.Position = UDim2.new(0, 12, 0, 55)
Sidebar.BackgroundColor3 = THEME.SidebarBackground
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame
addCorner(Sidebar, 8)

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.Parent = Sidebar

-- Conteúdo
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -165, 1, -70)
ContentArea.Position = UDim2.new(0, 150, 0, 55)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.Parent = ContentArea

-- == QUADRADO MINIMIZADO (XH) ==
local MinimizedButton = Instance.new("Frame")
MinimizedButton.Name = "MinimizedButton"
MinimizedButton.Size = UDim2.new(0, 60, 0, 60)
MinimizedButton.Position = UDim2.new(0.5, -30, 0.5, -30) -- Começa no meio
MinimizedButton.BackgroundColor3 = THEME.SidebarBackground -- Cor das categorias
MinimizedButton.BorderSizePixel = 0
MinimizedButton.ZIndex = 1000
MinimizedButton.Parent = ScreenGui
addCorner(MinimizedButton, 12)

local MinimizedText = Instance.new("TextButton")
MinimizedText.Size = UDim2.new(1, 0, 1, 0)
MinimizedText.BackgroundTransparency = 1
MinimizedText.Text = "XH"
MinimizedText.TextColor3 = Color3.new(1, 1, 1) -- Branco puro
MinimizedText.Font = Enum.Font.GothamBold
MinimizedText.TextSize = 22
MinimizedText.ZIndex = 1001
MinimizedText.Parent = MinimizedButton

-- Lógica de Arrastar E Alternar (Toggle)
makeDraggableAndClickable(MinimizedButton, MinimizedText, function()
    MainFrame.Visible = not MainFrame.Visible -- Abre se fechado, fecha se aberto
end)

--------------------------------------------------------------------------------
-- 4. FUNÇÕES ESP
--------------------------------------------------------------------------------
local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        local function applyHighlight(char)
            if not char:FindFirstChild("CommunityHighlight") then
                local h = Instance.new("Highlight")
                h.Name = "CommunityHighlight"
                h.FillColor = THEME.HighlightFill
                h.OutlineColor = THEME.HighlightOutline
                h.FillTransparency = 0.5
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = char
            end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then applyHighlight(p.Character) end
        end
        espConnectionAdded = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(applyHighlight)
        end)
    else
        if espConnectionAdded then espConnectionAdded:Disconnect() end
        for _, p in ipairs(Players:GetPlayers()) do
            local c = p.Character
            if c and c:FindFirstChild("CommunityHighlight") then
                c.CommunityHighlight:Destroy()
            end
        end
    end
    return espEnabled
end



--------------------------------------------------------------------------------
-- 8. AIMBOT + AIMFOV SYSTEM (APENAS ADIÇÃO)
--------------------------------------------------------------------------------

local Camera = workspace.CurrentCamera

-- CONFIG
local AimSettings = {
    Enabled = false,
    FOVEnabled = false,
    FOVSize = 200,
    FOVPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2),
    WallCheck = true,
    TeamCheck = true,
    FriendCheck = true,
    RGB = false
}

-- AIM FOV CIRCLE
local AimCircle = Drawing.new("Circle")
AimCircle.Thickness = 2
AimCircle.NumSides = 100
AimCircle.Filled = false
AimCircle.Visible = false
AimCircle.Radius = AimSettings.FOVSize
AimCircle.Position = AimSettings.FOVPos
AimCircle.Color = Color3.fromRGB(255,0,0)

-- RGB
local hue = 0

RunService.RenderStepped:Connect(function()
    if AimSettings.FOVEnabled then
        AimCircle.Visible = true
        AimCircle.Radius = AimSettings.FOVSize
        AimCircle.Position = AimSettings.FOVPos

        if AimSettings.RGB then
            hue = (hue + 1) % 360
            AimCircle.Color = Color3.fromHSV(hue/360,1,1)
        end
    else
        AimCircle.Visible = false
    end
end)

-- WALL CHECK
local function isVisible(target)
    if not AimSettings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, rayParams)
    return result and result.Instance:IsDescendantOf(target.Parent)
end

-- GET TARGET
local function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if AimSettings.TeamCheck and p.Team == LocalPlayer.Team then continue end
            if AimSettings.FriendCheck and LocalPlayer:IsFriendsWith(p.UserId) then continue end

            local head = p.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mag = (Vector2.new(screenPos.X, screenPos.Y) - AimSettings.FOVPos).Magnitude
                if mag < AimSettings.FOVSize and mag < dist and isVisible(head) then
                    dist = mag
                    closest = head
                end
            end
        end
    end
    return closest
end

-- AIMBOT LOOP
RunService.RenderStepped:Connect(function()
    if AimSettings.Enabled then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

--------------------------------------------------------------------------------
-- 9. UI AIM TAB (BOTÕES 25% MENORES)
--------------------------------------------------------------------------------

local function createSmallButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30) -- 25% menor
    btn.BackgroundColor3 = THEME.ButtonNormal
    btn.Text = text
    btn.TextColor3 = THEME.TextLight
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = ContentArea
    addCorner(btn, 6)

    btn.MouseButton1Click:Connect(function()
        local state = callback()
        btn.BackgroundColor3 = state and THEME.ButtonHover or THEME.ButtonNormal
    end)
end

local function loadAim()
    for _, obj in pairs(ContentArea:GetChildren()) do
        if obj:IsA("TextButton") then obj:Destroy() end
    end

    createSmallButton("AimBot [OFF]", function()
        AimSettings.Enabled = not AimSettings.Enabled
        return AimSettings.Enabled
    end)

    createSmallButton("AimFOV [OFF]", function()
        AimSettings.FOVEnabled = not AimSettings.FOVEnabled
        return AimSettings.FOVEnabled
    end)

    createSmallButton("Wall Check", function()
        AimSettings.WallCheck = not AimSettings.WallCheck
        return AimSettings.WallCheck
    end)

    createSmallButton("Team Check", function()
        AimSettings.TeamCheck = not AimSettings.TeamCheck
        return AimSettings.TeamCheck
    end)

    createSmallButton("Friend Check", function()
        AimSettings.FriendCheck = not AimSettings.FriendCheck
        return AimSettings.FriendCheck
    end)

    createSmallButton("FOV RGB", function()
        AimSettings.RGB = not AimSettings.RGB
        return AimSettings.RGB
    end)
end

-- TAB AIM
local aimTab = Instance.new("TextButton")
aimTab.Size = UDim2.new(0, 110, 0, 35)
aimTab.BackgroundColor3 = THEME.ButtonNormal
aimTab.Text = "Aim"
aimTab.TextColor3 = THEME.TextLight
aimTab.Font = Enum.Font.GothamBold
aimTab.Parent = Sidebar
addCorner(aimTab, 6)
aimTab.MouseButton1Click:Connect(loadAim)

--------------------------------------------------------------------------------
-- 10. SETAS PARA MOVER O FOV (↑ ↓ ← →)
--------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Up then
        AimSettings.FOVPos += Vector2.new(0, -10)
    elseif input.KeyCode == Enum.KeyCode.Down then
        AimSettings.FOVPos += Vector2.new(0, 10)
    elseif input.KeyCode == Enum.KeyCode.Left then
        AimSettings.FOVPos += Vector2.new(-10, 0)
    elseif input.KeyCode == Enum.KeyCode.Right then
        AimSettings.FOVPos += Vector2.new(10, 0)
    end
end)



--------------------------------------------------------------------------------
-- 5. CATEGORIAS
--------------------------------------------------------------------------------
local function loadEsp()
    for _, obj in pairs(ContentArea:GetChildren()) do if obj:IsA("TextButton") then obj:Destroy() end end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = THEME.ButtonNormal
    btn.Text = "Player ESP [OFF]"
    btn.TextColor3 = THEME.TextLight
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = ContentArea
    addCorner(btn, 8)
    btn.MouseButton1Click:Connect(function()
        local state = toggleESP()
        btn.Text = state and "Player ESP [ON]" or "Player ESP [OFF]"
        btn.BackgroundColor3 = state and THEME.ButtonHover or THEME.ButtonNormal
    end)
end

local espTab = Instance.new("TextButton")
espTab.Size = UDim2.new(0, 110, 0, 35)
espTab.BackgroundColor3 = THEME.ButtonNormal
espTab.Text = "Esp"
espTab.TextColor3 = THEME.TextLight
espTab.Font = Enum.Font.GothamBold
espTab.Parent = Sidebar
addCorner(espTab, 6)
espTab.MouseButton1Click:Connect(loadEsp)
loadEsp()

--------------------------------------------------------------------------------
-- 6. JANELA DE CONFIRMAÇÃO (GIGANTE, SEM FUNDO PRETO)
--------------------------------------------------------------------------------
local ConfirmBox = Instance.new("Frame")
ConfirmBox.Size = UDim2.new(0, 450, 0, 220)
ConfirmBox.Position = UDim2.new(0.5, -225, 0.5, -110)
ConfirmBox.BackgroundColor3 = THEME.MainBackground
ConfirmBox.Visible = false
ConfirmBox.ZIndex = 2000
ConfirmBox.Parent = ScreenGui
addCorner(ConfirmBox, 15)

local ConfirmText = Instance.new("TextLabel")
ConfirmText.Size = UDim2.new(1, 0, 0.5, 0)
ConfirmText.BackgroundTransparency = 1
ConfirmText.Text = "Deseja realmente fechar o menu?"
ConfirmText.TextColor3 = THEME.TextLight
ConfirmText.Font = Enum.Font.GothamBold
ConfirmText.TextSize = 20
ConfirmText.Parent = ConfirmBox

local YesBtn = Instance.new("TextButton")
YesBtn.Size = UDim2.new(0, 160, 0, 50)
YesBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
YesBtn.BackgroundColor3 = THEME.ButtonNormal
YesBtn.Text = "SIM"
YesBtn.TextColor3 = THEME.TextLight
YesBtn.Font = Enum.Font.GothamBold
YesBtn.Parent = ConfirmBox
addCorner(YesBtn, 10)

local NoBtn = Instance.new("TextButton")
NoBtn.Size = UDim2.new(0, 160, 0, 50)
NoBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
NoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NoBtn.Text = "NÃO"
NoBtn.TextColor3 = THEME.TextLight
NoBtn.Font = Enum.Font.GothamBold
NoBtn.Parent = ConfirmBox
addCorner(NoBtn, 10)

--------------------------------------------------------------------------------
-- 7. EVENTOS FINAIS
--------------------------------------------------------------------------------
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function() 
    ConfirmBox.Visible = true 
end)

NoBtn.MouseButton1Click:Connect(function() 
    ConfirmBox.Visible = false 
end)

YesBtn.MouseButton1Click:Connect(function() 
    if espEnabled then toggleESP() end
    ScreenGui:Destroy() 
end)

-- Trava controles ao interagir
MainFrame.MouseEnter:Connect(function() toggleControls(false) end)
MainFrame.MouseLeave:Connect(function() toggleControls(true) end)
ConfirmBox.MouseEnter:Connect(function() toggleControls(false) end)
ConfirmBox.MouseLeave:Connect(function() toggleControls(true) end)
