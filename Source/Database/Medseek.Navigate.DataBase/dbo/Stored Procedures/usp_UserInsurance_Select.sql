
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserInsurance_Select    
Description   : This procedure is used to get the details from UserInsurance table   
Created By    : Aditya    
Created Date  : 25-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
26-Oct-2010 Rathnam modified casestatement  using PCPUserId instead of using userid.  
20-Jan-2012 Rathnam Removed the InsuranceGroupPlanID from UserInsurance
11-Apr-2012 NagaBabu Added EmployerGroup with Join and modified fields EmployerGroupNumber,EmployerGroupName
11-Apr-2012 Gurumoorthy.V added this statement(EmployerGroup.GroupNumber + ' - ' + EmployerGroup.GroupName AS EmployerGroupName) 
			AND UserInsurance.EmployerGroupID
28-Jan-2013	Praveen Takasi Calling usp_DashBoard_PatientUtilityAndCost proc to make it wrapper sp.
26-Mar-2013	P.V.P.Mohan modified UserInsurance to PatientInsurance
------------------------------------------------------------------------------    
*/ 
-- [usp_UserInsurance_Select] 64
CREATE PROCEDURE [dbo].[usp_UserInsurance_Select] 
(  
 @i_AppUserId KEYID ,  
 @i_UserId KEYID = NULL,
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
  
      SELECT  
          PatientInsurance.PatientInsuranceID UserInsuranceId ,  
          PatientInsurance.InsuranceGroupPlanId ,  
          InsuranceGroupPlan.PlanName ,  
          InsuranceGroup.InsuranceGroupId ,  
          InsuranceGroup.GroupName ,  
          PatientInsurance.PatientID UserId ,  
          '' IsPrimary ,  
          '' PCPUserId ,  
          --CASE  
          --     WHEN UserInsurance.PCPUserId IS NOT NULL   
          --          THEN Users.FirstName + ' ' + Users.LastName  
          --     WHEN UserInsurance.PCPExternalProviderId IS NOT NULL   
          --          THEN ExternalCareProvider.FirstName + ' ' + ExternalCareProvider.LastName  
          --END AS 
          
          '' PrimaryCareProvider ,  
          '' PCPExternalProviderId ,  
          '' PCPSystem ,  
          EmployerGroup.GroupNumber + ' - ' + EmployerGroup.GroupName AS EmployerGroupName , 
          PatientInsurance.EmployerGroupID,
          PatientInsurance.PolicyNumber +''+PatientInsurance.GroupNumber GroupOrPolicyNumber ,  
          PatientInsurance.SuperGroupCategory ,  
          '' PharmacyBenefit ,  
          '' MedicareSupplement ,  
          PatientInsurance.CreatedByUserId ,  
          PatientInsurance.CreatedDate ,  
          PatientInsurance.LastModifiedByUserId ,  
          PatientInsurance.LastModifiedDate ,  
          CASE PatientInsurance.StatusCode  
            WHEN 'A' THEN 'Active'  
            WHEN 'I' THEN 'InActive'  
            ELSE ''  
          END AS StatusDescription,
          ''  StartDate,
          ''  EndDate
		  --CONVERT(VARCHAR,UserInsurance.StartDate,101) AS StartDate,
		  --CONVERT(VARCHAR,UserInsurance.EndDate,101) AS EndDate
      FROM    
          PatientInsurance    WITH(NOLOCK)
      INNER JOIN InsuranceGroupPlan     WITH(NOLOCK)
          ON InsuranceGroupPlan.InsuranceGroupPlanId = PatientInsurance.InsuranceGroupPlanId       
      INNER JOIN InsuranceGroup    WITH(NOLOCK) 
          ON InsuranceGroup.InsuranceGroupID = InsuranceGroupPlan.InsuranceGroupId
      --LEFT OUTER JOIN Users    
      --    ON Users.UserId = UserInsurance.PCPUserId AND Users.IsProvider = 1    
      --LEFT OUTER JOIN ExternalCareProvider    
      --    ON ExternalCareProvider.ExternalProviderId = UserInsurance.PCPExternalProviderId  
      LEFT JOIN EmployerGroup  WITH(NOLOCK) 
		  ON EmployerGroup.EmployerGroupID = PatientInsurance.EmployerGroupID    
      WHERE    
          ( PatientInsurance.PatientID = @i_UserId OR @i_UserId IS NULL )  
          AND ( @v_StatusCode IS NULL OR PatientInsurance.StatusCode = @v_StatusCode )
          
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
    ON OBJECT::[dbo].[usp_UserInsurance_Select] TO [FE_rohit.r-ext]
    AS [dbo];

