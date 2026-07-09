# MATLAB-to-XMODEL Handoff 문서

이 문서는 MATLAB-vs-XMODEL 등가성 검증에 사용할 MATLAB reference output을 정의한다.  
이 문서는 MATLAB과 XMODEL이 이미 bit-exact로 일치함을 주장하지 않는다.

> This document defines the MATLAB reference outputs that should be used for MATLAB-vs-XMODEL equivalence verification.

## MATLAB의 역할

MATLAB 단계는 SystemVerilog XMODEL 구현 이전의 nominal system-level pre-validation 및 reference generation 단계이다.  
본 단계에서는 schematic 기반 AFE 필터 파라미터, ADC headroom, code mapping, 대표 ECG 입력에 대한 reference output vector를 정의한다.  
회로 소자 수준 non-ideality와 mixed-signal behavioral robustness는 후속 XMODEL 검증 단계에서 다룬다.

## Block order

```text
input ECG voltage [V]
→ HPF 0.482 Hz
→ Instrumentation amplifier ×201
→ 60 Hz notch, Q≈5
→ LPF 150 Hz
→ ADC saturation check, ±1.65 V
→ 12-bit offset-binary code
→ signed decimal stream
```

## 단위 및 sampling

| 항목 | 값 |
|---|---:|
| Sampling rate | 1 kSPS |
| Input unit | V |
| Stage output unit | V |
| ADC voltage range | ±1.65 V |
| ADC output | 12-bit offset-binary, 0-4095 |
| Signed stream | offset-binary − 2048 |

## 입력 column 주의

`reference_vectors/<CLASS>/input.csv`의 `source_code_signed_est_5uV_per_code`는 원본 ECG 입력 전압 scale을 추적하기 위한 estimate이다.  
이 값은 **AFE ADC output code가 아니다.**  
XMODEL analog input으로는 `voltage_V`를 사용해야 한다.

## 5.1 Time-domain stream equivalence 기준

XMODEL의 time-domain output은 아래 MATLAB reference와 비교한다.

```text
reference_vectors/<CLASS>/matlab_stage_outputs.csv
reference_vectors/<CLASS>/adc_offset_binary.mem
reference_vectors/<CLASS>/adc_signed.txt
```

| Metric | 목표 / 비고 |
|---|---|
| sample alignment | lag = 0 sample |
| RMS LSB error | convention matching 후 가능하면 2-3 LSB 이하 |
| max abs LSB error | outlier 확인 |
| correlation | 0.99 이상 권장 |
| ADC code convention | MATLAB과 XMODEL 동일 |
| signed stream convention | MATLAB과 XMODEL 동일 |

## 5.2 Active Twin-T notch frequency-response 기준

60 Hz notch의 parameter-level reference는 아래 결과와 비교한다.

```text
docs/notch_60hz_reference.md
results_dataset/notch_dense_sweep.csv
results_dataset/notch_dense_sweep_metrics.csv
```

중요한 구분은 다음과 같다.

```text
The MATLAB time-domain stream uses a digital Q≈5 notch approximation.
The dense notch sweep provides an active Twin-T frequency-domain reference.
These are related but not identical comparison targets.
For XMODEL verification, time-domain stream equivalence and notch frequency-response validation should be checked separately.
```

즉, MATLAB time-domain stream equivalence와 active Twin-T notch frequency-response validation은 서로 관련은 있지만 동일한 비교 대상이 아니다. 최종 논문에서 두 기준이 섞여 보이지 않도록 분리해서 서술한다.

## Reference vector 위치

```text
reference_vectors/NSR/
reference_vectors/CHF/
reference_vectors/ARR/
reference_vectors/AFF/
reference_vectors/reference_vector_manifest.csv
reference_vectors/reference_vector_manifest.md
```

각 case에는 다음 파일이 포함된다.

```text
input.csv
matlab_stage_outputs.csv
adc_offset_binary.mem
adc_signed.txt
```

## 주장하지 않는 항목

본 MATLAB package는 transistor-level, PCB-level, silicon-level, clinical validation, op-amp non-ideality 검증, CMRR 검증, ADC non-ideal robustness 검증, MATLAB-vs-XMODEL bit-exact equivalence 완료를 주장하지 않는다.
