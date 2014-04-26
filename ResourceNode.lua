ResourceNode = class("ResourceNode")

function ResourceNode:initialize(resource, x, y, size)
  self.resource = resource
  self.x = x
  self.y = y
  self.size = size
end

function ResourceNode:checkForPlayerPickup()
  if(player.x + 20 > self.x and player.x - 20 < self.x + RESOURCE_SIZE and player.y + 20 > self.y and player.y - 20 < self.y + RESOURCE_SIZE) then
    self.resource:addToExploringPlayer(self.size)
    return true -- handle removal of this from the world
  end
  return false
end

function ResourceNode:draw()
  love.graphics.setColor(self.resource:getTexture())
  love.graphics.rectangle("fill",self.x,self.y,RESOURCE_SIZE,RESOURCE_SIZE)
  love.graphics.setFont(resource_amt_font)
  love.graphics.printf(self.size,self.x+RESOURCE_SIZE/2, self.y + RESOURCE_SIZE + 10, 0, "center")
  love.graphics.setFont(ui_font)
end