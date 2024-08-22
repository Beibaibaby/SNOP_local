% Define the days to analyze
days_to_analyze = [23, 27, 28, 29, 34, 36, 38, 43, 44, 45, 50];

% Names for statistics and parameters
stat_names = {'fr', 'ff', 'rsc', 'psh', 'dsh', 'es (1st)'};
param_names = {'taudsynI', 'taudsynE', 'mean_sigmaRRIs', 'mean_sigmaRREs', 'mean_sigmaRXs', 'JrEI', 'JrIE', 'JrII', 'JrEE', 'JrEX', 'JrIX'};

% Initialize arrays to store data for plotting
all_target_stats = [];
all_customized_stats = [];
all_parameters = [];
min_stats_mean = zeros(55); % assuming stat_names matches the data dimensions

% Path patterns
file_pattr = 'monkey_output_';

for dayIndex = 1:length(days_to_analyze)
    jobid = days_to_analyze(dayIndex);

    % Load results and statistics for the current day
    results_name = strcat('./results_new/', file_pattr, string(jobid), '.mat');
    stats_name = strcat('./results_new/', file_pattr, string(jobid), '_stats.mat');
    stats_day_name = strcat('./data/stats_day', string(jobid), '.mat');

    load(results_name);
    load(stats_name);
    load(stats_day_name);

    fprintf('successfully loaded results and stats for day %d \n', jobid);

    % Extract statistics and parameters
    target_stats = [true_statistics.rate_mean, true_statistics.fano_mean, true_statistics.mean_corr_mean, true_statistics.fa_percent_mean, true_statistics.fa_dim_mean, true_statistics.fa_normeval_mean];
    all_target_stats = [all_target_stats; target_stats];

    % Find optimal parameter index and corresponding statistics
    [min_cost, idx] = min(y_train); % assuming y_train contains costs
    optimal_parameters = x_train(idx, :); % assuming x_train contains parameters
    min_stats = mean(stats{idx, [2,4:end]}, 1); % Adjusted to your structure and indices
    min_stats_mean(dayIndex, :) = min_stats;

    all_customized_stats = [all_customized_stats; min_stats];
    all_parameters = [all_parameters; optimal_parameters];

    fprintf('Optimal parameters and stats for day %d computed.\n', jobid);
end

% Plotting statistics comparison
figure;
lgd_entries = [];
for i = 1:length(stat_names)
    subplot(3, 2, i);
    p1 = plot(days_to_analyze, all_target_stats(:, i), 'bo-', 'DisplayName', 'Target');
    hold on;
    p2 = plot(days_to_analyze, all_customized_stats(:, i), 'rx-', 'DisplayName', 'Customized');
    title(sprintf('Comparison of %s', stat_names{i}));
    xlabel('Days');
    ylabel('Values');
    grid on;
    if i == 1 % Only add legend entries once
        lgd_entries = [p1; p2];
    end
end

% Place the legend outside the subplots
legend(lgd_entries, 'Location', 'eastoutside');

% Adjust figure size to accommodate the legend
set(gcf, 'Position', [100, 100, 700, 500]);

% Save the figure
saveas(gcf, 'Statistics_Comparison.png');

% Plotting parameters
figure;
num_params = length(param_names);
for i = 1:num_params
    subplot(4, ceil(num_params / 4), i); 
    plot(days_to_analyze, all_parameters(:, i), 'k.-', 'LineWidth', 1.5);
    title(param_names{i});
    xlabel('Days');
    ylabel('Value');
    grid on;
end
saveas(gcf, 'Parameters_Over_Days.png');