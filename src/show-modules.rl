module ShowModules

import "std/system.rl"; as sys
import "std/colors.rl"; as colors

let first_time = false;
let total_prefixes = 0;
let total_modules = 0;
let downloaded_modules = 0;

fn contains_rl(dir) {
    let lst = sys::get_all_files_by_ext(dir, "rl");
    return len(lst) > 0;
}

@world fn walk(loc, depth, import_envvar, concat_path) {
    let s, spaces = ("", "");
    for i in 0 to depth { s += "--"; spaces += "  "; }

    with name = loc.split("/").back() in

    if sys::isdir(loc) && name[0] != '.' {
        if depth == 0 && first_time {
            println("|");
        }
        else {
            first_time = true;
        }

        let contents = sys::ls(loc);
        let modules, prefixes = (0, 0);

        foreach f in contents {
            with parts = f.split(".") in
            if sys::isdir(f) && contains_rl(f) {
                prefixes += 1;
            }
            else if parts[len(parts)-1] == "rl" {
                modules += 1;
            }
        }

        let downloaded = depth == 0 && name != "std" && name != "mgr";
        let stdlib = depth == 0 && name == "std";
        let earlmgr = depth == 0 && name == "mgr";

        if downloaded {
            downloaded_modules += 1;
            print(colors::Tfc.Yellow);
        }
        else if earlmgr {
            print(colors::Tfc.Cyan);
        }
        else if depth == 0 {
            print(colors::Tfc.Blue);
        }

        println(
            colors::Te.Bold,
            colors::Te.Underline,
            f"|{s} {name} ({prefixes} sub-prefixes) ({modules} modules)",
            case downloaded of { true = " [third-party]"; _ = ""; },
            case stdlib of { true = " " + colors::Te.Invert + "[StdLib]"; _ = ""; },
            case earlmgr of { true = " " + colors::Te.Invert + "[EARLMgr]"; _ = ""; },
            colors::Te.Reset
        );
        total_prefixes += 1;
        foreach f in contents {
            walk(f, depth+1, import_envvar, concat_path+name+"/");
        }
    }
    else if name.split(".").back() == "rl" {
        println(
            f"|{s} {name} ..... ",
            colors::Te.Italic,
            f"import \"{concat_path}{name}\";",
            colors::Te.Reset
        );
        total_modules += 1;
    }
}

@pub @world
fn show(import_envvar) {
    let location = env(import_envvar);

    $"earl --is-portable" |> let portable;
    if portable == "YES" {
        println(
            colors::Te.Bold,
            colors::Te.Underline,
            "| [StdLib] builtin (due to EARL portable)",
            colors::Te.Reset,
            "\n|"
        );
    }

    foreach f in sys::ls(location) {
        walk(f, 0, import_envvar, "");
    }

    println(colors::Tfc.Cyan, f"\nTotal Prefixes: {total_prefixes}");
    println(f"Modules: {total_modules}");
    println(colors::Tfc.Yellow, f"Third-party Modules: {downloaded_modules}", colors::Te.Reset);
}
