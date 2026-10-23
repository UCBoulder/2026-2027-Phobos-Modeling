clc; clear; close all;
figure('Units', 'normalized', 'Position', [0.05 0.1 0.9 0.8]);

% Varied EVA Metabolic Rates
% MetMan Data (outputs in g/min)

% nominal
CO2_82_nom = 0.69;

% aerobic
CO2_82_aero = 5.22;

% resistive
CO2_82_resist = 1.89;

% recovery
CO2_82_recovery = 0.69;

% Percentile Masses (kg)
M_5th = 53.685;
M_95th = 99.157;

% CALCULATIONS
% nominal
CO2_5th_nom = (CO2_82_nom)*(M_5th/82);
CO2_95th_nom = (CO2_82_nom)*(M_95th/82);

% aerobic
CO2_5th_aero = (CO2_82_aero)*(M_5th/82);
CO2_95th_aero = (CO2_82_aero)*(M_95th/82);

% resistive
CO2_5th_resist = (CO2_82_resist)*(M_5th/82);
CO2_95th_resist = (CO2_82_resist)*(M_95th/82);

% recovery
CO2_5th_recovery = (CO2_82_recovery)*(M_5th/82);
CO2_95th_recovery = (CO2_82_recovery)*(M_95th/82);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT
hold on;

% Time boundaries (one more entry than there are chunks)
t = [0 0.5 1 1.5 2 3 3.5 3.75 4 5 5.25 5.5 6 6.5 7.25 7.5 8];
%t = [0 0.5 0.75 1 1.5 2 2.25 2.5 2.75 3 3.25 3.5 3.75 4 4.25 4.5 4.75 5 5.25 5.5 5.75 6 6.5 6.75 7 7.25 7.5 8];


% Activity zone for each chunk (nom, aero, resist, or recovery)
zones = {'nom', 'resist', 'recovery', 'nom', 'resist', 'recovery', 'aero', 'recovery', 'resist', 'aero', 'resist', 'recovery','nom', 'resist', 'recovery', 'nom'};

% Zone colors: blue, red, yellow, green
zone_names  = {'nom', 'aero', 'resist', 'recovery'};
zone_colors = [0 0.45 0.9;    % nominal  - blue
               0.85 0.1 0.1;  % aerobic  - red
               1 0.85 0;      % resistive - yellow
               0.1 0.7 0.2];  % recovery - green

% Task name for each chunk
tasks = {'Egress', ['Load' newline 'Rover'], '', 'Drive               ', 'Assemble', 'Rest', ['Walk/' newline 'Climb'], 'Survey', 'Collect', ['Walk/' newline 'Climb'],['Load' newline 'Rover'], '', 'Drive               ', 'Unload', 'Rest', 'Ingress'};

% Creating the horizontal lines
co2_5th  = [CO2_5th_nom  CO2_5th_resist  CO2_5th_recovery CO2_5th_nom  CO2_5th_resist  CO2_5th_recovery CO2_5th_aero CO2_5th_recovery CO2_5th_resist CO2_5th_aero CO2_5th_resist CO2_5th_recovery CO2_5th_nom CO2_5th_resist CO2_5th_recovery CO2_5th_nom];
co2_82   = [CO2_82_nom   CO2_82_resist   CO2_82_recovery CO2_82_nom   CO2_82_resist   CO2_82_recovery CO2_82_aero CO2_82_recovery CO2_82_resist CO2_82_aero CO2_82_resist CO2_82_recovery CO2_82_nom CO2_82_resist CO2_82_recovery CO2_82_nom];
co2_95th = [CO2_95th_nom CO2_95th_resist CO2_95th_recovery CO2_95th_nom CO2_95th_resist CO2_95th_recovery CO2_95th_aero CO2_95th_recovery CO2_95th_resist CO2_95th_aero CO2_95th_resist CO2_95th_recovery CO2_95th_nom CO2_95th_resist CO2_95th_recovery CO2_95th_nom];


% Draw each chunk
for k = 1:length(tasks)
    x = [t(k) t(k+1)];

    % shaded 5th-95th region
    line_color = [1 0.5 0];
    fill([x fliplr(x)], [co2_5th(k) co2_5th(k) co2_95th(k) co2_95th(k)], line_color, ...
        'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off')

    % lines
    plot(x, [co2_5th(k) co2_5th(k)], '--', 'Color', line_color)
    plot(x, [co2_82(k) co2_82(k)], '-', 'Color', line_color)
    plot(x, [co2_95th(k) co2_95th(k)], '--', 'Color', line_color)

    % task label centered under the chunk
    text(mean(x), -0.8, tasks{k}, 'HorizontalAlignment', 'center', 'FontSize', 8,'Clipping', 'off')

    % colored zone bar along the bottom of the plot
    c = zone_colors(strcmp(zone_names, zones{k}), :);
    fill([x fliplr(x)], [0 0 0.4 0.4], c, 'EdgeColor', 'none', 'HandleVisibility', 'off')

    
end

% Vertical connectors between chunks

for k = 1:length(tasks)-1
    xb = t(k+1);   % boundary between chunk k and k+1
    plot([xb xb], [co2_5th(k)  co2_5th(k+1)],  '-', 'Color', line_color, 'HandleVisibility', 'off')
    plot([xb xb], [co2_95th(k) co2_95th(k+1)], '-', 'Color', line_color, 'HandleVisibility', 'off')
    plot([xb xb], [co2_82(k) co2_82(k+1)], '-', 'Color', line_color, 'HandleVisibility', 'off')
end

% End caps (left edge of first chunk, right edge of last chunk)
plot([t(1) t(1)],     [co2_5th(1)   co2_95th(1)],   '-', 'Color', line_color, 'HandleVisibility', 'off')
plot([t(end) t(end)], [co2_5th(end) co2_95th(end)], '-', 'Color', line_color, 'HandleVisibility', 'off')

ylim([0 8])
yticks(0:1:8)
xlim([0 t(end)])
xticks(0:0.5:t(end))
grid on;

% Max/min box (top left)
max_val = max(co2_95th);   % highest 95th percentile rate
min_val = min(co2_5th);    % lowest 5th percentile rate
text(0.02, 0.97, sprintf('Max: %.2f g/min\nMin: %.2f g/min', max_val, min_val), ...
    'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 9, ...
    'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 5)

% Totals (top right)
% Duration of each chunk in minutes (since each activity lasts different amounts of time)
dt = diff(t)*60;

% Total water vapor (g -> kg)
tot_co2_5th  = sum(co2_5th .*dt)/1000;
tot_co2_82   = sum(co2_82  .*dt)/1000;
tot_co2_95th = sum(co2_95th.*dt)/1000;

text(0.72, 0.97, sprintf('Total CO2 Produced\n5th: %.2f kg\n82: %.2f kg\n95th: %.2f kg', tot_co2_5th, tot_co2_82, tot_co2_95th), ...
    'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 9, ...
    'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 5)

legend("5th Percentile", "82 kg Reference", "95th Percentile")
xlabel("EVA Duration (hours)", 'FontSize', 12, 'FontWeight', 'bold')
ylabel("Metabolic Production Rates (g/min)")
subtitle("Varied EVA Metabolic Loads")
title("CO2 Production Rates with Changing Activity Zones")

% main plot layout: [left bottom width height]
ax = gca;
ax.Position = [0.05 0.2 0.85 0.72];
ax.XLabel.Position(2) = -1.5;

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