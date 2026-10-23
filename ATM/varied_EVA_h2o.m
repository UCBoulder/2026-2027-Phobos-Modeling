clc; clear; close all;
figure('Units', 'normalized', 'Position', [0.05 0.1 0.9 0.8]);

% Varied EVA Metabolic Rates
% MetMan Data (outputs in g/min)

% nominal
watervapor_82_nom = 1.49;

% aerobic
watervapor_82_aero = 13.44; %(13.44+7.09)/2; % MAYBE AVG WITH 7.09 OR TAKE MAX - going with max

% resistive1
watervapor_82_resist1 = 11.07; 
% resistive2
watervapor_82_resist2 = 8.73; 
% resistive3
watervapor_82_resist3 = 6.79; 
% resistive4
watervapor_82_resist4 = 5.99; 

% recovery1
watervapor_82_recovery1 = 2.36;
% recovery1
watervapor_82_recovery2 = 2.00;
% recovery1
watervapor_82_recovery3 = 1.74;
% recovery4
watervapor_82_recovery4 = 1.59;

% Percentile Masses (kg)
M_5th = 53.685;
M_95th = 99.157;

% CALCULATIONS
% nominal
watervapor_5th_nom = (watervapor_82_nom)*(M_5th/82);
watervapor_95th_nom = (watervapor_82_nom)*(M_95th/82);

% aerobic
watervapor_5th_aero = (watervapor_82_aero)*(M_5th/82);
watervapor_95th_aero = (watervapor_82_aero)*(M_95th/82);

% resistive1
watervapor_5th_resist1 = (watervapor_82_resist1)*(M_5th/82);
watervapor_95th_resist1 = (watervapor_82_resist1)*(M_95th/82);
% resistive2
watervapor_5th_resist2 = (watervapor_82_resist2)*(M_5th/82);
watervapor_95th_resist2 = (watervapor_82_resist2)*(M_95th/82);
% resistive3
watervapor_5th_resist3 = (watervapor_82_resist3)*(M_5th/82);
watervapor_95th_resist3 = (watervapor_82_resist3)*(M_95th/82);
% resistive4
watervapor_5th_resist4 = (watervapor_82_resist4)*(M_5th/82);
watervapor_95th_resist4 = (watervapor_82_resist4)*(M_95th/82);



% recovery1
watervapor_5th_recovery1 = (watervapor_82_recovery1)*(M_5th/82);
watervapor_95th_recovery1 = (watervapor_82_recovery1)*(M_95th/82);
% recovery2
watervapor_5th_recovery2 = (watervapor_82_recovery2)*(M_5th/82);
watervapor_95th_recovery2 = (watervapor_82_recovery2)*(M_95th/82);
% recovery3
watervapor_5th_recovery3 = (watervapor_82_recovery3)*(M_5th/82);
watervapor_95th_recovery3 = (watervapor_82_recovery3)*(M_95th/82);
% recovery4
watervapor_5th_recovery4 = (watervapor_82_recovery4)*(M_5th/82);
watervapor_95th_recovery4 = (watervapor_82_recovery4)*(M_95th/82);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT
hold on;

% Time boundaries (one more entry than there are chunks)
t = [0 0.5 0.75 1 1.5 2 2.25 2.5 2.75 3 3.25 3.5 3.75 4 4.25 4.5 4.75 5 5.25 5.5 5.75 6 6.5 6.75 7 7.25 7.5 8];

% Activity zone for each chunk (nom, aero, resist, or recovery)
zones = {'nom', 'resist', 'resist', 'recovery', 'nom', ...
         'resist', 'resist', 'resist', 'resist', ...
         'recovery', 'recovery', 'aero', 'recovery', ...
         'resist', 'resist', 'resist', 'resist', ...
         'aero', 'resist', 'recovery', 'recovery', 'nom', ...
         'resist', 'resist', 'resist', 'recovery', 'nom'};

% Zone colors: blue, red, yellow, green
zone_names  = {'nom', 'aero', 'resist', 'recovery'};
zone_colors = [0 0.45 0.9;    % nominal  - blue
               0.85 0.1 0.1;  % aerobic  - red
               1 0.85 0;      % resistive - yellow
               0.1 0.7 0.2];  % recovery - green

% Task name for each chunk (edit these)
tasks = {'Egress', 'Load', 'Rover', 'Drive', '', '', 'Assemble', '', '', ...
         '  Rest', '', ['Walk/' newline 'Climb'], 'Survey', ' ', 'Collect', ' ', ' ', ...
         ['Walk/' newline 'Climb'], ['Load' newline 'Rover'], '', 'Drive', '', ...
         '', 'Unload', ' ', 'Rest', 'Ingress'};
