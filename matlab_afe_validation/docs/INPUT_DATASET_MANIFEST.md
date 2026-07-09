# INPUT_DATASET_MANIFEST

이 문서는 MATLAB nominal pre-validation에 사용되는 대표 4-class ECG input dataset의 재현성 기준을 정리한다.

## 재현성 caveat

Full regeneration from raw four-class ECG input files requires `afe_input_dataset/`.  
If this folder is absent, the top-level script rebuilds secondary reports, figures, and reference manifests from the checked-in `results_dataset/` artifacts.

즉, fresh clone 환경에서 `afe_input_dataset/`이 없으면 raw ECG input부터 전체를 재생성하는 것이 아니라, repo에 포함된 `results_dataset/` 및 `reference_vectors/` 기반으로 secondary artifact를 재구성한다.

## 입력 dataset manifest

| input class | expected input path | checked-in reference input | samples | fs [Hz] | duration [s] | voltage min [V] | voltage max [V] | reference input SHA256 | raw input in repo | regeneration |
|---|---|---|---:|---:|---:|---:|---:|---|---|---|
| NSR | `afe_input_dataset/afe_input_NSR.csv` | `reference_vectors/NSR/input.csv` | 60000 | 1000 | 60.000 | -0.00049 | 0.00212 | `f1e4202c85983dc11fbcd3772c1e81dbc24b72046e8d1bcbf5a029721c9eeac2` | No | Full regeneration requires afe_input_dataset/; without it, rebuild secondary reports/figures/manifests from checked-in results_dataset artifacts. |
| CHF | `afe_input_dataset/afe_input_CHF.csv` | `reference_vectors/CHF/input.csv` | 60000 | 1000 | 60.000 | -0.00159 | 0.00313 | `065d7f14b95f2be47cd48d3cb8f3c92f72ab14144fd0bbcb55aeba9080b362a1` | No | Full regeneration requires afe_input_dataset/; without it, rebuild secondary reports/figures/manifests from checked-in results_dataset artifacts. |
| ARR | `afe_input_dataset/afe_input_ARR.csv` | `reference_vectors/ARR/input.csv` | 60000 | 1000 | 60.000 | -0.00302 | 0.00251 | `6e0b9d9e4b811ec5761b97d73240e3ba3c8d66ca2ed4c60f15c1fafb081449af` | No | Full regeneration requires afe_input_dataset/; without it, rebuild secondary reports/figures/manifests from checked-in results_dataset artifacts. |
| AFF | `afe_input_dataset/afe_input_AFF.csv` | `reference_vectors/AFF/input.csv` | 60000 | 1000 | 60.000 | -0.001945 | 0.00184 | `ec86ecbe3f36edf26596f9bc31356673f97f358d60e6953eaf994f8b5aef1f46` | No | Full regeneration requires afe_input_dataset/; without it, rebuild secondary reports/figures/manifests from checked-in results_dataset artifacts. |


## column 설명

- `expected_input_path`: raw 4-class ECG input file이 존재해야 하는 기대 경로이다.
- `checked-in reference input`: 현재 repo에 포함된 reference vector용 input copy이다.
- `checked_in_reference_input_sha256`: 현재 repo에 포함된 `reference_vectors/<CLASS>/input.csv`의 SHA256 hash이다.
- `raw input in repo`: `afe_input_dataset/` raw source input이 repo에 직접 포함되어 있는지 여부이다.

## 사용 기준

- XMODEL analog input으로는 `reference_vectors/<CLASS>/input.csv`의 `voltage_V`를 사용한다.
- `source_code_signed_est_5uV_per_code`는 원본 ECG 입력 전압 scale 추적용 estimate이며, AFE ADC output code가 아니다.
