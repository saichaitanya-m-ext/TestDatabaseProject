CREATE TABLE [dbo].[Patient] (
    [PatientID]                                           [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [UserID]                                              [dbo].[KeyID]            NULL,
    [FirstName]                                           [dbo].[FirstName]        NOT NULL,
    [MiddleName]                                          [dbo].[MiddleName]       NULL,
    [LastName]                                            VARCHAR (100)            NOT NULL,
    [NamePrefix]                                          VARCHAR (10)             NULL,
    [NameSuffix]                                          VARCHAR (10)             NULL,
    [Title]                                               [dbo].[ShortDescription] NULL,
    [PreferredName]                                       [dbo].[ShortDescription] NULL,
    [SSN]                                                 [dbo].[SSN]              NULL,
    [DateOfBirth]                                         [dbo].[UserDate]         NULL,
    [CountryOfBirthID]                                    [dbo].[KeyID]            NULL,
    [IsDeceased]                                          [dbo].[IsIndicator]      NULL,
    [DateDeceased]                                        [dbo].[UserDate]         NULL,
    [Gender]                                              VARCHAR (1)              NULL,
    [RaceID]                                              [dbo].[KeyID]            NULL,
    [EthnicityID]                                         [dbo].[KeyID]            NULL,
    [BloodType]                                           VARCHAR (10)             NULL,
    [MaritalStatusID]                                     [dbo].[KeyID]            NULL,
    [NoOfDependents]                                      TINYINT                  NULL,
    [EmploymentStatus]                                    VARCHAR (30)             NULL,
    [PCPName]                                             VARCHAR (120)            NULL,
    [PCPNPI]                                              VARCHAR (80)             NULL,
    [PCPInternalProviderID]                               [dbo].[KeyID]            NULL,
    [MedicalRecordNumber]                                 VARCHAR (30)             NULL,
    [PrimaryAddressContactName]                           VARCHAR (60)             NULL,
    [PrimaryAddressContactRelationshipToPatientID]        [dbo].[KeyID]            NULL,
    [PrimaryAddressTypeID]                                [dbo].[KeyID]            NULL,
    [PrimaryAddressLine1]                                 VARCHAR (60)             NULL,
    [PrimaryAddressLine2]                                 VARCHAR (60)             NULL,
    [PrimaryAddressLine3]                                 VARCHAR (60)             NULL,
    [PrimaryAddressCity]                                  VARCHAR (60)             NULL,
    [PrimaryAddressStateCodeID]                           [dbo].[KeyID]            NULL,
    [PrimaryAddressCountyID]                              [dbo].[KeyID]            NULL,
    [PrimaryAddressPostalCode]                            VARCHAR (20)             NULL,
    [PrimaryAddressCountryCodeID]                         [dbo].[KeyID]            NULL,
    [SecondaryAddressContactName]                         VARCHAR (60)             NULL,
    [SecondaryAddressContactRelationshipToPatientID]      [dbo].[KeyID]            NULL,
    [SecondaryAddressTypeID]                              [dbo].[KeyID]            NULL,
    [SecondaryAddressLine1]                               VARCHAR (60)             NULL,
    [SecondaryAddressLine2]                               VARCHAR (60)             NULL,
    [SecondaryAddressLine3]                               VARCHAR (60)             NULL,
    [SecondaryAddressCity]                                VARCHAR (60)             NULL,
    [SecondaryAddressStateCodeID]                         [dbo].[KeyID]            NULL,
    [SecondaryAddressCountyID]                            [dbo].[KeyID]            NULL,
    [SecondaryAddressPostalCode]                          VARCHAR (20)             NULL,
    [SecondaryAddressCountryCodeID]                       [dbo].[KeyID]            NULL,
    [PrimaryPhoneContactName]                             VARCHAR (60)             NULL,
    [PrimaryPhoneContactRelationshipToPatientID]          [dbo].[KeyID]            NULL,
    [PrimaryPhoneTypeID]                                  [dbo].[KeyID]            NULL,
    [PrimaryPhoneNumber]                                  VARCHAR (15)             NULL,
    [PrimaryPhoneNumberExtension]                         VARCHAR (20)             NULL,
    [SecondaryPhoneContactName]                           VARCHAR (60)             NULL,
    [SecondaryPhoneContactRelationshipToPatientID]        [dbo].[KeyID]            NULL,
    [SecondaryPhoneTypeID]                                [dbo].[KeyID]            NULL,
    [SecondaryPhoneNumber]                                VARCHAR (15)             NULL,
    [SecondaryPhoneNumberExtension]                       VARCHAR (20)             NULL,
    [TertiaryPhoneContactName]                            VARCHAR (60)             NULL,
    [TertiaryPhoneContactRealtionToPatientID]             [dbo].[KeyID]            NULL,
    [TertiaryPhoneTypeID]                                 [dbo].[KeyID]            NULL,
    [TertiaryPhoneNumber]                                 VARCHAR (15)             NULL,
    [TeritaryPhoneNumberExtension]                        VARCHAR (20)             NULL,
    [PrimaryEmailAddressContactName]                      VARCHAR (60)             NULL,
    [PrimaryEmailAddressContactRelationshipToPatientID]   [dbo].[KeyID]            NULL,
    [PrimaryEmailAddressTypeID]                           [dbo].[KeyID]            NULL,
    [PrimaryEmailAddress]                                 VARCHAR (256)            NULL,
    [SecondaryEmailAddressContactName]                    VARCHAR (60)             NULL,
    [SecondaryEmailAddressContactRelationshipToPatientID] [dbo].[KeyID]            NULL,
    [SecondaryEmailAddresTypeID]                          [dbo].[KeyID]            NULL,
    [SecondaryEmailAddress]                               VARCHAR (256)            NULL,
    [MedicarePrimeIndicator]                              VARCHAR (1)              NULL,
    [MedicarePrimeBeginDate]                              [dbo].[UserDate]         NULL,
    [MedicarePrimeEndDate]                                [dbo].[UserDate]         NULL,
    [DefaultTaskCareProviderID]                           [dbo].[KeyID]            NULL,
    [BarrierComments]                                     VARCHAR (1000)           NULL,
    [SocialAssessmentText]                                VARCHAR (1000)           NULL,
    [FunctionalAssessmentText]                            VARCHAR (1000)           NULL,
    [EnvironmentalAssessmentText]                         VARCHAR (1000)           NULL,
    [GeneralComments]                                     VARCHAR (2000)           NULL,
    [AcceptsFaxCommunications]                            [dbo].[IsIndicator]      NULL,
    [AcceptsEmailCommunications]                          [dbo].[IsIndicator]      NULL,
    [AcceptsSMSCommunications]                            [dbo].[IsIndicator]      NULL,
    [AcceptsMassCommunications]                           [dbo].[IsIndicator]      NULL,
    [AcceptsPreventativeCommunications]                   [dbo].[IsIndicator]      NULL,
    [PreferredCommunicationTypeID]                        [dbo].[KeyID]            NULL,
    [CallTimePreferenceID]                                [dbo].[KeyID]            NULL,
    [PreferredCallTime]                                   TIME (7)                 NULL,
    [ProfessionalTypeID]                                  [dbo].[KeyID]            NULL,
    [UnderWriter]                                         VARCHAR (5)              NULL,
    [DataSourceID]                                        [dbo].[KeyID]            NULL,
    [DataSourceFileID]                                    [dbo].[KeyID]            NULL,
    [RecordTag_FileID]                                    VARCHAR (30)             NULL,
    [EmploymentStatusID]                                  [dbo].[KeyID]            NULL,
    [AccountStatusCode]                                   VARCHAR (20)             CONSTRAINT [DF_Patient_AccountStatus] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]                                     [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                                         [dbo].[UserDate]         CONSTRAINT [DF_Patient_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]                                [dbo].[KeyID]            NULL,
    [LastModifiedDate]                                    [dbo].[UserDate]         NULL,
    [BloodTypeID]                                         [dbo].[KeyID]            NULL,
    [InsuranceGroupID]                                    [dbo].[KeyID]            NULL,
    [MemberID]                                            VARCHAR (80)             NULL,
    [PolicyNumber]                                        VARCHAR (80)             NULL,
    [GroupNumber]                                         VARCHAR (80)             NULL,
    [PatientPrimaryId]                                    UNIQUEIDENTIFIER         NULL,
    CONSTRAINT [PK_Patient] PRIMARY KEY CLUSTERED ([PatientID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Patient_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_Patient_CodeSetEmploymentStatus] FOREIGN KEY ([EmploymentStatusID]) REFERENCES [dbo].[CodeSetEmploymentStatus] ([EmploymentStatusID]),
    CONSTRAINT [FK_Patient_CodeSetProfessionalType] FOREIGN KEY ([ProfessionalTypeID]) REFERENCES [dbo].[CodeSetProfessionalType] ([ProfessionalTypeID]),
    CONSTRAINT [FK_Patient_CodeSetState] FOREIGN KEY ([PrimaryAddressStateCodeID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_Patient_CountryOfBirthCodeSetCountry] FOREIGN KEY ([CountryOfBirthID]) REFERENCES [dbo].[CodeSetCountry] ([CountryID]),
    CONSTRAINT [FK_Patient_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_Patient_InsuranceGroup] FOREIGN KEY ([InsuranceGroupID]) REFERENCES [dbo].[InsuranceGroup] ([InsuranceGroupID]),
    CONSTRAINT [FK_Patient_LkUpAccountStatus] FOREIGN KEY ([AccountStatusCode]) REFERENCES [dbo].[LkUpAccountStatus] ([AccountStatusCode]),
    CONSTRAINT [FK_Patient_PCPInternalProviderID] FOREIGN KEY ([PCPInternalProviderID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_Patient_PrimaryAddressCodeSetCountry] FOREIGN KEY ([PrimaryAddressCountryCodeID]) REFERENCES [dbo].[CodeSetCountry] ([CountryID]),
    CONSTRAINT [FK_Patient_PrimaryAddressCodeSetCounty] FOREIGN KEY ([PrimaryAddressCountyID]) REFERENCES [dbo].[CodeSetCounty] ([CountyID]),
    CONSTRAINT [FK_Patient_PrimaryAddressCodeSetState] FOREIGN KEY ([PrimaryAddressStateCodeID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_Patient_PrimaryAddressLkUpAddressType] FOREIGN KEY ([PrimaryAddressTypeID]) REFERENCES [dbo].[LkUpAddressType] ([AddressTypeID]),
    CONSTRAINT [FK_Patient_PrimaryEmailAddressLkUpEmailAddressType] FOREIGN KEY ([PrimaryEmailAddressTypeID]) REFERENCES [dbo].[LkUpEmailAddressType] ([EmailAddressTypeID]),
    CONSTRAINT [FK_Patient_PrimaryPhoneLkUpPhoneType] FOREIGN KEY ([PrimaryPhoneTypeID]) REFERENCES [dbo].[LkUpPhoneType] ([PhoneTypeID]),
    CONSTRAINT [FK_Patient_SecondaryAddressCodeSetCountry] FOREIGN KEY ([SecondaryAddressCountryCodeID]) REFERENCES [dbo].[CodeSetCountry] ([CountryID]),
    CONSTRAINT [FK_Patient_SecondaryAddressCodeSetCounty] FOREIGN KEY ([SecondaryAddressCountyID]) REFERENCES [dbo].[CodeSetCounty] ([CountyID]),
    CONSTRAINT [FK_Patient_SecondaryAddressCodeSetState] FOREIGN KEY ([SecondaryAddressStateCodeID]) REFERENCES [dbo].[CodeSetState] ([StateID]),
    CONSTRAINT [FK_Patient_SecondaryAddressLkUpAddressType] FOREIGN KEY ([SecondaryAddressTypeID]) REFERENCES [dbo].[LkUpAddressType] ([AddressTypeID]),
    CONSTRAINT [FK_Patient_SecondaryEmailAddressLkUpEmailAddressType] FOREIGN KEY ([SecondaryEmailAddresTypeID]) REFERENCES [dbo].[LkUpEmailAddressType] ([EmailAddressTypeID]),
    CONSTRAINT [FK_Patient_SecondaryPhoneLkUpPhoneType] FOREIGN KEY ([SecondaryPhoneTypeID]) REFERENCES [dbo].[LkUpPhoneType] ([PhoneTypeID]),
    CONSTRAINT [FK_Patient_TertiaryPhoneLkUpPhoneType] FOREIGN KEY ([TertiaryPhoneTypeID]) REFERENCES [dbo].[LkUpPhoneType] ([PhoneTypeID])
);


GO
CREATE STATISTICS [stat_Patient_AcceptsSMSCommunications_PatientID]
    ON [dbo].[Patient]([AcceptsSMSCommunications], [PatientID]);


GO
CREATE STATISTICS [stat_Patient_AccountStatusCode_UserID_PCPInternalProviderID_PatientID]
    ON [dbo].[Patient]([AccountStatusCode], [UserID], [PCPInternalProviderID], [PatientID]);


GO
CREATE STATISTICS [stat_Patient_PatientID_AccountStatusCode_UserID]
    ON [dbo].[Patient]([PatientID], [AccountStatusCode], [UserID]);


GO
CREATE STATISTICS [stat_Patient_PCPInternalProviderID_PatientID]
    ON [dbo].[Patient]([PCPInternalProviderID], [PatientID]);


GO
/*                      
--------------------------------------------------------------------------------------------------------------------------      
Trigger Name: [dbo].[tr_Update_Patient] 
Description:                     
When   Who    Action                      
---------------------------------------------------------------------------------------------------------------------------      
20-March-2013 Rathnam Created

----------------------------------------------------------------------------------------------------------------------------      
*/
CREATE TRIGGER [dbo].[tr_Update_Patient] ON [dbo].[Patient]
       AFTER UPDATE
AS
BEGIN
      IF TRIGGER_NESTLEVEL() > 1
         BEGIN
               RETURN
         END
--------------Updation Takes place into Users Table------------------------------------  
      UPDATE
          Users
      SET
          Users.EndDate = ISNULL(Users.EndDate , GETDATE())
         ,LastModifiedByUserId = INSERTED.LastModifiedByUserId
         ,LastModifiedDate = GETDATE()
      FROM
          INSERTED
      WHERE
          inserted.UserID = Users.UserId
          AND ( INSERTED.DateDeceased IS NOT NULL
                OR INSERTED.IsDeceased = 1
              )
 
--------------Updation Takes place into Task Table------------------------------------          
      UPDATE
          Task
      SET
          Task.TaskStatusId = ( SELECT
                                    TaskStatusId
                                FROM
                                    TaskStatus
                                WHERE
                                    TaskStatusText = 'Closed Incomplete' )
         ,LastModifiedByUserId = INSERTED.LastModifiedByUserId
         ,LastModifiedDate = GETDATE()
      FROM
          INSERTED
      WHERE
          Task.PatientId = INSERTED.PatientID
          AND ( INSERTED.DateDeceased IS NOT NULL
                OR INSERTED.IsDeceased = 1
              )
          AND Task.TaskStatusId IN ( SELECT
                                         TaskStatusId
                                     FROM
                                         TaskStatus
                                     WHERE
                                         TaskStatusText IN ( 'Open' , 'Scheduled' ) )

--------------Updation Takes place into UserPrograms Table------------------------------------          
      UPDATE
          PatientProgram
      SET
          DeclinedDate = GETDATE()
         ,StatusCode = 'I'
         ,LastModifiedByUserId = INSERTED.LastModifiedByUserId
         ,LastModifiedDate = GETDATE()
      FROM
          INSERTED
      WHERE
          PatientProgram.PatientID = INSERTED.PatientID
          AND ( INSERTED.DateDeceased IS NOT NULL
                OR INSERTED.IsDeceased = 1
              )
               
--------------Updation Takes place into PatientGoalProgressLog Table------------------------------------

      UPDATE
          PatientGoalProgressLog
      SET
          PatientGoalProgressLog.StatusCode = 'I'
         ,LastModifiedByUserId = INSERTED.LastModifiedByUserId
         ,LastModifiedDate = GETDATE()
      FROM
          PatientGoalProgressLog
          INNER JOIN PatientGoal
          ON PatientGoalProgressLog.PatientGoalId = PatientGoal.PatientGoalId
          INNER JOIN INSERTED
          ON PatientGoal.PatientId = INSERTED.PatientID
          AND ( INSERTED.DateDeceased IS NOT NULL
                OR INSERTED.IsDeceased = 1
              )
          AND PatientGoalProgressLog.StatusCode = 'A'          	     
	   
--------------Updation Takes place into CohortListUsers Table------------------------------------                                                                                                                  
      UPDATE
          PopulationDefinitionPatients
      SET
          PopulationDefinitionPatients.StatusCode = 'I'
         ,LastModifiedByUserId = INSERTED.LastModifiedByUserId
         ,LastModifiedDate = GETDATE()
      FROM
          INSERTED
      WHERE
          PopulationDefinitionPatients.PatientID = INSERTED.PatientID
          AND ( INSERTED.DateDeceased IS NOT NULL
                OR INSERTED.IsDeceased = 1
              )               
--------------Deletion Takes place into CohortListUsers Table------------------------------------
      UPDATE
          PatientCommunication
      SET
          PatientCommunication.StatusCode = 'I'
         ,PatientCommunication.LastModifiedByUserId = INSERTED.LastModifiedByUserId
         ,LastModifiedDate = GETDATE()
      FROM
          INSERTED
      WHERE
          PatientCommunication.PatientId = INSERTED.PatientID
          AND PatientCommunication.IsSentIndicator = 0
          AND ( INSERTED.DateDeceased IS NOT NULL
                OR INSERTED.IsDeceased = 1
              )
      
        /*   
		UPDATE
			aspnet_Membership
		SET
			aspnet_Membership.IsLockedOut = 0,
			aspnet_Membership.FailedPasswordAttemptCount=0
		FROM
			aspnet_Membership
	    INNER JOIN aspnet_users
			ON aspnet_users.UserId = aspnet_Membership.UserId
		INNER JOIN INSERTED
			ON INSERTED.UserLoginName = aspnet_users.UserName
		INNER JOIN DELETED
			ON DELETED.UserID = INSERTED.UserID
		WHERE
			DELETED.UserStatusCode = 'L'
		AND INSERTED.UserStatusCode = 'A'
		*/

      IF UPDATE(PrimaryEmailAddress)
         BEGIN
               UPDATE
                   aspnet_Membership
               SET
                   aspnet_Membership.Email = INSERTED.PrimaryEmailAddress
                  ,aspnet_Membership.LoweredEmail = LOWER(INSERTED.PrimaryEmailAddress)
               FROM
                   aspnet_Membership
                   INNER JOIN aspnet_users
                   ON aspnet_users.UserId = aspnet_Membership.UserId
                   INNER JOIN Users
                   ON Users.UserLoginName = aspnet_users.UserName
                   INNER JOIN INSERTED
                   ON INSERTED.UserID = Users.UserID
         END

	  IF UPDATE(AccountStatusCode)
         BEGIN
               UPDATE
                   aspnet_Membership
               SET
                   aspnet_Membership.IsLockedOut = CASE WHEN INSERTED.AccountStatusCode = 'L' THEN 1 ELSE 0 END,
                   aspnet_Membership.FailedPasswordAttemptCount =  CASE WHEN INSERTED.AccountStatusCode = 'L' THEN 5 ELSE 0 END
               FROM
                   aspnet_Membership
                   INNER JOIN aspnet_users
                   ON aspnet_users.UserId = aspnet_Membership.UserId
                   INNER JOIN Users
                   ON Users.UserLoginName = aspnet_users.UserName
                   INNER JOIN INSERTED
                   ON INSERTED.UserID = Users.UserID
         END


END
