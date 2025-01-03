module ModuleDownloader

import "std/parsers/toml.rl"; as toml
import "std/utils.rl"; as utils
import "std/system.rl"; as sys
import "std/colors.rl"; as clr

import "mgr/mgrutils.rl"; as mgru

let git_dirs = [];

@pub fn prefix_already_exists(import_loc, depname) {
    foreach f in sys::ls(import_loc) {
        if sys::isdir(f) && f.split("/").filter(|k|{k != "";}).back() == depname {
            return true;
        }
    }
    return false;
}

@pub @world
fn get(
    earlmgr_install_envvar,
    import_envvar,
    link) {

    let import_loc = env(import_envvar);

    mgru::log(f"dowloading: {link}", clr::Tfc.Green);

    let tmp_git_dir = "__earl-package." + str(utils::iota());
    $f"git clone {link} --depth=1 {tmp_git_dir}";
    $f"ls {tmp_git_dir}/config.toml" |> let config_file;

    if config_file == "" {
        $f"sudo rm -r {tmp_git_dir}";
        panic("no TOML file found!");
    }

    let config = toml::parse(config_file);

    if !config["config"] {
        $f"sudo rm -r {tmp_git_dir}";
        panic(f"no `config` section found in the TOML config for {link}");
    }

    if !config["config"].unwrap()["prefix"] {
        $f"sudo rm -r {tmp_git_dir}";
        panic(f"no `prefix` section found in the TOML config for {link}");
    }

    let import_prefix = config["config"]
                            .unwrap()["prefix"]
                            .unwrap();

    git_dirs.append((tmp_git_dir, import_prefix));

    let destination = import_loc+"/"+import_prefix;
    $f"sudo mv {tmp_git_dir} {destination}";

    if config["deps"] {
        foreach dep_prefix, dep_link in config["deps"].unwrap() {
            mgru::log(f"Gathering dependency [{dep_prefix}]...", clr::Tfc.Green);
            if !prefix_already_exists(import_loc, dep_prefix) {
                get(earlmgr_install_envvar, import_envvar, dep_link);
            }
            else {
                mgru::log(f"Dependency [{dep_prefix}] is already downloaded", clr::Tfc.Yellow);
            }
        }
    }

    mgru::log(f"Installed module: {import_prefix}", clr::Tfc.Green);
}

@pub @world
fn clean() {
    foreach d, p in git_dirs {
        $f"sudo rm -r {d}    # [{p}]";
    }
}
