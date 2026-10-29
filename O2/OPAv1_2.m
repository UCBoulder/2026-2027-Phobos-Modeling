clc;
clear;
close all;
%% Oxygen, Pressure, and Atmosphere Model or OPA!
% Current Version: 1.1
% Currently models Oxygen Provision, Helmet Pressure, CO2 Concentration,
% and CO2 added pressure in mmHg during the course of an 8 hour EVA. 
% Running for Upper Bound EVA (6 hours resistive, 1.5 hours nom/recovery, 
% .5 hours aerobic).
% 
%  
% Assumptions:
% Helmet Volume at around 0.04 m^2
% Initial pressure = 29.647 kPa
% Operating at Room Temp for Whole duration
% Ideal mixing
%
% Upcoming Updates:
% Requirement Outlining
% H20 addition
% Leak of Mixture instead of pure O2 (need to check if pure O2 is good
% assumption)
% Imperfect CO2 Extraction
% Pertubations
% Monte Carlo Simulation Capability

%% Starting conditions 

V = 0.016; % helmet volume in m^3
P_o = 29.647 * 10^3; % Helmet initial Pressure in Pa
P_set = 30 * 10^3; % Regulator Set Pressure in Pa 
temperature = 293.15; % Helmet initial temperature in K
gasConstant = 8.314; % J/(mol*K)
moles_O2 = P_o * V / (gasConstant * temperature); % moles of O2

%% Metabolic Rates 
% *********************** 50th Percentile *********************************
% O2 Consumption
consumptionRate_mol_nom_50 = (0.59/32)/60; % 50th percentile Nominal Astronaut O2 consumption in mol/s O2
consumptionRate_mol_res_50 = (1.43/32)/60; % 50th percentile Astronaut O2 consumption in mol/s O2
consumptionRate_mol_aero_50 = (3.99/32)/60; % 50th percentile Astronaut O2 consumption in mol/s O2
consumptionRate_mol_rec_50 = (0.59/32)/60; % 50th percentile Astronaut O2 consumption in mol/s O2

% CO2 Output
output_CO2_nom_50 = (0.69 / 44)/60; % 50th percentile Astronaut CO2 consumption in mol/s CO2
output_CO2_res_50 = (1.89 / 44)/60; % 50th percentile Astronaut CO2 consumption in mol/s CO2
output_CO2_aero_50 = (5.22 / 44)/60; % 50th percentile Astronaut CO2 consumption in mol/s CO2
output_CO2_rec_50 = (0.69 / 44)/60; % 50th percentile Astronaut CO2 consumption in mol/s CO2

% Vapor Output

% Power Consumption

% *************************************************************************

% *********************** 95th Percentile Male ****************************
% O2 Consumption
consumptionRate_mol_nom_95 = (0.7135/32)/60; % 95th percentile Nominal Astronaut O2 consumption in mol/s O2
consumptionRate_mol_res_95 = (1.729/32)/60; % 95th percentile Astronaut O2 consumption in mol/s O2
consumptionRate_mol_aero_95 = (4.825/32)/60; % 95th percentile Astronaut O2 consumption in mol/s O2
consumptionRate_mol_rec_95 = (0.7135/32)/60; % 95th percentile Astronaut O2 consumption in mol/s O2

% CO2 Output
output_CO2_nom_95 = (0.8344 / 44)/60; % 95th percentile Astronaut CO2 consumption in mol/s CO2
output_CO2_res_95 = (2.2854 / 44)/60; % 95th percentile Astronaut CO2 consumption in mol/s CO2
output_CO2_aero_95 = (6.3122 / 44)/60; % 95th percentile Astronaut CO2 consumption in mol/s CO2
output_CO2_rec_95 = (0.8344 / 44)/60; % 95th percentile Astronaut CO2 consumption in mol/s CO2

% Vapor Output

% Power Consumption

% *************************************************************************

% *********************** 5th Percentile Female ****************************
% O2 Consumption
consumptionRate_mol_nom_5 = (0.3882/32)/60; % 5th percentile Nominal Astronaut O2 consumption in mol/s O2
consumptionRate_mol_res_5 = (0.9410/32)/60; % 5th percentile Astronaut O2 consumption in mol/s O2
consumptionRate_mol_aero_5 = (2.626/32)/60; % 5th percentile Astronaut O2 consumption in mol/s O2
consumptionRate_mol_rec_5 = (0.3882/32)/60; % 5th percentile Astronaut O2 consumption in mol/s O2

% CO2 Output
output_CO2_nom_5 = (0.4517 / 44)/60; % 5th percentile Astronaut CO2 consumption in mol/s CO2
output_CO2_res_5 = (1.2374 / 44)/60; % 5th percentile Astronaut CO2 consumption in mol/s CO2
output_CO2_aero_5 = (3.4175 / 44)/60; % 5th percentile Astronaut CO2 consumption in mol/s CO2
output_CO2_rec_5 = (0.4517 / 44)/60; % 5th percentile Astronaut CO2 consumption in mol/s CO2

