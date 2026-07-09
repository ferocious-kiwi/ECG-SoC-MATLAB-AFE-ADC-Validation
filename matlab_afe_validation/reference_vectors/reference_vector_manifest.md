# Reference Vector Manifest 기준 문서

이 manifest는 후속 MATLAB-vs-XMODEL 등가성 검증에 사용할 MATLAB reference input/output vector의 SHA256 hash를 정리한다.  
수환님 XMODEL 결과와 비교할 때 아래 파일과 hash를 기준으로 사용한다.

## 중요한 입력 code convention 주의

`reference_vectors/<CLASS>/input.csv`의 `source_code_signed_est_5uV_per_code`는 원본 ECG 입력 전압 scale을 추적하기 위한 estimate이다.  
이 값은 **AFE ADC output code가 아니다.**  
XMODEL의 analog input에는 `voltage_V`를 사용해야 한다.  
AFE+ADC 이후의 MATLAB reference output은 `adc_offset_binary.mem` 및 `adc_signed.txt`를 사용한다.

| Class | 파일 역할 | 상대 경로 | Bytes | SHA256 |
|---|---|---|---:|---|
| NSR | input.csv | `reference_vectors/NSR/input.csv` | 1439265 | `f1e4202c85983dc11fbcd3772c1e81dbc24b72046e8d1bcbf5a029721c9eeac2` |
| NSR | matlab_stage_outputs.csv | `reference_vectors/NSR/matlab_stage_outputs.csv` | 7366581 | `92ecc4af4a1da753f1d8363671a38a45564d7f9c986544d08b74ed0d081f35a4` |
| NSR | adc_offset_binary.mem | `reference_vectors/NSR/adc_offset_binary.mem` | 240000 | `a9da5909aa345e89bd9a0357f33a7e92bdf8263e6d916e617dd4de26114cb1ba` |
| NSR | adc_signed.txt | `reference_vectors/NSR/adc_signed.txt` | 276136 | `c34aaea1b6e33c12f2245736299f34e308a4f34a2566bf21534d4c68e7f5855c` |
| CHF | input.csv | `reference_vectors/CHF/input.csv` | 1575859 | `065d7f14b95f2be47cd48d3cb8f3c92f72ab14144fd0bbcb55aeba9080b362a1` |
| CHF | matlab_stage_outputs.csv | `reference_vectors/CHF/matlab_stage_outputs.csv` | 7345162 | `bd414c4dbe51246bbc42436d634638d851d60680537b74783d6b4a6187a70941` |
| CHF | adc_offset_binary.mem | `reference_vectors/CHF/adc_offset_binary.mem` | 240000 | `ae7ec806059809121fd5524bb634fa8d2ceaaeaa158f38ce833f771fe085a42c` |
| CHF | adc_signed.txt | `reference_vectors/CHF/adc_signed.txt` | 281866 | `9dcba06b6bd876ad6cd00a9041fdc650e3005c1478fa03a95c1b0a8d9bff8dbf` |
| ARR | input.csv | `reference_vectors/ARR/input.csv` | 1557607 | `6e0b9d9e4b811ec5761b97d73240e3ba3c8d66ca2ed4c60f15c1fafb081449af` |
| ARR | matlab_stage_outputs.csv | `reference_vectors/ARR/matlab_stage_outputs.csv` | 7348955 | `c82706ffd2f6d292ea9963c14f1aeb49a7c07af4e91c876c9609a5d3b9d623f9` |
| ARR | adc_offset_binary.mem | `reference_vectors/ARR/adc_offset_binary.mem` | 240000 | `1c218ac363c580317d7acd18a7a869c58ef0c11c7420f12d4b0191083c5bb6ca` |
| ARR | adc_signed.txt | `reference_vectors/ARR/adc_signed.txt` | 279589 | `958affc2f2584d005a6aecaeea0019d144659b1b08d03e35add0231265a09589` |
| AFF | input.csv | `reference_vectors/AFF/input.csv` | 1546154 | `ec86ecbe3f36edf26596f9bc31356673f97f358d60e6953eaf994f8b5aef1f46` |
| AFF | matlab_stage_outputs.csv | `reference_vectors/AFF/matlab_stage_outputs.csv` | 7287836 | `d32f995d04e17748f5eaf469fca9b0152439217b36d115ae0605016e2a4e7123` |
| AFF | adc_offset_binary.mem | `reference_vectors/AFF/adc_offset_binary.mem` | 240000 | `0f03e0e2c8f50e9c188a1c859c5c0e914a80877dbd73d5624993e1f8f96e93d8` |
| AFF | adc_signed.txt | `reference_vectors/AFF/adc_signed.txt` | 266825 | `7275d11062dea6b456618234dd4f8eaba1951125bf7c59c35745dd13de192b19` |
