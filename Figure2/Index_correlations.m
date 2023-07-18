%Checking correlations between indices on a 3 month basis
load('C:\Users\pn399\OneDrive - University of Bath\phoebe\PROJECT 1\Re-write\Figures\Figure2\Indices.mat');


correlations = nan(6,6,12);

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
    
    f107 = indices.f107(idx2);
    ENSO = indices.ENSO(idx2);
    QBO10 = indices.QBO10(idx2);
    QBO30 = indices.QBO30(idx2);
    SAM = indices.SAM(idx2);
    t = (1:204)';
    TIME = t(idx2);
    
    list = [TIME,f107, ENSO, QBO10, QBO30, SAM];
    for i = 1:6
        for j = i:6
            R = corrcoef(list(:,i), list(:,j));
            correlations(i,j,mnth_ii) = R(1,2);
        end
    end

end

labels = {'TIME','SOLAR','ENSO','QBO10','QBO30','SAM'};
figure()
for sub = 1:12
    subplot(4,3,sub)
    imagesc(1:6,1:6,correlations(:,:,sub));
    clim([-1,1]);
    colorbar();
    colormap(cbrew('RdBu',100))
    set(gca, 'ydir','normal'); 
    xticks(1:6); yticks(1:6);
    xticklabels(labels);
    yticklabels(labels);
end
