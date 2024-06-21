

-- Initialisation function, set up the global variables 
function love.load()
    mousex, mousey = love.mouse.getPosition()

    puck_width = 100
    puck_height = 10 
    puck_space = 20 -- space of the puck from the bottom of the screen
   
    ball = {}
    ball.y = love.graphics.getHeight() / 2
    ball.x = love.graphics.getWidth() / 2
    ball.x_velocity = 200
    ball.y_velocity = 200
    ball.radius = 15

    screenheight = love.graphics.getHeight()

    bricks = {}
   
    brick_width  = 100
    brick_height = 10 
    brick_space  = 50 
    brick_number = 5

    math.randomseed(os.time())

    inGame = false 
end

function addNewBricks() 
    local brick_offset_x = 20 
    local brick_offset_y = 20 

    local current_brick_offset_y = brick_offset_y 
    for i = 1,5,1 do 
        addBrickRow( current_brick_offset_y, brick_offset_x )
        current_brick_offset_y = current_brick_offset_y + 50 
    end


end


function addBrickRow( el_brick_offset_y, el_brick_offset_x )
    local brick_top_left_x = el_brick_offset_x
    local brick_top_left_y = el_brick_offset_y

    local red    = math.random()
    local green  = math.random()
    local blue   = math.random()
  
    nextRectangle = {}
   
    for i=1,brick_number do 
        nextRectangle = {}
        nextRectangle.x = brick_top_left_x
        nextRectangle.y = brick_top_left_y

        nextRectangle.red   = red
        nextRectangle.green = green
        nextRectangle.blue  = blue

        nextRectangle.keep = true

        brick_top_left_x = brick_top_left_x + brick_width + brick_space

        table.insert( bricks, nextRectangle )
    end
end

function drawBall() 
    love.graphics.setColor(0.8, 0.0, 0.0)
    love.graphics.circle( "fill", ball.x, ball.y, ball.radius ) 
end 

function drawBricks()
    for i,v in ipairs(bricks) do 
        love.graphics.setColor( v.red, v.green, v.blue )
        love.graphics.rectangle( "fill", v.x, v.y, brick_width, brick_height )
    end
end

function collideBallAndPuck() 
    puck_top_left_corner_x  = mousex - ( puck_width * 0.5 )
    puck_top_right_corner_x = mousex + ( puck_width * 0.5 )
    puck_top_y = love.graphics.getHeight() - puck_space - puck_height

    x_dist = 0 

    if ( ball.x < puck_top_left_corner_x ) then 
        x_dist = puck_top_left_corner_x - ball.x
    end

    if ( ball.x > puck_top_right_corner_x ) then
        x_dist = ball.x - puck_top_right_corner_x
    end

    y_dist = puck_top_y - ball.y

    local x_puck_constant = 10

    if ( x_dist * x_dist + y_dist * y_dist ) < ball.radius then 
        ball.y_velocity = 0 - ball.y_velocity   
        ball.x_velocity = ball.x_velocity + ( ball.x - mousex )  * x_puck_constant 
        
        -- Constrain the x velocity 
        if ( ball.x_velocity > 300 ) then 
            ball.x_velocity = 300 
        end

        if ( ball.x_velocity < 300 ) then 
            ball.x_velocity = -300 
        end
    end

   
end

function collideBallAndBricks()
    
    local foundCollision = false
    
    for i,v in ipairs(bricks) do 
        local brick_x = v.x
        local brick_y = v.y 

        local x_dist = 0 
        if ( ball.x < brick_x ) then 
            x_dist = brick_x - ball.x 
        end

        if ( ball.x > ( brick_x + brick_width ) ) then 
            x_dist = ball.x - ( brick_x + brick_width ) 
        end

        local y_dist = 0 
        if ( ball.y < brick_y ) then 
            y_dist = brick_y - ball.y  
        end

        if ( ball.y > brick_y + brick_height ) then 
            y_dist = ball.y - ( brick_y + brick_height )
        end

        if ( x_dist * x_dist + y_dist * y_dist ) < ball.radius then 
            foundCollision = true
            v.keep = false 
            ball.y_velocity = 0 - ball.y_velocity  
                   
        end
    end

    if foundCollision then
        newBrickList = {} 
        
        for i,v in ipairs(bricks) do 
            if ( v.keep ) then 
                table.insert( newBrickList, v ) 
            end 
        end
    
        bricks = newBrickList     
    end
end

function collideBallAndSidesAndTop()

    -- check collision with top of screen
    if ( ( ball.y - ball.radius < 0 ) ) then
        ball.y_velocity = 0 - ball.y_velocity         
    end

    -- check collisions with sides 
    if  ( ( ball.x + ball.radius) > love.graphics.getWidth() ) or ( ( ( ball.x - ball.radius) < 0 ) ) then
        ball.x_velocity = 0 - ball.x_velocity     
    end

end

function collideBallAndEndOfScreen() 
    if ( ( ball.y + ball.radius ) > screenheight ) then
        endGame()
    end
end

function endGame()
    inGame = false
    bricks = {}

end

function updateBall(dt) 
    ball.x = ball.x + dt * ball.x_velocity
    ball.y = ball.y + dt * ball.y_velocity

    -- check collision with sides 
    collideBallAndPuck()
    collideBallAndBricks()
    collideBallAndSidesAndTop()
    collideBallAndEndOfScreen()
end

function drawFPS()
    -- Draw the current FPS.
    love.graphics.print("FPS: " .. love.timer.getFPS(), 50, 50 )
    -- Draw the current delta-time. (The same value
    -- is passed to update each frame).
    -- love.graphics.print("dt: " .. love.timer.getDelta(), 50, 100)
end

function  drawPuck()
    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.rectangle( "fill", mousex - ( puck_width * 0.5 ), love.graphics.getHeight() - puck_space , puck_width, puck_height )
end

function drawTitleScreen() 
    font = love.graphics.newFont(40)
    love.graphics.setFont(font)
    love.graphics.setColor( 0.8, 0.3, 0.3 )
    love.graphics.print( "LuArkanoid", 150, 150, 0, 1, 1)
    love.graphics.print( "Press q to quit", 150, 250, 0, 1, 1)
    love.graphics.print( "Any other key to begin", 150, 350, 0, 1, 1)
    
end

function love.keypressed(key, scancode, isrepeat) 
    if ( key == 'q' ) then 
        love.event.quit(0)
    end
    
    startGame()
 end


-- Draw function 
function love.draw()
    if ( inGame ) then 
        drawPuck()
        drawBall()
        drawBricks()
    else
        drawTitleScreen()
    end

    -- drawFPS()
end

function startGame() 
    ball.y = love.graphics.getHeight() / 2
    ball.x = love.graphics.getWidth() / 2
    ball.x_velocity = 200
    ball.y_velocity = 200

    addNewBricks()
    inGame = true 
end

function love.update(dt)
    if ( inGame ) then
        mousex, mousey = love.mouse.getPosition()
        updateBall(dt)
    end
end