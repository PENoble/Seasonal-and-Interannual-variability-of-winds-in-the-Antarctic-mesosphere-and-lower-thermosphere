%Import
clear all

% before this point, f107, Nino34 and SAM text files are loaded and saved
% into .mat file
num_years = 17;
indices = struct;

load('f107.mat');
load('Nino34.mat');
load('SAM.mat');

% get first 204 point from each array as we only want 2005-2021 (inclusive)
indices.f107 = f107(1:num_years*12)./10; 
indices.ENSO = Nino34(1:num_years*12);

% Removing seasonal cycle from SAM
SAM = SAM(1:num_years*12);
SAM_ave = mean(reshape(SAM,[12,num_years]),2,'omitnan');
SAM = SAM - repmat(SAM_ave, [num_years,1]);
indices.SAM = SAM;

indices.time = (datetime(2005,01,01):calmonths(1):datetime(2021,12,31))';

%% Loading QBO indices
era5 = nph_getnet('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\Figures\Figure2\era5_MonthlyMeanU.nc');
zonal_mean = squeeze(mean(mean(era5.Data.u,2,'omitnan'),1,'omitnan'));

QBO10 = zonal_mean(1,1:num_years*12);
QBO30 = zonal_mean(2,1:num_years*12);

indices.QBO10 = QBO10';
indices.QBO30 = QBO30';

save('indices.mat','indices')