clc; clear; close all;


%% INPUTS
% Metabolic data 
CO2_82.nom      = 0.69;
CO2_82.aero     = 5.22;
CO2_82.resist   = 1.89;
CO2_82.recovery = 0.69;
M_ref  = 82;        % kg
M_95th = 99.157;    % kg

% EVA timeline 
t_bound = [0 0.5 1 2 3 3.5 3.75 4 5 5.25 5.5 6 6.5 7.25 7.5 8];   % hr
zones = {'nom','resist','nom','resist','recovery','aero','recovery', ...
'resist','aero','resist','recovery','nom','resist','recovery','nom'};

%% CANISTER SIZING (from Component Sizing Math file)
MW_LiOH = 23.95;            % g/mol
MW_CO2  = 44.01;            % g/mol
lioh_per_co2 = (2*MW_LiOH)/MW_CO2;
co2_per_lioh = 1/lioh_per_co2;


m_co2load_mars = 0.91;                  % kg over 8 hr
m_co2load_4hrs = m_co2load_mars/2;      % kg

% Apollo 11-14 4 hr reference
m_tot_ref_4hrs  = 2.107;    % kg
m_sorb_ref_4hrs = 1.36;     % kg
util_4hr        = 0.35;     % bed utilization, 4 hr canister
m_co2load_ref_4hrs = m_sorb_ref_4hrs*co2_per_lioh*util_4hr;
m_house_ref_4hrs   = m_tot_ref_4hrs - m_sorb_ref_4hrs;

% --- Canister 1: 4 hr ---
scaling_4hrs = m_co2load_4hrs/m_co2load_ref_4hrs;
m4hr_sorb  = m_sorb_ref_4hrs*scaling_4hrs;                % kg LiOH
m4hr_house = m_house_ref_4hrs*(m4hr_sorb/m_sorb_ref_4hrs)^(2/3) ;
m4hr_total = m4hr_sorb + m4hr_house;                      % kg dry

% --- Canister 2: 4:30 (4 hr load + 30 min nom emergency, 95th pct) ---
CO2_95th_nom = CO2_82.nom*(M_95th/M_ref);   % g/min 
util_430     = 0.35;                         % bed utilization, 4:30 nominal canister
m30min_co2_actual = (CO2_95th_nom/1000)*30;  % kg
m_430_co2_actual  = m_co2load_4hrs + m30min_co2_actual;
m_430_sorb  = m_430_co2_actual*lioh_per_co2/util_430;    % kg LiOH
m_430_house = m_house_ref_4hrs*(m_430_sorb/m_sorb_ref_4hrs)^(2/3) ;
m430_total  = m_430_sorb + m_430_house;                   % kg dry

% Per-canister arrays [canister 1, canister 2]
m_LiOH_can  = [m4hr_sorb  m_430_sorb]*1000;   % g LiOH
util_can    = [util_4hr   util_430];
dry_can     = [m4hr_total m430_total];        % kg dry

%% EFFICIENCY (BREAKTHROUGH) MODEL
eta0       = 0.85;   % removal efficiency while bed is fresh
x_bt       = 0.8;  % fraction of usable capacity consumed where roll-off starts
p_roll     = 2;     % roll-off sharpness (higher = sharper breakthrough)
eta_switch = 0.70;  % switch canisters when efficiency drops to this (70%)...
t_switch_hr = 8;    % ...or when this much EVA time has elapsed 

dt = 0.1;           % time step (min)

%% 95th PERCENTILE PRODUCTION PROFILE
t_end_min = t_bound(end)*60;
N   = round(t_end_min/dt);
tm  = ((1:N) - 0.5)*dt;                 % step midpoints (min)
idx = discretize(tm/60, t_bound);       % chunk index for each step

rate_chunk = zeros(1, numel(zones));
for k = 1:numel(zones)
    rate_chunk(k) = CO2_82.(zones{k}) * (M_95th/M_ref);   % g/min
end
prod_rate = rate_chunk(idx);            % g/min at each step

%% CANISTER CAPACITY
CO2_first4 = sum(prod_rate(tm <= 4*60))*dt;      % g, 95th pct, first 4 hr
cap = m_LiOH_can.*co2_per_lioh.*util_can;        % usable CO2 capacity (g) per canister


% Efficiency vs. fraction of usable capacity consumed
eta_fun = @(x) max(0, min(1, ...
    eta0*(1 - (max(0, x - x_bt)/(1 - x_bt)).^p_roll)));

%% SIMULATION
active = 1;
captured = [0 0];            % g CO2 captured per canister
t_switched = NaN;
incoming_at_switch = NaN;    % g/min CO2 reaching canister 1 when valve switches
x1_at_switch = NaN;          % fraction of canister 1 usable capacity used at switch
captured1_at_switch = NaN;   % g CO2 captured by canister 1 at switch

eta_inst   = zeros(1,N);
removed    = zeros(1,N);     % g per step
slip       = zeros(1,N);
active_log = zeros(1,N);
x_log      = zeros(2,N);

for i = 1:N
    P = prod_rate(i)*dt;     % g CO2 produced this step

    eta = eta_fun(captured(active)/cap(active));

    % Valve switch logic (canister 1 -> 2, one-way)
    if active == 1 && (tm(i) >= t_switch_hr*60 || eta < eta_switch)
        t_switched = tm(i)/60;
        incoming_at_switch  = prod_rate(i);
        x1_at_switch        = captured(1)/cap(1);
        captured1_at_switch = captured(1);
        active = 2;
        eta = eta_fun(captured(active)/cap(active));
    end

    rem_cap = cap(active) - captured(active);
    r = min(eta*P, rem_cap);

    captured(active) = captured(active) + r;
    removed(i)    = r;
    slip(i)       = P - r;
    eta_inst(i)   = r/P;
    active_log(i) = active;
    x_log(:,i)    = captured(:)./cap(:);
