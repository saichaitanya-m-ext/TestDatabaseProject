CREATE PROCEDURE usp_Data_Load_ADT (@i_AppUserId KEYID)
AS
BEGIN TRY
	INSERT INTO Stg_ADTPatient (
		Patient_PrimaryId_Id
		,Identifiers_Identifier_Id
		,Identifiers_Identifier_TypeCode
		,Identifiers_Identifier_AssigningFacility
		,PatientNames_Name_FamilyName
		,PatientNames_Name_GivenName
		,DateOfBirth
		,Sex
		,Races_Race_OriginalNameCode
		,Races_Race_NameCode
		,Addresses_Address_StreetAddress
		,Addresses_Address_City
		,Addresses_Address_StateOrProvince
		,Addresses_Address_ZipOrPostalCode
		,Addresses_Address_Country
		,Addresses_Address_AddressType
		,HomePhoneNumbers_TeleComNumber_UseCode
		,HomePhoneNumbers_TeleComNumber_EquipmentType
		,HomePhoneNumbers_TeleComNumber_CommAddress
		,HomePhoneNumbers_TeleComNumber_CountryCode
		,HomePhoneNumbers_TeleComNumber_AreaCode
		,HomePhoneNumbers_TeleComNumber_LocalNumber
		,BusinessPhoneNumbers_TeleComNumber_UseCode
		,BusinessPhoneNumbers_TeleComNumber_EquipmentType
		,BusinessPhoneNumbers_TeleComNumber_CommAddress
		,BusinessPhoneNumbers_TeleComNumber_CountryCode
		,BusinessPhoneNumbers_TeleComNumber_AreaCode
		,BusinessPhoneNumbers_TeleComNumber_LocalNumber
		,MaritalStatus
		,Religion
		,SSN
		,EthnicGroups_EthnicGroup_OriginalNameCode
		,EthnicGroups_EthnicGroup_NameCode
		,Languages_Language_OriginalNameCode
		,Languages_Language_NameCode
		,DeathIndicator
		,EventType
		)
	SELECT DISTINCT Patient_PrimaryId_Id
		,Identifiers_Identifier_Id
		,Identifiers_Identifier_TypeCode
		,Identifiers_Identifier_AssigningFacility
		,PatientNames_Name_FamilyName
		,PatientNames_Name_GivenName
		,DateOfBirth
		,CASE 
			WHEN Sex = 'Female'
				THEN 'F'
			WHEN Sex = 'Male'
				THEN 'M'
			ELSE NULL
			END AS Sex
		,Races_Race_OriginalNameCode
		,Races_Race_NameCode
		,Addresses_Address_StreetAddress
		,Addresses_Address_City
		,Addresses_Address_StateOrProvince
		,Addresses_Address_ZipOrPostalCode
		,Addresses_Address_Country
		,Addresses_Address_AddressType
		,HomePhoneNumbers_TeleComNumber_UseCode
		,HomePhoneNumbers_TeleComNumber_EquipmentType
		,HomePhoneNumbers_TeleComNumber_CommAddress
		,HomePhoneNumbers_TeleComNumber_CountryCode
		,HomePhoneNumbers_TeleComNumber_AreaCode
		,HomePhoneNumbers_TeleComNumber_LocalNumber
		,BusinessPhoneNumbers_TeleComNumber_UseCode
		,BusinessPhoneNumbers_TeleComNumber_EquipmentType
		,BusinessPhoneNumbers_TeleComNumber_CommAddress
		,BusinessPhoneNumbers_TeleComNumber_CountryCode
		,BusinessPhoneNumbers_TeleComNumber_AreaCode
		,BusinessPhoneNumbers_TeleComNumber_LocalNumber
		,MaritalStatus
		,Religion
		,SSN
		,EthnicGroups_EthnicGroup_OriginalNameCode
		,EthnicGroups_EthnicGroup_NameCode
		,Languages_Language_OriginalNameCode
		,Languages_Language_NameCode
		,DeathIndicator
		,EventType
	FROM ADTPatient
	WHERE EventType IN (
			'A01'
			,'A03'
			,'A04'
			,'A08'
			)

	INSERT INTO Stg_ADTVisit (
		Patient_PrimaryId_Id
		,SetId
		,PatientClass
		,AssignedPatientLocation_Facility
		,AssignedPatientLocation_Description
		,AdmissionType
		,AttendingDoctor_PersonIdentifier
		,AttendingDoctor_FamilyName
		,AttendingDoctor_GivenName
		,ReferringDoctor_PersonIdentifier
		,ReferringDoctor_FamilyName
		,ReferringDoctor_GivenName
		,HospitalService_Identifier
		,HospitalService_NameOfCodingSystem
		,HospitalService_NameOfAlternateCodingSystem
		,AdmittingDoctor_PersonIdentifier
		,AdmittingDoctor_FamilyName
		,AdmittingDoctor_GivenName
		,VisitNumber
		,AdmitDateTime
		,DischargeDateTime
		,AdmitReason_Identifier
		,AdmitReason_TEXT
		,AdmitReason_NameOfCodingSystem
		,AdmitReason_NameOfAlternateCodingSystem
		,ExpectedDischargeDateTime
		,LengthOfInPatientStay
		,EventType
		)
	SELECT DISTINCT Patient_PrimaryId_Id
		,SetId
		,PatientClass
		,AssignedPatientLocation_Facility
		,AssignedPatientLocation_Description
		,AdmissionType
		,AttendingDoctor_PersonIdentifier
		,AttendingDoctor_FamilyName
		,AttendingDoctor_GivenName
		,ReferringDoctor_PersonIdentifier
		,ReferringDoctor_FamilyName
		,ReferringDoctor_GivenName
		,HospitalService_Identifier
		,HospitalService_NameOfCodingSystem
		,HospitalService_NameOfAlternateCodingSystem
		,AdmittingDoctor_PersonIdentifier
		,AdmittingDoctor_FamilyName
		,AdmittingDoctor_GivenName
		,VisitNumber
		,AdmitDateTime
		,DischargeDateTime
		,AdmitReason_Identifier
		,AdmitReason_TEXT
		,AdmitReason_NameOfCodingSystem
		,AdmitReason_NameOfAlternateCodingSystem
		,ExpectedDischargeDateTime
		,LengthOfInPatientStay
		,EventType
	FROM ADTVisit
	WHERE EventType IN (
			'A01'
			,'A03'
			,'A04'
			,'A08'
			)

	INSERT INTO Stg_ADTInsuranceDetails (
		Patient_PrimaryId_Id
		,HealthPlanId_Identifier
		,HealthPlanId_NameOfCodingSystem
		,HealthPlanId_NameOfAlternateCodingSystem
		,InsuranceCompany_InsuranceCompanyId_Id
		,InsuranceCompany_InsuranceCompanyId_TypeCode
		,InsuranceCompany_InsuranceCompanyName
		,InsuranceCompany_InsuranceCompanyAddresses_Address_StreetAddress
		,InsuranceCompany_InsuranceCompanyAddresses_Address_City
		,InsuranceCompany_InsuranceCompanyAddresses_Address_StateOrProvince
		,InsuranceCompany_InsuranceCompanyAddresses_Address_ZipOrPostalCode
		,InsuranceCompany_InsuranceCompanyAddresses_Address_Country
		,InsuranceCompany_InsuranceCompanyAddresses_Address_AddressType
		,InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_EquipmentType
		,InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_CountryCode
		,InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_AreaCode
		,InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_LocalNumber
		,GroupNumber
		,GroupName_OrganizationName
		,InsuredGroupEmployerName
		,PlanEffectiveDate
		,PlanExpiryDate
		,PlanType_Identifier
		,InsuredNames_NAME_FamilyName
		,InsuredNames_NAME_GivenName
		,InsuredRelationshipToPatient
		,InsuredDateOfBirth
		,InsuredAddresses_Address_StreetAddress
		,InsuredAddresses_Address_City
		,InsuredAddresses_Address_StateOrProvince
		,InsuredAddresses_Address_ZipOrPostalCode
		,InsuredAddresses_Address_Country
		,InsuredAddresses_Address_AddressType
		,CompanyPlanCode_NameOfCodingSystem
		,CompanyPlanCode_NameOfAlternateCodingSystem
		,PolicyNumber
		,InsuredSSN
		,InsuredHomePhoneNumbers
		,PatientRelationshipToInsured
		,EventType
		)
	SELECT DISTINCT Patient_PrimaryId_Id
		,InsuranceDetail_HealthPlanId_Identifier
		,InsuranceDetail_HealthPlanId_NameOfCodingSystem
		,InsuranceDetail_HealthPlanId_NameOfAlternateCodingSystem
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyId_Id
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyId_TypeCode
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyName
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyAddresses_Address_StreetAddress
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyAddresses_Address_City
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyAddresses_Address_StateOrProvince
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyAddresses_Address_ZipOrPostalCode
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyAddresses_Address_Country
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyAddresses_Address_AddressType
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_EquipmentType
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_CountryCode
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_AreaCode
		,InsuranceDetail_InsuranceCompany_InsuranceCompanyPhoneNumbers_TeleComNumber_LocalNumber
		,InsuranceDetail_GroupNumber
		,InsuranceDetail_GroupName_OrganizationName
		,InsuranceDetail_InsuredGroupEmployerName
		,InsuranceDetail_PlanEffectiveDate
		,InsuranceDetail_PlanExpiryDate
		,InsuranceDetail_PlanType_Identifier
		,InsuranceDetail_InsuredNames_NAME_FamilyName
		,InsuranceDetail_InsuredNames_NAME_GivenName
		,InsuranceDetail_InsuredRelationshipToPatient
		,InsuranceDetail_InsuredDateOfBirth
		,InsuranceDetail_InsuredAddresses_Address_StreetAddress
		,InsuranceDetail_InsuredAddresses_Address_City
		,InsuranceDetail_InsuredAddresses_Address_StateOrProvince
		,InsuranceDetail_InsuredAddresses_Address_ZipOrPostalCode
		,InsuranceDetail_InsuredAddresses_Address_Country
		,InsuranceDetail_InsuredAddresses_Address_AddressType
		,InsuranceDetail_CompanyPlanCode_NameOfCodingSystem
		,InsuranceDetail_CompanyPlanCode_NameOfAlternateCodingSystem
		,InsuranceDetail_PolicyNumber
		,InsuranceDetail_InsuredSSN
		,InsuranceDetail_InsuredHomePhoneNumbers
		,InsuranceDetail_PatientRelationshipToInsured
		,EventType
	FROM ADTInsuranceDetails
	WHERE EventType IN (
			'A01'
			,'A03'
			,'A04'
			,'A08'
			)

	INSERT INTO Stg_ADTDiagnoses (
		Patient_PrimaryId_Id
		,Diagnosis_SetId
		,Diagnosis_CodingMethod
		,Diagnosis_Code_Identifier
		,Diagnosis_Code_Text
		,Diagnosis_Code_NameOfCodingSystem
		,Diagnosis_Code_NameOfAlternateCodingSystem
		,Diagnosis_DateTime
		,Diagnosis_Type_Identifier
		,Diagnosis_Type_NameOfCodingSystem
		,Diagnosis_Type_NameOfAlternateCodingSystem
		,Diagnosis_Clinician_PersonIdentifier
		,Diagnosis_Clinician_FamilyName
		,Diagnosis_Clinician_GivenName
		,EventType
		)
	SELECT DISTINCT Patient_PrimaryId_Id
		,Diagnosis_SetId
		,Diagnosis_CodingMethod
		,Diagnosis_Code_Identifier
		,Diagnosis_Code_Text
		,Diagnosis_Code_NameOfCodingSystem
		,Diagnosis_Code_NameOfAlternateCodingSystem
		,Diagnosis_DateTime
		,Diagnosis_Type_Identifier
		,Diagnosis_Type_NameOfCodingSystem
		,Diagnosis_Type_NameOfAlternateCodingSystem
		,Diagnosis_Clinician_PersonIdentifier
		,Diagnosis_Clinician_FamilyName
		,Diagnosis_Clinician_GivenName
		,EventType
	FROM ADTDiagnoses
	WHERE EventType IN (
			'A01'
			,'A03'
			,'A04'
			,'A08'
			)

	INSERT INTO Stg_ADTProcedures (
		Patient_PrimaryId_Id
		,Procedure_SetId
		,Procedure_CodingMethod
		,Procedure_Code_Identifier
		,Procedure_Code_Text
		,Procedure_Code_NameOfCodingSystem
		,Procedure_Code_NameOfAlternateCodingSystem
		,Procedure_DateTime
		,Procedure_CodeModifier_Identifier
		,Procedure_CodeModifier_Text
		,Procedure_CodeModifier_NameOfCodingSystem
		,Procedure_CodeModifier_NameOfAlternateCodingSystem
		,EventType
		)
	SELECT DISTINCT Patient_PrimaryId_Id
		,Procedure_SetId
		,Procedure_CodingMethod
		,Procedure_Code_Identifier
		,Procedure_Code_Text
		,Procedure_Code_NameOfCodingSystem
		,Procedure_Code_NameOfAlternateCodingSystem
		,Procedure_DateTime
		,Procedure_CodeModifier_Identifier
		,Procedure_CodeModifier_Text
		,Procedure_CodeModifier_NameOfCodingSystem
		,Procedure_CodeModifier_NameOfAlternateCodingSystem
		,EventType
	FROM ADTProcedures
	WHERE EventType IN (
			'A01'
			,'A03'
			,'A04'
			,'A08'
			)

	--INSERT INTO Stg_ADTPharmacy
	--(
	--Patient_PrimaryId_Id ,
	--NAME ,
	--Address_StreetAddress ,
	--Address_City ,
	--Address_StateOrProvince ,
	--Address_ZipOrPostalCode ,
	--Address_Country ,
	--Address_AddressType ,
	--IsPreferred ,
	--EmailAddress ,
	--EventType
	--)
	--SELECT DISTINCT 
	--Patient_PrimaryId_Id ,
	--NAME ,
	--Address_StreetAddress ,
	--Address_City ,
	--Address_StateOrProvince ,
	--Address_ZipOrPostalCode ,
	--Address_Country ,
	--Address_AddressType ,
	--IsPreferred ,
	--EmailAddress ,
	--EventType
	--FROM ADTPharmacy
	--WHERE EventType IN('A01','A03','A04','A08') 
	--INSERT INTO Stg_ADTGeneral
	--(
	--Patient_PrimaryId_Id ,
	--SendingApplication ,
	--SendingFacility ,
	--ReceivingApplication ,
	--ReceivingFacility ,
	--MsgDateTime ,
	--MessageType_MsgType ,
	--MessageType_Event ,
	--MessageControlId ,
	--ProcessingId ,
	--VersionId ,
	--SequenceNumber ,
	--EventDateTime ,
	--EventFacility ,
	--EventType
	--)
	--SELECT DISTINCT 
	--Patient_PrimaryId_Id ,
	--SendingApplication ,
	--SendingFacility ,
	--ReceivingApplication ,
	--ReceivingFacility ,
	--MsgDateTime ,
	--MessageType_MsgType ,
	--MessageType_Event ,
	--MessageControlId ,
	--ProcessingId ,
	--VersionId ,
	--SequenceNumber ,
	--EventDateTime ,
	--EventFacility ,
	--EventType
	--FROM ADTGeneral
	--WHERE EventType IN('A01','A03','A04','A08') 
	--INSERT INTO Stg_ADTEmergencyContact
	--(
	--Patient_PrimaryId_Id ,
	--Identifier ,
	--ContactName_FamilyName ,
	--ContactName_GivenName ,
	--ContactName_Suffix ,
	--ContactAddress_StreetAddress ,
	--ContactAddress_City ,
	--ContactAddress_StateOrProvince ,
	--ContactAddress_ZipOrPostalCode ,
	--ContactAddress_Country ,
	--ContactAddress_AddressType ,
	--HomePhoneNumber_UseCode ,
	--HomePhoneNumber_EquipmentType ,
	--HomePhoneNumber_CountryCode ,
	--HomePhoneNumber_AreaCode ,
	--HomePhoneNumber_LocalNumber ,
	--HomePhoneNumber_Extension ,
	--BusinessPhoneNumber_UseCode ,
	--BusinessPhoneNumber_EquipmentType ,
	--BusinessPhoneNumber_CountryCode ,
	--BusinessPhoneNumber_AreaCode ,
	--BusinessPhoneNumber_LocalNumber ,
	--BusinessPhoneNumber_Extension ,
	--MobileNumber_EquipmentType ,
	--MobileNumber_AreaCode ,
	--Relationship ,
	--EventType
	--)
	--SELECT DISTINCT
	--Patient_PrimaryId_Id ,
	--Identifier ,
	--ContactName_FamilyName ,
	--ContactName_GivenName ,
	--ContactName_Suffix ,
	--ContactAddress_StreetAddress ,
	--ContactAddress_City ,
	--ContactAddress_StateOrProvince ,
	--ContactAddress_ZipOrPostalCode ,
	--ContactAddress_Country ,
	--ContactAddress_AddressType ,
	--HomePhoneNumber_UseCode ,
	--HomePhoneNumber_EquipmentType ,
	--HomePhoneNumber_CountryCode ,
	--HomePhoneNumber_AreaCode ,
	--HomePhoneNumber_LocalNumber ,
	--HomePhoneNumber_Extension ,
	--BusinessPhoneNumber_UseCode ,
	--BusinessPhoneNumber_EquipmentType ,
	--BusinessPhoneNumber_CountryCode ,
	--BusinessPhoneNumber_AreaCode ,
	--BusinessPhoneNumber_LocalNumber ,
	--BusinessPhoneNumber_Extension ,
	--MobileNumber_EquipmentType ,
	--MobileNumber_AreaCode ,
	--Relationship ,
	--EventType
	--FROM ADTEmergencyContact
	--WHERE EventType IN('A01','A03','A04','A08') 
	-----------------------------------------------------------------------------------------------
	--SELECT * FROM CodeSetProviderType
	UPDATE Pa
	SET PatientPrimaryId = SP.Patient_PrimaryId_Id
	FROM Patient Pa
	INNER JOIN PatientInternalIdentifier PII ON Pa.PatientID = PII.PatientID
	INNER JOIN Stg_ADTPatient SP ON SP.SSN = Pa.SSN
		AND SP.DateOfBirth = Pa.DateOfBirth
		AND sp.Sex = Pa.Gender

	INSERT INTO Patient (
		[FirstName]
		,[LastName]
		,[SSN]
		,[DateOfBirth]
		,[Gender]
		,[MemberID]
		--,[DataSourceID]
		--,[DataSourceFileID]
		,[AccountStatusCode]
		,[CreatedByUserID]
		,[CreatedDate]
		,PatientPrimaryId
		)
	SELECT DISTINCT P.PatientNames_Name_FamilyName
		,P.PatientNames_Name_GivenName
		,P.SSN
		,P.DateOfBirth
		,P.Sex
		,P.Identifiers_Identifier_Id
		,'A'
		,1
		,GETDATE()
		,P.Patient_PrimaryId_Id
	FROM Stg_ADTPatient P
	WHERE NOT EXISTS (
			SELECT 1
			FROM PatientInternalIdentifier PII
			INNER JOIN Patient Pa ON Pa.PatientID = PII.PatientID
			WHERE PII.SSN = P.SSN
				AND Pa.DateOfBirth = P.DateOfBirth
				AND Pa.Gender = P.Sex
			)
		AND p.EventType IN (
			'A01'
			,'A03'
			,'A04'
			)

	INSERT INTO PatientInternalIdentifier (
		PatientID
		,SSN
		,Dep_Seq
		,StatusCode
		,CreatedByUserID
		,CreatedDate
		)
	SELECT P.PatientID
		,P.SSN
		,NULL
		,'A'
		,1
		,GETDATE()
	FROM Patient P
	WHERE NOT EXISTS (
			SELECT 1
			FROM PatientInternalIdentifier PII
			WHERE PII.PatientID = P.PatientID
			)

	UPDATE P
	SET [FirstName] = AP.PatientNames_Name_FamilyName
		,[LastName] = AP.PatientNames_Name_GivenName
		,[SSN] = AP.SSN
		,[DateOfBirth] = AP.DateOfBirth
		,[Gender] = AP.Sex
		,[MemberID] = AP.Identifiers_Identifier_Id
		,LastModifiedByUserID = 1
		,LastModifiedDate = GETDATE()
	FROM Patient P
	INNER JOIN Stg_ADTPatient AP ON P.PatientPrimaryId = AP.Patient_PrimaryId_Id

	INSERT INTO PatientInsurance (
		PatientID
		,InsuranceGroupPlanId
		,SuperGroupCategory
		,EmployerGroupID
		,StatusCode
		,PolicyNumber
		,SecondaryPolicyNumber
		,GroupNumber
		,PolicyHolderPatientID
		,PolicyHolderRelationID
		,CreatedByUserId
		,CreatedDate
		)
	SELECT DISTINCT p.PatientID
		,IGP.InsuranceGroupPlanId
		,NULL
		,NULL
		,--EG.EmployerGroupID ,
		'A'
		,SAID.PolicyNumber
		,NULL
		,SAID.GroupNumber
		,NULL
		,NULL
		,1
		,GETDATE()
	FROM Stg_ADTInsuranceDetails SAID
	INNER JOIN InsuranceGroup IG ON SAID.InsuranceCompany_InsuranceCompanyId_TypeCode = IG.InternalID
	INNER JOIN InsuranceGroupPlan IGP ON IG.InsuranceGroupID = IGP.InsuranceGroupId
		AND IGP.PlanName = SAID.PlanType_Identifier
	--INNER JOIN EmployerGroup EG
	--ON EG.GroupNumber = SAID.GroupNumber
	INNER JOIN Patient p ON P.PatientPrimaryId = SAID.Patient_PrimaryId_Id
	WHERE NOT EXISTS (
			SELECT 1
			FROM PatientInsurance PAI
			WHERE PAI.PatientID = p.PatientID
				AND PAI.InsuranceGroupPlanId = IGP.InsuranceGroupPlanId
				AND PAI.GroupNumber = SAID.GroupNumber
				AND PAI.PolicyNumber = SAID.PolicyNumber
			)

	DECLARE @InsuranceBenefitTypeID INT

	SET @InsuranceBenefitTypeID = (
			SELECT InsuranceBenefitTypeID
			FROM CCMV2SageACOINT.dbo.LKUPINSURANCEBENEFITTYPE
			WHERE BenefitTypeName = 'Major Medical (MM)'
			)

	INSERT INTO PatientInsuranceBenefit (
		PatientInsuranceID
		,InsuranceBenefitTypeID
		,BenfitTypeCode
		,IsPrimary
		,DateOfEligibility
		,CoverageEndsDate
		,CreatedByUserId
		,CreatedDate
		)
	SELECT DISTINCT PAI.PatientInsuranceID
		,@InsuranceBenefitTypeID
		,NULL
		,NULL
		,SAID.PlanEffectiveDate
		,SAID.PlanExpiryDate
		,1
		,GETDATE()
	FROM Stg_ADTInsuranceDetails SAID
	INNER JOIN Patient p ON P.PatientPrimaryId = SAID.Patient_PrimaryId_Id
	INNER JOIN InsuranceGroup IG ON SAID.InsuranceCompany_InsuranceCompanyId_TypeCode = IG.InternalID
	INNER JOIN InsuranceGroupPlan IGP ON IG.InsuranceGroupID = IGP.InsuranceGroupId
		AND IGP.PlanName = SAID.PlanType_Identifier
	INNER JOIN PatientInsurance PAI ON PAI.PatientID = P.PatientID
		AND PAI.InsuranceGroupPlanId = IGP.InsuranceGroupPlanId
	WHERE NOT EXISTS (
			SELECT 1
			FROM PatientInsuranceBenefit PIB
			WHERE PIB.PatientInsuranceID = PAI.PatientInsuranceID
				AND PIB.DateOfEligibility = SAID.PlanEffectiveDate
			)

	-----------------------------Patient Insurance-------------------------------------------
	---------------------------------PatientVist---------------------------------------------
	--INSERT INTO PatientADT
	--(
	--    PatientId,
	--    EventAdmitdate,
	--    EventDischargedate,
	--    IsReadmit,
	--    FacilityId,
	--    AdmitType,
	--    DischargeTo,
	--    RefferingDoctorId,
	--    AdmittingDoctorId,
	--    AttendingDoctorId,
	--    MessageAdmitdate,
	--    VisitAdmitdate,
	--    --MessageDischargedate,
	--    VisitDischargedate,
	--    CreatedByUserId,
	--    CreatedDate
	--)
	--SELECT DISTINCT
	--p.PatientID ,
	--NULL ,--SELECT CAST(SUBSTRING(AdmitDateTime,1,4) + '-' + SUBSTRING(AdmitDateTime,5,2) + '-' + SUBSTRING(AdmitDateTime,7,2) + ' ' + SUBSTRING(AdmitDateTime,9,2) + ':' + SUBSTRING(AdmitDateTime,11,2) + ':' + SUBSTRING(AdmitDateTime,13,2) AS DATETIME) ,
	--NULL ,--SELECT CAST(SUBSTRING(DischargeDateTime,1,4) + '-' + SUBSTRING(DischargeDateTime,5,2) + '-' + SUBSTRING(DischargeDateTime,7,2) + ' ' + SUBSTRING(DischargeDateTime,9,2) + ':' + SUBSTRING(DischargeDateTime,11,2) + ':' + SUBSTRING(DischargeDateTime,13,2) AS DATETIME) ,
	--NULL ,---AdmissionType
	--NULL , --AssignedPatientLocation_Facility ,
	--NULL , --PatientClass
	--NULL , --DischargeTo
	--NULL , --ReferringDoctor_FamilyName + ' ' + ReferringDoctor_GivenName
	--NULL , --AdmittingDoctor_FamilyName + ' ' + AdmittingDoctor_GivenName
	--NULL , --AttendingDoctor_FamilyName	+ ' ' + AttendingDoctor_GivenName
	--NULL , --Message AdmitDate
	--CAST(SUBSTRING(AdmitDateTime,1,4) + '-' + SUBSTRING(AdmitDateTime,5,2) + '-' + SUBSTRING(AdmitDateTime,7,2) + ' ' + SUBSTRING(AdmitDateTime,9,2) + ':' + SUBSTRING(AdmitDateTime,11,2) + ':' + SUBSTRING(AdmitDateTime,13,2) AS DATETIME) AS VistAdmitDate , 
	--CAST(SUBSTRING(DischargeDateTime,1,4) + '-' + SUBSTRING(DischargeDateTime,5,2) + '-' + SUBSTRING(DischargeDateTime,7,2) + ' ' + SUBSTRING(DischargeDateTime,9,2) + ':' + SUBSTRING(DischargeDateTime,11,2) + ':' + SUBSTRING(DischargeDateTime,13,2) AS DATETIME) AS VisitDischargedate ,
	--1 ,
	--GETDATE()
	--FROM Stg_ADTVisit PV
	--INNER JOIN Patient p
	--ON P.PatientPrimaryId = PV.Patient_PrimaryId_Id
	--WHERE PV.EventType IN ('A01','A04')
	--AND NOT EXISTS (SELECT 1
	--				FROM PatientADT PA
	--				WHERE PA.PatientId = P.PatientID
	--				AND PA.VisitAdmitdate = CAST(SUBSTRING(AdmitDateTime,1,4) + '-' + SUBSTRING(AdmitDateTime,5,2) + '-' + SUBSTRING(AdmitDateTime,7,2) + ' ' + SUBSTRING(AdmitDateTime,9,2) + ':' + SUBSTRING(AdmitDateTime,11,2) + ':' + SUBSTRING(AdmitDateTime,13,2) AS DATETIME))
	--------------------------------------------------------------------------------------------------------------------
	INSERT INTO PatientADT (
		PatientId
		,EventAdmitdate
		,EventDischargedate
		,IsReadmit
		,FacilityId
		,AdmitType
		,DischargeTo
		,RefferingDoctorId
		,AdmittingDoctorId
		,AttendingDoctorId
		,MessageAdmitdate
		,VisitAdmitdate
		,
		--MessageDischargedate,
		VisitDischargedate
		,CreatedByUserId
		,CreatedDate
		)
	SELECT DISTINCT p.PatientID
		,NULL
		,--SELECT CAST(SUBSTRING(AdmitDateTime,1,4) + '-' + SUBSTRING(AdmitDateTime,5,2) + '-' + SUBSTRING(AdmitDateTime,7,2) + ' ' + SUBSTRING(AdmitDateTime,9,2) + ':' + SUBSTRING(AdmitDateTime,11,2) + ':' + SUBSTRING(AdmitDateTime,13,2) AS DATETIME) ,
		NULL
		,--SELECT CAST(SUBSTRING(DischargeDateTime,1,4) + '-' + SUBSTRING(DischargeDateTime,5,2) + '-' + SUBSTRING(DischargeDateTime,7,2) + ' ' + SUBSTRING(DischargeDateTime,9,2) + ':' + SUBSTRING(DischargeDateTime,11,2) + ':' + SUBSTRING(DischargeDateTime,13,2) AS DATETIME) ,
		NULL
		,---AdmissionType
		NULL
		,--AssignedPatientLocation_Facility ,
		NULL
		,--PatientClass
		NULL
		,--DischargeTo
		NULL
		,--ReferringDoctor_FamilyName + ' ' + ReferringDoctor_GivenName
		NULL
		,--AdmittingDoctor_FamilyName + ' ' + AdmittingDoctor_GivenName
		NULL
		,--AttendingDoctor_FamilyName	+ ' ' + AttendingDoctor_GivenName
		NULL
		,--Message AdmitDate
		CAST(SUBSTRING(AdmitDateTime, 1, 4) + '-' + SUBSTRING(AdmitDateTime, 5, 2) + '-' + SUBSTRING(AdmitDateTime, 7, 2) + ' ' + SUBSTRING(AdmitDateTime, 9, 2) + ':' + SUBSTRING(AdmitDateTime, 11, 2) + ':' + SUBSTRING(AdmitDateTime, 13, 2) AS DATETIME) AS VistAdmitDate
		,CAST(SUBSTRING(DischargeDateTime, 1, 4) + '-' + SUBSTRING(DischargeDateTime, 5, 2) + '-' + SUBSTRING(DischargeDateTime, 7, 2) + ' ' + SUBSTRING(DischargeDateTime, 9, 2) + ':' + SUBSTRING(DischargeDateTime, 11, 2) + ':' + SUBSTRING(DischargeDateTime, 13, 2) AS DATETIME) AS VisitDischargedate
		,1
		,GETDATE()
	FROM Stg_ADTVisit PV
	INNER JOIN Patient p ON P.PatientPrimaryId = PV.Patient_PrimaryId_Id
	WHERE --PV.EventType = 'A03'
		--AND 
		NOT EXISTS (
			SELECT 1
			FROM PatientADT PA
			WHERE PA.PatientId = P.PatientID
				AND PA.VisitAdmitdate = CAST(SUBSTRING(AdmitDateTime, 1, 4) + '-' + SUBSTRING(AdmitDateTime, 5, 2) + '-' + SUBSTRING(AdmitDateTime, 7, 2) + ' ' + SUBSTRING(AdmitDateTime, 9, 2) + ':' + SUBSTRING(AdmitDateTime, 11, 2) + ':' + SUBSTRING(AdmitDateTime, 13, 2) AS DATETIME)
			)

	UPDATE PA
	SET DischargeTo = NULL
		,VisitDischargedate = CAST(SUBSTRING(DischargeDateTime, 1, 4) + '-' + SUBSTRING(DischargeDateTime, 5, 2) + '-' + SUBSTRING(DischargeDateTime, 7, 2) + ' ' + SUBSTRING(DischargeDateTime, 9, 2) + ':' + SUBSTRING(DischargeDateTime, 11, 2) + ':' + SUBSTRING(DischargeDateTime, 13, 2) AS DATETIME)
		,LastModifiedUserId = 1
		,LastModifiedDate = GETDATE()
	FROM PatientADT PA
	INNER JOIN Patient p ON P.PatientID = PA.PatientId
	INNER JOIN Stg_ADTVisit AV ON AV.Patient_PrimaryId_Id = P.PatientPrimaryId
		AND PA.VisitAdmitdate = CAST(SUBSTRING(AdmitDateTime, 1, 4) + '-' + SUBSTRING(AdmitDateTime, 5, 2) + '-' + SUBSTRING(AdmitDateTime, 7, 2) + ' ' + SUBSTRING(AdmitDateTime, 9, 2) + ':' + SUBSTRING(AdmitDateTime, 11, 2) + ':' + SUBSTRING(AdmitDateTime, 13, 2) AS DATETIME)
	WHERE AV.EventType = 'A03'

	----------------------------------------------PatientADT----------------------------------------------------
	----------------------------------------------PatientProcedures---------------------------------------------
	INSERT INTO PatientADTProcedure (
		PatientADTId
		,ProcedureCodeId
		,RendaringProviderId
		,CreatedByUserId
		,CreatedDate
		,ProcedureDate
		)
	SELECT DISTINCT pa.PatientADTId
		,csp.ProcedureCodeID
		,NULL
		,1
		,GETDATE()
		,CAST(SUBSTRING(AP.Procedure_DateTime, 1, 4) + '-' + SUBSTRING(AP.Procedure_DateTime, 5, 2) + '-' + SUBSTRING(AP.Procedure_DateTime, 7, 2) + ' ' + SUBSTRING(AP.Procedure_DateTime, 9, 2) + ':' + SUBSTRING(AP.Procedure_DateTime, 11, 2) + ':' + SUBSTRING(AP.Procedure_DateTime, 13, 2) AS DATETIME)
	FROM Stg_ADTProcedures AP
	INNER JOIN Patient p ON P.PatientPrimaryId = AP.Patient_PrimaryId_Id
	INNER JOIN PatientADT pa ON PA.PatientId = P.PatientID
	INNER JOIN CodeSetProcedure csp ON AP.Procedure_Code_Identifier = csp.ProcedureCode
	WHERE CAST(SUBSTRING(AP.Procedure_DateTime, 1, 4) + '-' + SUBSTRING(AP.Procedure_DateTime, 5, 2) + '-' + SUBSTRING(AP.Procedure_DateTime, 7, 2) + ' ' + SUBSTRING(AP.Procedure_DateTime, 9, 2) + ':' + SUBSTRING(AP.Procedure_DateTime, 11, 2) + ':' + SUBSTRING(AP.Procedure_DateTime, 13, 2) AS DATETIME) BETWEEN PA.VisitAdmitdate
			AND PA.VisitDischargedate
		AND NOT EXISTS (
			SELECT 1
			FROM PatientADTProcedure PAD
			WHERE PAD.PatientADTId = PA.PatientADTId
				AND PAD.ProcedureCodeId = CSP.ProcedureCodeID
				AND PAD.ProcedureDate = CAST(SUBSTRING(AP.Procedure_DateTime, 1, 4) + '-' + SUBSTRING(AP.Procedure_DateTime, 5, 2) + '-' + SUBSTRING(AP.Procedure_DateTime, 7, 2) + ' ' + SUBSTRING(AP.Procedure_DateTime, 9, 2) + ':' + SUBSTRING(AP.Procedure_DateTime, 11, 2) + ':' + SUBSTRING(AP.Procedure_DateTime, 13, 2) AS DATETIME)
			)

	-------------------------------------------------PatientADTProcedure-------------------------------------------------------------------------
	-------------------------------------------------PatientADTDiagnosis-------------------------------------------------------------------------
	INSERT INTO PatientADTDiagnosis (
		PatientADTId
		,DiagnosisCodeId
		,CreatedByUserId
		,CreatedDate
		,DiagnosedDate
		)
	SELECT DISTINCT pa.PatientADTId
		,csi.DiagnosisCodeID
		,1
		,GETDATE()
		,CAST(SUBSTRING(AD.Diagnosis_DateTime, 1, 4) + '-' + SUBSTRING(AD.Diagnosis_DateTime, 5, 2) + '-' + SUBSTRING(AD.Diagnosis_DateTime, 7, 2) + ' ' + SUBSTRING(AD.Diagnosis_DateTime, 9, 2) + ':' + SUBSTRING(AD.Diagnosis_DateTime, 11, 2) + ':' + SUBSTRING(AD.Diagnosis_DateTime, 13, 2) AS DATETIME)
	FROM Stg_ADTDiagnoses AD
	INNER JOIN Patient p ON P.PatientPrimaryId = AD.Patient_PrimaryId_Id
	INNER JOIN PatientADT pa ON PA.PatientId = P.PatientID
	INNER JOIN CodeSetICDDiagnosis csi ON AD.Diagnosis_Code_Identifier = csi.DiagnosisCode
	WHERE CAST(SUBSTRING(AD.Diagnosis_DateTime, 1, 4) + '-' + SUBSTRING(AD.Diagnosis_DateTime, 5, 2) + '-' + SUBSTRING(AD.Diagnosis_DateTime, 7, 2) + ' ' + SUBSTRING(AD.Diagnosis_DateTime, 9, 2) + ':' + SUBSTRING(AD.Diagnosis_DateTime, 11, 2) + ':' + SUBSTRING(AD.Diagnosis_DateTime, 13, 2) AS DATETIME) BETWEEN PA.VisitAdmitdate
			AND PA.VisitDischargedate
		AND NOT EXISTS (
			SELECT 1
			FROM PatientADTDiagnosis PAD
			WHERE PAD.PatientADTId = PA.PatientADTId
				AND PAD.DiagnosisCodeId = csi.DiagnosisCodeID
				AND PAD.DiagnosedDate = CAST(SUBSTRING(AD.Diagnosis_DateTime, 1, 4) + '-' + SUBSTRING(AD.Diagnosis_DateTime, 5, 2) + '-' + SUBSTRING(AD.Diagnosis_DateTime, 7, 2) + ' ' + SUBSTRING(AD.Diagnosis_DateTime, 9, 2) + ':' + SUBSTRING(AD.Diagnosis_DateTime, 11, 2) + ':' + SUBSTRING(AD.Diagnosis_DateTime, 13, 2) AS DATETIME)
			)

	-------------------------------------------------PatientADTModifier-----------------------------------------------------------------
	SELECT *
	FROM PatientADT

	INSERT INTO PatientADTModifier (
		PatientADTId
		,ProcedureCodeModifierID
		,CreatedByUserId
		,CreatedDate
		)
	SELECT DISTINCT pa.PatientADTId
		,csm.ProcedureCodeModifierId
		,1
		,GETDATE()
	FROM Stg_ADTProcedures AP
	INNER JOIN Patient p ON P.PatientPrimaryId = AP.Patient_PrimaryId_Id
	INNER JOIN PatientADT pa ON PA.PatientId = P.PatientID
	INNER JOIN CodeSetProcedureModifier csm ON AP.Procedure_CodeModifier_Identifier = csm.ProcedureCodeModifierCode
	WHERE CAST(SUBSTRING(AP.Procedure_DateTime, 1, 4) + '-' + SUBSTRING(AP.Procedure_DateTime, 5, 2) + '-' + SUBSTRING(AP.Procedure_DateTime, 7, 2) + ' ' + SUBSTRING(AP.Procedure_DateTime, 9, 2) + ':' + SUBSTRING(AP.Procedure_DateTime, 11, 2) + ':' + SUBSTRING(AP.Procedure_DateTime, 13, 2) AS DATETIME) BETWEEN PA.VisitAdmitdate
			AND PA.VisitDischargedate
		AND NOT EXISTS (
			SELECT 1
			FROM PatientADTModifier cam
			WHERE cam.PatientADTId = pa.PatientADTId
				AND cam.ProcedureCodeModifierID = csm.ProcedureCodeModifierId
			)
		-------------------------------------------------PatientADTModifier-----------------------------------------------------------------
END TRY

BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

