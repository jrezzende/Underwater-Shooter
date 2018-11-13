function love.load()
  submarine_image = love.graphics.newImage("resources/images/submarine.png")
  torpedo_image = love.graphics.newImage("resources/images/torpedo.png")
  squid_image = love.graphics.newImage("resources/images/squid.png")
  shark_image = love.graphics.newImage("resources/images/shark.png")
  swordfish_image = love.graphics.newImage("resources/images/swordfish.png")
  ground_image = love.graphics.newImage("resources/images/ground.png")
  background_image = love.graphics.newImage("resources/images/background.png")

  torpedo_timer_max = 0.2
  torpedo_start_speed = 100
  torpedo_max_speed = 300

  squid_speed = 200
  shark_speed = 250
  swordfish_speed = 300
  charge_speed = 500

  spawn_timer_max = 0.66 -- fator tempo de spawn

  music_track = love.audio.newSource("resources/audio/Mercury.wav", "static")
  music_track:setLooping(true)
  shoot_sfx = love.audio.newSource("resources/audio/Explosion.wav", "static")
  shoot_sfx:setVolume(0.5)
  enemy_destroy_sfx = love.audio.newSource("resources/audio/Shoot.wav", "static")
  player_destroy_sfx = love.audio.newSource("resources/audio/Lightening.wav", "static")

  -- particulas
  bubble = getBubble(50)
  smallCircle = getBubble(40)
  smallBlast = getBlast(50)
  blast = getBlast(100)

  startGame()
end

function startGame()
  player_alive = true
  player = {xPos = 0, yPos = 0, angle = 0, width = 64, height = 64, speed=200, img=submarine_image, pSystem=getBubbleTrail(bubble)}
  torpedoes = {}
  enemies = {}
  explosions = {}

  canFire = true
  torpedoTimer = torpedo_timer_max
  spawnTimer = 0
  restartTimer = 1

  backgroundPosition = 0
  groundPosition = 0

  music_track:play()
end

function love.draw()
  love.graphics.setColor(186, 255, 255)
  background = love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255)

  love.graphics.setColor(100, 200, 200, 200)
  love.graphics.draw(background_image, backgroundPosition, 380, 0, 2, 2)
  love.graphics.draw(background_image, backgroundPosition + 800, 380, 0, 2, 2)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(ground_image, groundPosition, 400, 0, 2, 2)
  love.graphics.draw(ground_image, groundPosition + 800, 400, 0, 2, 2)

  if player_alive then
    love.graphics.draw(player.img, player.xPos, player.yPos, player.angle, 2, 2)
    love.graphics.draw(player.pSystem, 0, 0)
  end

  for index, torpedo in ipairs(torpedoes) do
    love.graphics.draw(torpedo.img, torpedo.xPos, torpedo.yPos)
    love.graphics.draw(torpedo.pSystem, 0, 0)
  end

  for index, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.xPos, enemy.yPos, enemy.angle, 2, 2)
  end

  for index, explosion in ipairs(explosions) do
    love.graphics.draw(explosion, 0, 0)
  end
end

function love.update(dt)
  updatePlayer(dt)
  updateTorpedoes(dt)
  updateEnemies(dt)
  updateExplosions(dt)
  checkCollisions()

  if groundPosition > -800 then
    groundPosition = groundPosition - dt * 100
  else
    groundPosition = 0
  end
  if backgroundPosition > -800 then
    backgroundPosition = backgroundPosition - dt * 50
  else
    backgroundPosition = 0
  end

  if player_alive == false then
    if restartTimer > 0 then
      restartTimer = restartTimer - dt
    else
      startGame()
    end   
  end
end

