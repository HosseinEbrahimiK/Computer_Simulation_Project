function patient = create_patient(lambda, alpha)

    patient = Patient();
    
    patient.covidTest = binornd(1, 0.1);
    patient.boringTime = ceil(exprnd(alpha));
    patient.remainBoringTime = patient.boringTime;
    
    patient.queueReceptionTime = 0;
    patient.queueTreatTime = 0;
    patient.enterTime = ceil(exprnd(lambda));
    
end
