function [ final_path ] = planLawnmover()
%this function takes an initial and final goal position as well as the
%total budget to plan a lawnmover like pattern

%min_budget = sum(goal_pos - init_pos);

init_pos = [1, 10];

%creates a zig zag path with a budget of 50
s_p = 3;
d_p = s_p*2-1;
lawnmover_vect = [0,0,0,0,s_p,0,0,-d_p,0,0,d_p,0,0,-d_p,0,0,d_p,0,0,-d_p,0,0,s_p-1,0,0,0];

%works given the lawnmover vect
path = [init_pos];
current_pos = init_pos;

for i = 1:length(lawnmover_vect)
    
    %move forward
    if lawnmover_vect(i) == 0
        current_pos = current_pos + [1,0];
        path = [path; current_pos];
        
        %move left
    elseif lawnmover_vect(i) < 0
        for j=1:abs(lawnmover_vect(i))
            current_pos = current_pos + [0,-1];
            path = [path; current_pos];
        end
        
        
        %move right
    else
        for j=1:abs(lawnmover_vect(i))
            current_pos = current_pos + [0,1];
            path = [path; current_pos];
        end
        
        
    end
  
end

%figure; plot(path(:,1), path(:,2))

%add NSS measurements to the path- uniformlyish
%with a budget of 50 we can use the NSS 10 times
%the lawnmover path is 50 steps long so we'll use NSS every 5 steps. This
%creates a path which is 60 long. 

final_path = zeros(60,3);
path_counter = 1;
NSS_counter = 0;
num_NSS = 0;
for i = 1:60
    if path_counter == 51
       final_path(60,:) = [path(path_counter-1,:),2];
       %disp('51')
       continue
    end
    %insert NSS reading
    if (NSS_counter == 5) && (num_NSS <= 10)
        NSS_counter = 0;
        final_path(i,:) = [path(path_counter-1,:),2];
        num_NSS = num_NSS + 1;
    else
        final_path(i,:) = [path(path_counter,:),1];
        path_counter = path_counter + 1;
        NSS_counter = NSS_counter + 1;
    end
    
end

end

