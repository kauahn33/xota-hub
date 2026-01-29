true--[[
    ═══════════════════════════════════════════════════════════════
    ██╗  ██╗    ██╗  ██╗██╗   ██╗██████╗ 
    ╚██╗██╔╝    ██║  ██║██║   ██║██╔══██╗
     ╚███╔╝     ███████║██║   ██║██████╔╝
     ██╔██╗     ██╔══██║██║   ██║██╔══██╗
    ██╔╝ ██╗    ██║  ██║╚██████╔╝██████╔╝
    ╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    ═══════════════════════════════════════════════════════════════
    Arceus X NEO (Speed Update)
    v2.1.0
    ═══════════════════════════════════════════════════════════════
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // CONFIGURAÇÕES E ESTADO
local v_Theme = {
    Bg = Color3.fromRGB(25, 0, 0),
    DarkBg = Color3.fromRGB(15, 0, 0),
    Acc = Color3.fromRGB(180, 0, 0),
    Txt = Color3.fromRGB(240, 240, 240),
    Trans = 0.1 
}

local v_Data = {
    -- Player (Speed)
    walkspeed = 16, -- Padrão do Roblox
    -- Visuais
    var1 = false, -- Highlight
    var2 = false, -- Names
    var3 = false, -- Health
    var4 = false, -- Tracers
    var5 = false, -- RGB UI
    -- Combat
    aimlock = false,
    showfov = false,
    fovsize = 100,      -- Padrão
    smoothness = 0,     -- 0 = Rápido, 100 = Lento
    ignorefriends = false,
    wallcheck = false,
    targetpart = "Head" -- "Head" ou "HumanoidRootPart"
}

local v_List = {} 

-- // DESENHO DO FOV (Drawing API)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Radius = v_Data.fovsize
FovCircle.Filled = false
FovCircle.Transparency = 0.8
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Visible = false

-- // INTERFACE (UI)
local v_Gui = Instance.new("ScreenGui")
v_Gui.Name = "XotaHB_Final_Speed"
v_Gui.ResetOnSpawn = false
if pcall(function() v_Gui.Parent = game.CoreGui end) then
    v_Gui.Parent = game.CoreGui
else
    v_Gui.Parent = Player:WaitForChild("PlayerGui")
end

-- Janela Principal
local v_Main = Instance.new("Frame")
v_Main.Size = UDim2.fromOffset(450, 400)
v_Main.Position = UDim2.fromScale(0.5, 0.5)
v_Main.AnchorPoint = Vector2.new(0.5, 0.5)
v_Main.BackgroundColor3 = v_Theme.Bg
v_Main.BackgroundTransparency = v_Theme.Trans
v_Main.Active = true 
v_Main.Parent = v_Gui
Instance.new("UICorner", v_Main)

local v_Stroke1 = Instance.new("UIStroke")
v_Stroke1.Thickness = 2; v_Stroke1.Color = v_Theme.Acc; v_Stroke1.Parent = v_Main

-- Barra Superior
local v_Top = Instance.new("Frame")
v_Top.Size = UDim2.new(1, 0, 0, 35)
v_Top.BackgroundColor3 = v_Theme.DarkBg
v_Top.Active = true
v_Top.Parent = v_Main
Instance.new("UICorner", v_Top)
local v_Stroke2 = Instance.new("UIStroke")
v_Stroke2.Thickness = 2; v_Stroke2.Color = v_Theme.Acc; v_Stroke2.Parent = v_Top

-- Título
local v_Title = Instance.new("TextLabel")
v_Title.Size = UDim2.new(1, -100, 1, 0)
v_Title.Position = UDim2.fromOffset(15, 0)
v_Title.Text = "Xota HB - Elite"
v_Title.TextColor3 = v_Theme.Txt
v_Title.Font = Enum.Font.GothamBold
v_Title.BackgroundTransparency = 1
v_Title.TextXAlignment = Enum.TextXAlignment.Left
v_Title.Parent = v_Top

-- Ícone Flutuante (Para abrir de volta)
local v_Icon = Instance.new("TextButton") 
v_Icon.Size = UDim2.fromOffset(45, 45)
v_Icon.Position = UDim2.new(0.05, 0, 0.1, 0)
v_Icon.BackgroundColor3 = v_Theme.Bg
v_Icon.Text = "XH"
v_Icon.TextColor3 = v_Theme.Acc
v_Icon.Font = Enum.Font.GothamBold
v_Icon.Visible = true
v_Icon.Parent = v_Gui
Instance.new("UICorner", v_Icon).CornerRadius = UDim.new(0, 10)

-- Botão MINIMIZAR (-)
local v_Min = Instance.new("TextButton")
v_Min.Size = UDim2.fromOffset(25, 25)
v_Min.Position = UDim2.new(1, -30, 0.5, -12) -- Canto superior direito
v_Min.BackgroundColor3 = v_Theme.Acc
v_Min.Text = "-"
v_Min.TextColor3 = Color3.new(1,1,1)
v_Min.Font = Enum.Font.GothamBold
v_Min.AutoButtonColor = true
v_Min.Parent = v_Top
Instance.new("UICorner", v_Min)

-- Lógica Janela (Minimizar/Abrir)
v_Min.MouseButton1Click:Connect(function() 
    v_Main.Visible = false -- Esconde a janela principal
end)

v_Icon.MouseButton1Click:Connect(function() 
    v_Main.Visible = not v_Main.Visible -- Alterna visibilidade
end)

-- Sistema de Drag
local function func_Drag(f, h)
    local drag, start, pos
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; start = i.Position; pos = f.Position
        end
    end)
    h.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - start
            f.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
        end
    end)
