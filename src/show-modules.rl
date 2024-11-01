module ShowModules

import "std/system.rl"; as sys

@pub fn show(import_envvar) {
    let total_files = 0;
    let total_prefixes = 0;

    let location = env(import_envvar);
    foreach mod in sys::ls(location) {
        let prefix = mod.split("/").rev()[0];
        let files = sys::ls(mod);

        println(f"+ {prefix} [prefix] (", len(files), " files)");
        foreach f in files {
            let filename = f.split("/").rev()[0];
            println(f"|-- {filename} [module]");
        }
        println("*");

        total_prefixes += 1;
        total_files += len(files);
    }

    println(f"Prefixes: {total_prefixes}");
    println(f"Modules: {total_files}");
}