end

%% RESULTS
tot_prod    = sum(prod_rate)*dt;
tot_removed = sum(removed);
tot_slip    = sum(slip);
overall_eff = tot_removed/tot_prod*100;
% Wet mass per canister (dry + CO2 captured by that canister)
wet_can = dry_can + captured/1000;      % kg; captured is g CO2 per canister at end of sim

fprintf('\n===== LiOH TIERED SYSTEM (4 hr + 4:30) RESULTS (95th percentile) =====\n');
fprintf('LiOH, canister 1 / 2:     %.0f g / %.0f g\n', m_LiOH_can(1), m_LiOH_can(2));
fprintf('Dry mass, canister 1 / 2: %.3f kg / %.3f kg\n', dry_can(1), dry_can(2));
fprintf('Dry mass, total:          %.3f kg\n', sum(dry_can));
fprintf('Wet mass, canister 1 / 2: %.3f kg / %.3f kg\n', wet_can(1), wet_can(2));
fprintf('Wet mass, total:          %.3f kg (dry + captured CO2)\n', sum(wet_can));
fprintf('CO2 captured, can 1 / 2:  %.1f g / %.1f g\n', captured(1), captured(2));
fprintf('Usable CO2 capacity:      %.1f g / %.1f g\n', cap(1), cap(2));
fprintf('95th pct CO2, first 4 hr: %.1f g\n', CO2_first4);
fprintf('95th pct CO2, last 4 hr:  %.1f g\n', tot_prod-CO2_first4);
fprintf('Total CO2 produced:       %.1f g\n', tot_prod);
fprintf('Total CO2 removed:        %.1f g\n', tot_removed);
fprintf('Total CO2 slip:           %.1f g\n', tot_slip);
fprintf('  Slip, canister 1 active: %.1f g\n', sum(slip(active_log==1)));
fprintf('  Slip, canister 2 active: %.1f g\n', sum(slip(active_log==2)));
fprintf('Overall removal eff.:     %.2f %%\n', overall_eff);
fprintf('Canister 1 used:          %.1f %% of usable capacity\n', x_log(1,end)*100);
fprintf('Canister 2 used:          %.1f %% of usable capacity\n', x_log(2,end)*100);
fprintf('Min instantaneous eff.:   %.2f %%\n', min(eta_inst)*100);

fprintf('\n----- BREAKTHROUGH AT VALVE SWITCH (eta = %.0f %%) -----\n', eta_switch*100);
if isnan(t_switched)
    fprintf('Valve never switched.\n');
else
    bt_rate = (1 - eta_switch)*incoming_at_switch;      % g/min leaking at the switch
    fprintf('Switch time:                    %.2f hr\n', t_switched);
    fprintf('Canister 1 captured at switch:  %.1f g (%.1f %% of usable capacity)\n', ...
            captured1_at_switch, x1_at_switch*100);
    fprintf('CO2 reaching canister 1:        %.3f g/min\n', incoming_at_switch);
    fprintf('CO2 breaking through at switch: %.3f g/min (%.0f %% of incoming)\n', ...
            bt_rate, (1-eta_switch)*100);
    fprintf('Worst case (aerobic, %.2f g/min incoming): %.3f g/min breakthrough\n', ...
            max(prod_rate), (1-eta_switch)*max(prod_rate));
    fprintf('Cumulative slip before switch:  %.1f g\n', sum(slip(active_log==1)));
end

%% PLOTS
th = tm/60;
figure('Units','normalized','Position',[0.05 0.05 0.85 0.85]);

subplot(3,1,1); hold on; grid on;
plot(th, prod_rate, 'k-', 'LineWidth', 1.5);
plot(th, removed/dt, 'b-', 'LineWidth', 1.5);
plot(th, slip/dt, 'r-', 'LineWidth', 1.5);
xline(t_switched, '--m', 'Valve switch');
ylabel('CO_2 rate (g/min)');
legend('Produced (95th)','Removed','Slip','Location','northeast');
title('Tiered LiOH System (4 hr + 4:30): CO_2 Production, Removal, and Slip');
xlim([0 th(end)]);

subplot(3,1,2); hold on; grid on;
plot(th, eta_inst*100, 'LineWidth', 1.5);
yline(eta_switch*100, ':k', sprintf('Switch at %.0f%%', eta_switch*100));
xline(t_switched, '--m', 'Valve Switch');
ylabel('Removal efficiency (%)'); ylim([0 105]);
xlim([0 th(end)]);
title('Instantaneous Removal Efficiency');

subplot(3,1,3); hold on; grid on;
plot(th, (1-x_log(1,:))*100, 'LineWidth', 1.5);
plot(th, (1-x_log(2,:))*100, 'LineWidth', 1.5);
xline(t_switched, '--m', 'Valve Switch');
ylabel('Remaining capacity (%)'); xlabel('EVA Duration (hr)');
legend('Canister 1 (4 hr)','Canister 2 (4:30)','Location','northeast');
xlim([0 th(end)]); ylim([0 105]);
title('Canister Remaining Usable Capacity');