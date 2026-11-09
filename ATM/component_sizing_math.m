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

m4hr_total = (m4hr_sorb + m4hr_house); % one 4 hr can

fprintf('m_tot_mars_4hr dry = %g kg\n', m4hr_total)

% % 8 to 4 differences - in order to size charcoal
% tot_ref_diff = m_tot_ref-m_tot_ref_4hrs;
% sorb_ref_diff = m_sorb_ref - m_sorb_ref_4hrs;
% house_ref_diff = m_house_ref - m_house_ref_4hrs;


% 30 min emergency: aerobic
CO2_95th_aero = 6.3122; % g/min - from NEWupperbound_EVA_co2.m
bed_utilization_30MINcanister = 0.3; % estimation
m30min_co2load = (((CO2_95th_aero)/1000)*30)/bed_utilization_30MINcanister; % co2 produced by 95th for 30 mins of aerobic
m30min_sorb = lioh_per_co2 * m30min_co2load;

m30min_house = (m_house_mars * (m30min_sorb/m_sorb_mars)^(2/3)) + m_extrahouse_8hrs;
m30min_total = m30min_sorb + m30min_house;
fprintf('m_tot_mars_30min aerobic dry = %g kg\n', m30min_total)


% 4:30 EVA: aero 30
bed_utilization_430canister = 0.4; % estimation

m30min_co2_actual = (CO2_95th_aero/1000)*30;                 % kg actually absorbed
m_430_co2_actual  = m_co2load_4hrs + m30min_co2_actual;

m_430_sorb = (m_430_co2_actual)*lioh_per_co2/bed_utilization_430canister;
m_430_house = (m_house_ref_4hrs * (m_430_sorb/m_sorb_ref_4hrs)^(2/3)) + m_extrahouse_8hrs;
m430_total = m_430_house + m_430_sorb;


% 30 min emergency: nominal
CO2_95th_nom = 0.8344; %g/min
bed_utilization_30MINcanister = 0.30; % estimation
m30min_nom_co2load = (((CO2_95th_nom)/1000)*30)/bed_utilization_30MINcanister; % co2 produced by 95th for 30 mins of nominal
m30min_nom_sorb = lioh_per_co2 * m30min_nom_co2load;

m30min_nom_house = (m_house_mars * (m30min_nom_sorb/m_sorb_mars)^(2/3)) + m_extrahouse_8hrs;
m30min_nom_total = m30min_nom_sorb + m30min_nom_house;
fprintf('m_tot_mars_30min nominal dry = %g kg\n', m30min_nom_total)

% 4:30 EVA: nom 30
bed_utilization_430canister = 0.35; % estimation

m30min_co2_nom_actual = (CO2_95th_nom/1000)*30;                 % kg actually absorbed
m_430_co2_nom_actual  = m_co2load_4hrs + m30min_co2_nom_actual;

m_430_nom_sorb = (m_430_co2_nom_actual)*lioh_per_co2/bed_utilization_430canister;
%m_430_nom_sorb = m4hr_sorb + m30min_nom_sorb;
m_430_nom_house = (m_house_ref_4hrs * (m_430_nom_sorb/m_sorb_ref_4hrs)^(2/3)) + m_extrahouse_8hrs;
m430_nom_total = m_430_nom_house + m_430_nom_sorb;



% Modular LiOH Setups
% mod 1: three separate - 4, 4, 30 aero
total_modular_mass1 = m4hr_total + m4hr_total + m30min_total;
fprintf('total modular 1 mass dry = %g kg\n', total_modular_mass1)

bed_utilization_MODcanister = 0.85; % estimation
m_sorb_mod = 2*(m4hr_sorb) + m30min_sorb;
m_co2load_mod = m_sorb_mod * co2_per_lioh * bed_utilization_MODcanister;

% mod 2: 4+430 (30 aero)
total_modular_mass2 = m4hr_total + m430_total;
fprintf('total modular 2 mass dry = %g kg\n', total_modular_mass2)

% two fours: 4+4
two_4hr_sized = 2*m4hr_total;
% this might cover the 8hr upper AND the 30 min aerobic
fprintf('two 4hr-sized = %g kg\n', two_4hr_sized)

% mod3 -  4+430 with 30 being nominal
total_modular_mass3 = m4hr_total + m430_nom_total;
fprintf('total modular 3 mass dry = %g kg\n', total_modular_mass3)




