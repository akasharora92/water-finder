function [r] = dirichlet(a)
    p = length(a);
    %r = gamrnd(repmat(a,n,1),1,n,p);
		r = zeros([1,p]);
		for i=1:p
			r(i) = gamma(a(i));
		end 
    r = r/sum(r);
end

function g=gamma(a)
		g = sum(-log(rand([1,a])));
end
