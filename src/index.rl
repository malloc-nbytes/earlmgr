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

### This file is used to generate the documentation for the StdLib
### section of the EARL-language-reference.org/html. The parsing
### that happens is not human-friendly and can easily break!

#############################################################################
### RULES
#############################################################################
### There are two types of comments that this file looks for:
###   1. `###` sequence comment
###   2. `#--` docs comment
### To begin parsing a certain section, you start with the sequence comment.
### To parse the information on the section, you start with a docs comment.
### The available sequence sections are:
###   * Variable
###   * Function
###   * Enum
###   * Class
###   * Method
###   * Member
###   * End
###   * IGNORE
###  You end the section with a sequence comment `End`.
###  Variables are expected to have the following:
###    * Name
###    * Type
###    * Description
###  Functions are expected to have the following:
###    * Name
###    * Parameter(s)
###    * Returns
###    * Description
### Enums are expected to have the following:
###    * Name
###    * Parameter(s)
###    * Description
### Classes are expected to have the following:
###    * Name
###    * Parameter(s)
###    * Description
### Methods are expected to have the following:
###    * Name
###    * Parameter(s)
###    * Returns
###    * Description
### Members are expected to have the following:
###    * Name
###    * Type
###    * Description
### If a module is still being worked on and you do not want to add
### it to the docs yet, add `### IGNORE` at the top of the file and
### this script will ignore it.
### See files in std/ for examples on how to use these comments.

module Main

import "std/system.rl";
import "std/utils.rl";
import "std/io.rl";
import "std/datatypes/str.rl";
import "std/script.rl";

enum State {
    None,
    Variables,
    Functions,
    Methods,
    Members,
    Classes,
    Enums,
}

class Parameter [name, ty] {
    @pub let name, ty = (name, ty);

    @pub fn tostr() {
        return this.name + ": " + this.ty;
    }
}

class Function [] {
    @pub let name, returns, description = ("", "", "");
    @pub let parameters = [];

    @pub fn add_name(name) {
        this.name = name;
    }

    @pub fn add_param(param) {
        this.parameters.append(param);
    }

    @pub fn add_returns(returns) {
        this.returns = returns;
    }

    @pub fn add_description(desc) {
        this.description = description;
    }

    @pub fn addto_description(s) {
        this.description += s;
    }

    @pub fn dump() {
        print(this.name, "(");
        for i in 0 to len(this.parameters) {
            print(this.parameters[i].tostr());
            if i != len(this.parameters)-1 {
                print(", ");
            }
        }
        println(") -> ", this.returns);
        with lines = this.description.split("\n").filter(!= "")
        in for i in 0 to len(lines) {
            if i == 0 {
                println("└──", lines[i]);
            } else {
                println("   ", lines[i]);
            }
        }
        println("\n");
    }
}

class Class [] {
    @pub let name = "";
    @pub let description = "";
    @pub let params = [];
    @pub let methods = [];
    @pub let members = [];

    @pub fn add_name(name) {
        this.name = name;
    }

    @pub fn add_param(param) {
        this.params.append(param);
    }

    @pub fn addto_description(s) {
        this.description += s;
    }

    @pub fn add_method(m) {
        this.methods.append(m);
    }

    @pub fn add_member(m) {
        this.members.append(m);
    }

    @pub fn dump() {
        print(this.name, "[");
        for i in 0 to len(this.params) {
            print(this.params[i].tostr());
            if i != len(this.params)-1 {
                print(", ");
            }
        }
        println("]");
        # println("└──", this.description, "\n");
        with lines = this.description.split("\n").filter(!= "")
        in for i in 0 to len(lines) {
            if i == 0 {
                println("└──", lines[i]);
            } else {
                println("   ", lines[i]);
            }
        }
        println("\n");
    }
}

class Variable [] {
    @pub let name = "";
    @pub let ty = "";
    @pub let description = "";