% Vapor Output

% Power Consumption

% *************************************************************************

%% Vector Initialization
time = 0:8*3600; % time in seconds from 
N = length(time);
O2_consumption = zeros(1,N);
CO2_output = zeros(1,N);

% ***************** EVA Inputs ********************************************
% Assigns metabolic activity levels to 15 minute periods within EVA
% Nominal = "NOM" | Resistance = "RES" | Aerobic = "AERO" | Recovery = "REC"

Percentile_tracker = 95; % 95 = 95th Percentile Astroanut | 50 = 50th Percentile American Male | 5th Percentile Asian Female

% HOUR 1
EVA_index(1:15*60)             = "NOM"; % 0:00-0:15
EVA_index(15*60 + 1 : 30*60)   = "NOM"; % 0:15-0:30
EVA_index(30*60 + 1 : 45*60)   = "RES"; % 0:30-0:45
EVA_index(45*60 + 1 : 60*60)   = "RES"; % 0:45-1:00

% HOUR 2
EVA_index(60*60 + 1 : 75*60)   = "RES"; % 1:00-1:15
EVA_index(75*60 + 1 : 90*60)   = "RES"; % 1:15-1:30
EVA_index(90*60 + 1 : 105*60)  = "RES"; % 1:30-1:45
EVA_index(105*60 + 1 : 120*60) = "RES"; % 1:45-2:00

% HOUR 3
EVA_index(120*60 + 1 : 135*60) = "RES"; % 2:00-2:15
EVA_index(135*60 + 1 : 150*60) = "RES"; % 2:15-2:30
EVA_index(150*60 + 1 : 165*60) = "RES"; % 2:30-2:45
EVA_index(165*60 + 1 : 180*60) = "RES"; % 2:45-3:00

% HOUR 4
EVA_index(180*60 + 1 : 195*60) = "RES"; % 3:00-3:15
EVA_index(195*60 + 1 : 210*60) = "RES"; % 3:15-3:30
EVA_index(210*60 + 1 : 225*60) = "RES"; % 3:30-3:45
EVA_index(225*60 + 1 : 240*60) = "RES"; % 3:45-4:00

% HOUR 5
EVA_index(240*60 + 1 : 255*60) = "RES"; % 4:00-4:15
EVA_index(255*60 + 1 : 270*60) = "RES"; % 4:15-4:30
EVA_index(270*60 + 1 : 285*60) = "RES"; % 4:30-4:45
EVA_index(285*60 + 1 : 300*60) = "RES"; % 4:45-5:00

% HOUR 6
EVA_index(300*60 + 1 : 315*60) = "RES"; % 5:00-5:15
EVA_index(315*60 + 1 : 330*60) = "RES"; % 5:15-5:30
EVA_index(330*60 + 1 : 345*60) = "RES"; % 5:30-5:45
EVA_index(345*60 + 1 : 360*60) = "RES"; % 5:45-6:00

% HOUR 7
EVA_index(360*60 + 1 : 375*60) = "RES"; % 6:00-6:15
EVA_index(375*60 + 1 : 390*60) = "RES"; % 6:15-6:30
EVA_index(390*60 + 1 : 405*60) = "AERO"; % 6:30-6:45
EVA_index(405*60 + 1 : 420*60) = "AERO"; % 6:45-7:00

% HOUR 8
EVA_index(420*60 + 1 : 435*60) = "NOM"; % 7:00-7:15
EVA_index(435*60 + 1 : 450*60) = "NOM"; % 7:15-7:30
EVA_index(450*60 + 1 : 465*60) = "NOM"; % 7:30-7:45
EVA_index(465*60 + 1 : N)      = "NOM"; % 7:45-8:00
% *************************************************************************



% *********** Consumption vector initialization ***************************
% Initializes consumption values based on EVA index to time corresponding 
% positions in preallocated vectors
if Percentile_tracker == 95
    for i = 1:N
        if EVA_index(i) == "AERO"
            O2_consumption(i) = consumptionRate_mol_aero_95;
            CO2_output(i) = output_CO2_aero_95;
        elseif EVA_index(i) == "RES"
            O2_consumption(i) = consumptionRate_mol_res_95;
            CO2_output(i) = output_CO2_res_95;
        elseif EVA_index(i) == "REC"
            O2_consumption(i) = consumptionRate_mol_rec_95;
            CO2_output(i) = output_CO2_rec_95;
        else
            O2_consumption(i) = consumptionRate_mol_nom_95;
            CO2_output(i) = output_CO2_nom_95;
        end
    end
elseif Percentile_tracker == 5
    for i = 1:N
        if EVA_index(i) == "AERO"
            O2_consumption(i) = consumptionRate_mol_aero_5;
            CO2_output(i) = output_CO2_aero_5;
        elseif EVA_index(i) == "RES"
            O2_consumption(i) = consumptionRate_mol_res_5;
            CO2_output(i) = output_CO2_res_5;
        elseif EVA_index(i) == "REC"
            O2_consumption(i) = consumptionRate_mol_rec_5;
            CO2_output(i) = output_CO2_rec_5;
        else
            O2_consumption(i) = consumptionRate_mol_nom_5;
            CO2_output(i) = output_CO2_nom_5;
        end
    end
