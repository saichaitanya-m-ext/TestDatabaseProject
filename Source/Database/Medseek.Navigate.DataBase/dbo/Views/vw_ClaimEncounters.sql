  
     
CREATE view [dbo].[vw_ClaimEncounters]    
       as    
       SELECT     
     ClaimInfo.PatientID UserId,    
     ClaimLine.BeginServiceDate EncounterDate,    
     CASE WHEN PlaceOfService.PlaceOfServiceName = 'Inpatient Hospital' THEN 1     
      ELSE NULL    
     END IsInpatient,    
     DATEDIFF(DAY, ClaimLine.BeginServiceDate,ClaimLine.EndServiceDate) + 1 StayDays,    
     ISNULL(PE.CodeGroupingID,1) EncounterTypeId,    
     ClaimLine.EndServiceDate DateDue,    
     ClaimLine.EndServiceDate ScheduledDate,    
     ClaimProvider.ProviderId CareTeamUserID,    
     --ClaimLine.RenderingFacilityOrganizationId OrganizationHospitalId,    
     CPT.ProviderTypeCodeID AS OrganizationHospitalId,   
     ClaimLine.ClaimLineID ,    
     ClaimProvider.ProviderId ProviderId ,    
     ClaimProvider.HASPCPENCOUNTERED IsEncounterwithPCP,    
     ClaimLine.ClaimInfoID ,  
     CodeSetCMSProviderSpecialty.ProviderSpecialtyCode AS SpecialityId  
    FROM     
     ClaimInfo    
    INNER JOIN ClaimLine    
     ON ClaimInfo.ClaimInfoId = ClaimLine.ClaimInfoID    
    INNER JOIN dbo.vw_PatientEncounter PE  
     ON PE.ClaimInfoId = ClaimLine.ClaimInfoID  
    INNER JOIN ClaimProvider  
     ON ClaimProvider.ClaimInfoID = PE.ClaimInfoId   
    LEFT JOIN ProviderSpecialty  
     ON ProviderSpecialty.ProviderID = ClaimProvider.ProviderID  
    LEFT JOIN Provider P   
     ON P.ProviderID = ProviderSpecialty.ProviderID  
    LEFT JOIN CodeSetProviderType CPT  
     ON P.ProviderTypeID = CPT.ProviderTypeCodeID   
    LEFT JOIN CodeSetCMSProviderSpecialty  
     ON CodeSetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID  
    LEFT JOIN CodeSetCMSPlaceOfService PlaceOfService     
     ON PlaceOfService.PlaceOfServiceCodeID = CLAIMLINE.PlaceOfServiceCodeID     
       
    WHERE (ClaimProvider.ProviderId IS NOT NULL  )  
       --OR ClaimLine.RenderingFacilityOrganizationId IS NOT NULL )    
  
  
  
  
  
