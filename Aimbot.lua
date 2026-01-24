--[[
    X Hub - Aimbot System
    Sistema de mira assistida com smoothness e strength
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Aimbot = {}

-- Configurações
local Settings = {
    Enabled = false,
    FOVVisible = false,
    FOVSize = 200,
    Smoothness = 50, -- 1-100
    Strength = 75, -- 1-100
    WallCheck = true,
    TeamCheck = true,
    FriendCheck = true,
    RGB = false,
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2.5
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)

-- RGB Animation
local hue = 0

-- Utilitários
local function isVisible(targetPart)
    if not Settings.WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 500
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(origin, direction, rayParams)
    
    if not result then return true end
    
    return result.Instance:IsDescendantOf(targetPart.Parent)
end

local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Verificações de filtro
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        if Settings.FriendCheck and LocalPlayer:IsFriendsWith(player.UserId) then continue end
        
        local character = player.Character
        if not character then continue end
        
        local head = character:FindFirstChild("Head")
        if not head then continue end
        
        -- Verificar se está na tela
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        
        -- Calcular distância do cursor
        local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
        local distance = (screenPoint - mousePos).Magnitude
        
        -- Verificar se está dentro do FOV
        if distance > Settings.FOVSize then continue end
        
        -- Verificar wall
        if not isVisible(head) then continue end
        
        -- Atualizar mais próximo
        if distance < shortestDistance then
            shortestDistance = distance
            closestPlayer = head
        end
    end
    
    return closestPlayer
end

local function smoothAim(targetPosition)
    local Utils = require(script.Parent.Utils)
    
    -- Converter smoothness (1-100) para fator de interpolação (0-1)
    -- Quanto maior smoothness, menor o fator (mais suave)
    local smoothFactor = 1 - (Settings.Smoothness / 100 * 0.95) -- Máximo 95% de suavização
    
    -- Converter strength (1-100) para multiplicador (0-1)
    local strengthMultiplier = Settings.Strength / 100
    
    -- Calcular direção para o alvo
    local currentLook = Camera.CFrame.LookVector
    local targetLook = (targetPosition - Camera.CFrame.Position).Unit
    
    -- Aplicar smoothness (lerp entre direção atual e alvo)
    local smoothedLook = currentLook:Lerp(targetLook, smoothFactor)
    
    -- Aplicar strength (reduzir a intensidade final)
    local finalLook = currentLook:Lerp(smoothedLook, strengthMultiplier)
    
    -- Atualizar câmera
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + finalLook)
end

-- Sistema de Aimbot
local aimbotConnection = nil

function Aimbot.Enable()
    if aimbotConnection then return end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        
        local target = getClosestPlayerToCursor()
        if target then
            smoothAim(target.Position)
        end
    end)
end

function Aimbot.Disable()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- FOV Circle Update
RunService.RenderStepped:Connect(function()
    -- Atualizar posição do FOV
    local mouseLocation = UserInputService:GetMouseLocation()
    FOVCircle.Position = mouseLocation
    FOVCircle.Radius = Settings.FOVSize
    FOVCircle.Visible = Settings.FOVVisible
    
    -- RGB Animation
    if Settings.RGB then
        hue = (hue + 1) % 360
        FOVCircle.Color = Color3.fromHSV(hue / 360, 1, 1)
    else
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    end
end)

-- Controle por teclas de seta
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local moveAmount = 10
    local currentPos = FOVCircle.Position
    
    if input.KeyCode == Enum.KeyCode.Up then
        FOVCircle.Position = Vector2.new(currentPos.X, currentPos.Y - moveAmount)
    elseif input.KeyCode == Enum.KeyCode.Down then
        FOVCircle.Position = Vector2.new(currentPos.X, currentPos.Y + moveAmount)
    elseif input.KeyCode == Enum.KeyCode.Left then
        FOVCircle.Position = Vector2.new(currentPos.X - moveAmount, currentPos.Y)
    elseif input.KeyCode == Enum.KeyCode.Right then
        FOVCircle.Position = Vector2.new(currentPos.X + moveAmount, currentPos.Y)
    end
end)

-- Métodos públicos
function Aimbot.SetEnabled(state)
    Settings.Enabled = state
    if state then
        Aimbot.Enable()
    else
        Aimbot.Disable()
    end
end

function Aimbot.SetFOVVisible(state)
    Settings.FOVVisible = state
end

function Aimbot.SetFOVSize(size)
    Settings.FOVSize = size
end

function Aimbot.SetSmoothness(value)
    Settings.Smoothness = math.clamp(value, 1, 100)
end

function Aimbot.SetStrength(value)
    Settings.Strength = math.clamp(value, 1, 100)
end

function Aimbot.SetWallCheck(state)
    Settings.WallCheck = state
end

function Aimbot.SetTeamCheck(state)
    Settings.TeamCheck = state
end

function Aimbot.SetFriendCheck(state)
    Settings.FriendCheck = state
end

function Aimbot.SetRGB(state)
    Settings.RGB = state
end

function Aimbot.Cleanup()
    Aimbot.Disable()
    FOVCircle.Visible = false
    FOVCircle:Remove()
end

return Aimbot
