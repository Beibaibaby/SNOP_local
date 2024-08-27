clear; clc; close all;
addpath('src')
addpath(fullfile('src', 'fa_Yu')); % Add this line
% Load data
load('/Users/dracoxu/Research/SNOP_local/data_dave/1.mat')
spkmat = areaData.LIP.spont(1).X';  % Note the transpose here
[n_neurons, n_timepoints] = size(spkmat);

fprintf('LIP data size (number of neurons) x (number of time points): %s\n', mat2str(size(spkmat)));

% Define analyzeNeuralData function
function [rate1, var1, FanoFactor1, mean_corr1, percentSharedVariance, dimensionality, eigenspectrum] = analyzeNeuralData(re1_s)
    % Bin width in seconds
    binWidth = 0.1; % 100 ms = 0.1 s
    
    % Compute covariance and extract variance
    COV = cov(re1_s');
    Var = diag(COV);
    
    % Compute mean variance and mean firing rate (considering bin width)
    var1 = mean(Var) / binWidth; % Variance scaled by bin width
    rate1 = mean(mean(re1_s, 2)) / binWidth; % Rate per second
    
    % Compute Fano Factor (considering bin width)
    FanoFactor1 = var1/rate1;
    
    % Compute correlation coefficients
    R = COV ./ sqrt(Var * Var');
    upper_R = R(triu(true(size(R)), 1));
    mean_corr1 = nanmean(rtoZ(upper_R));
    
    % Calculate percent shared variance
    totalVariance = sum(Var);
    sharedVariance = sum(sum(COV - diag(Var)));
    percentSharedVariance = sharedVariance / totalVariance;
    
    % Calculate dimensionality of the shared variance
    eigenValues = eig(COV);
    eigenspectrum = sort(eigenValues, 'descend');
    cumulativeVarianceExplained = cumsum(eigenspectrum) / sum(eigenspectrum);
    dimensionality = find(cumulativeVarianceExplained >= 0.95, 1); % Adjust threshold as necessary
end

% Define rtoZ function
function Z = rtoZ(r)
    % RTOZ translates Fisher r correlations into Z scores
    % Jittering to avoid division by zero or log of zero
    if any(r <= -1) || any(r >= 1)
        error('r values must be bounded by -1 and 1');
    end
    Z = 0.5 * log((1 + r + 1e-10) ./ (1 - r + 1e-10));
end

% Main script to analyze data
[rate1, var1, FanoFactor1, mean_corr1, percentSharedVariance, dimensionality, eigenspectrum] = analyzeNeuralData(spkmat);
fprintf('Mean Rate: %f, Mean Variance: %f, Mean Fano Factor: %f, Mean Correlation: %f\n', rate1, var1, FanoFactor1, mean_corr1);
fprintf('Percent Shared Variance: %f, Dimensionality: %d\n', percentSharedVariance, dimensionality);
fprintf('Eigenspectrum (Top 5): %s\n', mat2str(eigenspectrum(1:5))); % Print top 5 eigenvalues for brevity

% Define parameters for population analysis
n_samples = 100; % Number of samples to analyze
n_sampled_neurons = min(50, round(0.8 * n_neurons)); % Sample 60 neurons or 80% if less than 60 are available
sampling_inds = randi([1 n_neurons], n_samples, n_sampled_neurons);% Random sampling indices

Tw = 100; % Increased time window size
dim_method = 'PA'; % Dimensionality reduction method to use

% Compute population statistics using the provided function
[fa_percentshared, fa_normevals, fa_dshared] = compute_pop_stats(sampling_inds, spkmat, n_sampled_neurons, Tw, dim_method);

% Display the results
fprintf('Average Percent Shared Variance: %.2f%%\n', fa_percentshared * 100);
fprintf('Average Dimensionality of Shared Variance: %.2f\n', fa_dshared);
fprintf('Eigenspectrum (First 5 values): %s\n', mat2str(fa_normevals(1:5), 6));


