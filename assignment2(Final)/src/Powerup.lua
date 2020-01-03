

Powerup = Class{}

function Powerup:init()
    
    self.width = 8
    self.height = 8
    self.x = math.random(16,VIRTUAL_WIDTH-16)
    self.y = -18
    -- drops from random x above screen
    self.dy = 0
    self.dx = 0
    

   
 

end


function Powerup:reload() -- function to reload powerup above screen after the drop
    if keyLevel and not key  then 
        --Update(III): if its key level and brick is still locked then probability of next powerup to be key = 1/3

        self.powerindex = math.random(3) == 1 and 2 or 1
    else
        --else next powerup will be extra balls
        self.powerindex = 1
    end
    
    self.x = math.random(16,VIRTUAL_WIDTH-16)
    self.y = -18
    self.dy = 0
    self.dx = 0
end


function Powerup:update(dt)

    self.x = self.x + self.dx
    self.y = self.y + self.dy
    --powerup can collide with the walls while its way down
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx + 1 --increament of speed a bit
        gSounds['wall-hit']:play()
    end

    if self.x >= VIRTUAL_WIDTH - 8 then
        self.x = VIRTUAL_WIDTH - 8
        self.dx = -self.dx - 1
        gSounds['wall-hit']:play()
    end

    --same as ball
end

function Powerup:collide(target)

    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

  
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

   --same as ball
    return true
end


function Powerup:render()
    --rendering

    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.powerindex],
        self.x, self.y)

end