else
    for i = 1:N
        if EVA_index(i) == "AERO"
            O2_consumption(i) = consumptionRate_mol_aero_50;
            CO2_output(i) = output_CO2_aero_50;
        elseif EVA_index(i) == "RES"
            O2_consumption(i) = consumptionRate_mol_res_50;
            CO2_output(i) = output_CO2_res_50;
        elseif EVA_index(i) == "REC"
            O2_consumption(i) = consumptionRate_mol_rec_50;
            CO2_output(i) = output_CO2_rec_50;
        else
            O2_consumption(i) = consumptionRate_mol_nom_50;
            CO2_output(i) = output_CO2_nom_50;
        end
    end
end
% *************************************************************************

O2_mol = zeros(1,N); % O2 mol vector
O2_mol(1) = moles_O2;
O2_provided = zeros(1,N); % O2 needing provided via Tank 

CO2_mol = zeros(1,N); % CO2 mol vector

pressure = zeros(1,N); % pressure vector
CO2_concentration = zeros(1,N); % CO2 mol fraction vector
pressure(1) = O2_mol(1) * gasConstant * temperature / V; % Initial value

%% Euler Method Integration
% *************************************************************************
for i = 2:N
    
    leak_rate = (9.33*10^-6)*pressure(i-1)/(32*60);
    provision_rate = (-1*10^(-1*5)*(pressure(i-1)-P_set)); % Control 
    % Proporitional to Difference between Suit Pressure and Regulator Set
    % Pressure (trying to model regulator behavior as accurately as
    % possible)
    
    vent_rate = (0.169901 * pressure(i-1) /(gasConstant * temperature))/60; % Ventilation mol flow in mol/s mixture 
    % this is 0.169901 number comes from 6 ACFM flow rate  from Req. 2.1.2.1

    if (pressure(i-1)-P_set) < 0
        O2_mol(i) = O2_mol(i-1) - O2_consumption(i) - leak_rate + provision_rate;
        % Vent rate is assumed to be net 0
        % ((1-CO2_concentration(i-1))*vent_rate - (1-CO2_concentration(i-1))*vent_rate) = 0) 
        O2_provided(i) = O2_provided(i-1) + provision_rate;
    else
        O2_mol(i) = O2_mol(i-1) - O2_consumption(i) - leak_rate;
        O2_provided(i) = O2_provided(i-1);
    end
    
    CO2_mol(i) = CO2_mol(i-1) + CO2_output(i) - CO2_concentration(i-1)*vent_rate;

    pressure(i) = (O2_mol(i) + CO2_mol(i)) * gasConstant * temperature / V;
    
    CO2_concentration(i) = CO2_mol(i)/(O2_mol(i)+CO2_mol(i));
end

%% ************ GRAPHING SECTION - Edit as Needed *************************

% Concentration Figure
figure
plot(time,CO2_concentration*100,LineWidth=2);
hold on;
title("CO2 Concentration");
xlabel("Time (s)");
ylabel("CO2 Mol Fraction (%)");
grid on;
hold off;

CO2_added_pres = CO2_mol*gasConstant*temperature/V;

% Partial Pressure Figure
figure
plot(time, CO2_added_pres*7.5/1000,LineWidth=2);
title("CO2 Partial Pressure");
xlabel("Time (s)");
ylabel("Pressure (mmHg)");
yline(9,'r--',LineWidth=2);
legend('Inspired CO2 Partial Pressure','Nominal Non-Emergency Upper Limit', Location="southeast");
grid on;
hold off;

% Helmet Pressure Figure
figure
plot(time,pressure/1000,LineWidth=2);
title("Helmet Pressure");
xlabel("Time (s)");
ylabel("Pressure (kPa)");
grid on;
hold off;

% Cumulative Oxygen Provided Figure
% Value at End of Graph = Oxygen Needed for EVA
figure
plot(time,O2_provided*32,lineWidth=2);
title("Cumulative Oxygen Provided");
xlabel("Time (s)");
ylabel("Oxygen Provided (g)");
grid on;

fprintf('Maximum O2 provided: %.6f mol\n', max(O2_provided));

tank_volume = 0.0038;
tank_pres_min = 1.034 * 10^6; % 150 psi
tank_min_mols = tank_volume * tank_pres_min / (gasConstant * temperature); % Minumum operational O2 content for tank
tank_inventory = max(O2_provided) + 1.15*tank_min_mols; % adding minimum content with 15% margin

fprintf('O2 Tank Inventory: %.6f kg\n', tank_inventory*32/1000);

tank_start_pres = tank_inventory * (gasConstant * temperature)/tank_volume;
fprintf('O2 Primary Tank Start Pressure: %.6f Psi\n', tank_start_pres*0.000145038);