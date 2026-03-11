local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v2.6 Animation Update",
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
    sans_walk = false,
    rgb_speed = 1
}

local function getRGB()
    local t = tick() * settings.rgb_speed
    return Color3.fromHSV(t % 1, 0.8, 1)
end

-- Вкладки
local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483346362)
local AnimTab = Window:CreateTab("Animations", "accessibility") -- Иконка человечка
local SocialTab = Window:CreateTab("Socials", 4483345906)

-- [[ MAIN ]]
MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      if lp.Character and lp.Character:FindFirstChild("Humanoid") then
          lp.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

-- [[ ANIMATIONS ]]
AnimTab:CreateToggle({
   Name = "Sans Walk (Походка Санса)",
   CurrentValue = false,
   Callback = function(Value)
       settings.sans_walk = Value
       if Value then
           Rayfield:Notify({Title = "Sans Mode", Content = "Руки в карманы, идем отдыхать.", Duration = 3})
       end
   end,
})

-- [[ VISUALS ]]
VisualTab:CreateToggle({ Name = "2D Box ESP", CurrentValue = false, Callback = function(v) settings.boxes = v end })
VisualTab:CreateToggle({ Name = "Tracers", CurrentValue = false, Callback = function(v) settings.tracers = v end })
VisualTab:CreateToggle({ Name = "RGB China Hat", CurrentValue = false, Callback = function(v) settings.chinahat = v end })
VisualTab:CreateToggle({ Name = "3D Jump Circles", CurrentValue = false, Callback = function(v) settings.jumpcircles = v end })

-- [[ SOCIALS ]]
SocialTab:CreateButton({
   Name = "Telegram: @idkkkk_dev",
   Callback = function()
       setclipboard("https://t.me/idkkkk_dev")
       Rayfield:Notify({Title = "Telegram", Content = "Ссылка скопирована!", Duration = 3})
   end,
})

-- Логика походки Санса (Процедурная анимация)
run_svc.Stepped:Connect(function()
    if settings.sans_walk and lp.Character then
        local char = lp.Character
        local r_arm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
        local l_arm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
        local r_leg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
        local l_leg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg")
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")

        if hum and hum.MoveDirection.Magnitude > 0 then
            local t = tick() * (hum.WalkSpeed / 5)
            -- Руки в карманах (неподвижны относительно торса)
            if r_arm and l_arm then
                local r_joint = char.Torso:FindFirstChild("Right Shoulder") or char.RightUpperArm:FindFirstChild("RightShoulder")
                local l_joint = char.Torso:FindFirstChild("Left Shoulder") or char.LeftUpperArm:FindFirstChild("LeftShoulder")
                
                if r_joint then r_joint.C0 = r_joint.C0:Lerp(CFrame.new(1.2, 0.2, 0.2) * CFrame.Angles(math.rad(-10), 0, math.rad(10)), 0.1) end
                if l_joint then l_joint.C0 = l_joint.C0:Lerp(CFrame.new(-1.2, 0.2, 0.2) * CFrame.Angles(math.rad(-10), 0, math.rad(-10)), 0.1) end
            end
            -- Покачивание тела (ленивая походка)
            hum.CameraOffset = hum.CameraOffset:Lerp(Vector3.new(math.sin(t)*0.1, math.abs(math.cos(t)*0.05), 0), 0.1)
        end
    end
end)

-- Функция Jump Circle
local function createJumpCircle()
    if not settings.jumpcircles then return end
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local p = Instance.new("Part", workspace)
        p.Anchored, p.CanCollide = true, false
        p.Size = Vector3.new(0.1, 0.5, 0.5)
        p.Material = Enum.Material.Neon
        p.Color = getRGB()
        p.CFrame = CFrame.new(char.HumanoidRootPart.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
        
        local m = Instance.new("SpecialMesh", p)
        m.MeshType = Enum.MeshType.Cylinder
        
        tween_svc:Create(p, TweenInfo.new(0.6), {Size = Vector3.new(0.1, 10, 10), Transparency = 1}):Play()
        task.delay(0.6, function() p:Destroy() end)
    end
end

-- ESP Drawing API
local cache = {}
local function createEsp(player)
    cache[player] = {box = Drawing.new("Square"), tracer = Drawing.new("Line")}
    cache[player].box.Thickness = 1.5
    cache[player].tracer.Thickness = 1.5
end

for _, p in pairs(game:GetService("Players"):GetPlayers()) do if p ~= lp then createEsp(p) end end
game:GetService("Players").PlayerAdded:Connect(function(p) if p ~= lp then createEsp(p) end end)

-- Рендер цикл
run_svc.RenderStepped:Connect(function()
    local rgb = getRGB()
    
    if settings.chinahat and lp.Character and lp.Character:FindFirstChild("Head") then
        local head = lp.Character.Head
        local hat = head:FindFirstChild("IDK_Hat") or Instance.new("Part", head)
        hat.Name = "IDK_Hat"
        hat.CanCollide = false
        hat.Size = Vector3.new(1.3, 0.1, 1.3)
        hat.Material = Enum.Material.Neon
        hat.Color = rgb
        if not hat:FindFirstChild("Mesh") then
            local m = Instance.new("SpecialMesh", hat)
            m.MeshId = "rbxassetid://1033714"
            m.Scale = Vector3.new(1.4, 0.5, 1.4)
        end
        hat.CFrame = head.CFrame * CFrame.new(0, 0.55, 0)
    end

    for player, drawings in pairs(cache) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
            if onScreen then
                if settings.tracers then
                    drawings.tracer.Visible, drawings.tracer.Color = true, rgb
                    drawings.tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                    drawings.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                else drawings.tracer.Visible = false end
                
                if settings.boxes then
                    local size = Vector2.new(2000/screenPos.Z, 3000/screenPos.Z)
                    drawings.box.Visible, drawings.box.Color = true, rgb
                    drawings.box.Size = size
                    drawings.box.Position = Vector2.new(screenPos.X - size.X/2, screenPos.Y - size.Y/2)
                else drawings.box.Visible = false end
            else drawings.box.Visible, drawings.tracer.Visible = false, false end
        else drawings.box.Visible, drawings.tracer.Visible = false, false end
    end
end)

lp.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Jumping then createJumpCircle() end
    end)
end)
if lp.Character then
    lp.Character:WaitForChild("Humanoid").StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Jumping then createJumpCircle() end
    end)
end

Rayfield:Notify({Title = "idkkkk hub", Content = "v2.6 загружен!  ТГ: @idkkkk_dev", Duration = 5})
