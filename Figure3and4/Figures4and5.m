%% STRIP PLOTS MR
clear all

year_start = 2005;
year_end = 2021;
num_years = year_end - year_start+1;
mid_year = floor(year_start+num_years/2);

for WindDirection = 1:2  
    % Set up figure
    gcf = figure('position',[1900 -250 1000 900]); 
    set(gcf,'color','w')

    % set(gcf,'position',[50 50 1000 750]);
    vert_gap = 0.05;        horz_gap = 0.05;
    lower_marg = 0.12;     upper_marg = 0.13;
    left_marg = 0.15;      right_marg = 0.15;

    subplot = @(rows,cols,p) subtightplot (rows,cols,p,[vert_gap horz_gap],[lower_marg upper_marg],[left_marg right_marg]);
    
    switch WindDirection
        case 1; sgtitle('ZONAL WINDS','fontsize',20); 
        case 2; sgtitle('MERIDIONAL WINDS','fontsize',20); 
    end

    %Load data
    MR = load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\MR Data\Data\AllYears.mat');
    WACCM = load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\WACCM Data\OriginalData\AllWACCMRothera.mat');
    height = WACCM.All.Data.Height;
    
    for type = 1:2
        switch type
            case 1
            switch WindDirection
                case 1
                Z = MR.AllYears.MonthlyMeanU;
                Zlims = 50;
                AllU = mean(reshape(MR.AllYears.MonthlyMeanU,[size(height,2),12,num_years]),3,'omitnan');
                
                case 2
                Z = MR.AllYears.MonthlyMeanV;
                Zlims = 20;
                AllU = mean(reshape(MR.AllYears.MonthlyMeanV,[size(height,2),12,num_years]),3,'omitnan');
            end
            case 2
            switch WindDirection
                case 1
                Z = WACCM.All.Data.MonthlyMeanU;
                Zlims = 50;
                AllU = mean(reshape(WACCM.All.Data.MonthlyMeanU,[size(height,2),12,num_years]),3,'omitnan');
                
                case 2
                Z = WACCM.All.Data.MonthlyMeanV;
                Zlims = 20;
                AllU = mean(reshape(WACCM.All.Data.MonthlyMeanV,[size(height,2),12,num_years]),3,'omitnan');
            end %switch wind direction
            
        end % switch type


%         Position the monthly average at the 15th of each month
        Time = datenum(datetime(year_start,01,15):calmonths(1):datetime(datetime(year_end,12,15)));


        % Subplot of long time series looped over two parts
            for i = 1:2 % repeat for two strips
                switch type
                    case 1
                        switch i
                            case 1; subplot(26,18,[163:234]);
                            case 2; subplot(26,18, [235,304]);
                        end
                    case 2
                        switch i
                            case 1; subplot(26,18,[325:396]);
                            case 2; subplot(26,18, [397,466]);
                        end
                end
                hold on
                
                contourf(Time, height, Z, [-Zlims-10:1:Zlims+10], 'LineColor','none'); 
                [C1,h1] = contour(Time,  height, Z, [-Zlims:10:Zlims],'LineColor','black');
                [C3,h3] = contour(Time,  height, Z, [0 0],'LineWidth', 2, 'LineColor','black');
                yline(100, 'LineWidth',1,'Alpha',1);
                yline(80, 'LineWidth',1,'Alpha',1);
                hold off

                colormap(cbrew('RdBu',100))
                set(gca, 'ydir','normal'); clim([-Zlims,Zlims])
                grey = [170 170 170]/255;
                set(gca,'color',grey);
                set(gcf,'color','w');
                set(gca,'TickDir','out','TickLength',[0.005,0.005],'LineWidth',1);
                set(gca, 'fontsize', 15);

                %Position xticks at the beginning of each month
                times = datenum(datetime(year_start,01,01):calyears(1):datetime(datetime(year_end,12,31)));
                xticks(times);
                % Offset the label to appear in the gap
                datetick('x','             yyyy','keepticks');
                xtickangle(0);
                xline(datenum(year_end,12,31));
                ylim([80,100]);
                switch i
                    case 1
                        xlim([datenum(year_start, 01,01),datenum(mid_year, 12,31)]);
                    case 2
                        xlim([datenum(mid_year+1, 01,01),datenum(year_end, 12,31)]);  
                end
                
                switch i
                    case 1
                        switch type
                            case 1
                                title('(c) Meteor radar wind','fontsize',15);
                                text(-0.11,-0.2,'HEIGHT (km)','Units','Normalized','Rotation',90,'Fontsize',18,'VerticalAlignment','middle', 'HorizontalAlignment','center'); 

                            case 2
                                title('(d) WACCM-X wind','fontsize',15);
                                cbar = colorbar;
                                cbar.Ticks = -60:20:60;
                                cbar.Ruler.MinorTick = 'on';
                                cbar.Ruler.MinorTickValues = -60:10:60;
                                cbar.TickDirection = 'out';
                                cbar.Label.FontSize = 15;
                                cbar.Label.String = 'Wind speed (ms^{-1})';
                                set(cbar,'YTick',[-60:10:60],'Fontsize',15);
                                set(cbar,'Position',[0.88 0.2 0.02 0.6]);
                        end 
                end
            end %i 




        % Plotting composite year
        AllU = [AllU AllU AllU];
        
        switch type
            case 1; subplot(26,18,[1,135]);
            case 2; subplot(26,18,[10,144]);
        end
        
        hold on
        contourf(1:36,  height, AllU, [-Zlims-10:1:Zlims+10], 'LineColor','none'); 
        [C1,h1] = contour(1:36,  height, AllU, [0:10:Zlims],'LineColor','black');
        [C2,h2] = contour(1:36,  height, AllU, [-Zlims:10:0],'LineStyle','--', 'LineColor','black');
        [C3,h3] = contour(1:36,  height, AllU, [0 0],'LineWidth', 2, 'LineColor','black');
        yline(100, 'LineWidth',1,'Alpha',1);
        yline(80, 'LineWidth',1,'Alpha',1);
        xline(12.5);
        xline(24.5);
        hold off

        switch type
            case 1; title(strcat('(a) Meteor radar average year'));            
            case 2; title(strcat('(b) WACCM-X average year'));
        end

        colormap(cbrew('RdBu',100))
        set(gca, 'ydir','normal'); clim([-Zlims,Zlims])
        set(gca,'TickDir','out','TickLength',[0.005,0.005],'LineWidth',1);
        set(gcf,'InvertHardCopy','off');
        set(gca, 'fontsize', 15);

        %Position xticks at the beginning of each month
        xlim([12.5,24.5])
        ylim([80,100]);
        yticks([80,90,100]);

        gapsize = 5;
        box off;
        clim([-Zlims,Zlims]);
        xticks(12.5:1:24.5);
        xtickangle(0);
        set(gca,'xticklabel', {[ blanks(gapsize) 'J'], [ blanks(gapsize) 'F'], [ blanks(gapsize) 'M'],[ blanks(gapsize) 'A'],[ blanks(gapsize) 'M'], [ blanks(gapsize) 'J'],[ blanks(gapsize) 'J'], [ blanks(gapsize) 'A'], [ blanks(gapsize) 'S'], [ blanks(gapsize) 'O'],[ blanks(gapsize) 'N'], [ blanks(gapsize) 'D'], ''});

    end %type
end % wind direction