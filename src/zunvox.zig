const std = @import("std");
const builtin = @import("builtin");
const assert = std.debug.assert;

const expectEqual = std.testing.expectEqual;

/// As long as the program encounter a data desync between the sunvox lib and the tracking type,
/// a panic will be fired because there is no simple way to recover the messed up mapping;
/// however, this error should only occur when the allocator cause an error which is rare.
const fatalErrorMsg = "Critical Memory Integrity Error";

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

// Module Lkup for creating the modules since sunvox passes strings instead of enums or index for module typing
fn getModuleTypeStr(module_type: ModuleType) []const u8 {
    return switch (module_type) {
        .@"Analog generator" => "Analog generator",
        .DrumSynth => "DrumSynth",
        .FM => "FM",
        .FMX => "FMX",
        .Generator => "Generator",
        .Input => "Input",
        .Kicker => "Kicker",
        .@"Vorbis player" => "Vorbis player",
        .Sampler => "Sampler",
        .SpectraVoice => "SpectraVoice",
        .Amplifier => "Amplifier",
        .Compressor => "Compressor",
        .@"DC Blocker" => "DC_Blocker",
        .Delay => "Delay",
        .Distortion => "Distortion",
        .Echo => "Echo",
        .EQ => "EQ",
        .FFT => "FFT",
        .Filter => "Filter",
        .@"Filter Pro" => "Filter Pro",
        .Flanger => "Flanger",
        .LFO => "LFO",
        .Loop => "Loop",
        .Modulator => "Modulator",
        .@"Pitch shifter" => "Pitch_shifter",
        .Reverb => "Reverb",
        .Smooth => "Smooth",
        .@"Vocal filter" => "Vocal filter",
        .Vibrato => "Vibrato",
        .Waveshaper => "Waveshaper",
        .ADSR => "ADSR",
        .Ctl2Note => "Ctl2Note",
        .Feedback => "Feedback",
        .Glide => "Glide",
        .GPIO => "GPIO",
        .MetaModule => "MetaModule",
        .MultiCtl => "MultiCtl",
        .MultiSynth => "MultiSynth",
        .Pitch2Ctl => "Pitch2Ctl",
        .@"Pitch Detector" => "Pitch_Detector",
        .Sound2Ctl => "Sound2Ctl",
        .Velocity2Ctl => "Velocity2Ctl",
        .Output => "Output",
    };
}

pub const SamplerProperties = enum(c_int) {
    LoopBeginPosition = 0,
    LoopDuration,
    LoopType,
    LoopReleaseFlag,
    Volume,
    Panning,
    Finetune,
    RelativeNote,
    StartPosition,
};

pub const SamplerLoopType = enum(c_int) {
    Forward = 0,
    PingPong,
};

pub const LoopReleaseFlag = enum(c_int) {
    None = 0,
    LoopFinishAfterRelease,
};

pub const SamplerParamValues = packed union {
    raw: c_int,
    loop_type: SamplerLoopType,
    loop_release_flag: LoopReleaseFlag,
};

pub const ModuleFlags = packed union {
    raw: u32,
    details: packed struct {
        is_exist: bool,
        is_generator: bool,
        is_effect: bool,
        is_muted: bool,
        is_bypassed: bool,
        _padding: u11,
        inputs_cnt: u8,
        outputs_cnt: u8,
    },
};

pub const ModuleLocation = packed union {
    raw: u32,
    axis: struct {
        x: u16,
        y: u16,
    },
};

pub const Color = packed union {
    raw: u32,
    col: struct {
        r: u8,
        g: u8,
        b: u8,
    },
};

pub const DetuneProperties = packed union {
    raw: u32,
    pitch: struct {
        rel: i16,
        fine: i16,
    },
};

pub const CurveType = enum(c_int) {
    curve1_note_to_vel = 0,
    curve2_vel_to_vel,
    curve3_note_to_pitch,
};

// Here are the list of errors for the library, to replace the negative value used for the original library
// so that to provide a clearer ideas of what goes wrong with your projects
const SvError = error{
    FailedToInitizeGlobalSoundSystem,
    FailedToCraeteSunVoxSlot,
    MaximumSlotExceeded,
    FailedToDestroySlot,
    SlotAlreadyDestroyed,
    FailedToObtainSampleRate,
    FailedToLockSlot,
    FailedToUnlockSlot,
    SlotAlreadyLocked,
    SlotAlreadyUnlocked,
    FailedToLoadProject,
    FailedToSaveProject,
    FailedToPlay,
    FailedToStop,
    FailedToCheckAutostopStatus,
    FailedToSetAutoStop,
    FailedToSetPlayheadPosition,
    OutOfRange,
    FailedToSetMasterVolume,
    FailedToSetProjectName,
    FailedToGetTempoInfo,
    FailedToChangeEventSendLatency,
    FailedToSetEvent,
    FailedToCreateModule,
    FailedToRemoveModule,
    FailedToConnectModule,
    FailedToDisconnectedModule,
    LockRequired,
    NotSampler,
    NotMetaModule,
    NotMultiSynth,
    FailedToLoadSample,
    SampleParameterNotFound,
    ModuleNotFound,
    FailedToCountModule,
    FailedToGetModuleFlag,
    FailedToSetModuleName,
    FailedToSetModuleLocation,
    FailedToSetModuleColor,
    FailedToSetModuleRelNote,
    FailedToSetModuleFinetune,
    FailedToAccessModuleCurve,
    ModuleNotSupported,
    WrongBufferLength,
};

