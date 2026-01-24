--[[
    Xota Hub - Utilidades
    Funções auxiliares reutilizáveis
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

local Utils = {}

-- Adicionar cantos arredondados
function Utils.AddCorner(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = element
    return corner
end

-- Adicionar padding
function Utils.AddPadding(element, padding)
    local pad = Instance.new("UIPadding")
    if type(padding) == "number" then
        pad.PaddingTop = UDim.new(0, padding)
        pad.PaddingBottom = UDim.new(0, padding)
        pad.PaddingLeft = UDim.new(0, padding)
        pad.PaddingRight = UDim.new(0, padding)
    else
        pad.PaddingTop = UDim.new(0, padding.Top or 0)
        pad.PaddingBottom = UDim.new(0, padding.Bottom or 0)
        pad.PaddingLeft = UDim.new(0, padding.Left or 0)
        pad.PaddingRight = UDim.new(0, padding.Right or 0)
    end
    pad.Parent = element
    return pad
end

-- Travar/Destravar controles do jogador
function Utils.ToggleControls(enable)
    if enable then
        ContextActionService:UnbindAction("XHub_FreezeControls")
    else
        ContextActionService:BindAction("XHub_FreezeControls", function()
            return Enum.ContextActionResult.Sink
        end, false, unpack(Enum.PlayerActions:GetEnumItems()))
    end
end

-- Fazer elemento arrastável (simples)
function Utils.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Fazer elemento arrastável com detecção de clique
function Utils.MakeDraggableWithClick(frame, button, onClickCallback)
    local dragging = false
    local dragStart, startPos
    local moved = false
    local moveThreshold = 5
    
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
            if delta.Magnitude > moveThreshold then
                moved = true
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            Utils.ToggleControls(true)
            
            if not moved and onClickCallback then
                onClickCallback()
            end
        end
    end)
end

-- Tween suave
function Utils.Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Efeito hover em botões
function Utils.AddHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        Utils.Tween(button, {BackgroundColor3 = hoverColor}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        Utils.Tween(button, {BackgroundColor3 = normalColor}, 0.2)
    end)
end

-- Interpolar valores (para smoothness)
function Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

-- Normalizar valores de 0 a 1
function Utils.Normalize(value, min, max)
    return (value - min) / (max - min)
end

-- Mapear valor de uma range para outra
function Utils.Map(value, inMin, inMax, outMin, outMax)
    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

-- Verificar se elemento está visível na tela
function Utils.IsOnScreen(position, camera)
    local _, onScreen = camera:WorldToViewportPoint(position)
    return onScreen
end

-- Formatar número com casas decimais
function Utils.Round(number, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(number * mult + 0.5) / mult
end

return Utils