end
func_Drag(v_Main, v_Top)
func_Drag(v_Icon, v_Icon)

-- Layouts
local v_Side = Instance.new("ScrollingFrame")
v_Side.Size = UDim2.new(0, 130, 1, -45)
v_Side.Position = UDim2.fromOffset(10, 45)
v_Side.BackgroundTransparency = 1
v_Side.ScrollBarThickness = 2
v_Side.Parent = v_Main
Instance.new("UIListLayout", v_Side).Padding = UDim.new(0, 5)

local v_Content = Instance.new("Frame")
v_Content.Size = UDim2.new(1, -155, 1, -45)
v_Content.Position = UDim2.fromOffset(145, 45)
v_Content.BackgroundTransparency = 1
v_Content.Parent = v_Main

-- // FUNÇÕES AUXILIARES (Aimbot)
local function IsVisible(targetPart)
    if not v_Data.wallcheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Player.Character, targetPart.Parent} 
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, direction, rayParams)
    return result == nil
end

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = v_Data.fovsize
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild(v_Data.targetpart) and p.Character.Humanoid.Health > 0 then
            if v_Data.ignorefriends and p:IsFriendsWith(Player.UserId) then continue end
            local part = p.Character[v_Data.targetpart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if distance < shortestDistance then
                    if IsVisible(part) then
                        shortestDistance = distance
                        closest = p
                    end
                end
            end
        end
    end
    return closest
end

-- // FUNÇÕES UI
local function func_Page(n)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.fromScale(1, 1); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 2; p.AutomaticCanvasSize = Enum.AutomaticSize.Y; p.Parent = v_Content
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 30); b.BackgroundColor3 = v_Theme.DarkBg; b.Text = n; b.TextColor3 = v_Theme.Txt; b.Font = Enum.Font.Gotham; b.AutoButtonColor = true; b.Parent = v_Side
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() for _, x in pairs(v_Content:GetChildren()) do x.Visible = false end p.Visible = true end)
    return p
end

local function func_Btn(page, txt, key, call)
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, -10, 0, 35); bg.BackgroundColor3 = v_Theme.DarkBg; bg.BackgroundTransparency = 0.5; bg.Parent = page; Instance.new("UICorner", bg)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.fromOffset(10, 0); lbl.Text = txt; lbl.TextColor3 = v_Theme.Txt; lbl.Font = Enum.Font.Gotham; lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = bg
    local btn = Instance.new("TextButton"); btn.Size = UDim2.fromOffset(30, 20); btn.Position = UDim2.new(1, -40, 0.5, -10); btn.BackgroundColor3 = v_Data[key] and v_Theme.Acc or Color3.fromRGB(50, 0, 0); btn.Text = ""; btn.AutoButtonColor = true; btn.Parent = bg; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() v_Data[key] = not v_Data[key]; btn.BackgroundColor3 = v_Data[key] and v_Theme.Acc or Color3.fromRGB(50, 0, 0); if call then call(v_Data[key]) end end)
