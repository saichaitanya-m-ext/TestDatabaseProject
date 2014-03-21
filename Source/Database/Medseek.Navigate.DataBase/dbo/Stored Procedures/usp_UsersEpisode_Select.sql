/*    
--------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_UsersEpisode_Select]    
Description   : This procedure is used to select the details from UsersEpisode , EpisodeGroupers table     
     for a patientuserid.    
Created By    : Rathnam     
Created Date  : 14-Oct-2011    
---------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
20-Mar-2013 P.V.P.Mohan modified UserEpisodicGroup to PatientEpisodicGroup
			and modified columns.  
---------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UsersEpisode_Select]
(
 @i_AppUserId KEYID
,@i_PatientUserID KEYID
)
AS
BEGIN
      BEGIN TRY     
  
-- Check if valid Application User ID is passed    
            IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END

            SELECT
                ueg.PatientEpisodicGroupID AS UsersEpisodeID
               ,ueg.PatientID
               ,gd.GrouperDiseaseID
               ,gd.Name GrouperDiseaseName
               ,ueg.StartDate
               ,ueg.EndDate
               ,DATEDIFF(DD , ueg.StartDate , ueg.EndDate) AS Duration
               ,CONVERT(VARCHAR,gst.StageID) + ' : ' + gst.Description StageDescription
            FROM
                GrouperDisease gd WITH(NOLOCK)
            INNER JOIN GrouperStage gst WITH(NOLOCK)
				ON gd.GrouperDiseaseId = gst.GrouperDiseaseID	     
            INNER JOIN PatientEpisodicGroup ueg WITH(NOLOCK)
                ON ueg.GrouperStageID = gst.GrouperStageId
            WHERE
                ueg.PatientID = @i_PatientUserID
      END TRY    
----------------------------------------------------------------------------------------------------------    
      BEGIN CATCH    
-- Handle exception    
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UsersEpisode_Select] TO [FE_rohit.r-ext]
    AS [dbo];

