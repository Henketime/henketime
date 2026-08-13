-- snake game
-- copyright @eyuzwa
-- released under
-- mit license
--
-- note:
-- this source is split into
-- different tabs in the
-- pico8 editor
-- tab0: _init
-- tab1: _draw
-- tab2: _update


-- version
version = "0.1.0"

-- global variables
x = {}
y = {}
x_dir = 1
y_dir = 0
score = 0

-- color definitions
color_ui_text = 7
color_menu_text = 10
color_warning_text = 8
color_background = 1
color_snake_initial = 6
color_snake_initial = 9
color_fruit = 3

-- we are splitting up our 
-- screen into tiles
-- the larger the tile_num,
-- the larger the game area
tile_num = 32
tile_size = 128 / tile_num

-- track our fruit position
-- and color
fruit = {}
fruit.x = 0
fruit.y = 0
fruit.color = color_fruit


-- generate a random (x,y)
-- to place the fruit
function update_fruit()
  fruit.x = math.random(0, tile_num - 1) * tile_size
  fruit.y = math.random(0, tile_num - 1) * tile_size
end

-- initialize and setup game
-- generate snake head
-- starting position
-- todo: randomize it?
x[1] = tile_size * (tile_num / 4)
y[1] = tile_size * (tile_num / 2)

-- set starting snake tail
-- length
for i = 2, 7 do
  x[i] = x[i - 1] - tile_size
  y[i] = y[1]
end

-- generate fruit
update_fruit()

-->8
-- main draw method called
-- by pico8
-- clear the screen and draw
-- everything
function draw()
  if x[1] == nil or y[1] == nil then
    drawText("SNAKE NOT INITIALIZED", 8, 8, 8, 1)
    return
  end
  clearScreen(1)
  draw_snake()
  draw_fruit()
  draw_score()
  
  -- draw version
  drawText("v" ..version, 100, 1, color_ui_text)
end

-- draw fruit
function draw_fruit()
  drawRect(fruit.x, fruit.y, fruit.x + tile_size - 1, fruit.y + tile_size - 1, fruit.color)
end

-- draw score
function draw_score()
  drawText("score: " .. score, 1, 1, color_menu_text)
end

-- draw snake
function draw_snake()
  -- draw snake head

  drawRect(x[1], y[1], x[1] + tile_size - 1, y[1] + tile_size - 1, color_snake_initial)
    
  -- draw snake segments
  for i=2, #x do
    drawRect(x[i], y[i], x[i] + tile_size - 1, y[i] + tile_size - 1, color_snake_segment)
  end
end

-->8
-- main update function
-- called by pico8
-- updated at 30fps
-- todo: look at _update60
function update()
  -- check for wall collision
  if(is_wall_collision()) then
    return
  end

  -- capture input
  update_input()
  
  -- check for collision
  -- with fruit
  local collide = false
  collide = is_fruit_collision()
  if(collide)then
    -- increment score
    score=score + 10
    
    -- push new snake segment
    -- using the position of
    -- the fruit
    for i = #x + 1, 2, -1 do
      x[i] = x[i-1]
      y[i] = y[i-1]
    end
    
    x[1] = fruit.x
    y[1] = fruit.y
    
    -- generate a new fruit
    update_fruit()
  else
    update_snake()
  end
end

function update_input()
  if buttonDown(BTN_LEFT) then
    x_dir = -1
    y_dir = 0

  elseif buttonDown(BTN_RIGHT) then
    x_dir = 1
    y_dir = 0

  elseif buttonDown(BTN_UP) then
    x_dir = 0
    y_dir = -1

  elseif buttonDown(BTN_DOWN) then
    x_dir = 0
    y_dir = 1
  end
end

function update_snake()
  -- local temp variables
  local temp1x = x[1]
  local temp1y = y[1]
  local temp2x, temp2y
  
  -- update snake head segment
  x[1] += (x_dir * tile_size)
  y[1] += (y_dir * tile_size)
  
  -- update snake tail segments
  for i = 2, #x do
    temp2x = x[i]
    temp2y = y[i]
    
    x[i] = temp1x
    y[i] = temp1y
    
    temp1x = temp2x
    temp1y = temp2y
  end
end

function is_fruit_collision()
  if(x[1] + (x_dir * tile_size) == fruit.x and y[1] + (y_dir * tile_size) == fruit.y) then
    return true
  end
  return false
end

function is_wall_collision()
  return x[1] < 0 or x[1] >= 128
      or y[1] < 0 or y[1] >= 128
end