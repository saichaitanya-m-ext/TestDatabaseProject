/*        
------------------------------------------------------------------------------        
Procedure Name: usp_UserInsurance_Insert        
Description   : This procedure is used to insert record into UserInsurance table    
Created By    : Aditya        
Created Date  : 25-Mar-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
27-Oct-2010 Rathnam Added exist cluase        
11-Apr-2012 NagaBabu Added @i_EmployerGroupID Parameter and deleted @i_InsuranceGroupId,@i_EmployerGroupNumber,    
      @vc_EmployerGroupName     
------------------------------------------------------------------------------        
*/     
CREATE PROCEDURE [dbo].[usp_UserInsurance_Insert]    
(    
  @i_AppUserId KEYID    
 ,@i_InsuranceGroupPlanId KEYID    
 --,@i_InsuranceGroupId KEYID    
 ,@i_UserId KEYID    
 ,@vc_StatusCode STATUSCODE    
 ,@i_IsPrimary ISINDICATOR    
 ,@i_PCPUserId KEYID    
 ,@i_PCPExternalProviderId KEYID    
 ,@vc_PCPSystem SOURCENAME    
 --,@i_EmployerGroupNumber CODE    
 --,@vc_EmployerGroupName SOURCENAME    
 ,@vc_GroupNumber VARCHAR(15)  
 ,@vc_PolicyNumber varchar(15)
 ,@vc_SuperGroupCategory SOURCENAME    
 ,@i_PharmacyBenefit ISINDICATOR    
 ,@i_MedicareSupplement ISINDICATOR    
 ,@o_UserInsuranceId KEYID OUTPUT    
 ,@dt_StartDate DATETIME    
 ,@dt_EndDate DATETIME    
 ,@i_EmployerGroupID KeyId     
)    
AS    
BEGIN TRY    
      SET NOCOUNT ON    
      DECLARE @l_numberOfRecordsInserted INT       
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )    
      OR ( @i_AppUserId <= 0 )    
         BEGIN    
               RAISERROR ( N'Invalid Application User ID %d passed.'    
               ,17    
               ,1    
               ,@i_AppUserId )    
         END    
      IF EXISTS ( SELECT    
                      1    
                  FROM    
                      PatientInsurance    
                  WHERE    
                      PatientID = @i_UserId     
                )    
      AND @i_IsPrimary = 1    
         BEGIN    
               RAISERROR ( N'Already having Primary Value for UserID %d.'    
               ,9    
               ,1    
               ,@i_AppUserId )    
         END    
      ELSE    
         BEGIN    
               INSERT INTO    
                   PatientInsurance    
                   (    
                    InsuranceGroupPlanId    
                   ,PatientID    
                   ,StatusCode    
                   ,PolicyNumber
				   ,GroupNumber    
                   ,SuperGroupCategory    
                   ,CreatedByUserId    
                   ,EmployerGroupID    
                   )    
               VALUES    
                   (    
                    @i_InsuranceGroupPlanId    
                   ,@i_UserId    
                   ,@vc_StatusCode    
                   ,@vc_GroupNumber  
                   ,@vc_PolicyNumber 
                   ,@vc_SuperGroupCategory    
                   ,@i_AppUserId    
                   ,@i_EmployerGroupID    
                   )    
    
               SELECT    
                   @l_numberOfRecordsInserted = @@ROWCOUNT    
                  ,@o_UserInsuranceId = SCOPE_IDENTITY()    
    
               IF @l_numberOfRecordsInserted <> 1    
                  BEGIN    
                        RAISERROR ( N'Invalid row count %d in insert document Type'    
                        ,17    
                        ,1    
                        ,@l_numberOfRecordsInserted )    
                  END    
    
               RETURN 0    
         END    
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
    ON OBJECT::[dbo].[usp_UserInsurance_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

