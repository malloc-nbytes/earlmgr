module MgrUtils

import "std/colors.rl";

@pub fn log(msg, color) {
    println(color, msg, Colors::Te.Reset);
}
