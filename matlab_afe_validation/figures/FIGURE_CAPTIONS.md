# Figure Captions / Notes

아래 figure들은 모두 **SystemVerilog XMODEL 구현 전 MATLAB nominal reference 결과**이다.  
이 figure들은 transistor-level, PCB-level, silicon-level 검증 또는 MATLAB-vs-XMODEL 등가성 검증을 의미하지 않는다.

| Figure | Caption / Note |
|---|---|
| `fig_total_frequency_response.png/.pdf` | MATLAB nominal reference before SystemVerilog XMODEL implementation. 60 Hz digital notch zero는 physical analog attenuation claim이 아니며, analog-style notch attenuation은 dense active Twin-T sweep 기준을 사용한다. |
| `fig_notch_dense_sweep.png/.pdf` | Active Twin-T 60 Hz notch frequency-domain reference. 60 Hz mains target용 nominal reference이며, 50 Hz까지 완전 제거한다는 claim이 아니다. |
| `fig_dynamic_range_headroom.png/.pdf` | MATLAB nominal ADC headroom reference for representative ECG inputs. IA gain ×201과 ADC ±1.65 V range가 representative inputs에 대해 clipping 없이 동작함을 보여준다. |
| `fig_adc_code_distribution.png/.pdf` | MATLAB nominal ADC code distribution. ADC code가 0 또는 4095 rail에 붙지 않음을 보여주는 reference이며, RTL/XMODEL equivalence 완료를 의미하지 않는다. |
| `fig_reference_vector_handoff.png/.pdf` | MATLAB reference vector가 후속 XMODEL verification으로 전달되는 흐름을 나타낸다. |
| `fig_matlab_prevalidation_flow.png/.pdf` | 프로젝트 내 MATLAB nominal pre-validation의 위치를 나타낸다. |
| `fig_afe_chain_overview.png/.pdf` | HPF → IA → notch → LPF → ADC의 MATLAB nominal AFE+ADC chain overview이다. |

## 공통 한국어 caption 문구

본 figure는 SystemVerilog XMODEL 구현 전 MATLAB nominal reference 결과이며, transistor-level, PCB-level, silicon-level 검증 또는 MATLAB-vs-XMODEL 등가성 검증을 의미하지 않는다.
