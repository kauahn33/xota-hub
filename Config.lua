--[[
    Xota Hub - Configurações Centralizadas
    Todas as cores, tamanhos e constantes em um só lugar
]]

local Config = {}

-- Tema de cores
Config.THEME = {
    -- Backgrounds
    MainBackground = Color3.fromRGB(35, 10, 10),
    HeaderBackground = Color3.fromRGB(20, 5, 5),
    SidebarBackground = Color3.fromRGB(30, 8, 8),
    ContentBackground = Color3.fromRGB(25, 7, 7),
    
    -- Botões
    ButtonNormal = Color3.fromRGB(80, 20, 20),
    ButtonHover = Color3.fromRGB(120, 30, 30),
    ButtonActive = Color3.fromRGB(150, 40, 40),
    
    -- Textos
    TextLight = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    
    -- Highlights e acentos
    Accent = Color3.fromRGB(255, 50, 50),
    HighlightFill = Color3.fromRGB(255, 0, 0),
    HighlightOutline = Color3.fromRGB(139, 0, 0),
    
    -- Slider
    SliderBackground = Color3.fromRGB(50, 15, 15),
    SliderFill = Color3.fromRGB(200, 30, 30),
    SliderKnob = Color3.fromRGB(255, 255, 255),
}

-- Dimensões da UI
Config.UI = {
    MainFrameSize = UDim2.new(0, 580, 0, 420),
    SidebarWidth = 140,
    TopBarHeight = 50,
    ButtonHeight = 35,
    SliderHeight = 45,
    Padding = 10,
    CornerRadius = 12,
    MinimizedSize = UDim2.new(0, 65, 0, 65),
}

-- Configurações de ESP
Config.ESP = {
    DefaultColor = Color3.fromRGB(255, 0, 0),
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
}

-- Configurações de Aimbot
Config.AIMBOT = {
    DefaultFOV = 200,
    MinFOV = 50,
    MaxFOV = 500,
    DefaultSmoothness = 50,
    DefaultStrength = 75,
    CircleThickness = 2.5,
    CircleSides = 100,
}

-- Teclas de atalho
Config.KEYBINDS = {
    ToggleUI = Enum.KeyCode.RightShift,
    ToggleAimbot = Enum.KeyCode.E,
}

-- Versão
Config.VERSION = "2.0.0"
Config.SCRIPT_NAME = "Xota Hub"

return Config
