 load(strcat('./data/stats_day45.mat'))
 fprintf('successfully loaded file %d \n', jobid)
 disp(true_statistics)
 target_stats_mean = [true_statistics.rate_mean, true_statistics.fano_mean, true_statistics.mean_corr_mean, true_statistics.fa_percent_mean, true_statistics.fa_dim_mean,true_statistics.fa_normeval_mean];



file_pattr = 'monkey_output_';
nthread = 100;
min_costs=[]; %minimal cost for each customization task
optimal_paras=[]; %optimal parameter set for each customization task
min_stats_mean = zeros(nthread, 55);  %activity stats of the optimal parameter set (es has 50 entries, leading to a total of 55)
target_stats_mean = zeros(nthread, 6); %activity stats of the target data
cost_trace = {}; %trace of the cost over iteration for each customization task
time_trace = {}; %trace of the time over iteration for each customization task

for jobid=45:45
  y_trains = [];
  x_trains = [];
  stats = [];
  parass = [];

    results_name = strcat('./results_new/', file_pattr, string(jobid), '.mat');
    stats_name=strcat('./results_new/', file_pattr, string(jobid), '_stats.mat');

    load(results_name)
    load(stats_name)
    fprintf(results_name)
    fprintf(stats_name)

    y_trains=[y_trains;y_train];
    x_trains=[x_trains;x_train];
    stats = [stats;full_stats];
    parass = [parass;paras];
    cost_trace{end+1} = y_train;
    time_trace{end+1} = optimization_time;
    [I, J]=min(y_trains);
    min_costs = [min_costs, I];
    optimal_paras = [optimal_paras; x_trains(J, :)];
    disp(optimal_paras)
    pa1 = x_trains(J, 1);
    J = parass{:, 1} == pa1;
    pas = parass{J, :};
    pas = pas(1, :);
    min_stats_mean(jobid, :)=mean(stats{J,[2,4:end]},1);
    fprintf(strcat('./data/stats_day',string(jobid),'.mat'))

    load(strcat('./data/stats_day',string(jobid),'.mat'))
    fprintf('successfully loaded file %d \n', jobid)
    disp(true_statistics)
    
    target_stats_mean(jobid,:) = [true_statistics.rate_mean, true_statistics.fano_mean, true_statistics.mean_corr_mean, true_statistics.fa_percent_mean, true_statistics.fa_dim_mean,true_statistics.fa_normeval_mean];
    fprintf('successfully loaded file %d \n', jobid)
    fprintf('target stats: fr: %.2f, ff: %.2f, rsc: %.3f, psh: %.1f, dsh: %.1f, es (1st): %.1f \n',...
            target_stats_mean(jobid,1), target_stats_mean(jobid,2), target_stats_mean(jobid,3),...
            target_stats_mean(jobid,4)*100, target_stats_mean(jobid,5), target_stats_mean(jobid,6) )
    fprintf('customized stats: fr: %.2f, ff: %.2f, rsc: %.3f, psh: %.1f, dsh: %.1f, es (1st): %.1f \n',...
            min_stats_mean(jobid,1), min_stats_mean(jobid,2), min_stats_mean(jobid,3),...
            min_stats_mean(jobid,4)*100, min_stats_mean(jobid,5), min_stats_mean(jobid,6) )
    disp(size(optimal_paras));
    fprintf('optimal parameter set: taudsynI: %.2f, taudsynE: %.2f, mean_sigmaRRIs: %.2f, mean_sigmaRREs: %.2f, mean_sigmaRXs: %.2f, JrEI: %.2f, JrIE: %.2f, JrII: %.2f, JrEE: %.2f, JrEX: %.2f, JrIX: %.2f \n',...
            optimal_paras(:))
    disp('~~~~~~~~~~~~~~~~~~~~')


end


