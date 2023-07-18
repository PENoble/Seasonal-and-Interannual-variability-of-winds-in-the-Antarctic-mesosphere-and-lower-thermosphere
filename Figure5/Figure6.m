%% This code makes line plots of interdecile range of monthly wind values.
clear all

%% set up figure
clear all

gcf = figure();
set(gcf,'color','w','position',[50 50 1000 375]);

%-------------------------------------------------------
vert_gap = 0.02;        horz_gap = 0.1;
lower_marg = 0.17;     upper_marg = 0.1;
left_marg = 0.1;      right_marg = 0.1;

rows = 1; cols = 2;

subplot = @(rows,cols,p) subtightplot (rows,cols,p,[vert_gap horz_gap],[lower_marg upper_marg],[left_marg right_marg]);

% Load data
MR = load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\MR Data\Data\AllYears.mat');
WACCM = load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\WACCM Data\OriginalData\AllWACCMRothera.mat');
height = WACCM.All.Data.Height;


% Loop over direction, height and type
for direction = 1:2 % 1 is U, 2 is V
    subplot(1,2,direction);
    switch direction
        case 1
            title('(a) Zonal wind');
        case 2 
            title('(b) Meridional wind');
    end
  
    for type = 1:2 % 1 is MR, 2 is WACCM    
        for height_chosen = 1:2 % 1 is 85, 2 is 95


            switch type
                case 1 
                    switch direction
                        case 1; wind = MR.AllYears.MonthlyMeanU;
                        case 2; wind = MR.AllYears.MonthlyMeanV;
                    end            
            
                case 2
                    switch direction
                        case 1; wind = WACCM.All.Data.MonthlyMeanU;
                        case 2; wind = WACCM.All.Data.MonthlyMeanV;
                    end            
            end

            % extract necessary height
            
            switch height_chosen
                case 1; idx = height == 85;
                case 2; idx = height == 95;
            end
            
            wind_at_specific_height = wind(idx,:);
            wind_at_specific_height = reshape(wind_at_specific_height, 12, size(wind,2)/12)';
            interdecile_range = prctile(wind_at_specific_height,90)-prctile(wind_at_specific_height,10);
            interdecile_range = [interdecile_range, interdecile_range, interdecile_range];
            

            switch type
                case 1; lineColor = 'r';
                case 2; lineColor = 'b';
            end
            
            switch height_chosen
                case 1; lineStyle = '';
                case 2; lineStyle = '--';
            end
            
            hold on
            plot(1:36,interdecile_range,[lineColor,lineStyle],'LineWidth',1.5);
            xlim([12.5,24.5]);
            ylim([0,36]);
            xticks(12.5:24.5)
            gapsize = 5;
            xticklabels({[ blanks(gapsize) 'J'], [ blanks(gapsize) 'F'], [ blanks(gapsize) 'M'],[ blanks(gapsize) 'A'],[ blanks(gapsize) 'M'], [ blanks(gapsize) 'J'],[ blanks(gapsize) 'J'], [ blanks(gapsize) 'A'], [ blanks(gapsize) 'S'], [ blanks(gapsize) 'O'],[ blanks(gapsize) 'N'], [ blanks(gapsize) 'D'], ''});
        end
    end
    switch direction
        case 1; ylabel('Interdecile range (ms^{-1})');
        case 2; legend({'Meteor radar 85km','Meteor radar 95km','WACCM-X 85km','WACCM-X 95km'},'Location','northeast','NumColumns',1);
    end
    xlabel('Month');
end