% Dry vs. Wet Mass
% Dry is what I've calculated
% Wet is that mass plus however much co2 is actually captured (depends on efficiency which is derived from dry mass)


%% plot - cause I can
%y = [m_tot_ref m_tot_mars+m30min_total m_tot_ref_4hrs m4hr_total m30min_total total_modular_mass1 total_modular_mass2 two_4hr_sized total_modular_mass3];
y = [m_tot_ref m_tot_mars+m30min_total m_tot_mars+m30min_nom_total total_modular_mass1 total_modular_mass2 two_4hr_sized total_modular_mass3];

spacing = 1.4;                 % >1 spreads bars apart; 1 = original
x = (1:numel(y)) * spacing;

b = bar(x, y, 0.8/spacing);   % see note below on width

b.FaceColor = 'flat';
b.CData = [0.2 0.2 0.2;
           0.85 0.4 0.08;
           0.85 0.4 0.08;
           0.9 0.3 0.6;
           0.8 0.3 0.8;
           0.8 0.3 0.9;
           0.7 0.3 0.9];

xlabels = {
    {'Apollo','8hr canister'}
    {'Mars 8hr','+30min aero','(one can)'}
    {'Mars 8hr','+30min nom','(one can)'}
    {'Mars Mod1','4 + 4 + 30','(30 aero)'}
    {'Mars Mod2','4 + 4:30','(30 aero)'}
    {'Two','4hr-sized'}
    {'Mars Mod3','4 + 4:30','(30 nom)'}
    };

ax = gca;
ax.XTick = x;
ax.XTickLabel = {};
ax.FontSize = 11;
xlim([x(1)-spacing*0.7, x(end)+spacing*0.7])
ylim([0 max(y)*1.12])
ax.Position(2) = 0.22;
ax.Position(4) = 0.70;

yl = ylim;
for k = 1:numel(y)
    text(x(k), yl(1) - 0.02*diff(yl), xlabels{k}, ...
        'HorizontalAlignment','center', 'VerticalAlignment','top', ...
        'FontSize',11, 'Interpreter','none', 'Clipping','off');
end

text(x, y, compose('%.2f', y), ...
    'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize',10);

ylabel('Dry mass (kg)')
title('LiOH Canister Dry Mass Comparison')
grid on


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Volume
rho_bulk = 0.0004; % kg/cm^3
V_bed_ref = m_sorb_ref/rho_bulk;
V_bed_ref_4hrs = m_sorb_ref_4hrs/rho_bulk;

V_bed_mars = m_sorb_mars/rho_bulk;
V_bed_4hrs = m4hr_sorb/rho_bulk;
V_bed_430 = m_430_sorb/rho_bulk; % aerobic 30
V_bed_nom_430 = m_430_nom_sorb/rho_bulk; % nominal 30

% size of Apollo 8hr and 4hr cans are same - sorbent mass different
volume_scale_factor = V_bed_mars/V_bed_ref;
volume_scale_factor_4hrs = V_bed_4hrs/V_bed_ref_4hrs;
volume_scale_factor_430 = V_bed_430/V_bed_ref;   % relative to the Apollo 15-17 bigger bed to be safe
volume_scale_factor_nom_430 = V_bed_nom_430/V_bed_ref;


% volumes and dimensions of each canister

L_ref = 30.5; % cm long - Apollo journals
D_ref = 14; % cm in diameter - Apollo journals
V_ref = pi*L_ref*(D_ref/2)^2; % cm^3



V_mars = V_ref*volume_scale_factor;
L_mars = L_ref*(volume_scale_factor)^(1/3);
D_mars = D_ref*(volume_scale_factor)^(1/3);

V_4hr = (V_bed_4hrs)*volume_scale_factor_4hrs; % estimate
L_4hr = L_ref*(volume_scale_factor_4hrs)^(1/3); % cm
D_4hr = D_ref*(volume_scale_factor_4hrs)^(1/3);
V_4hr_real = pi*(L_4hr)*(D_4hr/2)^2;


V_430 = V_ref*volume_scale_factor_430;           % cm^3
L_430 = L_ref*(volume_scale_factor_430)^(1/3);
D_430 = D_ref*(volume_scale_factor_430)^(1/3);

