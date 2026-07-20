# Opcode coverage matrix (80486DX target)

Status legend: `OK` = mapped + executed subset; `MAP` = MISC/uop mapped, semantics partial; `UD` = raises #UD; `DEC` = decoded only; `-` = missing.

| Class | Status | Notes |
|-------|--------|-------|
| ALU / logic / shift | OK | EXU units present |
| MUL / DIV | OK | |
| MOV / MOVSX / MOVZX / XCHG / LEA | OK | |
| Near JMP / CALL / RET / Jcc / LOOP | OK | |
| Far JMP / CALL / RET | MAP | Segment load path |
| PUSH / POP GPR | OK | |
| PUSH / POP sreg | MAP | MISC_SUB_PUSH/POP_SEG |
| PUSHA / POPA / PUSHF / POPF | MAP | Simplified |
| ENTER | - | Subcode reserved; decode port TBD |
| LEAVE | MAP | ESP:=EBP + POP EBP skeleton |
| String (MOVS/…) | MAP | Single-step + REP restart interface |
| BT / BTS / BTR / BTC / BSF / BSR / BSWAP | OK | |
| CBW / CWDE / CDQ / CWD | MAP | MISC + EXU |
| BCD (AAA/AAS/DAA/DAS/AAD/AAM) | MAP | MISC + EXU |
| XLAT | MAP | |
| BOUND / ARPL | MAP | Subcodes present |
| Flag control | MAP | FLAG_CTRL needs imm fix |
| IN / OUT | MAP | |
| INT / IRET | MAP | IDU path |
| LGDT / LIDT / SGDT / SIDT | MAP | |
| LMSW / MOV CR | MAP | |
| CLTS / SMSW | MAP | |
| LLDT / LTR / LAR / LSL / VERR / VERW | MAP | Subcodes; EXU TBD |
| LDS/LES/LFS/LGS/LSS | MAP | |
| CPUID | OK | 486DX identity + 4-reg WB |
| INVD / WBINVD / INVLPG | MAP | INVLPG→TLB parent TBD |
| x87 | MAP | Subset + CR0 #NM gate |
| MMX / SSE / MSR / RDTSC | UD | Outside 486DX contract |
| V86 sensitive trap | MAP | INT/IRET/IN/OUT wired |
| TSS privilege stack | MAP | Helper + IDU inputs |
| Task switch | - | Ongoing |

Update this table as milestones land.
