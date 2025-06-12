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

module GetModuleInfo

import "std/system.rl"; as sys
import "std/colors.rl";
import "std/parsers/toml.rl";
import "mgr/mgrutils.rl"; as utils

@pub fn get_module_info(modname: str, import_envvar: str): unit {
    if modname == "mgr" || modname == "std" {
        utils::log("built in", Colors::Tfc.Green);
        return;
    }

    let location = format(env(import_envvar), "/", modname);

    try {
        let toml_file = sys::get_all_files_by_ext(location, "toml")[0];
        let toml = TOML::parse(toml_file);
        foreach k, v in toml {
            println(k, ":");
            foreach i, j in v {
                println("  ", i, ": ", j);
            }
        }
    } catch e {
        utils::log("Could not get info on prefix: " + e, Colors::Tfc.Red);
        return;
    }
}
