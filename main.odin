package main

import ray "vendor:raylib"
import "core:fmt"
import linalg "core:math/linalg"

WINDOW_WIDTH :: 1024
WINDOW_HEIGHT :: 512

PI: f32 = 3.14

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
	
	delta_x = linalg.cos(player_angle) * DELTA_MULTIPLAYER
	delta_y = linalg.sin(player_angle) * DELTA_MULTIPLAYER
	
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
		delta_x = linalg.cos(player_angle) * DELTA_MULTIPLAYER
		delta_y = linalg.sin(player_angle) * DELTA_MULTIPLAYER
	} 
	if ray.IsKeyDown(.D) {
		player_angle += 0.1 
		if player_angle > 2 * PI{
			player_angle -= 2 * PI
		}
		delta_x = linalg.cos(player_angle) * DELTA_MULTIPLAYER
		delta_y = linalg.sin(player_angle) * DELTA_MULTIPLAYER
	} 
	if ray.IsKeyDown(.W){
		player_x += delta_x
		player_y += delta_y
	}
	if ray.IsKeyDown(.S){
		player_x -= delta_x
		player_y -= delta_y
	}
}

render :: proc(){
	ray.BeginDrawing()
	defer ray.EndDrawing()
	
	ray.ClearBackground(ray.Color{153, 153, 153, 255})
	
	render_map()
	render_player()
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

