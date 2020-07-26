command = input('Enter input as a list\n');

N = 1e5;
num_of_patient = 0;

M= command(1);
lambda = command(2);
alpha = command(3);
mu = command(4);

rooms = [];

for i = 1:M
    
    doctor_mus = input('');
    r = room();
    
    for j= 1:length(doctor_mus)
        
        doc = doctor();
        doc.mu = doctor_mus(j);
        r.doctors = [r.doctors, doc];
        r.earliest_availableTime(j) = 0;
        
    end
    
    rooms = [rooms, r];
end

reception_covid_pos = [];
reception_covid_neg = [];

next_patient = create_patient(lambda, alpha);
next_reception_service = ceil(exprnd(mu));

time = min(next_patient.enterTime, next_reception_service);

while num_of_patient < N
    
    if next_patient.enterTime == time
        
        if next_patient.covidTest == 0
            reception_covid_neg = [reception_covid_neg, next_patient];
        else
            reception_covid_pos = [reception_covid_pos, next_patient];
        end
        next_patient = create_patient(lambda, alpha);
        
        next_patient.enterTime = next_patient.enterTime + time;
        
        num_of_patient = num_of_patient + 1;
    end

    if next_reception_service == time
        
        if isempty(reception_covid_pos) == 0

            patient = reception_covid_pos(1);
            
            while time - patient.enterTime > patient.boringTime && isempty(reception_covid_pos) == 0
                reception_covid_pos(1) = [];
                if isempty(reception_covid_pos) == 0
                    patient = reception_covid_pos(1);
                end
            end
            
            if isempty(reception_covid_pos) == 0
                idx = find_room(rooms, 1);
                reception_covid_pos(1).remainBoringTime = reception_covid_pos(1).boringTime - (time - patient.enterTime);
                reception_covid_pos(1).queueReceptionTime = time - patient.enterTime;
                rooms(idx).queue_covid_pos = [rooms(idx).queue_covid_pos, reception_covid_pos(1)];
                reception_covid_pos(1) = [];
            end
            
        elseif isempty(reception_covid_neg) == 0
            
            patient = reception_covid_neg(1);
            
            while time - patient.enterTime > patient.boringTime && isempty(reception_covid_neg) == 0
                reception_covid_neg(1) = [];
                if isempty(reception_covid_neg) == 0
                    patient = reception_covid_neg(1);
                end
            end
            
            if isempty(reception_covid_neg) == 0
                idx = find_room(rooms, 0);
                reception_covid_neg(1).remainBoringTime = reception_covid_neg(1).boringTime - (time - patient.enterTime);
                reception_covid_neg(1).queueReceptionTime = time - patient.enterTime;
                rooms(idx).queue_covid_neg = [rooms(idx).queue_covid_neg, reception_covid_neg(1)];
                reception_covid_neg(1) = [];
            end
            
        end
        next_reception_service = next_reception_service + ceil(exprnd(mu));
    end
    
    doctor_idx = zeros(length(rooms));
    room_times = ones(length(rooms)) * 1e7;
    
    min_time_access = 0;
    room_num = 0;
    
    for j = 1:length(rooms)
        
        if isempty(rooms(j).queue_covid_neg) == 0 || isempty(rooms(j).queue_covid_pos) == 0
            [val, arg] = min(rooms(j).earliest_availableTime);
            room_times(j) = val;
            doctor_idx(j) = arg;
        end
    end
    
    if min(room_times) < 1e7
        [min_time_access, room_num] = min(room_times);
    end

    if min_time_access == time
        
    end
    
    time = min([next_reception_service, next_patient.enterTime, min_time_access]);   
end