    @pub fn dump() {
        println(this.name, ": ", this.ty);
        with lines = this.description.split("\n").filter(!= "")
        in for i in 0 to len(lines) {
            if i == 0 {
                println("└──", lines[i]);
            } else {
                println("   ", lines[i]);
            }
        }
        println("\n");
    }

    @pub fn add_name(name) {
        this.name = name;
    }

    @pub fn add_type(ty) {
        this.ty = ty;
    }

    @pub fn addto_description(s) {
        this.description += s;
    }
}

class Enum [] {
    @pub let name = "";
    @pub let items = [];
    @pub let description = "";

    @pub fn add_name(name) {
        this.name = name;
    }

    @pub fn add_param(item) {
        this.items.append(item);
    }

    @pub fn addto_description(s) {
        this.description += s;
    }

    @pub fn dump() {
        println(this.name, " {");
        for i in 0 to len(this.items) {
            print("    ", this.items[i].tostr());
            if i != len(this.items)-1 {
                print(",");
            }
            println();
        }
        println("}");
        with lines = this.description.split("\n").filter(!= "")
        in for i in 0 to len(lines) {
            if i == 0 {
                println("└──", lines[i]);
            } else {
                println("   ", lines[i]);
            }
        }
        println("\n");
    }
}

class Entry [import_, mod, classes, functions, enums, variables] {
    @pub let import_ = import_;
    @pub let mod = mod;
    @pub let classes = classes;
    @pub let functions = functions;
    @pub let enums = enums;
    @pub let variables = variables;
}

fn commit(
    @ref state,
    @ref cur_item,
    @const @ref variables,
    @const @ref functions,
    @const @ref enums,
    @const @ref classes,
    @const @ref methods,
    @const @ref members,
    @ref cur_class,
    mod) {

    assert(cur_item);

    if state == State.Variables {
        print("(Variable) ", f"{mod}::");
        cur_item.unwrap().dump();
        variables.append(cur_item.unwrap());
        state = State.None;
        cur_item = none;
    }
    else if state == State.Functions {
        print("(Function) ", f"{mod}::");
        cur_item.unwrap().dump();
        functions.append(cur_item.unwrap());
        state = State.None;
        cur_item = none;
    }
    else if state == State.Enums {
        print("(Enum) ", f"{mod}::");
        cur_item.unwrap().dump();
        enums.append(cur_item.unwrap());
        state = State.None;
        cur_item = none;
    }
    else if state == State.Classes {
        print("(Class) ", f"{mod}::");
        cur_item.unwrap().dump();
        foreach m in methods { cur_item.unwrap().add_method(m); }
        foreach m in members { cur_item.unwrap().add_member(m); }
        classes.append(cur_item.unwrap());
        state = State.None;
        cur_item = none;
    }
    else if state == State.Methods {
        print("(Method) ", f"{mod}::", cur_class.unwrap().name, ".");
        cur_item.unwrap().dump();
        methods.append(cur_item.unwrap());
        state = State.Classes;
        cur_item = cur_class;
    }
    else if state == State.Members {
        print("(Member) ", f"{mod}::", cur_item.unwrap().name, ".");
        cur_member.unwrap().dump();
        members.append(cur_item.unwrap());
        state = State.Classes;
        cur_item = cur_class;
    }
}

