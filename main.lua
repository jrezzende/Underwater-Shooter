function love.load()  
  
  submarine_image = love.graphics.newImage("resources/images/submarine.png")
  torpedo_image = love.graphics.newImage("resources/images/torpedo.png")
  squid_image = love.graphics.newImage("resources/images/squid.png")
  shark_image = love.grpahics.newImage("resources/images/shark.png")
  swordfish_image = love.graphics.newImage("resources/images/swordfish.png")

  torpedo_timer_max = 0.2
  torpedo_start_speed = 100
  torpedo_max_speed = 300
  
  squid_speed = 200
  shark_speed = 250
  swordfish_speed = 300
  charge_speed = 500
  
  spawn_timer_max
  
  startGame()
  
end

function love.draw()
  
  love.graphics.setColor(186, 255, 255)
  background = love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255)
  
  love.graphics.draw(player.img, player.x_pos, player.y_pos, 0, 2, 2)
  
  for index, torpedo in ipairs(torpedoes) do
    love.graphics.draw(torpedo.img, torpedo.x_pos, torpedo.y_pos)
  end
  
end

function love.update(dt)
  update_player(dt)
  update_torpedoes()
end

function update_player(dt)
  down = love.keyboard.isDown("down")
  up = love.keyboard.isDown("up")
  left = love.keyboard.isDown("left")
  right = love.keyboard.isDown("right")
  
  speed = player.speed
  if((down or up) and (left or right)) then
    speed = speed / math.sqrt(2)
  end

  if down and player.y_pos < love.graphics.getHeight() - player.height then
    player.y_pos = player.y_pos + dt * speed
  elseif up and player.y_pos > 0 then
    player.y_pos = player.y_pos - dt * speed
  end

  if right and player.x_pos < love.graphics.getWidth() - player.width then
    player.x_pos = player.x_pos + dt * speed
  elseif left and player.x_pos > 0 then
    player.x_pos = player.x_pos - dt * speed
  end

  if love.keyboard.isDown("space") then
    torpedo_speed = torpedo_start_speed
    if(left) then
      torpedo_speed = torpedo_speed - player.speed/2
    elseif(right) then
      torpedo_speed = torpedo_speed + player.speed/2
    end
    spawn_torpedo(player.x_pos + player.width, player.y_pos + player.height / 2, torpedo_speed)
  end

  if torpedo_timer > 0 then
    torpedo_timer = torpedo_timer - dt
  else
    can_fire = true
  end
end


function update_torpedoes(dt)
  for index, torpedo in ipairs(torpedoes) do
    torpedo.x_pos = torpedo.x_pos + dt * torpedo.speed
    if torpedo.speed < torpedo_max_speed then
      torpedo.speed = torpedo.speed + dt * 100
    end
    if torpedo.x_pos > love.graphics.getWidth() then
      table.remove(torpedoes, index)
    end
  end
end

function spawn_torpedo(x, y, speed)
  if can_fire then
    torpedo = { x_pos = x, y_pos = y, width = 16, height = 16, speed = speed, img = torpedo_image }
    table.insert(torpedoes, torpedo)
    
    can_fire = false
    torpedo_timer = torpedo_timer_max
  end
end