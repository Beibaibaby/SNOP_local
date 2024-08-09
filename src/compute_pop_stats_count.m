function [fa_percentshared, fa_normevals, fa_dshared] = compute_pop_stats_count(sampling_inds, re, n_neuron, Tw, dim_method)
    % Number of samples for averaging the results
    n_samples = size(sampling_inds, 1);

    % Initialize outputs
    fa_percentshared = zeros(n_samples, 1);
    fa_normevals = zeros(n_samples, n_neuron);  % Assuming n_neuron is the max dimension to consider
    fa_dshared = zeros(n_samples, 1);

    % Loop through each sample
    for k = 1:n_samples
        % Extract the data for this sample
        tmp = re(sampling_inds(k,:), :);

        % Perform PCA on the data
        C = cov(tmp');  % Compute the covariance matrix
        [V, D] = eig(C);  % Eigenvalue decomposition
        eigenvalues = diag(D);  % Extract the eigenvalues
        [sorted_eigenvalues, idx] = sort(eigenvalues, 'descend');  % Sort eigenvalues in descending order
        
        % Compute shared variance percentage
        total_variance = sum(sorted_eigenvalues);
        fa_percentshared(k) = sum(sorted_eigenvalues(1:n_neuron)) / total_variance;

        % Compute dimensionality of shared variance
        cumulative_variance = cumsum(sorted_eigenvalues) / total_variance;
        fa_dshared(k) = find(cumulative_variance >= 0.95, 1, 'first');  % Find the dimensionality that captures 95% of variance

        % Store normalized eigenvalues
        fa_normevals(k,:) = sorted_eigenvalues(1:n_neuron) / total_variance;
    end

    % Average results across samples
    fa_percentshared = mean(fa_percentshared);
    fa_normevals = mean(fa_normevals);
    fa_dshared = mean(fa_dshared);
end