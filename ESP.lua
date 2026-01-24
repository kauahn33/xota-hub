--[[
    X Hub - ESP System
    Sistema de visualização de jogadores
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP = {}
local ESPEnabled = false
local ShowDistance = false
local ShowHealth = false
local Connections = {}
local Highlights = {}

function ESP.Toggle(state)
    ESPEnabled = state
    
    if ESPEnabled then
        ESP.Enable()
    else
        ESP.Disable()
    end
end

function ESP.Enable()
    local Config = require(script.Parent.Config)
    
    -- Aplicar em jogadores existentes
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP.AddToPlayer(player)
        end
    end
    
    -- Conectar eventos
    Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(char)
                ESP.AddToCharacter(char, player)
            end)
            
            if player.Character then
                ESP.AddToCharacter(player.Character, player)
            end
        end
    end)
    
    Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        ESP.RemoveFromPlayer(player)
    end)
end

function ESP.Disable()
    -- Desconectar eventos
    for _, conn in pairs(Connections) do
        conn:Disconnect()
    end
    Connections = {}
    
    -- Remover highlights
    for player, data in pairs(Highlights) do
        if data.Highlight then
            data.Highlight:Destroy()
        end
        if data.BillboardGui then
            data.BillboardGui:Destroy()
        end
    end
    Highlights = {}
end

function ESP.AddToPlayer(player)
    if player.Character then
        ESP.AddToCharacter(player.Character, player)
    end
    
    player.CharacterAdded:Connect(function(char)
        ESP.AddToCharacter(char, player)
    end)
end

function ESP.AddToCharacter(character, player)
    if not ESPEnabled then return end
    
    local Config = require(script.Parent.Config)
    
    -- Remover highlight antigo se existir
    ESP.RemoveFromPlayer(player)
    
    -- Criar highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "XHub_Highlight"
    highlight.FillColor = Config.ESP.DefaultColor
    highlight.OutlineColor = Config.ESP.DefaultColor
    highlight.FillTransparency = Config.ESP.FillTransparency
    highlight.OutlineTransparency = Config.ESP.OutlineTransparency
    highlight.DepthMode = Config.ESP.DepthMode
    highlight.Parent = character
    
    -- Criar billboard para informações
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "XHub_Info"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character:WaitForChild("Head", 5)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.Parent = billboard
    
    Highlights[player] = {
        Highlight = highlight,
        BillboardGui = billboard,
        TextLabel = textLabel,
        Character = character
    }
    
    ESP.UpdateInfo(player)
end

function ESP.RemoveFromPlayer(player)
    if Highlights[player] then
        if Highlights[player].Highlight then
            Highlights[player].Highlight:Destroy()
        end
        if Highlights[player].BillboardGui then
            Highlights[player].BillboardGui:Destroy()
        end
        Highlights[player] = nil
    end
end

function ESP.UpdateInfo(player)
    if not Highlights[player] then return end
    
    local data = Highlights[player]
    local char = data.Character
    local humanoid = char:FindFirstChild("Humanoid")
    
    local text = player.Name
    
    if ShowHealth and humanoid then
        local health = math.floor(humanoid.Health)
        local maxHealth = math.floor(humanoid.MaxHealth)
        text = text .. "\n❤ " .. health .. "/" .. maxHealth
    end
    
    if ShowDistance then
        local localChar = LocalPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
            local distance = (localChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            text = text .. "\n📍 " .. math.floor(distance) .. "m"
        end
    end
    
    data.TextLabel.Text = text
end

function ESP.SetShowDistance(state)
    ShowDistance = state
    for player, _ in pairs(Highlights) do
        ESP.UpdateInfo(player)
    end
end

function ESP.SetShowHealth(state)
    ShowHealth = state
    for player, _ in pairs(Highlights) do
        ESP.UpdateInfo(player)
    end
end

function ESP.Cleanup()
    ESP.Disable()
end

-- Update loop para informações dinâmicas
RunService.Heartbeat:Connect(function()
    if ESPEnabled and (ShowDistance or ShowHealth) then
        for player, _ in pairs(Highlights) do
            if player and player.Parent then
                ESP.UpdateInfo(player)
            end
        end
    end
end)

return ESP
