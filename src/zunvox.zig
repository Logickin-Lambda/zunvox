const std = @import("std");

// function table and types
// They won't be exposed at the user level since the convention is not native to the user end.
// Users will use the functions as the type SunVox instead which is more idiomatic to zig practice.
const tsv_audio_callback = *const fn (buf: *anyopaque, frames: c_int, latency: c_int, out_time: c_uint) callconv(.c) c_int;
const tsv_audio_callback2 = *const fn (buf: *anyopaque, frames: c_int, latency: c_int, out_time: c_uint, in_type: c_int, in_channels: c_int, in_buf: *anyopaque) callconv(.c) c_int;
const tsv_open_slot = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_close_slot = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_lock_slot = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_unlock_slot = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_init = *const fn (config: [*c]u8, freq: c_int, channels: c_int, flags: c_uint) callconv(.c) c_int;
const tsv_deinit = *const fn () callconv(.c) c_int;
const tsv_get_sample_rate = *const fn () callconv(.c) c_int;
const tsv_update_input = *const fn () callconv(.c) c_int;
const tsv_load = *const fn (slot: c_int, name: [*c]u8) callconv(.c) c_int;
const tsv_load_from_memory = *const fn (slot: c_int, data: *anyopaque, data_size: c_uint) callconv(.c) c_int;
const tsv_save = *const fn (slot: c_int, name: [*c]u8) callconv(.c) c_int;
const tsv_save_to_memory = *const fn (slot: c_int, size: *usize) callconv(.c) *anyopaque;
const tsv_play = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_play_from_beginning = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_stop = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_pause = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_resume = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_sync_resume = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_set_autostop = *const fn (slot: c_int, autostop: c_int) callconv(.c) c_int;
const tsv_get_autostop = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_end_of_song = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_rewind = *const fn (slot: c_int, t: c_int) callconv(.c) c_int;
const tsv_volume = *const fn (slot: c_int, vol: c_int) callconv(.c) c_int;
const tsv_set_event_t = *const fn (slot: c_int, set: c_int, t: c_int) callconv(.c) c_int;
const tsv_send_event = *const fn (slot: c_int, track_num: c_int, note: c_int, vel: c_int, module: c_int, ctl: c_int, ctl_val: c_int) callconv(.c) c_int;
const tsv_get_current_line = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_get_current_line2 = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_get_current_signal_level = *const fn (slot: c_int, channel: c_int) callconv(.c) c_int;
const tsv_get_song_name = *const fn (slot: c_int) callconv(.c) [*c]u8;
const tsv_set_song_name = *const fn (slot: c_int, name: [*c]u8) callconv(.c) c_int;
const tsv_get_song_bpm = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_get_song_tpl = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_get_song_length_frames = *const fn (slot: c_int) callconv(.c) c_uint;
const tsv_get_song_length_lines = *const fn (slot: c_int) callconv(.c) c_uint;
const tsv_get_time_map = *const fn (slot: c_int, start_line: c_int, len: c_int, dest: *c_uint, flags: c_int) callconv(.c) c_int;
const tsv_new_module = *const fn (slot: c_int, type: [*c]u8, name: [*c]u8, x: c_int, y: c_int, z: c_int) callconv(.c) c_int;
const tsv_remove_module = *const fn (slot: c_int, mod_num: c_int) callconv(.c) c_int;
const tsv_connect_module = *const fn (slot: c_int, source: c_int, destination: c_int) callconv(.c) c_int;
const tsv_disconnect_module = *const fn (slot: c_int, source: c_int, destination: c_int) callconv(.c) c_int;
const tsv_load_module = *const fn (slot: c_int, file_name: [*c]u8, x: c_int, y: c_int, z: c_int) callconv(.c) c_int;
const tsv_load_module_from_memory = *const fn (slot: c_int, data: *anyopaque, data_size: c_uint, x: c_int, y: c_int, z: c_int) callconv(.c) c_int;
const tsv_sampler_load = *const fn (slot: c_int, mod_num: c_int, file_name: [*c]u8, sample_slot: c_int) callconv(.c) c_int;
const tsv_sampler_load_from_memory = *const fn (slot: c_int, mod_num: c_int, data: *anyopaque, data_size: c_uint, sample_slot: c_int) callconv(.c) c_int;
const tsv_sampler_par = *const fn (slot: c_int, mod_num: c_int, sample_slot: c_int, par: c_int, par_val: c_int, set: c_int) callconv(.c) c_int;
const tsv_metamodule_load = *const fn (slot: c_int, mod_num: c_int, file_name: [*c]u8) callconv(.c) c_int;
const tsv_metamodule_load_from_memory = *const fn (slot: c_int, mod_num: c_int, data: *anyopaque, data_size: c_uint) callconv(.c) c_int;
const tsv_vplayer_load = *const fn (slot: c_int, mod_num: c_int, file_name: [*c]u8) callconv(.c) c_int;
const tsv_vplayer_load_from_memory = *const fn (slot: c_int, mod_num: c_int, data: *anyopaque, data_size: c_uint) callconv(.c) c_int;
const tsv_get_number_of_modules = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_find_module = *const fn (slot: c_int, name: [*c]u8) callconv(.c) c_int;
const tsv_get_module_flags = *const fn (slot: c_int, mod_num: c_int) callconv(.c) c_uint;
const tsv_get_module_inputs = *const fn (slot: c_int, mod_num: c_int) callconv(.c) *c_int;
const tsv_get_module_outputs = *const fn (slot: c_int, mod_num: c_int) callconv(.c) *c_int;
const tsv_get_module_type = *const fn (slot: c_int, mod_num: c_int) callconv(.c) [*c]u8;
const tsv_get_module_name = *const fn (slot: c_int, mod_num: c_int) callconv(.c) [*c]u8;
const tsv_set_module_name = *const fn (slot: c_int, mod_num: c_int, name: [*c]u8) callconv(.c) c_int;
const tsv_get_module_xy = *const fn (slot: c_int, mod_num: c_int) callconv(.c) c_uint;
const tsv_set_module_xy = *const fn (slot: c_int, mod_num: c_int, x: c_int, y: c_int) callconv(.c) c_int;
const tsv_get_module_color = *const fn (slot: c_int, mod_num: c_int) callconv(.c) c_int;
const tsv_set_module_color = *const fn (slot: c_int, mod_num: c_int, color: c_int) callconv(.c) c_int;
const tsv_get_module_finetune = *const fn (slot: c_int, mod_num: c_int) callconv(.c) c_uint;
const tsv_set_module_finetune = *const fn (slot: c_int, mod_num: c_int, finetune: c_int) callconv(.c) c_int;
const tsv_set_module_relnote = *const fn (slot: c_int, mod_num: c_int, relative_note: c_int) callconv(.c) c_int;
const tsv_get_module_scope2 = *const fn (slot: c_int, mod_num: c_int, channel: c_int, dest_buf: *i16, samples_to_read: c_uint) callconv(.c) c_uint;
const tsv_module_curve = *const fn (slot: c_int, mod_num: c_int, curve_num: c_int, data: *f32, len: c_int, w: c_int) callconv(.c) c_int;
const tsv_get_number_of_module_ctls = *const fn (slot: c_int, mod_num: c_int) callconv(.c) c_int;
const tsv_get_module_ctl_name = *const fn (slot: c_int, mod_num: c_int, ctl_num: c_int) callconv(.c) [*c]u8;
const tsv_get_module_ctl_value = *const fn (slot: c_int, mod_num: c_int, ctl_num: c_int, scaled: c_int) callconv(.c) c_int;
const tsv_set_module_ctl_value = *const fn (slot: c_int, mod_num: c_int, ctl_num: c_int, val: c_int, scaled: c_int) callconv(.c) c_int;
const tsv_get_module_ctl_min = *const fn (slot: c_int, mod_num: c_int, ctl_num: c_int, scaled: c_int) callconv(.c) c_int;
const tsv_get_module_ctl_max = *const fn (slot: c_int, mod_num: c_int, ctl_num: c_int, scaled: c_int) callconv(.c) c_int;
const tsv_get_module_ctl_offset = *const fn (slot: c_int, mod_num: c_int, ctl_num: c_int) callconv(.c) c_int;
const tsv_get_module_ctl_type = *const fn (slot: c_int, mod_num: c_int, ctl_num: c_int) callconv(.c) c_int;
const tsv_get_module_ctl_group = *const fn (slot: c_int, mod_num: c_int, ctl_num: c_int) callconv(.c) c_int;
const tsv_new_pattern = *const fn (slot: c_int, clone: c_int, x: c_int, y: c_int, tracks: c_int, lines: c_int, icon_seed: c_int, name: [*c]u8) callconv(.c) c_int;
const tsv_remove_pattern = *const fn (slot: c_int, pat_num: c_int) callconv(.c) c_int;
const tsv_get_number_of_patterns = *const fn (slot: c_int) callconv(.c) c_int;
const tsv_find_pattern = *const fn (slot: c_int, name: [*c]u8) callconv(.c) c_int;
const tsv_get_pattern_x = *const fn (slot: c_int, pat_num: c_int) callconv(.c) c_int;
const tsv_get_pattern_y = *const fn (slot: c_int, pat_num: c_int) callconv(.c) c_int;
const tsv_set_pattern_xy = *const fn (slot: c_int, pat_num: c_int, x: c_int, y: c_int) callconv(.c) c_int;
const tsv_get_pattern_tracks = *const fn (slot: c_int, pat_num: c_int) callconv(.c) c_int;
const tsv_get_pattern_lines = *const fn (slot: c_int, pat_num: c_int) callconv(.c) c_int;
const tsv_set_pattern_size = *const fn (slot: c_int, pat_num: c_int, tracks: c_int, lines: c_int) callconv(.c) c_int;
const tsv_get_pattern_name = *const fn (slot: c_int, pat_num: c_int) callconv(.c) [*c]u8;
const tsv_set_pattern_name = *const fn (slot: c_int, pat_num: c_int, name: [*c]u8) callconv(.c) c_int;
const tsv_get_pattern_data = *const fn (slot: c_int, pat_num: c_int) callconv(.c) *Note;
const tsv_set_pattern_event = *const fn (slot: c_int, pat_num: c_int, track: c_int, line: c_int, nn: c_int, vv: c_int, mm: c_int, ccee: c_int, xxyy: c_int) callconv(.c) c_int;
const tsv_get_pattern_event = *const fn (slot: c_int, pat_num: c_int, track: c_int, line: c_int, column: c_int) callconv(.c) c_int;
const tsv_pattern_mute = *const fn (slot: c_int, pat_num: c_int, mute: c_int) callconv(.c) c_int;
const tsv_get_ticks = *const fn () callconv(.c) c_uint;
const tsv_get_ticks_per_second = *const fn () callconv(.c) c_uint;
const tsv_get_log = *const fn (size: c_int) callconv(.c) [*c]u8;

