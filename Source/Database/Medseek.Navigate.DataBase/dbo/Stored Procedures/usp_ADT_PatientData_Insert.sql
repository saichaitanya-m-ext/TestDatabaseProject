-- drop procedure usp_PatientData_Insert
CREATE PROCEDURE [dbo].[usp_ADT_PatientData_Insert] (
	-- @tblVisit tblVisit READONLY
	--,@tblProcedure tblProcedure READONLY
	--,@tblPatient tblPatient READONLY
	--,@tblGuarantor tblGuarantor READONLY
	--,@tblGeneral tblGeneral READONLY
	--,@tblDiagnosis tblDiagnosis READONLY
	--,@tblDemographics tblDemographics READONLY
	--,@tblEmergencyContact tblEmergencyContact READONLY
	--,@tblExtendedData tblExtendedData READONLY
	--,@tblInsuranceDetails tblInsuranceDetails READONLY
	--,@tblPharmacy tblPharmacy READONLY
	--,@tblPhysicianRole tblPhysicianRole READONLY
	--1.General
	@tblGeneral tblADTGeneral READONLY
	--2.Patient
	,@tblPatient tblADTPatient READONLY
	--3.Visit
	,@tblVisit tblADTVisit READONLY
	--4.Gurantor
	--,@tblGuarantor tblGuarantor READONLY
	--5.InsuranceDetails
	,@tblInsuranceDetails tblADTInsuranceDetails READONLY
	--6.CustomDemographics
	--,@tblDemographics tblDemographics READONLY
	--7.EmergencyContact
	,@tblEmergencyContact tblADTEmergencyContact READONLY
	--8.CustomPharmacies
	--,@tblPharmacy tblADTPharmacy READONLY
	--9.PhysicianRoles
	--,@tblPhysicianRole tblPhysicianRole READONLY
	--10.Diagnosis
	,@tblDiagnosis tblADTDiagnoses READONLY
	--11.Procedures
	,@tblProcedure tblADTProcedures READONLY
	--12.ExtendedData
	--,@tblExtendedData tblExtendedData READONLY
	,@Status int OutPut
	)
AS
BEGIN TRAN

