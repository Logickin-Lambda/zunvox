const std = @import("std");
const builtin = @import("builtin");

const expectEqual = std.testing.expectEqual;

// ______________________________________________________________________________________________________________________
//                                                                                                                      /
// function table, types and Lookups                                                                                   /
// ___________________________________________________________________________________________________________________/
//
// They won't be exposed at the user level since the convention is not native to the user end.
// Users will use the functions as the type SunVox instead which is more idiomatic to zig practice.
//
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

// Here are the list of errors for the library, to replace the negative value used for the original library
// so that to provide a clearer ideas of what goes wrong with your projects
const SvError = error{
    FailedToInitizeGlobalSoundSystem,
    FailedToCraeteSunVoxInstance,
    MaximumInstancesExceeded,
};

/// The original library requires the user to specify the sunvox instance ID (aka slot_id)
/// created by the sv_init() function, but to prevent users accidentally modify the id,
/// this type is created.
const SunVoxPrivateField = struct {
    instance_id: u4, // The original library capped the number of slots at 16
};

const SunVoxVersion = packed union {
    raw: u32,
    detail: packed struct {
        bug_fix: u8,
        minor: u8,
        major: u16,
    },
};

var sv: SunVoxFunctionTable = undefined;
var dll: std.DynLib = undefined;
var instance_tracker = std.mem.zeroes([16]bool);

// ______________________________________________________________________________________________________________________
//                                                                                                                      /
// Public Functions                                                                                                    /
// ___________________________________________________________________________________________________________________/
//
// The following code are available from the user perspective, offering a more idiomatic experience to use the SunVox Lib:
//
/// To be defined
pub const Note = extern struct {
    note: u8,
    vel: u8,
    module: u16,
    ctl: u16,
    ctl_vel: u16,
};

