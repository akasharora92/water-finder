%reads in the excel data sheets and calculates required results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ent_data = xlsread('lawnmover_comp.xlsx','Sheet1');

%get the terminal entropy value for each run- works
ent_datafinal = zeros(size(ent_data,2),1);
for i = 1:size(ent_data,2)
    %go through each row
    for j = 1:size(ent_data,1)
        if ent_data(j,i) == 0
           ent_datafinal(i) = ent_data((j-1),i); 
           break
        end
    end
    
end

ent_datareshape = reshape(ent_datafinal,4,30);
info_gainvect = 439.445 - ent_datareshape;

%performance improvement over random policy
info_gainratio = zeros(size(info_gainvect));
info_gainratio(1,:) = info_gainvect(1,:)./info_gainvect(2,:);
info_gainratio(2,:) = info_gainvect(2,:)./info_gainvect(2,:);
info_gainratio(3,:) = info_gainvect(3,:)./info_gainvect(2,:);
info_gainratio(4,:) = info_gainvect(4,:)./info_gainvect(2,:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
brier_data = xlsread('lawnmover_comp.xlsx','Sheet3');

%get the terminal brier score for each run
brier_datafinal = zeros(size(brier_data,2),1);
for i = 1:size(brier_data,2)
    %go through each row
    for j = 1:size(brier_data,1)
        if brier_data(j,i) == 0
           brier_datafinal(i) = brier_data((j-1),i); 
           break
        end
    end
    
end

brier_reshape = reshape(brier_datafinal,4,30);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
