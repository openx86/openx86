# Remove all SYSTEMVERILOG_FILE assignments
remove_all_global_assignments -name SYSTEMVERILOG_FILE

proc add_sv_files {dir} {
    foreach file [glob -nocomplain -directory $dir *.sv] {
        set_global_assignment -name SYSTEMVERILOG_FILE $file
    }

    foreach subdir [glob -nocomplain -type d -directory $dir *] {
        add_sv_files $subdir
    }
}

add_sv_files "../../../rtl"
