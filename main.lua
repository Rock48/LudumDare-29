require "lib/light"
require "lib/postshader"
class = require "middleclass"
gui = require "imgui/gui"
require "AnAL"

require "Resource"
require "Player"
require "ResourceNode"
require "CraftingAndInventory"


TUTORIAL_0 = 0
TUTORIAL_1 = 0.1
TUTORIAL_2 = 0.2
TUTORIAL_3 = 0.2

CRAFTING_MENU = 1
EXPLORING = 2
EXPLORING_OVERVIEW = 3
WIN = 4

gamestate = CRAFTING_MENU
RESOURCE_SIZE = 24

function defaultConfig()
  key_up = "w"
  key_down = "s"
  key_left = "a"
  key_right = "d"
  shake_enabled = true
end

function readConfig()
  
  dir = love.filesystem.getWorkingDirectory()
  
  --if(love.filesystem.exists("config.lua")) then
    conf = require "config"
    key_up = conf.up
    key_down = conf.down
    key_right = conf.right
    key_left = conf.left
    shake_enabled = conf.enable_shake
  --else
    --defaultConfig()
  --end
end

function table.set(t) -- set of list
  local u = { }
  for _, v in ipairs(t) do u[v] = true end
  return u
end

function love.load(arg)
  
  --require("mobdebug").start()
  
  readConfig()
  
  oil = love.graphics.newImage("oil.png")
  iron = love.graphics.newImage("iron.png")
  urnaium = love.graphics.newImage("uranium.png")
  crystal = love.graphics.newImage("powerCrystal.png")
  player_img = love.graphics.newImage("player.png")
  player_anim = newAnimation(player_img, 40, 40, 0.2, 0)
  
  theme = love.audio.newSource("craft.wav")
  theme:setLooping(true)
  theme:setVolume(0.25)
  iPickup1 = love.audio.newSource("itemPickup1.wav")
  iPickup1:setVolume(0.15)
  iPickup2 = love.audio.newSource("itemPickup2.wav")
  iPickup2:setVolume(0.25)
  explMusic = love.audio.newSource("music.wav")
  explMusic:setLooping(true)
  explMusic:setVolume(0.15)
  craftSound = love.audio.newSource("craftItem.wav")
  craftSound:setVolume(0.25)
  
  
  player.airCapacity = 7.5
  
  ui_font = love.graphics.setNewFont("Ubuntu.ttf", 42)
  resource_amt_font = love.graphics.newFont("Ubuntu.ttf", 12)
  gui_font = love.graphics.newFont("Ubuntu.ttf",24)
  
  nodes = {}
  
  resources = {}
  
  resources["iron"] = Resource:new("Iron", nil, iron, 140, 50, 20)
  resources["plastic"] = Resource:new("Plastic", nil, nil, nil, nil, nil)
  resources["oil"] = Resource:new("Oil",nil,oil,50,50,50)
  resources["uranium"] = Resource:new("Uranium",nil,urnaium,0,255,0)
  resources["powerCrystal"] = Resource:new("Power Crystal",nil,crystal,0,150,255)
  
  bg = love.graphics.newImage("oceanBackground.png")
  bg:setWrap("repeat","repeat")
  
  bgQuad = love.graphics.newQuad(0, 0, love.window.getWidth(), love.window.getHeight() + 64, 64, 64)
  
  waves = love.graphics.newImage("waves.png")
  
  theme:play()
  
end

PLAYER_SPEED = 120

playerAngle = 0

