% Component Sizing Math

clc; clear; close all;

% LiOH
m_LiOH = 23.95; %g/mol
m_CO2 = 44.01; %g/mol

lioh_per_co2 = (2*m_LiOH)/m_CO2;
co2_per_lioh = 1/lioh_per_co2;


% Reference - Apollo 15-17 8hr LiOH Canister
m_tot_ref = 2.81; % kg - PLSS Cartridge from launch stowage
m_sorb_ref = 1.42; %kg - LiOH sorbent from Apollo journal
bed_utilization_8hrcanister = 0.50; % 50% reaction completion for 8hr EVA - from NASA tech report (19720017483)
bed_utilization_4hrcanister = 0.35;
% utilization: how lioh can become lithium carbonate
% removal efficiency: how much co2 can be captured
m_charcoal_ref = 0.0567; % kg (2 ounces) - CHECKED, YES THIS IS CORRECT FOR 8HRS

m_co2load_ref = m_sorb_ref * co2_per_lioh * bed_utilization_8hrcanister;

m_house_ref = m_tot_ref - m_sorb_ref;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mars model
m_co2load_mars = 0.91; %kg over 8hrs - from NEW EVA
scaling_ratio = m_co2load_mars/m_co2load_ref;

m_sorb_mars = m_sorb_ref * scaling_ratio;
% charcoal
m_ammonasorbII_8hrs = 0.085; % kg (3 ounces)
m_extrahouse_8hrs = m_ammonasorbII_8hrs - m_charcoal_ref; % = 0.0283 --> add to any house calculations

m_house_mars = (m_house_ref * (m_sorb_mars/m_sorb_ref)^(2/3)) + m_extrahouse_8hrs; % scale up only volume, not thikness

m_tot_mars = m_sorb_mars + m_house_mars + m_extrahouse_8hrs;


fprintf('m_tot_apollo = %g\n', m_tot_ref)
fprintf('m_tot_mars dry = %g\n', m_tot_mars)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Segments! Splitting the 8hr upper bound directly in half to account for "short EVAs"
% Assume: short EVA = half of 8hr upper bound --> m_4hr_co2load = m_mars_co2_load/2
% 4 hour EVA:
m_co2load_4hrs = m_co2load_mars/2;

m_tot_ref_4hrs = 2.107; % kg - Apollo 11-14 (with charcoal filter)
m_sorb_ref_4hrs = 1.36; % kg - Apollo 11-14
m_co2load_ref_4hrs = m_sorb_ref_4hrs * co2_per_lioh * bed_utilization_4hrcanister;
m_house_ref_4hrs = m_tot_ref_4hrs - m_sorb_ref_4hrs;

scaling_ratio_4hrs = m_co2load_4hrs/m_co2load_ref_4hrs;

m4hr_sorb = m_sorb_ref_4hrs * scaling_ratio_4hrs;
m4hr_house = (m_house_ref_4hrs * (m4hr_sorb/m_sorb_ref_4hrs)^(2/3)) + m_extrahouse_8hrs; % scale up only volume, not thikness

m4hr_total = m4hr_sorb + m4hr_house;

fprintf('m_tot_mars_4hr dry = %g kg\n', m4hr_total)

% % 8 to 4 differences - in order to size charcoal
% tot_ref_diff = m_tot_ref-m_tot_ref_4hrs;
% sorb_ref_diff = m_sorb_ref - m_sorb_ref_4hrs;
% house_ref_diff = m_house_ref - m_house_ref_4hrs;


% 30 min emergency:
CO2_95th_aero = 6.3122; % g/min - from NEWupperbound_EVA_co2.m
bed_utilization_30MINcanister = 0.3; % estimation
m30min_co2load = (((CO2_95th_aero)/1000)*30)/bed_utilization_30MINcanister; % co2 produced by 95th for 30 mins of aerobic
m30min_sorb = lioh_per_co2 * m30min_co2load;

m30min_house = (m_house_mars * (m30min_sorb/m_sorb_mars)^(2/3)) + m_extrahouse_8hrs;
m30min_total = m30min_sorb + m30min_house;
fprintf('m_tot_mars_30min dry = %g kg\n', m30min_total)


% 4:30 EVA
bed_utilization_430canister = 0.4; % estimation

m30min_co2_actual = (CO2_95th_aero/1000)*30;                 % kg actually absorbed
m_430_co2_actual  = m_co2load_4hrs + m30min_co2_actual;

