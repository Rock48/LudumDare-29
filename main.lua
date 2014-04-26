require "lib/light"
require "lib/postshader"
class = require "middleclass"
gui = require "imgui/gui"

require "Resource"
require "Player"
require "ResourceNode"
require "CraftingAndInventory"



MAIN_MENU = 0
CRAFTING_MENU = 1
EXPLORING = 2
EXPLORING_OVERVIEW = 3

gamestate = CRAFTING_MENU

RESOURCE_SIZE = 24



function love.load(arg)
  
  player.airCapacity = 7.5
  
  ui_font = love.graphics.setNewFont("Ubuntu.ttf", 48)
  resource_amt_font = love.graphics.newFont("Ubuntu.ttf", 12)
  
  nodes = {}
  
  resources = {}
  
  resources["iron"] = Resource:new("Iron", nil, nil, 140, 50, 20)
  
  table.insert(nodes, ResourceNode:new(resources["iron"], 150, 150, 5))
  table.insert(nodes, ResourceNode:new(resources["iron"], 600, 150, 5))
  table.insert(nodes, ResourceNode:new(resources["iron"], 500, 350, 5))
  table.insert(nodes, ResourceNode:new(resources["iron"], 700, 450, 5))
  table.insert(nodes, ResourceNode:new(resources["iron"], 250, 400, 5))
  table.insert(nodes, ResourceNode:new(resources["iron"], 300, 500, 5))
  
end

PLAYER_SPEED = 230

function love.update(dt)
  if(gamestate == EXPLORING) then
    player:update(dt)
    
    if(love.keyboard.isDown("w")) then player.y = player.y - PLAYER_SPEED * dt end
    if(love.keyboard.isDown("s")) then player.y = player.y + PLAYER_SPEED * dt end
    if(love.keyboard.isDown("a")) then player.x = player.x - PLAYER_SPEED * dt end
    if(love.keyboard.isDown("d")) then player.x = player.x + PLAYER_SPEED * dt end
    
    
    removealQueue = {}
    for k, v in pairs(nodes) do if(v:checkForPlayerPickup()) then table.insert(removealQueue, k) end end
    
    for k, v in pairs(removealQueue) do
      table.remove(nodes, v)
    end
  end
  if(gamestate == EXPLORING_OVERVIEW) then
    if(gui.Button("Continue", 450, 300, 200, 100)) then
      gamestate = CRAFTING_MENU
    end
  end
  if(gamestate == CRAFTING_MENU) then
    
    if(gui.Button("Upgrade Tank",300,50,100,50)) then
      craftItem(ireg.tankMk1)
    end
    
    if(gui.Button("Continue", 450, 300, 200, 100)) then
      switchToPlayState()
    end
  end
end

function love.draw()
  
    love.graphics.setColor(255,255,255)
  if(gamestate == EXPLORING) then
    love.graphics.print("Air: "..round(player.currentAir,2).." / "..player.airCapacity, 0,0)
    
    for k, v in pairs(nodes) do
      v:draw()
    end
    love.graphics.setColor(0,150,0)
    player:draw()
  end
  
  if(gamestate == EXPLORING_OVERVIEW) then
    
    res_string = "You Collected:\n"
    
    for k, v in pairs(resources) do
      res_string = res_string..v.name..": "..player.inventory[v.name].."\n"
    end
    
    love.graphics.print(res_string, 0,0)
    
  end
  
  if(gamestate == CRAFTING_MENU) then
    
    res_string = "Your Stash:\n"
    
    for k, v in pairs(resources) do
      res_string = res_string..v.name..": "..v.amount.."\n"
    end
    
    love.graphics.print(res_string, 0,0)
    
  end
  gui.core.draw()
end

function switchToPlayState()
  player:switchToPlayState(50, 50)
  gamestate = EXPLORING
end
function endPlayState()
  for k, v in pairs(resources) do
    v.amount = v.amount + player.inventory[v.name]
  end
  gamestate = EXPLORING_OVERVIEW
end

function round(num, idp) -- from lua-users.org/wiki/SimpleRound
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end