# ZunVox, the More Intuitive SunVox Library for zig

### Story
I have a couple of sunvox project on hand, including the VOXCOM 1610 assembler and the Preset bank generator which these project are based on the [SunVox Library](https://warmplace.ru/soft/sunvox/sunvox_lib.php).The original library is not hard to use, as you can see, you can just load the dynamic/share library like shown, which is surprisingly simple for zig:

``` zig
pub fn main(){
    dll = try std.DynLib.open("sunvox");
    const audio_callback = dll.lookup(tsv_audio_callback, "sv_audio_callback");
    const audio_callback2 = dll.lookup(tsv_audio_callback2, "sv_audio_callback2");
    const open_slot = dll.lookup(tsv_open_slot, "sv_open_slot");
    const init = dll.lookup(tsv_init, "sv_init");
    // ... and ~80 more functions to go

    _ = init.?(0, 44100, 2, 0);
}

```

however, the concept of the library is a bit low level since you need to manually manage the slot and module IDs and keep track on the event change, while the negative error number can be thrown unexpectedly in any point of the function call if you used a wrong id or forget to lock the slot.

Thus, since my use of the SunVox library is to generate and manipulate modules, I decided to build a level of abstraction such that the library will be easier to use for simple application and ensure the reliability setting certain components of the modules and projects. If you need maximal performance, this **might not be** the library for you since this has a lot more overhead than the original library.

Similar to the original library, this library is **not thread safe**, so be aware if you use the library with multiple threads.

### Basics


