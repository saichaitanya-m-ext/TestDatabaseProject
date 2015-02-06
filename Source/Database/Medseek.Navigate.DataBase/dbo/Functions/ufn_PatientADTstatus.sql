
CREATE FUNCTION [dbo].[ufn_PatientADTstatus] 
(
    @i_PatientUserID INT ,
    @vc_ADTtype VARCHAR(1)
)
RETURNS VARCHAR(20)
AS
BEGIN

   	DECLARE @vc_ADTStatus VARCHAR(20)
	
	IF @vc_ADTtype = 'D'
		SELECT @vc_ADTStatus = 'Discharge'		
	ELSE
		BEGIN
			IF (SELECT ISNULL(pa.IsReadmit,0)
				FROM PatientADT pa
				WHERE COALESCE(EventDischargedate,MessageDischargedate,VisitDischargedate) IS NULL
				AND PA.PatientId = @i_PatientUserID ) = 1
				
				SELECT @vc_ADTStatus = 'ReAdmission'
			ELSE
				SELECT @vc_ADTStatus = 'Admit'	
		END		
		

    RETURN @vc_ADTStatus

END
