clc;
clear;
close all; 

% Author: Julianna Maria Moore & Nathan Geuzaine
% Assignment: Primary & Emergency Tank Modeling 
% Purpose: 
% Date: 10/29/2026

%% Important Considerations
% Shell dimensions and packaging [50 x 45 x 21.5 cm^3]
% Insulation thickness [1 cm]
% Regulator height and attachment []
% Do modeling for Spherical vs Cylindrical tanks   
% Center of mass
% Mounting integration within the shell
% Attachments with other components
% Structures team preference: Shrunken overall emergency tank

%% Emergency Tank Dimension Selection

% {CYLINDER w/ TWO DOME CAPS (c1, first cylinder configuration)}
% *REUSE* [Ideal Gas Law: PV=nRT]
    P = 25855350; % [Pa] (aka 3750 psia)
    n = (0.5523*1000)/(31.998); % grams of emergency O2 needed [g] / MW O2 [g/mol] = [mol]
    R = 8.3145; % [J/mol*K]
    T = 293.15; % [K]
    V_internal = (n*R*T) / (P); % internal volume in [m^3] needed for emergency O2 amount

% [Calculate Volume of Cylinder + Domes]
    D_vector_c1 = linspace(0.001, 0.15, 10); %[m], max of 10 cm or 0.1 m
    H_vector_c1 = linspace(0.01, 0.2, 10); %[m], max of 20 cm or 0.2m; OVERALL tank height including end caps

    [D_c1, H_tot_c1] = meshgrid(D_vector_c1, H_vector_c1); % computes every possible combination of volume instead of just 10 combos

    H_cyl_c1 = (H_tot_c1 - D_c1); % cylinder height only (excluding end caps)

    % Volume equations
    V_cyl_c1 = (pi * (D_c1).^2 .* (H_cyl_c1)) ./ (4); % [m^3]
    V_domes_c1 = (2)*((pi * (D_c1).^3) ./ (12)); % account for 2 dome caps
    V_tot_c1 = V_cyl_c1 + V_domes_c1; % cyl vol + 2 dome caps vol

    V_tot_c1(H_cyl_c1 < 0) = NaN;

% [Plot V_tot against vectors for Diameter and Height]
    figure();

    surf(D_c1, H_tot_c1, V_tot_c1);
    hold on;

    % Ideal internal volume (scaling)
    V_ideal = V_internal .* ones(size(V_tot_c1));

    surf(D_c1, H_tot_c1, V_ideal, 'FaceColor', 'magenta', 'FaceAlpha', 0.4, 'EdgeColor', 'none');

    grid on;
    title('Emergency Tank Volume Model: Cylindrical + 2 Dome Caps');
    xlabel('Diameter [m]');
    ylabel('Total Height (w/Edgecaps) [m]');
    zlabel('Volume [m^3]');
    legend('Tank Volumes vs. Ideal Volume');

    hold off;

% {CYLINDER w/ ONE DOME CAP (c2, second cylinder configuration)} 
% [Calculate Volume of Cylinder + One Dome Cap]
    D_vector_c2 = linspace(0.001, 0.15, 10); %[m], max of 10 cm or 0.1 m
    H_vector_c2 = linspace(0.01, 0.2, 10); %[m], max of 20 cm or 0.2m; OVERALL tank height including end caps

    [D_c2, H_tot_c2] = meshgrid(D_vector_c2, H_vector_c2); % computes every possible combination of volume instead of just 10 combos

    H_cyl_c2 = (H_tot_c2 - D_c2); % cylinder height only (excluding end caps)

    % Volume equations
    V_cyl_c2 = (pi * (D_c2).^2 .* (H_cyl_c2)) ./ (4); % [m^3]
    V_domes_c2 = (pi * (D_c2).^3) ./ (12); % account for 1 dome cap
    V_tot_c2 = V_cyl_c2 + V_domes_c2; % cyl vol + 1 dome cap vol

    V_tot_c2(H_cyl_c2 < 0) = NaN;

% [Plot V_tot against vectors for Diameter and Height]
    figure();

    surf(D_c2, H_tot_c2, V_tot_c2);
    hold on;

    % Ideal internal volume (scaling)
    V_ideal = V_internal .* ones(size(V_tot_c2));

    surf(D_c2, H_tot_c2, V_ideal, 'FaceColor', 'cyan', 'FaceAlpha', 0.4, 'EdgeColor', 'none');

    grid on;
    title('Emergency Tank Volume Model: Cylindrical + 1 Dome Cap');
    xlabel('Diameter [m]');
    ylabel('Total Height (w/Edgecap) [m]');
    zlabel('Volume [m^3]');
    legend('Tank Volumes vs. Ideal Volume');

    hold off;

% {SPHERE (s1, first sphere configuration)}

% [Calculate Volume of Sphere]
    D_vector_s1 = linspace(0.001, 0.17, 10); %[m], max of 17 cm or 0.17 m

    % Volume equation
    V_sphere_s1 = (1/6) * (pi .* (D_vector_s1).^3);

% [Plot spherical tank volume]
    figure();
    grid on;
    plot(D_vector_s1, V_sphere_s1, 'LineWidth', 2);
    hold on;
    % Display yarget internal volume
    yline(V_internal, 'r--', 'LineWidth', 2);
    xlabel('Sphere Diameter [m]');
    ylabel('Tank Volume [m^3]');
    title('Spherical Emergency Tank Volume Model');
    legend('Calculated Sphere Volume','Target Internal Volume');
    hold off;

%% Emergency Tank Material & FOS Modeling
% Need F.O.S = 2
% FOS = 2;
% Material: Carbon-Composite COPV, Metal-Lined
% Declare pressure variables


