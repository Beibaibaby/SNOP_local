% Load the data
data = load('/Users/dracoxu/Research/SNOP_local/results_matt/matt_output_3_stats.mat');

% Check if 'full_stats' and 'paras' are tables and handle accordingly
full_stats = data.full_stats; % Make sure 'full_stats' is the correct variable name
paras = data.paras; % Make sure 'paras' is the correct variable name

% If 'full_stats' is a table, assume 'objective' is a column name
[min_value, idx] = min(full_stats.objective);

% Retrieve the corresponding parameters from 'paras'
% Check if 'paras' is a table and handle accordingly
if istable(paras)
    corresponding_parameters = paras(idx, :);
else
    corresponding_parameters = paras(idx, :); % This assumes 'paras' is a numeric matrix
end

% Display the results
disp('Minimum Objective Value:');
disp(min_value);
disp(full_stats(idx,:));
disp('Index Value:');
disp(idx);
disp('Corresponding Parameters:');
disp(corresponding_parameters);