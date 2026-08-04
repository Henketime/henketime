-- pico-8 spaceship - cleaned up collision, kept enemy corpses
state_title=1 state_entrance=2 state_play=3 state_boss_intro=4 state_boss=5 state_gameover=6
game_state=state_title state_timer=0 current_set=1

authors={"default art","rahma","dani","layla","joey","mika","thomas","reese","gabe","liam","daniel","aidan","oliver","james","artist 15","artist 16"}

function get_ship_sprites(set)
  local base=(set-1)*3
  return base+1,base+2,base+3
end

function get_enemy_sprite(set)
  return 127+set
end

function get_projectile_sprite(set)
  return 143+set
end

function get_boss_sprites(set)
  local base_row
  if set<=8 then base_row=64
  else base_row=96 end
  local col_offset=((set-1)%8)*2
  local tl=base_row+col_offset
  return tl, tl+1, tl+16, tl+17
end

function apply_set(set)
  local s1,s2,s3=get_ship_sprites(set)
  ship_sprite_base=s1 ship_sprite_mid=s2 ship_sprite_rear=s3
  enemy_sprite=get_enemy_sprite(set)
  projectile_sprite=get_projectile_sprite(set)
  boss_tl,boss_tr,boss_bl,boss_br=get_boss_sprites(set)
  boss_sprite=boss_tl
  current_author=authors[set]
end

init_state={
  game_state=state_title,
  state_timer=0,
  current_set=1,
  ship_x=64,
  ship_y=128,
  ship_speed=1.25,
  ship_target_y=80,
  ship_entrance_speed=2,
  ship_sprite=1,
  ship_invuln=0,
  ship_bounce_timer=0,
  shoot_timer=0,
  shoot_delay=30,
  projectile_max_speed=2,
  projectile_accel=0.125,
  stars={},
  enemy1={x=-20,y=30,alive=false,respawn=0,entering=true,enter_x=-20,dx=0,dy=0,invuln=0,base_y=30,dead=false},
  enemy2={x=148,y=35,alive=false,respawn=0,entering=true,enter_x=148,dx=0,dy=0,invuln=0,base_y=35,dead=false},
  boss_x=56,
  boss_y=-20,
  boss_speed=0.5,
  boss_dir=1,
  boss_active=false,
  boss_sprite=64,
  boss_hp=5,
  boss_entrance=false,
  boss_target_y=0,
  enemies_killed=0,
  boss_spawned=false,
  left_rows={17,33},
  right_rows={25,41}
}

projectiles={} particles={} stars={}
left_rows={17,33}
right_rows={25,41}
enemy1={x=-20,y=30,alive=false,respawn=0,entering=true,enter_x=-20,dx=0,dy=0,invuln=0,base_y=30,dead=false}
enemy2={x=148,y=35,alive=false,respawn=0,entering=true,enter_x=148,dx=0,dy=0,invuln=0,base_y=35,dead=false}
boss_x=56 boss_y=-20 boss_speed=0.5 boss_dir=1 boss_active=false boss_sprite=64 boss_hp=5 boss_entrance=false
boss_target_y=0
enemies_killed=0 boss_spawned=false

function copytable(t)
  local r={}
  for k,v in pairs(t) do
    if type(v)=="table" then r[k]=copytable(v) else r[k]=v end
  end
  return r
end

function _init() reset_game() end

