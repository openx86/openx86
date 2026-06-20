// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : lpt_env.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : UVM environment for chip_centronics_lpt
// ============================================================================

class lpt_env extends uvm_env;

    isa_agent     agt;
    lpt_scoreboard sb;
    lpt_coverage  cov;

    `uvm_component_utils(lpt_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = isa_agent::type_id::create("agt", this);
        sb  = lpt_scoreboard::type_id::create("sb", this);
        cov = lpt_coverage::type_id::create("cov", this);
        uvm_config_db#(uvm_object_wrapper)::set(this, "agt.sqr.main_phase", "default_sequence",
            random_stress_seq::get_type());
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.mon_ap.connect(sb.mon_export);
        agt.mon.mon_ap.connect(cov.analysis_export);
    endfunction

    function void reset(string kind = "");
        sb.reset();
    endfunction

endclass
