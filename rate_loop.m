% Load the data from a MAT file
clear; clc; close all;
addpath('src')

load('./data/ADdataDraco_04032024');  % Adjust the filename as needed

% Display field names and details for each field in the structure
fields = fieldnames(d);
fprintf('Fields in the structure:\n');

% Define configuration parameters
binSize = 0.2;  % Bin size for computing firing rates in seconds

% Initialize arrays to store firing rates and days for both regions
all_firing_rates_v4 = zeros(min(200, length(d)), 1);
all_firing_rates_v4e = zeros(min(200, length(d)), 1);
all_days = zeros(min(200, length(d)), 1);

% Loop through the first 200 entries in the dataset
for i = 1:min(200, length(d))
    if isempty(d(i).dayNum)
        fprintf('Skipping Entry %d due to missing Day Number.\n', i);
        continue;
    end
    fprintf('\nProcessing Entry %d - Day: %s\n', i, num2str(d(i).dayNum));
    
    % Store day numbers
    all_days(i) = d(i).dayNum;
    
    % Process v4counts
    if isempty(d(i).v4counts) || all(d(i).v4counts(:) == 0)
        fprintf('No valid v4counts data for Day %d. Skipping calculation for v4.\n', d(i).dayNum);
        all_firing_rates_v4(i) = NaN;
    else
        v4counts_current = d(i).v4counts;
        firing_rates_v4 = mean(sum(v4counts_current, 2) / (size(v4counts_current, 2) * binSize));
        all_firing_rates_v4(i) = firing_rates_v4;
    end
    
    % Process v4ecounts
    if isempty(d(i).v4ecounts) || all(d(i).v4ecounts(:) == 0)
        fprintf('No valid v4ecounts data for Day %d. Skipping calculation for v4e.\n', d(i).dayNum);
        all_firing_rates_v4e(i) = NaN;
    else
        v4ecounts_current = d(i).v4ecounts;
        firing_rates_v4e = mean(sum(v4ecounts_current, 2) / (size(v4ecounts_current, 2) * binSize));
        all_firing_rates_v4e(i) = firing_rates_v4e;
    end
    
    % Display firing rates
    fprintf('Firing rates for Day %d - V4: %f, V4e: %f\n', d(i).dayNum, firing_rates_v4, firing_rates_v4e);
end

% Filter out zeros from all_days and their corresponding firing rates
non_zero_indices = all_days ~= 0;
filtered_days = all_days(non_zero_indices);
filtered_firing_rates_v4 = all_firing_rates_v4(non_zero_indices);
filtered_firing_rates_v4e = all_firing_rates_v4e(non_zero_indices);

% Plotting the average firing rates vs. days
figure;
set(gcf, 'Position', [100, 100, 1000, 600]); % Adjust width and height as needed
hold on;
plot(filtered_days, filtered_firing_rates_v4, 'o-b', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'V4');
plot(filtered_days, filtered_firing_rates_v4e, 's-r', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'V4e');
xlabel('Day Number');
ylabel('Average Firing Rate (spikes/s)');
title('Average Firing Rates vs. Days for V4 and V4e');
legend('show');
grid on;
hold off;

% Set y-axis limits
ylim([0 max([filtered_firing_rates_v4; filtered_firing_rates_v4e]) + 1]); % Add a buffer to the maximum value for better visibility