const SunVoxFunctionTable = struct {
    sv_audio_callback: tsv_audio_callback = undefined,
    sv_audio_callback2: tsv_audio_callback2 = undefined,
    sv_open_slot: tsv_open_slot = undefined,
    sv_close_slot: tsv_close_slot = undefined,
    sv_lock_slot: tsv_lock_slot = undefined,
    sv_unlock_slot: tsv_unlock_slot = undefined,
    sv_init: tsv_init = undefined,
    sv_deinit: tsv_deinit = undefined,
    sv_get_sample_rate: tsv_get_sample_rate = undefined,
    sv_update_input: tsv_update_input = undefined,
    sv_load: tsv_load = undefined,
    sv_load_from_memory: tsv_load_from_memory = undefined,
    sv_save: tsv_save = undefined,
    sv_save_to_memory: tsv_save_to_memory = undefined,
    sv_play: tsv_play = undefined,
    sv_play_from_beginning: tsv_play_from_beginning = undefined,
    sv_stop: tsv_stop = undefined,
    sv_pause: tsv_pause = undefined,
    sv_resume: tsv_resume = undefined,
    sv_sync_resume: tsv_sync_resume = undefined,
    sv_set_autostop: tsv_set_autostop = undefined,
    sv_get_autostop: tsv_get_autostop = undefined,
    sv_end_of_song: tsv_end_of_song = undefined,
    sv_rewind: tsv_rewind = undefined,
    sv_volume: tsv_volume = undefined,
    sv_set_event_t: tsv_set_event_t = undefined,
    sv_send_event: tsv_send_event = undefined,
    sv_get_current_line: tsv_get_current_line = undefined,
    sv_get_current_line2: tsv_get_current_line2 = undefined,
    sv_get_current_signal_level: tsv_get_current_signal_level = undefined,
    sv_get_song_name: tsv_get_song_name = undefined,
    sv_set_song_name: tsv_set_song_name = undefined,
    sv_get_song_bpm: tsv_get_song_bpm = undefined,
    sv_get_song_tpl: tsv_get_song_tpl = undefined,
    sv_get_song_length_frames: tsv_get_song_length_frames = undefined,
    sv_get_song_length_lines: tsv_get_song_length_lines = undefined,
    sv_get_time_map: tsv_get_time_map = undefined,
    sv_new_module: tsv_new_module = undefined,
    sv_remove_module: tsv_remove_module = undefined,
    sv_connect_module: tsv_connect_module = undefined,
    sv_disconnect_module: tsv_disconnect_module = undefined,
    sv_load_module: tsv_load_module = undefined,
    sv_load_module_from_memory: tsv_load_module_from_memory = undefined,
    sv_sampler_load: tsv_sampler_load = undefined,
    sv_sampler_load_from_memory: tsv_sampler_load_from_memory = undefined,
    sv_sampler_par: tsv_sampler_par = undefined,
    sv_metamodule_load: tsv_metamodule_load = undefined,
    sv_metamodule_load_from_memory: tsv_metamodule_load_from_memory = undefined,
    sv_vplayer_load: tsv_vplayer_load = undefined,
    sv_vplayer_load_from_memory: tsv_vplayer_load_from_memory = undefined,
    sv_get_number_of_modules: tsv_get_number_of_modules = undefined,
    sv_find_module: tsv_find_module = undefined,
    sv_get_module_flags: tsv_get_module_flags = undefined,
    sv_get_module_inputs: tsv_get_module_inputs = undefined,
    sv_get_module_outputs: tsv_get_module_outputs = undefined,
    sv_get_module_type: tsv_get_module_type = undefined,
    sv_get_module_name: tsv_get_module_name = undefined,
    sv_set_module_name: tsv_set_module_name = undefined,
    sv_get_module_xy: tsv_get_module_xy = undefined,
    sv_set_module_xy: tsv_set_module_xy = undefined,
    sv_get_module_color: tsv_get_module_color = undefined,
    sv_set_module_color: tsv_set_module_color = undefined,
    sv_get_module_finetune: tsv_get_module_finetune = undefined,
    sv_set_module_finetune: tsv_set_module_finetune = undefined,
    sv_set_module_relnote: tsv_set_module_relnote = undefined,
    sv_get_module_scope2: tsv_get_module_scope2 = undefined,
    sv_module_curve: tsv_module_curve = undefined,
    sv_get_number_of_module_ctls: tsv_get_number_of_module_ctls = undefined,
    sv_get_module_ctl_name: tsv_get_module_ctl_name = undefined,
    sv_get_module_ctl_value: tsv_get_module_ctl_value = undefined,
    sv_set_module_ctl_value: tsv_set_module_ctl_value = undefined,
    sv_get_module_ctl_min: tsv_get_module_ctl_min = undefined,
    sv_get_module_ctl_max: tsv_get_module_ctl_max = undefined,
    sv_get_module_ctl_offset: tsv_get_module_ctl_offset = undefined,
    sv_get_module_ctl_type: tsv_get_module_ctl_type = undefined,
    sv_get_module_ctl_group: tsv_get_module_ctl_group = undefined,
    sv_new_pattern: tsv_new_pattern = undefined,
    sv_remove_pattern: tsv_remove_pattern = undefined,
    sv_get_number_of_patterns: tsv_get_number_of_patterns = undefined,
    sv_find_pattern: tsv_find_pattern = undefined,
    sv_get_pattern_x: tsv_get_pattern_x = undefined,
    sv_get_pattern_y: tsv_get_pattern_y = undefined,
    sv_set_pattern_xy: tsv_set_pattern_xy = undefined,
    sv_get_pattern_tracks: tsv_get_pattern_tracks = undefined,
    sv_get_pattern_lines: tsv_get_pattern_lines = undefined,
    sv_set_pattern_size: tsv_set_pattern_size = undefined,
    sv_get_pattern_name: tsv_get_pattern_name = undefined,
    sv_set_pattern_name: tsv_set_pattern_name = undefined,
    sv_get_pattern_data: tsv_get_pattern_data = undefined,
    sv_set_pattern_event: tsv_set_pattern_event = undefined,
    sv_get_pattern_event: tsv_get_pattern_event = undefined,
    sv_pattern_mute: tsv_pattern_mute = undefined,
    sv_get_ticks: tsv_get_ticks = undefined,
    sv_get_ticks_per_second: tsv_get_ticks_per_second = undefined,
    sv_get_log: tsv_get_log = undefined,
};

// The following code are usable from the user perspective, offering a more idiomatic experience to use the SunVox Lib:
/// To be defined
const Note = struct {};

var sv: SunVoxFunctionTable = undefined;
var dll: std.DynLib = undefined;

/// This is the original load_dll() function, but because of the zig naming convention,
/// the sv_init() will be replaced by zv.SunVox.CreateInstance()
pub fn init() !void {
    dll = try std.DynLib.open("sunvox");
    sv = SunVoxFunctionTable{
        .sv_init = dll.lookup(tsv_init, "sv_init") orelse return error.MissingMethod,
    };
}

pub fn deinit() !void {
    dll.close();
    // Build a collection for tracking the active sunvox instance for removal

}

test "init sunvox library" {
    try init();

    const result = sv.sv_init(0, 44100, 2, 0);
    std.debug.print("SunVox Version: {x}", .{result});
}