/// The original library requires the user to specify the sunvox instance ID (aka slot_id)
/// created by the sv_init() function, but to prevent users accidentally modify the id,
/// this type is created.
const SlotPrivateField = struct {
    slot_id: c_int, // The original library capped the number of slots at 16
    is_locked: bool = false,
    active_module_list: std.AutoHashMap(c_int, *Module),
    allocator: std.mem.Allocator,
};

/// to prevent user modifying the private field which will corrupt the slot_state_list
/// which is used for tracking any available slots for the library, this opaque type
/// will hide the field for the SlotPrivateField stored in the
const SlotInfo = opaque {
    fn getSlotId(self: *SlotInfo) c_int {
        const private_field: *SlotPrivateField = @ptrCast(@alignCast(self));
        return private_field.slot_id;
    }

    fn isLocked(self: *SlotInfo) bool {
        const private_field: *SlotPrivateField = @ptrCast(@alignCast(self));
        return private_field.is_locked;
    }

    fn lock(self: *SlotInfo) void {
        const private_field: *SlotPrivateField = @ptrCast(@alignCast(self));
        private_field.is_locked = true;
    }

    fn unlock(self: *SlotInfo) void {
        const private_field: *SlotPrivateField = @ptrCast(@alignCast(self));
        private_field.is_locked = false;
    }

    fn registerModule(self: *SlotInfo, module_id: c_int, module: *Module) !void {
        const private_field: *SlotPrivateField = @ptrCast(@alignCast(self));
        try private_field.active_module_list.put(module_id, module);
    }

    fn removeModule(self: *SlotInfo, module_id: c_int) bool {
        const private_field: *SlotPrivateField = @ptrCast(@alignCast(self));
        return private_field.active_module_list.remove(module_id);
    }

    fn peekModule(self: *SlotInfo, module_id: c_int) ?*Module {
        const private_field: *SlotPrivateField = @ptrCast(@alignCast(self));
        return private_field.active_module_list.get(module_id);
    }

    fn clearModuleList(self: *SlotInfo) void {
        const private_field: *SlotPrivateField = @ptrCast(@alignCast(self));
        var iter = private_field.active_module_list.iterator();
        while (iter.next()) |entry| {
            self.getAllocator().destroy(@as(*ModulePrivateField, @ptrCast(@alignCast(entry.value_ptr.*))));
            _ = self.removeModule(entry.key_ptr.*);
        }
    }

    fn getAllocator(self: *SlotInfo) std.mem.Allocator {
        const private_field: *SlotPrivateField = @ptrCast(@alignCast(self));
        return private_field.allocator;
    }
};

/// The objective of this library is to hide all the manual index for most of the functions,
const ModulePrivateField = struct {
    slot_info: *SlotInfo = undefined,
    module_id: c_int,
    module_type: ModuleType,
};

const ModuleInfo = opaque {};

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
var slot_state_list = std.mem.zeroes([16]bool);

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

/// I understand the naming convention is a bit... inconsistent,
/// but since we have used SunVox for a long time or at least long
/// enough before touching this library, we find some familiarity
/// with this convention, but this could easily causes typing mistakes;
/// thus, the ZunVox library will offer you an enum instead so that
/// the library handles the typing for you when you add a new module.
/// In addition, this enum set up works the best for mapping the
/// module type collected from the library.
pub const ModuleType = enum(u8) {
    // synths
    @"Analog generator" = 0,
    DrumSynth,
    FM,
    FMX,
    Generator,
    Input,
    Kicker,
    @"Vorbis player",
    Sampler,
    SpectraVoice,
    // effects
    Amplifier,
    Compressor,
    @"DC Blocker",
    Delay,
    Distortion,
    Echo,
    EQ,
    FFT,
    Filter,
    @"Filter Pro",
    Flanger,
    LFO,
    Loop,
    Modulator,
    @"Pitch shifter",
    Reverb,
    Smooth,
    @"Vocal filter",
    Vibrato,
    Waveshaper,
    // misc
    ADSR,
    Ctl2Note,
    Feedback,
    Glide,
    GPIO,
    MetaModule,
    MultiCtl,
    MultiSynth,
    Pitch2Ctl,
    @"Pitch Detector",
    Sound2Ctl,
    Velocity2Ctl,
    /// NON ASSIGNABLE", Only used for type check
    Output,
};

/// This combines the original sv_load_dll() and sv_init() function because
/// these two functions are mandatory for putting the dynamic library in action
pub fn init(config: ?[]u8, freq: u32, channels: u32, flags: u32) !SunVoxVersion {
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
    var is_active_instance_remains = false;
    for (slot_state_list) |state| {
        if (state) {
            std.log.err("Active SunVox Instances Found, Please Destroy All the Instance before deinit", .{});
            is_active_instance_remains = true;
            break;
        }
    }
    assert(!is_active_instance_remains);

    dll.close();
}

pub fn getSampleRate() !u32 {
    const result = sv.sv_get_sample_rate();
    if (result > 0) {
        return @intCast(result);
    } else {
        return SvError.FailedToObtainSampleRate;
    }
}

