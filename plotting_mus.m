mus = [[15, 18]; [10, 15]; [8, 16]];

plot_mu = [];
plot_mean = [];

while true
    
    [result, dummy] = simulation(mus, 5000);
    
    plot_mu = [plot_mu, 1 / mean(mus(1,:))];
    plot_mean = [plot_mean, result(1)];
    
    disp(result(1));
    
    if result(1) < 1e-3
        break;
    end
    
    mus(1, 1) = mus(1, 1) - 0.5;
    mus(1, 2) =  mus(1, 2) - 0.5;
    
   if mus(1, 1) == 0
       mus(1, 1) = 1;
   end
   
   if mus(1, 2) == 0
       mus(1, 2) = 1;
   end
   
end

plot(plot_mu, plot_mean)