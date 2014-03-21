/*    
--------------------------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_CareProviderDashBoard_MyTasksHomePage_InsertUpdate]
Description   : This procedure is to be Insert the mytaskhomepage information For careteam
Created By    : Sivakrishna
Created Date  : 24-Jan-2012  
---------------------------------------------------------------------------------------------------------------    
Log History   :     
DD-Mon-YYYY  BY  DESCRIPTION 
---------------------------------------------------------------------------------------------------------------    
*/ 

CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyTasksHomePage_InsertUpdate]
       (
        @i_AppUserId KEYID
       ,@t_DueDateIds TTypeKeyId READONLY
       ,@t_PopulationIDs TTypeKeyId READONLY
       ,@t_TaskTypeIds TTypeKeyId READONLY
       ,@t_TypeIds tbSourceName READONLY
       ,@t_MeasureRanges tbSourceName READONLY
       ,@t_PcpIds TTypeKeyId READONLY
       ,@t_CareTeamMemberIds TTypeKeyId READONLY
       ,@t_DueDateType STATUSCODE = NULL
       ,@v_ReportType VARCHAR(1) = 'T'
       ,@v_CareTeamIds VARCHAR(500) = NULL
       )
AS
BEGIN TRY
      SET NOCOUNT ON    
-- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL )  OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
			
			
			
		IF NOT EXISTS(SELECT 1
						 FROM 
							MyTaskHomePage   
					  WHERE UserId = @i_AppUserId )
			BEGIN
				INSERT INTO MyTaskHomePage
					   (UserId,
						DueDateIds,
						PopulationIDs,
						MeasureRanges,
						TaskTypeIds,
						TypeIds,
						PcpIds,
						CareTeamMemberIds,
						CreatedByUserId,
						TaskStatus,
						ReportType,
						CareTeamIds
						)
				SELECT @i_AppUserId,
						STUFF ((SELECT '~' + CAST(tkeyId AS VARCHAR(10)) 
												FROM   
													@t_DueDateIds DD 
												FOR XML PATH ('')),1,1,''),
						STUFF ((SELECT '~' + CAST(tkeyId AS VARCHAR(10)) 
												FROM   
													@t_PopulationIDs DD 
												FOR XML PATH ('')),1,1,''),
						STUFF ((SELECT '~' +  SourceName  
												FROM   
													@t_MeasureRanges DD 
												FOR XML PATH ('')),1,1,''),						
						STUFF ((SELECT '~' + CAST(tkeyId AS VARCHAR(10)) 
												FROM   
													@t_TaskTypeIds DD 
												FOR XML PATH ('')),1,1,''),
						STUFF ((SELECT '~' + CAST(SourceName AS VARCHAR(5)) 
												FROM   
													@t_TypeIds DD 
												FOR XML PATH ('')),1,1,''),
						STUFF ((SELECT '~' + CAST(tkeyId AS VARCHAR(10)) 
												FROM   
													@t_PcpIds DD 
												FOR XML PATH ('')),1,1,''),
						STUFF ((SELECT '~' + CAST(tkeyId AS VARCHAR(10)) 
												FROM   
													@t_CareTeamMemberIds DD 
												FOR XML PATH ('')),1,1,''),
						@i_AppUserId,
						@t_DueDateType,
						@v_ReportType,
						@v_CareTeamIds
				
			END
			
		ELSE
			BEGIN
				UPDATE MyTaskHomePage
				   SET 
				   
						DueDateIds = STUFF ((SELECT '~' + CAST(tkeyId AS VARCHAR(10)) 
												FROM   
													@t_DueDateIds DD 
												FOR XML PATH ('')),1,1,''),
						PopulationIDs = STUFF ((SELECT '~' + CAST(tkeyId AS VARCHAR(10)) 
												FROM   
													@t_PopulationIDs DD 
												FOR XML PATH ('')),1,1,''),
						MeasureRanges = STUFF ((SELECT '~' +  SourceName  
												FROM   
													@t_MeasureRanges DD 
												FOR XML PATH ('')),1,1,''),						
						TaskTypeIds= STUFF ((SELECT '~' + CAST(tkeyId AS VARCHAR(10)) 
												FROM   
													@t_TaskTypeIds DD 
												FOR XML PATH ('')),1,1,''),
						TypeIds = STUFF ((SELECT '~' + CAST(SourceName AS VARCHAR(10)) 
												FROM   
													@t_TypeIds DD 
												FOR XML PATH ('')),1,1,''),
						PcpIds = STUFF ((SELECT '~' + CAST(tkeyId AS VARCHAR(10)) 
												FROM   
													@t_PcpIds DD 
												FOR XML PATH ('')),1,1,''),
						CareTeamMemberIds = STUFF ((SELECT '~' + CAST(tkeyId AS VARCHAR(5)) 
												FROM   
													@t_CareTeamMemberIds DD 
												FOR XML PATH ('')),1,1,''),
					   UpdatedByUserId = @i_AppUserId , TaskStatus = @t_DueDateType, ReportType = @v_ReportType,
					   CareTeamIds = @v_CareTeamIds, UpdatedDate = GETDATE()
				WHERE
				UserId = @i_AppUserId
			END
				
END TRY	
BEGIN CATCH    
----------------------------------------------------------------------------------------------------------   
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyTasksHomePage_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

