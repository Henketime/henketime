-- PIXELFALLS Snake
-- Adapted from the Snake source by Erik Yuzwa (MIT License)

version = "0.4"

-- Board settings
screen_size = 128
tile_num = 32
tile_size = screen_size / tile_num

-- Palette color indices
background_color = 1
head_color = 10
body_color = 3
fruit_color = 8
ui_text_color = 10
version_text_color = 7

-- Game state
x = {}
y = {}
x_dir = 1
y_dir = 0
score = 0
fruit = { x = 0, y = 0, color = fruit_color }
game_over = false

-- Set up the initial snake directly in the main file.
x[1] = tile_size * (tile_num / 4)
y[1] = tile_size * (tile_num / 2)

for i = 2, 7 do
  x[i] = x[i - 1] - tile_size
  y[i] = y[1]
end

function update_fruit()
  fruit.x = math.random(0, tile_num - 1) * tile_size
  fruit.y = math.random(0, tile_num - 1) * tile_size
end

update_fruit()

function draw()
  clearScreen(background_color)
  draw_snake()
  draw_fruit()
  draw_score()
  drawText("V" .. version, 100, 1, version_text_color, 1)

  if game_over then
    drawText("GAME OVER", 40, 56, fruit_color, 1)
  end
end

function draw_fruit()
  drawFillRect(
    fruit.x,
    fruit.y,
    fruit.x + tile_size - 1,
    fruit.y + tile_size - 1,
    fruit.color
  )
end

function draw_score()
  drawText("SCORE: " .. score, 1, 1, ui_text_color, 1)
end

function draw_snake()
  drawFillRect(
    x[1],
    y[1],
    x[1] + tile_size - 1,
    y[1] + tile_size - 1,
    head_color
  )

  for i = 2, #x do
    drawFillRect(
      x[i],
      y[i],
      x[i] + tile_size - 1,
      y[i] + tile_size - 1,
      body_color
    )
  end
end

function update()
  if game_over then
    return
  end

  update_input()

  if is_wall_collision() then
    game_over = true
    return
  end

  if is_fruit_collision() then
    score = score + 10

    for i = #x + 1, 2, -1 do
      x[i] = x[i - 1]
      y[i] = y[i - 1]
    end

    x[1] = fruit.x
    y[1] = fruit.y
    update_fruit()
  else
    update_snake()
  end
end

function update_input()
  -- Do not allow an immediate 180-degree turn into the snake.
  if buttonPressed(BTN_LEFT) and x_dir ~= 1 then
    x_dir = -1
    y_dir = 0
  elseif buttonPressed(BTN_RIGHT) and x_dir ~= -1 then
    x_dir = 1
    y_dir = 0
  elseif buttonPressed(BTN_UP) and y_dir ~= 1 then
    x_dir = 0
    y_dir = -1
  elseif buttonPressed(BTN_DOWN) and y_dir ~= -1 then
    x_dir = 0
    y_dir = 1
  end
end

function update_snake()
  local previous_x = x[1]
  local previous_y = y[1]

  x[1] = x[1] + x_dir * tile_size
  y[1] = y[1] + y_dir * tile_size

  for i = 2, #x do
    local segment_x = x[i]
    local segment_y = y[i]

    x[i] = previous_x
    y[i] = previous_y

    previous_x = segment_x
    previous_y = segment_y
  end
end

function is_fruit_collision()
  return x[1] + x_dir * tile_size == fruit.x
    and y[1] + y_dir * tile_size == fruit.y
end

function is_wall_collision()
  local next_x = x[1] + x_dir * tile_size
  local next_y = y[1] + y_dir * tile_size

  return next_x < 0 or next_x >= screen_size
    or next_y < 0 or next_y >= screen_size
end