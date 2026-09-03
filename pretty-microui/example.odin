package main

import "core:math"

import rl "vendor:raylib"
import mu "shared:microui"

SCREEN_WIDTH  :: 1440
SCREEN_HEIGHT :: 900

App_State :: struct {
	ui: mu.Context,

	theme_index: int,
	gallery_tab: int,
	language_index: int,
	selected_list: int,
	selected_combo: int,
	radio_value: int,

	enabled: bool,
	show_grid: bool,
	auto_range: bool,
	check_a: bool,
	check_b: bool,

	gain: mu.Real,
	frequency: mu.Real,
	progress: f32,

	plot_values: [160]f32,
	spark_values: [32]f32,

	editor: mu.Code_Editor,
	editor_buffer: [256 * 1024]u8,
}

state: App_State

custom_completion_words := [?]string{
	"application_state", "render_dashboard", "update_simulation", "frame_delta",
	"primary_color", "secondary_color", "selected_item", "window_width",
	"window_height", "raylib", "microui", "code_editor", "plot_values",
}

language_names := [?]string{"C", "C++", "Odin", "Python"}
theme_names := [?]string{"Midnight", "Light"}
list_items := [?]string{"Overview", "Appearance", "Input", "Rendering", "Editor", "Diagnostics"}
combo_items := [?]string{"Balanced", "Compact", "Comfortable", "Presentation"}
gallery_tabs := [?]string{"Controls", "Data", "Status"}
radio_items := [?]string{"Low latency", "Balanced", "High quality"}

default_source :: `package main

import rl "vendor:raylib"
import ui "microui"

App :: struct {
    ctx: ui.Context,
    running: bool,
    frame_count: u64,
}

main :: proc() {
    rl.InitWindow(1280, 720, "Beautiful Odin UI")
    defer rl.CloseWindow()

    app: App
    ui.init_raylib(&app.ctx)

    for !rl.WindowShouldClose() {
        ui.frame_begin(&app.ctx)

        if ui.window(&app.ctx, "Hello", {40, 40, 420, 280}) {
            ui.layout_row(&app.ctx, {-1}, 32)
            ui.heading(&app.ctx, "Immediate mode, polished")
            ui.callout(&app.ctx, "Everything is rendered by Raylib 6.")
        }

        ui.frame_end(&app.ctx)
        app.frame_count += 1
    }
}
`

// init_raylib automatically selects the best installed Linux font set.
update_plot_data :: proc() {
	t := f32(rl.GetTime())
	gain := f32(state.gain)
	frequency := f32(state.frequency)
	for &value, i in state.plot_values {
		x := f32(i) / f32(len(state.plot_values)-1)
		wave := math.sin((x*7.5+t*0.7)*frequency) * 0.62
		detail := math.sin((x*23.0-t*1.3)*frequency) * 0.18
		value = (wave + detail) * gain
	}
	for &value, i in state.spark_values {
		x := f32(i) / f32(len(state.spark_values)-1)
		value = 0.5 + 0.35*math.sin(x*8+t*1.7) + 0.1*math.sin(x*25-t)
	}
	state.progress = 0.5 + 0.5*math.sin(t*0.65)
}

