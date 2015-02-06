
CREATE FUNCTION [dbo].[ufn_PatientADTMYPatient] 
(
    @i_PatientUserID INT ,
    @vc_Request VARCHAR(50) 
)
RETURNS VARCHAR(50)
AS
BEGIN


   	DECLARE @vc_Result VARCHAR(50) ,
			@i_PreADTid INT ,
			@dt_MaxAdmitDate DATETIME ,
			@dt_MinAdmitDate DATETIME ,
			@dt_MaxDischargeDate DATETIME ,
			@dt_MinDischargeDate DATETIME 
	
	--IF (SELECT ISNULL(pd.IsADT,0)
	--	FROM Program p
	--	INNER JOIN PopulationDefinition pd
	--		ON P.PopulationDefinitionID = PD.PopulationDefinitionID
	--	WHERE P.ProgramId = @i_ProgramId) = 1
		
		--BEGIN
		--IF @i_PatientADTid IS NOT NULL
			BEGIN
				SELECT @dt_MaxAdmitDate	= MAX(COALESCE(EventAdmitdate,MessageAdmitdate,VisitAdmitdate))
										  FROM PatientADT pa1	
										  WHERE PatientId = @i_PatientUserID	
										  
				SELECT @dt_MinAdmitDate	= MAX(COALESCE(EventAdmitdate,MessageAdmitdate,VisitAdmitdate)) 
										  FROM PatientADT pa1	
										  WHERE PatientId = @i_PatientUserID
										  AND COALESCE(EventAdmitdate,MessageAdmitdate,VisitAdmitdate) < @dt_MaxAdmitDate								  	
						
				SELECT @i_PreADTid	= pa.PatientADTId  
									  FROM PatientADT pa
									  WHERE pa.PatientId = @i_PatientUserID	
									  AND COALESCE(pa.EventAdmitdate,pa.MessageAdmitdate,pa.VisitAdmitdate) = @dt_MinAdmitDate
				
				
				
				SELECT @dt_MaxDischargeDate = MAX(COALESCE(EventDischargedate,MessageDischargedate,VisitDischargedate))
												FROM PatientADT pa
												WHERE PatientId = @i_PatientUserID	
												
				SELECT @dt_MinDischargeDate = COALESCE(EventDischargedate,MessageDischargedate,VisitDischargedate)
												FROM PatientADT pa
												WHERE PatientADTId = @i_PreADTid													
												
				

				IF @vc_Request = 'Facility'	
				BEGIN
					SELECT @vc_Result = p.OrganizationName 
					FROM Provider p
					INNER JOIN PatientADT pa
						ON pa.FacilityId = p.ProviderID
					WHERE PA.PatientId = @i_PatientUSERid	
					AND eventAdmitdate = (SELECT MAX(EVENTADMITDATE) FROM PatientADT WHERE PatientID = @i_PatientUSERid)
					
					--SELECT * FROM PROVIDER P
					-- INNER JOIN PATIENTPROVIDER PP
					--   ON P.Providerid = PP.PROVIDERID
					
					--SELECT * FROM PATIENTADT ORDER BY PATIENTID
					--GOTO EndLine
				END	
				IF @vc_Request = 'LastFacility'
				BEGIN
					SELECT @vc_Result = p.OrganizationName 
					FROM Provider p
					INNER JOIN PatientADT pa
						ON pa.FacilityId = p.ProviderID
					WHERE PA.PatientADTId = @i_PreADTid	
						
					--GOTO EndLine
				END	

				IF @vc_Request = 'DischargedTo'	
				BEGIN
					SELECT @vc_Result = CASE WHEN DischargeTo = 'HME' THEN 'Home'
											 WHEN DischargeTo = 'SNF' THEN 'SNF'
											 WHEN DischargeTo = 'HHH' THEN 'Home Health'
										END	 
					FROM PatientADT pa
					WHERE PA.PatientId = @i_PatientUserid	
					AND EVENTDISCHARGEDATE = (SELECT MAX(EVENTDISCHARGEDATE) FROM PatientADT WHERE PatientID = @i_PatientUserid)
								
					
				END	

				IF @vc_Request = 'NoOfDays'	
				BEGIN
					SELECT @vc_Result = CAST(DATEDIFF(DAY,@dt_MinDischargeDate,@dt_MaxAdmitDate) AS VARCHAR(3))	
							
					--GOTO EndLine
				END	

				IF @vc_Request = 'InPatientDays'	
				BEGIN
					SELECT @vc_Result = CAST(DATEDIFF(DAY,@dt_MaxAdmitDate,@dt_MaxDischargeDate) AS VARCHAR(50))	
											  
						
					--GOTO EndLine
				END	
				
				IF @vc_Request = 'AdmitDate'	
				BEGIN
					SELECT @vc_Result = CONVERT(VARCHAR(19),@dt_MaxAdmitDate,120)
					
					--GOTO EndLine
				END	
				IF @vc_Request = 'Dischargedate'
				BEGIN
					SELECT @vc_Result = CONVERT(VARCHAR(19),@dt_MaxDischargeDate,120)
					--GOTO EndLine
				END	

				IF @vc_Request = 'LastDischargedate'	
				BEGIN
					SELECT @vc_Result = CONVERT(VARCHAR(19),@dt_MinDischargeDate,120)
								
					--GOTO EndLine
				END
			END		
		--ELSE
		--	BEGIN
		--		SELECT @vc_Result = NULL
		--	END
		
		RETURN @vc_Result		
	
END

