close all;
clear; 
clc; % Clear the console

% Add necessary paths
addpath('src')
addpath(fullfile('src', 'fa_Yu'));

% Load data
load('/Users/dracoxu/Research/SNOP_local/data_dave/1.mat')
spkmat = areaData.FEF1.spont(10).X'; % Note the transpose here
[n_neurons, n_timepoints] = size(spkmat);
fprintf('FEF1 data size (number of neurons) x (number of time points): %s\n', mat2str(size(spkmat)));

% Main analysis
[rate1, var1, FanoFactor1, mean_corr1, percentSharedVariance, d_sh, eigenspectrum] = analyzeNeuralData(spkmat);

% Display results
displayResults(rate1, var1, FanoFactor1, mean_corr1, percentSharedVariance, d_sh, eigenspectrum);

n_samples = 100;
n_sampled_neurons = min(50, round(0.8 * n_neurons));
sampling_inds = randi([1 n_neurons], n_samples, n_sampled_neurons);
Tw = 100;
dim_method = 'PA';
[fa_percentshared, fa_normevals, fa_dshared] = compute_pop_stats(sampling_inds, spkmat, n_sampled_neurons, Tw, dim_method);
fprintf('FA: Average Percent Shared Variance: %.2f%%\n', fa_percentshared * 100);
fprintf('FA: Average Dimensionality of Shared Variance: %.2f\n', fa_dshared);
fprintf('FA: Eigenspectrum (First 5 values): %s\n', mat2str(fa_normevals(1:5), 6));

fano_var = 1/FanoFactor1;
mean_corr_var = 1/mean_corr1;
fa_percent_var = 0.0001;
fa_dim_var = 0.0001;
fa_normeval_var = 0.0001;
default_weights = ones(1,6);

%%%all the variance here need to be fixed

true_statistics = table(n_sampled_neurons, rate1, 1/rate1, FanoFactor1, fano_var, mean_corr1, mean_corr_var, fa_percentshared, fa_percent_var, fa_dshared, fa_dim_var, fa_normevals, fa_normeval_var, default_weights, ...
                            'VariableNames', {'n_neuron', 'rate_mean', 'rate_var', 'fano_mean', 'fano_var', 'mean_corr_mean', 'mean_corr_var', 'fa_percent_mean', 'fa_percent_var', 'fa_dim_mean', 'fa_dim_var', 'fa_normeval_mean', 'fa_normeval_var', 'default_weights'});


% Optionally save the statistics table to a file
output_file_name = './data_dave/dave_10.mat';
save(output_file_name, 'true_statistics');

disp(true_statistics);  % Display the results for this dataset
% Function definitions
function [rate1, var1, FanoFactor1, mean_corr1, percentSharedVariance, d_sh, eigenspectrum] = analyzeNeuralData(re1_s)
    binWidth = 0.1; % 100 ms = 0.1 s
    COV = cov(re1_s');
    Var = diag(COV);
    
    var1 = mean(Var) / binWidth;
    rate1 = mean(mean(re1_s, 2)) / binWidth;
    FanoFactor1 = var1/rate1;
    
    % Correlation calculation remains the same
    R = COV ./ sqrt(Var * Var');
    upper_R = R(triu(true(size(R)), 1));
    mean_corr1 = nanmean(rtoZ(upper_R));
    
    % Corrected shared variance calculation
    totalVar = sum(sum(COV));
    individualVar = sum(Var);
    sharedVar = totalVar - individualVar;
    percentSharedVariance = min(100, max(0, (sharedVar / totalVar) * 100));
    
    % Shared covariance matrix and eigenspectrum calculation
    sharedCOV = COV - diag(diag(COV));
    eigenValues = eig(sharedCOV);
    eigenspectrum = sort(max(eigenValues, 0), 'descend');
    eigenspectrum = eigenspectrum / sum(eigenspectrum);
    
    cumulativeVarianceExplained = cumsum(eigenspectrum);
    d_sh = find(cumulativeVarianceExplained >= 0.95, 1);
    if isempty(d_sh)
        d_sh = sum(eigenspectrum > 0);
    end
end

function Z = rtoZ(r)
    if any(r <= -1) || any(r >= 1)
        error('r values must be bounded by -1 and 1');
    end
    Z = 0.5 * log((1 + r + 1e-10) ./ (1 - r + 1e-10));
end

function displayResults(rate1, var1, FanoFactor1, mean_corr1, percentSharedVariance, d_sh, eigenspectrum)
    fprintf('Mean Rate: %.2f, Mean Variance: %.2f, Mean Fano Factor: %.2f, Mean Correlation: %.4f\n', ...
            rate1, var1, FanoFactor1, mean_corr1);
    fprintf('Percent Shared Variance (%% sh): %.2f%%\n', percentSharedVariance);
    fprintf('Dimensionality of Shared Variance (d_sh): %d\n', d_sh);
    fprintf('Eigenspectrum (Top 5 normalized values): %s\n', mat2str(eigenspectrum(1:5), 4));
    
    figure;
    plot(eigenspectrum, 'o-');
    title('Normalized Eigenspectrum of Shared Covariance');
    xlabel('Dimension');
    ylabel('Normalized Eigenvalue');
    xlim([1, min(20, length(eigenspectrum))]);
end

function performMultiScaleAnalysis(spkmat, n_neurons)
    bin_sizes = [1, 2, 5, 10]; % 100ms, 200ms, 500ms, 1s
    for i = 1:length(bin_sizes)
        rebinned = sum(reshape(spkmat, n_neurons, [], bin_sizes(i)), 3);
        [~, ~, ~, ~, pSV, d_sh, ~] = analyzeNeuralData(rebinned);
        fprintf('Bin size: %d ms, Percent Shared Variance: %.2f%%, d_sh: %d\n', ...
                bin_sizes(i)*100, pSV, d_sh);
    end
end

function performNormalizedAnalysis(spkmat)
    spkmat_zscore = zscore(spkmat, 0, 2);
    [~, ~, ~, ~, pSV_norm, d_sh_norm, ~] = analyzeNeuralData(spkmat_zscore);
    fprintf('Normalized data - Percent Shared Variance: %.2f%%, d_sh: %d\n', ...
            pSV_norm, d_sh_norm);
end

function analyzeGlobalFluctuations(spkmat)
    pop_rate = mean(spkmat, 1);
    [r, ~] = corr(pop_rate', spkmat');
    figure;
    histogram(r, 20);
    title('Correlation of Neurons with Population Rate');
    xlabel('Correlation Coefficient');
    ylabel('Count');
end

