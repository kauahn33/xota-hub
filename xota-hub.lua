-- Serviço de Jogadores
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configurações Visuais
local HIGHLIGHT_NAME = "CommunityHighlight"
local FILL_COLOR = Color3.fromRGB(255, 0, 0)      -- Vermelho Vivo
local OUTLINE_COLOR = Color3.fromRGB(139, 0, 0)   -- Vermelho Escuro
local FILL_TRANSPARENCY = 0.5                     -- 0 é sólido, 1 é invisível
local OUTLINE_TRANSPARENCY = 0                    -- 0 é sólido, 1 é invisível

-- Função para criar ou atualizar o Highlight
local function addHighlightToCharacter(character)
    if not character then return end

    -- Verifica se já existe um highlight para evitar duplicatas
    if character:FindFirstChild(HIGHLIGHT_NAME) then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = HIGHLIGHT_NAME
    highlight.Adornee = character
    highlight.Parent = character
    
    -- Aplica as cores solicitadas
    highlight.FillColor = FILL_COLOR
    highlight.OutlineColor = OUTLINE_COLOR
    
    -- Aplica as transparências
    highlight.FillTransparency = FILL_TRANSPARENCY
    highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
    
    -- Define o modo para cobrir o personagem mesmo através de paredes (Opcional)
    -- Use Enum.HighlightDepthMode.Occluded para ver apenas quando visível
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

-- Função para configurar um jogador
local function setupPlayer(player)
    -- Ignora o próprio jogador se você quiser destacar APENAS os outros.
    -- Remova a linha abaixo se quiser destacar a si mesmo também.
    -- if player == LocalPlayer then return end

    -- Se o personagem já existe, destaca agora
    if player.Character then
        addHighlightToCharacter(player.Character)
    end

    -- Conecta ao evento de quando o personagem nasce/renasce
    player.CharacterAdded:Connect(function(character)
        -- Espera um pouco para garantir que o modelo carregou
        character:WaitForChild("HumanoidRootPart", 5) 
        addHighlightToCharacter(character)
    end)
end

-- 1. Configura todos os jogadores que já estão no jogo
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

-- 2. Conecta o evento para novos jogadores que entrarem (Entrada)
Players.PlayerAdded:Connect(function(player)
    setupPlayer(player)
end)

-- Nota: Não é necessário um evento explícito de "Saída" (PlayerRemoving),
-- pois quando o jogador sai, o modelo do personagem (Character) e o Highlight
-- dentro dele são destruídos automaticamente pelo Roblox.
