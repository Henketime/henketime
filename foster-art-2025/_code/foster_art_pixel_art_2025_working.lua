-- foster-art-2025 working code
-- This code is part of the Foster Art 2025 pixel art lesson
app = {}
gravity = 0.5

app.current_level = 1
app.max_levels = 1

app.current_player_set = 1
app.current_objective_set = 1
app.current_sprite_set = 1

player_sets = {
 {
  name = "mr henke",
  frames = {2, 3},
  timer = 0,
  sprite = 2
 },
 {
  name = "june",
  frames = {4, 5},
  timer = 0,
  sprite = 4
 },
 {
  name = "gavin",
  frames = {6, 7},
  timer = 0,
  sprite = 6
 },
 {
  name = "lily",
  frames = {8, 9},
  timer = 0,
  sprite = 8
 },
 {
  name = "allie",
  frames = {10, 11},
  timer = 0,
  sprite = 10
 },
 {
  name = "gabe",
  frames = {12, 13},
  timer = 0,
  sprite = 12
 },
 {
  name = "archie",
  frames = {14, 15},
  timer = 0,
  sprite = 14
 },
 {
  name = "lucas",
  frames = {16, 17},
  timer = 0,
  sprite = 16
 },
 {
  name = "reese",
  frames = {18, 19},
  timer = 0,
  sprite = 18
 },
 {
  name = "dahlia",
  frames = {20, 21},
  timer = 0,
  sprite = 20
 },
 {
  name = "isla",
  frames = {22, 23},
  timer = 0,
  sprite = 22
 },
 {
  name = "mrs foster",
  frames = {32, 33},
  timer = 0,
  sprite = 32
 },
 {
  name = "aidan",
  frames = {34, 35},
  timer = 0,
  sprite = 34
 },
 {
  name = "evie",
  frames = {36, 37},
  timer = 0,
  sprite = 36
 },
 {
  name = "vivi",
  frames = {38, 39},
  timer = 0,
  sprite = 38
 },
}

objective_types = {
 -- {
 --  name = "mr henke",
 --  frames = {24, 25, 26, 27},
 --  timer = 0,
 --  sprite = 24
 -- },
 {
  name = "june",
  frames = {28, 29, 30, 31},
  timer = 0,
  sprite = 28
 }
}

levels = {
 {
  map_x = 0, map_y = 0,
  start_x = 15, start_y = 112,
  objective_x = 80, objective_y = 16,  -- add objective position for level 1
  bg_color = 0   -- black
 },
 -- {
 --  map_x = 16, map_y = 0,
 --  start_x = 15, start_y = 112,
 --  objective_x = 80, objective_y = 16,  -- add objective position for level 2
 --  bg_color = 0   -- black
 -- }
}

sprite_sets = {
 {
  name = "mr henke",
  platform_left = 64,
  platform_mid = 65,
  platform_right = 66,
  ground = 67,
  solid = 120
 },
 {
  name = "june",
  platform_left = 68,
  platform_mid = 69,
  platform_right = 70,
  ground = 71,
  solid = 121
 },
 {
  name = "gavin",
  platform_left = 72,
  platform_mid = 73,
  platform_right = 74,
  ground = 75,
  solid = 122
 },
 {
  name = "lily",
  platform_left = 76,
  platform_mid = 77,
  platform_right = 78,
  ground = 79,
  solid = 123
 },
 {
  name = "allie",
  platform_left = 40,
  platform_mid = 41,
  platform_right = 42,
  ground = 43,
  solid = 44
 },
 {
  name = "gabe",
  platform_left = 80,
  platform_mid = 81,
  platform_right = 82,
  ground = 83,
  solid = 124
 },
 {
  name = "archie",
  platform_left = 84,
  platform_mid = 85,
  platform_right = 86,
  ground = 87,
  solid = 45
 },
 {
  name = "lucas",
  platform_left = 88,
  platform_mid = 89,
  platform_right = 90,
  ground = 91,
  solid = 125
 },
 {
  name = "reese",
  platform_left = 92,
  platform_mid = 93,
  platform_right = 94,
  ground = 95,
  solid = 126
 },
 {
  name = "dahlia",
  platform_left = 96,
  platform_mid = 97,
  platform_right = 98,
  ground = 99,
  solid = 127
 },
 {
  name = "isla",
  platform_left = 100,
  platform_mid = 101,
  platform_right = 102,
  ground = 103,
  solid = 46
 },
 {
  name = "mrs foster",
  platform_left = 104,
  platform_mid = 105,
  platform_right = 106,
  ground = 107,
  solid = 47
 },
 {
  name = "aidan",
  platform_left = 108,
  platform_mid = 109,
  platform_right = 110,
  ground = 111,
  solid = 56
 },
 {
  name = "evie",
  platform_left = 112,
  platform_mid = 113,
  platform_right = 114,
  ground = 115,
  solid = 57
 },
 {
  name = "vivi",
  platform_left = 116,
  platform_mid = 117,
  platform_right = 118,
  ground = 119,
  solid = 58
 }
}

