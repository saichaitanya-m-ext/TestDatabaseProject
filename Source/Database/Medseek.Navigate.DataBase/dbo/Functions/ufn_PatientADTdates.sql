
CREATE FUNCTION [dbo].[ufn_PatientADTdates] 
(
    @i_PatientUserID INT ,
    @vc_Request VARCHAR(50) ,
    @i_ProgramId INT
)
RETURNS DATETIME
AS
BEGIN

   	DECLARE @vc_Result VARCHAR(50) ,
			@i_MaxADTid INT ,
			@i_MinADTid INT ,
			@dt_MaxAdmitDate DATETIME ,
			@dt_MinAdmitDate DATETIME ,
			@dt_MaxDischargeDate DATETIME 

	IF (SELECT ISNULL(pd.IsADT,0)
		FROM Program p
		INNER JOIN PopulationDefinition pd
			ON P.PopulationDefinitionID = PD.PopulationDefinitionID
		WHERE P.ProgramId = @i_ProgramId) = 1
		
		BEGIN
			SELECT @dt_MaxAdmitDate	= MAX(COALESCE(EventAdmitdate,MessageAdmitdate,VisitAdmitdate)) 
									  FROM PatientADT pa1	
									  WHERE PatientId = @i_PatientUserID	
									  
			SELECT @dt_MinAdmitDate	= MAX(COALESCE(EventAdmitdate,MessageAdmitdate,VisitAdmitdate)) 
									  FROM PatientADT pa1	
									  WHERE PatientId = @i_PatientUserID
									  AND COALESCE(EventAdmitdate,MessageAdmitdate,VisitAdmitdate) < @dt_MaxAdmitDate								  	
					
			SELECT @i_MaxADTid	= pa.PatientADTId  
								  FROM PatientADT pa
								  WHERE pa.PatientId = @i_PatientUserID	
								  AND COALESCE(pa.EventAdmitdate,pa.MessageAdmitdate,pa.VisitAdmitdate) = @dt_MaxAdmitDate
			
			SELECT @i_MinADTid	= pa.PatientADTId  
								  FROM PatientADT pa
								  WHERE pa.PatientId = @i_PatientUserID	
								  AND COALESCE(pa.EventAdmitdate,pa.MessageAdmitdate,pa.VisitAdmitdate) = @dt_MinAdmitDate
			
			
			

			IF @vc_Request = 'AdmitDate'	
			BEGIN
				SELECT @vc_Result = COALESCE(EventAdmitdate,MessageAdmitdate,VisitAdmitdate)
				FROM PatientADT pa
				WHERE PA.PatientADTId = @i_MaxADTid	
				
				GOTO EndLine
			END	
			IF @vc_Request = 'Dischargedate'
			BEGIN
				SELECT @vc_Request = COALESCE(EventDischargedate,MessageDischargedate,VisitDischargedate)
											FROM PatientADT pa
											WHERE pa.PatientId = @i_PatientUserID	
											AND PA.PatientADTId = @i_MaxADTid
					
				GOTO EndLine
			END	

			IF @vc_Request = 'LastDischargedate'	
			BEGIN
				SELECT @vc_Request = COALESCE(EventDischargedate,MessageDischargedate,VisitDischargedate)
											FROM PatientADT pa
											WHERE pa.PatientId = @i_PatientUserID	
											AND PA.PatientADTId = @i_MinADTid
							
				GOTO EndLine
			END	
		END	
	ELSE
		BEGIN
			SELECT @vc_Request = NULL
			
			GOTO EndLine
		END	
		
	EndLine:
	BEGIN
		RETURN @vc_Result
	END 
	
END
