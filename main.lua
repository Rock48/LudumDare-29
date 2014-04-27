require "lib/light"
require "lib/postshader"
class = require "middleclass"
gui = require "imgui/gui"

require "Resource"
require "Player"
require "ResourceNode"
require "CraftingAndInventory"

CRAFTING_MENU = 1
EXPLORING = 2
EXPLORING_OVERVIEW = 3
WIN = 4

gamestate = CRAFTING_MENU

RESOURCE_SIZE = 24

function table.set(t) -- set of list
  local u = { }
  for _, v in ipairs(t) do u[v] = true end
  return u
end

function love.load(arg)
  
  --require("mobdebug").start()
  
  oil = love.graphics.newImage("oil.png")
  iron = love.graphics.newImage("iron.png")
  
  player.airCapacity = 7.5
  
  ui_font = love.graphics.setNewFont("Ubuntu.ttf", 42)
  resource_amt_font = love.graphics.newFont("Ubuntu.ttf", 12)
  gui_font = love.graphics.newFont("Ubuntu.ttf",24)
  
  nodes = {}
  
  resources = {}
  
  resources["iron"] = Resource:new("Iron", nil, iron, 140, 50, 20)
  resources["plastic"] = Resource:new("Plastic", nil, nil, nil, nil, nil)
  resources["oil"] = Resource:new("Oil",nil,oil,50,50,50)
  resources["uranium"] = Resource:new("Uranium",nil,nil,0,255,0)
  resources["powerCrystal"] = Resource:new("Power Crystal",nil,nil,0,150,255)
  
  bg = love.graphics.newImage("oceanBackground.png")
  bg:setWrap("repeat","repeat")
  
  bgQuad = love.graphics.newQuad(0, 0, love.window.getWidth(), love.window.getHeight() + 64, 64, 64)
end

PLAYER_SPEED = 120



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
      if(player.y < 0) then
        endPlayState()
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
    end
    if(love.keyboard.isDown("d")) then 
      player.x = player.x + PLAYER_SPEED * dt 
    end
    
    removealQueue = {}
    for k, v in pairs(nodes) do if(v:checkForPlayerPickup()) then table.insert(removealQueue, k) end end
    
    for k, v in pairs(removealQueue) do
      table.remove(nodes, v)
    end
    
    -- calculate shake for given pressure suit
    
    if(player.y > player.maxDepth - 500) then
      shake_mult = ((player.y - player.maxDepth + 500) / 500) * 10
      print(shake_mult)
    else
      shake_mult = 0
    end
    
    if(shake_mult >= 10) then
      endPlayState()
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
  
  if(gamestate == WIN) then
    rotation_amount = rotation_amount - dt * 30
    light1.setDirection(math.rad(rotation_amount))
    light2.setDirection(math.rad(rotation_amount+120))
    light3.setDirection(math.rad(rotation_amount+240))
  end
  
end

shake_mult = 0

cam_y = 0
function love.draw()
  
  love.graphics.setColor(255,255,255)
  if(gamestate == EXPLORING) then
    
    
    love.graphics.push()
      --shake test
      
      love.graphics.translate(math.random()*shake_mult*2-shake_mult,math.random()*shake_mult*2-shake_mult)
      love.graphics.draw(bg, bgQuad, 0, -cam_y % 64 -64)
      love.graphics.translate(0,-cam_y)
      love.graphics.setColor(150,180,255)
      love.graphics.rectangle("fill",0,0,800,-600)
      --love.graphics.draw(bg,0,0)
      love.graphics.setColor(255,255,255)
      for k, v in pairs(nodes) do
        v:draw()
      end
      love.graphics.setColor(0,150,0)
      
      player:draw()
    love.graphics.pop()
    
    
    
    love.graphics.print("Air: "..round(player.currentAir,1).." / "..player.airCapacity.."\nDepth: "..round(player.y,0).."/"..player.maxDepth, 0,0)
    if(shake_mult > 7) then
      love.graphics.setColor(255,0,0)
      love.graphics.printf("Pressure Nearing Critical!!!", 400,100,0,"center")
    end
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
    
    love.graphics.print(res_string.."\nStats:\nMax Depth\n"..player.maxDepth.."\nSpeed: "..PLAYER_SPEED.."\nAir: "..player.airCapacity, 0,0)
    
  end
  
  if(gamestate == WIN) then
    
    love.graphics.setColor(255,255,255)
    
    lightWorld.update()
    
    love.graphics.rectangle("fill",0,0,800,600)
    
    lightWorld.drawShadow()
    
    love.graphics.draw(winImg,0,0)
    
    love.graphics.printf("Contratulations! You Escaped!", 0,500, 800, "center")
    
    lightWorld.drawShine()
    
  end
  
  love.graphics.setFont(gui_font)
  gui.core.draw()
  love.graphics.setFont(ui_font)
  
end

OCEAN_DEPTH = 20000

SPARSITY = 32

function genWorld()
  nodes = {}
    math.randomseed(os.time())
  for i = 0, OCEAN_DEPTH/SPARSITY do
    for j = 0, 100 do
      rand = math.random(0, 500)
      
      if(rand<5) then
        table.insert(nodes, ResourceNode:new(resources["iron"], j*SPARSITY, i*SPARSITY, math.random(1, 15)))
      elseif(rand<7) then
        table.insert(nodes, ResourceNode:new(resources["oil"], j*SPARSITY, i*SPARSITY, math.random(1, 5)))
      elseif(rand<8 and i*SPARSITY>10000) then
        table.insert(nodes, ResourceNode:new(resources["uranium"], j*SPARSITY, i*SPARSITY, math.random(1, 1)))
      end
    end
  end
  table.insert(nodes, ResourceNode:new(resources["powerCrystal"], 388, 19800, 1))
end

function switchToPlayState()
  
  genWorld()
  
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