fn index(lines, fp) {
    let state = State.None;
    let mod = "";
    let variables, functions, enums, classes = (
        [], [], [], [],
    );
    let methods, members = ([], []);
    let history = "";
    let cur_item = none;
    let cur_class = none;
    let desc_newline = false;

    let i = 0;
    while i < len(lines) {
        let line = lines[i];
        Str::trim(line);

        let parts = line.split(" ").filter(|s|{return s != "";});
        if parts[0] == "module" {
            if mod != "" {
                panic("duplicate module statements");
            }
            mod = parts[1];
        }
        else if parts[0] == "###" {
            if parts[1] == "IGNORE" {
                return none;
            }
            else if parts[1] == "Variable" {
                cur_item = some(Variable());
                state = State.Variables;
            }
            else if parts[1] == "Function" {
                cur_item = some(Function());
                state = State.Functions;
            }
            else if parts[1] == "Enum" {
                cur_item = some(Enum());
                state = State.Enums;
            }
            else if parts[1] == "Class" {
                cur_item = some(Class());
                state = State.Classes;
            }
            else if parts[1] == "Method" {
                cur_class = cur_item;
                cur_item = some(Function());
                state = State.Methods;
            }
            else if parts[1] == "Member" {
                cur_class = cur_item;
                cur_item = some(Variable());
                state = State.Members;
            }
            else if parts[1] == "End" {
                commit(state, cur_item, variables, functions, enums, classes, methods, members, cur_class, mod);
            }
            else {
                panic("unknown section: ", parts[1]);
            }
        }
        else if parts[0] == "#--" && len(parts) != 1 && cur_item {
            let right = parts[2:].fold(|s, acc|{return acc+' '+s;}, "");
            match parts[1] {
                "Name:" -> {
                    desc_newline = false;
                    Str::trim(right);
                    cur_item.unwrap().add_name(right);
                }
                "Type:" -> {
                    desc_newline = false;
                    Str::trim(right);
                    cur_item.unwrap().add_type(right);
                }
                "Parameter:" -> {
                    desc_newline = false;
                    let param_parts = right.split(":");
                    let name = param_parts[0];
                    let ty = "";
                    if len(param_parts) > 2 {
                        ty = param_parts[1:].fold(|s, acc|{return acc+':'+s;}, "");
                    }
                    else {
                        ty = param_parts[1];
                    }
                    Str::trim(name);
                    Str::trim(ty);
                    cur_item.unwrap().add_param(Parameter(name, ty));
                }
                "Returns:" -> {
                    desc_newline = false;
                    Str::trim(right);
                    cur_item.unwrap().add_returns(right);
                }
                "Description:" -> {
                    cur_item.unwrap().addto_description(right);
                    if len(right) > 0 {
                        desc_newline = true;
                    }
                }
                _ -> {
                    let s = "";
                    if len(parts) < 2 {
                        s = "";
                    }
                    else if desc_newline {
                        s = '\n'+parts[1]+right;
                    }
                    else {
                        s = parts[1]+right;
                        desc_newline = true;
                    }
                    cur_item.unwrap().addto_description(s);
                }
            }
        }

        i += 1;
    }

    if mod == "" {
        panic(f"file `{fp}` is missing a module statement");
    }

    return some((Entry(fp, mod, classes, functions, enums, variables), mod));
}

fn ready_input(fp) {
    let lines = IO::file_to_str(fp)
        .split("\n")
        .filter(|k|{return k != "";});
    return lines;
}

fn iterdir(path) {
    if System::isdir(path) {
        let files = [];
        foreach f in System::ls(path) {
            files += iterdir(f);
        }
        return files;
    }
    with parts = System::name_and_ext(path) in
    if parts[1] && parts[1].unwrap() == "rl" {
        return [path];
    }
    return [];
}

@pub fn gen_index(searchpaths: list) {
    $"earl --install-prefix" |> let main_prefix;
    let prefix = main_prefix.split("at ")[1];
    let paths = searchpaths.map(|p| { f"{prefix}/include/EARL/{p}"; });

    let modules = [];
    let entries = [];

    foreach docpath in paths {
        let files = iterdir(docpath);
        foreach f in files {
            println("############################################################");
            println(f"# Indexing {f}");
            println("############################################################\n");
            let lines = ready_input(f);
            let res = index(lines, f);
            if res {
                let entry, mod = res.unwrap();
                modules.append(mod);
                entries.append(entry);
            }
            else {
                println(f"file {f} has IGNORE tag, ignoring...");
            }
        }
    }

    println(f"Indexed the following modules");
    println(modules);
}
