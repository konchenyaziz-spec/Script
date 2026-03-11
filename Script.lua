local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v1.6",
   LoadingTitle = "idkkkk hub",
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

MainTab:CreateSection("Локальный игрок")

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

MainTab:CreateSection("Контакты")

MainTab:CreateButton({
   Name = "Telegram: @idkkkk_dev",
   Callback = function()
       setclipboard("https://t.me/idkkkk_dev")
       Rayfield:Notify({
           Title = "Telegram",
           Content = "Ссылка скопирована в буфер обмена!",
           Duration = 5
       })
   end,
})

local TrollTab = Window:CreateTab("Trolling", 4483345998)

TrollTab:CreateInput({
   Name = "Target Name",
   PlaceholderText = "Target...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       for _, v in pairs(game:GetService("Players"):GetPlayers()) do
           if v.Name:lower():find(Text:lower()) or v.DisplayName:lower():find(Text:lower()) then
               bangTarget = v
               break
           end
       end
   end,
})

TrollTab:CreateToggle({
   Name = "Bang",
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
                           myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.9 + (i/10))
                           run_svc.Heartbeat:Wait()
                       end
                       for i = 6, 1, -1 do
                           if not banging then break end
                           myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.9 + (i/10))
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

local VisualTab = Window:CreateTab("Visuals", 4483346362)

VisualTab:CreateToggle({
   Name = "3D Box ESP",
   CurrentValue = false,
   Callback = function(Value) visual_settings.boxes = Value end,
})

VisualTab:CreateToggle({
   Name = "Small China Hat",
   CurrentValue = false,
   Callback = function(Value) visual_settings.chinahat = Value end,
})

VisualTab:CreateToggle({
   Name = "Big Jump Circles",
   CurrentValue = false,
   Callback = function(Value) visual_settings.jumpcircles = Value end,
})

run_svc.RenderStepped:Connect(function()
    if visual_settings.chinahat and lp.Character and lp.Character:FindFirstChild("Head") then
        local head = lp.Character.Head
        local hat = head:FindFirstChild("IDK_Hat")
        if not hat then
            hat = Instance.new("Part")
            hat.Name = "IDK_Hat"
            hat.CanCollide = false
            hat.Parent = head
            hat.Size = Vector3.new(1.2, 0.2, 1.2)
            hat.Material = Enum.Material.Neon
            hat.Color = Color3.fromRGB(255, 0, 100)
            hat.Transparency = 0.3
            
            local mesh = Instance.new("SpecialMesh", hat)
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://1033714"
            mesh.Scale = Vector3.new(1.5, 0.6, 1.5)
        end
        hat.CFrame = head.CFrame * CFrame.new(0, 0.55, 0)
    elseif lp.Character and lp.Character.Head:FindFirstChild("IDK_Hat") then
        lp.Character.Head.IDK_Hat:Destroy()
    end

    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local container = p.Character:FindFirstChild("IDK_ESP_Box")
            if visual_settings.boxes then
                if not container then
                    container = Instance.new("BoxHandleAdornment")
                    container.Name = "IDK_ESP_Box"
                    container.Parent = p.Character
                    container.Adornee = p.Character
                    container.AlwaysOnTop = true
                    container.ZIndex = 5
                    container.Transparency = 0.8
                    container.Color3 = Color3.fromRGB(255, 255, 255)
                    container.Size = Vector3.new(4, 5.5, 2)
                end
            else
                if container then container:Destroy() end
            end
        end
    end
end)

local function createJumpCircle()
    if not visual_settings.jumpcircles then return end
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local p = Instance.new("Part")
        p.Name = "IDK_Circle"
        p.Parent = workspace
        p.Anchored = true
        p.CanCollide = false
        p.CastShadow = false
        p.Size = Vector3.new(2, 0.05, 2)
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(0, 255, 255)
        p.Transparency = 0.2
        p.CFrame = CFrame.new(char.HumanoidRootPart.Position - Vector3.new(0, 2.9, 0))
        
        local m = Instance.new("SpecialMesh", p)
        m.MeshType = Enum.MeshType.Cylinder
        
        task.spawn(function()
            for i = 1, 30 do
                p.Size = p.Size + Vector3.new(1.2, 0, 1.2)
                p.Transparency = p.Transparency + 0.03
                run_svc.Heartbeat:Wait()
            end
            p:Destroy()
        end)
    end
end

local function setupDetection(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Jumping then
            createJumpCircle()
        end
    end)
end

lp.CharacterAdded:Connect(setupDetection)
if lp.Character then setupDetection(lp.Character) end

Rayfield:Notify({
   Title = "idkkkk hub",
   Content = "v1.6 Loaded by IDKKK team. TG: @idkkkk_dev",
   Duration = 5
})
