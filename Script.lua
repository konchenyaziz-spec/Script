--[[
    IDKKK HUB v1.5
    Library: Rayfield
    Credits: by IDKKK team
    Fixes: Jump Circles, China Hat Stability, Author Tags
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk HUB | v1.5",
   LoadingTitle = "Загрузка IDKKKK HUB...",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})


local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local visual_settings = {
    boxes = false,
    chinahat = false,
    jumpcircles = false
}

local banging = false
local bangTarget = nil


local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSlider({
   Name = "Скорость бега",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      if lp.Character and lp.Character:FindFirstChild("Humanoid") then
          lp.Character.Humanoid.WalkSpeed = Value
      end
   end,
})


local TrollTab = Window:CreateTab("Trolling", 4483345998)

TrollTab:CreateInput({
   Name = "Имя жертвы (Bang)",
   PlaceholderText = "Имя или DisplayName...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       for _, v in pairs(game:GetService("Players"):GetPlayers()) do
           if v.Name:lower():find(Text:lower()) or v.DisplayName:lower():find(Text:lower()) then
               bangTarget = v
               Rayfield:Notify({Title = "Цель выбрана", Content = "Выбрана цель: " .. v.DisplayName, Duration = 2})
               break
           end
       end
   end,
})

TrollTab:CreateToggle({
   Name = "Bang (Ебать игрока)",
   CurrentValue = false,
   Callback = function(Value)
       banging = Value
       if Value then
           task.spawn(function()
               while banging do
                   if bangTarget and bangTarget.Character and bangTarget.Character:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                       local targetHrp = bangTarget.Character.HumanoidRootPart
                       local myHrp = lp.Character.HumanoidRootPart
                       
                       
                       for i = 1, 6 do
                           if not banging then break end
                           myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.8 + (i/10))
                           run_svc.Heartbeat:Wait()
                       end
                       for i = 6, 1, -1 do
                           if not banging then break end
                           myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.8 + (i/10))
                           run_svc.Heartbeat:Wait()
                       end
                   else
                       run_svc.Heartbeat:Wait()
                   end
               end
           end)
       end
   end,
})

local cal VisualTab = Window:CreateTab("Visuals", 4483346362)

VisualTab:CreateToggle({
   Name = "Neon Box ESP",
   CurrentValue = false,
   Callback = function(Value) visual_settings.boxes = Value end,
})

VisualTab:CreateToggle({
   Name = "Premium China Hat (v1.5 Fix)",
   CurrentValue = false,
   Callback = function(Value) visual_settings.chinahat = Value end,
})

VisualTab:CreateToggle({
   Name = "Jump Circles (Instant Fix)",
   CurrentValue = false,
   Callback = function(Value) visual_settings.jumpcircles = Value end,
})



--localhina Hat
run_svc.RenderStepped:Connect(function()
    if visual_settings.chinahat and lp.Character and lp.Character:FindFirstChild("Head") then
        local head = lp.Character.Head
        local hat = head:FindFirstChild("IDK_Hat_v15")
        if not hat then
            hat = Instance.new("Part")
            hat.Name = "IDK_Hat_v15"
            hat.CanCollide = false
            hat.Parent = head
            hat.Size = Vector3.new(2, 0.5, 2)
            hat.Material = Enum.Material.Neon
            hat.Color = Color3.fromRGB(255, 0, 255) -- Розовый неон
            hat.Transparency = 0.4
            
            local mesh = Instance.new("SpecialMesh", hat)
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://1033714" -- Стандартный конус
            mesh.Scale = Vector3.new(2.5, 1.2, 2.5)
        end
        hat.CFrame = head.CFrame * CFrame.new(0, 0.7, 0) * CFrame.Angles(0, tick() * 5, 0)
    elseif lp.Character and lp.Character.Head:FindFirstChild("IDK_Hat_v15") then
        lp.Character.Head.IDK_Hat_v15:Destroy()
    end

    -- 2. Box ESP
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= lp and p.Character then
            local box = p.Character:FindFirstChild("IDK_Box_v15")
            if visual_settings.boxes then
                if not box then
                    box = Instance.new("SelectionBox")
                    box.Name = "IDK_Box_v15"
                    box.Adornee = p.Character
                    box.Color3 = Color3.fromRGB(0, 255, 150)
                    box.LineThickness = 0.04
                    box.SurfaceColor3 = Color3.fromRGB(0, 255, 150)
                    box.SurfaceTransparency = 0.9
                    box.AlwaysOnTop = true
                    box.Parent = p.Character
                end
            else
                if box then box:Destroy() end
            end
        end
    end
end)

local function createCircle()
    if not visual_settings.jumpcircles then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local p = Instance.new("Part")
        p.Name = "JumpCircle"
        p.Parent = workspace
        p.Anchored = true
        p.CanCollide = false
        p.Size = Vector3.new(1, 0.1, 1)
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(0, 255, 255)
        p.Transparency = 0.3
        p.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0,0,0)
        
        local m = Instance.new("SpecialMesh", p)
        m.MeshType = Enum.MeshType.Cylinder
        
        task.spawn(function()
            for i = 1, 25 do
                p.Size = p.Size + Vector3.new(0.8, 0, 0.8)
                p.Transparency = p.Transparency + 0.03
                run_svc.Heartbeat:Wait()
            end
            p:Destroy()
        end)
    end
end
    local function setupJumpDetection(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(old, new)
        if new == Enum.HumanoidStateType.Jumping then
            createCircle()
        end
    end)
end

lp.CharacterAdded:Connect(setupJumpDetection)
if lp.Character then setupJumpDetection(lp.Character) end

Rayfield:Notify({
   Title = "IDKKKK HUB v1.5",
   Content = "Загружено успешно! Приятной игры.",
   Duration = 5,
   Image = 4483362458,
})