/// This combines the original sv_load_dll() and sv_init() function because
/// these two functions are mandatory for putting the dynamic library in action
pub fn init(config: ?[]u8, freq: u16, channels: u16, flags: u32) !SunVoxVersion {
    dll = try std.DynLib.open("sunvox");
    sv = SunVoxFunctionTable{
        .sv_audio_callback = dll.lookup(tsv_audio_callback, "sv_audio_callback") orelse return error.Missing_tsv_audio_callback,
        .sv_audio_callback2 = dll.lookup(tsv_audio_callback2, "sv_audio_callback2") orelse return error.Missing_tsv_audio_callback2,
        .sv_open_slot = dll.lookup(tsv_open_slot, "sv_open_slot") orelse return error.Missing_tsv_open_slot,
        .sv_close_slot = dll.lookup(tsv_close_slot, "sv_close_slot") orelse return error.Missing_tsv_close_slot,
        .sv_lock_slot = dll.lookup(tsv_lock_slot, "sv_lock_slot") orelse return error.Missing_tsv_lock_slot,
        .sv_unlock_slot = dll.lookup(tsv_unlock_slot, "sv_unlock_slot") orelse return error.Missing_tsv_unlock_slot,
        .sv_init = dll.lookup(tsv_init, "sv_init") orelse return error.Missing_tsv_init,
        .sv_deinit = dll.lookup(tsv_deinit, "sv_deinit") orelse return error.Missing_tsv_deinit,
        .sv_get_sample_rate = dll.lookup(tsv_get_sample_rate, "sv_get_sample_rate") orelse return error.Missing_tsv_get_sample_rate,
        .sv_update_input = dll.lookup(tsv_update_input, "sv_update_input") orelse return error.Missing_tsv_update_input,
        .sv_load = dll.lookup(tsv_load, "sv_load") orelse return error.Missing_tsv_load,
        .sv_load_from_memory = dll.lookup(tsv_load_from_memory, "sv_load_from_memory") orelse return error.Missing_tsv_load_from_memory,
        .sv_save = dll.lookup(tsv_save, "sv_save") orelse return error.Missing_tsv_save,
        .sv_save_to_memory = dll.lookup(tsv_save_to_memory, "sv_save_to_memory") orelse return error.Missing_tsv_save_to_memory,
        .sv_play = dll.lookup(tsv_play, "sv_play") orelse return error.Missing_tsv_play,
        .sv_play_from_beginning = dll.lookup(tsv_play_from_beginning, "sv_play_from_beginning") orelse return error.Missing_tsv_play_from_beginning,
        .sv_stop = dll.lookup(tsv_stop, "sv_stop") orelse return error.Missing_tsv_stop,
        .sv_pause = dll.lookup(tsv_pause, "sv_pause") orelse return error.Missing_tsv_pause,
        .sv_resume = dll.lookup(tsv_resume, "sv_resume") orelse return error.Missing_tsv_resume,
        .sv_sync_resume = dll.lookup(tsv_sync_resume, "sv_sync_resume") orelse return error.Missing_tsv_sync_resume,
        .sv_set_autostop = dll.lookup(tsv_set_autostop, "sv_set_autostop") orelse return error.Missing_tsv_set_autostop,
        .sv_get_autostop = dll.lookup(tsv_get_autostop, "sv_get_autostop") orelse return error.Missing_tsv_get_autostop,
        .sv_end_of_song = dll.lookup(tsv_end_of_song, "sv_end_of_song") orelse return error.Missing_tsv_end_of_song,
        .sv_rewind = dll.lookup(tsv_rewind, "sv_rewind") orelse return error.Missing_tsv_rewind,
        .sv_volume = dll.lookup(tsv_volume, "sv_volume") orelse return error.Missing_tsv_volume,
        .sv_set_event_t = dll.lookup(tsv_set_event_t, "sv_set_event_t") orelse return error.Missing_tsv_set_event_t,
        .sv_send_event = dll.lookup(tsv_send_event, "sv_send_event") orelse return error.Missing_tsv_send_event,
        .sv_get_current_line = dll.lookup(tsv_get_current_line, "sv_get_current_line") orelse return error.Missing_tsv_get_current_line,
        .sv_get_current_line2 = dll.lookup(tsv_get_current_line2, "sv_get_current_line2") orelse return error.Missing_tsv_get_current_line2,
        .sv_get_current_signal_level = dll.lookup(tsv_get_current_signal_level, "sv_get_current_signal_level") orelse return error.Missing_tsv_get_current_signal_level,
        .sv_get_song_name = dll.lookup(tsv_get_song_name, "sv_get_song_name") orelse return error.Missing_tsv_get_song_name,
        .sv_set_song_name = dll.lookup(tsv_set_song_name, "sv_set_song_name") orelse return error.Missing_tsv_set_song_name,
        .sv_get_song_bpm = dll.lookup(tsv_get_song_bpm, "sv_get_song_bpm") orelse return error.Missing_tsv_get_song_bpm,
        .sv_get_song_tpl = dll.lookup(tsv_get_song_tpl, "sv_get_song_tpl") orelse return error.Missing_tsv_get_song_tpl,
        .sv_get_song_length_frames = dll.lookup(tsv_get_song_length_frames, "sv_get_song_length_frames") orelse return error.Missing_tsv_get_song_length_frames,
        .sv_get_song_length_lines = dll.lookup(tsv_get_song_length_lines, "sv_get_song_length_lines") orelse return error.Missing_tsv_get_song_length_lines,
        .sv_get_time_map = dll.lookup(tsv_get_time_map, "sv_get_time_map") orelse return error.Missing_tsv_get_time_map,
        .sv_new_module = dll.lookup(tsv_new_module, "sv_new_module") orelse return error.Missing_tsv_new_module,
        .sv_remove_module = dll.lookup(tsv_remove_module, "sv_remove_module") orelse return error.Missing_tsv_remove_module,
        .sv_connect_module = dll.lookup(tsv_connect_module, "sv_connect_module") orelse return error.Missing_tsv_connect_module,
        .sv_disconnect_module = dll.lookup(tsv_disconnect_module, "sv_disconnect_module") orelse return error.Missing_tsv_disconnect_module,
        .sv_load_module = dll.lookup(tsv_load_module, "sv_load_module") orelse return error.Missing_tsv_load_module,
        .sv_load_module_from_memory = dll.lookup(tsv_load_module_from_memory, "sv_load_module_from_memory") orelse return error.Missing_tsv_load_module_from_memory,
        .sv_sampler_load = dll.lookup(tsv_sampler_load, "sv_sampler_load") orelse return error.Missing_tsv_sampler_load,
        .sv_sampler_load_from_memory = dll.lookup(tsv_sampler_load_from_memory, "sv_sampler_load_from_memory") orelse return error.Missing_tsv_sampler_load_from_memory,
        .sv_sampler_par = dll.lookup(tsv_sampler_par, "sv_sampler_par") orelse return error.Missing_tsv_sampler_par,
        .sv_metamodule_load = dll.lookup(tsv_metamodule_load, "sv_metamodule_load") orelse return error.Missing_tsv_metamodule_load,
        .sv_metamodule_load_from_memory = dll.lookup(tsv_metamodule_load_from_memory, "sv_metamodule_load_from_memory") orelse return error.Missing_tsv_metamodule_load_from_memory,
        .sv_vplayer_load = dll.lookup(tsv_vplayer_load, "sv_vplayer_load") orelse return error.Missing_tsv_vplayer_load,
        .sv_vplayer_load_from_memory = dll.lookup(tsv_vplayer_load_from_memory, "sv_vplayer_load_from_memory") orelse return error.Missing_tsv_vplayer_load_from_memory,
        .sv_get_number_of_modules = dll.lookup(tsv_get_number_of_modules, "sv_get_number_of_modules") orelse return error.Missing_tsv_get_number_of_modules,
        .sv_find_module = dll.lookup(tsv_find_module, "sv_find_module") orelse return error.Missing_tsv_find_module,
        .sv_get_module_flags = dll.lookup(tsv_get_module_flags, "sv_get_module_flags") orelse return error.Missing_tsv_get_module_flags,
        .sv_get_module_inputs = dll.lookup(tsv_get_module_inputs, "sv_get_module_inputs") orelse return error.Missing_tsv_get_module_inputs,
        .sv_get_module_outputs = dll.lookup(tsv_get_module_outputs, "sv_get_module_outputs") orelse return error.Missing_tsv_get_module_outputs,
        .sv_get_module_type = dll.lookup(tsv_get_module_type, "sv_get_module_type") orelse return error.Missing_tsv_get_module_type,
        .sv_get_module_name = dll.lookup(tsv_get_module_name, "sv_get_module_name") orelse return error.Missing_tsv_get_module_name,
        .sv_set_module_name = dll.lookup(tsv_set_module_name, "sv_set_module_name") orelse return error.Missing_tsv_set_module_name,
        .sv_get_module_xy = dll.lookup(tsv_get_module_xy, "sv_get_module_xy") orelse return error.Missing_tsv_get_module_xy,
        .sv_set_module_xy = dll.lookup(tsv_set_module_xy, "sv_set_module_xy") orelse return error.Missing_tsv_set_module_xy,
        .sv_get_module_color = dll.lookup(tsv_get_module_color, "sv_get_module_color") orelse return error.Missing_tsv_get_module_color,
        .sv_set_module_color = dll.lookup(tsv_set_module_color, "sv_set_module_color") orelse return error.Missing_tsv_set_module_color,
        .sv_get_module_finetune = dll.lookup(tsv_get_module_finetune, "sv_get_module_finetune") orelse return error.Missing_tsv_get_module_finetune,
        .sv_set_module_finetune = dll.lookup(tsv_set_module_finetune, "sv_set_module_finetune") orelse return error.Missing_tsv_set_module_finetune,
        .sv_set_module_relnote = dll.lookup(tsv_set_module_relnote, "sv_set_module_relnote") orelse return error.Missing_tsv_set_module_relnote,
        .sv_get_module_scope2 = dll.lookup(tsv_get_module_scope2, "sv_get_module_scope2") orelse return error.Missing_tsv_get_module_scope2,
        .sv_module_curve = dll.lookup(tsv_module_curve, "sv_module_curve") orelse return error.Missing_tsv_module_curve,
        .sv_get_number_of_module_ctls = dll.lookup(tsv_get_number_of_module_ctls, "sv_get_number_of_module_ctls") orelse return error.Missing_tsv_get_number_of_module_ctls,
        .sv_get_module_ctl_name = dll.lookup(tsv_get_module_ctl_name, "sv_get_module_ctl_name") orelse return error.Missing_tsv_get_module_ctl_name,
        .sv_get_module_ctl_value = dll.lookup(tsv_get_module_ctl_value, "sv_get_module_ctl_value") orelse return error.Missing_tsv_get_module_ctl_value,
        .sv_set_module_ctl_value = dll.lookup(tsv_set_module_ctl_value, "sv_set_module_ctl_value") orelse return error.Missing_tsv_set_module_ctl_value,
        .sv_get_module_ctl_min = dll.lookup(tsv_get_module_ctl_min, "sv_get_module_ctl_min") orelse return error.Missing_tsv_get_module_ctl_min,
        .sv_get_module_ctl_max = dll.lookup(tsv_get_module_ctl_max, "sv_get_module_ctl_max") orelse return error.Missing_tsv_get_module_ctl_max,
        .sv_get_module_ctl_offset = dll.lookup(tsv_get_module_ctl_offset, "sv_get_module_ctl_offset") orelse return error.Missing_tsv_get_module_ctl_offset,
        .sv_get_module_ctl_type = dll.lookup(tsv_get_module_ctl_type, "sv_get_module_ctl_type") orelse return error.Missing_tsv_get_module_ctl_type,
        .sv_get_module_ctl_group = dll.lookup(tsv_get_module_ctl_group, "sv_get_module_ctl_group") orelse return error.Missing_tsv_get_module_ctl_group,
        .sv_new_pattern = dll.lookup(tsv_new_pattern, "sv_new_pattern") orelse return error.Missing_tsv_new_pattern,
        .sv_remove_pattern = dll.lookup(tsv_remove_pattern, "sv_remove_pattern") orelse return error.Missing_tsv_remove_pattern,
        .sv_get_number_of_patterns = dll.lookup(tsv_get_number_of_patterns, "sv_get_number_of_patterns") orelse return error.Missing_tsv_get_number_of_patterns,
        .sv_find_pattern = dll.lookup(tsv_find_pattern, "sv_find_pattern") orelse return error.Missing_tsv_find_pattern,
        .sv_get_pattern_x = dll.lookup(tsv_get_pattern_x, "sv_get_pattern_x") orelse return error.Missing_tsv_get_pattern_x,
        .sv_get_pattern_y = dll.lookup(tsv_get_pattern_y, "sv_get_pattern_y") orelse return error.Missing_tsv_get_pattern_y,
        .sv_set_pattern_xy = dll.lookup(tsv_set_pattern_xy, "sv_set_pattern_xy") orelse return error.Missing_tsv_set_pattern_xy,
        .sv_get_pattern_tracks = dll.lookup(tsv_get_pattern_tracks, "sv_get_pattern_tracks") orelse return error.Missing_tsv_get_pattern_tracks,
        .sv_get_pattern_lines = dll.lookup(tsv_get_pattern_lines, "sv_get_pattern_lines") orelse return error.Missing_tsv_get_pattern_lines,
        .sv_set_pattern_size = dll.lookup(tsv_set_pattern_size, "sv_set_pattern_size") orelse return error.Missing_tsv_set_pattern_size,
        .sv_get_pattern_name = dll.lookup(tsv_get_pattern_name, "sv_get_pattern_name") orelse return error.Missing_tsv_get_pattern_name,
        .sv_set_pattern_name = dll.lookup(tsv_set_pattern_name, "sv_set_pattern_name") orelse return error.Missing_tsv_set_pattern_name,
        .sv_get_pattern_data = dll.lookup(tsv_get_pattern_data, "sv_get_pattern_data") orelse return error.Missing_tsv_get_pattern_data,
        .sv_set_pattern_event = dll.lookup(tsv_set_pattern_event, "sv_set_pattern_event") orelse return error.Missing_tsv_set_pattern_event,
        .sv_get_pattern_event = dll.lookup(tsv_get_pattern_event, "sv_get_pattern_event") orelse return error.Missing_tsv_get_pattern_event,
        .sv_pattern_mute = dll.lookup(tsv_pattern_mute, "sv_pattern_mute") orelse return error.Missing_tsv_pattern_mute,
        .sv_get_ticks = dll.lookup(tsv_get_ticks, "sv_get_ticks") orelse return error.Missing_tsv_get_ticks,
        .sv_get_ticks_per_second = dll.lookup(tsv_get_ticks_per_second, "sv_get_ticks_per_second") orelse return error.Missing_tsv_get_ticks_per_second,
        .sv_get_log = dll.lookup(tsv_get_log, "sv_get_log") orelse return error.Missing_tsv_get_log,
    };

    const result = sv.sv_init(if (config) |cfg| cfg.ptr else 0, @intCast(freq), @intCast(channels), @intCast(flags));

    if (result > 0) {
        return SunVoxVersion{ .raw = @intCast(result) };
    } else {
        return SvError.FailedToInitizeGlobalSoundSystem;
    }
}

