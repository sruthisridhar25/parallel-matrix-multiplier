# Parallel Hardware Matrix Multiplier (Verilog)

*Course project for Digital Systems II (EEC 180), UC Davis, completed March 2026.*

Hardware accelerator for 8x8 signed matrix multiplication, built in Verilog for an FPGA (Intel MAX 10 / DE10-Lite). The project starts from a single multiply-accumulate (MAC) unit and scales to a parallel design, measuring the speed vs. hardware-cost trade-off at each step.

## Results

| Design | File | MACs | Cycles (start to done) | Speedup |
|---|---|---|---|---|
| Baseline | `src/matrixMult.v` | 1 | 833 | 1.0x |
| Parallel | `src/matrixMult3.v` | 2 | 419 | 2.0x |
| Parallel | `src/matrixMult4.v` | 4 | 244 | 3.4x |

All three designs produce the correct 8x8 product (verified in simulation against a software reference).

## Design overview

- **MAC unit (`mac.v`)**: multiplies two 8-bit signed inputs and accumulates into a 19-bit signed register; `macc_clear` starts a new dot product without an extra cycle.
- **Baseline (1 MAC)**: a finite state machine walks rows of A and columns of B, computing one output entry every ~13 cycles.
- **Parallel (2 and 4 MACs)**: dual-ported input RAMs (`ram_dual.v`) feed multiple MACs at once so several output entries are computed in parallel. Because the output RAM is single-ported, results are buffered (`buffer.v`) and written back one per cycle.
- **Memories**: inputs stored column-major in on-chip block RAM (`ram.v`, `ram_dual.v`); results written to `ram_output` (`RAMOUTPUT.v`).

## Trade-offs

Each doubling of MACs adds embedded multipliers and control logic. Going from 1 to 4 MACs cut cycles by 71%, with the single-port output RAM becoming the bottleneck (results must be serialized on write-back).

## Notes

- Fixed a state-register width bug in `matrixMult.v` (the 3-bit state could not encode the final state, so `done` never asserted); the state register is now 4 bits.
- Cycle counts are measured by `sim/tb_matrix.v` from the `start` pulse to `done`.

## Running the simulation

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/).

```bash
cd sim
iverilog -DDUT=matrixMult4 -o sim tb_matrix.v ../src/*.v && vvp sim
```

Swap `matrixMult4` for `matrixMult` or `matrixMult3` to compare designs. `ram_a_init.txt` and `ram_b_init.txt` hold sample input matrices.
