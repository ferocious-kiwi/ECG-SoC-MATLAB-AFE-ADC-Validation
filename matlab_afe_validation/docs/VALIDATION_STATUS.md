# VALIDATION_STATUS

이 문서는 MATLAB AFE+ADC nominal pre-validation repo의 산출물 상태와 claim boundary를 정리한다.

| 항목 | 상태 | 산출물 | 비고 |
|---|---|---|---|
| Parameter reference | PASS | `docs/afe_adc_parameter_reference.md` | XMODEL 구현 기준 |
| Frequency response reference | PASS | `docs/frequency_response_reference.md` | 60 Hz ideal digital notch zero caveat 포함 |
| Dense 60 Hz notch reference | PASS | `docs/notch_60hz_reference.md` | bandwidth/Q 정의 명확화, physical Q claim 없음 |
| Dynamic range / headroom | PASS | `docs/dynamic_range_headroom_reference.md` | representative NSR/CHF/ARR/AFF inputs 기준 |
| ADC code mapping | PASS | `docs/adc_code_mapping_convention.md` | 0 V convention 및 source input code 구분 명시 |
| Reference vectors | PASS | `reference_vectors/reference_vector_manifest.md` | SHA256-tracked NSR/CHF/ARR/AFF reference vectors |
| Input dataset manifest | PASS | `docs/INPUT_DATASET_MANIFEST.md` | raw input 재현성 caveat 포함 |
| MATLAB-to-XMODEL handoff | PASS | `docs/MATLAB_TO_XMODEL_HANDOFF.md` | time-domain stream과 active Twin-T notch 기준 분리 |
| MATLAB-vs-XMODEL equivalence | NOT DONE | XMODEL 담당 | claim 금지 |
| CMRR / op-amp / ADC nonideal | NOT DONE | XMODEL 또는 analog stress 검증 담당 | claim 금지 |
| PCB / silicon / clinical validation | NOT DONE | scope 밖 | claim 금지 |

## 최종 claim 문장

MATLAB 단계는 SystemVerilog XMODEL 구현 이전의 nominal system-level pre-validation 및 reference generation 단계로 사용된다. 본 단계에서는 schematic 기반 AFE 필터 파라미터, frequency-response reference, ADC headroom, code-mapping convention, 그리고 대표 NSR/CHF/ARR/AFF 입력에 대한 SHA256-tracked reference vector를 정의한다. 본 단계는 transistor-level, PCB-level, silicon-level, clinical validation 또는 MATLAB-vs-XMODEL bit-exact equivalence를 주장하지 않는다.
