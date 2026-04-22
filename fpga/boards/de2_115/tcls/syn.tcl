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

execute_flow -analysis_and_elaboration
# execute_flow -eda_synthesis
# execute_flow -compile
# execute_flow -implement
# execute_flow -recompile
# execute_flow -check_ios
# execute_flow -check_netlist
# execute_flow -compile_and_simulate
# execute_flow -signalprobe
# execute_flow -vqm_writer
# execute_flow -finalize
# execute_flow -eco
# execute_flow -generate_functional_sim_netlist
# execute_flow -export_database
# execute_flow -import_database
# execute_flow -incremental_compilation_export
# execute_flow -incremental_compilation_import
