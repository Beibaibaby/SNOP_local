file_pattr = 'monkey_output_';
days_to_analyze = [23, 27, 28, 29, 34, 36, 38, 43, 44, 45, 50];

% Initialize the cell arrays and other variables
cost_trace = {};
time_trace = {};
min_costs = []; % Initialize the minimum costs array
optimal_paras = []; % Initialize the array to store optimal parameters

for dayIndex = 1:length(days_to_analyze)
    jobid = days_to_analyze(dayIndex);

    y_trains = [];
    x_trains = [];
    stats = [];
    parass = [];

    results_name = strcat('./results_new/', file_pattr, string(jobid), '.mat');
    stats_name = strcat('./results_new/', file_pattr, string(jobid), '_stats.mat');
    stats_day_name = strcat('./data/stats_day', string(jobid), '.mat'); % Correct path to the stats file

    load(results_name);
    file_info = load(results_name, '-mat');
    disp(file_info);

    load(stats_name);
    file_info = load(stats_name, '-mat');
    disp(file_info);


    load(stats_day_name); % Load the correct day stats file
    fprintf('successfully loaded results and stats for day %d \n', jobid);

    y_trains = [y_trains; y_train];
    x_trains = [x_trains; x_train];
    stats = full_stats;
    parass = [parass; paras];
    cost_trace{end+1} = y_train;
    time_trace{end+1} = optimization_time;
    [I, J] = min(y_trains);
    [I, J] = min(y_trains);
    fprintf('The minimum value occurs at index: %d\n', J);
    % Check for NaN values in the 'objective' column
nan_indices = isnan(full_stats.objective);

% Exclude rows with NaN values in the 'objective' column
cleaned_full_stats = full_stats(~nan_indices, :);
disp('Size of cleaned full_stats:');
disp(size(cleaned_full_stats));
% Find the minimum value in the 'objective' column and its index
[min_value, min_index] = min(cleaned_full_stats.objective);

% Retrieve the row with the smallest objective value
min_row = cleaned_full_stats(min_index, :);

% Print the row with the smallest objective value
disp('Row with the smallest objective value:');
disp(min_row);

    min_costs = [min_costs, I];
    optimal_paras = [optimal_paras; x_trains(J, :)];
    pa1 = x_trains(J, 1);
    J = parass{:, 1} == pa1;
    pas = parass{J, :};
    pas = pas(1, :);
    min_stats_mean(jobid, :) = mean(stats{J, [2, 4:end]}, 1);
    target_stats_mean(jobid, :) = [true_statistics.rate_mean, true_statistics.fano_mean, true_statistics.mean_corr_mean, true_statistics.fa_percent_mean, true_statistics.fa_dim_mean, true_statistics.fa_normeval_mean];
    fprintf('successfully loaded file %d \n', jobid);
    fprintf('target stats: fr: %.2f, ff: %.2f, rsc: %.3f, psh: %.1f, dsh: %.1f, es (1st): %.1f \n',...
            target_stats_mean(jobid, 1), target_stats_mean(jobid, 2), target_stats_mean(jobid, 3),...
            target_stats_mean(jobid, 4) * 100, target_stats_mean(jobid, 5), target_stats_mean(jobid, 6));
    fprintf('customized stats: fr: %.2f, ff: %.2f, rsc: %.3f, psh: %.1f, dsh: %.1f, es (1st): %.1f \n',...
            min_stats_mean(jobid, 1), min_stats_mean(jobid, 2), min_stats_mean(jobid, 3),...
            min_stats_mean(jobid, 4) * 100, min_stats_mean(jobid, 5), min_stats_mean(jobid, 6));
    disp(size(optimal_paras));
    fprintf('optimal parameter set: taudsynI: %.2f, taudsynE: %.2f, mean_sigmaRRIs: %.2f, mean_sigmaRREs: %.2f, mean_sigmaRXs: %.2f, JrEI: %.2f, JrIE: %.2f, JrII: %.2f, JrEE: %.2f, JrEX: %.2f, JrIX: %.2f \n',...
            optimal_paras(dayIndex,:));
    disp('~~~~~~~~~~~~~~~~~~~~');
end