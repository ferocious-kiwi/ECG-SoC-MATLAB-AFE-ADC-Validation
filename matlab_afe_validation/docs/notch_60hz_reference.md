# Dense 60 Hz Notch Reference

이 문서는 active Twin-T notch의 **30-100 Hz dense sweep reference**를 정리한다.  
현재 notch scope는 **60 Hz mains target**이다. 50 Hz까지 완벽히 제거한다고 주장하지 않는다.

- CSV: `results_dataset/notch_dense_sweep.csv`
- Metric CSV: `results_dataset/notch_dense_sweep_metrics.csv`
- Figure: `figures/fig_notch_dense_sweep.png`
- PDF: `figures/fig_notch_dense_sweep.pdf`

## configured Q / estimated Q / physical Q 구분

| 항목 | 의미 |
|---|---|
| configured Q | MATLAB notch design parameter로 설정한 nominal Q |
| estimated Q | active Twin-T dense sweep 결과에서 local passband 기준 -3 dB bandwidth로 계산한 nominal estimate |
| physical Q | 실제 회로 측정값이 아님. 본 MATLAB repo에서는 physical Q를 주장하지 않음 |

## bandwidth/Q 계산 정의

The notch bandwidth is computed relative to the local passband reference magnitude.  
여기서는 30 Hz와 100 Hz endpoint magnitude의 평균을 local passband reference로 두고, 그 기준에서 -3 dB threshold를 적용하였다.  
따라서 reported Q는 nominal MATLAB reference value이며 measured circuit Q가 아니다.

## Dense sweep metrics

|   target_frequency_Hz |   sweep_low_Hz |   sweep_high_Hz |   notch_center_frequency_Hz |   exact_60Hz_attenuation_dB |   minimum_attenuation_dB_in_sweep |   local_passband_reference_dB |   minus3dB_threshold_dB |   bandwidth_low_Hz |   bandwidth_high_Hz |   bandwidth_Hz |   estimated_Q_from_sweep |   configured_Q |   attenuation_at_50Hz_dB | physical_Q_claim                  | definition_note                                                                                                                                                                       | scope_note                                                  |
|----------------------:|---------------:|----------------:|----------------------------:|----------------------------:|----------------------------------:|------------------------------:|------------------------:|-------------------:|--------------------:|---------------:|-------------------------:|---------------:|-------------------------:|:----------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------|
|                    60 |             30 |             100 |                          60 |                    -83.5557 |                          -83.5557 |                     -0.113293 |                -3.11329 |             54.425 |              66.146 |         11.721 |                  5.11902 |              5 |                 -1.13122 | No; nominal MATLAB reference only | Bandwidth is computed relative to the local passband reference magnitude from 30 Hz and 100 Hz endpoints. Estimated Q is a nominal sweep estimate, not a measured physical circuit Q. | 60 Hz mains target; not claimed as complete 50 Hz rejection |

## 해석

- configured Q는 약 5.0이다.
- exact 60 Hz attenuation은 MATLAB active Twin-T nodal-analysis reference 기준으로 약 -83.56 dB이다.
- estimated Q는 30-100 Hz dense sweep의 local passband -3 dB bandwidth 기준으로 약 5.12이다.
- 50 Hz attenuation은 reference point로만 제공하며, 본 notch의 primary target은 60 Hz이다.

## 한계

이 결과는 MATLAB nominal/reference 결과이다. 실제 XMODEL 결과와의 equivalence는 후속 SystemVerilog XMODEL 검증에서 수행해야 한다.  
본 결과는 transistor-level, PCB-level, silicon-level 검증 또는 physical measured Q를 의미하지 않는다.
