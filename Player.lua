Player = class("player")

function Player:initialize()
  self.x = 0
  self.y = 0
  self.maxWeight = 0
  self.currentWeight = 0
  self.currentAir = 0
  self.airCapacity = 0
  self.maxDepth = 0
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
  love.graphics.circle("fill",self.x,self.y,20)
end