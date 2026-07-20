// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VT__SYMS_H_
#define VERILATED_VT__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vt.h"

// INCLUDE MODULE CLASSES
#include "Vt___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vt__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vt* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vt___024root                   TOP;

    // CONSTRUCTORS
    Vt__Syms(VerilatedContext* contextp, const char* namep, Vt* modelp);
    ~Vt__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
