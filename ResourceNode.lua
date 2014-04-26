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
  if(self.y > cam_y and self.y < cam_y + 800) then
    love.graphics.setFont(resource_amt_font)
    if(self.resource.texture ~= nil) then
      love.graphics.draw(self.resource.texture,self.x,self.y)
      love.graphics.setColor(255,255,255)
      love.graphics.printf(self.size,self.x+RESOURCE_SIZE/2, self.y + RESOURCE_SIZE, 0, "center")
    else
      love.graphics.setColor(self.resource:getTexture())
      love.graphics.rectangle("fill",self.x,self.y,RESOURCE_SIZE,RESOURCE_SIZE)
      love.graphics.setColor(255,255,255)
      love.graphics.printf(self.size,self.x+RESOURCE_SIZE/2, self.y + RESOURCE_SIZE - 20, 0, "center")
    end
    love.graphics.setFont(ui_font)
  end
end