// The behavior of these functions is not known yet, so
// I am not going to write a wrapper function for now
// TODO: sv_update_input()
// TODO: sv_audio_callback()
// TODO: sv_audio_callback2()

// Here is the main instance:
pub const Slot = struct {
    const Self = @This();
    _info: *SlotInfo = undefined,
    // _allocator: std.mem.Allocator = undefined,
    Project: ProjectFn = ProjectFn{},
    Event: EventFn = EventFn{},

    // instance construction and destruction
    pub fn create(allocator: std.mem.Allocator) anyerror!Self {
        for (0..slot_state_list.len) |i| {
            if (!slot_state_list[i]) {
                if (sv.sv_open_slot(@intCast(i)) < 0) {
                    return SvError.FailedToCraeteSunVoxSlot;
                }
                slot_state_list[i] = true;

                var private_field = try allocator.create(SlotPrivateField);
                private_field.slot_id = @intCast(i);
                private_field.active_module_list = std.AutoHashMap(c_int, *Module).init(allocator);
                private_field.allocator = allocator;

                var slot = Self{};
                slot.setupSlot(@ptrCast(private_field));

                // set up module for empty project
                const output = try Module.opacifyWithID(slot._info, 0);
                try private_field.active_module_list.put(0, output);

                return slot;
            }
        }
        return SvError.MaximumSlotExceeded;
    }

    fn setupSlot(self: *Self, slot_info: *SlotInfo) void {
        self._info = slot_info;
        self.Project._info = slot_info;
        self.Event._info = slot_info;
    }

    pub fn destroy(self: Self) SvError!void {
        const slot_id = self._info.getSlotId();
        if (slot_state_list[@intCast(slot_id)]) {
            if (sv.sv_close_slot(slot_id) != 0) {
                return SvError.FailedToDestroySlot;
            }

            // Clear off the private object, and release the instance_tracker state to inactive
            const slot_info: *SlotPrivateField = @ptrCast(@alignCast(self._info));
            const allocator = slot_info.allocator;
            self._info.clearModuleList();
            slot_info.active_module_list.deinit();
            allocator.destroy(slot_info);
            slot_state_list[@intCast(slot_id)] = false;
        } else {
            return SvError.SlotAlreadyDestroyed;
        }
    }

    // lock/Unlock operations
    pub fn lock(self: *Self) SvError!void {
        if (self._info.isLocked()) {
            return SvError.SlotAlreadyLocked;
        } else if (sv.sv_lock_slot(self._info.getSlotId()) == 0) {
            self._info.lock();
        } else {
            return SvError.FailedToLockSlot;
        }
    }

    pub fn unlock(self: *Self) SvError!void {
        if (!self._info.isLocked()) {
            return SvError.SlotAlreadyUnlocked;
        } else if (sv.sv_unlock_slot(self._info.getSlotId()) == 0) {
            self._info.unlock();
        } else {
            return SvError.FailedToUnlockSlot;
        }
    }
};