widget_gallery :: proc(ctx: ^mu.Context) {
	options := mu.Options{.NO_CLOSE}
	if mu.window(ctx, "Widget Gallery", {18, 18, 356, 864}, options) {
		mu.layout_row(ctx, {-1}, 36)
		mu.heading(ctx, "microUI, redesigned")
		mu.layout_row(ctx, {-1}, 24)
		mu.muted_label(ctx, "Single-file Odin UI powered directly by Raylib 6")

		mu.layout_row(ctx, {94, -1}, 30)
		mu.label(ctx, "Theme")
		old_theme := state.theme_index
		_ = mu.combo_box(ctx, "Theme preset", theme_names[:], &state.theme_index)
		if old_theme != state.theme_index {
			mu.apply_theme(ctx, state.theme_index == 0 ? .MIDNIGHT : .LIGHT)
		}

		mu.layout_row(ctx, {-1}, 34)
		_ = mu.tab_bar(ctx, gallery_tabs[:], &state.gallery_tab)
		mu.layout_row(ctx, {-1}, 18)
		mu.separator(ctx)

		switch state.gallery_tab {
		case 0:
			mu.layout_row(ctx, {-1}, 30)
			_ = mu.toggle(ctx, "Enable live updates", &state.enabled)
			mu.layout_row(ctx, {-1}, 28)
			_ = mu.checkbox(ctx, "Show grid", &state.show_grid)
			_ = mu.checkbox(ctx, "Automatic plot range", &state.auto_range)
			_ = mu.checkbox(ctx, "Remember layout", &state.check_a)

			mu.layout_row(ctx, {-1}, 20)
			mu.separator(ctx, "Choice controls")
			mu.layout_row(ctx, {-1}, 27)
			for label, index in radio_items {
				if .SUBMIT in mu.radio_button(ctx, label, state.radio_value == index) {
					state.radio_value = index
				}
			}

			mu.layout_row(ctx, {-1}, 20)
			mu.separator(ctx, "Continuous values")
			mu.layout_row(ctx, {88, -1}, 28)
			mu.label(ctx, "Gain")
			_ = mu.slider(ctx, &state.gain, 0.1, 1.8, 0.01, "%.2f")
			mu.label(ctx, "Frequency")
			_ = mu.slider(ctx, &state.frequency, 0.25, 2.5, 0.01, "%.2f")
			mu.layout_row(ctx, {112, 112, -1}, 112)
			_ = mu.knob(ctx, "Gain", &state.gain, 0.1, 1.8, 0.01)
			_ = mu.knob(ctx, "Frequency", &state.frequency, 0.25, 2.5, 0.01)
			mu.layout_begin_column(ctx)
			mu.layout_row(ctx, {-1}, 24)
			mu.badge(ctx, "RAYLIB 6", .SUCCESS)
			mu.badge(ctx, "ODIN", .ACCENT)
			mu.layout_row(ctx, {-1}, 42)
			mu.spinner(ctx)
			mu.layout_end_column(ctx)

		case 1:
			mu.layout_row(ctx, {-1}, 186)
			_ = mu.list_box(ctx, "Navigation", list_items[:], &state.selected_list, 28)
			mu.layout_row(ctx, {92, -1}, 30)
			mu.label(ctx, "Density")
			_ = mu.combo_box(ctx, "Density", combo_items[:], &state.selected_combo)
			mu.layout_row(ctx, {-1}, 20)
			mu.separator(ctx, "Miniature plot")
			mu.layout_row(ctx, {-1}, 74)
			mu.sparkline(ctx, state.spark_values[:])
			mu.layout_row(ctx, {-1}, 28)
			mu.progress_bar(ctx, state.progress)
			mu.layout_row(ctx, {-1}, 48)
			mu.callout(ctx, "Plots, editors and controls share one command renderer.", .INFO, .ACCENT)

		case:
			mu.layout_row(ctx, {-1}, 28)
			mu.badge(ctx, "CONNECTED", .SUCCESS)
			mu.layout_row(ctx, {-1}, 54)
			mu.callout(ctx, "Input is polled once and translated into microUI state.", .INFO, .ACCENT)
			mu.callout(ctx, "Custom TTF/OTF fonts are loaded into named font roles.", .CHECK, .SUCCESS)
			mu.callout(ctx, "The editor completes language keywords and local symbols.", .WARNING, .WARNING)
			mu.layout_row(ctx, {-1}, 20)
			mu.separator(ctx, "Icon buttons")
			mu.layout_row(ctx, {42, 42, 42, 42, 42, -1}, 38)
			_ = mu.icon_button(ctx, "play", .PLAY, true)
			_ = mu.icon_button(ctx, "pause", .PAUSE)
			_ = mu.icon_button(ctx, "copy", .COPY)
			_ = mu.icon_button(ctx, "settings", .SETTINGS)
			_ = mu.icon_button(ctx, "delete", .TRASH)
			mu.muted_label(ctx, "Vector icons")
		}
	}
}

plot_window :: proc(ctx: ^mu.Context) {
	if mu.window(ctx, "Interactive Plot", {394, 18, 1028, 352}, {.NO_CLOSE}) {
		mu.layout_row(ctx, {-1}, 32)
		mu.heading(ctx, "Live signal inspector")
		mu.layout_row(ctx, {-1}, 24)
		mu.muted_label(ctx, "Move the pointer over the graph for the nearest sample and value")
		mu.layout_row(ctx, {-1}, -1)
		plot_options := mu.Plot_Options{
			auto_range = state.auto_range,
			min_value = -2,
			max_value = 2,
			show_grid = state.show_grid,
			show_fill = true,
			show_points = false,
			show_tooltip = true,
			grid_lines = 5,
			line_thickness = 2.25,
		}
		_, _ = mu.plot(ctx, "Amplitude", state.plot_values[:], plot_options)
	}
}

editor_window :: proc(ctx: ^mu.Context) {
	if mu.window(ctx, "Code Studio", {394, 388, 1028, 494}, {.NO_CLOSE}) {
		mu.layout_row(ctx, {430, -1}, 34)
		mu.heading(ctx, "Syntax-aware code editor")
		mu.layout_begin_column(ctx)
		mu.layout_row(ctx, {-1}, 28)
		old_language := state.language_index
		_ = mu.tab_bar(ctx, language_names[:], &state.language_index)
		if old_language != state.language_index {
			state.editor.language = mu.Code_Language(state.language_index)
		}
		mu.layout_end_column(ctx)

		mu.layout_row(ctx, {-1}, 24)
		mu.muted_label(ctx, "Ctrl+Space completion • Tab/Enter accept • Ctrl+C/X/V clipboard • Shift+arrows select")
		mu.layout_row(ctx, {-1}, -1)
		_ = mu.code_editor(ctx, &state.editor)
	}
}

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT, .MSAA_4X_HINT})
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "microUI Studio — Odin + Raylib 6")
	defer rl.CloseWindow()
	rl.SetTargetFPS(120)

	mu.init_raylib(&state.ui)
	defer mu.shutdown_raylib(&state.ui)
	mu.apply_theme(&state.ui, .MIDNIGHT)

	state.enabled = true
	state.show_grid = true
	state.auto_range = true
	state.check_a = true
	state.gain = 1
	state.frequency = 1
	state.radio_value = 1
	state.selected_combo = 2
	state.language_index = int(mu.Code_Language.ODIN)
	mu.code_editor_init(&state.editor, state.editor_buffer[:], default_source, .ODIN)
	mu.code_editor_set_completion_dictionary(&state.editor, custom_completion_words[:])

	for !rl.WindowShouldClose() {
		free_all(context.temp_allocator)
		if state.enabled do update_plot_data()

		mu.frame_begin(&state.ui)
		widget_gallery(&state.ui)
		plot_window(&state.ui)
		editor_window(&state.ui)

		background := mu.Color{8, 12, 18, 255}
		if state.theme_index == 1 {
			background = {226, 232, 240, 255}
		}
		mu.frame_end(&state.ui, background)
	}
}