V_nom_430 = V_ref*volume_scale_factor_nom_430;           % cm^3
L_nom_430 = L_ref*(volume_scale_factor_nom_430)^(1/3);
D_nom_430 = D_ref*(volume_scale_factor_nom_430)^(1/3);
V_nom_430_real = pi*(L_nom_430)*(D_nom_430/2)^2;

V_mod2 = V_4hr + V_430;
V_mod3 = V_4hr + V_nom_430;


fprintf('V_apollo = %gL\n', V_ref/1000)
fprintf('V_mars = %gL\n', V_mars/1000)
fprintf('V_4hr = %gL\n', V_4hr/1000)
%fprintf('V_430 = %gL\n', V_430/1000)
fprintf('V_4hr_real = %gL\n', V_4hr_real/1000)
fprintf('V_nom_430 = %gL\n', V_nom_430/1000)
fprintf('V_nom_430_real = %gL\n', V_nom_430_real/1000)
fprintf('V_mod3 = %gL\n', V_mod3/1000)

% Volume plot
volumeValues = [V_ref, V_mars,V_4hr, V_430, V_nom_430, V_mod2, V_mod3] / 1000;
figure;
bar(volumeValues);
xticklabels({'Apollo 4hr/8hr','Mars 8 hr','Mars 4 hr','Mars 430 aero','Nominal 430','Modular 2 (aero 30)','Modular 3 (nom 30)'});
ylabel('Volume (L)');
title('LiOH Canister Volume Comparison');
grid on

m_sorb_tot_needed_upperbound8hrs_plus30aerobic = (m_co2load_mars + m30min_co2_actual) * lioh_per_co2;
co2load_8hr_plus_30aero = m_co2load_mars + m30min_co2_actual;
fprintf('co2 load 8hr upper +30 aerobic = %gkg\n', co2load_8hr_plus_30aero)

m_sorb_tot_needed_upperbound8hrs_plus30nominal = (m_co2load_mars + m30min_co2_nom_actual) * lioh_per_co2;
co2load_8hr_plus_30nom = m_co2load_mars + m30min_co2_nom_actual;
fprintf('co2 load 8hr upper +30 nominal = %gkg\n', co2load_8hr_plus_30nom)


% metox quick math
ag2o_per_co2 = 5.3;
m_metoxsorb_tot = co2load_8hr_plus_30aero * ag2o_per_co2;
m_metoxsorb_tot_nom = co2load_8hr_plus_30nom * ag2o_per_co2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% show this modular approach saves lioh sorbent - more efficient than one big can

% one big can's waste vs. 4&430 cans' waste
% waste is lioh left after 8:30
% after we 70% efficiency of lioh1 we switch to lioh2
% after 8:30 eva is done we discard whatever is left of 430 can


% %% Single 8:30 EVA: one big can vs LiOH1 (4 hr can) -> LiOH2
% L        = co2load_8hr_plus_30aero;          % kg CO2 for 8 hr + 30 min aerobic
% u_single = bed_utilization_8hrcanister;      % 0.50, big can discarded at this utilization
% u2       = bed_utilization_430canister;      % LiOH2 utilization when discarded (0.40)
% m1       = m4hr_sorb;                        % LiOH1 mass as sized
% 
% m_react  = L*lioh_per_co2;                   % kg LiOH that must react (same for every option)
% 
% % One big can
% m_big     = m_react/u_single;
% waste_big = m_big - m_react;
% 
% % LiOH1 then LiOH2, swapping when LiOH1 reaches u_switch
% u_switch = 0.35:0.05:0.80;                   % ASSUMPTION: sweep this
% C1 = min(m1*co2_per_lioh*u_switch, L);       % kg CO2 absorbed by LiOH1 before the swap
% L2 = L - C1;                                 % kg CO2 left for LiOH2
% m2 = L2*lioh_per_co2/u2;                     % LiOH2 sized for that remainder
% 
% m_mod     = m1 + m2;                         % expendable LiOH carried
% waste_mod = m_mod - m_react;                 % unreacted LiOH thrown away
% saving_mass  = 100*(1 - m_mod/m_big);        % % less expendable LiOH than one big can
% saving_waste = 100*(1 - waste_mod/waste_big);
% 
% % Swap utilization where modular = one big can
% u_be = (L - (m_big - m1)*u2*co2_per_lioh)/(m1*co2_per_lioh);
% fprintf('break-even swap utilization = %g\n', u_be)
% 
% figure; plot(u_switch, saving_mass, 'o-'); hold on; yline(0,'k--'); grid on
% xlabel('LiOH1 utilization at swap'); ylabel('Expendable LiOH saved vs one big can (%)')
% 
% u_switch = 0.35:0.01:0.85;
% C1 = min(m4hr_sorb*co2_per_lioh*u_switch, L);
% m2 = (L - C1)*lioh_per_co2/bed_utilization_430canister;
% m_mod = m4hr_sorb + m2;
% m_big = L*lioh_per_co2/bed_utilization_8hrcanister;
% 
% figure; hold on; grid on
% plot(u_switch, m_mod, 'LineWidth', 2)
% yline(m_big, 'r--', 'One 8:30 can', 'LineWidth', 2)
% win = m_mod < m_big;
% area(u_switch(win), m_big*ones(1,nnz(win)), 'FaceColor',[0.8 1 0.8], 'EdgeColor','none', 'FaceAlpha',0.5)
% plot(u_switch, m_mod, 'b', 'LineWidth', 2)   % redraw line on top of shading
% xline(0.68, ':', 'Source: 68% at 12 hr')
% xlabel('LiOH1 utilization when swapped to LiOH2')
% ylabel('Expendable LiOH (kg)')
% legend('Modular', 'One 8:30 can', 'Modular wins', 'Location','northeast')
% title('LiOH carried and discarded, one 8:30 EVA')


