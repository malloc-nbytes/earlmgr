module ShowModules

import "std/system.rl"; as sys

let first_time = false;
let total_prefixes = 0;
let total_modules = 0;

@world fn walk(loc, depth, import_envvar) {
    let s, spaces = ("", "");
    for i in 0 to depth { s += "--"; spaces += "  "; }

    with name = loc.split("/").back() in

    if sys::isdir(loc) {
        if depth == 0 && first_time {
            println("|");
        }
        else {
            first_time = true;
        }

        let contents = sys::ls(loc);
        let modules, prefixes = (0, 0);

        foreach f in contents {
            if sys::isdir(f) {
                prefixes += 1;
            }
            else {
                modules += 1;
            }
        }

        println(f"|{s}{name}/ [Prefix] ({prefixes} sub-prefixes) ({modules} modules)");
        total_prefixes += 1;
        foreach f in contents {
            walk(f, depth+1, import_envvar);
        }
    }
    else {
        println(f"|{s}{name} [Module]");
        total_modules += 1;
    }
}

@pub @world
fn show(import_envvar) {
    let location = env(import_envvar);

    foreach f in sys::ls(location) {
        walk(f, 0, import_envvar);
    }

    println(f"\nTotal Prefixes: {total_prefixes}");
    println(f"Modules: {total_modules}");
}
