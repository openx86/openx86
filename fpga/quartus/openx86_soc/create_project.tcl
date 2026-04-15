# ============================================================================
# Quartus TCL: create/update project from sim/filelists/rtl.f
# ============================================================================
#
# Usage (from repo root):
#   quartus_sh -t fpga/quartus/openx86_soc/create_project.tcl
#
# What it does:
# - Creates (or opens) the `openx86_soc` project in this directory
# - Imports sources and include/search paths from `sim/filelists/rtl.f`
# - Sets TOP_LEVEL_ENTITY = soc_top
# - Applies generic timing constraints from fpga/boards/generic/constraints.sdc
#
# Notes:
# - Board-specific pin assignments are intentionally NOT provided here.
# - Customize by copying fpga/boards/generic -> fpga/boards/<your_board>.
#

package require ::quartus::project

set script_dir [file dirname [info script]]
set repo_root  [file normalize [file join $script_dir .. .. ..]]

set proj_name  "openx86_soc"
set proj_dir   $script_dir
set filelist   [file join $repo_root sim filelists rtl.f]
set sdc_file   [file join $repo_root fpga boards generic constraints.sdc]

if {![file exists $filelist]} {
    post_message -type error "Missing filelist: $filelist"
    exit 2
}

cd $proj_dir

if {[project_exists $proj_name]} {
    project_open -revision $proj_name $proj_name
} else {
    project_new -revision $proj_name $proj_name
}

set_global_assignment -name TOP_LEVEL_ENTITY soc_top
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY [file join $repo_root build quartus $proj_name]

# Parse filelist
set incdirs {}
set sources {}

set fp [open $filelist r]
while {[gets $fp line] >= 0} {
    set l [string trim $line]
    if {$l eq ""} { continue }
    if {[string match "#*" $l]} { continue }

    if {[string match "+incdir+*" $l]} {
        set dir [string range $l [string length "+incdir+"] end]
        set dir [string trim $dir]
        if {$dir ne ""} {
            lappend incdirs [file normalize [file join $repo_root $dir]]
        }
        continue
    }

    # Only import real sources (.sv); headers (.svh) should be picked up via SEARCH_PATH.
    if {[string match "*.sv" $l]} {
        lappend sources [file normalize [file join $repo_root $l]]
    }
}
close $fp

# Apply include/search paths
foreach d $incdirs {
    set_global_assignment -name SEARCH_PATH $d
}

# Apply sources
foreach f $sources {
    set_global_assignment -name SYSTEMVERILOG_FILE $f
}

# Apply constraints
if {[file exists $sdc_file]} {
    set_global_assignment -name SDC_FILE $sdc_file
} else {
    post_message -type warning "SDC not found: $sdc_file"
}

project_close

post_message -type info "OK: project '$proj_name' updated from $filelist"
exit 0

