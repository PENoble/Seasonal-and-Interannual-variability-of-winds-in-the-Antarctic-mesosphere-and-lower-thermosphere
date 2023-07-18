%% MR Linear regression 
% Current working version 22nd March 2023
% Re-write for paper with new data

clear all;

% 
list_choice = {'TIME','SOLAR','ENSO','QBO10','QBO30','SAM'}; 
% list_choice = {'SOLAR','ENSO','QBO10','QBO30','SAM','TIME'};
num_indices = length(list_choice);

start_yr = 2005; % note that the start year cannot be earlier than 2005 (as MR data doesn't exist).
end_yr = 2021; % inclusive

% yr_label = strcat(string(start_yr),'-',string(end_yr));
length_yrs = end_yr - start_yr + 1;

% Output variables
RegressionResults = struct;
RegressionResults.MR = struct;
RegressionResults.WACCM = struct;
RegressionResults.MR.U = struct;
RegressionResults.MR.V = struct;
RegressionResults.WACCM.U = struct;
RegressionResults.WACCM.V = struct;
output_dir = 'C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\Figures\Figure7and8\';



%Load the indices
load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\Figures\Figure2\Indices.mat');
load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\OZONE\dataset-satellite-ozone-v1-57fa5918-d4ee-469a-a5a7-2cb08abf40d4\OZONE.mat')
OZONE = ozone.noseason;
f107 = indices.f107;
ENSO = indices.ENSO;
QBO10 = indices.QBO10;
QBO30 = indices.QBO30;
SAM = indices.SAM;
time = datetime(indices.time);
TIME = (1:length(time))';

% Full descriptions
full_list = {'TIME';'SOLAR';'ENSO';'QBO10';'QBO30';'SAM';'OZONE'};
full_units = {'per \alpha years';'per \alpha sfu';'per \alpha °C';'per \alpha m/s';'per \alpha m/s';'per \alpha hPa';'per \alpha DU'};
full_variables = {TIME;f107;ENSO;QBO10;QBO30;SAM;OZONE};


% Calculate scaling for all vars
perc = 90;
scaling_list = [];

for i = 1:length(full_variables)
    scaling_list = [scaling_list, prctile(full_variables{i},perc) - prctile(full_variables{i},100-perc)];
end % i
scaling_list(1) = 120; % 120 for time scaling per decade
scaling_list(2) = 100; % 100 for time scaling per 100sfu
scaling_list = scaling_list';

look_up_table = table(full_list, full_units, full_variables, scaling_list);
look_up_table.Properties.RowNames = full_list;

% Selecting subset of variables chosen
units = cell(size(list_choice));
labels = cell(size(list_choice));
scalings = nan(size(list_choice));
variables = cell(size(list_choice));

for i = 1:num_indices
    units(i) = look_up_table{list_choice(i),'full_units'};
    labels(i) = look_up_table{list_choice(i),'full_list'};
    scalings(i) = look_up_table{list_choice(i),'scaling_list'};
    variables(i) = look_up_table{list_choice(i),'full_variables'};
end % i

data_table = table(labels', units', variables', scalings');
data_table.Properties.RowNames = labels;
data_table.Properties.VariableNames = {'Name', 'Units', 'Variable','Scaling'};

for input_data = 1:2 % 1 = MR, 2 = WACCM
    disp(strcat('Data source =',string(input_data)));
    for direction = 1:2 % 1 = Zonal wind, 2 = meridional wind
        disp(strcat('Wind direction =',string(direction)));
        switch input_data
            % Loading necessary data for direction and source
            case 1
                % Load MR data
                MR = load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\MR Data\Data\AllYears.mat');
                height = MR.AllYears.Height;
                
                switch direction
                    case 1; U = MR.AllYears.MonthlyMeanU;
                    case 2; U = MR.AllYears.MonthlyMeanV;
                end

            case 2
                % Load WACCM data
                WACCM = load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\WACCM Data\OriginalData\AllWACCMRothera.mat');
                height = WACCM.All.Data.Height;
                
                switch direction
                    case 1; U = WACCM.All.Data.MonthlyMeanU;
                    case 2; U = WACCM.All.Data.MonthlyMeanV;
                
                end

                % removing years that are missing from the MR
                
                % times missing (due to bad data quality)
                % pick a middle height for this
                MR = load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\MR Data\Data\AllYears.mat');
                uu = MR.AllYears.MonthlyMeanU(15,:);
                nan_idx = isnan(uu);

                U(:, nan_idx) = nan; 

        end % input_data switch
      
        %% REGRESSION PRE PROCESSING - find and remove anomaly 
        % Variables for first step
        U_anomaly = nan(size(height,2),12*length_yrs);

        for height_i = 1:size(height,2)
            %average year - and use this as oU_anomaly season
            aveU = mean(reshape(U(height_i,:), [12,length_yrs]),2,'omitnan')';
            % copying the season (length_yrs) times for each year.
            season = repmat(aveU, [1,length_yrs])';

            % Subtracting the anomaly from the wind
            U_anomaly(height_i,:) = U(height_i,:) - season'; 

        end % height_i

        % For Main regression later
        mdl = cell(size(height,2),12);
        DW_test = nan(size(height,2),12);
        p_DW_test = nan(size(height,2),12);
        coeffs = nan(size(height,2),12,num_indices+1);
        pv = nan(size(height,2),12,num_indices+1);
        t_stat = nan(size(height,2),12,num_indices+1);

        for height_ii = 1:size(height,2)
            for mnth_ii = 1:12
                %Extracting month window around selected month.
                if mnth_ii == 12
                    mnth_plus = 1;
                else
                    mnth_plus = mnth_ii+1;
                end

                if mnth_ii == 1
                    mnth_minus = 12;
                else
                    mnth_minus = mnth_ii-1;
                end

                %Selecting the values from those months
                idx2 = month(time) == mnth_minus | month(time) == mnth_ii | month(time) == mnth_plus;

                % Extracting the index values for each three month window
                month_subset = cell(size(list_choice));
                for t_i = 1:length(data_table.Name) % looping through table variables
                    temp_data = data_table.Variable{t_i};
                    temp_data_subsetted = temp_data(idx2);
                    month_subset{t_i} = temp_data_subsetted;
                    clear temp_data
                end 

                data_table = addvars(data_table, month_subset', 'NewVariableNames', {'Month_subset'});
                
                % do the same to wind variables
                Um = U_anomaly(height_ii, idx2);

        
                %% Regression
                matrix = [];

                for t_i = 1:length(data_table.Name) % looping through table variables
                    matrix = [matrix, data_table.Month_subset{t_i}];
                end 

                % Saving the linear regression in a cell array.
                mdl{height_ii,mnth_ii} = fitlm(matrix, Um);

                % Properties of the regression
                [t,DW] = dwtest(mdl{height_ii, mnth_ii});
                DW_test(height_ii, mnth_ii) = DW;
                p_DW_test(height_ii, mnth_ii) = t;

                
                % saved for later
                % Coefficients of the regression for each height, month and term
                coeffs(height_ii, mnth_ii,:) = mdl{height_ii,mnth_ii}.Coefficients.Estimate;        
                % p values of the regression for each height, month and term
                pv(height_ii, mnth_ii,:) = mdl{height_ii,mnth_ii}.Coefficients.pValue;
                t_stat(height_ii, mnth_ii,:) = mdl{height_ii,mnth_ii}.Coefficients.tStat;
                

                % clear temp variables from table
                data_table = removevars(data_table, {'Month_subset'});
            end % mnth

        end %height

        
        % Saving results
        switch input_data
            case 1 
            switch direction
                case 1;     RegressionResults.MR.U.scalingList = data_table.Scaling;
                            RegressionResults.MR.U.t_stat = t_stat(:,:,2:num_indices+1);
                            RegressionResults.MR.U.coefficients = coeffs(:,:,2:num_indices+1);
                            RegressionResults.MR.U.height = height;
                            RegressionResults.MR.U.DW_test = DW_test;
                            RegressionResults.MR.U.p_DW_test = p_DW_test;

                case 2;     RegressionResults.MR.V.scalingList = data_table.Scaling;
                            RegressionResults.MR.V.t_stat = t_stat(:,:,2:num_indices+1);
                            RegressionResults.MR.V.coefficients = coeffs(:,:,2:num_indices+1);
                            RegressionResults.MR.V.height = height;
                            RegressionResults.MR.V.DW_test = DW_test;
                            RegressionResults.MR.V.p_DW_test = p_DW_test;
            end
            
            case 2
            switch direction
                case 1;     RegressionResults.WACCM.U.scalingList = data_table.Scaling;
                            RegressionResults.WACCM.U.t_stat = t_stat(:,:,2:num_indices+1);
                            RegressionResults.WACCM.U.coefficients = coeffs(:,:,2:num_indices+1);
                            RegressionResults.WACCM.U.height = height;
                            RegressionResults.WACCM.U.DW_test = DW_test;
                            RegressionResults.WACCM.U.p_DW_test = p_DW_test;

                case 2;     RegressionResults.WACCM.V.scalingList = data_table.Scaling;
                            RegressionResults.WACCM.V.t_stat = t_stat(:,:,2:num_indices+1);
                            RegressionResults.WACCM.V.coefficients = coeffs(:,:,2:num_indices+1);
                            RegressionResults.WACCM.V.height = height;
                            RegressionResults.WACCM.V.DW_test = DW_test;
                            RegressionResults.WACCM.V.p_DW_test = p_DW_test;
                            
            end    
        end % input_data
        
    end % direction

end %input_data

%% PLOTTING

for direction = 1:2 % 1 is zonal, 2 meridional

    gcf = figure();
    title('ll');
    set(gcf,'color','w','position',[2800 -230 800 900]);

    %-------------------------------------------------------
    vert_gap = 0.02;        horz_gap = 0.04;
    lower_marg = 0.05;     upper_marg = 0.12;
    left_marg = 0.2;      right_marg = 0.25;

    rows = num_indices; cols = 2;

    subplot = @(rows,cols,p) subtightplot (rows,cols,p,[vert_gap horz_gap],[lower_marg upper_marg],[left_marg right_marg]);
    switch direction
        case 1; sgtitle('ZONAL WIND REGRESSION COEFFICIENTS','Fontsize',18);
        case 2; sgtitle('MERIDIONAL WIND REGRESSION COEFFICIENTS','Fontsize',18);
    end
    
    figLabels = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(h)','(i)','(j)','(k)','(l)','(m)','(n)'};
    for index = 1:num_indices
        
        for type = 1:2    % 1 is MR, 2 WACCM
            switch direction 
                case 1
                switch type
                    case 1; Results = RegressionResults.MR.U;
                    case 2; Results = RegressionResults.WACCM.U;
                end
                case 2
                switch type 
                    case 1; Results = RegressionResults.MR.V;
                    case 2; Results = RegressionResults.WACCM.V;
                end
            end
            
            scaling = Results.scalingList(index);
            t_stat = Results.t_stat(:,:,index);
            coeffs = Results.coefficients(:,:,index);
            height = Results.height;

            coeffs = scaling.*coeffs;
            
            % arranging subplots
            num = (index-1)*2 + type;
            subplot(num_indices,2,num);
            text(0.08,0.9,string(figLabels(num)),'FontWeight','bold','HorizontalAlignment', 'center', 'Units','Normalized','Fontsize',14,'color','white');
            text(0.08,0.9,string(figLabels(num)),'HorizontalAlignment', 'center', 'Units','Normalized','Fontsize',13);
            
            axx = gca;
            x = 1:36; 
            y = height;
            Z = [coeffs, coeffs, coeffs];
            t = [t_stat,t_stat,t_stat];

            %interpolating for hatching
            [X,Y] = meshgrid(x,y);
            xq = 1:0.1:36;
            yq = 79:0.25:101;
            [Xq,Yq] = meshgrid(xq,yq);

            Zq = interp2(X,Y,Z,Xq,Yq);
            Tq = interp2(X,Y,t,Xq,Yq);

            
            
            %hatching
            hold on
            H1 = imagesc(xq,yq,Zq);
            h = patch(axx.XLim([1 2 2 1]), axx.YLim([1 1 2 2]),'red');
            hh = hatchfill(h, 'single',45,3);
            % set(H1, 'EdgeColor', 'none');

            set(hh, 'color', [0 0 0 0.5],'linewi',1);


%             nanmask = t<1.7 & t>-1.7; % 1.7 is the critcal value for t-stat at 90%
            % nanmask = t<2.05 & t>-2.05; %  is the critcal value for t-stat at 95%
%             nanmask = t<2.47 & t>-2.47; %  is the critcal value for t-stat at 99%

            nanmask = Tq<2.03 & Tq>-2.03; %  is the critcal value for t-stat at 95%

            Z_nan = Zq;
            Z_nan(~nanmask) = NaN;

            imAlpha=ones(size(Zq));
            imAlpha(isnan(nanmask))=0;
            imagesc(xq,yq,Zq,'AlphaData',nanmask);

            % set(H2, 'EdgeColor', 'none');
            contour(xq,yq,Zq,-10:5:10,'k','Showtext','on');

            hold off

            gapsize = 3;



            switch index
                case num_indices
                    set(gca,'xticklabel', {[ blanks(gapsize) 'J'], [ blanks(gapsize) 'F'], [ blanks(gapsize) 'M'],[ blanks(gapsize) 'A'],[ blanks(gapsize) 'M'], [ blanks(gapsize) 'J'],[ blanks(gapsize) 'J'], [ blanks(gapsize) 'A'], [ blanks(gapsize) 'S'], [ blanks(gapsize) 'O'],[ blanks(gapsize) 'N'], [ blanks(gapsize) 'D'], ''});
                    switch type
                        case 1
                            text(-0.3,4,'HEIGHT (km)','Units','Normalized','Rotation',90,'Fontsize',15,'VerticalAlignment','middle', 'HorizontalAlignment','center') 
                        case 2
                            c = colorbar; 
                            c.Label.String = strcat('Regression coefficient (ms^{-1} per \alpha)');
                            set(c,'YTick',[-10:2:10],'Fontsize',13);
                            set(c,'Position',[0.83 0.15 0.02 0.6]);
                    end
            end



            colormap(cbrew('RdBu',100))
            set(gca, 'ydir','normal'); 
            clim([-10,10])
            set(gcf,'color','w')
            set(gca,'TickDir','out','TickLength',[0.005,0.005],'LineWidth',1.5);
            set(gca, 'fontsize', 13);
            set(gca, 'xtick',12.5:24.5);
            xtickangle(0);

            yline(80);
            yline(100);
            xline(12.5);
            xline(24.5);

            ylim([80,100]);    
            
            switch type
                case 1; yticks(80:10:100);
                case 2; yticks(80:10:100); yticklabels({[]});
            end
            

            xlim([12.5,24.5]);

            switch index
                case 1
                    switch direction
                        case 1
                        switch type
                            case 1; title('Meteor radar','fontsize',15);
                            case 2; title('WACCM-X','fontsize',15);
                        end
                        case 2
                        switch type
                            case 1; title('Meteor radar','fontsize',15);
                            case 2; title('WACCM-X','fontsize',15);
                        end
                    end
                    xticklabels({[]});
                    
                case 2; xticklabels({[]});
                case 3; xticklabels({[]});
                case 4; xticklabels({[]});
                case 5; xticklabels({[]});
            end
            
            switch type % if on RHS
                case 2; text(1.05, 0.5, string(data_table.Name{index}), 'Units', 'Normalized', 'fontsize', 18, 'rotation', 90, 'HorizontalAlignment','center','VerticalAlignment','middle');
            end
            



        end % panel

    end %index
end % figure

