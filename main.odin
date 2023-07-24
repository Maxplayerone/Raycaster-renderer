/*
package main

import ray "vendor:raylib"
import "core:fmt"
import math "core:math/linalg"

WINDOW_WIDTH :: 1024
WINDOW_HEIGHT :: 512

PI: f32 = 3.14
HALF_PI: f32 = 1.57
PI23: f32 = 4.71

player_x: f32 = 300
player_y: f32 = 300

player_angle: f32 = 0.0
delta_x: f32 = 0
delta_y: f32 = 0
DELTA_MULTIPLAYER :: 5

PLAYER_SIZE :: 8

MAP_SIZE_X :: 8
MAP_SIZE_Y :: 8
MAP_SIZE :: 64
MAP := [MAP_SIZE]u8{
	1, 1, 1, 1, 1, 1, 1, 1,
	1, 0, 1, 0, 0, 0, 0, 1,
	1, 0, 1, 0, 0, 0, 0, 1,
	1, 0, 1, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 0, 0, 0, 1,
	1, 0, 0, 0, 0, 1, 0, 1,
	1, 0, 0, 0, 0, 0, 0, 1,
	1, 1, 1, 1, 1, 1, 1, 1,
}

main :: proc(){
	ray.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "raycast engine")
	defer ray.CloseWindow()
	
	ray.SetTargetFPS(60)
	
	delta_x = math.cos(player_angle) * DELTA_MULTIPLAYER
	delta_y = math.sin(player_angle) * DELTA_MULTIPLAYER
	
	for !ray.WindowShouldClose(){
		update_player()
		render()
	}
}

update_player :: proc(){
	if ray.IsKeyDown(.A) {
		player_angle -= 0.1 
		if player_angle < 0{
			player_angle += 2 * PI
		}
		delta_x = math.cos(player_angle) * DELTA_MULTIPLAYER
		delta_y = math.sin(player_angle) * DELTA_MULTIPLAYER
	} 
	if ray.IsKeyDown(.D) {
		player_angle += 0.1 
		if player_angle > 2 * PI{
			player_angle -= 2 * PI
		}
		delta_x = math.cos(player_angle) * DELTA_MULTIPLAYER
		delta_y = math.sin(player_angle) * DELTA_MULTIPLAYER
	} 
	if ray.IsKeyDown(.W){
		player_x += delta_x
		player_y += delta_y
	}
	if ray.IsKeyDown(.S){
		player_x -= delta_x
		player_y -= delta_y
	}
	
	//fmt.println("Angle ", player_angle)
}

render :: proc(){
	ray.BeginDrawing()
	defer ray.EndDrawing()
	
	ray.ClearBackground(ray.Color{153, 153, 153, 255})
	
	render_map()
	render_player()
	render_rays()
}

render_player :: proc(){
	ray.DrawRectangle(cast(i32)player_x, cast(i32)player_y, PLAYER_SIZE, PLAYER_SIZE, ray.Color{255, 255, 0, 255})

	ray.DrawLine(cast(i32)player_x, cast(i32)player_y, cast(i32)(player_x + delta_x * DELTA_MULTIPLAYER), cast(i32)(player_y + delta_y * DELTA_MULTIPLAYER), ray.Color{0, 255, 0, 255})
}

render_map :: proc(){
	for y in 0..<MAP_SIZE_Y{
		for x in 0..<MAP_SIZE_X{
			color := MAP[y * MAP_SIZE_X + x] == 1 ? ray.WHITE : ray.BLACK
			
			ray.DrawRectangle(cast(i32)x * MAP_SIZE, cast(i32)y * MAP_SIZE, MAP_SIZE - 1, MAP_SIZE - 1, color)
		}
	}
}

render_rays :: proc(){
	ray_count: i32 = 1
	dof, map_x, map_y, map_index: i32 
	
	ray_angle, ray_x, ray_y, x_offset, y_offset: f32
	ray_angle = player_angle
	
	for i in 0..<ray_count{
		//horizontal lines
		neg_inv_tan: f32 = -1/math.tan(ray_angle)
		if ray_angle > PI{ //looking up
			ray_y = cast(f32)((cast(i32)player_y>>6)<<6) - 0.0001
			ray_x = (player_y - ray_y) * neg_inv_tan + player_x
			y_offset = -64
			x_offset = -y_offset * neg_inv_tan
		}
		if ray_angle < PI{
			ray_y = cast(f32)((cast(i32)player_y>>6)<<6) + 64
			ray_x = (player_y - ray_y) * neg_inv_tan + player_x
			y_offset = 64
			x_offset = -y_offset * neg_inv_tan
		}
		if ray_angle == 0 || ray_angle == PI{
			ray_x = player_x
			ray_y = player_y
			dof = 8
		}
		for dof < 8{
			map_x = cast(i32)ray_x>>6
			map_y = cast(i32)ray_y>>6
			map_index = map_y * MAP_SIZE_X + map_x
			if map_index > 0 || map_index < MAP_SIZE && MAP[map_index] == 1{
				dof = 8
			}
			else{
				ray_x += x_offset
				ray_y += y_offset
				dof += 1
			}
		}
		ray.DrawLine(cast(i32)player_x, cast(i32)player_y, cast(i32)ray_x, cast(i32)ray_y, ray.Color{255, 0, 0, 255})
		
		//vertical lines
		neg_tan: f32 = -math.tan(ray_angle)
		if ray_angle > HALF_PI && ray_angle < PI23{
			ray_x = cast(f32)((cast(i32)player_x>>6)<<6) - 0.0001
			ray_y = (player_x - ray_x) * neg_tan + player_y
			x_offset = -64
			y_offset = -x_offset * neg_tan
		}
		if ray_angle < HALF_PI || ray_angle > PI23{
			ray_x = cast(f32)((cast(i32)player_x>>6)<<6) + 64
			ray_y = (player_x - ray_x) * neg_tan + player_y
			x_offset = 64
			y_offset = -x_offset * neg_tan
		}
		if ray_angle == 0 || ray_angle == PI{
			ray_x = player_x
			ray_y = player_y
			dof = 8
		}
		for dof < 8{
			map_x = cast(i32)ray_x>>6
			map_y = cast(i32)ray_y>>6
			map_index = map_y * MAP_SIZE_X + map_x
			if map_index > 0  && map_index < MAP_SIZE && MAP[map_index] == 1{
				dof = 8
			}
			else{
				ray_x += x_offset
				ray_y += y_offset
				dof += 1
			}
		}
		//ray.DrawLine(cast(i32)player_x, cast(i32)player_y, cast(i32)ray_x, cast(i32)ray_y, ray.Color{0, 0, 255, 255})
	}
	
}
*/
package main

import ray "vendor:raylib"
import "core:fmt"
import math "core:math/linalg"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

MAP_WIDTH :: 24
MAP_HEIHT :: 24

