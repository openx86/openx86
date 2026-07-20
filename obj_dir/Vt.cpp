// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vt__pch.h"

//============================================================
// Constructors

Vt::Vt(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vt__Syms(contextp(), _vcname__, this)}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vt::Vt(const char* _vcname__)
    : Vt(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vt::~Vt() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vt___024root___eval_debug_assertions(Vt___024root* vlSelf);
#endif  // VL_DEBUG
void Vt___024root___eval_static(Vt___024root* vlSelf);
void Vt___024root___eval_initial(Vt___024root* vlSelf);
void Vt___024root___eval_settle(Vt___024root* vlSelf);
void Vt___024root___eval(Vt___024root* vlSelf);

void Vt::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vt::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vt___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vt___024root___eval_static(&(vlSymsp->TOP));
        Vt___024root___eval_initial(&(vlSymsp->TOP));
        Vt___024root___eval_settle(&(vlSymsp->TOP));
        vlSymsp->__Vm_didInit = true;
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vt___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vt::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty() && !contextp()->gotFinish(); }

uint64_t Vt::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vt::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vt___024root___eval_final(Vt___024root* vlSelf);

VL_ATTR_COLD void Vt::final() {
    contextp()->executingFinal(true);
    Vt___024root___eval_final(&(vlSymsp->TOP));
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vt::hierName() const { return vlSymsp->name(); }
const char* Vt::modelName() const { return "Vt"; }
unsigned Vt::threads() const { return 1; }
void Vt::prepareClone() const { contextp()->prepareClone(); }
void Vt::atClone() const {
    contextp()->threadPoolpOnClone();
}