function love.update(dt)
  
  if(gamestate ~= MAIN_MENU) then
    updateInventory(dt)
  end
  
  if(gamestate == EXPLORING) then
    player:update(dt)
    
    if(love.keyboard.isDown(key_up)) then 
      
      up = true
      
      player.y = player.y - PLAYER_SPEED * dt 
      if(player.y < 200 + cam_y) then
        cam_y = cam_y - PLAYER_SPEED * dt 
      end
      if(player.y < 0) then
        endPlayState()
      end
    else
      up = false
    end  
    
    if(love.keyboard.isDown(key_down)) then 
      down = true
      player.y = player.y + PLAYER_SPEED * dt 
      if(player.y > 400 + cam_y) then
        cam_y = cam_y + PLAYER_SPEED * dt 
      end
    else
      down = false
    end  
    if(love.keyboard.isDown(key_left)) then 
      left = true
      player.x = player.x - PLAYER_SPEED * dt
    else
      left = false
    end  
    if(love.keyboard.isDown(key_right)) then 
      right = true
      player.x = player.x + PLAYER_SPEED * dt 
    else
      right = false
    end  
    
    
    --player image rotation calculation
    if(up and not down and not left and not right) then
      playerAngle = 0
    end
    if(not up and down and not left and not right) then
      playerAngle = 180
    end
    if(not up and not down and left and not right) then
      playerAngle = -90
    end
    if(not up and not down and not left and right) then
      playerAngle = 90
    end
    if(up and not down and left and not right) then
      playerAngle = -45
    end
    if(up and not down and not left and right) then
      playerAngle = 45
    end
    if(not up and down and left and not right) then
      playerAngle = -135
    end
    if(not up and down and not left and right) then
      playerAngle = 135
    end
    if(up or down or left or right) then
      player_anim:play()
    else
      player_anim:stop()
      player_anim:reset()
    end
    player_anim:update(dt)
    
    removealQueue = {}
    for k, v in pairs(nodes) do if(v:checkForPlayerPickup()) then 
        table.insert(removealQueue, k) 
        if(math.random(1,2) == 1) then
          iPickup1:clone():play()
        else
          iPickup2:clone():play()
        end
      end 
    end
    
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
    
    if(gui.Button("Music: "..music_on, 450, 500, 175, 75)) then
      if(music_on == "enabled") then
        music_on = "disabled"
        theme:stop()
      else
        music_on = "enabled"
        theme:play()
      end
    end
    
  end
  
  if(gamestate == WIN) then
    rotation_amount = rotation_amount - dt * 30
    light1.setDirection(math.rad(rotation_amount))
    light2.setDirection(math.rad(rotation_amount+120))
    light3.setDirection(math.rad(rotation_amount+240))
  end
  
end
music_on = "enabled"

shake_mult = 0

cam_y = -200
function love.draw()
  
  love.graphics.setColor(255,255,255)
  if(gamestate == EXPLORING) then
    
    
    love.graphics.push()
      if(shake_enabled) then
        love.graphics.translate(math.random()*shake_mult*2-shake_mult,math.random()*shake_mult*2-shake_mult) end
      love.graphics.draw(bg, bgQuad, 0, -cam_y % 64 -64)
      love.graphics.translate(0,-cam_y)
      
      love.graphics.setColor(120,140,255)
      love.graphics.rectangle("fill",0,0,800,-600)
      love.graphics.setColor(255,255,255)
      for i = 0, 800, 64 do
        love.graphics.draw(waves, i,-32)
      end
      --love.graphics.draw(bg,0,0)
      love.graphics.setColor(255,255,255)
      for k, v in pairs(nodes) do
        v:draw()
      end
      love.graphics.setColor(255,255,255)
      
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
      
      if(i*SPARSITY<2000) then
        iron = math.random(1, 15)
        oil = math.random(1, 5)
        uranium = 0
      elseif(i*SPARSITY<4000) then
        iron = math.random(5, 20)
        oil = math.random(3, 7)
        uranium = 0
        
      elseif(i*SPARSITY<8000) then
        iron = math.random(10, 30)
        oil = math.random(5, 12)
        uranium = 0
        
      elseif(i*SPARSITY<12000) then
        iron = math.random(25, 40)
        oil = math.random(7, 15)
        uranium = math.random(1,3)
        
      elseif(i*SPARSITY<16000) then
        
        iron = math.random(35, 60)
        oil = math.random(17, 25)
        uranium = math.random(3,6)
        
      else
        
        iron = math.random(55, 80)
        oil = math.random(28, 40)
        uranium = math.random(5,10)
        
      end
      
      if(rand<5) then
        table.insert(nodes, ResourceNode:new(resources["iron"], j*SPARSITY, i*SPARSITY, iron))
      elseif(rand<7) then
        table.insert(nodes, ResourceNode:new(resources["oil"], j*SPARSITY, i*SPARSITY, oil))
      elseif(rand<8 and i*SPARSITY>10000) then
        table.insert(nodes, ResourceNode:new(resources["uranium"], j*SPARSITY, i*SPARSITY, uranium))
      end
    end
  end
  table.insert(nodes, ResourceNode:new(resources["powerCrystal"], 388, 19800, 1))
end

function switchToPlayState()
  
  genWorld()
  
  theme:stop()
  if(music_on == "enabled") then
    explMusic:play()
  end
  
  cam_y = -200
  player:switchToPlayState(400, 100)
  gamestate = EXPLORING
end
function endPlayState()
  if(music_on == "enabled") then
    theme:play()
  end
  explMusic:stop()
  for k, v in pairs(resources) do
    v.amount = v.amount + player.inventory[v.name]
  end
  gamestate = EXPLORING_OVERVIEW
end

function round(num, idp) -- from lua-users.org/wiki/SimpleRound
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end