function [rate0, var0, FanoFactor0, mean_corr0, unstable_flag, sampling_inds, re_filtered, low_rate_flag] = compute_stats_count(re, Ic1, n_sampling, n_neuron, check_stability)
    %% Wrapper function for computing the single-neuron and pairwise statistics of the given spike count matrix
    %   -Input
    %     re: [number of neurons, number of bins], spike count matrix
    %     Ic1: [number of E neurons], indices of the E neurons in the recurrent layer
    %     n_sampling: int, number of neuron samplings for averaging the activity stats
    %     n_neuron: int, number of neurons per sampling
    %     check_stability: {0, 1}, check if the spiking activity is stable

    % Initialize flags
    low_rate_flag = false;
    unstable_flag = false;

    % Threshold for low firing rate (in Hz, assuming time is in milliseconds)
    rate_th = 0.5; % low firing rate threshold
    high_rate_th = 100; % high firing rate threshold

    % Filter neurons based on Ic1 indices if provided
    if ~isempty(Ic1)
        re = re(Ic1, :);
    end

    % Check if there are enough neurons after filtering
    if size(re, 1) < n_neuron
        warning('Not enough neurons available for the analysis.');
        low_rate_flag = true;
        rate0 = NaN;
        var0 = NaN;
        FanoFactor0 = NaN;
        mean_corr0 = NaN;
        sampling_inds = NaN;
        re_filtered = NaN;
        return;
    end

    binSize = 0.2; 
    % Stability and firing rate checks
    mean_rates = sum(re, 2) / (size(re, 2) * binSize);
    
    if any(mean_rates < rate_th) || any(mean_rates > high_rate_th)
        low_rate_flag = true;
    end
    if check_stability
        % Implement any stability check if applicable
        % unstable_flag = is_unstable(re); % Placeholder for stability check
    end

    % Filter out neurons with extreme firing rates
    re_filtered = re(mean_rates >= rate_th & mean_rates <= high_rate_th, :);
    if isempty(re_filtered)
        warning('All neurons have extreme firing rates.');
        rate0 = NaN;
        var0 = NaN;
        FanoFactor0 = NaN;
        mean_corr0 = NaN;
        sampling_inds = NaN;
        re_filtered = NaN;
        return;
    end

    % Sampling neurons and computing statistics
    sampling_inds = randperm(size(re_filtered, 1), n_neuron);
    rate0s = zeros(n_sampling, 1);
    var0s = zeros(n_sampling, 1);
    FanoFactor0s = zeros(n_sampling, 1);
    mean_corr0s = zeros(n_sampling, 1);

    for i = 1:n_sampling
        
        sampled_data = re_filtered(sampling_inds, :);
        tmp = re(sampling_inds, :);
        [rate0,var0, FanoFactor0, mean_corr0]=compute_statistics_only(tmp);
       rate0s(i)=rate0*1000/200; % look at all neurons for rate
       var0s(i)=var0;
       FanoFactor0s(i)=FanoFactor0;
       mean_corr0s(i)=mean_corr0;
    end

    % Averaging the statistics
    rate0 = mean(rate0s);
    var0 = mean(var0s);
    FanoFactor0 = mean(FanoFactor0s);
    mean_corr0 = mean(mean_corr0s);

    if isnan(rate0) || isnan(var0) || isnan(FanoFactor0) || isnan(mean_corr0)
        error('Invalid stats, possibly due to low firing rate and <=1 neuron passes the rate threshold!');
    end
end
