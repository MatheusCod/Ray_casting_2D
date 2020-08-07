function love.load()

  -- Window
  windowWidth = 800
  windowHeight = 600
  love.window.setMode(windowWidth, windowHeight)
  love.window.setTitle("Ray casting")

  -- Area
  divisor = 100
  walls = {}
  sizeX = windowWidth/divisor
  sizeY = windowHeight/divisor
  numberWalls = sizeX * sizeY
  for i=1,sizeY do
    walls[i] = {}
    for j=1,sizeX do
      walls[i][j] = 0
    end
  end

  time_var = 0

  --[[
  walls = {
    {1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1},
  }
  ]]--

  walls = {
    {0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 1, 0, 0, 1, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0},
  }

  -- Fill the side walls
  --[[
  for i=1,sizeX do
    walls[1][i] = 1
    walls[sizeY][i] = 1
  end

  for i=2,sizeY-1 do
    walls[i][1] = 1
    walls[i][sizeX] = 1
  end
  ]]--

  -- Print the area
  for i=1,sizeY do
    for j=1,sizeX do
      io.write(walls[i][j] .. " ")
    end
    print()
  end

  light_simulation = false
  background_color = 0.8

  -- Player
  player = {}
  player.x = divisor*5 - divisor/2
  player.y = divisor*3 - divisor/2
  player.size = 10
  speed = 200
  speed = 200
  forward_speed = speed
  backward_speed = speed

  -- Point
  point = {}
  point.x = player.x
  point.y = player.y - player.size * 100
  point.angle = 0
  point.var = 2.5

  -- Rays
  rays = {}
  numberRays = 200
  rays_length = player.size + 1000
  rays_var = math.pi/5
  rays_angle_var = (2*rays_var) / numberRays
  rays_color_red = 0.5
  rays_color_green = 0.5
  rays_color_blue = 0
  for i=1,numberRays do
    rays[i] = {}
    rays[i].var = -rays_var + (rays_angle_var * i)
    rays[i].x = player.x + (rays_length) * math.cos(point.angle - rays[i].var)
    rays[i].y = player.y + (rays_length) * math.sin(point.angle - rays[i].var)
  end

end

