function patient = create_patient(lambda, alpha)

    patient = Patient();
    
    patient.covidTest = binornd(1, 0.1);
    patient.boringTime = alpha;
    patient.remainBoringTime = patient.boringTime;
    
    patient.queueReceptionTime = 0;
    patient.queueTreatTime = 0;
    patient.serviceTime = 0;
    patient.enterTime = ceil(exprnd(lambda));
    patient.receptionDuration = 0;
    
    patient.done = false;
end
