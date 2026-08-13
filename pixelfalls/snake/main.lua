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
snake = {
  x = {},
  y = {},
  x_dir = 1,
  y_dir = 0
}
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
snake.x[1] = tile_size * (tile_num / 4)
snake.y[1] = tile_size * (tile_num / 2)

-- set starting snake tail
-- length
for i = 2, 7 do
  snake.x[i] = snake.x[i - 1] - tile_size
  snake.y[i] = snake.y[1]
end

-- generate fruit
update_fruit()

-->8
-- main draw method called
-- by pico8
-- clear the screen and draw
-- everything
function draw()
  if snake.x[1] == nil or snake.y[1] == nil then
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

  drawRect(snake.x[1], snake.y[1], snake.x[1] + tile_size - 1, snake.y[1] + tile_size - 1, color_snake_initial)
    
  -- draw snake segments
  for i=2, #snake.x do
    drawRect(snake.x[i], snake.y[i], snake.x[i] + tile_size - 1, snake.y[i] + tile_size - 1, color_snake_segment)
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
    for i = #snake.x + 1, 2, -1 do
      snake.x[i] = snake.x[i-1]
      snake.y[i] = snake.y[i-1]
    end

    snake.x[1] = fruit.x
    snake.y[1] = fruit.y
    
    -- generate a new fruit
    update_fruit()
  else
    update_snake()
  end
end

function update_input()
  if buttonDown(BTN_LEFT) then
    snake.x_dir = -1
    snake.y_dir = 0

  elseif buttonDown(BTN_RIGHT) then
    snake.x_dir = 1
    snake.y_dir = 0

  elseif buttonDown(BTN_UP) then
    snake.x_dir = 0
    snake.y_dir = -1

  elseif buttonDown(BTN_DOWN) then
    snake.x_dir = 0
    snake.y_dir = 1
  end
end

function update_snake()
  -- local temp variables
  local temp1x = snake.x[1]
  local temp1y = snake.y[1]
  local temp2x, temp2y
  
  -- update snake head segment
  snake.x[1] += (snake.x_dir * tile_size)
  snake.y[1] += (snake.y_dir * tile_size)
  
  -- update snake tail segments
  for i = 2, #snake.x do
    temp2x = snake.x[i]
    temp2y = snake.y[i]

    snake.x[i] = temp1x
    snake.y[i] = temp1y

    temp1x = temp2x
    temp1y = temp2y
  end
end

function is_fruit_collision()
  if(snake.x[1] + (snake.x_dir * tile_size) == fruit.x and snake.y[1] + (snake.y_dir * tile_size) == fruit.y) then
    return true
  end
  return false
end

function is_wall_collision()
  return snake.x[1] < 0 or snake.x[1] >= 128
      or snake.y[1] < 0 or snake.y[1] >= 128
end