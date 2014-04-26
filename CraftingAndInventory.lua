
player = Player:new()
ireg = {}

itemInventory = {ireg.basicTank, ireg.basicPressureSuit, ireg.basicBag}



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
  if(item.crafted) then return false end
  if(not item.requirement) then return true end
  for k, v in pairs(ireg) do
    if(v == item.requirement) then
      return true
    end
  end
  return false
end
function craftItem(item)
  
  if(not isCraftingAvailibleForItem(item)) then return false end
  
  if(item.craftingmaterials ~= nil) then
    for k, v in pairs(item.craftingmaterials) do
      
      if(resources[k].amount < v) then return false else resources[k].amount = resources[k].amount - v end
    end
  end
  
  
  
  table.insert(itemInventory, item)
  
  item.crafted = true
  
  if(item.oncraft) then item.oncraft() end
  
end

-- Starter Items
ireg.basicTank = newItem("Basic Tank", nil, {}, nil)
ireg.basicTank.crafted = true
ireg.basicPressureSuit = newItem("Basic Pressure Suit", nil, {}, nil)
ireg.basicPressureSuit.crafted = true
ireg.basicBag = newItem("Basic Bag", nil, {}, nil)
ireg.basicBag.crafted = true

-- Crafting Requirements (Machines etc)
ireg.refinery = newItem("Plasic Refinery", nil, {iron = 200}, nil)

-- Equipment
t1Crft = function()
  player.airCapacity = 10
  end
ireg.tankMk1 = newItem("Home-Made Tank", ireg.basicTank, {iron = 20},  t1Crft)