function updatePlayer(dt)
  down = love.keyboard.isDown("down")
  up = love.keyboard.isDown("up")
  left = love.keyboard.isDown("left")
  right = love.keyboard.isDown("right")

  speed = player.speed
  if((down or up) and (left or right)) then
    speed = speed / math.sqrt(2)
  end

  if down and player.yPos<love.graphics.getHeight()-player.height then
    player.yPos = player.yPos + dt * speed
    player.angle = 0.1
  elseif up and player.yPos>0 then
    player.yPos = player.yPos - dt * speed
    player.angle = -0.1
  else
    player.angle = 0
  end

  if right and player.xPos<love.graphics.getWidth()-player.width then
    player.xPos = player.xPos + dt * speed
  elseif left and player.xPos>0 then
    player.xPos = player.xPos - dt * speed
  end

  if love.keyboard.isDown("space") then
    torpedoSpeed = torpedo_start_speed
    if(left) then
      torpedoSpeed = torpedoSpeed - player.speed/2
    elseif(right) then
      torpedoSpeed = torpedoSpeed + player.speed/2
    end
    spawnTorpedo(player.xPos + player.width, player.yPos + player.height/2, torpedoSpeed)
  end

  if torpedoTimer > 0 then
    torpedoTimer = torpedoTimer - dt
  else
    canFire = true
  end

  if(left) then
    player.pSystem:setEmissionRate(10)
  elseif(right) then
    player.pSystem:setEmissionRate(20)
  else
    player.pSystem:setEmissionRate(15)
  end

  player.pSystem:setPosition(player.xPos, player.yPos + player.height / 2)
  player.pSystem:update(dt)
end

function updateTorpedoes(dt)
  for i=table.getn(torpedoes), 1, -1 do
    torpedo = torpedoes[i]
    torpedo.xPos = torpedo.xPos + dt * torpedo.speed
    torpedo.pSystem:setPosition(torpedo.xPos, torpedo.yPos + torpedo.height / 2)
    torpedo.pSystem:update(dt)
    if torpedo.speed < torpedo_max_speed then
      torpedo.speed = torpedo.speed + dt * 100
    end
    if torpedo.xPos > love.graphics.getWidth() then
      table.remove(torpedoes, i)
    end
  end
end

function spawnTorpedo(x, y, speed)
  if canFire then
    torpedo = {xPos = x, yPos = y, width = 16, height=16, speed=speed, img = torpedo_image, pSystem = getBubbleTrail(smallCircle)}
    torpedo.pSystem:setEmissionRate(20)
    table.insert(torpedoes, torpedo)

    canFire = false
    torpedoTimer = torpedo_timer_max
    playSound(shoot_sfx)
  end
end

function updateEnemies(dt)
  if spawnTimer > 0 then
    spawnTimer = spawnTimer - dt
  else
    spawnEnemy()
  end

  for i=table.getn(enemies), 1, -1 do
    enemy=enemies[i]
    enemy.update = enemy:update(dt)
    if enemy.xPos < -enemy.width then
      table.remove(enemies, i)
    end
  end
end

function spawnEnemy()
  y = love.math.random(0, love.graphics.getHeight() - 64)
  enemyType = love.math.random(0, 2)
  if enemyType == 0 then
    enemy = Enemy:new{yPos = y, speed = squid_speed, img = squid_image, update=moveLeft}
  elseif enemyType == 1 then
    enemy = Enemy:new{yPos = y, speed = shark_speed, img = shark_image, update=moveToPlayer}
  else
    enemy = Enemy:new{yPos = y, speed = swordfish_speed, img = swordfish_image, update=chargePlayer}
  end
  table.insert(enemies, enemy)

  spawnTimer = spawn_timer_max
end

Enemy = {xPos = love.graphics.getWidth(), yPos = 0, width = 64, height = 64, angle = 0}

function Enemy:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function moveLeft(obj, dt)
  obj.xPos = obj.xPos - obj.speed * dt
  return moveLeft
end

