





CREATE VIEW [dbo].[vw_Dataload_CodesetNPI]
AS

SELECT [NPI]                                                 AS NPINumber
      ,ISNULL(csnd.[Entity Type Code] ,2)                    AS EntityTypeID
      ,csnd.[Replacement NPI]                                AS ReplacementNPI
      ,csnd.[Employer Identification Number (EIN)]           AS TaxID_EIN_SSN
      ,csnd.[Provider Organization Name (Legal Business Name)] AS OrganizationName
      ,csnd.[Provider Last Name (Legal Name)]                AS LastName
      ,csnd.[Provider First Name]                            AS FirstName
      ,csnd.[Provider Middle Name]                           AS MiddleName
      ,csnp.NamePrefixID                                     AS NamePrefixID
      ,csns.NameSuffixID                                     AS NameSuffixID
      ,csnd.[Provider Credential Text]                       AS [Credential]
      ,csg.GenderID                                          AS GenderID
      ,csnd.[Provider Other Organization Name]               AS OtherOrganizationName
      ,csnd.[Provider Other Organization Name Type Code]     AS OtherOrganizationNameTypeID
      ,csnd.[Provider Other Last Name]                       AS OtherLastName
      ,csnd.[Provider Other First Name]                      AS OtherFirstName
      ,csnd.[Provider Other Middle Name]                     AS OtherMiddleName
      ,csnop.NamePrefixID                                    AS OtherNamePrefixID
      ,csnos.NameSuffixID                                    AS OtherNameSuffixID
      ,csnd.[Provider Other Credential Text]                 AS OtherCredential
      ,csnd.[Provider Other Last Name Type Code]             AS OtherLastNameTypeID
      ,csnd.[Provider First Line Business Mailing Address]   AS MailingAddress1
      ,csnd.[Provider Second Line Business Mailing Address]  AS MailingAddress2
      ,csnd.[Provider Business Mailing Address City Name]    AS MailingAddressCity
      ,css.StateID                                           AS MailingAddressStateID
      ,csnd.[Provider Business Mailing Address Postal Code]  AS MailingAddressPostalCode
      ,csc.CountryID                                         AS MailingAddressCountryID
      ,csnd.[Provider Business Mailing Address Telephone Number] AS MailingAddressPhoneNumber
      ,csnd.[Provider Business Mailing Address Fax Number]   AS MailingAddressFaxNumber
      ,csnd.[Provider First Line Business Practice Location Address] AS PracticeLocationAddress1
      ,csnd.[Provider Second Line Business Practice Location Address] AS PracticeLocationAddress2
      ,csnd.[Provider Business Practice Location Address City Name] AS PracticeLocationCity
      ,pcss.StateID                                          AS PracticeLocationStateID
      ,csnd.[Provider Business Practice Location Address Postal Code] AS PracticeLocationPostalCode
      ,pcsc.CountryID                                        AS PracticeLocationCountryID
      ,csnd.[Provider Business Practice Location Address Telephone Number] AS PracticeLocationPhoneNumber
      ,csnd.[Provider Business Practice Location Address Fax Number] AS PracticeLocationFaxNumber
      ,csnd.[Provider Enumeration Date]                      AS ProviderEnumerationDate
      ,csnd.[Last Update Date]                               AS LastUpdateDate
      ,csnr.DeactivationReasonCodeID                         AS NPIDeactivationReasonCodeID
      ,csnd.[NPI Deactivation Date]                          AS NPIDeactivationDate
      ,csnd.[NPI Reactivation Date]                          AS NPIReactivationDate
      ,csnd.[Authorized Official Last Name]                  AS AuthorizedOfficialLastName
      ,csnd.[Authorized Official First Name]                 AS AuthorizedOfficialFirstName
      ,csnd.[Authorized Official Middle Name]                AS AuthorizedOfficialMiddleName
      ,csnd.[Authorized Official Title or Position]          AS AuthorizedOfficialTitlePosition
      ,csnd.[Authorized Official Telephone Number]           AS [Authorized OfficialTelephoneNumber]
      ,CASE 
            WHEN CHARINDEX('Y',csnd.[Is Sole Proprietor]) > 0 THEN 1
            WHEN CHARINDEX('N',csnd.[Is Sole Proprietor]) > 0 THEN 0
            ELSE NULL
       END                                                   AS IsSoleProprietor
      ,CASE 
            WHEN CHARINDEX('Y',csnd.[Is Organization Subpart]) > 0 THEN 1
            WHEN CHARINDEX('N',csnd.[Is Organization Subpart]) > 0 THEN 0
            ELSE NULL
       END                                                   AS IsOrganizationSubpart
      ,csnd.[Parent Organization LBN]                        AS ParentOrganizationLBN
      ,csnd.[Parent Organization TIN]                        AS ParentOrganizationTIN
      ,csnap.NamePrefixID                                    AS AuthorizedOfficialNamePrefixID
      ,[Authorized Official Name Prefix Text]
      ,csnas.NameSuffixID                                    AS AuthorizedOfficialNameSuffixID
      ,[Authorized Official Name Suffix Text]
      ,[Authorized Official Credential Text]                 AS AuthorizedOfficialCredential
      ,NULL                                                  AS DataSourceID
      ,NULL                                                  AS DataSourceFileID
      ,'A'													 AS StatusCode
      ,(
           SELECT MIN(ProviderID)
           FROM   Provider p
       )                                                     AS CreatedByUserID
      ,GETDATE()                                             AS CreatedDate
      ,NULL                                                  AS LastModifiedByUserID
      ,NULL                                                  AS LastModifiedDate
       --INTO Dataload_CodesetNPITest
