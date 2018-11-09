function love.load()
  x_pos = 0
  y_pos = 0
  player_width = 64
  player_height = 64
  player_speed = 200
  submarine_icon = love.graphics.newImage("resources/images/submarine.png")
end

function love.draw()
  love.graphics.draw(submarine_icon, x_pos, y_pos, 0, 2, 2)
end

function love.update(dt)
  down_up = love.keyboard.isDown("down") or love.keyboard.isDown("up")
  left_right = love.keyboard.isDown("left") or love.keyboard.isDown("right")
  
  speed = player_speed
  if(down_up and left_right) then
    speed = speed / math.sqrt(2)
  end
  
  if love.keyboard.isDown("down") and y_pos < love.graphics.getHeight()-player_height then
    y_pos = y_pos + dt * speed
  elseif love.keyboard.isDown("up") and y_pos > 0 then
    y_pos = y_pos - dt * speed
  end
  
  if love.keyboard.isDown("right") and x_pos < love.graphics.getWidth() - player_width then
    x_pos = x_pos + dt * speed
  elseif love.keyboard.isDown("left") and x_pos < 0 then
    x_pos = x_pos - dt * speed
  end
end

