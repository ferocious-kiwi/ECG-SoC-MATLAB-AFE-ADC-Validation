# Figure Captions

본 문서는 `figures/` 폴더에 저장된 주요 figure를 논문 또는 보고서에 사용할 때 적용할 caption 문구를 정리한다.

모든 figure는 **SystemVerilog XMODEL 구현 전 MATLAB nominal reference 결과**를 나타낸다. 따라서 아래 figure들은 transistor-level, PCB-level, silicon-level 검증 또는 MATLAB-vs-XMODEL bit-exact 등가성 검증을 의미하지 않는다.

## 공통 주의 문구

각 figure caption 또는 본문 설명에는 필요에 따라 아래 문구를 함께 사용한다.

```text
본 figure는 SystemVerilog XMODEL 구현 전 MATLAB nominal reference 결과이며,
transistor-level, PCB-level, silicon-level 검증 또는 MATLAB-vs-XMODEL 등가성 검증을 의미하지 않는다.
```

## Figure별 권장 Caption

| Figure | 권장 caption / note |
|---|---|
| `fig_matlab_prevalidation_flow` | SystemVerilog XMODEL 구현 전 MATLAB nominal pre-validation과 reference generation의 전체 흐름을 나타낸다. MATLAB 단계는 schematic 기반 AFE+ADC 파라미터, ADC headroom, code mapping, reference vector를 정의하는 역할을 한다. |
| `fig_afe_chain_overview` | MATLAB nominal model에서 사용한 AFE+ADC 신호 처리 체인을 나타낸다. 입력 ECG 전압은 HPF, IA, 60 Hz notch, LPF, ADC quantizer를 거쳐 offset-binary ADC code와 signed stream으로 변환된다. |
| `fig_total_frequency_response` | MATLAB nominal AFE+ADC chain의 전체 frequency response reference를 나타낸다. HPF cutoff, 60 Hz notch target, LPF cutoff를 확인하기 위한 기준 그래프이다. 단, MATLAB time-domain digital notch approximation에서 60 Hz ideal zero가 발생할 수 있으므로, 해당 수치를 실제 analog 회로의 감쇠량으로 해석하지 않는다. Analog-style notch attenuation claim은 active Twin-T dense sweep 결과를 기준으로 사용한다. |
| `fig_notch_dense_sweep` | Active Twin-T 60 Hz notch의 frequency-domain dense sweep reference를 나타낸다. 본 결과는 60 Hz mains 제거 특성을 확인하기 위한 nominal reference이며, 50 Hz 성분까지 완전히 제거한다고 주장하지 않는다. configured Q, estimated Q, physical Q claim은 구분해서 해석해야 한다. |
| `fig_dynamic_range_headroom` | 대표 NSR/CHF/ARR/AFF ECG 입력에 대해 AFE 출력이 ADC 입력 범위 ±1.65 V rail에 대해 확보하는 headroom을 나타낸다. 본 결과는 선택한 IA gain ×201과 ADC range가 대표 입력에서 clipping 없이 동작하는지 확인하기 위한 nominal ADC headroom reference이다. |
| `fig_adc_code_distribution` | 대표 ECG 입력에 대해 생성된 ADC code 분포를 나타낸다. ADC code가 0 또는 4095 rail에 포화되지 않음을 확인하기 위한 reference figure이다. Offset-binary code와 signed stream convention은 downstream XMODEL 및 digital RTL testbench convention과 정합되어야 한다. |
| `fig_reference_vector_handoff` | MATLAB에서 생성한 reference vector가 후속 SystemVerilog XMODEL 검증으로 전달되는 흐름을 나타낸다. `reference_vectors/<CLASS>/matlab_stage_outputs.csv`, `adc_offset_binary.mem`, `adc_signed.txt`는 MATLAB-vs-XMODEL 비교 기준으로 사용된다. 단, 이 figure는 MATLAB과 XMODEL이 이미 bit-exact하게 일치한다는 의미는 아니다. |

## 논문/보고서 사용 시 권장 표현

아래 문장은 MATLAB figure set을 설명할 때 사용할 수 있다.

```text
MATLAB figure set은 SystemVerilog XMODEL 구현 이전의 nominal reference 결과를 시각화한 것이다.
본 figure들은 schematic 기반 AFE+ADC 파라미터, frequency response, ADC headroom, code mapping,
reference vector handoff를 설명하기 위한 자료이며, transistor-level, PCB-level, silicon-level,
clinical validation 또는 MATLAB-vs-XMODEL bit-exact equivalence를 주장하지 않는다.
```
