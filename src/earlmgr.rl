#!/usr/bin/env earl

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

##############################
#       EARLMGR DRIVER       #
##############################

module EARLMgr

#############################
# BEGIN FIRST TIME SETUP
#############################

set_flag("-x");

#-- The environment variables that earlmgr needs to know for locations.
@const let EARLMGR_INSTALL_LOC_ENVVAR, EARLMGR_IMPORT_LOC_ENVVAR = (
    "EARLMGR_INSTALL_LOC",
    "EARLMGR_IMPORT_LOC",
);

let FIRST_TIME_SETUP = len(env(f"{EARLMGR_INSTALL_LOC_ENVVAR}")) == 0
    || len(env(f"{EARLMGR_IMPORT_LOC_ENVVAR}")) == 0;

import "std/script.rl"; as scr
import "std/system.rl"; as sys
import "std/io.rl"; as io
import "std/colors.rl"; as clr

@const let VERSION = "0.0.1";

#-- All of the required programs for setup.
@const let REQ_PROGRAMS = ["wget", "git", "earl"];

#-- The main, most up-to-date version link.
@const let EARLMGR_MAIN_LINK = "https://raw.githubusercontent.com/malloc-nbytes/earlmgr/refs/heads/main/src/earlmgr.rl";

#-- The required modules for earlmgr.
@const let EARLMGR_MODULE_LINKS = (
    "https://raw.githubusercontent.com/malloc-nbytes/earlmgr/refs/heads/main/src/mgrutils.rl",
    "https://raw.githubusercontent.com/malloc-nbytes/earlmgr/refs/heads/main/src/newprog.rl",
    "https://raw.githubusercontent.com/malloc-nbytes/earlmgr/refs/heads/main/src/templates.rl",
    "https://raw.githubusercontent.com/malloc-nbytes/earlmgr/refs/heads/main/src/update-mgr.rl",
    "https://raw.githubusercontent.com/malloc-nbytes/earlmgr/refs/heads/main/src/uninstall.rl",
    "https://raw.githubusercontent.com/malloc-nbytes/earlmgr/refs/heads/main/src/gen-documentation.rl",
    "https://raw.githubusercontent.com/malloc-nbytes/earlmgr/refs/heads/main/src/module-downloader.rl",
    "https://raw.githubusercontent.com/malloc-nbytes/earlmgr/refs/heads/main/src/module-remover.rl",
    "https://raw.githubusercontent.com/malloc-nbytes/earlmgr/refs/heads/main/src/show-modules.rl",
);

#-- Get the installation prefix from what is
#-- stored in the EARL installation.
@const let INSTALL_PREFIX = sys::cmdstr("earl --install-prefix")
                                .split(" ")
                                .rev()[0]
                                .filter(|s|{return s != '\n';});

#-- The location for the earlmgr script to reside.
@const let INSTALL_BIN_LOCATION = INSTALL_PREFIX+"/bin";

#-- The location for the required modules to reside.
@const let INSTALL_IMPORT_LOCATION = INSTALL_PREFIX+"/include/EARL";

fn log(msg, color) {
    println(color, msg, clr::Te.Reset);
}

@world fn install_earlmgr() {
    log("Installing earlmgr...", clr::Tfc.Green);

    let echo_cmd = f"echo \"export {EARLMGR_INSTALL_LOC_ENVVAR}={INSTALL_BIN_LOCATION}\" >> "+env("HOME")+"/.bashrc";

    log("Allow earlmgr to modify the bashrc with the following?", clr::Tfc.Green);
    println(f"    {echo_cmd}");
    let inp = input("[Y/n] > ");
    sleep(500000);

    if inp != "N" && inp != "n" && inp != "no" && inp != "No" {
        if len(inp) == 0 {
            log("Empty input, assuming `Yes`", clr::Tfc.Yellow);
        }
        $echo_cmd;
    }
    else {
        log(
            f"NOTE: The environment variable [export {EARLMGR_INSTALL_LOC_ENVVAR}={INSTALL_BIN_LOCATION}] must be set to use earlmgr",
            clr::Tfc.Yellow
        );
    }

    $f"sudo wget -P {INSTALL_BIN_LOCATION} {EARLMGR_MAIN_LINK}";
    $f"sudo mv -v {INSTALL_BIN_LOCATION}/earlmgr.rl {INSTALL_BIN_LOCATION}/earlmgr";
    $f"sudo chmod +x {INSTALL_BIN_LOCATION}/earlmgr";
    log("Done", clr::Tfc.Green);
    sleep(500000);
}

@world fn install_earlmgr_includes() {
    log("Installing earlmgr modules", clr::Tfc.Green);

    let echo_cmd = f"echo \"export {EARLMGR_IMPORT_LOC_ENVVAR}={INSTALL_IMPORT_LOCATION}\" >> "+env("HOME")+"/.bashrc";
    log("Allow earlmgr to modify the bashrc with the following?", clr::Tfc.Green);
    println(f"    {echo_cmd}");
    let inp = input("[Y/n] > ");
    sleep(500000);

    if inp != "N" && inp != "n" && inp != "no" && inp != "No" {
        if len(inp) == 0 {
            log("Empty input, assuming `Yes`", clr::Tfc.Yellow);
        }
        $echo_cmd;
    }
    else {
        log(
            f"NOTE: The environment variable [export {EARLMGR_IMPORT_LOC_ENVVAR}={INSTALL_IMPORT_LOCATION}] must be set to use earlmgr",
            clr::Tfc.Green
        );
    }
    log("Done", clr::Tfc.Green);
    sleep(500000);

    let mgr_loc = f"{INSTALL_IMPORT_LOCATION}/mgr";
    $f"sudo mkdir -p {mgr_loc}";

    foreach link in EARLMGR_MODULE_LINKS {
        log(f"Downloading: {link}", clr::Tfc.Yellow);
        $f"sudo wget -P {mgr_loc} {link}";
    }

    println("Done");
    sleep(500000);
}

