%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cost function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [c] = cost(sequence, robot)

c = 0;
if isempty(sequence)
    return
end

for i=1:length(sequence)
    if sequence(i) == 1
        c = c + robot.cost_mov;
    elseif sequence(i) == 2
        c = c + robot.cost_NIR;
    else
        c = c + robot.cost_NSS;
    end
end

end