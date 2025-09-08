FN_LIST = [
    "typedef int (SUNVOX_FN_ATTR *tsv_audio_callback)( void* buf, int frames, int latency, uint32_t out_time );",
    "typedef int (SUNVOX_FN_ATTR *tsv_audio_callback2)( void* buf, int frames, int latency, uint32_t out_time, int in_type, int in_channels, void* in_buf );",
    "typedef int (SUNVOX_FN_ATTR *tsv_open_slot)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_close_slot)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_lock_slot)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_unlock_slot)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_init)( const char* config, int freq, int channels, uint32_t flags );",
    "typedef int (SUNVOX_FN_ATTR *tsv_deinit)( void );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_sample_rate)( void );",
    "typedef int (SUNVOX_FN_ATTR *tsv_update_input)( void );",
    "typedef int (SUNVOX_FN_ATTR *tsv_load)( int slot, const char* name );",
    "typedef int (SUNVOX_FN_ATTR *tsv_load_from_memory)( int slot, void* data, uint32_t data_size );",
    "typedef int (SUNVOX_FN_ATTR *tsv_save)( int slot, const char* name );",
    "typedef void* (SUNVOX_FN_ATTR *tsv_save_to_memory)( int slot, size_t* size );",
    "typedef int (SUNVOX_FN_ATTR *tsv_play)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_play_from_beginning)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_stop)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_pause)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_resume)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_sync_resume)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_autostop)( int slot, int autostop );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_autostop)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_end_of_song)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_rewind)( int slot, int t );",
    "typedef int (SUNVOX_FN_ATTR *tsv_volume)( int slot, int vol );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_event_t)( int slot, int set, int t );",
    "typedef int (SUNVOX_FN_ATTR *tsv_send_event)( int slot, int track_num, int note, int vel, int module, int ctl, int ctl_val );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_current_line)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_current_line2)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_current_signal_level)( int slot, int channel );",
    "typedef const char* (SUNVOX_FN_ATTR *tsv_get_song_name)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_song_name)( int slot, const char* name );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_song_bpm)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_song_tpl)( int slot );",
    "typedef uint32_t (SUNVOX_FN_ATTR *tsv_get_song_length_frames)( int slot );",
    "typedef uint32_t (SUNVOX_FN_ATTR *tsv_get_song_length_lines)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_time_map)( int slot, int start_line, int len, uint32_t* dest, int flags );",
    "typedef int (SUNVOX_FN_ATTR *tsv_new_module)( int slot, const char* type, const char* name, int x, int y, int z );",
    "typedef int (SUNVOX_FN_ATTR *tsv_remove_module)( int slot, int mod_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_connect_module)( int slot, int source, int destination );",
    "typedef int (SUNVOX_FN_ATTR *tsv_disconnect_module)( int slot, int source, int destination );",
    "typedef int (SUNVOX_FN_ATTR *tsv_load_module)( int slot, const char* file_name, int x, int y, int z );",
    "typedef int (SUNVOX_FN_ATTR *tsv_load_module_from_memory)( int slot, void* data, uint32_t data_size, int x, int y, int z );",
    "typedef int (SUNVOX_FN_ATTR *tsv_sampler_load)( int slot, int mod_num, const char* file_name, int sample_slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_sampler_load_from_memory)( int slot, int mod_num, void* data, uint32_t data_size, int sample_slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_sampler_par)( int slot, int mod_num, int sample_slot, int par, int par_val, int set );",
    "typedef int (SUNVOX_FN_ATTR *tsv_metamodule_load)( int slot, int mod_num, const char* file_name );",
    "typedef int (SUNVOX_FN_ATTR *tsv_metamodule_load_from_memory)( int slot, int mod_num, void* data, uint32_t data_size );",
    "typedef int (SUNVOX_FN_ATTR *tsv_vplayer_load)( int slot, int mod_num, const char* file_name );",
    "typedef int (SUNVOX_FN_ATTR *tsv_vplayer_load_from_memory)( int slot, int mod_num, void* data, uint32_t data_size );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_number_of_modules)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_find_module)( int slot, const char* name );",
    "typedef uint32_t (SUNVOX_FN_ATTR *tsv_get_module_flags)( int slot, int mod_num );",
    "typedef int* (SUNVOX_FN_ATTR *tsv_get_module_inputs)( int slot, int mod_num );",
    "typedef int* (SUNVOX_FN_ATTR *tsv_get_module_outputs)( int slot, int mod_num );",
    "typedef const char* (SUNVOX_FN_ATTR *tsv_get_module_type)( int slot, int mod_num );",
    "typedef const char* (SUNVOX_FN_ATTR *tsv_get_module_name)( int slot, int mod_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_module_name)( int slot, int mod_num, const char* name );",
    "typedef uint32_t (SUNVOX_FN_ATTR *tsv_get_module_xy)( int slot, int mod_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_module_xy)( int slot, int mod_num, int x, int y );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_module_color)( int slot, int mod_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_module_color)( int slot, int mod_num, int color );",
    "typedef uint32_t (SUNVOX_FN_ATTR *tsv_get_module_finetune)( int slot, int mod_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_module_finetune)( int slot, int mod_num, int finetune );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_module_relnote)( int slot, int mod_num, int relative_note );",
    "typedef uint32_t (SUNVOX_FN_ATTR *tsv_get_module_scope2)( int slot, int mod_num, int channel, int16_t* dest_buf, uint32_t samples_to_read );",
    "typedef int (SUNVOX_FN_ATTR *tsv_module_curve)( int slot, int mod_num, int curve_num, float* data, int len, int w );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_number_of_module_ctls)( int slot, int mod_num );",
    "typedef const char* (SUNVOX_FN_ATTR *tsv_get_module_ctl_name)( int slot, int mod_num, int ctl_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_module_ctl_value)( int slot, int mod_num, int ctl_num, int scaled );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_module_ctl_value)( int slot, int mod_num, int ctl_num, int val, int scaled );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_module_ctl_min)( int slot, int mod_num, int ctl_num, int scaled );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_module_ctl_max)( int slot, int mod_num, int ctl_num, int scaled );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_module_ctl_offset)( int slot, int mod_num, int ctl_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_module_ctl_type)( int slot, int mod_num, int ctl_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_module_ctl_group)( int slot, int mod_num, int ctl_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_new_pattern)( int slot, int clone, int x, int y, int tracks, int lines, int icon_seed, const char* name );",
    "typedef int (SUNVOX_FN_ATTR *tsv_remove_pattern)( int slot, int pat_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_number_of_patterns)( int slot );",
    "typedef int (SUNVOX_FN_ATTR *tsv_find_pattern)( int slot, const char* name );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_pattern_x)( int slot, int pat_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_pattern_y)( int slot, int pat_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_pattern_xy)( int slot, int pat_num, int x, int y );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_pattern_tracks)( int slot, int pat_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_pattern_lines)( int slot, int pat_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_pattern_size)( int slot, int pat_num, int tracks, int lines );",
    "typedef const char* (SUNVOX_FN_ATTR *tsv_get_pattern_name)( int slot, int pat_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_pattern_name)( int slot, int pat_num, const char* name );",
    "typedef sunvox_note* (SUNVOX_FN_ATTR *tsv_get_pattern_data)( int slot, int pat_num );",
    "typedef int (SUNVOX_FN_ATTR *tsv_set_pattern_event)( int slot, int pat_num, int track, int line, int nn, int vv, int mm, int ccee, int xxyy );",
    "typedef int (SUNVOX_FN_ATTR *tsv_get_pattern_event)( int slot, int pat_num, int track, int line, int column );",
    "typedef int (SUNVOX_FN_ATTR *tsv_pattern_mute)( int slot, int pat_num, int mute );",
    "typedef uint32_t (SUNVOX_FN_ATTR *tsv_get_ticks)( void );",
    "typedef uint32_t (SUNVOX_FN_ATTR *tsv_get_ticks_per_second)( void );",
    "typedef const char* (SUNVOX_FN_ATTR *tsv_get_log)( int size );",
]