function reset_game(reset_state)
  local s=copytable(init_state)
  game_state=reset_state or s.game_state
  state_timer=s.state_timer
  current_set=s.current_set
  ship_x=s.ship_x ship_y=s.ship_y ship_speed=s.ship_speed ship_target_y=s.ship_target_y ship_entrance_speed=s.ship_entrance_speed ship_sprite=s.ship_sprite ship_invuln=s.ship_invuln ship_bounce_timer=s.ship_bounce_timer
  shoot_timer=s.shoot_timer shoot_delay=s.shoot_delay projectile_max_speed=s.projectile_max_speed projectile_accel=s.projectile_accel
  stars={}
  for i=1,20 do add(stars,{x=rnd(128),y=rnd(128),s=1+rnd(2),sp=0.25+rnd(0.75)}) end
  enemy1=copytable(s.enemy1)
  enemy2=copytable(s.enemy2)
  boss_x=s.boss_x boss_y=s.boss_y boss_speed=s.boss_speed boss_dir=s.boss_dir boss_active=s.boss_active boss_sprite=s.boss_sprite boss_hp=s.boss_hp boss_entrance=s.boss_entrance boss_target_y=s.boss_target_y
  enemies_killed=s.enemies_killed boss_spawned=s.boss_spawned
  projectiles={} particles={}
  apply_set(current_set)
end

function collision_8x8(x1,y1,x2,y2) local dx=abs(x1-x2) local dy=abs(y1-y2) return (dx<8 and dy<8) end
function collision_boss(px,py,bx,by) local dx=abs(px-bx) local dy=abs(py-by) return (dx<12 and dy<12) end

