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

module NewProj

import "std/system.rl";
import "mgr/templates.rl";

fn get_user_input(msg, possible) {
    while (1) {
        let inp = input(msg);
        if len(possible) == 0 {
            return inp;
        }
        for i in 0 to len(possible) {
            if inp == possible[i] {
                return possible[i];
            }
        }
        println("Invalid choice `", inp);
    }
}

@pub fn new_proj() {
    let name = get_user_input("Enter project name: ", []);
    let newdir = get_user_input("Create a new directory? [y/n] ", ["Y", "y", "N", "n"]);
    let create_changelog = get_user_input("Create a changelog? [y/n] ", ["Y", "y", "N", "n"]);
    let create_readme = get_user_input("Create a readme? [y/n] ", ["Y", "y", "N", "n"]);
    let init_git = get_user_input("Initialize a git repository? [y/n]", ["Y", "y", "N", "n"]);

    println("earlmgr uses a .toml configuration file to get appropriate");
    println("information to make an EARL compliant module. If you are intending");
    println("to have other people be able to download and use your module(s)");
    println("you should select `y`.");
    let create_toml = get_user_input("Make this an EARL compliant module? [y/n] ", ["Y", "y", "N", "n"]);

    let cwd = ".";

    if newdir == "Y" || newdir == "y" {
        System::mkdir(name);
        cwd = name;
    }

    let main_filename = "/main.rl";
    if create_toml == 'Y' || create_toml == 'y' {
        main_filename = "/my-module.rl";
        let toml_handle = open(cwd+"/config.toml", "w");
        toml_handle.write(Templates::toml_template);
        toml_handle.close();
    }
    let f1 = open(cwd+main_filename, "w");
    f1.write(Templates::main_template);
    f1.close();

    if create_changelog == 'Y' || create_changelog == 'y' {
        let f2 = open(cwd+"/CHANGELOG.md", "w");
        f2.write(Templates::changelog);
        f2.close();
    }

    if create_readme == 'Y' || create_readme == 'y' {
        let f3 = open(cwd+"/README.md", "w");
        f3.write(Templates::readme + name + "\n");
        f3.close();
    }

    if init_git == 'y' || init_git == 'Y' {
        $f"git init {cwd}";
    }

    println("Created new EARL project at `", cwd, "` with contents:");
    System::ls(cwd).foreach(|el| { println("  ", el); });
    if create_toml == 'y' || create_toml == 'Y' {
        println("Note: You selected to create an EARL compliant module.");
        println("      Make sure you configure your config.toml file!");
    }
}
