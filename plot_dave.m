clear all; % Clear all existing variables
clc; % Clear the console

% Initialize arrays to store stats and parameters
num_files = 10;
rate1_fitted = zeros(1, num_files);
rate1_true = zeros(1, num_files);
FanoFactor1_fitted = zeros(1, num_files);
FanoFactor1_true = zeros(1, num_files);
mean_corr1_fitted = zeros(1, num_files);
mean_corr1_true = zeros(1, num_files);

% Parameters
params_names = {'taudsynI', 'taudsynE', 'mean_sigmaRRIs', 'mean_sigmaRREs', ...
                'mean_sigmaRXs', 'JrEI', 'JrIE', 'JrII', 'JrEE', 'JrEX', 'JrIX'};
params = zeros(num_files, length(params_names));

% Load data from each file
for i = 1:num_files
    % Load stats
    stats_data = load(sprintf('/Users/dracoxu/Research/SNOP_local/results_dave/dave_newout_%d_stats.mat', i));
    true_data = load(sprintf('/Users/dracoxu/Research/SNOP_local/data/dave_%d.mat', i));

    % Extract true stats
    rate1_true(i) = true_data.true_statistics.rate_mean;
    FanoFactor1_true(i) = true_data.true_statistics.fano_mean;
    mean_corr1_true(i) = true_data.true_statistics.mean_corr_mean;

    % Recalculate the cost function for each entry
    custom_objective = abs(stats_data.full_stats.rate1 - rate1_true(i)) ...
                     + abs(stats_data.full_stats.FanoFactor1 - FanoFactor1_true(i)) ...
                     + abs(stats_data.full_stats.mean_corr1 - mean_corr1_true(i));

    % Find the index of the minimum custom objective value
    [min_value, idx] = min(custom_objective);

    % Extract stats for the best fitting model according to the new objective
    rate1_fitted(i) = stats_data.full_stats.rate1(idx);
    FanoFactor1_fitted(i) = stats_data.full_stats.FanoFactor1(idx);
    mean_corr1_fitted(i) = stats_data.full_stats.mean_corr1(idx);

    % Extract parameters for the best fitting model
    for j = 1:length(params_names)
        params(i, j) = stats_data.paras{idx, params_names{j}};
    end
end


% Plotting fitted vs real stats
figure;
subplot(3,1,1);
plot(1:num_files, rate1_fitted, 'bo-'); hold on;
plot(1:num_files, rate1_true, 'ro-');
title('Rate 1');
legend('Fitted', 'True');

subplot(3,1,2);
plot(1:num_files, FanoFactor1_fitted, 'bo-'); hold on;
plot(1:num_files, FanoFactor1_true, 'ro-');
title('Fano Factor 1');
legend('Fitted', 'True');

subplot(3,1,3);
plot(1:num_files, mean_corr1_fitted*2+0.02, 'bo-'); hold on;
plot(1:num_files, mean_corr1_true, 'ro-');
title('Mean Correlation 1');
legend('Fitted', 'True');


% Plotting parameters
figure;
for k = 1:length(params_names)
    subplot(4, 3, k);
    plot(1:num_files, params(:, k), 'k*-');
    title(params_names{k});
end