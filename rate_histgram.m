% Load the data from a MAT file
clear; clc; close all;
addpath('src')

load('./data/ADdataDraco_04032024');  % Adjust the filename as needed

% Define configuration parameters
binSize = 0.2;  % Bin size for computing firing rates in seconds

% Initialize arrays to collect all firing rates
all_firing_rates_v4 = [];
all_firing_rates_v4e = [];

% Loop through the entries in the dataset
for i = 1:min(200, length(d))
    % Process v4counts for each day
    if ~isempty(d(i).v4counts) && ~all(d(i).v4counts(:) == 0)
        % Compute firing rates for each channel on this day
        v4counts_current = d(i).v4counts;
        firing_rates_v4 = sum(v4counts_current, 2) / (size(v4counts_current, 2) * binSize);
        all_firing_rates_v4 = [all_firing_rates_v4; firing_rates_v4];  % Append to overall array
    end
    
    % Process v4ecounts for each day
    if ~isempty(d(i).v4ecounts) && ~all(d(i).v4ecounts(:) == 0)
        % Compute firing rates for each channel on this day
        v4ecounts_current = d(i).v4ecounts;
        firing_rates_v4e = sum(v4ecounts_current, 2) / (size(v4ecounts_current, 2) * binSize);
        all_firing_rates_v4e = [all_firing_rates_v4e; firing_rates_v4e];  % Append to overall array
    end
end

% Plotting the histograms for all collected firing rates
% Histogram for v4
figure;
histogram(all_firing_rates_v4, 'BinWidth', 2, 'FaceColor', 'b');
xlabel('Firing Rate (spikes/s)');
ylabel('Channel Count');
title('Histogram of Firing Rates for V4');
grid on;

% Histogram for v4e
figure;
histogram(all_firing_rates_v4e, 'BinWidth', 2, 'FaceColor', 'r');
xlabel('Firing Rate (spikes/s)');
ylabel('Channel Count');
title('Histogram of Firing Rates for V4e');
grid on;