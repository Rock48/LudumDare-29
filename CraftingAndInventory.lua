
player = Player:new()
ireg = {}

itemInventory = {}

OIL_TIME = 1.5--seconds
curTime = 0

function updateInventory(dt) -- Update conversion between oil & coal + perhaps more
  inv = table.set(itemInventory)
  
  
  if(inv[ireg.refinery]) then
    curTime = curTime + dt
    if(curTime > OIL_TIME) then
      curTime = 0
      if(resources["oil"].amount>1.5) then
        resources["oil"].amount = resources["oil"].amount - 1.5
        resources["plastic"].amount = resources["plastic"].amount + 1
      end
    end
  end
end

function craftingButtons()
  
  av_items = {}
  
  for k, v in pairs(ireg) do
    if(isCraftingAvailibleForItem(v)) then
      table.insert(av_items, v)
    end
  end
  
  cx = 325
  cy = 25/2
  
  for k, v in pairs(av_items) do
    materials = ""
    even = false
    for i,j in pairs(v.craftingmaterials) do
      materials = materials..resources[i].name..": "..j
      if even then materials = materials .."\n" else materials = materials.."\t\t\t" end
      even = not even
    end
    
    if(gui.Button(v.name.."\n"..materials, cx, cy, 400, 120, nil, true)) then
      craftItem(v)
    end
    
    cy = cy + 120
  end
end

function newItem(name, requirement, craftingmaterials, oncraft)
  item = {}
  item.name = name
  item.requirement = requirement
  item.craftingmaterials = craftingmaterials -- table?
  item.oncraft = oncraft
  item.crafted = false
  
  return item
end

function isCraftingAvailibleForItem(item)
  if(item.crafted) then return false end -- if item is already crafted
  if(item.requirement==nil) then return true end -- if item has no requirements
  for _, v in pairs(item.requirement) do
    if(not inv[v]) then
      return false
    end
  end
  
  return true
end
function craftItem(item)
  
  if(not isCraftingAvailibleForItem(item)) then return false end
  
  if(item.craftingmaterials ~= nil) then
    for k, v in pairs(item.craftingmaterials) do
      if(resources[k].amount < v) then return false end
    end
    for k, v in pairs(item.craftingmaterials) do
      resources[k].amount = resources[k].amount - v
    end
  end
  
  table.insert(itemInventory, item)
  
  item.crafted = true
  
  if(item.oncraft) then item.oncraft() end
  
end

-- Crafting Requirements (Machines etc)
ireg.refinery = newItem("Plastic Refinery", nil, {iron = 200}, nil)
ireg.refinery2 = newItem("Overclock Refinery", {ireg.refinery}, {iron = 1000}, function ()
  OIL_TIME = 1
end)
ireg.refinery3 = newItem("Power Refinery With Uranium", {ireg.refinery2}, {iron = 500, uranium = 20}, function()
  OIL_TIME = 0.4
end)
ireg.refinery4 = newItem("Overclock Refinery Again", {ireg.refinery3}, {plastic=800, iron=400}, function()
  OIL_TIME = 0.15
end)

-- Equipment
ireg.tankMk1 = newItem("Home-Made Tank", nil, {iron = 20},  function()
  player.airCapacity = 10
end)
ireg.tankMk2 = newItem("Reinforced Tank", {ireg.tankMk1}, {iron = 50}, function()
  player.airCapacity = 15
end)
ireg.tankMk3 = newItem("Sealed Tank", {ireg.tankMk2, ireg.refinery}, {iron = 80, plastic=15}, function()
  player.airCapacity = 25
end)
ireg.tankMk4 = newItem("Reinsealed Tank", {ireg.tankMk3, ireg.refinery}, {iron = 150, plastic=40}, function()
  player.airCapacity = 40
end)
ireg.tankMk5 = newItem("Mega-Evolved Tank", {ireg.tankMk4, ireg.refinery}, {iron = 300, plastic=80}, function()
  player.airCapacity = 70
end)
ireg.tankMk6 = newItem("Giga Tank", {ireg.tankMk5, ireg.refinery}, {iron = 1000, plastic=120, uranium=5}, function()
  player.airCapacity = 100
end)
ireg.tankMk7 = newItem("SuperMegaUberTank5000", {ireg.tankMk6, ireg.refinery}, {iron = 2500, plastic=300, uranium=15}, function()
  player.airCapacity = 180
end)

ireg.pSuitMk1 = newItem("Pressure Suit", nil, {iron=120}, function() 
  player.maxDepth = 2000
end)
ireg.pSuitMk2 = newItem("High Pressure Suit", {ireg.pSuitMk1}, {iron=250,plastic=25}, function()
  player.maxDepth = 4000
end)
ireg.pSuitMk3 = newItem("Double Pressure Suit", {ireg.pSuitMk2}, {iron=1000,plastic=100}, function()
  player.maxDepth = 12000 
end)
ireg.pSuitMk4 = newItem("Radioactive Pressure Suit", {ireg.pSuitMk3}, {iron=1500,plastic=150, uranium=5}, function()
  player.maxDepth = 16000
end)
ireg.pSuitMk5 = newItem("Fusion Powered Pressure Suit", {ireg.pSuitMk4}, {iron=3500, plastic=500, uranium=35}, function()
  player.maxDepth = 20000
end)

ireg.flippers = newItem("Flippers", {ireg.refinery}, {plastic=50}, function()
  PLAYER_SPEED = PLAYER_SPEED + 90
end)
ireg.rockets = newItem("Rockets", {ireg.refinery, ireg.flippers}, {plastic=200, iron=1000}, function()
  PLAYER_SPEED = PLAYER_SPEED + 140
end)
ireg.radRockets = newItem("Radioactive Rocket", {ireg.refinery, ireg.rockets}, {plastic=600, iron=2000, uranium=25}, function()
  PLAYER_SPEED = PLAYER_SPEED + 180
end)

-- Other

ireg.escapeShip = newItem("Escape Boat", {ireg.pSuitMk5}, {iron=4000, plastic=600, uranium=40, powerCrystal=1}, function()
  
  lightWorld = love.light.newWorld()
  lightWorld.setAmbientColor(40,40,40)
  
  winImg = love.graphics.newImage("Winner.png")
  
  rotation_amount = 0
  
  
  light1 = lightWorld.newLight(400, 300, 255,0,0,500)
  light1.setAngle(math.rad(180))
  light2 = lightWorld.newLight(400, 300, 0,255,0,500)
  light2.setAngle(math.rad(180))
  light2.setDirection(math.rad(rotation_amount+120))
  light3 = lightWorld.newLight(400, 300, 0,0,255,500)
  light3.setAngle(math.rad(180))
  light3.setDirection(math.rad(rotation_amount+240))
  
  gamestate = WIN
end)