function spawn_particles(x,y,count,colors)
  for i=1,count do local angle=i/count*3.14159*2 local speed=0.5+flr(rnd(1.5))
    add(particles,{x=x,y=y,dx=cos(angle)*speed,dy=sin(angle)*speed,life=15+rnd(10),color=colors[flr(rnd(#colors))+1],size=1+rnd(2)}) end
end

function pick_row(from_left)
  local rows=from_left and left_rows or right_rows
  return rows[flr(rnd(#rows))+1]
end

function spawn_enemy(e,from_left)
  e.alive=true e.dead=false e.entering=true e.dx=0 e.dy=0 e.invuln=0
  e.base_y=pick_row(from_left)
  if from_left then e.enter_x=-20 e.x=-20 else e.enter_x=148 e.x=148 end
  e.y=e.base_y
end

function kill_enemy(e) e.alive=false e.dead=true e.entering=false e.dx=0 e.dy=0 enemies_killed=enemies_killed+1 spawn_particles(e.x+4,e.y+4,8,{7,10,9}) end

function bounce_ship_enemy(e)
  local ship_cx=ship_x+4 local ship_cy=ship_y+4 local enemy_cx=e.x+4 local enemy_cy=e.y+4
  local dx=ship_cx-enemy_cx local dy=ship_cy-enemy_cy local adx=abs(dx) local ady=abs(dy)
  if adx>ady then if dx<0 then ship_x=ship_x-4 e.dx=2 else ship_x=ship_x+4 e.dx=-2 end
  else if dy<0 then ship_y=ship_y-4 e.dy=2 else ship_y=ship_y+4 e.dy=-2 end end
  if ship_x<0 then ship_x=0 end if ship_x>120 then ship_x=120 end
  if ship_y<0 then ship_y=0 end if ship_y>96 then ship_y=96 end
  ship_invuln=20 ship_bounce_timer=10 e.invuln=20 spawn_particles(ship_cx,ship_cy,6,{7,8,10})
end

function update_stars()
  for s in all(stars) do
    s.y=s.y+s.sp
    if s.y>127 then s.y=0 s.x=rnd(128) end
  end
end

function _update60()
  state_timer=state_timer+1
  if ship_invuln>0 then ship_invuln=ship_invuln-1 end
  if ship_bounce_timer>0 then ship_bounce_timer=ship_bounce_timer-1 end
  if enemy1.invuln>0 then enemy1.invuln=enemy1.invuln-1 end
  if enemy2.invuln>0 then enemy2.invuln=enemy2.invuln-1 end

  update_stars()

  if game_state==state_title then
    if btnp(4) then
      current_set=current_set+1
      if current_set>16 then current_set=1 end
      apply_set(current_set)
    end
    if btn(5) then game_state=state_entrance state_timer=0 reset_game(state_entrance) end
  end

  if game_state==state_play or game_state==state_boss_intro or game_state==state_boss then
    if btnp(4) then
      current_set=current_set+1
      if current_set>16 then current_set=1 end
      apply_set(current_set)
    end
  end

  if game_state==state_entrance then
    if ship_y>ship_target_y then ship_y=ship_y-ship_entrance_speed else ship_y=ship_target_y
      if state_timer>=30 then game_state=state_play state_timer=0 spawn_enemy(enemy1,true) spawn_enemy(enemy2,false) end end end

  update_enemies() update_enemy_movement()

  if game_state==state_play then
    update_ship() update_projectiles() update_particles()
    handle_ship_enemy_collision()
    if enemies_killed>=4 and not boss_spawned then game_state=state_boss_intro state_timer=0 boss_active=false boss_entrance=true boss_y=-20 end end

  if game_state==state_boss_intro then
    update_ship() update_projectiles() update_particles()
    handle_ship_enemy_collision()
    if boss_entrance and boss_y<boss_target_y then
      boss_y=boss_y+(projectile_max_speed/4)
    else
      boss_y=boss_target_y
      boss_active=true
      boss_entrance=false
      game_state=state_boss
    end
  end

  if game_state==state_boss then
    update_ship() update_projectiles() update_particles() update_boss()
    handle_ship_enemy_collision()
    if boss_hp<=0 then game_state=state_gameover state_timer=0 end end

  if game_state==state_gameover and btn(5) and state_timer>30 then game_state=state_title state_timer=0 end
end

function update_ship()
  if ship_bounce_timer<=0 then
    if btn(0) then ship_x=ship_x-ship_speed end if btn(1) then ship_x=ship_x+ship_speed end
    if btn(2) then ship_y=ship_y-ship_speed end if btn(3) then ship_y=ship_y+ship_speed end end
  if ship_x<0 then ship_x=0 end if ship_x>120 then ship_x=120 end
  if ship_y<0 then ship_y=0 end if ship_y>96 then ship_y=96 end
  if shoot_timer>0 then shoot_timer=shoot_timer-1 end
  if btn(5) and shoot_timer<=0 then add(projectiles,{x=ship_x,y=ship_y-4,sprite=projectile_sprite,speed=0.5,age=0}) shoot_timer=shoot_delay end
  if btn(0) then ship_sprite=ship_sprite_base elseif btn(1) then ship_sprite=ship_sprite_rear else ship_sprite=ship_sprite_mid end
end

function update_projectiles()
  for i=#projectiles,1,-1 do local p=projectiles[i]
    if p.speed<projectile_max_speed then p.speed=p.speed+projectile_accel if p.speed>projectile_max_speed then p.speed=projectile_max_speed end end
    p.y=p.y-p.speed p.age=p.age+1 local hit=false local pcx=p.x+4 local pcy=p.y+4
    if enemy1.alive and not enemy1.dead and not enemy1.entering and enemy1.invuln<=0 then
      local e1cx=enemy1.x+4 local e1cy=enemy1.y+4 if collision_8x8(pcx,pcy,e1cx,e1cy) then hit=true kill_enemy(enemy1) end end
    if enemy2.alive and not enemy2.dead and not enemy2.entering and enemy2.invuln<=0 then
      local e2cx=enemy2.x+4 local e2cy=enemy2.y+4 if collision_8x8(pcx,pcy,e2cx,e2cy) then hit=true kill_enemy(enemy2) end end
    if boss_active then local bcx=boss_x+8 local bcy=boss_y+8
      if collision_boss(pcx,pcy,bcx,bcy) then boss_hp=boss_hp-1 spawn_particles(pcx,pcy,8,{7,10,9}) hit=true end end
    if hit or p.y<-8 then del(projectiles,p) end end
end

function update_particles() for i=#particles,1,-1 do local pt=particles[i] pt.x=pt.x+pt.dx pt.y=pt.y+pt.dy pt.life=pt.life-1 if pt.life<=0 then del(particles,pt) end end end

function update_enemies()
  if enemy1.entering then if enemy1.x<32 then enemy1.x=enemy1.x+2 else enemy1.entering=false end end
  if enemy2.entering then if enemy2.x>96 then enemy2.x=enemy2.x-2 else enemy2.entering=false end end
  if not enemy1.alive and not enemy1.entering then enemy1.respawn=enemy1.respawn-1 if enemy1.respawn<=0 then spawn_enemy(enemy1,enemy1.enter_x<64) end end
  if not enemy2.alive and not enemy2.entering then enemy2.respawn=enemy2.respawn-1 if enemy2.respawn<=0 then spawn_enemy(enemy2,enemy2.enter_x<64) end end
end

function update_enemy_movement()
  if enemy1.alive and not enemy1.entering then
    if enemy1.dx==0 then enemy1.dx=0.5 end enemy1.x=enemy1.x+enemy1.dx
    if enemy1.x<=0 then enemy1.x=0 enemy1.dx=0.5 end if enemy1.x>=120 then enemy1.x=120 enemy1.dx=-0.5 end end
  if enemy2.alive and not enemy2.entering then
    if enemy2.dx==0 then enemy2.dx=-0.5 end enemy2.x=enemy2.x+enemy2.dx
    if enemy2.x<=0 then enemy2.x=0 enemy2.dx=0.5 end if enemy2.x>=120 then enemy2.x=120 enemy2.dx=-0.5 end end
end

function handle_ship_enemy_collision()
  local ship_cx=ship_x+4 local ship_cy=ship_y+4
  if enemy1.alive and not enemy1.dead and enemy1.invuln<=0 then if collision_8x8(ship_cx,ship_cy,enemy1.x+4,enemy1.y+4) then bounce_ship_enemy(enemy1) end end
  if enemy2.alive and not enemy2.dead and enemy2.invuln<=0 then if collision_8x8(ship_cx,ship_cy,enemy2.x+4,enemy2.y+4) then bounce_ship_enemy(enemy2) end end
end

function update_boss() boss_x=boss_x+boss_speed*boss_dir if boss_x<=0 then boss_x=0 boss_dir=1 end if boss_x>=112 then boss_x=112 boss_dir=-1 end end

function _draw()
  cls(0)
  for s in all(stars) do pset(s.x,s.y,1) end
  if game_state==state_title then
    print("press x or ❎ to begin",20,60,7,false)
    print("press z or 🅾️ to change artist",4,68,7,false)
    return
  end
  if game_state==state_gameover then
    print("game over",48,60,7,false)
    print("press x or ❎ to restart",16,68,7,false)
    return
  end
  for pt in all(particles) do circfill(pt.x,pt.y,pt.size,pt.color) end
  for p in all(projectiles) do spr(p.sprite,p.x,p.y) end
  if ship_invuln>0 and (flr(state_timer/4)%2==0) then else spr(ship_sprite,ship_x,ship_y) end
  if enemy1.alive then spr(enemy_sprite,enemy1.x,enemy1.y) end if enemy2.alive then spr(enemy_sprite,enemy2.x,enemy2.y) end
  if boss_entrance or boss_active then spr(boss_sprite,boss_x,boss_y,2,2) end
  if game_state==state_play or game_state==state_boss_intro or game_state==state_boss then
    print("author: "..current_author,2,120,7,false)
  end
  if ship_invuln>0 and (flr(state_timer/4)%2==0) then else spr(ship_sprite,ship_x,ship_y) end
  if enemy1.alive then spr(enemy_sprite,enemy1.x,enemy1.y) end if enemy2.alive then spr(enemy_sprite,enemy2.x,enemy2.y) end
  if boss_entrance or boss_active then spr(boss_sprite,boss_x,boss_y,2,2) end
end
