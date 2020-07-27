function [mean, donePatients] = simulation(mus, N)

    M = length(mus(:, 1));
    
    lambda = 0.5;
    alpha = 3;
    mu = 1;
    
    num_of_patient = 0;

    rooms = [];

    for i = 1:M

        doctor_mus = mus(i,:);
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

    finished_patient = [];
    time = min(next_patient.enterTime, next_reception_service);

    min_time_access = 1e7;
    room_num = 1;

    sum_queue_reception = 0;
    sum_queue_rooms = zeros(1, length(rooms));

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

            recption_duration = ceil(exprnd(mu));

            if isempty(reception_covid_pos) == 0

                patient = reception_covid_pos(1);

                while time - patient.enterTime > patient.boringTime && isempty(reception_covid_pos) == 0

                    patient.queueReceptionTime = patient.boringTime;
                    finished_patient = [finished_patient, patient];
                    reception_covid_pos = reception_covid_pos(2:length(reception_covid_pos));
                    if isempty(reception_covid_pos) == 0
                        patient = reception_covid_pos(1);
                    end
                end

                if isempty(reception_covid_pos) == 0
                    idx = find_room(rooms, 1);
                    reception_covid_pos(1).remainBoringTime = reception_covid_pos(1).boringTime - (time - patient.enterTime);
                    reception_covid_pos(1).queueReceptionTime = time - patient.enterTime;
                    reception_covid_pos(1).receptionDuration = recption_duration;
                    rooms(idx).queue_covid_pos = [rooms(idx).queue_covid_pos, reception_covid_pos(1)];
                    reception_covid_pos = reception_covid_pos(2:length(reception_covid_pos));
                end

            elseif isempty(reception_covid_neg) == 0

                patient = reception_covid_neg(1);

                while time - patient.enterTime > patient.boringTime && isempty(reception_covid_neg) == 0

                    patient.queueReceptionTime = patient.boringTime;
                    finished_patient = [finished_patient, patient];
                    reception_covid_neg = reception_covid_neg(2:length(reception_covid_neg));
                    if isempty(reception_covid_neg) == 0
                        patient = reception_covid_neg(1);
                    end
                end

                if isempty(reception_covid_neg) == 0
                    idx = find_room(rooms, 0);
                    reception_covid_neg(1).remainBoringTime = reception_covid_neg(1).boringTime - (time - patient.enterTime);
                    reception_covid_neg(1).queueReceptionTime = time - patient.enterTime;
                    reception_covid_neg(1).receptionDuration = recption_duration;
                    rooms(idx).queue_covid_neg = [rooms(idx).queue_covid_neg, reception_covid_neg(1)];
                    reception_covid_neg = reception_covid_neg(2:length(reception_covid_neg));
                end

            end
            next_reception_service = next_reception_service + recption_duration;
        end

        if min_time_access == time

            if isempty(rooms(room_num).queue_covid_pos) == 0

                sick_guy = rooms(room_num).queue_covid_pos(1);

                while sick_guy.remainBoringTime < time - (sick_guy.enterTime + sick_guy.queueReceptionTime) && isempty(rooms(room_num).queue_covid_pos) == 0
                    sick_guy.queueTreatTime = sick_guy.remainBoringTime;
                    finished_patient = [finished_patient, sick_guy];
                    rooms(room_num).queue_covid_pos = rooms(room_num).queue_covid_pos(2:length(rooms(room_num).queue_covid_pos));

                    if isempty(rooms(room_num).queue_covid_pos) == 0
                        sick_guy = rooms(room_num).queue_covid_pos(1);
                    end
                end

                    sick_guy.serviceTime = ceil(exprnd(rooms(room_num).doctors(doctor_idx(room_num)).mu));
                    rooms(room_num).doctors(doctor_idx(room_num)).busy = true;
                    rooms(room_num).earliest_availableTime(doctor_idx(room_num)) = time + sick_guy.serviceTime;
                    sick_guy.queueTreatTime = time - (sick_guy.enterTime + sick_guy.queueReceptionTime);
                    rooms(room_num).queue_covid_pos = rooms(room_num).queue_covid_pos(2:length(rooms(room_num).queue_covid_pos));
                    sick_guy.done = true;
                    finished_patient = [finished_patient, sick_guy];


            elseif isempty(rooms(room_num).queue_covid_neg) == 0

                sick_guy = rooms(room_num).queue_covid_neg(1);

                while sick_guy.remainBoringTime < time - (sick_guy.enterTime + sick_guy.queueReceptionTime) && isempty(rooms(room_num).queue_covid_neg) == 0
                    sick_guy.queueTreatTime = sick_guy.remainBoringTime;
                    finished_patient = [finished_patient, sick_guy];
                    rooms(room_num).queue_covid_neg = rooms(room_num).queue_covid_neg(2:length(rooms(room_num).queue_covid_neg));

                    if isempty(rooms(room_num).queue_covid_neg) == 0
                        sick_guy = rooms(room_num).queue_covid_neg(1);
                    end
                end

                sick_guy.serviceTime = ceil(exprnd(rooms(room_num).doctors(doctor_idx(room_num)).mu));
                rooms(room_num).doctors(doctor_idx(room_num)).busy = true;
                rooms(room_num).earliest_availableTime(doctor_idx(room_num)) = time + sick_guy.serviceTime;
                sick_guy.queueTreatTime = time - (sick_guy.enterTime + sick_guy.queueReceptionTime);
                rooms(room_num).queue_covid_neg = rooms(room_num).queue_covid_neg(2:length(rooms(room_num).queue_covid_neg));
                sick_guy.done = true;
                finished_patient = [finished_patient, sick_guy];

            end
        end

        doctor_idx = zeros(length(rooms));
        room_times = ones(1, length(rooms)) * 1e7;
        min_time_access = 1e7;

        for j = 1:length(rooms)

            for k = 1:length(rooms(j).doctors)
                if rooms(j).doctors(k).busy == false
                   rooms(j).earliest_availableTime(k) = time;
                else
                    if time >= rooms(j).earliest_availableTime(k)
                        rooms(j).doctors(k).busy = false;
                        rooms(j).earliest_availableTime(k) = time;
                    end
                end
            end

            if isempty(rooms(j).queue_covid_neg) == 0 || isempty(rooms(j).queue_covid_pos) == 0
                [val, arg] = min(rooms(j).earliest_availableTime);
                room_times(j) = val;
                doctor_idx(j) = arg;
            end
        end

        if min(room_times) < 1e7
            [min_time_access, room_num] = min(room_times);     
        end
        pre_time = time;
        time = min([next_reception_service, next_patient.enterTime, min_time_access]);   

        sum_queue_reception = sum_queue_reception + (length(reception_covid_pos) + length(reception_covid_neg)) * (time - pre_time);

        for r = 1:length(rooms)
            sum_queue_rooms(r) = sum_queue_rooms(r) + ((length(rooms(r).queue_covid_pos) + length(rooms(r).queue_covid_neg)) * (time - pre_time));
        end
    end
    donePatients = finished_patient;
    mean = sum_queue_rooms / time;
end
