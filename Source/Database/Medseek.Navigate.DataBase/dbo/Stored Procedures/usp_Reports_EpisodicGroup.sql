
/*          
------------------------------------------------------------------------------------------------------------          
Procedure Name: usp_EpisodeGroupers_Select          
Description   : This procedrue is used to get the EpisodeGroupers,UsersEpisode Hirarichal population data     
Created By    : Rathnam  
Created Date  : 14-Nov-2011  
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION 
20-Mar-2013 P.V.P.Mohan modified UserEpisodicGroup to PatientEpisodicGroup
			and modified columns.         
------------------------------------------------------------------------------          
*/--[usp_Reports_EpisodicGroup]1,3,NULL,'D'
CREATE PROCEDURE [dbo].[usp_Reports_EpisodicGroup]
(
 @i_AppUserId KEYID ,
 @i_GrouperSystemId KEYID = NULL ,
 @i_GrouperDiseaseID KEYID = NULL ,
 @c_ByType CHAR(1) = 'D' -----> D-GrouperDisease P-Population  

)
AS

      BEGIN TRY
            SET NOCOUNT ON           
 -- Check if valid Application User ID is passed          
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.' ,
                     17 ,
                     1 ,
                     @i_AppUserId )
               END
            DECLARE
                    @i_StageCount INT ,
                    @i_SystemCount INT ,
                    @i_SystemPatientCount INT

            IF @i_GrouperSystemId IS NULL
            AND @i_GrouperDiseaseID IS NULL
               BEGIN

                     SELECT
                         @i_SystemPatientCount = COUNT(ueg.PatientID)
                     FROM
                         PatientEpisodicGroup ueg

                     SELECT
                         epg.Name SystemName ,
                         ISNULL(gde.Name , '') AS DiseaseName ,
                         epg.SystemName AS SystemNameWithPercent ,
                         epg.GrouperSystemId GrouperSystemId ,
                         CASE
                              WHEN gde.GrouperDiseaseId IS NOT NULL THEN 1
                              ELSE 0
                         END ChildID ,
                         dense_rank() OVER (
                         ORDER BY
                         epg.GrouperSystemId ) AS ParentID
                     FROM
                         GrouperDisease gde
                     RIGHT JOIN (
                                  SELECT
                                      gs.GrouperSystemId ,
                                      gs.Name ,
                                      COUNT(ueg.PatientID) PatientCount ,
                                      UPPER(gs.Name) + ' - ' + CONVERT(VARCHAR , CONVERT(DECIMAL(10,2) , COUNT(ueg.PatientID) * 100.00 / NULLIF(@i_SystemPatientCount , 0))) + '% (# ' + CONVERT(VARCHAR , COUNT(ueg.Patientid)) + ')' SystemName
                                  FROM
                                      GrouperSystem gs
                                  LEFT JOIN GrouperDisease gd WITH (NOLOCK)
                                      ON gs.GrouperSystemId = gd.GrouperSystemID
                                  LEFT JOIN GrouperStage Gst WITH (NOLOCK)
                                      ON gd.GrouperDiseaseId = Gst.GrouperDiseaseId
                                  LEFT JOIN PatientEpisodicGroup ueg WITH (NOLOCK)
                                      ON ueg.GrouperStageID = Gst.GrouperStageId
                                  WHERE
                                      gs.StatusCode = 'A'
                                      AND gd.StatusCode = 'A'
                                      AND ueg.StatusCode = 'A'
                                  GROUP BY
                                      gs.GrouperSystemId ,
                                      gs.Name
                                ) epg
                         ON epg.GrouperSystemId = gde.GrouperSystemID
                     WHERE
                         gde.StatusCode = 'A'

                     SELECT TOP 1
                         @i_GrouperSystemId = GrouperSystemId
                     FROM
                         GrouperSystem
                     WHERE
                         StatusCode = 'A'
                     SELECT
                         @i_GrouperDiseaseID = MAX(GrouperDiseaseId)
                     FROM
                         GrouperDisease
                     WHERE
                         GrouperSystemId = @i_GrouperSystemId
                         AND StatusCode = 'A'

               END

            IF @i_GrouperSystemId IS NOT NULL
               BEGIN

                     SELECT
                         @i_SystemCount = COUNT(ueg.PatientID)
                     FROM
                         GrouperSystem gs
                     INNER JOIN GrouperDisease gd WITH (NOLOCK)
                         ON gs.GrouperSystemId = gd.GrouperSystemID
                     INNER JOIN GrouperStage gst  WITH (NOLOCK)
                         ON gd.GrouperDiseaseId = gst.GrouperDiseaseID
                     INNER JOIN PatientEpisodicGroup ueg WITH (NOLOCK)
                         ON ueg.GrouperStageID = gst.GrouperStageId
                     WHERE
                         gs.GrouperSystemId = @i_GrouperSystemId
                     SELECT
                         gs.GrouperSystemId ,
                         gs.Name SystemName ,
                         gd.GrouperDiseaseId ,
                         gd.Name GrouperDiseaseName ,
                         COUNT(ueg.PatientID) PatientCount ,
                         ISNULL(CONVERT(DECIMAL(10,2) , ( COUNT(ueg.PatientID) * 100.00 ) / NULLIF(( @i_SystemCount ) , 0)) , 0) PatientPercentage ,
                         CONVERT(VARCHAR(10) , ISNULL(CONVERT(DECIMAL(10,2) , ( COUNT(ueg.Patientid) * 100.00 ) / NULLIF(( @i_SystemCount ) , 0)) , 0)) + ' % ( # ' + CONVERT(VARCHAR(10) , COUNT(ueg.Patientid)) + ' )' AS FormatedValue
                     FROM
                         GrouperSystem gs WITH (NOLOCK)
                     INNER JOIN GrouperDisease gd WITH (NOLOCK)
                         ON gs.GrouperSystemId = gd.GrouperSystemID
                     LEFT JOIN GrouperStage Gst WITH (NOLOCK)
                         ON gd.GrouperDiseaseId = gst.GrouperDiseaseID
                     LEFT JOIN PatientEpisodicGroup ueg WITH (NOLOCK)
                         ON ueg.GrouperStageID = Gst.GrouperStageId
                     WHERE
                         gs.GrouperSystemId = @i_GrouperSystemId
                         AND ueg.StatusCode = 'A'
                         AND gs.StatusCode = 'A'
                         AND gd.StatusCode = 'A'
                     GROUP BY
                         gs.GrouperSystemId ,
                         gs.Name ,
                         gd.GrouperDiseaseId ,
                         gd.Name


               END
            IF @i_GrouperDiseaseID IS NOT NULL
               BEGIN
                     IF @c_ByType = 'D'
                        BEGIN
                              SELECT
                                  @i_StageCount = COUNT(ueg.PatientID)
                              FROM
                                  GrouperSystem gs  WITH (NOLOCK)
                              INNER JOIN GrouperDisease gd WITH (NOLOCK)
                                  ON gs.GrouperSystemId = gd.GrouperSystemID
                              INNER JOIN GrouperStage gst WITH (NOLOCK)
                                  ON gd.GrouperDiseaseId = gst.GrouperDiseaseID
                              INNER JOIN PatientEpisodicGroup ueg WITH (NOLOCK)
                                  ON ueg.GrouperStageID = gst.GrouperStageId
                              WHERE
                                  gs.GrouperSystemId = @i_GrouperSystemId
                                  AND gd.GrouperDiseaseId = @i_GrouperDiseaseID
                                  AND ueg.StatusCode = 'A'
                                  AND gs.StatusCode = 'A'
                                  AND gd.StatusCode = 'A'
                        END
                     ELSE
                        BEGIN
                              IF @c_ByType = 'P'
                                 BEGIN
                                       SELECT
                                           @i_StageCount = COUNT(DISTINCT Patientid)
                                       FROM
                                           PatientEpisodicGroup
                                 END
                        END


                     SELECT
                         gs.GrouperSystemId ,
                         gs.Name SystemName ,
                         gd.GrouperDiseaseId ,
                         gd.Name GrouperDiseaseName ,
                         gd.DxCAT ,
                         gst.GrouperStageId ,
                         gst.StageID AS StatgeValue ,
                         gst.Description ,
                         COUNT(ueg.PatientID) PatientCount ,
                         CONVERT(DECIMAL(10,2) , COUNT(ueg.Patientid) * 100.00 / NULLIF(@i_StageCount , 0)) PateintsPercentage
                     FROM
                         GrouperSystem gs  WITH (NOLOCK)
                     INNER JOIN GrouperDisease gd WITH (NOLOCK)
                         ON gs.GrouperSystemId = gd.GrouperSystemID
                     LEFT JOIN GrouperStage gst  WITH (NOLOCK)
                         ON gd.GrouperDiseaseId = gst.GrouperDiseaseID
                     LEFT JOIN PatientEpisodicGroup ueg WITH (NOLOCK)
                         ON ueg.GrouperStageID = gst.GrouperStageId
                     WHERE
                         gs.GrouperSystemId = @i_GrouperSystemId
                         AND gd.GrouperDiseaseId = @i_GrouperDiseaseID
                         AND ueg.StatusCode = 'A'
                         AND gs.StatusCode = 'A'
                         AND gd.StatusCode = 'A'
                     GROUP BY
                         gs.GrouperSystemId ,
                         gs.Name ,
                         gd.GrouperDiseaseId ,
                         gd.Name ,
                         gd.DxCAT ,
                         gst.GrouperStageId ,
                         gst.StageID ,
                         gst.Description
               END
      END TRY  
------------------------------------------------------------------------------------------------------------  
      BEGIN CATCH          
    -- Handle exception          
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Reports_EpisodicGroup] TO [FE_rohit.r-ext]
    AS [dbo];

