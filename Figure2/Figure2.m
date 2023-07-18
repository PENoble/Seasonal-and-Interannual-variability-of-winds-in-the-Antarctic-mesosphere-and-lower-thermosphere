%% Plotting indices
clear all

start_yr = 2005;
end_yr = 2021;

num_years = end_yr - start_yr + 1;


%Load the indices
load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\Figures\Figure2\Indices.mat');

f107 = indices.f107';
ENSO = indices.ENSO';
QBO10 = indices.QBO10';
QBO30 = indices.QBO30';
SAM = indices.SAM';
time = datetime(indices.time');

fig1 = figure('position',[2000 -200 1400 800]); 
hold all; set(gcf,'color','w')

vert_gap = 0.07;        horz_gap = 0.05;
lower_marg = 0.08;     upper_marg = 0.12;
left_marg = 0.1;      right_marg = 0.07;

subplot = @(rows,cols,p) subtightplot (rows,cols,p,[vert_gap horz_gap],[lower_marg upper_marg],[left_marg right_marg]);
sgtitle('Linear regression indices','fontsize',25); 

subplot(5,1,1)
plot(time,f107,'LineWidth',2, 'color',[0.8500, 0.3250, 0.0980]);
set(gca,'TickLength',[0.005, 0.005],'fontsize',13);
xticks(datetime(start_yr,01,01):calyears(1):datetime(end_yr,12,31));
datetick('x','             YYYY','keepticks');
xtickangle(0);
% xticklabels({});
xlim([datetime(start_yr,01,01),datetime(end_yr+1,01,01)]);
ylim([60,180]);
yticks(60:40:180);
grid on
text(1.01, 0.5, 'SOLAR', 'Units', 'Normalized', 'fontsize', 20, 'color',[0.8500, 0.3250, 0.0980], 'rotation', 90, 'HorizontalAlignment','center','VerticalAlignment','middle');
title('(a) F10.7 (sfu)');


subplot(5,1,2)
plot(time,ENSO,'LineWidth',2, 'color', [0.9290, 0.6940, 0.1250]);
set(gca,'TickLength',[0.005, 0.005],'fontsize',13);
xticks(datetime(datetime(start_yr,01,01):calyears(1):datetime(end_yr,12,31)));
datetick('x','             YYYY','keepticks');
xtickangle(0);
xlim([datetime(start_yr,01,01),datetime(end_yr+1,01,01)]);
ylim([24,30]);
yticks([24:2:30]);
text(1.01, 0.5, 'ENSO', 'Units', 'Normalized', 'fontsize', 20, 'color', [0.9290, 0.6940, 0.1250], 'rotation', 90, 'HorizontalAlignment','center','VerticalAlignment','middle');
% box off
grid on
title('(b) ENSO (°C)');


subplot(5,1,3)
plot(time,QBO10,'LineWidth',2, 'color',[0.4940, 0.1840, 0.5560]);
set(gca,'TickLength',[0.005, 0.005],'fontsize',13);
xticks(datetime(datetime(start_yr,01,01):calyears(1):datetime(end_yr,12,31)));
datetick('x','             YYYY','keepticks');
xtickangle(0);
xlim([datetime(start_yr,01,01),datetime(end_yr+1,01,01)]);
% xticklabels({});
ylim([-40,20]);
yticks([-40:20:20]);
text(1.01, 0.5, 'QBO10', 'Units', 'Normalized', 'fontsize', 20, 'color',[0.4940, 0.1840, 0.5560], 'rotation', 90, 'HorizontalAlignment','center','VerticalAlignment','middle');
% box off
grid on
title('(c) QBO10 (ms^{-1})');

subplot(5,1,4)
plot(time,QBO30,'LineWidth',2, 'color', [0.4660, 0.6740, 0.1880]);
set(gca,'TickLength',[0.005, 0.005],'fontsize',13);
xticks(datetime(datetime(start_yr,01,01):calyears(1):datetime(end_yr,12,31)));
datetick('x','             YYYY','keepticks');
xtickangle(0);% xticklabels({});
xlim([datetime(start_yr,01,01),datetime(end_yr+1,01,01)]);
ylim([-40,20]);
yticks([-40:20:20]);
text(1.01, 0.5, 'QBO30', 'Units', 'Normalized', 'fontsize', 20, 'color', [0.4660, 0.6740, 0.1880], 'rotation', 90, 'HorizontalAlignment','center','VerticalAlignment','middle');
% box off
grid on
title('(d) QBO30 (ms^{-1})');

subplot(5,1,5)
plot(time,SAM,'LineWidth',2, 'color', [0.3010, 0.7450, 0.9330]);
set(gca,'TickLength',[0.005, 0.005],'fontsize',13);
xticks(datetime(datetime(start_yr,01,01):calyears(1):datetime(end_yr,12,31)));
datetick('x','             YYYY','keepticks');
xtickangle(0);xlim([datetime(start_yr,01,01),datetime(end_yr+1,01,01)]);
ylim([-5,5]);
yticks([-5:2.5:5]);
text(1.01, 0.5, 'SAM', 'Units', 'Normalized', 'fontsize', 20, 'color', [0.3010, 0.7450, 0.9330], 'rotation', 90, 'HorizontalAlignment','center','VerticalAlignment','middle');
% box off
grid on
title('(e) SAM (hPa)');
