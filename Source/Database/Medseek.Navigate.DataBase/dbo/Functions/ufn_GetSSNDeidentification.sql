/*                  
------------------------------------------------------------------------------                  
Function Name : [dbo].[ufn_GetSSNDeidentification]             
Description   : This Function Returns Deidentified ssn  
Created By    : Rathnam              
Created Date  : 27-Dec-2011                 
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
------------------------------------------------------------------------------                  
*/      
CREATE FUNCTION [dbo].[ufn_GetSSNDeidentification]
(
  @v_SSN VARCHAR(10)
)
RETURNS  VARCHAR(10)
AS
BEGIN
	DECLARE @v_DeIdentifiedSSN VARCHAR(200)
	
		IF @v_SSN IS NULL OR @v_SSN = ''
		RETURN ''
			
		SELECT @v_DeIdentifiedSSN = CONVERT(VARCHAR,ISNULL(LEFT(100-SUBSTRING(@v_SSN,1,2),2),'')) +
									CONVERT(VARCHAR,ISNULL(LEFT(1000-SUBSTRING(@v_SSN,3,3),3),'')) +
									CONVERT(VARCHAR,ISNULL(LEFT(10-SUBSTRING(@v_SSN,6,1),1),'')) + 
									CONVERT(VARCHAR,ISNULL( LEFT(100-SUBSTRING(@v_SSN,7,2),2),'')) +
									CONVERT(VARCHAR,ISNULL( LEFT(10 - SUBSTRING(@v_SSN,9,2),1),''))
		
	RETURN @v_DeIdentifiedSSN
END	


