
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
  
  cx = 250
  cy = 25/2
  
  for k, v in pairs(av_items) do
    materials = ""
    for i,j in pairs(v.craftingmaterials) do
      materials = materials..resources[i].name..": "..j.."\n"
      
    end
    
    if(gui.Button(v.name.."\n"..materials, cx, cy, 200, 125, nil, true)) then
      craftItem(v)
    end
    
    cy = cy + 150
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
ireg.refinery2 = newItem("Overclocked Refinery", {ireg.refinery}, {iron = 1000}, function ()
  OIL_TIME = 1
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

ireg.pSuitMk1 = newItem("Pressure Suit", nil, {iron=120}, function() 
  player.maxDepth = 2000
  end)

ireg.flippers = newItem("Flippers", {ireg.refinery}, {plastic=50}, function()
  PLAYER_SPEED = PLAYER_SPEED + 90
end)