// Operations related to projects:
const ProjectFn = struct {
    const Self = @This();
    _info: *SlotInfo = undefined,

    pub fn load(self: Self, file_path: []const u8) SvError!void {
        const result = sv.sv_load(self._info.getSlotId(), @constCast(file_path.ptr));
        if (result < 0) return SvError.FailedToLoadProject;
        self._info.clearModuleList();
        self.opacifyExistingModules() catch @panic("Critial Memory Integrity Error");
    }

    pub fn loadFromMemory(self: Self, data: []const u8) SvError!void {
        const result = sv.sv_load(self._info.getSlotId(), @constCast(data.ptr));
        if (result < 0) return SvError.FailedToLoadProject;
        self._info.clearModuleList();
        self.opacifyExistingModules() catch @panic("Critial Memory Integrity Error");
    }

    fn opacifyExistingModules(self: Self) !void {
        const largest_module_id = sv.sv_get_number_of_modules(self._info.getSlotId());

        for (0..@intCast(largest_module_id)) |i| {
            if (sv.sv_get_module_flags(self._info.getSlotId(), @intCast(i)) & 1 == 0) continue;
            const module = try Module.opacifyWithID(self._info, @intCast(i));
            try self._info.registerModule(@intCast(i), module);
        }
    }

    pub fn save(self: Self, file_name: []const u8) SvError!void {
        const result = sv.sv_save(self._info.getSlotId(), @constCast(file_name.ptr));
        if (result < 0) return SvError.FailedToSaveProject;
    }

    // TODO: Need to figure out how to destroy a chunk of memory create in shared library for save_memory()

    pub fn play(self: Self) SvError!void {
        const result = sv.sv_play(self._info.getSlotId());
        if (result < 0) return SvError.FailedToPlay;
    }

    pub fn playFromBeginning(self: Self) SvError!void {
        const result = sv.sv_play_from_beginning(self._info.getSlotId());
        if (result < 0) return SvError.FailedToPlay;
    }

    pub fn stop(self: Self, hardstop: bool) SvError!void {
        var result = sv.sv_stop(self._info.getSlotId());
        if (hardstop) {
            result += sv.sv_stop(self._info.getSlotId());
        }
        if (result < 0) {
            return SvError.FailedToStop;
        }
    }

    // TODO: sv_pause()
    // TODO: sv_resume()
    // TODO: sv_sync_resume()

    pub fn isAutostopEnabled(self: Self) SvError!bool {
        const result = sv.sv_get_autostop(self._info.getSlotId());
        if (result < 0) return SvError.FailedToCheckAutostopStatus;
        return if (result == 0) false else true;
    }

    pub fn setAutoStop(self: Self, isAutoStop: bool) SvError!void {
        const result = sv.sv_set_autostop(self._info.getSlotId(), if (isAutoStop) 1 else 0);
        if (result < 0) return SvError.FailedToSetAutoStop;
    }

    pub fn isStopped(self: Self) bool {
        const result = sv.sv_end_of_song(self._info.getSlotId());
        return if (result == 0) false else true;
    }

    pub fn getPlayheadPosition(self: Self) i32 {
        return sv.sv_get_current_line(self._info.getSlotId());
    }

    // TODO: we need a better presentation for sv_get_current_line2 before wrapping it as a function

    pub fn setPlayheadPosition(self: Self, playhead_index: i32) SvError!void {
        const result = sv.sv_rewind(self._info.getSlotId(), @intCast(playhead_index));
        if (result < 0) return SvError.FailedToSetPlayheadPosition;
    }

    pub fn setMasterVolume(self: Self, volume: u32) SvError!void {
        if (volume > 256) return SvError.OutOfRange;
        const result = sv.sv_volume(self._info.getSlotId(), @intCast(volume));
        if (result < 0) return SvError.FailedToSetMasterVolume;
    }

    pub fn getCurrentOutputSignalLevel(self: Self, channel: u32) u8 {
        return @intCast(sv.sv_get_current_signal_level(self._info.getSlotId(), @intCast(channel)));
    }

    pub fn getName(self: Self) ?[]const u8 {
        const result = sv.sv_get_song_name(self._info.getSlotId());
        if (result == null) return null;
        return std.mem.span(result);
    }

    pub fn setName(self: Self, name: []const u8) SvError!void {
        const result = sv.sv_set_song_name(self._info.getSlotId(), @ptrCast(name.ptr));
        if (result < 0) return SvError.FailedToSetProjectName;
    }

    pub fn getBPM(self: Self) SvError!u32 {
        return @intCast(sv.sv_get_song_bpm(self._info.getSlotId()));
    }

    pub fn getTPL(self: Self) SvError!u32 {
        return @intCast(sv.sv_get_song_tpl(self._info.getSlotId()));
    }

    pub fn getLengthBySamepleFrameCount(self: Self) SvError!u32 {
        return @intCast(sv.sv_get_song_length_frames(self._info.getSlotId()));
    }

    pub fn getLengthByLineCount(self: Self) SvError!u32 {
        return @intCast(sv.sv_get_song_length_lines(self._info.getSlotId()));
    }

    // TODO Need to know how sv_get_time_map() behaved and what kind of return type for better accessiblilty
};

const EventFn = struct {
    const Self = @This();
    _info: *SlotInfo = undefined,

    pub fn minimizeSendLatency(self: Self) SvError!void {
        const result = sv.sv_set_event_t(self._info.getSlotId(), 1, 0);
        if (result < 0) return SvError.FailedToChangeEventSendLatency;
    }

    pub fn autoSendLatency(self: Self) SvError!void {
        const result = sv.sv_set_event_t(self._info.getSlotId(), 0, 0);
        if (result < 0) return SvError.FailedToChangeEventSendLatency;
    }

    pub fn setSendLatency(self: Self, system_tick: i32) SvError!void {
        const result = sv.sv_set_event_t(self._info.getSlotId(), 0, @intCast(system_tick));
        if (result < 0) return SvError.FailedToChangeEventSendLatency;
    }

    pub fn sendFull(
        self: Self,
        event: struct {
            track: u8 = 0, // SunVox pattern only support 32 tracks, so u8 is sufficient
            note: u8 = 0,
            vel: u8 = 0,
            module: u16 = 0,
            ctl: packed union { raw: u16, div: struct { ee: u8, cc: u8 } } = .{ .raw = 0 },
            ctl_val: u16,
        },
    ) SvError!void {
        const result = sv.sv_send_event(
            self._info.getSlotId(),
            @intCast(event.track),
            @intCast(event.note),
            @intCast(event.vel),
            @intCast(event.module),
            @intCast(event.ctl.raw),
            @intCast(event.ctl_val),
        );

        if (result < 0) return SvError.FailedToSetEvent;
    }
};

