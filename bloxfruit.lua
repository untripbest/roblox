local ts = game:GetService("TweenService")
local webhookUrl = "https://discord.com/api/webhooks/1048474854980063294/hO8p5eV-M0n3ILvMgIIoeIqVcfjgRV1-q4TtOm-Ei7lC0EFwmTShAY2xgmcKOI9cRI_y"
test
local blacklisted = {
  "Kilo",
  "Spin",
  "Chop",
  "Spring",
  "Bomb",
  "Smoke",
  "Spike",
  "Flame",
  "Falcon",
  "Ice",
  "Sand",
  "Dark",
  "Revive",
  "Diamond",
  "Light",
  "Love",
  "Rubber",
  "Barrier",
  "Magu", -- (magma)
  --"Door",
  "Quake",
  "Smouke", -- (smoke)
  --"Buddha",
  "Cube.010", -- (rubber)
  -- "String",
  -- "Phoenix",
  -- "Rumble",
  -- "Paw",
  -- "Gravity",
  -- "Dough",
  -- "Shadow",
  -- "Venom",
  -- "Control",
  -- "Soul",
  -- "Dragon",
  -- "Leopard"
}

local function webhook_msg(str)
  local httpService = game:GetService("HttpService")
  syn.request(
    {
      Url = webhookUrl, 
      Method = "POST",
      Headers = {
				["Content-Type"] = "application/json"
      },
      Body = httpService:JSONEncode({content = str})
    }
  )
end

local function good_fruit(fruit)
  if not (fruit:IsA("Tool") or fruit:IsA("Model")) then return end
  if fruit:FindFirstChild("Humanoid") then return end
  if not fruit.Name:find("Fruit") then return end
  if fruit.Name == "Fruit " then
      for i, p in next, fruit:GetDescendants() do
          for i, name in next, blacklisted do
              if p.Name:lower():find(name:lower()) then
                  return false, name
              end
          end
      end
  else
      for i, name in next, blacklisted do
          if fruit.Name:lower():find(name:lower()) then
              return false, name
          end
      end
  end
  -- ALL CHECKS PASSED! MUST BE GOD FRUIT
  local msg = "POTENTIAL GOD FOUND @everyone"
  for i, p in next, fruit:GetDescendants() do
      if p:IsA("BasePart") then msg ..= "\n" .. p.Name end
  end
  return true, msg:sub(1, 1200)
end

local plr = game:GetService("Players").LocalPlayer
while not plr do game:GetService("Players").PlayerAdded:Wait() plr = game:GetService("Players").LocalPlayer end

local function main()
  -- change team + change camera
  game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
  plr.PlayerGui.Main:FindFirstChild("ChooseTeam").Visible = false
  workspace.CurrentCamera.CameraType = "Custom"
  workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid

  plr.Character.ChildAdded:Connect(function(c)
    if c.Name:find("Fruit") then
      game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", c:GetAttribute("OriginalName"), c)
    end 
  end)

  plr.Backpack.ChildAdded:Connect(function(c)
    if c.Name:find("Fruit") then
      game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", c:GetAttribute("OriginalName"), c)
    end
  end)

  -- find fruit
  for i,v in next, workspace:GetChildren() do
    local goodFruit, msg = good_fruit(v)
    if msg then webhook_msg(msg) end
    if goodFruit then
      local handle = v.Handle
      while (v.Parent == workspace) do
        local tween = ts:Create(
        plr.Character.PrimaryPart, 
        TweenInfo.new((plr:DistanceFromCharacter(handle.Position) - 100) / 320, Enum.EasingStyle.Linear),
        {CFrame = handle.CFrame + Vector3.new(0, handle.Size.Y, 0)}
        )
        tween:Play()
        tween.Completed:Wait()
      end
      task.wait(1)
    end
  end
  -- teleport to new server
  local succ, games
  while not succ do
    succ, games = pcall(game.HttpGet, game, "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=1&excludeFullGames=true&limit=100")
  end

  local json = game:GetService("HttpService"):JSONDecode(games)
  for i = #json.data, 1, -1 do
    if json.data[i].playing ~= nil and json.data[i].id ~= game.JobId then
      print(pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, json.data[i].id)
      end))
      task.wait(1)
    end
  end
end

plr:WaitForChild("PlayerGui").DescendantRemoving:Connect(function(d)
  if d.Name == "LoadingScreen" then
    main()
  end
end)
