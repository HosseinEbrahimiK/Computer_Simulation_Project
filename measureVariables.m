sum_system_time_covid_pos = 0;
sum_system_time_covid_neg = 0;
sum_inqueue_covid_pos     = 0;
sum_inqueue_covid_neg     = 0;
sum_bored_people          = 0;

num_covid_pos = 0;
num_covid_neg = 0;

mean_system_all       = 0;

mean_inqueue_covid_pos = 0;
mean_inqueue_covid_neg = 0;
mean_inqueue_covid_all = 0;
mean_bored_people      = 0;

response_time_pos = [];
response_time_neg = [];

queue_time_pos = [];
queue_time_neg = [];

arr = [];

period = 100;
bins = zeros(1, floor(time / period));
bins_pos = zeros(1, floor(time / period));
bins_neg = zeros(1, floor(time / period));

bin_times = [];

for i = 1:length(finished_patient)
    
    if finished_patient(i).done == 0
        sum_bored_people = sum_bored_people + 1;
    end
    if finished_patient(i).covidTest == 1
        sum_system_time_covid_pos = sum_system_time_covid_pos + finished_patient(i).queueReceptionTime + finished_patient(i).queueTreatTime + finished_patient(i).serviceTime + finished_patient(i).receptionDuration;
        sum_inqueue_covid_pos = sum_inqueue_covid_pos + finished_patient(i).queueReceptionTime + finished_patient(i).queueTreatTime;
        num_covid_pos = num_covid_pos + 1;
    else
        sum_system_time_covid_neg = sum_system_time_covid_neg + finished_patient(i).queueReceptionTime + finished_patient(i).queueTreatTime + finished_patient(i).serviceTime + finished_patient(i).receptionDuration;
        sum_inqueue_covid_neg = sum_inqueue_covid_neg + finished_patient(i).queueReceptionTime + finished_patient(i).queueTreatTime;
        num_covid_neg = num_covid_neg + 1;
    end
    
    if finished_patient(i).covidTest == 0
        response_time_neg = [response_time_neg, finished_patient(i).receptionDuration + finished_patient(i).serviceTime];
        queue_time_neg = [queue_time_neg, finished_patient(i).queueReceptionTime + finished_patient(i).queueTreatTime];
    else
        response_time_pos = [response_time_pos, finished_patient(i).receptionDuration + finished_patient(i).serviceTime];
        queue_time_pos = [queue_time_pos, finished_patient(i).queueReceptionTime + finished_patient(i).queueTreatTime];
    end
    
    for b = floor(finished_patient(i).enterTime / period)+1 : floor(finished_patient(i).finishTime / period)
        if finished_patient(i).covidTest == 1
            bins_pos(b) = bins_pos(b) + 1;
        else
            bins_neg(b) = bins_neg(b) + 1;
        end
        bins(b) = bins(b) + 1; 
    end
    
end

mean_system_pos = sum_system_time_covid_pos / num_covid_pos;
mean_system_neg = sum_system_time_covid_neg / num_covid_neg;
mean_system_all = (sum_system_time_covid_pos + sum_system_time_covid_neg) / num_of_patient;

mean_inqueue_covid_pos = sum_inqueue_covid_pos / num_covid_pos;
mean_inqueue_covid_neg = sum_inqueue_covid_neg / num_covid_neg;
mean_inqueue_covid_all = (sum_inqueue_covid_pos + sum_inqueue_covid_neg) / num_of_patient;

mean_bored_people = sum_bored_people / num_of_patient;

disp(mean_system_pos);
disp(mean_system_neg);
disp(mean_system_all);

disp(mean_inqueue_covid_pos);
disp(mean_inqueue_covid_neg);
disp(mean_inqueue_covid_all);

disp(mean_bored_people);

disp(sum_queue_reception / time);
disp(sum_queue_rooms / time);

acc_mu = [[10, 9]; [14, 15]; [2, 3]];


num_p = 1000;

[dummy, patient_results] = simulation(acc_mu, num_p);
brr = [];

for i = 1:length(patient_results)
    brr = [brr, patient_results(i).queueReceptionTime + patient_results(i).queueTreatTime];
end

disp((1 - (1.96 * std(brr)) / (sqrt(length(patient_results)) * mean(brr))));

while (1 - (1.96 * std(brr)) / (sqrt(length(patient_results)) * mean(brr))) < 0.95
    
    num_p = num_p + 100;
    
    [dummy, patient_results] = simulation(acc_mu, num_p);
    
    for i = 1:length(patient_results)
        brr = [brr, patient_results(i).queueReceptionTime + patient_results(i).queueTreatTime];
    end
    disp((1 - (1.96 * std(brr)) / (sqrt(length(patient_results)) * mean(brr))));
    disp(num_p);
end

subplot(4, 1, 1);
hist1 = histogram(queue_time_neg, 20, 'facecolor', 'b');
title('queue negative patients');
subplot(4, 1, 2);
hist2 = histogram(queue_time_pos, 20, 'facecolor', 'r');
title('queue positive patients');

subplot(4, 1, 3);
hist3 = histogram(response_time_neg, 20, 'facecolor', 'g');
title('response negative patients');
subplot(4, 1, 4);
hist4 = histogram(response_time_pos, 20);
title('response positive patients');
figure;

present_freq = mean(bins / period);
present_freq_pos = mean(bins_pos / period);
present_freq_neg = mean(bins_neg / period);

disp(present_freq);
disp(present_freq_pos);
disp(present_freq_neg);

subplot(3, 1, 1);
hist5 = histogram(bins);

subplot(3, 1, 2);
hist6 = histogram(bins_pos);

subplot(3, 1, 3);
hist7 = histogram(bins_neg);
figure;

for t = 1:length(bins)
    bin_times = [bin_times, (period * (t-1) + period * t)  / 2];
end

subplot(3, 1, 1);
fig1 = plot(bin_times, bins);

subplot(3, 1, 2);
fig2 = plot(bin_times, bins_pos);

subplot(3, 1, 3);
fig3 = plot(bin_times, bins_neg);
figure;

subplot(3, 1, 1);
fig1 = plot(event, len_queue);

subplot(3, 1, 2);
fig2 = plot(event, len_queue_pos);

subplot(3, 1, 3);
fig3 = plot(event, len_queue_neg);
figure;

fig4 = plot(event, rooms(1).len_queue);
figure;
