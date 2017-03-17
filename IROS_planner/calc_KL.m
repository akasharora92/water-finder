%calculate KL divergence of set of trials

true_theta = [1 1 18; 2 17 1; 17 2 1];
true_theta = true_theta./sum(true_theta,1);

%true_theta = 1/3.*ones(3);

test_kl = kl_random;

kl_1_mat = zeros(3,size(test_kl,2));
kl_2_mat = zeros(3,size(test_kl,2));

for i = 1:size(test_kl,2)
   theta_mat = test_kl(:,i);
   theta_mat = reshape(theta_mat,3,3);
   
   for j = 1:3  %calculating KL for each terrain type
      theta_row = theta_mat(j,:);
      kl1 = 0;
      for k = 1:3
         kl1 = kl1 + theta_row(k)*(log(theta_row(k)) -log(true_theta(j,k))); 
      end
      kl_1_mat(j,i) = kl1;
      
      kl2 = 0;
      for k = 1:3
         kl2 = kl2 + true_theta(j,k)*(log(true_theta(j,k))-log(theta_row(k))); 
      end
      kl_2_mat(j,i) = kl2;
      
   end
    
    
end

kl_ave = [mean(mean(kl_1_mat,1),2),mean(mean(kl_2_mat,1),2)];