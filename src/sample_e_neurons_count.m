function [Ic1] = sample_e_neurons_count(re, Ne1, is_simulation)
%% Obtain indices for the recurrent E neurons to compute activity statistics from a spike count matrix
%   -Input
%     re: [number of neurons, number of bins], spike count matrix
%     Ne1: int, number of E neurons in the recurrent layer per side (total number if Ne1^2)
%     is_simulation: {0,1}, if = 1, does not account for the periodic boundary condition for sampling neurons.

% Number of neurons
total_neurons = size(re, 1);

if is_simulation
    % Simulation mode: Simply take the first Ne1^2 neurons if they exist
    Ic1 = transpose(1:min(Ne1^2, total_neurons));
else
    % Non-simulation mode: Apply spatial filtering based on some criteria
    % Assuming neurons are laid out in a grid and indexed in some order that supports spatial reasoning
    Ix = ceil((1:total_neurons) / Ne1) / Ne1; % X coordinate normalized
    Iy = mod((1:total_neurons) - 1, Ne1) + 1 / Ne1; % Y coordinate normalized
    Ic1 = find(Ix < 0.75 & Ix > 0.25 & Iy < 0.75 & Iy > 0.25);
    Ic1 = Ic1(Ic1 <= Ne1^2);
end