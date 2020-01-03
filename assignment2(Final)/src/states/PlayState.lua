--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
key = false
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
    
    self.powerup  = Powerup() --Update(I):Init powerup

    self.recoverPoints = params.recoverPoints

    self.powerCounter = 0 -- Update(I): Time note
    self.randomTime = math.random(10,15) -- Threshold time for Releasing Powerup
    self.totalBalls = 0 -- count of no of (power)balls assigned
    if keyLevel and not key  then--Update(II)
        self.powerup.powerindex = math.random(3) == 1 and 2 or 1
    else
        self.powerup.powerindex = 1
    end

    -- give ball random starting velocity
    self.balls[0].dx = math.random(-200, 200)
    self.balls[0].dy = math.random(-50, -60)
    self.currentdy = self.balls[0].dy-- Update(I)
    
    self.paddlePoints = params.paddlePoints


end

function PlayState:update(dt)

    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self.powerCounter = self.powerCounter + dt--Update(I)

    -- update positions based on velocity
    self.paddle:update(dt)
    for k, ball in pairs(self.balls) do -- Update(I)
        if ball.inPlay then
        ball:update(dt)
        end
    end

    --KN start

    self.powerup:update(dt)

    if self.powerup:collide(self.paddle) then--Update(I)

       
        
        
        if self.powerup.powerindex == 1 then

            gSounds['recover']:play()
       

            self.balls[self.totalBalls+1] = Ball()
            self.balls[self.totalBalls+2] = Ball()
            self.balls[self.totalBalls+1].x = self.paddle.x + (self.paddle.width / 2) - 4
            self.balls[self.totalBalls+1].y = self.paddle.y - 16
            self.balls[self.totalBalls+2].x = self.paddle.x + (self.paddle.width / 2) - 4
            self.balls[self.totalBalls+2].y = self.paddle.y - 16
            self.balls[self.totalBalls+1].dx = math.random(100,200)
            self.balls[self.totalBalls+1].dy = -math.abs(self.currentdy)
            self.balls[self.totalBalls+2].dx = -self.balls[self.totalBalls+1].dx
            self.balls[self.totalBalls+2].dy = -math.abs(self.currentdy)
            self.balls[self.totalBalls+1].skin = self.balls[0].skin
            self.balls[self.totalBalls+2].skin = self.balls[0].skin
            

           
            self.totalBalls = self.totalBalls + 2
        else--Update(III)
            gSounds['unlock']:play()
            key = true
        end
        self.powerup:reload()
            
            
       
    elseif self.powerup.y > VIRTUAL_HEIGHT + 16 then

        self.powerup:reload()
       
    
    end


    for k, ball1 in pairs(self.balls) do --Update(I)
        for j, ball2 in pairs(self.balls) do
            if ball1:collides(ball2) and ball1 ~= ball2 and ball1.inPlay and ball2.inPlay then
                gSounds['paddle-hit']:play()
                if ball1.x + 2 < ball2.x and ball1.dx > 0 then

                    local dx = ball1.dx
                    ball1.dx = ball2.dx 
                    ball2.dx =  dx
                    ball1.x = ball1.x - 4
                    ball2.x = ball2.x + 4
                    
                elseif ball1.x + 2 > ball2.x + 8 and ball1.dx < 0 then

                    local dx = ball1.dx
                    ball1.dx = ball2.dx 
                    ball2.dx =  dx
                    ball1.x = ball1.x + 4
                    ball2.x = ball2.x - 4

                elseif ball1.y + 2 > ball2.y and ball1.dy > 0 then
                    
                    local dy = ball1.dy
                    ball1.dy = ball2.dy 
                    ball2.dy =  dy
                    ball1.y = ball1.y - 4
                    ball2.y = ball2.y + 4

                else
                    local dy = ball1.dy
                    ball1.dy = ball2.dy 
                    ball2.dy = dy
                    ball1.y = ball1.y + 4
                    ball2.y = ball2.y - 4
                end
            end
        end
    end




    for k, ball in pairs(self.balls) do--Update(I)
    if ball.inPlay and ball:collides(self.paddle) then
        -- raise ball above paddle in case it goes below it, then reverse dy
        ball.y = self.paddle.y - 8
        ball.dy = -ball.dy

        --
        -- tweak angle of bounce based on where it hits the paddle
        --

        -- if we hit the paddle on its left side while moving left...
        if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
        
        -- else if we hit the paddle on its right side while moving right...
        elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
            ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
        end

        gSounds['paddle-hit']:play()
    end