function love.update(dt)

  time_var = time_var + dt
  if (time_var >= 5) then
    time_var = 0
  end

  -- Create or erase a wall by the click of the mouse

  -- Reset the area
  if (love.keyboard.isDown("r")) then
    for i=1,sizeY do
      for j=1,sizeX do
        walls[i][j] = 0
      end
    end
  end

  -- Print the fps
  --print(tostring(1/dt))

  -- Player collision
  forward_speed = speed
  backward_speed = speed
  for i=1,sizeY do
    for j=1,sizeX do
      if (walls[i][j] == 1) then
        -- Player's front collision detection
        if (
          point.x > (divisor*j - divisor) and
          point.x < (divisor*j) and
          point.y > (divisor*i - divisor) and
          point.y < (divisor*i)
        ) then
          forward_speed = 0
        -- Player's back collision detection
        elseif (
          (
            player.x + player.size * math.cos(point.angle + math.pi) > (divisor*j - divisor) and
            player.x + player.size * math.cos(point.angle + math.pi) < (divisor*j) and
            player.y + player.size * math.sin(point.angle + math.pi) > (divisor*i - divisor) and
            player.y + player.size * math.sin(point.angle + math.pi) < (divisor*i)
          )
        ) then
          backward_speed = 0
        end
      end
    end
  end

  -- Player movement
  if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) then
    player.x = player.x + forward_speed * math.cos(point.angle) * dt
    player.y = player.y + forward_speed * math.sin(point.angle) * dt
  end
  if (love.keyboard.isDown("down") or love.keyboard.isDown("s")) then
    player.x = player.x - backward_speed * math.cos(point.angle) * dt
    player.y = player.y - backward_speed * math.sin(point.angle) * dt
  end

  --Point movement
  if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) then
    point.angle = point.angle + point.var * dt
    if (point.angle > 2 * math.pi) then
      point.angle = 0
    end
  elseif (love.keyboard.isDown("left") or love.keyboard.isDown("a")) then
    point.angle = point.angle - point.var * dt
    if (point.angle < 0) then
      point.angle = 2 * math.pi + point.angle
    end
  end

  -- Point
  point.x = player.x + player.size * math.cos(point.angle)
  point.y = player.y + player.size * math.sin(point.angle)

  -- Player position by mouse
  if (light_simulation) then
    player.x, player.y = love.mouse.getPosition()
    if (player.x <= 0 or player.y <= 0) then
      player.x = 50
      player.y = 50
    end
  end


  --[[
  =====================================
  =                       -           =
  =           3           -     4     =
  =                       -           =
  =-----------------------*-----------=
  =                       -           =
  =           2           -     1     =
  =                       -           =
  =====================================

  ]]--
  -- Rays
  for k=1,numberRays do

    local ray_angle = point.angle + rays[k].var

    -- ray_angle >= 360 or ray_angle <= 0
    if ray_angle >= 2*math.pi then
      ray_angle = ray_angle - 2*math.pi
    elseif ray_angle <= 0 then
      ray_angle = 2*math.pi + ray_angle
    end

    -- Compute the limits of the area that the ray belongs to
    local bottom_I, bottom_J, limit_I, limit_J
    bottom_I = 1
    bottom_J = 1
    limit_I = sizeY
    limit_J = sizeX

    -- Computes ray's line
    rays[k].x = player.x + (rays_length) * math.cos(ray_angle)
    rays[k].y = player.y + (rays_length) * math.sin(ray_angle)

    -- Compute which area the ray belongs to
    if (ray_angle >= 0 and ray_angle < math.pi/2) then
      bottom_I = math.ceil(player.y / divisor)
      bottom_J = math.ceil(player.x / divisor)
      limit_I = sizeY
      limit_J = sizeX
    elseif (ray_angle >= math.pi/2 and ray_angle < math.pi) then
      bottom_I = math.ceil(player.y / divisor)
      bottom_J = 1
      limit_I = sizeY
      limit_J = math.ceil(player.x / divisor)
    elseif (ray_angle >= math.pi and ray_angle < 3*math.pi/2) then
      bottom_I = 1
      bottom_J = 1
      limit_I = math.ceil(player.y / divisor)
      limit_J = math.ceil(player.x / divisor)
    elseif (ray_angle >= 3*math.pi/2 and ray_angle <= 2*math.pi) then
      bottom_I = 1
      bottom_J = math.ceil(player.x / divisor)
      limit_I = math.ceil(player.y / divisor)
      limit_J = sizeX
    end

    -- Compute the closes ray-wall collision based on the ray's line equation
    -- and the grid area.
    local short_distance = math.sqrt(windowHeight^2 + windowWidth^2)
    local tangent = math.tan(ray_angle)

    --[[
      For every wall, the algorithm computes the closest wall that a ray
      collides with.

      The collision is computed by using the ray's line formulas to see if that
      line crosses any of the wall sides. If it does, it computes the closest
      collision within the wall and between all the walls. The last is compute
      by using the shor_distance variable defined locally above.

    ]]--
    for i=bottom_I,limit_I do
      for j=bottom_J,limit_J do
        if (walls[i][j] == 1) then

          --[[

          Wall:
            |------ divisor -----|
            x1                   x2
            ----------------------
         y1 -                    -
            -                    -
            -                    -
            -                    -
            -                    -
            -                    -
         y2 ----------------------

          ]]--
          local x1 = divisor*j - divisor
          local x2 = divisor*j
          local y1 = divisor*i - divisor
          local y2 = divisor*i

          --[[ Line formulas:
                y = Tg(angle)*(X - Xo) + Yo
                x = ((Y - Yo)/Tg(angle)) + Xo
          ]]--

          -- X1
          local y_X1 = tangent*(x1 - player.x) + player.y
          if (
            y_X1 >= y1 and y_X1 <= y2
          ) then
            local wall_distance = math.sqrt((x1-player.x)^2 + (y_X1-player.y)^2)
            if ((wall_distance < short_distance) and (wall_distance <= rays_length)) then
              short_distance = math.sqrt((x1-player.x)^2 + (y_X1-player.y)^2)
              rays[k].x = x1
              rays[k].y = y_X1
            end
          end

          -- X2
          local y_X2 = tangent*(x2 - player.x) + player.y
          if (
            y_X2 >= y1 and y_X2 <= y2
          ) then
            local wall_distance = math.sqrt((x2-player.x)^2 + (y_X2-player.y)^2)
            if ((wall_distance < short_distance) and (wall_distance <= rays_length)) then
              short_distance = math.sqrt((x2-player.x)^2 + (y_X2-player.y)^2)
              rays[k].x = x2
              rays[k].y = y_X2
            end
          end

          -- Y1
          local x_Y1 = ((y1 - player.y)/tangent) + player.x
          if (
            x_Y1 >= x1 and x_Y1 <= x2
          ) then
            local wall_distance = math.sqrt((x_Y1-player.x)^2 + (y1-player.y)^2)
            if ((wall_distance < short_distance) and (wall_distance <= rays_length)) then
              short_distance = math.sqrt((x_Y1-player.x)^2 + (y1-player.y)^2)
              rays[k].x = x_Y1
              rays[k].y = y1
            end
          end

          -- Y2
          local x_Y2 = ((y2 - player.y)/tangent) + player.x
          if (
            x_Y2 >= x1 and x_Y2 <= x2
          ) then
            local wall_distance = math.sqrt((x_Y2-player.x)^2 + (y2-player.y)^2)
            if ((wall_distance < short_distance) and (wall_distance <= rays_length)) then
              short_distance = math.sqrt((x_Y2-player.x)^2 + (y2-player.y)^2)
              rays[k].x = x_Y2
              rays[k].y = y2
            end
          end

        end
      end
    end

  end

