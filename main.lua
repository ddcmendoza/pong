-- AI will be Player 1

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

GOAL = 10 --change as needed

PADDLE_SPEED = 200
Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

function love.load()
    math.randomseed(os.time())
    love.window.setTitle("P O N G Remaster")
    love.graphics.setDefaultFilter('nearest','nearest')

    smallFont = love.graphics.newFont('font.ttf', 8)
    victoryFont = love.graphics.newFont('font.ttf', 24)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
        ['win'] = love.audio.newSource('win.wav', 'static'),
    }
        push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        vsync = true,
        resizable = true
    })
    player1score = 0
    player2score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2
    winninPlayer  = 0 

    paddle1 = Paddle(5, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5 , 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 3, VIRTUAL_HEIGHT / 2 - 3, 6, 6)
    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end
    
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 40

    
    gameState = "start"
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    
    if ball.x <= 0 then
        
        player2score = player2score + 1
        servingPlayer = 1
        ball:reset()
        ball.dx = 100
        if player2score >= GOAL then
            sounds['win']:play()
            gameState = 'victory'
            winningPlayer = 2
        else
            sounds['point_scored']:play()
            gameState = 'serve'
        end
    end
    if ball.x >= VIRTUAL_WIDTH - 6 then
        
        player1score = player1score + 1
        servingPlayer = 2
        ball:reset()
        ball.dx = -100
        if player1score >= GOAL then
            sounds['win']:play()
            gameState = 'victory'
            winningPlayer = 1
        else
            sounds['point_scored']:play()
            gameState = 'serve'
        end
    end

    if ball:collides(paddle1) then
        ball.dx = -ball.dx * 1.03
        ball.x = paddle1.x + 6

        sounds['paddle_hit']:play()
    end

    if ball:collides(paddle2) then
        ball.dx = -ball.dx * 1.03
        ball.x = paddle2.x - 5
        sounds['paddle_hit']:play()
    end

    if ball.y <= 0 then
        ball.dy = -ball.dy * .97
        ball.y = 0
        sounds['wall_hit']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - 6 then
        ball.dy = -ball.dy * .97
        ball.y = VIRTUAL_HEIGHT- 6
        sounds['wall_hit']:play()
    end

    paddle1:update(dt)
    paddle2:update(dt)

    --[[ if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end ]]
    if (ball.x < VIRTUAL_WIDTH / 3) and ball.dx < 0 then
        if (ball.y + ball.height / 2) < (paddle1.y + paddle1.height/2) then
            paddle1.dy = -PADDLE_SPEED
        elseif ball.y> (paddle1.y + paddle1.height/2) then
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end
    end

    if love.keyboard.isDown('up') then
        paddle2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0
    end
    if gameState == 'play' then
        ball:update(dt)
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == "enter" or key == "return" then
        if gameState == 'start' then
            gameState = 'play'
        elseif gameState == "serve" then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
            player2score = 0
            player1score = 0
        end
    end
end

function love.draw()
    push:apply('start')
    
    love.graphics.clear( 40 / 255, 45 / 255, 52 / 255, 255 / 255)
    
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press ENTER to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Player ".. tostring(servingPlayer).."'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press ENTER to Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player ".. tostring(winningPlayer).." wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press ENTER to play again!", 0, 42, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
    end
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    paddle1:render()
    paddle2:render()
    ball:render()
    
    displayFPS()

    
    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: '..tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1,1,1,1)
end