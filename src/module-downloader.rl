module ModuleDownloader

import "std/parsers/toml.rl"; as toml
import "std/utils.rl"; as utils
import "std/system.rl"; as sys
import "std/colors.rl"; as clr

import "mgr/mgrutils.rl"; as mgru

let git_dirs = [];

fn gather_src_files(gitdir) {
    let files = sys::ls(gitdir);
    return files.filter(|f| {
        return f.split(".").rev()[0] == "rl";
    });
}

@pub @world
fn get(
    earlmgr_install_envvar,
    import_envvar,
    link) {
    mgru::log(f"dowloading: {link}", clr::Tfc.Green);

    let tmp_git_dir = "__earl-package." + str(utils::iota());
    $f"git clone {link} --depth=1 {tmp_git_dir}";
    $f"ls {tmp_git_dir}/config.toml" |> let config_file;

    if config_file == "" {
        $f"sudo rm -r {tmp_git_dir}";
        panic("no TOML file found!");
    }

    let config = toml::parse(config_file);
    let src_files = gather_src_files(tmp_git_dir);

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

    let destination = env(import_envvar)+"/"+import_prefix;
    $f"sudo mkdir -p {destination}";
    foreach f in src_files {
        $f"sudo cp {f} {destination}";
    }

    if config["deps"] {
        foreach dep_prefix, dep_link in config["deps"].unwrap() {
            mgru::log(f"Gathering dependency [{dep_prefix}]...", clr::Tfc.Green);
            get(earlmgr_install_envvar, import_envvar, dep_link);
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
