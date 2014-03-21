CREATE FUNCTION [dbo].[ufn_PatientDashBoardADTstatus] 
(
    @i_PatientUserID INT
)
RETURNS VARCHAR(20)
AS
BEGIN

       DECLARE @vc_ADTStatus VARCHAR(20) ,
                     @dt_MaxAdtDate DATETIME ,
                     @dt_MaxDisDate DATETIME     
       
       
       IF EXISTS (SELECT DISTINCT 1
				  FROM Task t
				  INNER JOIN Program p
				  ON T.ProgramID = P.ProgramId
				  INNER JOIN PopulationDefinition pd
				  ON PD.PopulationDefinitionID = P.PopulationDefinitionID
				  WHERE T.PatientId = @i_PatientUserID 
				  AND IsADT = 1)
		   BEGIN			   	
			   IF (SELECT COUNT(1) FROM PatientADT WHERE PatientId = @i_PatientUserID) > 1 
					  BEGIN  
							 SET @dt_MaxAdtDate = (SELECT MAX(COALESCE(EventAdmitdate,MessageAdmitdate,VisitAdmitdate))
																 FROM PatientADT    
																 WHERE PatientId = @i_PatientUserID)
		                     
							 IF (SELECT COALESCE(EventDischargedate,MessageDischargedate,VisitDischargedate) 
								   FROM PatientADT
								   WHERE PatientId = @i_PatientUserID
								   AND COALESCE(EventAdmitdate,MessageAdmitdate,VisitAdmitdate) = @dt_MaxAdtDate ) IS NOT NULL 

								   SELECT @vc_ADTStatus = 'Discharge'                            
		                     
							 ELSE 
								   BEGIN
										  IF (SELECT ISNULL(IsReadmit,0) AS IsReadmit
												 FROM PatientADT
												 WHERE PatientId = @i_PatientUserID
												 AND COALESCE(EventAdmitdate,MessageAdmitdate,VisitAdmitdate) = @dt_MaxAdtDate ) = 1
		                                         
												 SELECT @vc_ADTStatus = 'ReAdmission'  
										  ELSE 
											   SELECT @vc_ADTStatus = 'Admit'  		    
								   END
					  END
			   ELSE		
				   BEGIN
					 SELECT @dt_MaxDisDate =  COALESCE(EventDischargedate,MessageDischargedate,VisitDischargedate)
															  FROM PatientADT
															  WHERE PatientId = @i_PatientUserID

						   IF @dt_MaxDisDate IS NOT NULL
								  SET @vc_ADTStatus = 'Discharge'   
						   ELSE 
								  SET @vc_ADTStatus = 'Admit' 
				   END
			    
		  END   
      ELSE      
		  SET @vc_ADTStatus =  NULL
    RETURN @vc_ADTStatus

END