function moveToPlayer(obj, dt)
  xSpeed = math.sin(math.rad (60)) * obj.speed
  ySpeed = math.cos(math.rad (60)) * obj.speed
  if (obj.yPos - player.yPos) > 10 then
    obj.yPos = obj.yPos - ySpeed * dt
    obj.xPos = obj.xPos - xSpeed * dt
    obj.angle = 0.1
  elseif (obj.yPos - player.yPos) < -10 then
    obj.yPos = obj.yPos + ySpeed * dt
    obj.xPos = obj.xPos - xSpeed * dt
    obj.angle = -0.1
  else
    obj.xPos = obj.xPos - obj.speed * dt
    obj.angle = 0
  end
  return moveToPlayer
end

function chargePlayer(obj, dt)
  xDistance = math.abs(obj.xPos - player.xPos)
  yDistance = math.abs(obj.yPos - player.yPos)
  distance = math.sqrt(yDistance^2 + xDistance^2)
  if distance < 150 then
    obj.speed = charge_speed
    obj.angle = 0
    return moveLeft
  end 
  moveToPlayer(obj, dt)
  return chargePlayer
end

function checkCollisions()
  for index, enemy in ipairs(enemies) do
    if player_alive and (intersects(player, enemy) or intersects(enemy, player)) then
      local explosion = getExplosion(blast)
      explosion:setPosition(enemy.xPos + enemy.width/2, enemy.yPos + enemy.height/2)
      explosion:emit(20)
      table.insert(explosions, explosion)
      player_alive = false
      music_track:stop()
      playSound(player_destroy_sfx)
      break
    end

    for index2, torpedo in ipairs(torpedoes) do
      if intersects(enemy, torpedo) then
        local explosion = getExplosion(smallBlast)
        explosion:setPosition(enemy.xPos + enemy.width/2, enemy.yPos + enemy.height/2)
        explosion:emit(10)

        table.insert(explosions, explosion)
        table.remove(enemies, index)
        table.remove(torpedoes, index2)
        playSound(enemy_destroy_sfx)
        break
      end
    end
  end
end

function intersects(rect1, rect2)
  if rect1.xPos < rect2.xPos and rect1.xPos + rect1.width > rect2.xPos and
     rect1.yPos < rect2.yPos and rect1.yPos + rect1.height > rect2.yPos then
    return true
  else
    return false
  end
end

function getBubble(size)
  local bubble = love.graphics.newCanvas(size, size)
  love.graphics.setCanvas(bubble)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.ellipse("fill", size/2, size/2, size/2, size/4)
  love.graphics.setCanvas()
  return bubble
end

function getBlast(size)
  local blast = love.graphics.newCanvas(size, size)
  love.graphics.setCanvas(blast)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.circle("fill", size/2, size/2, size/2)
  love.graphics.setCanvas()
  return blast
end

function getBubbleTrail(image)
  pSystem = love.graphics.newParticleSystem(image, 50)
  pSystem:setParticleLifetime(1, 1)
  pSystem:setSpeed(-50)
	pSystem:setColors(255, 255, 255, 200, 255, 255, 255, 100, 255, 255, 255, 0)
  pSystem:setSizes(0.2, 0.8)
  return pSystem
end

function getExplosion(image)
  pSystem = love.graphics.newParticleSystem(image, 30)
  pSystem:setParticleLifetime(0.5, 0.5)
  pSystem:setLinearAcceleration(-100, -100, 100, 100)
	pSystem:setColors(255, 255, 0, 255, 255, 153, 51, 255, 64, 64, 64, 0)
  pSystem:setSizes(0.5, 0.5)
  return pSystem
end

function updateExplosions(dt)
  for i = table.getn(explosions), 1, -1 do
    local explosion = explosions[i]
    explosion:update(dt)
    if explosion:getCount() == 0 then
      table.remove(explosions, i)
    end
  end
end

function playSound(sound)
  sound:rewind(sound)
  pitch_mod = 0.8 + love.math.random(0, 10) / 25
  sound:setPitch(pitch_mod)
  sound:play()
end