FROM   dbo.DataLoad_CodeSetNPIDetails csnd --WITH(INDEX(UQ_Dataload_NPIDeialis_NPI))
       
LEFT OUTER JOIN CodeSetNamePrefix csnp
       ON  REPLACE(csnd.[Provider Name Prefix Text] ,'.' ,'') = REPLACE(csnp.NamePrefix ,'.' ,'')
LEFT OUTER JOIN CodeSetNameSuffix csns
       ON  REPLACE(csnd.[Provider Name Suffix Text] ,'.' ,'') = REPLACE(csns.NameSuffix ,'.' ,'')
LEFT OUTER JOIN CodeSetNamePrefix csnop
       ON  REPLACE(csnd.[Provider Other Name Prefix Text] ,'.' ,'') = REPLACE(csnop.NamePrefix ,'.' ,'')
LEFT OUTER JOIN CodeSetNameSuffix csnos
       ON  REPLACE(csnd.[Provider Other Name Suffix Text] ,'.' ,'') = REPLACE(csnos.NameSuffix ,'.' ,'')
LEFT OUTER JOIN CodeSetNamePrefix csnap
       ON  REPLACE(csnd.[Provider Other Name Prefix Text] ,'.' ,'') = REPLACE(csnap.NamePrefix ,'.' ,'')
LEFT OUTER JOIN CodeSetNameSuffix csnas
       ON  REPLACE(csnd.[Provider Other Name Suffix Text] ,'.' ,'') = REPLACE(csnas.NameSuffix ,'.' ,'')
LEFT OUTER JOIN CodeSetGender csg
       ON  csg.GenderCode = csnd.[Provider Gender Code]
LEFT OUTER JOIN CodeSetState css
       ON  css.StateCode = csnd.[Provider Business Mailing Address State Name]
AND        LEN([Provider Business Mailing Address State Name]) = 2
LEFT OUTER JOIN CodeSetCountry csc
       ON  csc.CountryID = css.CountryID
LEFT OUTER JOIN CodeSetState pcss
       ON  pcss.StateCode = csnd.[Provider Business Practice Location Address State Name]
AND        LEN([Provider Business Practice Location Address State Name]) = 2
LEFT OUTER JOIN CodeSetCountry pcsc
       ON  pcsc.CountryID = pcss.CountryID
LEFT OUTER JOIN CodeSetNPIDeactivationReason csnr
       ON  csnr.DeactivationReasonCode = csnd.[NPI Deactivation Reason Code]





