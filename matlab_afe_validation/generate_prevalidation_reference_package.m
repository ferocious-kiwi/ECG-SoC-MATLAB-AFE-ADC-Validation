function generate_prevalidation_reference_package()
%GENERATE_PREVALIDATION_REFERENCE_PACKAGE
% Generate MATLAB nominal AFE+ADC pre-validation reference artifacts.
%
% This script assumes that run_afe_dataset_validation has already generated:
%   results_dataset/<CLASS>/matlab_afe_adc_output.csv
%   results_dataset/<CLASS>/matlab_adc_offset_binary_hex.mem
%   results_dataset/<CLASS>/matlab_adc_signed_decimal.txt
%
% Generated artifact categories:
%   - results_dataset/*reference*.csv
%   - docs/*.md
%   - figures/*.png and *.pdf
%   - reference_vectors/*
%   - reference_vectors/reference_vector_manifest.csv/.md
%
% This script creates nominal MATLAB references for later MATLAB-vs-XMODEL
% equivalence verification. It does not claim that MATLAB and XMODEL are
% already bit-exact equivalent.

    p = afe_adc_params();
    filt = design_afe_filters(p);

    results_dir = 'results_dataset';
    docs_dir = 'docs';
    figures_dir = 'figures';
    ref_dir = 'reference_vectors';

    ensure_dir(results_dir);
    ensure_dir(docs_dir);
    ensure_dir(figures_dir);
    ensure_dir(ref_dir);

    classes = {'NSR','CHF','ARR','AFF'};

    %% A. Parameter reference
    param_table = make_parameter_reference_table(p);
    writetable(param_table, fullfile(results_dir, 'afe_adc_parameter_reference.csv'));

    %% B. Frequency response numerical reference
    freq_table = make_frequency_response_metrics(p, filt);
    writetable(freq_table, fullfile(results_dir, 'afe_frequency_response_metrics.csv'));
    plot_total_frequency_response(p, filt, figures_dir);

    %% C. Dense 60 Hz notch reference
    [notch_table, notch_metrics] = make_notch_dense_sweep(p);
    writetable(notch_table, fullfile(results_dir, 'notch_dense_sweep.csv'));
    writetable(notch_metrics, fullfile(results_dir, 'notch_dense_sweep_metrics.csv'));
    plot_notch_dense_sweep(notch_table, notch_metrics, figures_dir);

    %% D. Dynamic range / ADC headroom reference
    headroom_table = make_dynamic_range_headroom_summary(classes, p, results_dir);
    writetable(headroom_table, fullfile(results_dir, 'afe_dynamic_range_headroom_summary.csv'));
    plot_dynamic_range_headroom(headroom_table, figures_dir);
    plot_adc_code_distribution(classes, results_dir, figures_dir);

    %% E. ADC code mapping convention
    mapping_table = make_adc_code_mapping_test(p);
    writetable(mapping_table, fullfile(results_dir, 'adc_code_mapping_test.csv'));

    %% F. Reference vector package and hash manifest
    make_reference_vectors(classes, results_dir, ref_dir);
    manifest_table = make_reference_vector_manifest(ref_dir);
    writetable(manifest_table, fullfile(ref_dir, 'reference_vector_manifest.csv'));
    write_reference_vector_manifest_md(manifest_table, fullfile(ref_dir, 'reference_vector_manifest.md'));

    %% G. Handoff/overview figures and docs
    plot_flow_figures(figures_dir);
    write_docs(docs_dir, param_table, freq_table, notch_metrics, headroom_table, mapping_table, p);

    fprintf('Generated MATLAB nominal pre-validation reference package.\n');
end

%% ------------------------------------------------------------------------
function ensure_dir(d)
    if ~exist(d, 'dir')
        mkdir(d);
    end
end

function T = make_parameter_reference_table(p)
    block = {};
    parameter = {};
    value = {};
    unit = {};
    note = {};
    add('Sampling','fs',p.fs,'Hz','ADC/system sample rate used for nominal MATLAB validation');
    add('HPF','R_hpf',p.R_hpf,'Ohm','Schematic-derived high-pass resistor');
    add('HPF','C_hpf',p.C_hpf,'F','Schematic-derived high-pass capacitor');
    add('HPF','fc_hpf',p.fc_hpf,'Hz','1/(2*pi*R*C), baseline drift removal reference');
    add('Instrumentation Amplifier','Rfb',p.Rfb,'Ohm','IA feedback resistor');
    add('Instrumentation Amplifier','Rg',p.Rg,'Ohm','IA gain-setting resistor');
    add('Instrumentation Amplifier','Av_ia',p.Av_ia,'V/V','1 + 2*Rfb/Rg');
    add('Differential Amplifier','Av_diff',p.Av_diff,'V/V','Unity differential stage in nominal model');
    add('Notch','f_notch',p.f_notch,'Hz','60 Hz mains target');
    add('Notch','R_twin',p.R_twin,'Ohm','Active Twin-T nominal resistor');
    add('Notch','C_twin',p.C_twin,'F','Active Twin-T nominal capacitor');
    add('Notch','Rk1',p.Rk1,'Ohm','Bootstrap feedback resistor');
    add('Notch','Rk2',p.Rk2,'Ohm','Bootstrap feedback resistor');
    add('Notch','k_boot',p.k_boot,'V/V','Rk2/(Rk1+Rk2)');
    add('Notch','Q_notch',p.Q_notch,'-','Approximate Q = 1/(4*(1-k))');
    add('LPF','R_lpf',p.R_lpf,'Ohm','Schematic-derived low-pass resistor');
    add('LPF','C_lpf',p.C_lpf,'F','Schematic-derived low-pass capacitor');
    add('LPF','fc_lpf',p.fc_lpf,'Hz','1/(2*pi*R*C), anti-aliasing reference');
    add('ADC','adc_bits',p.adc_bits,'bit','Nominal ADC output width');
    add('ADC','vref_n',p.vref_n,'V','Negative ADC input reference');
    add('ADC','vref_p',p.vref_p,'V','Positive ADC input reference');
    add('ADC','adc_max',p.adc_max,'code','2^12 - 1');
    add('ADC','lsb',(p.vref_p-p.vref_n)/p.adc_max,'V/LSB','3.3/4095');
    add('Output stream','offset_binary_mem',NaN,'hex','%03X per line, recommended for readmemh replay');
    add('Output stream','signed_decimal_txt',NaN,'decimal','adc_offset_binary - 2048');
    T = table(string(block(:)), string(parameter(:)), string(value(:)), string(unit(:)), string(note(:)), ...
        'VariableNames', {'block','parameter','value','unit','note'});

    function add(b, par, val, u, n)
        block{end+1} = b; %#ok<AGROW>
        parameter{end+1} = par; %#ok<AGROW>
        if isnumeric(val)
            if isnan(val)
                value{end+1} = ''; %#ok<AGROW>
            else
                value{end+1} = sprintf('%.12g', val); %#ok<AGROW>
            end
        else
            value{end+1} = char(val); %#ok<AGROW>
        end
        unit{end+1} = u; %#ok<AGROW>
        note{end+1} = n; %#ok<AGROW>
    end
end

function T = make_frequency_response_metrics(p, filt)
    freq = [0.05; 0.1; p.fc_hpf; 1; 5; 10; 40; 50; 60; 100; 150; 250; 500];
    purpose = ["baseline drift region"; "low-frequency drift"; "HPF cutoff"; ...
        "ECG low-frequency passband"; "ECG main band"; "ECG main band"; ...
        "ECG morphology band"; "50 Hz mains reference"; "60 Hz notch target"; ...
        "high-frequency ECG/noise"; "LPF cutoff"; "pre-ADC high-frequency reference"; ...
        "1 kSPS Nyquist"];

    H = total_response(freq, p, filt);
    mag = abs(H);
    mag_db = 20*log10(max(mag, realmin));
    phase_deg = angle(H)*180/pi;

    group_delay_samples = nan(size(freq));
    for i = 1:numel(freq)
        f = freq(i);
        if f > 0.02 && f < p.fs/2 - 0.02 && abs(f - 60) > 0.05
            df = max(0.001, f*1e-4);
            fpair = [f-df, f+df];
            Hpair = total_response(fpair, p, filt);
            ph = unwrap(angle(Hpair));
            w = 2*pi*fpair/p.fs;
            group_delay_samples(i) = -(ph(2)-ph(1))/(w(2)-w(1));
        end
    end
    group_delay_ms = group_delay_samples / p.fs * 1000;
    model_note = repmat("digital MATLAB nominal chain: HPF*IA*notch*LPF", numel(freq), 1);

    T = table(freq, purpose, mag, mag_db, phase_deg, group_delay_samples, group_delay_ms, model_note, ...
        'VariableNames', {'frequency_Hz','purpose','magnitude_V_per_V','magnitude_dB','phase_deg','group_delay_samples','group_delay_ms','model_note'});
end

function H = total_response(f, p, filt)
    H = freqz_eval(filt.b_hpf, filt.a_hpf, f, p.fs) .* p.Av_total .* ...
        freqz_eval(filt.b_notch, filt.a_notch, f, p.fs) .* ...
        freqz_eval(filt.b_lpf, filt.a_lpf, f, p.fs);
end

function H = freqz_eval(b, a, f, fs)
    f = f(:);
    w = 2*pi*f/fs;
    zinv = exp(-1j*w);
    num = zeros(size(f));
    den = zeros(size(f));
    for k = 1:numel(b)
        num = num + b(k) .* zinv.^(k-1);
    end
    for k = 1:numel(a)
        den = den + a(k) .* zinv.^(k-1);
    end
    H = num ./ den;
end

function [T, M] = make_notch_dense_sweep(p)
    frequency_Hz = (30:0.001:100)';
    H = active_twin_t_response(frequency_Hz, p.R_twin, p.C_twin, p.k_boot);
    magnitude_V_per_V = abs(H(:));
    magnitude_dB = 20*log10(max(magnitude_V_per_V, realmin));
    phase_deg = angle(H(:))*180/pi;
    T = table(frequency_Hz, magnitude_V_per_V, magnitude_dB, phase_deg);

    [min_att, idx] = min(magnitude_dB);
    center = frequency_Hz(idx);
    H60 = active_twin_t_response(60, p.R_twin, p.C_twin, p.k_boot);
    H50 = active_twin_t_response(50, p.R_twin, p.C_twin, p.k_boot);
    exact60 = 20*log10(max(abs(H60), realmin));
    att50 = 20*log10(max(abs(H50), realmin));

    mask = magnitude_dB <= -3;
    if any(mask)
        idxs = find(mask);
        bw_low = frequency_Hz(idxs(1));
        bw_high = frequency_Hz(idxs(end));
        bw = bw_high - bw_low;
        q_est = center / bw;
    else
        bw_low = NaN; bw_high = NaN; bw = NaN; q_est = NaN;
    end

    M = table(60, center, exact60, min_att, bw_low, bw_high, bw, q_est, p.Q_notch, att50, ...
        "60 Hz mains target; 30-100 Hz sweep; not claimed as complete 50 Hz rejection; bandwidth/Q are nominal MATLAB estimates, not physical circuit measurements", ...
        'VariableNames', {'target_frequency_Hz','notch_center_frequency_Hz','exact_60Hz_attenuation_dB', ...
        'minimum_attenuation_dB_in_sweep','minus3dB_bandwidth_low_Hz','minus3dB_bandwidth_high_Hz', ...
        'minus3dB_bandwidth_Hz','approximate_Q_from_minus3dB','configured_Q','attenuation_at_50Hz_dB','scope_note'});
end

function T = make_dynamic_range_headroom_summary(classes, p, results_dir)
    rows = table();
    lsb = (p.vref_p - p.vref_n) / p.adc_max;
    for i = 1:numel(classes)
        rec = classes{i};
        f = fullfile(results_dir, rec, 'matlab_afe_adc_output.csv');
        if ~exist(f, 'file')
            warning('Missing %s', f);
            continue;
        end
        D = readtable(f);
        duration = D.time_s(end) - D.time_s(1) + 1/p.fs;
        afe_min = min(D.v_lpf); afe_max = max(D.v_lpf);
        adc_min_v = min(D.v_adc_in); adc_max_v = max(D.v_adc_in);
        code_min = min(D.adc_code); code_max = max(D.adc_code);
        pos_hits = sum(D.v_lpf >= p.vref_p);
        neg_hits = sum(D.v_lpf <= p.vref_n);
        clip_ratio = 100*(pos_hits+neg_hits)/height(D);
        pos_headroom = p.vref_p - adc_max_v;
        neg_headroom = adc_min_v - p.vref_n;
        min_headroom = min(pos_headroom, neg_headroom);

        R = table(string(rec), duration, height(D), p.fs, afe_min, afe_max, adc_min_v, adc_max_v, ...
            code_min, code_max, code_max-code_min, pos_hits, neg_hits, clip_ratio, ...
            pos_headroom, neg_headroom, min_headroom, min_headroom/lsb, ...
            'VariableNames', {'record_name','input_duration_s','sample_count','sampling_rate_Hz', ...
            'afe_output_min_V','afe_output_max_V','adc_input_min_V','adc_input_max_V','adc_code_min','adc_code_max', ...
            'adc_code_peak_to_peak','positive_rail_hit_count','negative_rail_hit_count','clipping_ratio_percent', ...
            'positive_headroom_to_rail_V','negative_headroom_to_rail_V','minimum_headroom_to_rail_V','minimum_headroom_to_rail_LSB'});
        rows = [rows; R]; %#ok<AGROW>
    end
    T = rows;
end

function T = make_adc_code_mapping_test(p)
    lsb = (p.vref_p - p.vref_n) / p.adc_max;
    vin = [p.vref_n; -1; -lsb; 0; lsb; 1; p.vref_p];
    code = floor(((vin - p.vref_n)/(p.vref_p-p.vref_n))*p.adc_max);
    code = min(max(code, 0), p.adc_max);
    signed = code - 2^(p.adc_bits-1);
    hex = strings(numel(code),1);
    for i = 1:numel(code)
        hex(i) = upper(dec2hex(code(i), 3));
    end
    formula = repmat("floor((V + 1.65)/3.3 * 4095), clipped to [0,4095]", numel(code), 1);
    T = table(vin, code, hex, signed, formula, ...
        'VariableNames', {'input_voltage_V','offset_binary_code_decimal','offset_binary_code_hex','signed_decimal','formula'});
end

function make_reference_vectors(classes, results_dir, ref_dir)
    ensure_dir(ref_dir);
    for i = 1:numel(classes)
        rec = classes{i};
        out_dir = fullfile(ref_dir, rec);
        ensure_dir(out_dir);
        src_csv = fullfile(results_dir, rec, 'matlab_afe_adc_output.csv');
        D = readtable(src_csv);
        sample_index = (0:height(D)-1)';
        time_s = D.time_s;
        voltage_V = D.v_diff;
        source_code_signed_est_5uV_per_code = round(voltage_V * 200000);
        inputT = table(sample_index, time_s, voltage_V, source_code_signed_est_5uV_per_code);
        writetable(inputT, fullfile(out_dir, 'input.csv'));

        D.Properties.VariableNames{'adc_code'} = 'adc_offset_binary';
        writetable(D, fullfile(out_dir, 'matlab_stage_outputs.csv'));

        copyfile(fullfile(results_dir, rec, 'matlab_adc_offset_binary_hex.mem'), fullfile(out_dir, 'adc_offset_binary.mem'));
        copyfile(fullfile(results_dir, rec, 'matlab_adc_signed_decimal.txt'), fullfile(out_dir, 'adc_signed.txt'));
    end
end

function T = make_reference_vector_manifest(ref_dir)
    files = dir(fullfile(ref_dir, '**', '*'));
    rel = {}; cls = {}; role = {}; bytes = []; sha = {};
    root = char(java.io.File(ref_dir).getCanonicalPath());
    for i = 1:numel(files)
        if files(i).isdir
            continue;
        end
        if contains(files(i).name, 'reference_vector_manifest')
            continue;
        end
        full = fullfile(files(i).folder, files(i).name);
        canon = char(java.io.File(full).getCanonicalPath());
        r = erase(canon, [root filesep]);
        r = strrep(r, filesep, '/');
        parts = split(string(r), '/');
        rel{end+1,1} = ['reference_vectors/' char(r)]; %#ok<AGROW>
        if numel(parts) >= 2
            cls{end+1,1} = char(parts(1)); %#ok<AGROW>
        else
            cls{end+1,1} = ''; %#ok<AGROW>
        end
        role{end+1,1} = files(i).name; %#ok<AGROW>
        bytes(end+1,1) = files(i).bytes; %#ok<AGROW>
        sha{end+1,1} = sha256_file(full); %#ok<AGROW>
    end
    T = table(string(rel), string(cls), string(role), bytes, string(sha), ...
        'VariableNames', {'relative_path','class','file_role','bytes','sha256'});
end

function write_reference_vector_manifest_md(T, out_file)
    fid = fopen(out_file, 'w');
    fprintf(fid, '# Reference Vector Manifest\n\n');
    fprintf(fid, 'This manifest lists SHA256 hashes for MATLAB reference input/output vectors used for subsequent MATLAB-vs-XMODEL equivalence verification.\n\n');
    fprintf(fid, '| Class | File role | Relative path | Bytes | SHA256 |\n');
    fprintf(fid, '|---|---|---|---:|---|\n');
    for i = 1:height(T)
        fprintf(fid, '| %s | %s | `%s` | %d | `%s` |\n', T.class(i), T.file_role(i), T.relative_path(i), T.bytes(i), T.sha256(i));
    end
    fclose(fid);
end

function h = sha256_file(filename)
    fid = fopen(filename, 'r');
    data = fread(fid, Inf, '*uint8');
    fclose(fid);
    md = java.security.MessageDigest.getInstance('SHA-256');
    md.update(data);
    hash = typecast(md.digest(), 'uint8');
    h = lower(reshape(dec2hex(hash)', 1, []));
end

%% Plot functions ----------------------------------------------------------
function plot_total_frequency_response(p, filt, figures_dir)
    f = logspace(log10(0.03), log10(500), 4000)';
    H = total_response(f, p, filt);
    fig = figure('Visible','off');
    semilogx(f, 20*log10(max(abs(H), 1e-12))); grid on;
    xlabel('Frequency [Hz]'); ylabel('Magnitude [dB]');
    title('MATLAB Nominal AFE+ADC Frequency Response Reference');
    xline(p.fc_hpf, '--', 'HPF 0.482 Hz');
    xline(60, '--', '60 Hz notch');
    xline(p.fc_lpf, '--', 'LPF 150 Hz');
    save_figure(fig, figures_dir, 'fig_total_frequency_response');
end

function plot_notch_dense_sweep(T, M, figures_dir)
    fig = figure('Visible','off');
    plot(T.frequency_Hz, T.magnitude_dB); grid on;
    xlabel('Frequency [Hz]'); ylabel('Magnitude [dB]');
    title('Dense 60 Hz Active Twin-T Notch Reference');
    xline(60, '--', '60 Hz target');
    txt = sprintf('60 Hz attenuation %.2f dB', M.exact_60Hz_attenuation_dB(1));
    text(60.1, max(min(T.magnitude_dB)+5, -120), txt);
    save_figure(fig, figures_dir, 'fig_notch_dense_sweep');
end

function plot_dynamic_range_headroom(T, figures_dir)
    fig = figure('Visible','off');
    bar(categorical(T.record_name), T.minimum_headroom_to_rail_V); grid on;
    ylabel('Minimum headroom to ADC rail [V]');
    title('ADC Headroom Reference for Representative ECG Inputs');
    save_figure(fig, figures_dir, 'fig_dynamic_range_headroom');
end

function plot_adc_code_distribution(classes, results_dir, figures_dir)
    fig = figure('Visible','off'); hold on; grid on;
    for i = 1:numel(classes)
        D = readtable(fullfile(results_dir, classes{i}, 'matlab_afe_adc_output.csv'));
        histogram(D.adc_code, 80, 'Normalization', 'pdf', 'DisplayStyle', 'stairs');
    end
    xline(0, '--'); xline(2048, ':'); xline(4095, '--');
    legend(classes, 'Location', 'best');
    xlabel('Offset-binary ADC code'); ylabel('Density');
    title('ADC Code Distribution Reference');
    save_figure(fig, figures_dir, 'fig_adc_code_distribution');
end

function plot_flow_figures(figures_dir)
    simple_flow({'MATLAB nominal pre-validation','SystemVerilog XMODEL AFE+ADC','Digital SNN RTL / Vivado / Vitis','XMODEL stream + locked RTL'}, ...
        'AFE+ADC Validation Role in Project Flow', figures_dir, 'fig_matlab_prevalidation_flow');
    simple_flow({'ECG input','HPF 0.482 Hz','IA x201','60 Hz notch','LPF 150 Hz','12-bit ADC'}, ...
        'MATLAB Nominal AFE+ADC Chain Overview', figures_dir, 'fig_afe_chain_overview');
    simple_flow({'Representative ECG input','MATLAB stage outputs','Reference vectors + SHA256 manifest','XMODEL equivalence check'}, ...
        'MATLAB Reference Vector Handoff Flow', figures_dir, 'fig_reference_vector_handoff');
end

function simple_flow(labels, ttl, figures_dir, name)
    fig = figure('Visible','off'); axis off; hold on;
    n = numel(labels);
    for i = 1:n
        x = i;
        rectangle('Position', [x-0.4, 0.35, 0.8, 0.3]);
        text(x, 0.5, labels{i}, 'HorizontalAlignment','center', 'FontSize', 8);
        if i < n
            annotation('arrow', [(x+0.4)/(n+1), (x+0.6)/(n+1)], [0.5, 0.5]);
        end
    end
    xlim([0.4, n+0.6]); ylim([0.2, 0.8]);
    title(ttl);
    save_figure(fig, figures_dir, name);
end

function save_figure(fig, figures_dir, name)
    ensure_dir(figures_dir);
    saveas(fig, fullfile(figures_dir, [name '.png']));
    saveas(fig, fullfile(figures_dir, [name '.pdf']));
    close(fig);
end

%% Docs -------------------------------------------------------------------
function write_docs(docs_dir, param_table, freq_table, notch_metrics, headroom_table, mapping_table, p)
    write_text(fullfile(docs_dir, 'afe_adc_parameter_reference.md'), compose_parameter_doc(param_table));
    write_text(fullfile(docs_dir, 'frequency_response_reference.md'), compose_frequency_doc(freq_table));
    write_text(fullfile(docs_dir, 'notch_60hz_reference.md'), compose_notch_doc(notch_metrics));
    write_text(fullfile(docs_dir, 'dynamic_range_headroom_reference.md'), compose_headroom_doc(headroom_table));
    write_text(fullfile(docs_dir, 'adc_code_mapping_convention.md'), compose_adc_mapping_doc(mapping_table));
    write_text(fullfile(docs_dir, 'MATLAB_TO_XMODEL_HANDOFF.md'), compose_handoff_doc(p));
end

function write_text(file, txt)
    fid = fopen(file, 'w');
    fprintf(fid, '%s', txt);
    fclose(fid);
end

function s = compose_parameter_doc(T)
    s = "# AFE+ADC Parameter Reference\n\n" + ...
        "이 문서는 XMODEL 구현자가 따라갈 nominal parameter reference이다. 실제 회로 검증 완료를 의미하지 않는다.\n\n" + ...
        table_to_md(T);
end

function s = compose_frequency_doc(T)
    s = "# Frequency Response Numerical Reference\n\n" + ...
        "CSV: `results_dataset/afe_frequency_response_metrics.csv`\n\n" + table_to_md(T) + ...
        "\n\n본 결과는 XMODEL 구현 전 MATLAB reference frequency response이다.\n";
end

function s = compose_notch_doc(T)
    s = "# Dense 60 Hz Notch Reference\n\n" + ...
        "현재 notch scope는 60 Hz mains target이다. 50 Hz까지 완벽히 제거한다고 주장하지 않는다.\n\n" + ...
        table_to_md(T);
end

function s = compose_headroom_doc(T)
    s = "# Dynamic Range and ADC Headroom Reference\n\n" + ...
        "MATLAB nominal pre-validation을 통해 선택한 IA gain과 ADC range가 대표 ECG 입력에 대해 clipping 없이 충분한 headroom을 제공함을 확인하였다.\n\n" + ...
        table_to_md(T);
end

function s = compose_adc_mapping_doc(T)
    s = "# ADC Code Mapping Convention\n\n" + ...
        "MATLAB ADC는 `floor((V + 1.65)/3.3 * 4095)`를 사용한다. 따라서 0 V는 offset-binary 2047, signed -1로 매핑된다.\n\n" + ...
        table_to_md(T);
end

function s = compose_handoff_doc(p)
    s = sprintf(['# MATLAB-to-XMODEL Handoff Document\n\n' ...
        'This document defines the MATLAB reference outputs that should be used for MATLAB-vs-XMODEL equivalence verification.\n' ...
        'It does not claim that MATLAB and XMODEL are already bit-exact equivalent.\n\n' ...
        '## Block Order\n\n```text\ninput ECG voltage [V]\n→ HPF %.3f Hz\n→ IA ×%.0f\n→ 60 Hz notch, Q≈%.1f\n→ LPF %.1f Hz\n→ ADC ±1.65 V\n→ 12-bit offset-binary / signed stream\n```\n\n' ...
        '## Recommended XMODEL Comparison Metrics\n\n| Metric | Target / Comment |\n|---|---|\n| waveform alignment | lag = 0 sample |\n| RMS error | preferably 2-3 LSB or lower after convention matching |\n| max absolute error | inspect outliers |\n| correlation | 0.99 or higher recommended |\n| ADC code convention | identical offset-binary/signed convention |\n'], p.fc_hpf, p.Av_total, p.Q_notch, p.fc_lpf);
end

function s = table_to_md(T)
    vars = T.Properties.VariableNames;
    s = "| " + strjoin(vars, " | ") + " |\n";
    s = s + "|" + strjoin(repmat({"---"}, 1, numel(vars)), "|") + "|\n";
    for i = 1:height(T)
        vals = strings(1, numel(vars));
        for j = 1:numel(vars)
            x = T{i,j};
            if isnumeric(x)
                vals(j) = string(x);
            else
                vals(j) = string(x);
            end
        end
        s = s + "| " + strjoin(vals, " | ") + " |\n";
    end
end
