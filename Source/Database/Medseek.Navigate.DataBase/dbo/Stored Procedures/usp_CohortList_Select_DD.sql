
/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_CohortList_Select_DD]  1
Description   : This procedure is used to display CohortList drop down  
Created By    : NagaBabu  
Created Date  : 27-May-2010  
----------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY     DESCRIPTION  
07-July-10 NagaBabu Added StatusCode perameter,StatusCode field 
01-April-2011 NagaBabu Added @v_MassCommunication Parameter and added exists condition in where clause
03-APR-2013 Mohan Modified PopulationDefinitionUsers to PopulationDefinitionPatients Tables and
            added Definition Type = 'P'.      
----------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_CohortList_Select_DD]
(
  @i_AppUserId KEYID ,
  @v_StatusCode StatusCode = NULL ,
  @v_MassCommunication VARCHAR(1) = NULL
 -- @b_IsPopulationReport ISINDICATOR = 0 
)
AS
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

      SELECT
          PopulationDefinitionId ,
          PopulationDefinitionName ,
          CASE StatusCode
            WHEN 'A' THEN 'Active'
			WHEN 'I' THEN 'InActive'
			ELSE ''
		  END AS StatusDescription
      FROM
          PopulationDefinition  WITH (NOLOCK) 
      WHERE
          ( StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )
      AND (@v_MassCommunication IS NULL OR ( EXISTS ( SELECT 
														   1 
													   FROM 
														   PopulationDefinitionPatients 
													   WHERE 
														   PopulationDefinitionPatients.PopulationDefinitionId = PopulationDefinition.PopulationDefinitionId 
													   AND PopulationDefinitionPatients.statuscode = 'A'
													  ) 
										   )
		   )
	  -- AND ((@b_IsPopulationReport  =1 AND IsForPopulationReport = 1) OR @b_IsPopulationReport  = 0)
	  AND DefinitionType = 'P'
      ORDER BY
          PopulationDefinitionName
END TRY
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CohortList_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