pub const Module = opaque {
    /// turn module id into trackable reference type such that user can access module at high level
    fn opacify(slot_info: *SlotInfo, module_id: c_int, module_type: ModuleType) !*Module {
        var module_field = try slot_info.getAllocator().create(ModulePrivateField);
        module_field.module_id = module_id;
        module_field.module_type = module_type;
        module_field.slot_info = slot_info;

        const module: *Module = @ptrCast(@alignCast(module_field));
        try slot_info.registerModule(module_id, module);

        return module;
    }

    fn opacifyWithID(slot_info: *SlotInfo, module_id: c_int) !*Module {
        // Since we have ensured that module slot is not empty, unless there is an update while I haven't update the library,
        // ModuleType should covers all the possible built-in module type. User modules should only appeared as MetaModule.
        const module_type_str: []const u8 = std.mem.span(sv.sv_get_module_type(slot_info.getSlotId(), module_id));
        const module_type = std.meta.stringToEnum(ModuleType, module_type_str);
        if (module_type == null) return SvError.ModuleNotFound;

        return Module.opacify(slot_info, module_id, module_type.?) catch @panic(fatalErrorMsg);
    }

    pub fn new(slot: Slot, module_type: ModuleType, name: ?[]const u8, x: i32, y: i32, z_layers: u8) !*Module {
        if (!slot._info.isLocked()) return SvError.LockRequired;

        const result = sv.sv_new_module(
            0,
            @constCast(getModuleTypeStr(module_type).ptr),
            if (name) |n| @constCast(n.ptr) else @constCast(getModuleTypeStr(module_type).ptr),
            @intCast(x),
            @intCast(y),
            @intCast(z_layers),
        );

        if (result < 0) return SvError.FailedToCreateModule;

        return Module.opacify(slot._info, result, module_type) catch @panic(fatalErrorMsg);
    }

    pub fn load(slot: Slot, module_file_path: []const u8, x: i32, y: i32, z_layers: u8) SvError!*Module {
        const result = sv.sv_load_module(slot._info.getSlotId(), @ptrCast(module_file_path), x, y, z_layers);
        if (result < 0) return SvError.FailedToCreateModule;

        return Module.opacifyWithID(slot._info, result) catch @panic(fatalErrorMsg);
    }

    pub fn loadFromMemory(slot: Slot, data: []const u8, x: i32, y: i32, z_layers: u8) SvError!*Module {
        const result = sv.sv_load_module_from_memory(slot._info.getSlotId(), @ptrCast(data.ptr), @intCast(data.len), x, y, z_layers);
        if (result < 0) return SvError.FailedToCreateModule;

        return Module.opacifyWithID(slot._info, result) catch @panic(fatalErrorMsg);
    }

    pub fn fetchFromSlotByID(slot: Slot, module_id: u32) ?*Module {
        return slot._info.peekModule(@intCast(module_id));
    }

    pub fn getLargestModuleId(slot: Slot) !u32 {
        const result = sv.sv_get_number_of_modules(slot._info.getSlotId());
        if (result < 0) return SvError.FailedToCountModule;
    }

    pub fn getNumberOfModules(slot: Slot) !u32 {
        const info: *SlotPrivateField = @ptrCast(@alignCast(slot._info));
        return info.active_module_list.count();
    }

    pub fn findModuleByName(slot: Slot, module_name: []u8) ?*Module {
        const result = sv.sv_find_module(slot._info.isLocked(), @ptrCast(module_name.ptr));
        if (result >= 0) return slot._info.peekModule(result) else return null;
    }

    pub fn remove(self: *Module) !void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        if (!info.slot_info.isLocked()) return SvError.LockRequired;

        if (sv.sv_remove_module(info.slot_info.getSlotId(), info.module_id) < 0) return SvError.FailedToRemoveModule;
        _ = info.slot_info.removeModule(info.module_id);
        info.slot_info.getAllocator().destroy(info);
    }

    pub fn connect(self: *Module, target_module: *Module) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        const tar_info: *ModulePrivateField = @ptrCast(@alignCast(target_module));

        const result = sv.sv_connect_module(info.slot_info.getSlotId(), info.module_id, tar_info.module_id);
        if (result < 0) return SvError.FailedToConnectModule;
    }

    pub fn disconnect(self: *Module, target_module: *Module) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        const tar_info: *ModulePrivateField = @ptrCast(@alignCast(target_module));

        const result = sv.sv_disconnect_module(info.slot_info.getSlotId(), info.module_id, tar_info.module_id);
        if (result < 0) return SvError.FailedToDisconnectedModule;
    }

    pub fn getType(self: *Module) ModuleType {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        return info.module_type;
    }

    pub fn loadSample(self: *Module, sample_file_path: []const u8, sample_slot: u32) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        if (self.getType() != .Sampler) return SvError.NotSampler;
        const result = sv.sv_sampler_load(info.slot_info.getSlotId(), info.module_id, @ptrCast(sample_file_path.ptr), @intCast(sample_slot));

        if (result < 0) return SvError.FailedToLoadSample;
    }

    pub fn overrideAllSampleSlots(self: *Module, sample_file_path: []const u8) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        if (self.getType() != .Sampler) return SvError.NotSampler;
        const result = sv.sv_sampler_load(info.slot_info.getSlotId(), info.module_id, @ptrCast(sample_file_path.ptr), -1);

        if (result < 0) return SvError.FailedToLoadSample;
    }

    pub fn loadSampleFromMemory(self: *Module, data: []const u8, sample_slot: u32) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        if (self.getType() != .Sampler) return SvError.NotSampler;
        const result = sv.sv_sampler_load_from_memory(info.slot_info.getSlotId(), info.module_id, @ptrCast(data.ptr), @intCast(data.len), @intCast(sample_slot));

        if (result < 0) return SvError.FailedToLoadSample;
    }

    pub fn overrideAllSampleSlotsFromMemory(self: *Module, data: []const u8) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        if (self.getType() != .Sampler) return SvError.NotSampler;
        const result = sv.sv_sampler_load_from_memory(info.slot_info.getSlotId(), info.module_id, @ptrCast(data.ptr), @intCast(data.len), -1);

        if (result < 0) return SvError.FailedToLoadSample;
    }

    pub fn getSamplerParam(self: *Module, sample_slot: u32, param_type: SamplerProperties) SvError!SamplerParamValues {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        if (self.getType() != .Sampler) return SvError.NotSampler;

        const result = sv.sv_sampler_par(info.slot_info.getSlotId(), info.module_id, @intCast(sample_slot), @intFromEnum(param_type), 0, 0);
        return SamplerParamValues{ .raw = result };
    }

    pub fn setSamplerParam(self: *Module, sample_slot: u32, param_type: SamplerProperties, param_val: SamplerParamValues) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        if (self.getType() != .Sampler) return SvError.NotSampler;

        _ = sv.sv_sampler_par(info.slot_info.getSlotId(), info.module_id, @intCast(sample_slot), @intFromEnum(param_type), param_val.raw, 1);
    }

    pub fn loadProjectToMetaModule(self: *Module, sunvox_file_path: []const u8) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        if (self.getType() != .MetaModule) return SvError.NotMetaModule;

        const result = sv.sv_metamodule_load(info.slot_info.getSlotId(), info.module_id, @ptrCast(sunvox_file_path.ptr));
        if (result < 0) return SvError.FailedToLoadProject;
    }

    pub fn loadProjectToMetaModuleFromMemory(self: *Module, data: []const u8) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        if (self.getType() != .MetaModule) return SvError.NotMetaModule;

        const result = sv.sv_metamodule_load_from_memory(info.slot_info.getSlotId(), info.module_id, @ptrCast(data.ptr), @intCast(data.len));
        if (result < 0) return SvError.FailedToLoadProject;
    }

    pub fn getFlags(self: *Module) ModuleFlags {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        const result = sv.sv_get_module_flags(info.slot_info.getSlotId(), info.module_id);
        return ModuleFlags{ .raw = result };
    }

    pub fn getModuleInputs(self: *Module, allocator: std.mem.Allocator) ![]*Module {
        return self.getModulePorts(allocator, false);
    }

    pub fn getModuleOutputs(self: *Module, allocator: std.mem.Allocator) ![]*Module {
        return self.getModulePorts(allocator, true);
    }

    fn getModulePorts(self: *Module, allocator: std.mem.Allocator, isOutput: bool) ![]*Module {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        const port_cnt = if (isOutput) self.getFlags().details.outputs_cnt else self.getFlags().details.inputs_cnt;
        // if (port_cnt == 0) return null;

        var port_ptr: [*]c_int = undefined;
        if (isOutput) {
            port_ptr = @ptrCast(sv.sv_get_module_outputs(info.slot_info.getSlotId(), info.module_id));
        } else {
            port_ptr = @ptrCast(sv.sv_get_module_inputs(info.slot_info.getSlotId(), info.module_id));
        }

        var result = try allocator.alloc(*Module, self.countNumberOfModuleFromPort(port_ptr, port_cnt));
        var index: usize = 0;
        for (0..port_cnt) |i| {
            if (port_ptr[i] < 0) continue;
            result[index] = info.slot_info.peekModule(port_ptr[i]).?;
            index += 1;
        }

        return result;
    }

    fn countNumberOfModuleFromPort(_: *Module, input_ptr: [*]c_int, input_cnt: u8) usize {
        var cnt: usize = 0;
        for (0..input_cnt) |i| {
            if (input_ptr[i] >= 0) cnt += 1;
        }
        return cnt;
    }

    pub fn getName(self: *Module) ?[]const u8 {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));

        const result = sv.sv_get_module_name(info.slot_info.getSlotId(), info.module_id);
        if (result == null) return null;
        return std.mem.span(result);
    }

    pub fn setName(self: *Module, module_name: []const u8) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));

        const result = sv.sv_set_module_name(info.slot_info.getSlotId(), info.module_id, @ptrCast(module_name.ptr));
        if (result < 0) return SvError.FailedToSetModuleName;
    }

    pub fn getXY(self: *Module) ModuleLocation {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        return ModuleLocation{ .raw = sv.sv_get_module_xy(info.slot_info.getSlotId(), info.module_id) };
    }

    pub fn setXY(self: *Module, x: i32, y: i32) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        const result = sv.sv_set_module_xy(info.slot_info.getSlotId(), info.module_id, @intCast(x), @intCast(y));
        if (result < 0) return SvError.FailedToSetModuleLocation;
    }

    pub fn getColor(self: *Module) Color {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        return Color{ .raw = sv.sv_get_module_color(info.slot_info.getSlotId(), info.module_id) };
    }

    pub fn setColor(self: *Module, color: Color) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        const result = sv.sv_set_module_color(info.slot_info.getSlotId(), info.module_id, color.raw);
        if (result < 0) return SvError.FailedToSetModuleColor;
    }

    pub fn getDetuneProperties(self: *Module) DetuneProperties {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        return DetuneProperties{ .raw = sv.sv_get_module_finetune(info.slot_info.getSlotId(), info.module_id) };
    }

    pub fn setRelNote(self: *Module, rel_note: i16) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        const result = sv.sv_set_module_relnote(info.slot_info.getSlotId(), info.module_id, @intCast(rel_note));
        if (result < 0) return SvError.FailedToSetModuleRelNote;
    }

    pub fn setFinetune(self: *Module, finetune: i16) SvError!void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        const result = sv.sv_set_module_finetune(info.slot_info.getSlotId(), info.module_id, @intCast(finetune));
        if (result < 0) return SvError.FailedToSetModuleFinetune;
    }

    pub fn getScrope(self: *Module, channel: u32, out_buffer: []i16) u32 {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        const result = sv.sv_get_module_scope2(info.slot_info.getSlotId(), info.module_id, @intCast(channel), @constCast(out_buffer.ptr), @intCast(out_buffer.len));
        return @intCast(result);
    }

    pub fn getCurve(self: *Module, allocator: std.mem.Allocator, curve_type: ?CurveType) ![]f32 {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));
        var buffer: []f32 = undefined;

        switch (info.module_type) {
            .MultiSynth => {
                const auto_curve_type = if (curve_type) |ct| ct else CurveType.curve1_note_to_vel;
                switch (auto_curve_type) {
                    .curve1_note_to_vel => buffer = try allocator.alloc(f32, 128),
                    .curve2_vel_to_vel => buffer = try allocator.alloc(f32, 257),
                    .curve3_note_to_pitch => buffer = try allocator.alloc(f32, 128),
                }
            },
            .Waveshaper => buffer = try allocator.alloc(f32, 256),
            .MultiCtl => buffer = try allocator.alloc(f32, 257),
            .@"Analog generator" => buffer = try allocator.alloc(f32, 32),
            .FMX => buffer = try allocator.alloc(f32, 256),
            else => return SvError.ModuleNotSupported,
        }

        const curve_id: c_int = if (info.module_type != .MultiSynth) 0 else if (curve_type == null) 0 else @intCast(@intFromEnum(curve_type.?));
        const result = sv.sv_module_curve(info.slot_info.getSlotId(), info.module_id, curve_id, @ptrCast(buffer.ptr), @intCast(buffer.len), 0);
        if (result < 0) {
            allocator.free(buffer);
            return SvError.FailedToAccessModuleCurve;
        } else {
            return buffer;
        }
    }

    pub fn setCurve(self: *Module, curve_type: ?CurveType, curve_data: []f32) !void {
        const info: *ModulePrivateField = @ptrCast(@alignCast(self));

        switch (info.module_type) {
            .MultiSynth => {
                const auto_curve_type = if (curve_type) |ct| ct else CurveType.curve1_note_to_vel;
                switch (auto_curve_type) {
                    .curve1_note_to_vel => if (curve_data.len != 128) return SvError.WrongBufferLength,
                    .curve2_vel_to_vel => if (curve_data.len != 257) return SvError.WrongBufferLength,
                    .curve3_note_to_pitch => if (curve_data.len != 128) return SvError.WrongBufferLength,
                }
            },
            .Waveshaper => if (curve_data.len != 256) return SvError.WrongBufferLength,
            .MultiCtl => if (curve_data.len != 257) return SvError.WrongBufferLength,
            .@"Analog generator" => if (curve_data.len != 32) return SvError.WrongBufferLength,
            .FMX => if (curve_data.len != 256) return SvError.WrongBufferLength,
            else => return SvError.ModuleNotSupported,
        }

        const curve_id: c_int = if (info.module_type != .MultiSynth) 0 else if (curve_type == null) 0 else @intCast(@intFromEnum(curve_type.?));
        const result = sv.sv_module_curve(info.slot_info.getSlotId(), info.module_id, curve_id, @ptrCast(curve_data.ptr), @intCast(curve_data.len), 1);
        if (result < 0) return SvError.FailedToAccessModuleCurve;
    }
};

