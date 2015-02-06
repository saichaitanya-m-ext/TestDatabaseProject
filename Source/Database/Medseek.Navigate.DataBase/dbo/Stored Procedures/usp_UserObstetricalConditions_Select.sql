
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserObstetricalConditions_Select      
Description   : This procedure is used to get the list of all the detais from the     
    UserObstetricalConditions table based on ObstetricalConditionsID 
Created By    : Udaykumar      
Created Date  : 6-July-2011     
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
12-07-2012   Sivakrishna added SourceName column to 
			 the Existing Select statement.   
17-07-202   Sivakrishna added DataSourceId column to  existing the Select statement. 
20-Mar-2013 P.V.P.Mohan modified UserObstetricalConditions  columns.
------------------------------------------------------------------------------      
*/   
CREATE PROCEDURE [dbo].[usp_UserObstetricalConditions_Select]  
(    
 @i_AppUserId KeyId,   
 @i_UserID KeyId,   
 @i_UserObstetricalConditionsID KeyId = NULL,  
 @v_StatusCode StatusCode = NULL    
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
    
 SELECT    
  UserObstetricalConditions.UserObstetricalConditionsID,    
  UserObstetricalConditions.ObstetricalConditionsID,    
  UserObstetricalConditions.PatientID UserID,  
  UserObstetricalConditions.StartDate,    
  UserObstetricalConditions.EndDate,    
  UserObstetricalConditions.Comments,    
  ObstetricalConditions.ObstetricalName AS ObstetricalConditionsType,    
  UserObstetricalConditions.CreatedByUserId,  
  UserObstetricalConditions.CreatedDate,
  UserObstetricalConditions.LastModifiedByUserId,
  UserObstetricalConditions.LastModifiedDate ,
  
   CASE UserObstetricalConditions.StatusCode     
     WHEN 'A' THEN 'Active'    
     WHEN 'I' THEN 'InActive'    
     ELSE ''    
  END AS StatusCode    ,
  UserObstetricalConditions.DataSourceId,
    CodeSetDataSource.SourceName
   FROM UserObstetricalConditions    WITH(NOLOCK)
     INNER JOIN ObstetricalConditions   WITH(NOLOCK)  
    ON ObstetricalConditions.ObstetricalConditionsID = UserObstetricalConditions.ObstetricalConditionsID    
    LEFT JOIN CodeSetDataSource WITH(NOLOCK)
       ON CodeSetDataSource.DataSourceId = UserObstetricalConditions.DataSourceId
  WHERE ( UserObstetricalConditions.PatientID = @i_UserID )    
  AND ( UserObstetricalConditions.UserObstetricalConditionsID = @i_UserObstetricalConditionsID OR @i_UserObstetricalConditionsID IS NULL )    
        AND ( UserObstetricalConditions.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )    
END TRY      
--------------------------------------------------------       
BEGIN CATCH      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH 

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserObstetricalConditions_Select] TO [FE_rohit.r-ext]
    AS [dbo];

