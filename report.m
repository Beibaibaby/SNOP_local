% Define the days to analyze
days_to_analyze = [23, 27, 28, 29, 34, 36, 38, 43, 44, 45, 50];

% Names for statistics and parameters
stat_names = {'fr', 'ff', 'rsc', 'psh', 'dsh', 'es (1st)'};
param_names = {'taudsynI', 'taudsynE', 'mean_sigmaRRIs', 'mean_sigmaRREs', 'mean_sigmaRXs', 'JrEI', 'JrIE', 'JrII', 'JrEE', 'JrEX', 'JrIX'};

% Initialize arrays to store data for plotting
all_target_stats = [];
all_customized_stats = [];
all_parameters = [];

% Data for each day, manually input based on your data provided
target_stats_data = [
    20.93, 2.80, 0.304, 100.0, 26.0/2, 0.0; % Day 23
    22.39, 3.78, 0.268, 100.0, 23.0/2, 0.0; % Day 27
    16.59, 1.87, 0.117, 100.0, 30.0/2, 0.0; % Day 28
    26.70, 2.75, 0.238, 100.0, 29.0/2, 0.0; % Day 29
    27.68, 2.16, 0.175, 100.0, 33.0/2, 0.0; % Day 34
    28.89, 2.37, 0.231, 100.0, 31.0/2, 0.0; % Day 36
    26.09, 3.11, 0.228, 100.0, 26.0/2, 0.0; % Day 38
    32.37, 3.04, 0.339, 100.0, 23.0/2, 0.0; % Day 43
    20.19, 2.88, 0.257, 100.0, 23.0/2, 0.0; % Day 44
    29.60, 3.22, 0.383, 100.0, 24.0/2, 0.0; % Day 45
    22.26, 2.75, 0.271, 100.0, 22.0/2, 0.0  % Day 50
];

customized_stats_data = [
    0.66, 1.70, 0.222, 93.0, 9.0, 3.4;    % Day 23
    2.70, 1.13, 0.043, 85.2, 10.1, 7.9;   % Day 27
    0.65, 1.68, 0.126, 92.6, 12.3, 2.4;   % Day 28
    1.37, 2.36, 0.088, 96.0, 13.7, 6.6;   % Day 29
    0.79, 1.96, 0.086, 93.7, 14.6, 2.9;   % Day 34
    0.71, 1.80, 0.149, 94.4, 12.1, 2.4;   % Day 36
    0.79, 2.42, 0.120, 93.2, 12.4, 5.1;   % Day 38
    1.55, 2.25, 0.202, 90.3, 11.3, 7.5;   % Day 43
    0.60, 1.79, 0.189, 92.4, 9.9, 2.7;    % Day 44
    0.75, 1.74, 0.404, 93.3, 6.6, 6.3;    % Day 45
    0.69, 2.02, 0.319, 95.5, 7.6, 4.3     % Day 50
];

% Concatenate all data for plotting
all_target_stats = target_stats_data;
all_customized_stats = customized_stats_data;

% Parameters (just a random example based on the structure you provided)
all_parameters = rand(11, length(param_names)); % You should fill this with real data

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