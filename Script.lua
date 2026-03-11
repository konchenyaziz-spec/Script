local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v2.5 Social Edition",
   LoadingTitle = "idkkkk hub",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local camera = workspace.CurrentCamera
local tween_svc = game:GetService("TweenService")

local settings = {
    boxes = false,
    tracers = false,
    chinahat = false,
    jumpcircles = false,
    rgb_speed = 1
}

local function getRGB()
    local t = tick() * settings.rgb_speed
    return Color3.fromHSV(t % 1, 0.8, 1)
end

-- Вкладки
local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483346362)
local SocialTab = Window:CreateTab("Socials", 4483345906) -- Иконка для соцсетей

-- UI Elements
VisualTab:CreateToggle({
   Name = "2D Box ESP",
   CurrentValue = false,
   Callback = function(Value) settings.boxes = Value end,
})

VisualTab:CreateToggle({
   Name = "Линии (Tracers)",
   CurrentValue = false,
   Callback = function(Value) settings.tracers = Value end,
})

VisualTab:CreateToggle({
   Name = "RGB China Hat",
   CurrentValue = false,
   Callback = function(Value) settings.chinahat = Value end,
})

VisualTab:CreateToggle({
   Name = "3D Jump Circles (Floor)",
   CurrentValue = false,
   Callback = function(Value) settings.jumpcircles = Value end,
})

-- Socials Tab
SocialTab:CreateSection("Наши ресурсы")

SocialTab:CreateButton({
   Name = "Telegram Channel (Click to Copy)",
   Callback = function()
       setclipboard("https://t.me/idkkkkhub") -- Замени на свою реальную ссылку
       Rayfield:Notify({
          Title = "Socials",
          Content = "Ссылка на Telegram скопирована в буфер обмена!",
          Duration = 3
       })
   end,
})

-- Функция 3D Jump Circles на полу
local function createJumpCircle()
    if not settings.jumpcircles then return end
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    local pos = root.Position - Vector3.new(0, char.Humanoid.HipHeight + 1.5, 0)
    
    local part = Instance.new("Part")
    part.Name = "JumpCircle"
    part.Parent = workspace
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.5
    part.Material = Enum.Material.Neon
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(0.1, 0.5, 0.5)
    part.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
    part.Color = getRGB()
    
    local mesh = Instance.new("SpecialMesh", part)
    mesh.MeshType = Enum.MeshType.Cylinder
    
    -- Анимация расширения и исчезновения
    local info = TweenInfo.new(0.6, Enum.EasingStyle.QuartOut)
    local tween = tween_svc:Create(part, info, {
        Size = Vector3.new(0.1, 8, 8), -- Расширяется в стороны
        Transparency = 1
    })
    
    tween:Play()
    tween.Completed:Connect(function() part:Destroy() end)
end

-- ESP Drawing Setup
local cache = {}
local function createEsp(player)
    local drawings = {
        box = Drawing.new("Square"),
        tracer = Drawing.new("Line")
    }
    drawings.box.Thickness = 1.5
    drawings.box.Filled = false
    drawings.tracer.Thickness = 1.5
    cache[player] = drawings
end

for _, p in pairs(game:GetService("Players"):GetPlayers()) do
    if p ~= lp then createEsp(p) end
end

game:GetService("Players").PlayerAdded:Connect(function(p)
    if p ~= lp then createEsp(p) end
end)

-- Main Render Loop
run_svc.RenderStepped:Connect(function()
    local rgb = getRGB()
    
    -- Hat Logic
    if settings.chinahat and lp.Character and lp.Character:FindFirstChild("Head") then
        local head = lp.Character.Head
        local hat = head:FindFirstChild("IDK_Hat")
        if not hat then
            hat = Instance.new("Part", head)
            hat.Name = "IDK_Hat"
            hat.CanCollide = false
            hat.Size = Vector3.new(1.4, 0.1, 1.4)
            hat.Material = Enum.Material.Neon
            local mesh = Instance.new("SpecialMesh", hat)
            mesh.MeshId = "rbxassetid://1033714"
            mesh.Scale = Vector3.new(1.5, 0.6, 1.5)
        end
        hat.CFrame = head.CFrame * CFrame.new(0, 0.6, 0)
        hat.Color = rgb
    elseif lp.Character and lp.Character:FindFirstChild("Head") and lp.Character.Head:FindFirstChild("IDK_Hat") then
        lp.Character.Head.IDK_Hat:Destroy()
    end

    -- ESP Drawing Update
    for player, drawings in pairs(cache) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                if settings.tracers then
                    drawings.tracer.Visible = true
                    drawings.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    drawings.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    drawings.tracer.Color = rgb
                else
                    drawings.tracer.Visible = false
                end
                
                if settings.boxes then
                    local size = Vector2.new(2000 / screenPos.Z, 3000 / screenPos.Z)
                    drawings.box.Visible = true
                    drawings.box.Size = size
                    drawings.box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)
                    drawings.box.Color = rgb
                else
                    drawings.box.Visible = false
                end
            else
                drawings.box.Visible = false
                drawings.tracer.Visible = false
            end
        else
            drawings.box.Visible = false
            drawings.tracer.Visible = false
        end
    end
end)

-- Detect Jump
local function listenToJump(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Jumping then createJumpCircle() end
    end)
end

lp.CharacterAdded:Connect(listenToJump)
if lp.Character then listenToJump(lp.Character) end

Rayfield:Notify({
   Title = "idkkkk hub",
   Content = "Версия 2.5 загружена. Проверь вкладку Socials!",
   Duration = 5
})
