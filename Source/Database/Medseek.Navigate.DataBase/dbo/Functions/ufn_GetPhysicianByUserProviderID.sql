CREATE FUNCTION [dbo].[ufn_GetPhysicianByUserProviderID]  
(  
  @i_UserProviderID KEYID  
)  
RETURNS VARCHAR(150)  
AS  
BEGIN  
      DECLARE  
              @v_Name VARCHAR(150)  
             ,@v_InternalPhysicianName VARCHAR(150)  
             ,@v_ExternalPhysicianName VARCHAR(150)  
  
      SELECT  
          @v_InternalPhysicianName = ( SELECT  
                                           COALESCE(ISNULL(provider.LastName , '') + ' ' +   
                                                    ISNULL(provider.FirstName , '') + ' ' +   
                                                    ISNULL(provider.MiddleName , '') , ''  
                                                    )  
                                       FROM  
                                           Provider
                                       WHERE  
                                           Provider.UserId = patientProvider.ProviderID )  
         ,
          @v_ExternalPhysicianName = ( SELECT  
                                           COALESCE(ISNULL(ExternalCareProvider.LastName , '') + ' ' +   
                                                    ISNULL(ExternalCareProvider.FirstName , '') + ' ' +   
                                                    ISNULL(ExternalCareProvider.MiddleName , '') , ''  
                                                    )  
                                       FROM  
                                           ExternalCareProvider  
                                       WHERE  
                                           ExternalCareProvider.ExternalProviderId = UserProviders.ExternalProviderId ) -- AS ExternalPhysicianName    
      FROM  
          patientProvider  
      WHERE  
          patientProvider.PatientProviderID = @i_UserProviderID  
  
      IF @v_InternalPhysicianName <> ''  
         SET @v_Name = @v_InternalPhysicianName  
      ELSE  
         SET @v_Name = @v_ExternalPhysicianName  
  
      RETURN ISNULL(@v_Name , '')  
END  