# MATLAB 기반 ECG AFE+ADC Nominal Pre-Validation

본 repo는 ECG AFE+ADC chain의 MATLAB 기반 **nominal pre-validation**을 수행한다.  
목적은 SystemVerilog XMODEL 구현 전에 schematic 기반 필터 파라미터, ADC 동적 범위, code mapping, reference vector를 정의하는 것이다.

> 본 검증은 transistor-level, PCB-level, silicon-level, clinical validation을 의미하지 않는다.  
> 또한 MATLAB과 SystemVerilog XMODEL의 bit-exact equivalence를 이미 검증했다는 의미도 아니다.  
> MATLAB 결과는 후속 XMODEL 검증에서 비교 기준으로 사용할 reference output이다.

## 프로젝트 내 역할

```text
MATLAB nominal pre-validation
→ SystemVerilog XMODEL AFE+ADC implementation
→ digital SNN RTL / Vivado / Vitis validation
→ XMODEL AFE+ADC stream + locked digital RTL integration
```

MATLAB 파트는 다음을 제공한다.

```text
nominal parameter reference
frequency response reference
ADC headroom reference
ADC code mapping convention
golden/reference input-output vector
```

## 신호 처리 체인

본 MATLAB 모델에서는 다음과 같은 AFE+ADC 신호 처리 체인을 적용하였다.

```text
ECG input voltage_V
→ HPF 0.482 Hz
→ Instrumentation Amplifier ×201
→ 60 Hz notch filter, Q≈5
→ LPF 150 Hz
→ 12-bit ADC, ±1.65 V
→ signed 12-bit stream
```

## 폴더 구조

```text
matlab_afe_validation/
├─ README.md
├─ run_all_matlab_afe_prevalidation.m
├─ run_afe_dataset_validation.m
├─ afe_adc_params.m
├─ afe_adc_model.m
├─ design_afe_filters.m
├─ active_twin_t_response.m
├─ docs/
├─ figures/
├─ results_dataset/
└─ reference_vectors/
```

## 주요 산출물

| 구분 | 파일 |
|---|---|
| Parameter reference | `docs/afe_adc_parameter_reference.md`, `results_dataset/afe_adc_parameter_reference.csv` |
| Frequency response reference | `docs/frequency_response_reference.md`, `results_dataset/afe_frequency_response_metrics.csv` |
| Dense 60 Hz notch reference | `docs/notch_60hz_reference.md`, `results_dataset/notch_dense_sweep.csv` |
| Dynamic range/headroom | `docs/dynamic_range_headroom_reference.md`, `results_dataset/afe_dynamic_range_headroom_summary.csv` |
| ADC code mapping | `docs/adc_code_mapping_convention.md`, `results_dataset/adc_code_mapping_test.csv` |
| XMODEL handoff | `docs/MATLAB_TO_XMODEL_HANDOFF.md` |
| Input dataset manifest | `docs/INPUT_DATASET_MANIFEST.md`, `results_dataset/input_dataset_manifest.csv` |
| Validation status | `docs/VALIDATION_STATUS.md` |
| Figure captions | `figures/FIGURE_CAPTIONS.md` |
| Reference vectors | `reference_vectors/*`, `reference_vectors/reference_vector_manifest.csv` |
| Figures | `figures/*.png`, `figures/*.pdf` |

## 검증 결과 요약

MATLAB nominal pre-validation 결과, NSR/CHF/ARR/AFF 대표 ECG 입력에 대해 AFE 출력은 모두 ADC 입력 범위인 ±1.65 V 내에서 동작했으며 clipping ratio는 0%였다.

| Class | AFE Output Min [V] | AFE Output Max [V] | ADC Code Range | Clipping Ratio |
|---|---:|---:|---:|---:|
| NSR | -0.111193 | 0.385184 | 1909-2525 | 0.0% |
| CHF | -0.278713 | 0.557422 | 1701-2739 | 0.0% |
| ARR | -0.630367 | 0.466399 | 1265-2626 | 0.0% |
| AFF | -0.350374 | 0.326538 | 1612-2452 | 0.0% |

주요 해석은 다음과 같다.

- 선택한 IA gain ×201은 대표 ECG 입력에 대해 ADC rail에 닿지 않았다.
- 모든 클래스에서 positive/negative rail hit count는 0이다.
- ADC code는 0 또는 4095에 붙지 않고 정상적인 12-bit stream으로 생성되었다.
- 이 결과는 XMODEL 구현 전 nominal ADC headroom reference로 사용한다.

## 재현 방법

MATLAB Current Folder를 `matlab_afe_validation/`로 설정한 뒤 아래 script를 실행한다.

```matlab
run_all_matlab_afe_prevalidation
```

이 script는 다음 항목을 재생성하도록 구성되어 있다.

```text
parameter reference
frequency response metrics
60 Hz notch dense sweep
dynamic range/headroom summary
ADC code mapping test
reference vector package
figure export
manifest/hash generation
```

실제 4-class ECG 입력 데이터셋이 있는 경우 `afe_input_dataset/`을 같은 폴더 아래에 둔 뒤 실행한다.

재현성 기준은 다음과 같다.

```text
If afe_input_dataset/ is available:
    run_all_matlab_afe_prevalidation.m regenerates the dataset-level MATLAB outputs
    and rebuilds the reference package.

If afe_input_dataset/ is absent:
    the script rebuilds secondary reports, figures, and manifests from the checked-in
    results_dataset/ artifacts.
```

즉, top-level script가 항상 raw ECG input부터 모든 것을 재생성하는 것은 아니다. Fresh clone에서 raw input부터 완전 재생성하려면 `afe_input_dataset/`이 필요하다. 이미 생성된 reference package는 `results_dataset/` 및 `reference_vectors/`에 포함되어 있다.


## 60 Hz notch 해석 주의

MATLAB time-domain chain의 60 Hz digital notch approximation은 정확히 60 Hz에서 ideal zero를 만들 수 있다. 이 numerical value는 실제 analog attenuation claim이 아니다.  
최종 논문에서 사용할 analog-style notch attenuation claim은 `docs/notch_60hz_reference.md`와 `results_dataset/notch_dense_sweep.csv`의 active Twin-T dense sweep 기준을 사용한다.

## 범위와 한계

본 MATLAB repo에서는 아래 항목을 검증 완료했다고 주장하지 않는다.

- 실제 AFE 회로 검증 완료
- PCB 또는 센서 실측 검증
- CMOS/post-layout 검증
- op-amp finite GBW, offset, slew rate 검증
- CMRR/common-mode rejection 검증
- ADC offset/gain/noise/jitter robustness 검증
- MATLAB-vs-XMODEL sample-wise bit-exact equivalence 검증
- final classification accuracy 또는 board replay

위 항목은 후속 SystemVerilog XMODEL 검증, mixed-signal integration, digital RTL/Vivado/Vitis/board replay 단계에서 다룬다.
