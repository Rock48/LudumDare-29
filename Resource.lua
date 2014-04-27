Resource = class("Resource")
function Resource:initialize(name, weight, texture, r, g, b)
  self.name = name
  
  self.amount = 20000
  self.weight = weight
  
  self.texture = texture
  
  player.inventory[name] = 0
  
  self.r = r
  self.g = g
  self.b = b
end
function Resource:addToExploringPlayer(amount)
  player.inventory[self.name] = player.inventory[self.name] + amount
end
function Resource:getTexture() 
  return self.r, self.g, self.b
end