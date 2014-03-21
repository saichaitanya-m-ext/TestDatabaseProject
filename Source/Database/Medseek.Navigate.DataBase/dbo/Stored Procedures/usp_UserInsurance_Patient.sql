/*        
------------------------------------------------------------------------------        
Procedure Name: usp_UserInsurance_Patient 206,1,1
Description   : This procedure is used to get the details from Users table    
    for a particular insurance group and plan    
Created By    : NAGABABU        
Created Date  : 03-JUNE-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
02-Aug-2010 NagaBabu Added @i_InsuranceGroupPlanId IS NULL to where clause
                       and also @v_InsuranceGroupID IS NULL 
24-Sep-2010 NagaBabu ADDED UserInsurance.StatusCode to where condition 
26-Dec-2011 Rathnam added order by clause on PatientName                            
------------------------------------------------------------------------------        
*/    
CREATE PROCEDURE [dbo].[usp_UserInsurance_Patient]   
(    
 @i_AppUserId KEYID ,    
 @v_InsuranceGroupID KEYID,    
 @i_InsuranceGroupPlanId KEYID    
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
    
      SELECT DISTINCT    
          Patient.PatientID UserId,    
		  COALESCE(ISNULL(Patient.LastName , '') + ' '       
			+ ISNULL(Patient.FirstName , '') + ' '       
			+ ISNULL(Patient.MiddleName , '')      
			 ,'') AS PatientName ,    
          Patient.Gender ,    
          DateDIFF(Year , Patient.DateOfBirth , GETDATE()) AS Age ,    
          Patient.MedicalRecordNumber MemberNum  ,
          COALESCE(ISNULL(Provider.LastName , '') + ' '       
			+ ISNULL(Provider.FirstName , '') + ' '       
			+ ISNULL(Provider.MiddleName , '')      
			 ,'') AS LogonName  
      FROM    
          PatientInsurance    
      INNER JOIN InsuranceGroupPlan    
          ON PatientInsurance.InsuranceGroupPlanId = InsuranceGroupPlan.InsuranceGroupPlanId    
      INNER JOIN InsuranceGroup    
          ON InsuranceGroup.InsuranceGroupID = InsuranceGroupPlan.InsuranceGroupID    
      INNER JOIN Patient    
          ON Patient.PatientID = PatientInsurance.PatientID  
      LEFT JOIN Provider  
          ON Patient.PCPInternalProviderID = Provider.ProviderID
      WHERE    
            (InsuranceGroup.InsuranceGroupID = @v_InsuranceGroupID OR @v_InsuranceGroupID IS NULL )    
        AND (InsuranceGroupPlan.InsuranceGroupPlanId = @i_InsuranceGroupPlanId OR @i_InsuranceGroupPlanId IS NULL )  
        AND Patient.AccountStatusCode = 'A'
        AND PatientInsurance.StatusCode = 'A' 
      ORDER BY PatientName     
    
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
    ON OBJECT::[dbo].[usp_UserInsurance_Patient] TO [FE_rohit.r-ext]
    AS [dbo];

