

/*                
------------------------------------------------------------------------------                
Function Name: [ufn_GetPatientNameByID]
Description   : This Function is used to get the patient name by id
Created By    : Rathnam
Created Date  : 19-March-2013
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
------------------------------------------------------------------------------                
*/ --select dbo.[ufn_GetUserNameByID] (8588944)

CREATE FUNCTION [dbo].[ufn_GetPatientNameByID]
     (
        @i_PatientId KEYID
     )
RETURNS VARCHAR(150)
AS
BEGIN
      DECLARE @v_UserName VARCHAR(150)
      SELECT @v_UserName = 
			COALESCE(ISNULL(Patient.LastName , '') + ' '   
				+ ISNULL(Patient.FirstName , '') + ' '   
				+ ISNULL(Patient.MiddleName , ''),'')  
	  FROM 
		  Patient
	  WHERE
	      PatientID = @i_PatientId
      RETURN @v_UserName
END