end

local function func_Control(page, title, key, step, maxVal)
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, -10, 0, 35); bg.BackgroundColor3 = v_Theme.DarkBg; bg.BackgroundTransparency = 0.5; bg.Parent = page; Instance.new("UICorner", bg)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.Position = UDim2.fromOffset(10, 0); lbl.Text = title .. ": " .. v_Data[key]; lbl.TextColor3 = v_Theme.Txt; lbl.Font = Enum.Font.Gotham; lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = bg

    local btnPlus = Instance.new("TextButton"); btnPlus.Size = UDim2.fromOffset(25, 25); btnPlus.Position = UDim2.new(1, -35, 0.5, -12); btnPlus.BackgroundColor3 = Color3.fromRGB(40,40,40); btnPlus.Text = "+"; btnPlus.TextColor3 = Color3.new(1,1,1); btnPlus.Font = Enum.Font.GothamBold; btnPlus.Parent = bg; Instance.new("UICorner", btnPlus)
    
    local btnMinus = Instance.new("TextButton"); btnMinus.Size = UDim2.fromOffset(25, 25); btnMinus.Position = UDim2.new(1, -70, 0.5, -12); btnMinus.BackgroundColor3 = Color3.fromRGB(40,40,40); btnMinus.Text = "-"; btnMinus.TextColor3 = Color3.new(1,1,1); btnMinus.Font = Enum.Font.GothamBold; btnMinus.Parent = bg; Instance.new("UICorner", btnMinus)

    btnPlus.MouseButton1Click:Connect(function()
        if v_Data[key] + step <= maxVal then
            v_Data[key] = v_Data[key] + step
            lbl.Text = title .. ": " .. v_Data[key]
        end
    end)

    btnMinus.MouseButton1Click:Connect(function()
        if v_Data[key] - step >= 0 then
            v_Data[key] = v_Data[key] - step
            lbl.Text = title .. ": " .. v_Data[key]
        end
    end)
end

-- // CRIAÇÃO DAS ABAS
local p_Aim = func_Page("Combat")
local p_Vis = func_Page("Visuals")
local p_Set = func_Page("Settings")

-- ## ABA COMBAT ##
func_Btn(p_Aim, "Aimbot", "aimlock")
func_Btn(p_Aim, "Aimfov", "showfov")
func_Btn(p_Aim, "Ignore Friends", "ignorefriends")
func_Btn(p_Aim, "Wallcheck", "wallcheck")
func_Control(p_Aim, "Fov Size", "fovsize", 10, 500)
func_Control(p_Aim, "Smoothness", "smoothness", 10, 100)

local targetBtn = Instance.new("TextButton", p_Aim)
targetBtn.Size = UDim2.new(1, -10, 0, 35); targetBtn.BackgroundColor3 = v_Theme.DarkBg; targetBtn.BackgroundTransparency = 0.5; targetBtn.TextColor3 = v_Theme.Txt; targetBtn.Font = Enum.Font.GothamBold; targetBtn.Text = "Target: HEAD"
Instance.new("UICorner", targetBtn)
targetBtn.MouseButton1Click:Connect(function()
    if v_Data.targetpart == "Head" then
        v_Data.targetpart = "HumanoidRootPart"
        targetBtn.Text = "Target: TORSO"
    else
        v_Data.targetpart = "Head"
        targetBtn.Text = "Target: HEAD"
    end
end)

-- ## ABA VISUALS ##
local function func_AddH(c)
    if not c or not v_Data.var1 then return end
    if c:FindFirstChild("Obj_H_Final") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "Obj_H_Final"
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(139, 0, 0)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
    hl.Parent = c
end

local function func_RemH()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Obj_H_Final") then p.Character.Obj_H_Final:Destroy() end
    end
end

