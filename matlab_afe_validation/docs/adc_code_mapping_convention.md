# ADC Code Mapping Convention

이 문서는 MATLAB nominal ADC output convention을 정의한다.  
디지털 RTL 및 XMODEL testbench와 convention이 충돌하지 않도록 아래 mapping을 기준으로 사용한다.

## 계산식

```text
adc_offset_binary = floor((Vadc + 1.65) / 3.3 * 4095)
adc_offset_binary = clip(adc_offset_binary, 0, 4095)
adc_signed = adc_offset_binary - 2048
```

## Mapping test

|   input_voltage_V |   offset_binary_code_decimal | offset_binary_code_hex   |   signed_decimal | formula                                           |
|------------------:|-----------------------------:|:-------------------------|-----------------:|:--------------------------------------------------|
|      -1.65        |                            0 | 000                      |            -2048 | floor((V + 1.65)/3.3 * 4095), clipped to [0,4095] |
|      -1           |                          806 | 326                      |            -1242 | floor((V + 1.65)/3.3 * 4095), clipped to [0,4095] |
|      -0.000805861 |                         2046 | 7FE                      |               -2 | floor((V + 1.65)/3.3 * 4095), clipped to [0,4095] |
|       0           |                         2047 | 7FF                      |               -1 | floor((V + 1.65)/3.3 * 4095), clipped to [0,4095] |
|       0.000805861 |                         2048 | 800                      |                0 | floor((V + 1.65)/3.3 * 4095), clipped to [0,4095] |
|       1           |                         3288 | CD8                      |             1240 | floor((V + 1.65)/3.3 * 4095), clipped to [0,4095] |
|       1.65        |                         4095 | FFF                      |             2047 | floor((V + 1.65)/3.3 * 4095), clipped to [0,4095] |

## 파일 형식

| 파일 | 형식 | 권장 사용처 |
|---|---|---|
| `adc_offset_binary.mem` | line마다 12-bit hex code, `%03X` | XMODEL/RTL `$readmemh` replay 권장 |
| `adc_signed.txt` | line마다 signed decimal integer | digital/SNN signed stream 확인 권장 |
| `matlab_stage_outputs.csv` | time-domain stage output 및 ADC code | MATLAB-vs-XMODEL waveform/code 비교 |

## 0 V convention

현재 `floor` convention에서는 0 V가 offset-binary code `2047`, signed decimal `-1`로 mapping된다.  
이것은 오류가 아니다. XMODEL 및 RTL testbench는 동일한 convention을 사용하거나, offset 차이가 있다면 문서에 명확히 기록해야 한다.

## source input code와 AFE ADC output code 구분

`reference_vectors/<CLASS>/input.csv`의 `source_code_signed_est_5uV_per_code`는 원본 ECG 입력 전압 scale을 추적하기 위한 estimate이다.  
이 값은 **AFE ADC output code가 아니다.**

- XMODEL analog input에는 `voltage_V`를 사용한다.
- AFE ADC output reference는 `adc_offset_binary.mem` 및 `adc_signed.txt`이다.
- `source_code_signed_est_5uV_per_code`는 input traceability 용도이며, XMODEL ADC output 비교에는 사용하지 않는다.
