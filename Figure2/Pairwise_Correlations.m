%Load the indices
start_yr = 2005; % note that the start year cannot be earlier than 2005 (as MR data doesn't exist).
end_yr = 2021;

num_years = end_yr - start_yr + 1;


%Load the indices
load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\Figures\Figure2\Indices.mat');

f107 = indices.f107(1:end-(2022-end_yr)*12);
ENSO = indices.ENSO(1:end-(2022-end_yr)*12);
QBO10 = indices.QBO10(1:end-(2022-end_yr)*12);
QBO30 = indices.QBO30(1:end-(2022-end_yr)*12);
SAM = indices.SAM(1:end-(2022-end_yr)*12);
time = datetime(indices.time(1:end-(2022-end_yr)*12));

% Removing the seasonal cycle from SAM
SAM_ave = mean(reshape(SAM,[12,num_years]),2,'omitnan');
SAM = SAM - repmat(SAM_ave, [num_years,1]);

indices = [f107, ENSO, QBO10, QBO30, SAM, (1:12*num_years)']';
titles = {'DJF','JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','ASO','SON','OND','NDJ'};
matrix_correlations = zeros(5);
VIF = zeros(12,5);

figure('position',[50 50 1800 900]); 
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

    indices_mnth = indices(:,all_month_index);
    f107m = indices_mnth(:,1);
    ENSOm = indices_mnth(:,2);
    QBO10m = indices_mnth(:,3);
    QBO30m = indices_mnth(:,4);
    SAMm = indices_mnth(:,5);

    for i = 1:6
        for j = i:6
            R = corrcoef(indices_mnth(:,i), indices_mnth(:,j));
            matrix_correlations(i,j) = R(1,2);
        end

    end
    
    subplot(4,3,month)
    imagesc(matrix_correlations');
    colorbar()
    clim([-1,1]);
    colormap(cbrew('RdBu',100))
    
    %text
    for ki = 1:6
        for kj = ki:6
            text(ki, kj, string(sprintf('%.2f',matrix_correlations(ki,kj))),'HorizontalAlignment','center');
        end %ki
    end %kj
    
    xticks(1:6);
    xticklabels({'F10.7','ENSO','QBO10','QBO30','SAM','Time'});
    xtickangle(25);
    yticks(1:6);
    yticklabels({'F10.7','ENSO','QBO10','QBO30','SAM','Time'});
    title(titles(month));
end % months

figure()
all_matrix_correlations = zeros(6);

for i = 1:6
    for j = i:6
        R = corrcoef(indices(:,i), indices(:,j));
        all_matrix_correlations(i,j) = R(1,2);
    end
end

imagesc(all_matrix_correlations');
colorbar()
clim([-1,1]);
colormap(cbrew('RdBu',100))

%text
for ki = 1:6
    for kj = ki:6
        text(ki, kj, string(sprintf('%.2f',matrix_correlations(ki,kj))),'HorizontalAlignment','center');
    end %ki
end %kj

xticks(1:6);
xticklabels({'F10.7','ENSO','QBO10','QBO30','SAM','Time'});
xtickangle(45);
yticks(1:6);
yticklabels({'F10.7','ENSO','QBO10','QBO30','SAM','Time'});
title('All months');