-- create mapping tables for swapping
sprite_mapping = {}

function build_sprite_mapping()
 -- map from current level format to target format
 local current_level_set = app.current_sprite_set  -- what's currently on screen
 local target_set = (app.current_sprite_set % #sprite_sets) + 1  -- what we want

 local from_set = sprite_sets[current_level_set]
 local to_set = sprite_sets[target_set]

 sprite_mapping = {
  [from_set.ground] = to_set.ground,
  [from_set.platform_left] = to_set.platform_left,
  [from_set.platform_mid] = to_set.platform_mid,
  [from_set.platform_right] = to_set.platform_right,
  [from_set.solid] = to_set.solid
 }
end

function copy_map_area(from_x, from_y, to_x, to_y)
 for y = 0, 15 do
  for x = 0, 15 do
   local source_tile = mget(from_x + x, from_y + y)
   mset(to_x + x, to_y + y, source_tile)
  end
 end
end

function for_each_screen_tile(callback)
 for y = 0, 15 do
  for x = 0, 15 do
   callback(x, y)
  end
 end
end

function update_level_sprites()
 for_each_screen_tile(function(x, y)
  local current_tile = mget(x, y)
  local new_tile = sprite_mapping[current_tile]
  if new_tile then
   mset(x, y, new_tile)
  end
 end)
end

function game_init()
 app.current_level = _level or 1
 local level_data = levels[app.current_level]

 -- copy level map data to screen coordinates (0,0)
 for_each_screen_tile(function(x, y)
  local source_tile = mget(level_data.map_x + x, level_data.map_y + y)
  mset(x, y, source_tile)
 end)

 -- initialize sprite mapping and apply current sprite set
 build_sprite_mapping()
 if app.current_sprite_set > 1 then
  update_level_sprites()
 end

 -- use level-specific objective position instead of finding it
 app.objective_x = level_data.objective_x
 app.objective_y = level_data.objective_y

 player = {}
 player.name = 0
 player_init(player, level_data.start_x, level_data.start_y)
 set_app_mode("game")
 cls()
end

function _init()
 title_init()
end

function _update()
 app.update()
end

function _draw()
 app.draw()
end

function set_player_state(_p, _statename)
 _p.state = _statename
 _p.timer = 0
end

function get_player_state(_p)
 return _p.state
end

function is_platform(tile)
 return (tile >= 64 and tile <= 119)
end

function is_solid(tile)
 return (tile >= 44 and tile <= 63) or (tile >= 120 and tile <= 127)
end

function can_fall(_p)
 local tile = mget(flr((_p.pos.x+4)/8),flr((_p.pos.y+8)/8))
 return not (fget(tile, 0) or is_solid(tile) or is_platform(tile))
end

function can_move_horizontal(_p, _dx)
 local check_x = _p.pos.x + _dx + (_dx > 0 and 7 or 0)
 local tile = mget(flr(check_x/8), flr((_p.pos.y+4)/8))
 return not (fget(tile, 0) or is_solid(tile))
end

function move_player(_p)
 btn_l = btn(0, _p.name)
 btn_r = btn(1, _p.name)
 btn_j = btn(2, _p.name)

 if(get_player_state(_p) == "idle") then
  local player_set = player_sets[app.current_player_set]
  _p.sprite = player_set.frames[flr(_p.timer/8) % 2 + 1]

  if(btn_l or btn_r) then set_player_state(_p, "walking") end
  if(btn_j) then
   sfx(0, _p.name)
   set_player_state(_p, "falling")
  end
  if(can_fall(_p)) then set_player_state(_p, "jumping") end
 end

 if(get_player_state(_p) == "walking") then
  local move_amount = _p.dir * min(_p.timer, 2)
  local player_set = player_sets[app.current_player_set]

  if(btn_l and can_move_horizontal(_p, -1)) then _p.dir = -1 end
  if(btn_r and can_move_horizontal(_p, 1)) then _p.dir = 1 end

  if(can_move_horizontal(_p, move_amount)) then
   _p.pos.x += move_amount
  else
   if(can_fall(_p)) then
    set_player_state(_p, "jumping")
   end
  end
  _p.sprite = player_set.frames[flr(_p.timer/2) % 2 + 1]

  if(not (btn_l or btn_r)) then set_player_state(_p, "idle") end
  if(btn_j) then
   sfx(0, _p.name)
   set_player_state(_p, "falling")
  end
  if(can_fall(_p)) then set_player_state(_p, "jumping") end
 end

 if(get_player_state(_p) == "jumping") then
  sfx(-1, _p.name)
  local player_set = player_sets[app.current_player_set]
  _p.sprite = player_set.frames[1]

  if(can_fall(_p)) then
   -- increase horizontal movement while falling too
   local move_amount = 2  -- fixed faster speed instead of min(_p.timer, 2)
   if(btn_l and can_move_horizontal(_p, -move_amount)) then
    _p.dir = -1
    _p.pos.x -= move_amount
   end
   if(btn_r and can_move_horizontal(_p, move_amount)) then
    _p.dir = 1
    _p.pos.x += move_amount
   end

   -- fall speed mirrors jump speed (starts slow, gets faster)
   local fall_force = min(_p.timer * 0.5, 4)  -- same acceleration as jump
   _p.pos.y += fall_force

   if (not can_fall(_p)) then
    _p.pos.y = flr(_p.pos.y/8) * 8
    set_player_state(_p, "idle")
   end
  else
   _p.pos.y = flr(_p.pos.y/8) * 8
   set_player_state(_p, "idle")
  end
 end

 if(get_player_state(_p) == "falling") then
  local player_set = player_sets[app.current_player_set]
  _p.sprite = player_set.frames[2]
  -- more controlled jump speed
  local jump_force = max(4 - _p.timer * 0.5, 0)  -- starts at 4, decreases by 0.5 each frame
  _p.pos.y -= jump_force

  local jump_move_speed = _p.vel.x * 2
  if(btn_l and can_move_horizontal(_p, -jump_move_speed)) then _p.pos.x -= jump_move_speed end
  if(btn_r and can_move_horizontal(_p, jump_move_speed)) then _p.pos.x += jump_move_speed end
  if(not btn_j or _p.timer > 7) then set_player_state(_p, "idle") end
 end

 local level_data = levels[app.current_level]
 if(abs(_p.pos.x - app.objective_x) < 8 and abs(_p.pos.y - app.objective_y) < 8) then
  sfx(1)
  if app.current_level < app.max_levels then
   -- go to next level
   -- game_init(app.players_count, app.current_level + 1)
  else
   -- game complete
   set_app_mode("win")
  end
 end
 _p.pos.x = (_p.pos.x + 128) % 128
 _p.timer += 1
end

function anim_objective()
 -- use current objective set instead of level-specific objective
 local objective_type = objective_types[app.current_objective_set]

 if(objective_type.timer >= #objective_type.frames * 2) then
  objective_type.timer = 0
 end

 objective_type.sprite = objective_type.frames[flr(objective_type.timer/2) % #objective_type.frames + 1]
 objective_type.timer += 1
end

function title_update()
 if (btnp(5)) then
  game_init()
 end
end

function win_update()
 if btnp(4) then
 	title_init()
 elseif btnp(5) then
  game_init()  -- restart the game
 end
end

function game_update()
 anim_objective()

 -- demo cycling controls
 if btnp(3) then  -- down button - cycle player sprites
 end

 if btnp(4) then  -- z button - cycle objective sprites
  build_sprite_mapping()  -- build mapping before changing current set

  app.current_sprite_set = (app.current_sprite_set % #sprite_sets) + 1  -- update after swap
  update_level_sprites()

  app.current_player_set = (app.current_player_set % #player_sets) + 1
  update_player_sprites()

  app.current_objective_set = (app.current_objective_set % #objective_types) + 1
  update_objective_sprites()
 end

 if btnp(5) then  -- x button - cycle sprite sets
 end

 move_player(player)  -- always move player 1 first
end

function title_draw()
 -- Draw Foster Art logo
 for i=0,5 do
  spr(i+234, 40+(i*8), 30)
 end
 for i=0,5 do
  spr(i+250, 40+(i*8), 38)
 end
 print("press x to start", 15, 70, 7)
 print("press z to change artists", 15, 80, 6)
end

function win_draw()
 cls()
 -- Draw Foster Art logo
 for i=0,5 do
  spr(i+234, 40+(i*8), 50)
 end
 for i=0,5 do
  spr(i+250, 40+(i*8), 58)
 end
 print("great job making art!", 22, 85, 7)
 print("press x to restart", 22, 95, 7)
end

function player_draw(_p, _x, _y)
 spr(_p.sprite, _x, _y, 1, 1, _p.dir == -1)
end

function game_draw()
 local level_data = levels[app.current_level]
 local objective_type = objective_types[app.current_objective_set]
 local player_set = player_sets[app.current_player_set]
 local sprite_set = sprite_sets[app.current_sprite_set]

 -- fill background with level's color
 rectfill(0, 0, 127, 127, level_data.bg_color)

 -- draw from screen coordinates since we copied the map there
 map(0, 0, 0, 0, 16, 16)

 player_draw(player, player.pos.x, player.pos.y)

 spr(objective_type.sprite, app.objective_x, app.objective_y, 1, 1)

 -- show level indicator and artist credits
 print("artist: " .. player_set.name, 2, 2, 7)
 -- print("level " .. app.current_level, 2, 2, 7)
 -- print("player: " .. player_set.name, 2, 10, 6)
 -- print("objective: " .. objective_type.name, 2, 18, 6)
 -- print("sprites: " .. sprite_set.name, 2, 26, 6)
end

function find_objective_position(_level)
 local level_data = levels[_level]
 local objective_type = objective_types[app.current_objective_set]

 local found_x, found_y = nil, nil

 for_each_screen_tile(function(x, y)
  if found_x then return end  -- early exit if already found

  local tile = mget(level_data.map_x + x, level_data.map_y + y)
  for i = 1, #objective_type.frames do
   if tile == objective_type.frames[i] then
    found_x, found_y = x * 8, y * 8
    return
   end
  end
 end)

 -- return found position or default
 return found_x or 80, found_y or 16
end

function update_player_sprites()
 local player_set = player_sets[app.current_player_set]
 if player.state == "idle" or player.state == "walking" then
  player.sprite = player_set.frames[flr(player.timer/8) % 2 + 1]
 elseif player.state == "falling" then
  player.sprite = player_set.frames[2]
 else
  player.sprite = player_set.frames[1]
 end
end

function update_objective_sprites()
 -- update the current objective set directly
 local objective_type = objective_types[app.current_objective_set]
 objective_type.sprite = objective_type.frames[1]

 -- update objective position for new sprites
 app.objective_x, app.objective_y = find_objective_position(app.current_level)
end

function title_init()
 set_app_mode("title")
 cls()
end

function set_app_mode(_mode)
 app.mode = _mode
 if _mode == "title" then
  app.update = title_update
  app.draw = title_draw
 elseif _mode == "game" then
  app.update = game_update
  app.draw = game_draw
 elseif _mode == "win" then
  app.update = win_update
  app.draw = win_draw
 end
end

function player_init(_p, _x, _y)
 _p.pos = {x = _x, y = _y}
 _p.vel = {x = 1, y = 4}
 _p.dir = 1
 _p.sprite = player_sets[app.current_player_set].frames[1]
 set_player_state(_p, "idle")
end
