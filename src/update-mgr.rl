# MIT License

# Copyright (c) 2023 malloc-nbytes

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module UpdateEarl

import "std/system.rl"; as sys
import "std/io.rl"; as io
import "std/colors.rl"; as colors
import "std/parsers/toml.rl"; as toml
import "std/time.rl"; as time

import "mgr/module-downloader.rl"; as MD
import "mgr/mgrutils.rl"; as MGRU

fn update_toml(dir, import_envvar, earlmgr_install_envvar) {
    MGRU::log("Checking TOML changes...", colors::Tfc.Green);
    let import_loc = env(import_envvar);
    let config = toml::parse(dir+"/config.toml");

    if config["deps"] {
        foreach prefix, link in config["deps"].unwrap() {
            if !MD::prefix_already_exists(import_loc, prefix) {
                MGRU::log(f"Dep. `{prefix}` is new and will be downloaded", colors::Tfc.Yellow);
                MD::get(earlmgr_install_envvar, import_envvar, link);
            }
            else {
                MGRU::log(f"Prefix `{prefix}` is already downloaded", colors::Tfc.Green);
            }
        }
    }
}

fn update_third_party_modules(import_envvar, earlmgr_install_envvar) {
    let prefixes = sys::ls(env(import_envvar)).filter(|p| {
        with name = p.split("/").filter(|k|{k != "";}).back() in
        return name != "std" && name != "mgr";
    });

    with first = false in

    foreach dir in prefixes {
        if !sys::isdir(dir) { continue; }

        if first { println("|"); }
        else { first = true; }

        cd(dir);

        let name = dir.split("/").back();

        MGRU::log(f"| Checking: {name}", colors::Tfc.Green);

        $"git rev-parse --abbrev-ref HEAD" |> let current_branch;
        $"git fetch origin" |> let _;
        $f"git rev-parse {current_branch}" |> let local_commit;
        $f"git rev-parse origin/{current_branch}" |> let remote_commit;
        $f"git merge-base {current_branch} origin/{current_branch}" |> let base_commit;

        MGRU::log(f"| local hash: {local_commit}", colors::Tfc.White);
        MGRU::log(f"| remote hash: {remote_commit}", colors::Tfc.White);
        MGRU::log(f"| base hash: {base_commit}", colors::Tfc.White);

        if local_commit == remote_commit {
            MGRU::log(f"|-- Up to date.", colors::Tfc.Green + colors::Te.Bold);
            print(colors::Te.Reset);
        }
        else if local_commit == base_commit {
            MGRU::log(f"|<- Behind, pulling changes...", colors::Tfc.Yellow);
            $f"git pull";
            update_toml(dir, import_envvar, earlmgr_install_envvar);
            MGRU::log("Done", colors::Tfc.Green);
        }
        else if remote_commit == base_commit {
            MGRU::log(f"|-> Ahead of remote, either restore changes or push.", colors::Tfc.Yellow);
            println(f"    {dir}");
        }
        else {
            MGRU::log(f"|-x Diverged from the remote. Manual intervention needed...", colors::Tfc.Red);
            println(f"    {dir}");
        }
    }
}

#-- Name: update
#-- Param: update_type: str
#-- Param: earlmgr_install_envvar: str
#-- Param: import_envvar: str
#-- Param: main_link: str
#-- Param: module_links: list<str>
#-- Returns: unit
#-- Description: Updates the current installation of earlmgr as
#-- well as all the modules it requires.
@pub fn update(
    update_type,
    earlmgr_install_envvar,
    import_envvar,
    main_link,
    module_links) {

    assert(update_type == "remote" || update_type == "local" || update_type == "modules");

    if update_type == "modules" {
        update_third_party_modules(import_envvar, earlmgr_install_envvar);
        return;
    }

    set_flag("-x");

    let local_files = sys::ls(".").filter(|s|{return s != "./earlmgr.rl";});
    if update_type == "local" {
        # Make sure the user is in the repository.
        foreach f in local_files {
            let s = f.split(".").filter(|s|{return s != "";});
            if len(s) <= 1 || s.rev()[0] != "rl" {
                panic("Found a non .rl file. Are you in the correct directory?");
            }
        }
    }

    let earlmgr_loc = env(earlmgr_install_envvar);
    let modules_loc = env(import_envvar)+"/mgr/";
    let modules = sys::ls(modules_loc);

    if update_type == "remote" || update_type == "local" {
        println("Updating earlmgr");

        $f"sudo rm {earlmgr_loc}/earlmgr";
        foreach mod in modules {
            $f"sudo rm {mod}";
        }
    }

    if update_type == "remote" {
        $f"sudo wget -P {earlmgr_loc} {main_link}";
        $f"sudo mv {earlmgr_loc}/earlmgr.rl {earlmgr_loc}/earlmgr";
        $f"sudo chmod +x {earlmgr_loc}/earlmgr";
    }
    else if update_type == "local" {
        $f"sudo cp ./earlmgr.rl {earlmgr_loc}";
        $f"sudo mv {earlmgr_loc}/earlmgr.rl {earlmgr_loc}/earlmgr";
        $f"sudo chmod +x {earlmgr_loc}/earlmgr";
    }

    if update_type == "remote" {
        foreach link in module_links {
            $f"sudo wget -P {modules_loc} {link}";
        }
    }
    else if update_type == "local" {
        foreach f in local_files {
            $f"sudo cp {f} {modules_loc}";
        }
    }

    println("Done");
}