end

function love.draw()

  -- Background
  love.graphics.setBackgroundColor(background_color, background_color, background_color)
  --love.graphics.setBackgroundColor(0, 0, 0)

 -- Walls
  love.graphics.setColor(0, 0, 0)
  --love.graphics.setColor(0, 0, 0)
  for i=1,sizeY do
    for j=1,sizeX do
      if (walls[i][j] == 1) then
        love.graphics.rectangle("fill", (divisor*j - divisor), (divisor*i - divisor), divisor, divisor)
      end
    end
  end

  -- Background lines
  love.graphics.setColor(0, 0, 0)
  for i=1,windowWidth,divisor do
    love.graphics.line(i, 0, i, windowHeight)
  end
  for i=1,windowHeight,divisor do
    love.graphics.line(0, i, windowWidth, i)
  end

  -- Player
  love.graphics.setColor(0.8, 0, 0)
  love.graphics.circle("fill", player.x, player.y, player.size)

  -- Point
  love.graphics.setColor(0, 0, 0.8)
  love.graphics.circle("fill", point.x, point.y, 5)

  -- Rays
  love.graphics.setColor(rays_color_red, rays_color_green, rays_color_blue)
  --love.graphics.setColor(1, 1, 1)
  for i=1,numberRays do
    love.graphics.line(rays[i].x, rays[i].y, player.x, player.y)
  end

end

-- Activate mouse_control/light_simulation
function love.keypressed(key, scancode, isrepeat)
  if (key == "tab") then
    if (light_simulation == false) then
      light_simulation = true
      background_color = 0
      rays = newRays(1)
    else
      light_simulation = false
      background_color = 0.8
      rays = newRays(0)
    end
  end
end

-- Creates new set of rays
function newRays(mode)
  if (mode == 0) then
    new_rays = {}
    numberRays = 200
    rays_length = player.size + 1000
    rays_var = math.pi/5
    rays_angle_var = (2*rays_var) / numberRays
    rays_color_red = 0.5
    rays_color_green = 0.5
    rays_color_blue = 0
    for i=1,numberRays do
      new_rays[i] = {}
      new_rays[i].var = -rays_var + (rays_angle_var * i)
      new_rays[i].x = player.x + (rays_length) * math.cos(point.angle - new_rays[i].var)
      new_rays[i].y = player.y + (rays_length) * math.sin(point.angle - new_rays[i].var)
    end
  else
    new_rays = {}
    numberRays = 500
    rays_length = player.size + 1000
    rays_var = math.pi
    rays_angle_var = (2*rays_var) / numberRays
    rays_color_red = 1
    rays_color_green = 1
    rays_color_blue = 1
    for i=1,numberRays do
      new_rays[i] = {}
      new_rays[i].var = -rays_var + (rays_angle_var * i)
      new_rays[i].x = player.x + (rays_length) * math.cos(point.angle - new_rays[i].var)
      new_rays[i].y = player.y + (rays_length) * math.sin(point.angle - new_rays[i].var)
    end
  end

  return new_rays

end


-- Create or erase a wall by the click of the mouse
function love.mousepressed(x, y, button, istouch, presses)
  local newWall_Y = math.ceil(y/divisor)
  local newWall_X = math.ceil(x/divisor)
  if (button == 1) then
    if (walls[newWall_Y][newWall_X] == 1) then
      walls[newWall_Y][newWall_X] = 0
    elseif (walls[newWall_Y][newWall_X] == 0) then
      walls[newWall_Y][newWall_X] = 1
    end
  end
end
