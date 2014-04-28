Player = class("player")

function Player:initialize()
  self.x = 0
  self.y = 0
  self.maxWeight = 0
  self.currentWeight = 0
  self.currentAir = 0
  self.airCapacity = 0
  self.maxDepth = 1000
  self.inventory = {}
end

function Player:switchToPlayState(x, y)
  self.x = x
  self.y = y
  
  self.currentWeight = 0
  self.currentAir = self.airCapacity
  
  print (self.airCapacity)
  
  for k, v in pairs(self.inventory) do
    self.inventory[k] = 0
  end
end

function Player:update(dt)
  self.currentAir = self.currentAir - dt
  
  if(self.currentAir <= 0) then
    endPlayState()
  end
end
function Player:draw()
  love.graphics.push()
  love.graphics.translate(self.x,self.y)
  love.graphics.rotate(math.rad(playerAngle))
  player_anim:draw(-20, -20)--, math.rad(playerAngle),1,1,20,20)
  love.graphics.pop()
end