m_430_sorb = (m_430_co2_actual)*lioh_per_co2/bed_utilization_430canister;
m_430_house = (m_house_ref_4hrs * (m_430_sorb/m_sorb_ref_4hrs)^(2/3)) + m_extrahouse_8hrs;
m430_total = m_430_house + m_430_sorb;

% Modular LiOH Setup
% option 1:
total_modular_mass1 = m4hr_total + m4hr_total + m30min_total;
fprintf('total modular 1 mass dry = %g kg\n', total_modular_mass1)

bed_utilization_MODcanister = 0.85; % estimation
m_sorb_mod = 2*(m4hr_sorb) + m30min_sorb;
m_co2load_mod = m_sorb_mod * co2_per_lioh * bed_utilization_MODcanister;

% option 2:
total_modular_mass2 = m4hr_total + m430_total;
fprintf('total modular 2 mass dry = %g kg\n', total_modular_mass2)

% option 3:
two_4hr_sized = 2*m4hr_total;
% this might cover the 8hr upper AND the 30 min aerobic
fprintf('two 4hr-sized = %g kg\n', two_4hr_sized)


% Dry vs. Wet Mass
% Dry is what I've calculated
% Wet is that mass plus however much co2 is actually captured (depends on efficiency which is derived from dry mass)


% plot - cause I can
y = [m_tot_ref m_tot_mars+m30min_total m_tot_ref_4hrs m4hr_total m30min_total total_modular_mass1 total_modular_mass2 two_4hr_sized];
b = bar(y);
b.FaceColor = 'flat';
b.CData = [0.2 0.2 0.2; 
           0.85 0.4 0.08;
           0.2 0.2 0.2;
           0.9 0.6 0.3;
           0.8 0.0 0.3;
           0.9 0.3 0.6;
           0.8 0.3 0.8;
           0.8 0.3 0.9];

xticks(1:8)
xticklabels({'Apollo 8 hr canister','Mars 8 hr canister','Apollo 4 hr canister','Mars 4 hr canister','Mars 30 min aerobic canister','Mars Modular total 1','Mars Modular total 2', 'Two 4hr-sized'})
xtickangle(15)
ylabel('Dry mass (kg)')
title('LiOH Canister Dry Mass Comparison')
grid on


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Volume
rho_bulk = 0.0004; % kg/cm^3
V_bed_ref = m_sorb_ref/rho_bulk;
V_bed_ref_4hrs = m_sorb_ref_4hrs/rho_bulk;

V_bed_mars = m_sorb_mars/rho_bulk;
V_bed_4hrs = m4hr_sorb/rho_bulk;
V_bed_430 = m_430_sorb/rho_bulk;

% size of Apollo 8hr and 4hr are same
volume_scale_factor = V_bed_mars/V_bed_ref;
volume_scale_factor_4hrs = V_bed_4hrs/V_bed_ref_4hrs;
volume_scale_factor_430 = V_bed_430/V_bed_ref;   % relative to the Apollo 15-17 bed

L_ref = 30.5; % cm long - Apollo journals
D_ref = 14; % cm in diameter - Apollo journals
V_ref = pi*L_ref*(D_ref/2)^2; % cm^3


V_mars = V_ref*volume_scale_factor;
L_mars = L_ref*(volume_scale_factor)^(1/3);
D_mars = D_ref*(volume_scale_factor)^(1/3);

V_4hr = (V_bed_4hrs)*volume_scale_factor_4hrs; % estimate
L_4hr = L_ref*(volume_scale_factor_4hrs)^(1/3); % cm
D_4hr = D_ref*(volume_scale_factor_4hrs)^(1/3);


V_430 = V_ref*volume_scale_factor_430;           % cm^3
L_430 = L_ref*(volume_scale_factor_430)^(1/3);
D_430 = D_ref*(volume_scale_factor_430)^(1/3);

L_mod2 = L_4hr+L_430;
D_mod2 = D_4hr+D_430;


fprintf('V_apollo = %gL\n', V_ref/1000)
fprintf('V_mars = %gL\n', V_mars/1000)
fprintf('V_4hr = %gL\n', V_4hr/1000)
fprintf('V_430 = %gL\n', V_430/1000)
fprintf('V_mod2 = %gL\n', (V_4hr+V_430)/1000)

m_sorb_tot_needed_upperbound8hrs_plus30aerobic = (m_co2load_mars + m30min_co2_actual) * lioh_per_co2;
co2load_8hr_plus_30aero = m_co2load_mars + m30min_co2_actual;
fprintf('co2 load 8hr upper +30 aerobic = %gkg\n', co2load_8hr_plus_30aero)