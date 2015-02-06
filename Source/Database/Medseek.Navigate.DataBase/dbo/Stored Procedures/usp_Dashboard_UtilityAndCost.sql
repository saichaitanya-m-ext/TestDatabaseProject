
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Dashboard_UtilityAndCost  2,2  
Description   : This procedure is used to get the details from UserInsurance table   
Created By    : Rathnam    
Created Date  : 11-Feb-2013    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
21-MAy-2013 P.V.P.Mohan Modified join Statement LkUpInsuranceBenefitType from CodeSetInsuranceType Table.
------------------------------------------------------------------------------    
*/  
-- [usp_Dashboard_UtilityAndCost] 23,23,'A'
CREATE PROCEDURE [dbo].[usp_Dashboard_UtilityAndCost] 
(  
 @i_AppUserId KEYID ,  
 @i_UserId KEYID ,
 @v_StatusCode StatusCode = NULL
   
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
  
	  DECLARE @i_Top INT = 5
      SELECT DISTINCT TOP (@i_Top)
          ui.PatientInsuranceID AS UserInsuranceId ,  
          igp.PlanName ,  
          ig.GroupName ,
          ibt.BenefitTypeName PlanType,  
		  CONVERT(VARCHAR,uibt.DateOfEligibility,101) AS StartDate,
		  CONVERT(VARCHAR,uibt.CoverageEndsDate,101) AS EndDate
      FROM    
          PatientInsurance ui   WITH(NOLOCK)
      INNER JOIN PatientInsuranceBenefit uibt WITH(NOLOCK)
          ON uibt.PatientInsuranceID = ui.PatientInsuranceID 
      INNER JOIN LkUpInsuranceBenefitType ibt WITH(NOLOCK)
          ON ibt.InsuranceBenefitTypeID  = uibt.InsuranceBenefitTypeID       
      INNER JOIN InsuranceGroupPlan igp    WITH(NOLOCK)
          ON igp.InsuranceGroupPlanId = ui.InsuranceGroupPlanId       
      INNER JOIN InsuranceGroup ig    WITH(NOLOCK) 
          ON ig.InsuranceGroupID = igp.InsuranceGroupId
      WHERE    
          ( ui.PatientID = @i_UserId OR @i_UserId IS NULL )  
          AND ( @v_StatusCode IS NULL OR ui.StatusCode = @v_StatusCode )
      Order by StartDate desc    
       
       EXEC usp_DashBoard_PatientUtilityAndCost @i_AppUserId,@i_UserId
     
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
    ON OBJECT::[dbo].[usp_Dashboard_UtilityAndCost] TO [FE_rohit.r-ext]
    AS [dbo];

