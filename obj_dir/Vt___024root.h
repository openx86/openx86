// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vt.h for the primary calling header

#ifndef VERILATED_VT___024ROOT_H_
#define VERILATED_VT___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vt__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vt___024root final {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ t__DOT__b;
    CData/*0:0*/ __VactPhaseResult;
    CData/*0:0*/ __VinactPhaseResult;
    CData/*0:0*/ __VnbaPhaseResult;
    IData/*31:0*/ __VactIterCount;
    IData/*31:0*/ __VinactIterCount;
    IData/*31:0*/ __Vi;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggeredAcc;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlDelayScheduler __VdlySched;

    // INTERNAL VARIABLES
    Vt__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vt___024root(Vt__Syms* symsp, const char* namep);
    ~Vt___024root();
    VL_UNCOPYABLE(Vt___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
