//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace MEDSEEK.Navigate.Database.Context
{
    using System;
    
    public partial class ufn_HEDIS_GetPatients_EncouterClaims_ByProcedure2_SelectedPopulation_Result
    {
        public int PatientID { get; set; }
        public int ClaimInfoId { get; set; }
        public string ClaimNumber { get; set; }
        public int EDIClaimTypeID { get; set; }
        public string EDIClaimTypeCode { get; set; }
        public string EDIClaimTypeName { get; set; }
        public Nullable<int> TypeOfBillCodeID { get; set; }
        public string TypeOfBillCode { get; set; }
        public Nullable<int> AdmissionTypeCodeID { get; set; }
        public string AdmissionTypeCode { get; set; }
        public string AdmissionType { get; set; }
        public Nullable<int> EmployerGroupID { get; set; }
        public Nullable<int> InsuranceGroupID { get; set; }
        public Nullable<int> MemberID { get; set; }
        public Nullable<int> PolicyNumber { get; set; }
        public Nullable<int> MedicalRecordNumber { get; set; }
        public Nullable<int> PatientControlNumber { get; set; }
        public Nullable<int> DocumentControlNumber { get; set; }
        public Nullable<int> ClaimStatusCodeID { get; set; }
        public string ClaimStatusCode { get; set; }
        public Nullable<int> PatientStatusCodeID { get; set; }
        public string PatientStatusCode { get; set; }
        public string PatientStatus { get; set; }
        public Nullable<int> AdmissionSourceCodeID { get; set; }
        public string AdmissionSourceCode { get; set; }
        public string AdmissionSource { get; set; }
        public Nullable<int> ClaimSourceCodeID { get; set; }
        public string ClaimSourceCode { get; set; }
        public Nullable<int> MDCCodeID { get; set; }
        public string MDCCode { get; set; }
        public Nullable<int> MSDRGCodeID { get; set; }
        public string MSDRGCode { get; set; }
        public Nullable<int> DRGCodeID { get; set; }
        public string DRGCode { get; set; }
        public Nullable<int> APRDRGCodeID { get; set; }
        public string APRDRGCode { get; set; }
        public Nullable<int> APCCodeID { get; set; }
        public string APCCode { get; set; }
        public Nullable<System.DateTime> StatementDateFrom { get; set; }
        public Nullable<System.DateTime> StatementDateTo { get; set; }
        public Nullable<System.DateTime> DateOfAdmit { get; set; }
        public Nullable<System.DateTime> DateOfDischarge { get; set; }
        public Nullable<int> EnteredDate { get; set; }
        public Nullable<int> ReceivedDate { get; set; }
        public Nullable<System.DateTime> PaidDate { get; set; }
        public Nullable<int> IncurredDate { get; set; }
        public Nullable<int> ClaimProcessedDate { get; set; }
        public Nullable<short> LengthOfStay { get; set; }
        public Nullable<System.DateTime> PaidDays { get; set; }
        public Nullable<int> ClaimProcedureID { get; set; }
        public Nullable<int> ICDProcedureCodeID { get; set; }
        public string ICDProcedureCode { get; set; }
        public string ICDProcedureCodeType { get; set; }
        public Nullable<byte> ICDProcedureCodeRankOrder { get; set; }
        public Nullable<int> ClaimDataSourceID { get; set; }
        public string ClaimDataSourceName { get; set; }
        public Nullable<int> ClaimDataSourceFileID { get; set; }
        public string ClaimDataSourceFileName { get; set; }
        public string ClaimDataSourceFileLocation { get; set; }
        public Nullable<int> ClaimRecordTag_FileID { get; set; }
        public int ClaimCreatedByUserID { get; set; }
        public System.DateTime ClaimCreatedDate { get; set; }
        public Nullable<int> ClaimLastModifiedByUserID { get; set; }
        public Nullable<System.DateTime> ClaimLastModifiedDate { get; set; }
        public Nullable<int> ClaimLineID { get; set; }
        public Nullable<int> ProcedureCodeID { get; set; }
        public string ProcedureCode { get; set; }
        public string ProcedureName { get; set; }
        public string ProcedureCodeType { get; set; }
        public Nullable<int> ClaimLineDiagnosisID { get; set; }
        public Nullable<int> ICDDiagnosisCodeID { get; set; }
        public string ICDDiagnosisCode { get; set; }
        public string ICDDiagnosisCodeType { get; set; }
        public Nullable<int> ICDDiagnosisPurposeCodeID { get; set; }
        public string ICDDiagnosisPurposeCode { get; set; }
        public Nullable<byte> ICDDiagnosisCodeRankOrder { get; set; }
        public Nullable<int> RevenueCodeID { get; set; }
        public string RevenueCode { get; set; }
        public Nullable<int> PlaceOfServiceCodeID { get; set; }
        public string PlaceOfServiceCode { get; set; }
        public string PlaceOfServiceName { get; set; }
        public Nullable<int> ServiceTypeCodeID { get; set; }
        public string ServiceTypeCode { get; set; }
        public string ServiceTypeName { get; set; }
        public Nullable<System.DateTime> BeginServiceDate { get; set; }
        public Nullable<System.DateTime> EndServiceDate { get; set; }
        public Nullable<int> ClaimLineDataSourceID { get; set; }
        public string ClaimLineDataSourceName { get; set; }
        public Nullable<int> ClaimLineDataSourceFileID { get; set; }
        public string ClaimLineDataSourceFileName { get; set; }
        public string ClaimLineDataSourceFileLocation { get; set; }
        public string ClaimLineRecordTag_FileID { get; set; }
        public Nullable<int> ClaimLineCreatedByUserID { get; set; }
        public Nullable<System.DateTime> ClaimLineCreatedDate { get; set; }
        public Nullable<int> ClaimLineLastModifiedByUserID { get; set; }
        public Nullable<System.DateTime> ClaimLineLastModifiedDate { get; set; }
    }
}
