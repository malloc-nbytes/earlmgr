module ModuleRemover

import "std/system.rl"; as sys
import "std/colors.rl"; as clr

import "mgr/mgrutils.rl"; as mgru

@pub fn remove(
    earlmgr_install_envvar,
    import_envvar,
    module_prefix) {

    mgru::log(f"Uninstalling {module_prefix}", clr::Tfc.Green);

    let location = env(import_envvar)+"/"+module_prefix;
    let files = sys::ls(location);

    foreach f in files {
        mgru::log(f"Removing: {f}", clr::Tfc.Green);
        $f"sudo rm {f}";
    }
    $f"sudo rm -r {location}";

    mgru::log(f"Successfully removed all module files for {module_prefix}", clr::Tfc.Green);
}
