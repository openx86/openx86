// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vt.h for the primary calling header

#include "Vt__pch.h"

void Vt___024root___ctor_var_reset(Vt___024root* vlSelf);

Vt___024root::Vt___024root(Vt__Syms* symsp, const char* namep)
    : __VdlySched{*symsp->_vm_contextp__}
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vt___024root___ctor_var_reset(this);
}

void Vt___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vt___024root::~Vt___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