TYPE_LKUP = {
    "int": "c_int",
    "int*": "*c_int",
    "uint32_t": "c_uint",
    "uint32_t*": "*c_uint",
    "int16_t*": "*i16",
    "size_t*": "*usize",
    "float": "f32",
    "float*": "*f32",
    "const char*": "[*c]u8",
    "sunvox_note*": "*Note",
    "void*": "*anyopaque",
}

def define_zig_fn_type(fn_type_raw:str) -> str:
    fn_type = fn_type_raw.strip().replace(")", "").replace(";", "")
    return_type = fn_type.replace("typedef", "").strip()
    return TYPE_LKUP[return_type]

def define_zig_fn_name(fn_name_raw:str):
    fn_name = fn_name_raw.strip().replace(")", "").replace(";", "")
    return fn_name.replace("SUNVOX_FN_ATTR", "").replace("*", "").strip()

def define_zig_fn_param(param_def_raw:str):
    param_def_list = param_def_raw.strip().replace(")", "").replace(";", "").split(",")
    formatted_param_list = []

    for param_def in param_def_list:
        param_def = param_def.strip()
        last_space_location = param_def.rfind(" ")

        if param_def.strip() == "void" and len(param_def_list) == 1:
            return "()"

        param_name = param_def[last_space_location+1:]
        param_type = param_def[0:last_space_location]

        formatted_param = f"{param_name}: {TYPE_LKUP[param_type]}"
        formatted_param_list.append(formatted_param)

    return f"({", ".join(formatted_param_list)})"

def main():

    zig_fn_type_list = []
    zig_fn_table_fn_list = []
    zig_fn_table_initialization_list = []
    
    for fn_def in FN_LIST:
        fn_type, fn_name, param_def = fn_def.split("(")

        zig_fn_type  = define_zig_fn_type(fn_type)
        zig_fn_name  = define_zig_fn_name(fn_name)
        zig_fn_param = define_zig_fn_param(param_def)

        zig_fn_type_def = f"const {zig_fn_name} = *const fn {zig_fn_param} callconv(.c) {zig_fn_type};"
        zig_fn_type_list.append(zig_fn_type_def)

        zig_fn_table_fn_def = f"{zig_fn_name[1:]}: {zig_fn_name} = undefined,"
        zig_fn_table_fn_list.append(zig_fn_table_fn_def)

        zig_fn_table_initialization = f".{zig_fn_name[1:]} = dll.lookup({zig_fn_name}, \"{zig_fn_name[1:]}\") orelse return error.Missing_{zig_fn_name},"
        zig_fn_table_initialization_list.append(zig_fn_table_initialization)

    with open("SunVox Function Definition.txt", "a") as f:
        f.seek(0)
        f.truncate()
        f.write("Exported Result:\n")
        f.write("DLL Function Type:\n\n")
        for zig_fn_type in zig_fn_type_list:
            f.write(f"{zig_fn_type}\n")

        f.write("\n")
        f.write("DLL Function Table:\n\n")
        f.write("const SunVoxFunctionTable = struct {\n")
        for zig_fn_table_fn in zig_fn_table_fn_list:
            f.write(f"    {zig_fn_table_fn}\n")
        f.write("};")

        f.write("\n")
        f.write("DLL Function Table Initialization:\n\n")
        for zig_fn_table_initialization in zig_fn_table_initialization_list:
            f.write(f"    {zig_fn_table_initialization}\n")


    f.close()


main()