end
    if self.powerCounter > self.randomTime then -- Update(I)
        self.powerup.dx = math.random(1,2)--idk why it is so less
        self.powerup.dy = 2
        self.randomTime = self.randomTime + math.random(1,4)
        self.powerCounter = 0
    
    end
    
   
    


    -- detect collision across all bricks with the ball
    for j, ball in pairs(self.balls) do--Update(I)
    for k, brick in pairs(self.bricks) do

        -- only check collision if we're in play
        
        if brick.inPlay and ball:collides(brick) and ball.inPlay then

            -- add to score
            if brick.tier == 5  then -- Update(III)
                if key then
                self.score = self.score + 2000
                end
            else

            self.score = self.score + (brick.tier * 200 + brick.color * 25)
            end

            if self.score > self.paddlePoints then--Update(II)
                self.paddlePoints = self.paddlePoints + 7000
                if self.paddle.size ~= 4 then
                gSounds['paddle-inc']:play()
                self.paddle.width = self.paddle.width + 32
                self.paddle.size = self.paddle.size + 1
                end
                
                
                
            end


                
               
            -- trigger the brick's hit function, which removes it from play
            brick:hit()

            -- if we have enough points, recover a point of health
            if self.score > self.recoverPoints then
                -- can't go above 3 health
                self.health = math.min(3, self.health + 1)

                -- multiply recover points by 2
                self.recoverPoints = math.min(100000, self.recoverPoints*2)

                -- play recover sound effect
                gSounds['recover']:play()
            end

            -- go to our victory screen if there are no more bricks left
            if self:checkVictory() then
                keyLevel = math.random(2) == 1 and true or false
                key = false
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    balls = self.balls,
                    recoverPoints = self.recoverPoints,
                    paddlePoints = self.paddlePoints
                })
            end

            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
           
            if ball.x + 2 < brick.x and ball.dx > 0 then
                
                -- flip x velocity and reset position outside of brick
                ball.dx = -ball.dx
                ball.x = brick.x - 8
            
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                
                -- flip x velocity and reset position outside of brick
                ball.dx = -ball.dx
                ball.x = brick.x + 32
            
            -- top edge if no X collisions, always check
            elseif ball.y < brick.y then
                
                -- flip y velocity and reset position outside of brick
                ball.dy = -ball.dy
                ball.y = brick.y - 8
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of brick
                ball.dy = -ball.dy
                ball.y = brick.y + 16
            end

            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(ball.dy) < 150 then
                ball.dy = ball.dy * 1.02
                self.currentdy = ball.dy --Update(I)
               
            end

            -- only allow colliding with one brick, for corners
            break
        end
        
    end
end

        
    
            
        

    -- if ball goes below bounds, revert to serve state and decrease health
    for k, ball in pairs(self.balls) do--Update(I)
        if ball.inPlay and ball.y >= VIRTUAL_HEIGHT then
            ball.inPlay = false
            gSounds['hurt']:play()
        end
    end

        if self:checkBalls() then
            
            self.health = self.health - 1
            self.paddlePoints = self.score + 7000--Update(II)
            if self.paddle.size ~= 1 then
               self.paddle.size = self.paddle.size - 1
               self.paddle.width = self.paddle.width - 32
               
            end


        if self.health == 0 then
            keyLevel = math.random(2) == 1 and true or false
            key = false
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints,
                paddlePoints = self.paddlePoints
            })
        
        end
    end
        
            
    

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for k, ball in pairs(self.balls) do--Update(I)
        if ball.inPlay then
    ball:render()
    end
end
    self.powerup:render()--Update(I)

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
        
    end
    
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end
--Update(I):same as checkVictory()
function PlayState:checkBalls()
    for k, ball in pairs(self.balls) do
        if ball.inPlay then
            return false
        end 
    end

    return true
end
    