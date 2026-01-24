--[[
    ═══════════════════════════════════════════════════════════════
    ██╗  ██╗    ██╗  ██╗██╗   ██╗██████╗ 
    ╚██╗██╔╝    ██║  ██║██║   ██║██╔══██╗
     ╚███╔╝     ███████║██║   ██║██████╔╝
     ██╔██╗     ██╔══██║██║   ██║██╔══██╗
    ██╔╝ ██╗    ██║  ██║╚██████╔╝██████╔╝
    ╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    ═══════════════════════════════════════════════════════════════
    Main Loader - Organiza todos os módulos
    GitHub: https://github.com/seu-usuario/x-hub
    ═══════════════════════════════════════════════════════════════
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- URLs dos módulos no GitHub (raw)
local GITHUB_BASE = "https://raw.githubusercontent.com/seu-usuario/x-hub/main/"

local modules = {
    Config = GITHUB_BASE .. "Config.lua",
    Utils = GITHUB_BASE .. "Utils.lua",
    UI = GITHUB_BASE .. "UI.lua",
    ESP = GITHUB_BASE .. "ESP.lua",
    Aimbot = GITHUB_BASE .. "Aimbot.lua"
}

-- Sistema de carregamento de módulos
local LoadedModules = {}

local function loadModule(name, url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("[Xota Hub] ✓ Módulo carregado:", name)
        return result
    else
        warn("[Xota Hub] ✗ Erro ao carregar", name, ":", result)
        return nil
    end
end

-- Carregar todos os módulos
print("[Xota Hub] Iniciando carregamento...")
for name, url in pairs(modules) do
    LoadedModules[name] = loadModule(name, url)
end

-- Verificar se todos carregaram
local allLoaded = true
for name, module in pairs(LoadedModules) do
    if not module then
        allLoaded = false
        warn("[Xota Hub] Módulo faltando:", name)
    end
end

if not allLoaded then
    warn("[Xota Hub] Alguns módulos falharam. Verifique sua conexão.")
    return
end

-- Inicializar sistemas
local Config = LoadedModules.Config
local Utils = LoadedModules.Utils
local UI = LoadedModules.UI
local ESP = LoadedModules.ESP
local Aimbot = LoadedModules.Aimbot

-- Criar interface
local gui = UI.Create(Config.THEME)

-- Configurar categorias
UI.AddCategory("ESP", function()
    UI.AddToggle("Player ESP", false, function(state)
        ESP.Toggle(state)
    end)
    
    UI.AddToggle("Show Distance", false, function(state)
        ESP.SetShowDistance(state)
    end)
    
    UI.AddToggle("Show Health", false, function(state)
        ESP.SetShowHealth(state)
    end)
end)

UI.AddCategory("Aimbot", function()
    UI.AddToggle("Enable Aimbot", false, function(state)
        Aimbot.SetEnabled(state)
    end)
    
    UI.AddToggle("Show FOV Circle", false, function(state)
        Aimbot.SetFOVVisible(state)
    end)
    
    UI.AddSlider("Smoothness", 1, 100, 50, function(value)
        Aimbot.SetSmoothness(value)
    end)
    
    UI.AddSlider("Strength", 1, 100, 75, function(value)
        Aimbot.SetStrength(value)
    end)
    
    UI.AddSlider("FOV Size", 50, 500, 200, function(value)
        Aimbot.SetFOVSize(value)
    end)
    
    UI.AddToggle("Wall Check", true, function(state)
        Aimbot.SetWallCheck(state)
    end)
    
    UI.AddToggle("Team Check", true, function(state)
        Aimbot.SetTeamCheck(state)
    end)
    
    UI.AddToggle("RGB FOV", false, function(state)
        Aimbot.SetRGB(state)
    end)
end)

UI.AddCategory("Settings", function()
    UI.AddButton("Reset Position", function()
        UI.ResetPosition()
    end)
    
    UI.AddButton("Destroy GUI", function()
        UI.ShowConfirmDialog("Deseja realmente fechar o Xota Hub?", function()
            ESP.Cleanup()
            Aimbot.Cleanup()
            gui:Destroy()
        end)
    end)
end)

-- Carregar primeira categoria
UI.LoadCategory("ESP")

print("[Xota Hub] ✓ Carregado com sucesso!")
print("[Xota Hub] Use o quadrado 'XH' para abrir/fechar")