test "init sunvox library; create and destory SunVox Instances" {
    const version = try init(null, 44100, 2, 0);
    defer deinit();
    try expectEqual(2, version.detail.major);
    try expectEqual(1, version.detail.minor);
    try expectEqual(2, version.detail.bug_fix);

    // Validate Systemwise functions
    const sample_rate = try getSampleRate();
    try expectEqual(44100, sample_rate);

    // Create and Validate Slots
    const allocator = std.testing.allocator;

    const slot_a = try Slot.create(allocator);
    const slot_b = try Slot.create(allocator);
    const slot_c = try Slot.create(allocator);

    const err_msg = "Failed to destroy SunVox Slot";
    defer slot_a.destroy() catch @panic(err_msg);
    defer slot_b.destroy() catch @panic(err_msg);
    defer slot_c.destroy() catch @panic(err_msg);

    // validate the instance (slot) ID; however, the use of _private in your
    // project is strongly discouraged because it will cause instance tracking
    // to fail, causing improper behavior on destroying the instances.
    try expectEqual(0, slot_a._info.getSlotId());
    try expectEqual(1, slot_b._info.getSlotId());
    try expectEqual(2, slot_c._info.getSlotId());

    // the  SubModules should also have the same id; however, accessing these fuctions
    // by user shall be forbidden
    try expectEqual(slot_a._info.getSlotId(), slot_a.Project._info.getSlotId());
    try expectEqual(slot_b._info.getSlotId(), slot_b.Project._info.getSlotId());
    try expectEqual(slot_c._info.getSlotId(), slot_c.Project._info.getSlotId());

    var active_cnt: usize = 0;
    for (slot_state_list) |state| {
        active_cnt += if (state) 1 else 0;
    }
    try expectEqual(3, active_cnt);
}

