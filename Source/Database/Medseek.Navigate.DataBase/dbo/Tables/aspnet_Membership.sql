CREATE TABLE [dbo].[aspnet_Membership] (
    [ApplicationId]                          UNIQUEIDENTIFIER NOT NULL,
    [UserId]                                 UNIQUEIDENTIFIER NOT NULL,
    [Password]                               NVARCHAR (128)   NOT NULL,
    [PasswordFormat]                         INT              CONSTRAINT [DF__aspnet_Me__Passw__164452B1] DEFAULT ((0)) NOT NULL,
    [PasswordSalt]                           NVARCHAR (128)   NOT NULL,
    [MobilePIN]                              NVARCHAR (16)    NULL,
    [Email]                                  NVARCHAR (256)   NULL,
    [LoweredEmail]                           NVARCHAR (256)   NULL,
    [PasswordQuestion]                       NVARCHAR (256)   NULL,
    [PasswordAnswer]                         NVARCHAR (128)   NULL,
    [IsApproved]                             BIT              NOT NULL,
    [IsLockedOut]                            BIT              NOT NULL,
    [CreateDate]                             DATETIME         NOT NULL,
    [LastLoginDate]                          DATETIME         NOT NULL,
    [LastPasswordChangedDate]                DATETIME         NOT NULL,
    [LastLockoutDate]                        DATETIME         NOT NULL,
    [FailedPasswordAttemptCount]             INT              NOT NULL,
    [FailedPasswordAttemptWindowStart]       DATETIME         NOT NULL,
    [FailedPasswordAnswerAttemptCount]       INT              NOT NULL,
    [FailedPasswordAnswerAttemptWindowStart] DATETIME         NOT NULL,
    [Comment]                                NTEXT            NULL,
    [IsUserGeneratedPassword]                BIT              NULL,
    [IsPasswordLocked]                       BIT              NULL,
    [PasswordExpireDate]                     DATETIME         NULL,
    CONSTRAINT [PK__aspnet_Membershi__1367E606] PRIMARY KEY NONCLUSTERED ([UserId] ASC) WITH (FILLFACTOR = 25) ON [FG_Transactional_NCX],
    CONSTRAINT [FK__aspnet_Me__Appli__145C0A3F] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[aspnet_Applications] ([ApplicationId]),
    CONSTRAINT [FK__aspnet_Me__UserI__15502E78] FOREIGN KEY ([UserId]) REFERENCES [dbo].[aspnet_Users] ([UserId])
);


GO
CREATE CLUSTERED INDEX [aspnet_Membership_index]
    ON [dbo].[aspnet_Membership]([ApplicationId] ASC, [LoweredEmail] ASC) WITH (FILLFACTOR = 25);


GO

CREATE TRIGGER [dbo].[utr_aspnet_Membership_Update] ON [dbo].[aspnet_Membership]
AFTER UPDATE
AS
BEGIN
	IF (
			UPDATE (Email)
				OR
			UPDATE (IsApproved)
				OR
			UPDATE (IsLockedOut)
			)
	BEGIN
		DECLARE @v_aspnetLoginName NVARCHAR(256)
			,@v_aspnetEmail NVARCHAR(256)
			,@i_UserId INT
			,@i_ReturnNoOfRecordsUpdated INT
			,@b_IsApproved BIT
			,@b_IsLockedOut BIT

		SELECT @v_aspnetEmail = INS.Email
			,@v_aspnetLoginName = aspnet_Users.UserName
			,@b_IsApproved = INS.IsApproved
			,@b_IsLockedOut = INS.IsLockedOut
		FROM INSERTED INS
		INNER JOIN aspnet_users
			ON INS.UserId = aspnet_users.UserId

		DECLARE @b_IsProvider BIT
			,@b_IsPatient BIT
			,@v_AcctStatus VARCHAR(1)

		SELECT @i_UserId = UserId
			,@b_IsProvider = ISNULL(IsProvider, 0)
			,@b_IsPatient = ISNULL(IsPatient, 0)
		--,@v_AcctStatus = AccountStatusCode
		FROM Users
		WHERE UserLoginName = @v_aspnetLoginName

		--IF @b_IsLockedOut = 1
		--SET @v_AcctStatus = 'L'
		------------------- Update the users table when the aspnetuser mail is updated--------    
		UPDATE Users
		SET AccountStatusCode = 'L'
		WHERE UserId = @i_UserId
			AND @b_IsLockedOut = 1

		IF @b_IsProvider = 1
		BEGIN
			UPDATE Provider
			SET PrimaryEmailAddress = @v_aspnetEmail
				,AccountStatusCode = 'L'
				,LastModifiedDate = GETDATE()
			FROM UserGroUp
			WHERE UserGroup.ProviderID = Provider.ProviderID
				AND UserGroup.UserID = @i_UserId
				AND @b_IsLockedOut = 1
		END

		IF @b_IsPatient = 1
		BEGIN
			UPDATE Patient
			SET PrimaryEmailAddress = @v_aspnetEmail
				,AccountStatusCode = 'L'
				,LastModifiedDate = GETDATE()
			WHERE UserID = @i_UserId
				AND @b_IsLockedOut = 1
		END
	END
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MS .NET 2.9 Security Table - The cross reference between users and applications', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Application ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'ApplicationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'UserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Password (plaintext, hashed, or encrypted; base-64-encoded if hashed or encrypted)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'Password';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Password format (0=Plaintext, 1=Hashed, 2=Encrypted)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'PasswordFormat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Randomly generated 128-bit value used to salt password hashes; stored in base-64-encoded form', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'PasswordSalt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User mobile PIN (currently not used)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'MobilePIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User e-mail address', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User e-mail address (lowercase)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'LoweredEmail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Password question', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'PasswordQuestion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Answer to password question', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'PasswordAnswer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Approved, 0=Not approved', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'IsApproved';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1=Locked out, 0=Not locked out', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'IsLockedOut';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time this account was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'CreateDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time of this users last login', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'LastLoginDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time this users password was last changed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'LastPasswordChangedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time this user was last locked out', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'LastLockoutDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Number of consecutive failed login attempts', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'FailedPasswordAttemptCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time of first failed login if FailedPasswordAttemptCount is nonzero', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'FailedPasswordAttemptWindowStart';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Number of consecutive failed password answer attempts', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'FailedPasswordAnswerAttemptCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time of first failed password answer if FailedPasswordAnswerAttemptCount is nonzero', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'FailedPasswordAnswerAttemptWindowStart';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Membership', @level2type = N'COLUMN', @level2name = N'Comment';