% Values for each chunk, same order as tasks
wv_5th  = [watervapor_5th_nom watervapor_5th_resist1 watervapor_5th_resist2 watervapor_5th_recovery1 watervapor_5th_nom  watervapor_5th_resist1 watervapor_5th_resist2 watervapor_5th_resist3 watervapor_5th_resist4 watervapor_5th_recovery1 watervapor_5th_recovery2 watervapor_5th_aero watervapor_5th_recovery1 watervapor_5th_resist1 watervapor_5th_resist2 watervapor_5th_resist3 watervapor_5th_resist4 watervapor_5th_aero watervapor_5th_resist1 watervapor_5th_recovery1 watervapor_5th_recovery2 watervapor_5th_nom watervapor_5th_resist1 watervapor_5th_resist2 watervapor_5th_resist3 watervapor_5th_recovery1 watervapor_5th_nom];
wv_82   = [watervapor_82_nom  watervapor_82_resist1 watervapor_82_resist2 watervapor_82_recovery1 watervapor_82_nom   watervapor_82_resist1 watervapor_82_resist2 watervapor_82_resist3 watervapor_82_resist4 watervapor_82_recovery1 watervapor_82_recovery2 watervapor_82_aero watervapor_82_recovery1 watervapor_82_resist1 watervapor_82_resist2 watervapor_82_resist3 watervapor_82_resist4 watervapor_82_aero watervapor_82_resist1 watervapor_82_recovery1 watervapor_82_recovery2 watervapor_82_nom watervapor_82_resist1 watervapor_82_resist2 watervapor_82_resist3 watervapor_82_recovery1 watervapor_82_nom];
wv_95th = [watervapor_95th_nom watervapor_95th_resist1 watervapor_95th_resist2 watervapor_95th_recovery1 watervapor_95th_nom watervapor_95th_resist1 watervapor_95th_resist2 watervapor_95th_resist3 watervapor_95th_resist4 watervapor_95th_recovery1 watervapor_95th_recovery2 watervapor_95th_aero watervapor_95th_recovery1 watervapor_95th_resist1 watervapor_95th_resist2 watervapor_95th_resist3 watervapor_95th_resist4 watervapor_95th_aero watervapor_95th_resist1 watervapor_95th_recovery1 watervapor_95th_recovery2 watervapor_95th_nom watervapor_95th_resist1 watervapor_95th_resist2 watervapor_95th_resist3 watervapor_95th_recovery1 watervapor_95th_nom];


% Draw each chunk
for k = 1:length(wv_82)
    x = [t(k) t(k+1)];

    % shaded 5th-95th region
    fill([x fliplr(x)], [wv_5th(k) wv_5th(k) wv_95th(k) wv_95th(k)], 'b', ...
        'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off')

    % fill([x fliplr(x)], [co2_5th(k) co2_5th(k) co2_95th(k) co2_95th(k)], 'y', ...
    %     'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off')

    % lines
    plot(x, [wv_5th(k) wv_5th(k)], '--b')
    plot(x, [wv_82(k) wv_82(k)], 'b')
    plot(x, [wv_95th(k) wv_95th(k)], '--b')


    % task label centered under the chunk
    text(mean(x), -1.5, tasks{k}, 'HorizontalAlignment', 'center', 'FontSize', 8,'Clipping', 'off')

    % colored zone bar along the bottom of the plot
    c = zone_colors(strcmp(zone_names, zones{k}), :);
    fill([x fliplr(x)], [0 0 0.4 0.4], c, 'EdgeColor', 'none', 'HandleVisibility', 'off')

    
end

% Vertical connectors between chunks
for k = 1:length(wv_82)-1
    xb = t(k+1);   % boundary between chunk k and k+1
    plot([xb xb], [wv_5th(k)  wv_5th(k+1)],  '-b', 'HandleVisibility', 'off')
    plot([xb xb], [wv_95th(k) wv_95th(k+1)], '-b', 'HandleVisibility', 'off')
    plot([xb xb], [wv_82(k) wv_82(k+1)], '-b', 'HandleVisibility', 'off')

    
end

% End caps (left edge of first chunk, right edge of last chunk)
plot([t(1) t(1)],     [wv_5th(1)   wv_95th(1)],   '-b', 'HandleVisibility', 'off')
plot([t(end) t(end)], [wv_5th(end) wv_95th(end)], '-b', 'HandleVisibility', 'off')

ylim([0 18])
yticks(0:1:18)
xlim([0 t(end)])
xticks(0:0.25:t(end))

grid on;

% Max/min box (top left)
max_val = max(wv_95th);   % highest 95th percentile rate
min_val = min(wv_5th);    % lowest 5th percentile rate
text(0.02, 0.97, sprintf('Max: %.2f g/min\nMin: %.2f g/min', max_val, min_val), ...
    'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 9, ...
    'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 5)

% Totals (top right)
% Duration of each chunk in minutes (since each activity lasts different amounts of time)
dt = diff(t)*60;

% Total water vapor (g -> kg)
tot_wv_5th  = sum(wv_5th .*dt)/1000;
tot_wv_82   = sum(wv_82  .*dt)/1000;
tot_wv_95th = sum(wv_95th.*dt)/1000;

text(0.68, 0.97, sprintf('Total Water Vapor Produced\n5th: %.2f kg\n82: %.2f kg\n95th: %.2f kg', tot_wv_5th, tot_wv_82, tot_wv_95th), ...
    'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 9, ...
    'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 5)


legend("5th Percentile", "82 kg Reference", "95th Percentile")
xlabel("EVA Duration (hours)", 'FontSize', 12, 'FontWeight', 'bold')
ylabel("Metabolic Production Rates (g/min)")
subtitle("Varied EVA Metabolic Loads")
title("Water Vapor Production Rates with Changing Activity Zones")

% main plot layout: [left bottom width height]
ax = gca;
ax.Position = [0.05 0.2 0.85 0.72];
ax.XLabel.Position(2) = -2.4;
ax.XAxis.FontSize = 7;

% Zone key
zone_labels = {'Nominal', 'Aerobic', 'Resistive', 'Recovery'};
kax = axes('Position', [0.92 0.45 0.02 0.2]);
hold(kax, 'on')
for i = 1:4
    fill(kax, [0 1 1 0], [4-i 4-i 5-i 5-i], zone_colors(i,:), 'EdgeColor', 'k')
    text(kax, 1.3, 4.5-i, zone_labels{i}, 'FontSize', 8, 'VerticalAlignment', 'middle')
end
xlim(kax, [0 1])
ylim(kax, [0 4])
axis(kax, 'off')