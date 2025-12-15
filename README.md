# ZunVox, A More Intuitive SunVox Library Written In zig

### Todo:
- [x] Address the random segmentation fault during the first build to the project (Fixed, missing sv_deinit() should be the original cause)
- [ ] An async controller queue to ensure the controller parameter being update before project save. (zig 0.16.0 features required)
- [ ] More os support (currently windows, mac, and x86_64 Linux)
- [ ] Enable the Audio Callback and any other missing functions
- [ ] Replace function parameters and return type more idiomatic to zig.

### Story
I have a couple of sunvox project on hand, including the VOXCOM 1610 assembler and the Preset bank generator which these projects are based on the [SunVox Library](https://warmplace.ru/soft/sunvox/sunvox_lib.php).The original library is not hard to use, as you can see, you can just load the dynamic/share library like shown, which is surprisingly simple for zig:

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

however, the design of the original library is a bit low level since you need to manually manage the slot and module IDs and keep track on the event change, while the negative error number can be thrown unexpectedly in any point of the function call if you used a wrong id or forget to lock the slot.

Thus, since my use of the SunVox library is to generate and manipulate modules, I decided to build a level of abstraction such that the library will be easier to use for simple application and ensure the reliability setting certain components of the modules and projects. If you need maximal performance, this **might not be** the library for you since this has a lot more overhead than the original library.

Similar to the original library, this library is **not thread safe**, so be aware if you use the library with multiple threads.

### Basics
To build the library, you need to import the dependency as shown:

``` zig
const zunvox = b.dependency("zunvox", .{});
exe.root_module.addImport("zunvox", zunvox.module("zunvox"));

// install the original dynamic library into your project
@import("zunvox").installSunVoxBinary(&exe.step, zunvox, .bin);
```

With the set up above, when you compile the library, the share library (.so/.dll) will be installed into the destination binary folder. To use the library, simply import zunvox like shown to initialize the library:

``` zig
const std = @import("std");
const zunvox = @import("zunvox");

pub fn main() !void {
    _ = try zunvox.init(null, 44100, 2, 0);
    defer zunvox.deinit();

    // your code...
}
```

To load a project, you need to create a slot, and since ZunVox have automatically manage the slot id, you don't need to remember the id when calling the function, as long as you have kept a reference to the slot:
``` zig
var arena = std.heap.ArenaAllocator.init(std.heap.smp_allocator);
arena.deinit();

var slot = try zunvox.Slot.create(arena.allocator());
defer slot.destroy() catch @panic("failed to destroy slot");

try slot.Project.load("demo_track.sunvox");
try slot.Project.playFromBeginning();

std.Thread.sleep(20e9);
```

Creating a module is also easy, and all you need to do is to create a module object by calling Module.new(), you may connect to any modules existed from the project which 
you need to fetch the module type with a module ID like shown:

``` zig
const multi = try Module.new(slot, .MultiSynth, ">> Input", 0, 0, 1);
const square = try Module.new(slot, .@"Analog generator", "Square", 96, 0, 1);
const saw = try Module.new(slot, .@"Analog generator", "Saw", 96, 96, 1);
const sine = try Module.new(slot, .@"Analog generator", "Sine", 96, 96 * 2, 1);
const filter = try Module.new(slot, .@"Filter Pro", null, 96 * 2, 0, 1);
const output = Module.fetchFromSlotByID(slot, 0).?; // getting the reference of the output module

// make connections, you many also use module.disconnect(module) for disconnection
try multi.connect(square);
try multi.connect(saw);
try multi.connect(sine);

try square.connect(filter);
try saw.connect(filter);
try sine.connect(filter);

try filter.connect(output);
```

As you can see, in the exception of fetching the existing modules from the loaded project, you no longer need to manually handle the id of various instance.

However, there are some conventions keeps in mind:

If the member functions contains an allocator, you must manually destroy the instance. This is because those objects are not frequently used, and there is no way to determine the array size at compile time. For example:
``` zig
const curve_new = try drawn.getCurve(allocator, null);
defer allocator.free(curve_new);
```

Some of the type are encapsulated in pack unions, and the reason behind the design is that it provides a handly way to convert type between a raw bit field and a separated; thus, if you encounter function with returning a union type, make sure are you use the flags/detail of the union instead of raw which is used for the library internally:

``` zig

// instead of doing this:
const flags = self.getFlags().raw;

// it is more preferred to do get the specific flags instead:
const is_muted = self.getFlags().details.is_muted;
```