%% Single 8:30 EVA: one big can vs LiOH1 (4 hr can) -> LiOH2 - new nominal emergency 30 mins
L        = co2load_8hr_plus_30nom;          % kg CO2 for 8 hr + 30 min aerobic
u_single = bed_utilization_8hrcanister;      % 0.50, big can discarded at this utilization
u2       = bed_utilization_430canister;      % LiOH2 utilization when discarded (0.40)
m1       = m4hr_sorb;                        % LiOH1 mass as sized

m_react  = L*lioh_per_co2;                   % kg LiOH that must react (same for every option)

% One big can
m_big     = m_react/u_single;
waste_big = m_big - m_react;

% LiOH1 then LiOH2, swapping when LiOH1 reaches u_switch
u_switch = 0.35:0.05:0.80;                   % ASSUMPTION: sweep this
C1 = min(m1*co2_per_lioh*u_switch, L);       % kg CO2 absorbed by LiOH1 before the swap
L2 = L - C1;                                 % kg CO2 left for LiOH2
m2 = L2*lioh_per_co2/u2;                     % LiOH2 sized for that remainder

m_mod     = m1 + m2;                         % expendable LiOH carried
waste_mod = m_mod - m_react;                 % unreacted LiOH thrown away
saving_mass  = 100*(1 - m_mod/m_big);        % % less expendable LiOH than one big can
saving_waste = 100*(1 - waste_mod/waste_big);

% Swap utilization where modular = one big can
u_be = (L - (m_big - m1)*u2*co2_per_lioh)/(m1*co2_per_lioh);
fprintf('break-even swap utilization = %g\n', u_be)

figure; plot(u_switch, saving_mass, 'o-'); hold on; yline(0,'k--'); grid on
xlabel('LiOH1 utilization at swap'); ylabel('Expendable LiOH saved vs one big can (%)')

u_switch = 0.35:0.01:0.85;
C1 = min(m4hr_sorb*co2_per_lioh*u_switch, L);
m2 = (L - C1)*lioh_per_co2/bed_utilization_430canister;
m_mod = m4hr_sorb + m2;
m_big = L*lioh_per_co2/bed_utilization_8hrcanister;

figure; hold on; grid on
plot(u_switch, m_mod, 'LineWidth', 2)
yline(m_big, 'r--', 'One 8:30 can', 'LineWidth', 2)
win = m_mod < m_big;
area(u_switch(win), m_big*ones(1,nnz(win)), 'FaceColor',[0.8 1 0.8], 'EdgeColor','none', 'FaceAlpha',0.5)
plot(u_switch, m_mod, 'b', 'LineWidth', 2)   % redraw line on top of shading
xline(0.68, ':', 'Source: 68% at 12 hr')
xlabel('LiOH1 utilization when swapped to LiOH2')
ylabel('Expendable LiOH (kg)')
legend('Modular', 'One 8:30 can', 'Modular wins', 'Location','northeast')
title('LiOH carried and discarded, one 8:30 EVA')