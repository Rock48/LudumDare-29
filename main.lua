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

function table.set(t) -- set of list
  local u = { }
  for _, v in ipairs(t) do u[v] = true end
  return u
end

function love.load(arg)
  
  player.airCapacity = 7.5
  
  ui_font = love.graphics.setNewFont("Ubuntu.ttf", 48)
  resource_amt_font = love.graphics.newFont("Ubuntu.ttf", 12)
  gui_font = love.graphics.newFont("Ubuntu.ttf",24)
  
  nodes = {}
  
  resources = {}
  
  resources["iron"] = Resource:new("Iron", nil, nil, 140, 50, 20)
  resources["plastic"] = Resource:new("Plastic", nil, nil, nil, nil, nil)
  resources["oil"] = Resource:new("Oil",nil,nil,50,50,50)
  
  bg = love.graphics.newImage("oceanBackground.png")
  bg:setWrap("repeat","repeat")
  
  bgQuad = love.graphics.newQuad(0, 0, love.window.getWidth() + 64, love.window.getHeight() + 64, 64, 64)
  
  table.insert(nodes, ResourceNode:new(resources["iron"], 150, 150, 40))
  table.insert(nodes, ResourceNode:new(resources["iron"], 600, 150, 35))
  table.insert(nodes, ResourceNode:new(resources["iron"], 500, 350, 25))
  table.insert(nodes, ResourceNode:new(resources["iron"], 700, 450, 150))
  table.insert(nodes, ResourceNode:new(resources["iron"], 250, 400, 35))
  table.insert(nodes, ResourceNode:new(resources["iron"], 300, 500, 20))
  
  table.insert(nodes, ResourceNode:new(resources["oil"], 50, 300, 35))
  
end

PLAYER_SPEED = 230

function love.update(dt)
  if(gamestate ~= MAIN_MENU) then
    updateInventory(dt)
  end
  
  if(gamestate == EXPLORING) then
    player:update(dt)
    
    if(love.keyboard.isDown("w")) then 
      player.y = player.y - PLAYER_SPEED * dt 
      if(player.y < 200 + cam_y) then
        cam_y = cam_y - PLAYER_SPEED * dt 
      end
    end
    if(love.keyboard.isDown("s")) 
      then player.y = player.y + PLAYER_SPEED * dt 
      if(player.y > 400 + cam_y) then
        cam_y = cam_y + PLAYER_SPEED * dt 
      end
    end
    if(love.keyboard.isDown("a")) 
      then player.x = player.x - PLAYER_SPEED * dt 
      if(player.x < 300 + cam_x) then
        cam_x = cam_x - PLAYER_SPEED * dt 
      end
    end
    if(love.keyboard.isDown("d")) then 
      player.x = player.x + PLAYER_SPEED * dt 
      if(player.x > 500 + cam_x) then
        cam_x = cam_x + PLAYER_SPEED * dt 
      end
    end
    
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
    
    craftingButtons()
    
    if(gui.Button("Continue", 650, 500, 125, 75)) then
      switchToPlayState()
    end
    
  end
end
cam_x, cam_y = 0, 0
function love.draw()
  
    love.graphics.setColor(255,255,255)
  if(gamestate == EXPLORING) then
    
    
    love.graphics.push()
      
       love.graphics.draw(bg, bgQuad, -cam_x % 64 - 64, -cam_y % 64 -64)
      love.graphics.translate(-cam_x,-cam_y)
      for k, v in pairs(nodes) do
        v:draw()
      end
      love.graphics.setColor(0,150,0)
      player:draw()
    love.graphics.pop()
    love.graphics.setColor(255,255,255)
    love.graphics.print("Air: "..round(player.currentAir,2).." / "..player.airCapacity, 0,0)
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
  love.graphics.setFont(gui_font)
  gui.core.draw()
  love.graphics.setFont(ui_font)
end

function switchToPlayState()
  cam_x = 0
  cam_y = 0
  player:switchToPlayState(400, 300)
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