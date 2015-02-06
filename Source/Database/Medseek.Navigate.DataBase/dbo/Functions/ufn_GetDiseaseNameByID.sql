  
  
  
/*                  
------------------------------------------------------------------------------                  
Function Name: [ufn_GetDiseaseNameByID]  
Description   : This Function is used to get DiseaseName for a particular ID.  
Created By    : Rathnam  
Created Date  : 01-Dec-2010  
------------------------------------------------------------------------------  
Log History :  
DD-MM-YYYY     BY      DESCRIPTION  
------------------------------------------------------------------------------                  
*/  
  
CREATE FUNCTION [dbo].[ufn_GetDiseaseNameByID]  
     (  
        @i_ConditionID KEYID  
     )  
RETURNS VARCHAR(150)  
AS  
BEGIN  
      DECLARE @v_DiseaseName VARCHAR(150)  
      SELECT @v_DiseaseName =   
    ConditionName  
   FROM   
       Condition   
   WHERE  
       ConditionID = @i_ConditionID 
      RETURN @v_DiseaseName  
END  
  
  
