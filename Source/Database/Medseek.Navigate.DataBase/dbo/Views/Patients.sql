


CREATE VIEW [dbo].[Patients]
AS SELECT
       p.PatientID 
      --,p.UserLoginName
      ,p.FirstName
      ,p.MiddleName
      ,p.LastName
      ,p.NameSuffix
      ,p.NamePrefix
      ,p.Gender
      ,p.Title
      ,p.SSN
      ,pt.ProfessionalType
      ,p.PrimaryEmailAddress
      ,p.SecondaryEmailAddress
      ,p.PrimaryPhoneNumber
      ,p.PrimaryPhoneNumberExtension
      ,p.SecondaryPhoneNumber
      ,p.SecondaryPhoneNumberExtension
      ,p.TertiaryPhoneNumber Fax
      ,p.PrimaryAddressLine1 AddressLine1
      ,p.PrimaryAddressLine2 AddressLine2
      ,p.PrimaryAddressCity City
      ,css.StateName AS StateCode
      ,p.PrimaryAddressPostalCode ZipCode
      ,p.DateOfBirth
      ,Coalesce(p.MedicalRecordNumber,p.MemberID) MemberNum
      ,p.PrimaryAddressContactName EmergencyContactName
      --,p.EmergencyContactPhone
      ,p.AcceptsFaxCommunications
      ,p.AcceptsEmailCommunications
      ,p.AcceptsSMSCommunications
      ,p.AcceptsMassCommunications
      ,p.AcceptsPreventativeCommunications
      ,c.CommunicationType
      ,e.EthnicityName
      ,r.RaceName
      ,ctp.CallTimeName
      ,p.IsDeceased
      ,p.AccountStatusCode UserStatuscode 
      --,p.SMSPhoneNumber
      ,p.GeneralComments
      ,p.SocialAssessmentText
      ,p.FunctionalAssessmentText
      ,p.EnvironmentalAssessmentText
      ,dbo.ufn_GetAgeByDOB(p.DateOfBirth) AS Age
      ,COALESCE(ISNULL(p.LastName , '') + ', ' + ISNULL(p.FirstName , '') + '. ' + ISNULL(p.MiddleName , '') + ' ' + ISNULL(p.NameSuffix , '') , '') AS FullName
      ,p.PCPInternalProviderID PCPId
      ,b.BloodType
      ,p.DateDeceased DateOfDeath
      ,e.EthnicityId
      ,r.RaceId
      ,p.PrimaryAddressContactName
      ,pt.ProfessionalTypeID
      ,p.PreferredName
      ,p.UserID
   FROM
       dbo.Patient p WITH(NOLOCK)
   LEFT OUTER JOIN CodeSetProfessionalType pt WITH(NOLOCK)
       ON p.ProfessionalTypeID = pt.ProfessionalTypeID
   LEFT OUTER JOIN CommunicationType c WITH(NOLOCK)
       ON c.CommunicationTypeId = p.PreferredCommunicationTypeID 
   LEFT OUTER JOIN CodeSetEthnicity e WITH(NOLOCK)
       ON e.EthnicityId = p.EthnicityID
   LEFT OUTER JOIN CodeSetRace r WITH(NOLOCK)
       ON r.RaceId = p.RaceID
   LEFT OUTER JOIN CallTimePreference ctp WITH(NOLOCK)
       ON ctp.CallTimePreferenceId = p.CallTimePreferenceID                   
   LEFT OUTER JOIN CodeSetBloodType b WITH(NOLOCK)
       ON b.BloodTypeId = p.BloodTypeID
   LEFT OUTER JOIN CodeSetState css with(nolock)
       ON css.StateID = p.PrimaryAddressStateCodeID 
   --WHERE
   --    ( ISNULL(p.IsDeceased , 0) = 0 )
      --AND p.AccountStatusCode = 'A'
      
      
      
      
















