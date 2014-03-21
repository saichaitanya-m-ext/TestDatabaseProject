/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Immunizations_Select    
Description   : This procedure is used to get the list of all Immunizations  
    for a particular profesisonal Type or get lsit of all the types  
Created By    : Pramod    
Created Date  : 1-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
01-Sep-2010 NagaBabu Modified LastModifiedDate as it shows CreatedDate value when LastModifiedDate is NULL 
13-Oct-2010 NagaBabu Added Name to order by clause 
07-Apr-2011 NagaBabu Added Route Field in Select statement   
25-Apr-2011 NagaBabu Modified LastModifiedDate field by showing as it as from the table 
11-Aug-2011 NagaBabu Added join statement with CodeSetProcedure table for getting ProcedureName,ProcedureId fields 
28-Sep-2011 Rathnam added DependentImmunizationID,DaysBetweenImmunization,Strength columns to the select statement
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_Immunizations_Select]
(  
	@i_AppUserId INT,  
	@i_ImmunizationID INT = NULL,
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
			Immunizations.ImmunizationID  
			,Immunizations.Name  
			,Immunizations.Description  
			,Immunizations.SortOrder
			,Immunizations.CreatedByUserId  
			,Immunizations.CreatedDate  
			,Immunizations.LastModifiedByUserId  
			,Immunizations.LastModifiedDate
			,CASE Immunizations.StatusCode   
				WHEN 'A' THEN 'Active'  
				WHEN 'I' THEN 'InActive'  
				ELSE ''  
			 END AS StatusDescription
			,Route
			,Immunizations.ProcedureID
			,(CAST(CodeSetProcedure.ProcedureCode AS VARCHAR) + ' - ' + CodeSetProcedure.ProcedureName) AS ProcedureName
			,DependentImmunizationID
			,(SELECT Name FROM Immunizations ims WHERE ims.ImmunizationID = Immunizations.DependentImmunizationID) AS DependentImmunizationName
			,DaysBetweenImmunization
			,Strength
		FROM 
			Immunizations  WITH (NOLOCK) 
		LEFT OUTER JOIN CodeSetProcedure  WITH (NOLOCK) 
			ON Immunizations.ProcedureID = CodeSetProcedure.ProcedureCodeID	  
	    WHERE 
			( ImmunizationID = @i_ImmunizationID   
               OR @i_ImmunizationID IS NULL  
            )  
        AND ( @v_StatusCode IS NULL OR Immunizations.StatusCode = @v_StatusCode )             
        ORDER BY SortOrder,Name
  
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
    ON OBJECT::[dbo].[usp_Immunizations_Select] TO [FE_rohit.r-ext]
    AS [dbo];

