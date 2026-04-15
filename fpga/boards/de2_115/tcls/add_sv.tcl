proc add_sv_files {dir} {
    foreach file [glob -nocomplain -directory $dir *.sv] {
        set_global_assignment -name SYSTEMVERILOG_FILE $file
    }

    # # add .svh
    # foreach file [glob -nocomplain -directory $dir *.svh] {
    #     set_global_assignment -name VERILOG_INCLUDE_FILE $file
    # }

    foreach subdir [glob -nocomplain -type d -directory $dir *] {
        add_sv_files $subdir
    }
}

add_sv_files "../../../rtl"
