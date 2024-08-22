% Load the data from a MAT file
clear; clc; close all;
addpath('src')

load('./data/ADdataDraco_04032024');  % Adjust the filename as needed

% Display field names and details for each field in the structure
fields = fieldnames(d);
fprintf('Fields in the structure:\n');

% Define configuration parameters
obj_configs = struct();
obj_configs.n_sampling = 100;  % Example: number of samplings
obj_configs.Tw = 50;           % Example: time window size for spike counts
obj_configs.Tburn = 100;       % Example: burn-in period to exclude from analysis
obj_configs.Ne1 = 25;          % Example: number of excitatory neurons considered
obj_configs.dim_method = 'PA'; % Dimensionality reduction method

% Loop through the first 10 entries in the dataset
for i = 1:min(20, length(d))
    fprintf('\nProcessing Entry %d - Day: %s\n', i, num2str(d(i).dayNum));

    % Access v4counts field
    v4counts_current = d(i).v4counts;

    % Check if the number of neurons is greater than 50
    if size(v4counts_current, 1) <= 50
        fprintf('Skipping day %d due to insufficient neuron count (%d neurons).\n', d(i).dayNum, size(v4counts_current, 1));
        continue;  % Skip to the next iteration of the loop if neuron count is 50 or less
    end

    if size(v4counts_current, 2) <= 80
        fprintf('Skipping day %d due to insufficient trials (%d neurons).\n', d(i).dayNum, size(v4counts_current, 2));
        continue;  % Skip to the next iteration of the loop if neuron count is 50 or less
    end

    if d(i).dayNum == 35
        fprintf('Skipping day 35 as per condition.\n');
        continue;  % Skip the current iteration and move to the next entry
    end

    if d(i).dayNum == 37
        fprintf('Skipping day 35 as per condition.\n');
        continue;  % Skip the current iteration and move to the next entry
    end


   
    fprintf('v4counts data size: %s\n', mat2str(size(v4counts_current)));

    % Save the current v4counts to a MAT file
    current_data_filename = sprintf('./data/spike_data_day%d.mat', d(i).dayNum);
    save(current_data_filename, 'v4counts_current');

    % Load the data for analysis
    re = v4counts_current;
    Ic1 = sample_e_neurons_count(re, 50, 1);
    %disp(Ic1)
    n_neuron = 50;
    n_sampling = 20;
    check_stability = 1;

    % Compute the statistics
    [rate0, var0, FanoFactor0, mean_corr0, unstable_flag, sampling_inds, re_filtered, low_rate_flag] = compute_stats_count(re, Ic1, n_sampling, n_neuron, check_stability);

    % Compute population statistics
    [fa_percentshared, fa_normevals, fa_dshared] = compute_pop_stats_count(sampling_inds, re, n_neuron, 200, 'PA');
     
    default_weights=ones(1,6);
     % Compile results into a table with consistent naming conventions
    rate_mean = rate0;
    rate_var = var0;
    fano_mean = FanoFactor0;
    fano_var = 0.0002;
    mean_corr_mean = mean_corr0;
    mean_corr_var = 2e-6;
    fa_percent_mean = fa_percentshared;
    fa_percent_var = 1e-6;
    fa_dim_mean = fa_dshared;
    fa_dim_var = 0.1;
    fa_normeval_mean = fa_normevals;
    fa_normeval_var = 0.01;
    default_weights = ones(1,6);

    true_statistics = table(n_neuron, rate_mean, rate_var, fano_mean, fano_var, mean_corr_mean, mean_corr_var, fa_percent_mean, fa_percent_var, fa_dim_mean, fa_dim_var, fa_normeval_mean, fa_normeval_var, default_weights, ...
                            'VariableNames', {'n_neuron', 'rate_mean', 'rate_var', 'fano_mean', 'fano_var', 'mean_corr_mean', 'mean_corr_var', 'fa_percent_mean', 'fa_percent_var', 'fa_dim_mean', 'fa_dim_var', 'fa_normeval_mean', 'fa_normeval_var', 'default_weights'});

    % Optionally save the statistics table to a file
    output_file_name = sprintf('./data/stats_day%d.mat', d(i).dayNum);
    save(output_file_name, 'true_statistics');

    disp(true_statistics);  % Display the results for this day
end