test "project level function" {
    _ = try init(null, 44100, 2, 0);
    defer deinit();

    const allocator = std.testing.allocator;
    var slot = try Slot.create(allocator);
    defer slot.destroy() catch {};

    // These are the default sunvox project settings
    try expectEqual(125, slot.Project.getBPM());
    try expectEqual(6, slot.Project.getTPL());
    try expectEqual(0, slot.Project.getCurrentOutputSignalLevel(0));
    try expectEqual(32, slot.Project.getLengthByLineCount()); // default pattern on an empty project
    try expectEqual(0, slot.Project.getPlayheadPosition());

    try slot.Project.setPlayheadPosition(23);
    // SunVox Lib has latency for setting some of the functions and it is run in a differnt thread,
    // so make sure you have applied some delays or use their corresponding get functions to ensure
    // the control is properly set.
    std.Thread.sleep(1e9);
    try expectEqual(23, slot.Project.getPlayheadPosition());
}

// I actually want to turn this forum post into an actual feature
//
// Noties are instrument characters that assist you in placing and deleting them.
// White: Synth Notey
// Blue: Piano Notey
// Green: 2nd Synth Notey
// Turquoise: Xylo Notey (what)
// Red: Choir Notey
// Pink: Pad Notey
// Yellow: Bass Notey
// Orange: 2nd Bass Notey
// Cyan: Sound Notey (???)
// Green Yellow: Bass Kick Notey
// Green Blue: Bass Drum Notey (yep)
// Pink Red: Clap Notey
// Blue Turquoise: Cymbal Notey
// Green White: Hi-Hat Notey
// Green Red: Tiss Notey
// Pink Red: Snare Notey
// Noties are the most features in PixiTracker. Use them.
//
// Looks like this can be some kind of magical, generative synth patches.
// It would be cool if I can generate a patch by:
//
// const module: u32 = sunvox_slot.Notey(.yep).PLEASE_ANSWER_PLEASE();

