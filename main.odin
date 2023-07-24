package main

import ray "vendor:raylib"
import "core:fmt"

WINDOW_WIDTH :: 1024
WINDOW_HEIGHT :: 512

player_x: i32 = 300
player_y: i32 = 300

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
	
	for !ray.WindowShouldClose(){
		update_player()
		render()
	}
}

update_player :: proc(){
	if ray.IsKeyDown(.A) do player_x -= 2
	if ray.IsKeyDown(.D) do player_x += 2
	if ray.IsKeyDown(.W) do player_y -= 2
	if ray.IsKeyDown(.S) do player_y += 2
}

render :: proc(){
	ray.BeginDrawing()
	defer ray.EndDrawing()
	
	ray.ClearBackground(ray.Color{153, 153, 153, 255})
	
	render_map()
	render_player()
}

render_player :: proc(){
	ray.DrawRectangle(player_x, player_y, PLAYER_SIZE, PLAYER_SIZE, ray.Color{255, 255, 0, 255})
}

render_map :: proc(){
	for y in 0..<MAP_SIZE_Y{
		for x in 0..<MAP_SIZE_X{
			color := MAP[y * MAP_SIZE_X + x] == 1 ? ray.WHITE : ray.BLACK
			
			ray.DrawRectangle(cast(i32)x * MAP_SIZE, cast(i32)y * MAP_SIZE, MAP_SIZE - 1, MAP_SIZE - 1, color)
		}
	}
}

