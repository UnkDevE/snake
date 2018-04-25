function newFoodPlace()
    food.x = math.random(love.graphics.getWidth() - 20)
    food.y = math.random(love.graphics.getHeight() - 20)
end

function moveSnake()
    -- this is grusome
    oldpos = {}
    for k, v in pairs(snake) do
        if k == "x" then
            oldpos.x = v 
        elseif k == "y" then
            oldpos.y = v
        end
    end
    
    if snake.direction == direction.left then
        snake.x = (snake.x - snake.speed) % love.graphics.getWidth()
    elseif snake.direction == direction.right then
        snake.x = (snake.x + snake.speed) % love.graphics.getWidth()
    elseif snake.direction == direction.up then
        snake.y = (snake.y - snake.speed) % love.graphics.getHeight()
    elseif snake.direction == direction.down then
        snake.y = (snake.y + snake.speed) % love.graphics.getHeight()
    end
    
    if snake.ate then
        snake.ate = false

        -- create new tail with the new elem 
        tail = { oldpos }

        -- add old elems in correct order
        for i = 1, #snake.tail do
            -- lua not zero indx.
            tail[i + 1] = snake.tail[(snake.first + 1 + i) % #snake.tail]
        end

        -- replace old tail with new, replace pointers
        snake.tail = tail
        snake.first = 0
        snake.last = #snake.tail

    elseif #snake.tail ~= 0 then
        -- lua not zero indx.
        snake.tail[snake.last + 1] = oldpos
        
        -- iterate
        snake.first = snake.last
        snake.last = (snake.last - 1) % #snake.tail
    end
end

function love.load()
    snake = { 
        w = 5, 
        h = 5, 
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        
        score = 0,
        speed = 5,
        ate = false,
        direction = nil,
        tail = {}
    }
    
    direction = { left = 0, right = 1, up = 2, down = 3}
    gameOver = false

    food = { w = 20, h = 20 }
    newFoodPlace()

    -- using 0 indexing bc. moduluo
    -- used to create snake.tail into circular array
    snake.tail.last = #snake.tail
    snake.tail.first = 0
    
end

function love.draw()
    if gameOver then
        love.graphics.printf("GAME OVER", love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2 - 25, 100, "left")
        love.graphics.printf("SCORE WAS: "..snake.score, love.graphics.getWidth()/2 - 60, love.graphics.getHeight()/2, 150, "left")
    elseif snake.direction ~= nil then
        love.graphics.printf("SCORE: "..snake.score, 0, 0, 100, "left")
        love.graphics.rectangle("fill", snake.x, snake.y, snake.w, snake.h)
        for i, tail in ipairs(snake.tail) do
            love.graphics.rectangle("fill", tail.x, tail.y, snake.w, snake.h)
        end
        
        love.graphics.rectangle("fill", food.x, food.y, food.w, food.h)
    else
        love.graphics.printf("START", love.graphics.getWidth()/2 - 40, love.graphics.getHeight()/2 - 10, 100, "center")
    end
end


function isCollide(rect1, rect2)
    return (rect1.x < rect2.x + rect2.w) and 
    (rect1.x + rect1.w > rect2.x) and 
    (rect1.y < rect2.y + rect2.h) and 
    (rect1.h + rect1.y >rect2.y)
end

function love.update()
    if love.keyboard.isDown('w') then
        if snake.direction ~= direction.down or #snake.tail == nil then
            snake.direction  = direction.up
        end
    elseif love.keyboard.isDown('s') then
        if snake.direction ~= direction.up or #snake.tail == nil then
            snake.direction  = direction.down
        end
    elseif love.keyboard.isDown('a') then 
        if snake.direction ~= direction.right or #snake.tail == nil then
            snake.direction = direction.left
        end
    elseif love.keyboard.isDown('d') then
        if snake.direction ~= direction.left or #snake.tail == nil then
            snake.direction  = direction.right
        end
    end
    
    if isCollide(snake, food) then
        newFoodPlace()
        snake.ate = true
        snake.score = snake.score + 1
    end

    for i, tail in ipairs(snake.tail) do
        if isCollide(snake, { x = tail.x, y = tail.y, w = snake.w, h = snake.h }) then
           gameOver = true 
        end
    end

    moveSnake()
end