func_Btn(p_Vis, "Highlight ESP", "var1", function(v)
    if v then for _, p in pairs(Players:GetPlayers()) do if p ~= Player and p.Character then func_AddH(p.Character) end end
    else func_RemH() end
end)
func_Btn(p_Vis, "Show Names", "var2")
func_Btn(p_Vis, "Show Health", "var3")
func_Btn(p_Vis, "Tracers", "var4")

-- ## ABA SETTINGS (NOVO) ##
func_Btn(p_Set, "RGB Outline", "var5")
-- ADICIONADO: Controle de Velocidade
func_Control(p_Set, "Walk Speed", "walkspeed", 2, 100)

-- // LOOPS DE FUNCIONAMENTO (Runtime)
RunService.RenderStepped:Connect(function()
    
    -- >>> LOGICA DE VELOCIDADE (SPEED) <<<
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        -- Se o WalkSpeed estiver diferente do escolhido, força a mudança
        if Player.Character.Humanoid.WalkSpeed ~= v_Data.walkspeed then
            Player.Character.Humanoid.WalkSpeed = v_Data.walkspeed
        end
    end
    -- >>> FIM LÓGICA SPEED <<<

    -- RGB
    if v_Data.var5 then 
        local h = (tick() % 5) / 5
        local c = Color3.fromHSV(h, 1, 1)
        v_Stroke1.Color = c; v_Stroke2.Color = c
    else
        v_Stroke1.Color = v_Theme.Acc; v_Stroke2.Color = v_Theme.Acc
    end

    -- FOV
    FovCircle.Visible = v_Data.showfov
    FovCircle.Radius = v_Data.fovsize
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Aimlock
    if v_Data.aimlock then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(v_Data.targetpart) then
            local goalPos = target.Character[v_Data.targetpart].Position
            local mainCf = CFrame.new(Camera.CFrame.Position, goalPos)
            if v_Data.smoothness > 0 then
                local smoothFactor = (100 - v_Data.smoothness) / 100
                if smoothFactor < 0.05 then smoothFactor = 0.05 end
                Camera.CFrame = Camera.CFrame:Lerp(mainCf, smoothFactor)
            else
                Camera.CFrame = mainCf
            end
        end
    end

    -- Visuals
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if v_Data.var4 and p.Character.Humanoid.Health > 0 then
                local hrp = p.Character.HumanoidRootPart
                local sPos, vis = Camera:WorldToViewportPoint(hrp.Position)
                if vis then
                    if not v_List[p.Name] then local l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = Color3.fromRGB(255, 0, 0); v_List[p.Name] = l end
                    v_List[p.Name].Visible = true
                    v_List[p.Name].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    v_List[p.Name].To = Vector2.new(sPos.X, sPos.Y)
                else
                    if v_List[p.Name] then v_List[p.Name].Visible = false end
                end
            else
                if v_List[p.Name] then v_List[p.Name].Visible = false end
            end
            if v_Data.var2 or v_Data.var3 then
                local b = p.Character:FindFirstChild("Box_Info")
                if not b then
                    b = Instance.new("BillboardGui", p.Character)
                    b.Name = "Box_Info"; b.Size = UDim2.fromOffset(200, 50); b.AlwaysOnTop = true; b.StudsOffset = Vector3.new(0, -4.5, 0); b.Adornee = p.Character.HumanoidRootPart
                    local t = Instance.new("TextLabel", b); t.Size = UDim2.fromScale(1,1); t.BackgroundTransparency = 1; t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.GothamBold; t.TextSize = 13; t.TextStrokeTransparency = 0
                end
                local txt = ""
                if v_Data.var2 then txt = p.Name end
                if v_Data.var3 then txt = txt .. "\nHP: " .. math.floor(p.Character.Humanoid.Health) end
                b.TextLabel.Text = txt
            else
                if p.Character:FindFirstChild("Box_Info") then p.Character.Box_Info:Destroy() end
            end
        end
    end
end)

-- Loop de Recarregamento
task.spawn(function()
    while task.wait(5) do
        if v_Data.var1 then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character then
                    local old = p.Character:FindFirstChild("Obj_H_Final")
                    if old then old:Destroy() end
                    func_AddH(p.Character)
                end
            end
        end
    end
end)

p_Aim.Visible = true
