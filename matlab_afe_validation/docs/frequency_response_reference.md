# Frequency Response 수치 기준 문서

이 문서는 MATLAB nominal AFE chain의 frequency response reference를 정리한다.  
단순 plot만으로는 XMODEL과 비교하기 어렵기 때문에, 주요 주파수 지점에서 magnitude, phase, group delay를 CSV로 저장하였다.

- CSV: `results_dataset/afe_frequency_response_metrics.csv`
- Figure: `figures/fig_total_frequency_response.png`
- PDF: `figures/fig_total_frequency_response.pdf`

## 60 Hz ideal zero caveat

60 Hz 지점에서 MATLAB time-domain digital notch approximation은 이론적인 zero를 만들 수 있다.  
따라서 60 Hz의 numerical dB 값은 물리적인 analog attenuation claim이 아니라 **ideal digital-model artifact**로 해석해야 한다.

본 repo에서는 논문/보고서에 `-6000 dB` 같은 표현이 직접 나타나지 않도록 60 Hz magnitude를 `< -120 dB` 성격의 reporting cap으로 정리하였다.  
Analog-style notch attenuation claim은 `docs/notch_60hz_reference.md` 및 `results_dataset/notch_dense_sweep.csv`의 active Twin-T dense sweep 결과를 사용한다.

## Metric table

|   frequency_Hz | purpose                          |   magnitude_V_per_V |   magnitude_dB |   phase_deg |   group_delay_samples |   group_delay_ms | model_note                                     | interpretation_note                                                                                                                                                             |
|---------------:|:---------------------------------|--------------------:|---------------:|------------:|----------------------:|-----------------:|:-----------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|       0.05     | baseline drift region            |        20.7271      |        26.3308 |    84.0523  |            328.09     |       328.09     | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|       0.1      | low-frequency drift              |        40.8084      |        32.215  |    78.2283  |            317.997    |       317.997    | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|       0.482288 | HPF cutoff                       |       142.128       |        43.0536 |    44.7219  |            166.603    |       166.603    | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|       1        | ECG low-frequency passband       |       181.039       |        45.1554 |    25.1707  |             63.8761   |        63.8761   | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|       5        | ECG main band                    |       199.918       |        46.017  |     2.62009 |              4.65405  |         4.65405  | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|      10        | ECG main band                    |       200.144       |        46.0269 |    -3.05504 |              2.40963  |         2.40963  | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|      40        | ECG morphology band              |       187.236       |        45.4478 |   -27.9027  |              3.38189  |         3.38189  | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|      50        | 50 Hz mains reference            |       163.981       |        44.2959 |   -46.3966  |              8.17823  |         8.17823  | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|      60        | 60 Hz notch target               |         0           |      -120      |     0       |            nan        |       nan        | digital MATLAB nominal chain: HPF*IA*notch*LPF | ideal digital notch zero; dB value capped as < -120 dB for reporting; not a physical analog attenuation claim; use active Twin-T dense sweep for analog-style notch attenuation |
|     100        | high-frequency ECG/noise         |       165.205       |        44.3605 |   -23.6445  |              1.44175  |         1.44175  | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|     150        | LPF cutoff                       |       137.589       |        42.7717 |   -41.8353  |              0.768304 |         0.768304 | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|     250        | pre-ADC high-frequency reference |        86.578       |        38.7482 |   -62.2927  |              0.431782 |         0.431782 | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |
|     500        | 1 kSPS Nyquist                   |         5.86432e-15 |      -284.636  |   -90       |            nan        |       nan        | digital MATLAB nominal chain: HPF*IA*notch*LPF |                                                                                                                                                                                 |

## 해석 주의사항

- 이 frequency response는 MATLAB nominal chain의 기준값이다.
- Time-domain notch는 Q≈5 digital 2nd-order notch approximation을 사용한다.
- 60 Hz의 ideal zero는 MATLAB digital notch approximation의 수치적 결과이며, 실제 회로 attenuation claim이 아니다.
- Active Twin-T의 dense 60 Hz response는 `docs/notch_60hz_reference.md`에서 별도로 정리한다.
- 본 결과는 XMODEL 구현 전 reference frequency response이며, MATLAB과 XMODEL의 bit-exact equivalence를 이미 검증했다는 의미는 아니다.
