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
arr = [];

for i = 1:length(finished_patient)
    
    if finished_patient(i).done == 0
        sum_bored_people = sum_bored_people + 1;
    end
    if finished_patient(i).covidTest == 1
        sum_system_time_covid_pos = sum_system_time_covid_pos + finished_patient(i).queueReceptionTime + finished_patient(i).queueTreatTime + finished_patient(i).serviceTime;
        sum_inqueue_covid_pos = sum_inqueue_covid_pos + finished_patient(i).queueReceptionTime + finished_patient(i).queueTreatTime;
        num_covid_pos = num_covid_pos + 1;
    else
        sum_system_time_covid_neg = sum_system_time_covid_neg + finished_patient(i).queueReceptionTime + finished_patient(i).queueTreatTime + finished_patient(i).serviceTime;
        sum_inqueue_covid_neg = sum_inqueue_covid_neg + finished_patient(i).queueReceptionTime + finished_patient(i).queueTreatTime;
        num_covid_neg = num_covid_neg + 1;
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
