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
    P = 25855350; % [Pa] (aka 3750 psia) internal pressure
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
% Configuration: Cylindrical Tank w/ Two Dome Caps
% Need F.O.S = 2
% Material: Carbon-Fiber COPV, Metal-Lined
% Operating Pressure: 25855350 [Pa] / 3750 [psia]
% Diameter (for ideal internal volume) = 11.69 cm; Height = 20 cm
% Internal Volume = 0.0016 m^3

% [Metal Liner Thickness]
% Material Choice: Alumnimum 6061-T6 
    % Reasoning: Common material, affordable, lightweight, good against corrosion 
    % *Initial assumption that metal-liner carries entire 3750 psia load*

% [FOS & Stress Equations for Metal Liner]
% FOS = sigma_fail / sigma_allow

FOS = 2;
sigma_fail_m = (276 * 10^6); % [Pa] / for Aluminum 6061-T6
sigma_allow_m = sigma_fail_m / FOS; 

% sigma_hoop = (P_internal * r_ideal) / (t)
r_ideal = 11.69/2; % [cm] / from ideal diameter of 11.69

t_cylinder = (P * r_ideal) / (sigma_allow_m);
t_dome = (P * r_ideal) / (2 * sigma_allow_m);
uniform_t = max(t_cylinder, t_dome);

% Check if thin-wall assumption is applicable
thin_wall_ratio = uniform_t / r_ideal; % should be <= 0.1

% thin wall ratio > 0.1 so use thick wall equations
t_cylinder_thick = (r_ideal) .* (sqrt((sigma_allow_m + P) ./ (sigma_allow_m - P)) - 1);
t_dome_thick = (r_ideal) .* (((2*sigma_allow_m + P) ./ (2*(sigma_allow_m - P))).^(1/3) - 1);
uniform_t_thick = max(t_cylinder_thick, t_dome_thick);

% External dimensions
D_external = 11.69 + (2 .* uniform_t_thick);
H_external = 20 + (2 .* uniform_t_thick);

% [Carbon-Fiber Overwrap Thickness]
% Material Choice: Torayca T800 Carbon-Fiber
    % Reasoning: Widely used in aero. applications, high yield strength

% [FOS & Stress Equations for Carbon Liner]
sigma_fail_c = (5.5 * 10^9); % [Pa] / for Torayca T800
sigma_allow_c = sigma_fail_c / FOS;

% Burst pressure is double the internal pressure load
P_burst = 2 * P;

% sigma_hoop = (P_internal * r_ideal) / (t)
r_carbon = D_external / 2;
t_cylinder_c = (P_burst * r_carbon) / (sigma_allow_c);
t_dome_c = (P_burst * r_carbon) / (2 * sigma_allow_c);
uniform_t_c = max(t_cylinder_c, t_dome_c);

% Check if thin-wall assumption is applicable
thin_wall_ratio_c = uniform_t_c / r_carbon; % should be <= 0.1

% Total thickness of metal + carbon liner
t_total = uniform_t_thick + uniform_t_c;

% Final dimension calculations for entire tank (external)
D_final = 11.69 + (2 .* t_total);
H_final = 20 + (2 .* t_total);

















