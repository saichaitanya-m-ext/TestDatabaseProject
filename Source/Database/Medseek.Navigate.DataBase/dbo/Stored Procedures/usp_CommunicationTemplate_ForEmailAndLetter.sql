
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [usp_CommunicationTemplate_ForEmailAndLetter]  
Description   : This procedure is used to get the list of values for the communication template
				with only ('Letter','Email')
Created By    : Rathnam
Created Date  : 26-Nov-2012
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_CommunicationTemplate_ForEmailAndLetter] 
( @i_AppUserId INT
)
AS
BEGIN TRY
      SET NOCOUNT ON   
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
      BEGIN
          RAISERROR ( N'Invalid Application User ID %d passed.' ,
           17 ,
           1 ,
           @i_AppUserId )
      END
-------------------------------------------------------- 
      SELECT
          CommunicationTemplateId,
		  TemplateName 
      FROM
          CommunicationTemplate cte
      INNER JOIN CommunicationType ct
          ON cte.CommunicationTypeId = ct.CommunicationTypeId    
     WHERE 
           ct.CommunicationType IN ('Letter','Email')
	   AND cte.StatusCode = 'A' 
	ORDER BY
		  TemplateName 	
		  
 
END TRY  
--------------------------------------------------------   
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CommunicationTemplate_ForEmailAndLetter] TO [FE_rohit.r-ext]
    AS [dbo];

