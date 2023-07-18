%Load the indices
load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\Figures\Figure2\Indices.mat');

start_yr = 2005; % note that the start year cannot be earlier than 2005 (as MR data doesn't exist).
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

indices = [(1:12*num_years)', f107', ENSO', QBO10', QBO30', SAM'];
titles = {'DJF','JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','ASO','SON','OND','NDJ'};
VIF = zeros(12,6);

for month = 1:12
    month_plus = month+1;
    month_minus = month-1;

    if month_plus == 13
        month_plus = 1;
    end

    if month_minus == 0
        month_minus = 12;
    end

    month_index_list = month:12:12*num_years;
    month_plus_index_list = month_plus:12:12*num_years;
    month_minus_index_list = month_minus:12:12*num_years;

    all_month_index = [month_index_list; month_plus_index_list; month_minus_index_list];
    all_month_index = reshape(all_month_index,[1,3*num_years]);

    indices_mnth = indices(all_month_index,:);
    timem = indices_mnth(:,1);
    f107m = indices_mnth(:,2);
    ENSOm = indices_mnth(:,3);
    QBO10m = indices_mnth(:,4);
    QBO30m = indices_mnth(:,5);
    SAMm = indices_mnth(:,6);
    
    % VIF calculation
    mdl1 = fitlm([f107m, ENSOm, QBO10m, QBO30m, SAMm],timem);
    VIF(month,1) = 1/(1-mdl1.Rsquared.ordinary);

    mdl2 = fitlm([timem, ENSOm, QBO10m, QBO30m, SAMm],f107m);
    VIF(month,2) = 1/(1-mdl2.Rsquared.ordinary);

    mdl3 = fitlm([timem, f107m, QBO10m, QBO30m, SAMm],ENSOm);
    VIF(month,3) = 1/(1-mdl3.Rsquared.ordinary);

    mdl4 = fitlm([timem, f107m, ENSOm, QBO30m, SAMm],QBO10m);
    VIF(month,4) = 1/(1-mdl4.Rsquared.ordinary);

    mdl5 = fitlm([timem, f107m, ENSOm, QBO10m, SAMm],QBO30m);
    VIF(month,5) = 1/(1-mdl5.Rsquared.ordinary);

    mdl6 = fitlm([timem, f107m, ENSOm, QBO10m, QBO30m],SAMm);
    VIF(month,6) = 1/(1-mdl6.Rsquared.ordinary);
end % month


%%
figure('position',[50 50 1200 300]); 
imagesc(1:12,1:6,VIF');
set(gca,'YDir','normal');
colorbar()
clim([1,1.5]);
colormap(cbrew('PuBu',100))

%text
for ki = 1:12
    for kj = 1:6
        text(ki, kj, string(sprintf('%.2f',VIF(ki,kj))),'HorizontalAlignment','center');
    end %ki
end %kj

xticks(1:12);
xticklabels({'DJF','JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','ASO','SON','OND','NDJ'});
% ytickangle(45);
yticks(1:6);
yticklabels({'TIME','F10.7','ENSO','QBO10','QBO30','SAM'});
title('VIF values');