@world fn check_installed_programs() {
    log("Checking prerequisites", clr::Tfc.Green);
    foreach p in REQ_PROGRAMS {
        println(f"    ...{p}");
        if !scr::program_exists(p) {
            panic(f"{p} is required for earlmgr");
        }
    }
    log("Ok", clr::Tfc.Green);
    sleep(500000);

    log("Checking StdLib", clr::Tfc.Green);

    let libs = sys::ls(f"{INSTALL_PREFIX}/include/EARL/std");
    if len(libs) <= 0 {
        panic("It seems that the StdLib is not installed. How did we get here?");
    }
    log("Ok", clr::Tfc.Green);

    sleep(500000);
}

fn create_hidden_file() {
    log("Creating hidden config file", clr::Tfc.Green);
    let path = env("HOME")+"/.earlmgr";
    $f"touch {path}";
    log("Done", clr::Tfc.Green);
    sleep(500000);
}

if FIRST_TIME_SETUP {
    log("========== THIS SCRIPT IS WIP! USE AT YOUR OWN RISK! ==========", clr::Tfc.Yellow);

    log("This seems to be the first time this script has been run.", clr::Tfc.Green);
    sleep(1000000);
    log("Some setup is required", clr::Tfc.Green);
    sleep(1000000);

    check_installed_programs();
    install_earlmgr();
    install_earlmgr_includes();
    create_hidden_file();
    log("Please open a new bash instance to refresh the environment and run `earlmgr`", clr::Tfc.Green);
    exit(0);
}

#############################
# END FIRST TIME SETUP
#############################

#############################
# BEGIN MAIN FUNCTIONALITY
#############################

# Need to import these here because these
# are not on the system on first launch of earlmgr.
import "mgr/newprog.rl"; as NP
import "mgr/templates.rl"; as TMPLTS
import "mgr/update-mgr.rl"; as UPTMGR
import "mgr/uninstall.rl"; as UNINST
import "mgr/gen-documentation.rl"; as DOCS
import "mgr/module-downloader.rl"; as MD
import "mgr/module-remover.rl"; as MR
import "mgr/show-modules.rl"; as SM

@world fn _help() {
    println("Usage: earlmgr -- [options]");
    println();
    println("Options:");
    println("    help                    Prints this message");
    println("    version                 Print the version information");
    println("    new                     Create a new EARL project");
    println("    uninstall               Uninstall earlmgr and all associated modules");
    println("    docs                    Download the EARL-language-reference");
    println("    update <remote|local>   Update earlmgr and all associated modules");
    println("    | where");
    println("    |   remote = get modules from the earlmgr github repository");
    println("    |   local = get modules from the current directory");
    println("    get <github_link>       Download an EARL module with dependencies");
    println("    remove <prefix>         Remove all EARL modules based on the prefix");
    println("    ls                      Show all installed EARL modules");
    exit(0);
}

@world fn version() {
    println(f"earlmgr v{VERSION}");
    exit(0);
}

@world fn handle_args(args) {
    match args[0] {
        "help" -> {
            _help();
        }
        "version" -> {
            version();
        }
        "ls" -> {
            SM::show(EARLMGR_IMPORT_LOC_ENVVAR);
        }
        "update" -> {
            if len(args) != 2  || (args[1] != "remote" && args[1] != "local") {
                println("expected either remote or local as a second argument");
                exit(1);
            }
            UPTMGR::update(
                args[1],
                EARLMGR_INSTALL_LOC_ENVVAR,
                EARLMGR_IMPORT_LOC_ENVVAR,
                EARLMGR_MAIN_LINK,
                EARLMGR_MODULE_LINKS
            );
        }
        "get" -> {
            if len(args) != 2 {
                println("expected a github link as second argument");
                exit(1);
            }
            MD::get(
                EARLMGR_INSTALL_LOC_ENVVAR,
                EARLMGR_IMPORT_LOC_ENVVAR,
                args[1]
            );
            MD::clean();
        }
        "remove" -> {
            if len(args) != 2 {
                println("expected an EARL module name as second argument");
                exit(1);
            }
            MR::remove(
                EARLMGR_INSTALL_LOC_ENVVAR,
                EARLMGR_IMPORT_LOC_ENVVAR,
                args[1]
            );
        }
        "uninstall" -> {
            UNINST::uninstall(
                EARLMGR_INSTALL_LOC_ENVVAR,
                EARLMGR_IMPORT_LOC_ENVVAR
            );
        }
        "docs" -> {
            DOCS::gen();
        }
        "new" -> {
            NP::new_proj();
        }
        _ -> {
            println("unknown argument `", args[0], "`");
        }
    }
    exit(0);
}

@world fn driver() {
    if len(argv()) <= 1 {
        _help();
    }

    handle_args(argv()[1:]);
}

driver();

