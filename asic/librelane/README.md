# LibreLane design bundle (openx86_soc_top)

This directory holds a **LibreLane** configuration for `openx86_soc_top`.

- `config.base.json`: stable flow/PDK parameters (includes `RUN_LINTER: false` so the Classic flow skips the built-in Verilator lint pass; this repo already runs Verilator in CI).
- `generated.config.json`: produced by `scripts/gen_librelane_config.py` from `sim/filelists/rtl.f` (Verilog list + include dirs). It is gitignored.

## Local usage

```bash
export PDK_ROOT="$HOME/openx86-pdk"
python3 -m pip install "librelane==3.0.2"
python3 scripts/gen_librelane_config.py
python3 -m librelane --dockerized --docker-no-tty --pdk-root "$PDK_ROOT" --flow Classic --design-dir asic/librelane asic/librelane/generated.config.json
```

Expect long runtimes and possible Yosys/SystemVerilog limitations on this design size.