pub fn deinit() void {
    // Build a collection for tracking the active sunvox instance for removal

    dll.close();
}

// Here is the main instance:
pub fn SunVox() type {
    return struct {
        const Self = @This();
        _private: SunVoxPrivateField = undefined,

        pub fn createInstance() SvError!Self {
            for (0..instance_tracker.len) |i| {
                if (!instance_tracker[i]) {
                    instance_tracker[i] = true;
                    if (sv.sv_open_slot(@intCast(i)) < 0) {
                        return SvError.FailedToCraeteSunVoxInstance;
                    }
                    return Self{ ._private = .{ .instance_id = @intCast(i) } };
                }
            }
            return SvError.MaximumInstancesExceeded;
        }
    };
}

test "init sunvox library" {
    const version = try init(null, 44100, 2, 0);
    defer deinit();
    try expectEqual(2, version.detail.major);
    try expectEqual(1, version.detail.minor);
    try expectEqual(2, version.detail.bug_fix);

    const instance = try SunVox().createInstance();
    const instance_b = try SunVox().createInstance();
    const instance_c = try SunVox().createInstance();

    // validate the instance (slot) ID; however, the use of _private in your
    // project is strongly discouraged because it will cause instance tracking
    // to fail, causing improper behavior on destroying the instances.
    try expectEqual(0, instance._private.instance_id);
    try expectEqual(1, instance_b._private.instance_id);
    try expectEqual(2, instance_c._private.instance_id);

    var active_cnt: usize = 0;
    for (instance_tracker) |state| {
        active_cnt += if (state) 1 else 0;
    }
    try expectEqual(3, active_cnt);
}