test "Module Creation Test" {
    _ = try init(null, 44100, 2, 0);
    defer deinit();

    const allocator = std.testing.allocator;
    var slot = try Slot.create(allocator);
    defer slot.destroy() catch {};

    try std.testing.expectError(
        SvError.LockRequired,
        Module.new(slot, .Generator, "NOTEY", 0, 0, 1),
    );

    try slot.lock();
    const module = try Module.new(slot, .ADSR, "NOTEY", 0, 0, 1);
    try slot.unlock();

    try expectEqual(ModuleType.ADSR, module.getType());

    try slot.lock();
    module.remove() catch @panic("Failed To Remove Module");
    try slot.unlock();

    try expectEqual(0, slot._info.getSlotId());
}

test "Module Connection Test" {
    _ = try init(null, 44100, 2, 0);
    defer deinit();

    const allocator = std.testing.allocator;
    var slot = try Slot.create(allocator);
    defer slot.destroy() catch {};

    try slot.lock();

    const multi = try Module.new(slot, .MultiSynth, ">> Input", 0, 0, 1);
    const square = try Module.new(slot, .@"Analog generator", "Square", 96, 0, 1);
    const saw = try Module.new(slot, .@"Analog generator", "Saw", 96, 96, 1);
    const sine = try Module.new(slot, .@"Analog generator", "Sine", 96, 96 * 2, 1);
    const filter = try Module.new(slot, .@"Filter Pro", null, 96 * 2, 0, 1);
    const output = Module.fetchFromSlotByID(slot, 0).?;

    try multi.connect(square);
    try multi.connect(saw);
    try multi.connect(sine);

    try square.connect(filter);
    try saw.connect(filter);
    try sine.connect(filter);

    try filter.connect(output);

    const input_mods = try filter.getModuleInputs(allocator);
    defer allocator.free(input_mods);

    const output_mods = try filter.getModuleOutputs(allocator);
    defer allocator.free(output_mods);

    const target_result = [_]*Module{ square, saw, sine };
    for (input_mods, 0..) |module, i| {
        try expectEqual(target_result[i], module);
    }
    try expectEqual(1, output_mods.len);
    try expectEqual(output, output_mods[0]);
    try std.testing.expect(std.mem.eql(u8, "Square", square.getName().?));
}

test "Module Curve Test" {
    _ = try init(null, 44100, 2, 0);
    defer deinit();

    const allocator = std.testing.allocator;
    var slot = try Slot.create(allocator);
    defer slot.destroy() catch {};

    try slot.lock();

    const drawn = try Module.new(slot, .@"Analog generator", "drawn wave test", 0, 0, 1);

    var curve = try drawn.getCurve(allocator, null);
    defer allocator.free(curve);

    for (0..curve.len) |i| {
        curve[i] = @sin(@as(f32, @floatFromInt(i)) / 16.0 * std.math.pi);
    }

    try drawn.setCurve(null, curve);

    const curve_new = try drawn.getCurve(allocator, null);
    defer allocator.free(curve_new);

    for (curve, curve_new) |elements, elements_new| {
        // floating point error, so I let the function pass if the overall contour is same
        try std.testing.expect(@abs(elements - elements_new) < 0.01);
    }
}