BEGIN TRY

	DECLARE @PatientID VARCHAR(100),
	        @PatientEventType VARCHAR(100)

	SET @PatientID = (
			SELECT DISTINCT Patient_PrimaryId_Id
			FROM @tblPatient
			)
	SET @PatientEventType = (
			SELECT DISTINCT MessageType_Event
			FROM @tblGeneral
			)
	IF EXISTS (
			SELECT 1
			FROM @tblPatient
			)
	BEGIN
		INSERT INTO ADTPatient (
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
		SELECT Patient_PrimaryId_Id
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
			,@PatientEventType
		FROM @tblPatient
	END

	

	IF EXISTS (
			SELECT 1
			FROM @tblVisit
			)
	BEGIN
		INSERT INTO ADTVisit (
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
			,[ConsultingDoctor] 
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
		SELECT @PatientID
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
			,[ConsultingDoctor]
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
			,@PatientEventType
		FROM @tblVisit
	END

	IF EXISTS (
			SELECT 1
			FROM @tblProcedure
			)
	BEGIN
		INSERT INTO ADTProcedures (
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
		SELECT @PatientID
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
			,@PatientEventType
		FROM @tblProcedure
	END

	--IF EXISTS (
	--		SELECT 1
	--		FROM @tblGuarantor
	--		)
	--BEGIN
	--	INSERT INTO ADTGuarantor (
	--		Patient_SetID
	--		,SetId
	--		,GuarantorNumber_ID
	--		,GuarantorNumber_TypeCode
	--		,GuarantorNumber_AssigningFacility
	--		,Guarantor_FamilyName
	--		,Guarantor_GivenName
	--		,Guarantor_FurtherGivenName
	--		,Guarantor_Suffix
	--		,Guarantor_Prefix
	--		,Guarantor_StreetAddress
	--		,Guarantor_OtherDesignation
	--		,Guarantor_City
	--		,Guarantor_StateOrProvince
	--		,Guarantor_ZipOrPostalCode
	--		,Guarantor_Country
	--		,Guarantor_AddressType
	--		,HomePhoneNumber_UseCode
	--		,HomePhoneNumber_EquipmentType
	--		,HomePhoneNumber_CommAddress
	--		,HomePhoneNumber_CountryCode
	--		,HomePhoneNumber_AreaCode
	--		,HomePhoneNumber_LocalNumber
	--		,HomePhoneNumber_Extension
	--		,BusinessPhoneNumber_UseCode
	--		,BusinessPhoneNumber_EquipmentType
	--		,BusinessPhoneNumber_CommAddress
	--		,BusinessPhoneNumber_CountryCode
	--		,BusinessPhoneNumber_AreaCode
	--		,BusinessPhoneNumber_LocalNumber
	--		,BusinessPhoneNumber_Extension
	--		,DateOfBirth
	--		,Sex
	--		,Relationship
	--		,SSN
	--		,GuarantorPriority
	--		,Employer_EmployerID_ID
	--		,Employer_EmployerID_TypeCode
	--		,Employer_EmployerID_AssigningFacility
	--		,Employer_OrganizationName
	--		,Employer_OrganizationTypeCode
	--		,EmployerAddresses_StreetAddress
	--		,EmployerAddresses_OtherDesignation
	--		,EmployerAddresses_City
	--		,EmployerAddresses_StateOrProvince
	--		,EmployerAddresses_ZipOrPostalCode
	--		,EmployerAddresses_Country
	--		,EmployerAddresses_AddressType
	--		,EmployerPhoneNumbers_UseCode
	--		,EmployerPhoneNumbers_EquipmentType
	--		,EmployerPhoneNumbers_CommAddress
	--		,EmployerPhoneNumbers_CountryCode
	--		,EmployerPhoneNumbers_AreaCode
	--		,EmployerPhoneNumbers_LocalNumber
	--		,EmployerPhoneNumbers_Extension
	--		)
	--	SELECT @PatientSetID
	--		,[SetId]
	--		,[GuarantorNumber_Id]
	--		,[GuarantorNumber_TypeCode]
	--		,[GuarantorNumber_AssigningFacility]
	--		,[GuarantorName_FamilyName]
	--		,[GuarantorName_GivenName]
	--		,[GuarantorName_FurtherGivenName]
	--		,[GuarantorName_Suffix]
	--		,[GuarantorName_Prefix]
	--		,[Addresses_StreetAddress]
	--		,[Addresses_OtherDesignation]
	--		,[Addresses_City]
	--		,[Addresses_StateOrProvince]
	--		,[Addresses_ZipOrPostalCode]
	--		,[Addresses_Country]
	--		,[Addresses_AddressType]
	--		,[HomePhoneNumbers_UseCode]
	--		,[HomePhoneNumbers_EquipmentType]
	--		,[HomePhoneNumbers_CommAddress]
	--		,[HomePhoneNumbers_CountryCode]
	--		,[HomePhoneNumbers_AreaCode]
	--		,[HomePhoneNumbers_LocalNumber]
	--		,[HomePhoneNumbers_Extension]
	--		,[BusinessPhoneNumbers_UseCode]
	--		,[BusinessPhoneNumbers_EquipmentType]
	--		,[BusinessPhoneNumbers_CommAddress]
	--		,[BusinessPhoneNumbers_CountryCode]
	--		,[BusinessPhoneNumbers_AreaCode]
	--		,[BusinessPhoneNumbers_LocalNumber]
	--		,[BusinessPhoneNumbers_Extension]
	--		,[DateOfBirth]
	--		,[Sex]
	--		,[Relationship]
	--		,[SSN]
	--		,[GuarantorPriority]
	--		,[Id]
	--		,[TypeCode]
	--		,[AssigningFacility]
	--		,[OrganizationName]
	--		,[OrganizationTypeCode]
	--		,[EmployerAddresses_StreetAddress]
	--		,[EmployerAddresses_OtherDesignation]
	--		,[EmployerAddresses_City]
	--		,[EmployerAddresses_StateOrProvince]
	--		,[EmployerAddresses_ZipOrPostalCode]
	--		,[EmployerAddresses_Country]
	--		,[EmployerAddresses_AddressType]
	--		,[EmployerPhoneNumbers_UseCode]
	--		,[EmployerPhoneNumbers_EquipmentType]
	--		,[EmployerPhoneNumbers_CommAddress]
	--		,[EmployerPhoneNumbers_CountryCode]
	--		,[EmployerPhoneNumbers_AreaCode]
	--		,[EmployerPhoneNumbers_LocalNumber]
	--		,[EmployerPhoneNumbers_Extension]
	--	FROM @tblGuarantor
	--END
	IF EXISTS (
			SELECT 1
			FROM @tblGeneral
			)
	BEGIN
		INSERT INTO ADTGeneral (
			Patient_PrimaryId_Id
			,SendingApplication
			,SendingFacility
			,ReceivingApplication
			,ReceivingFacility
			,MsgDateTime
			,MessageType_MsgType
			,MessageType_Event
			,MessageControlId
			,ProcessingId
			,VersionId
			,SequenceNumber
			,EventDateTime
			,EventFacility
			)
		SELECT @PatientID
			,SendingApplication
			,SendingFacility
			,ReceivingApplication
			,ReceivingFacility
			,MsgDateTime
			,MessageType_MsgType
			,MessageType_Event
			,MessageControlId
			,ProcessingId
			,VersionId
			,SequenceNumber
			,EventDateTime
			,EventFacility
		FROM @tblGeneral
	END

	IF EXISTS (
			SELECT 1
			FROM @tblDiagnosis
			)
	BEGIN
		INSERT INTO ADTDiagnoses (
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
		SELECT @PatientID
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
			,@PatientEventType
		FROM @tblDiagnosis
	END

	--IF EXISTS (
	--		SELECT 1
	--		FROM @tblDemographics
	--		)
	--BEGIN
	--	INSERT INTO ADTDemographics (
	--		Patient_SetID
	--		,EnrollmentPIN
	--		,PatientEmailAddress
	--		,OverrideAgeOfMajority
	--		,OverrideAccountHolderMinimumAge
	--		,PatientWorkAddress_StreetAddress
	--		,PatientWorkAddress_OtherDesignation
	--		,PatientWorkAddress_City
	--		,PatientWorkAddress_StateOrProvince
	--		,PatientWorkAddress_ZipOrPostalCode
	--		,PatientWorkAddress_Country
	--		,PatientWorkAddress_AddressType
	--		,FacilityPIN_ID
	--		,FacilityPIN_TypeCode
	--		,FacilityPIN_AssigningFacility
	--		)
	--	SELECT @PatientSetID
	--		,EnrollmentPIN
	--		,PatientEmailAddress
	--		,OverrideAgeOfMajority
	--		,OverrideAccountHolderMinimumAge
	--		,PatientWorkAddress_StreetAddress
	--		,PatientWorkAddress_OtherDesignation
	--		,PatientWorkAddress_City
	--		,PatientWorkAddress_StateOrProvince
	--		,PatientWorkAddress_ZipOrPostalCode
	--		,PatientWorkAddress_Country
	--		,PatientWorkAddress_AddressType
	--		,FacilityPINs_Identifier_ID
	--		,FacilityPINs_Identifier_TypeCode
	--		,FacilityPINs_Identifier_AssigningFacility
	--	FROM @tblDemographics
	--END
	IF EXISTS (
			SELECT 1
			FROM @tblEmergencyContact
			)
	BEGIN
		INSERT INTO ADTEmergencyContact (
			Patient_PrimaryId_Id
			,	Identifier
,	ContactName_FamilyName
,	ContactName_GivenName
,	ContactName_Suffix
,	ContactAddress_StreetAddress
,	ContactAddress_City
,	ContactAddress_StateOrProvince
,	ContactAddress_ZipOrPostalCode
,	ContactAddress_Country
,	ContactAddress_AddressType
,	HomePhoneNumber_UseCode
,	HomePhoneNumber_EquipmentType
,	HomePhoneNumber_CountryCode
,	HomePhoneNumber_AreaCode
,	HomePhoneNumber_LocalNumber
,	HomePhoneNumber_Extension
,	BusinessPhoneNumber_UseCode
,	BusinessPhoneNumber_EquipmentType
,	BusinessPhoneNumber_CountryCode
,	BusinessPhoneNumber_AreaCode
,	BusinessPhoneNumber_LocalNumber
,	BusinessPhoneNumber_Extension
,	MobileNumber_EquipmentType
,	MobileNumber_AreaCode
,	Relationship
,	EmailAddress
,EventType
			)
		SELECT @PatientID
			,	Identifier
,	ContactName_FamilyName
,	ContactName_GivenName
,	ContactName_Suffix
,	ContactAddress_StreetAddress
,	ContactAddress_City
,	ContactAddress_StateOrProvince
,	ContactAddress_ZipOrPostalCode
,	ContactAddress_Country
,	ContactAddress_AddressType
,	HomePhoneNumber_UseCode
,	HomePhoneNumber_EquipmentType
,	HomePhoneNumber_CountryCode
,	HomePhoneNumber_AreaCode
,	HomePhoneNumber_LocalNumber
,	HomePhoneNumber_Extension
,	BusinessPhoneNumber_UseCode
,	BusinessPhoneNumber_EquipmentType
,	BusinessPhoneNumber_CountryCode
,	BusinessPhoneNumber_AreaCode
,	BusinessPhoneNumber_LocalNumber
,	BusinessPhoneNumber_Extension
,	MobileNumber_EquipmentType
,	MobileNumber_AreaCode
,	Relationship
,	EmailAddress
,@PatientEventType
		FROM @tblEmergencyContact
	END
	IF EXISTS (
			SELECT 1
			FROM @tblInsuranceDetails
			)
	BEGIN
		INSERT INTO ADTInsuranceDetails (
			Patient_PrimaryId_Id
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
			)
		SELECT @PatientID
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
			,@PatientEventType
		FROM @tblInsuranceDetails
	END

	--IF EXISTS (
	--		SELECT 1
	--		FROM @tblPhysicianRole
	--		)
	--BEGIN
	--	INSERT INTO [ADTPhysicianRole] (
	--		Patient_SetID
	--		,[ActionCode]
	--		,[Role]
	--		,[PhysicianNames_PersonIdentifier]
	--		,[PhysicianNames_FamilyName]
	--		,[PhysicianNames_GivenName]
	--		,[PhysicianNames_FurtherGivenName]
	--		,[PhysicianNames_Suffix]
	--		,[PhysicianNames_Prefix]
	--		,[PhysicianNames_Degree]
	--		,[PersonLocation_PointOfCare]
	--		,[PersonLocation_Room]
	--		,[PersonLocation_Bed]
	--		,[PersonLocation_Facility]
	--		,[PersonLocation_LocationStatus]
	--		,[PersonLocation_PersonLocationType]
	--		,[PersonLocation_Building]
	--		,[PersonLocation_Floor]
	--		,[PersonLocation_LocationDescription]
	--		,[PersonLocation_ComprehensiveLocationIdentifier]
	--		,[PersonLocation_AssigningAuthorityForLocation]
	--		)
	--	SELECT @PatientSetID
	--		,[ActionCode]
	--		,[Role]
	--		,[PhysicianNames_PersonIdentifier]
	--		,[PhysicianNames_FamilyName]
	--		,[PhysicianNames_GivenName]
	--		,[PhysicianNames_FurtherGivenName]
	--		,[PhysicianNames_Suffix]
	--		,[PhysicianNames_Prefix]
	--		,[PhysicianNames_Degree]
	--		,[PersonLocation_PointOfCare]
	--		,[PersonLocation_Room]
	--		,[PersonLocation_Bed]
	--		,[PersonLocation_Facility]
	--		,[PersonLocation_LocationStatus]
	--		,[PersonLocation_PersonLocationType]
	--		,[PersonLocation_Building]
	--		,[PersonLocation_Floor]
	--		,[PersonLocation_LocationDescription]
	--		,[PersonLocation_ComprehensiveLocationIdentifier]
	--		,[PersonLocation_AssigningAuthorityForLocation]
	--	FROM @tblPhysicianRole
	--END
	--IF EXISTS (
	--		SELECT 1
	--		FROM @tblPharmacy
	--		)
	--BEGIN
	--	INSERT INTO ADTPharmacy (
	--		Patient_PrimaryId_Id
	--		,NAME
	--		,Address_StreetAddress
	--		,Address_City
	--		,Address_StateOrProvince
	--		,Address_ZipOrPostalCode
	--		,Address_Country
	--		,Address_AddressType
	--		,IsPreferred
	--		,EmailAddress
	--		)
	--	SELECT @PatientID
	--		,NAME
	--		,Address_StreetAddress
	--		,Address_City
	--		,Address_StateOrProvince
	--		,Address_ZipOrPostalCode
	--		,Address_Country
	--		,Address_AddressType
	--		,IsPreferred
	--		,EmailAddress
	--	FROM @tblPharmacy
	--END
	--IF EXISTS (
	--		SELECT 1
	--		FROM @tblExtendedData
	--		)
	--BEGIN
	--	INSERT INTO [ADTExtendedData] (
	--		Patient_SetID
	--		,[ExtendedSource]
	--		,[ExtendedKey]
	--		,[Data]
	--		,[OnDemand]
	--		)
	--	SELECT @PatientSetID
	--		,[ExtendedSource]
	--		,[ExtendedKey]
	--		,[Data]
	--		,[OnDemand]
	--	FROM @tblExtendedData
	--END
	
		set @Status=1
	COMMIT TRAN
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	set @Status=0
	RETURN ERROR_MESSAGE()

	RETURN ERROR_PROCEDURE()
END CATCH
