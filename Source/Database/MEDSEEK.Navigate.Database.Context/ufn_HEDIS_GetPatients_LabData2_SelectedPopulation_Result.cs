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
    
    public partial class ufn_HEDIS_GetPatients_LabData2_SelectedPopulation_Result
    {
        public int PatientID { get; set; }
        public Nullable<int> MeasureID { get; set; }
        public string MeasureName { get; set; }
        public string UOMText { get; set; }
        public string MeasureValueText { get; set; }
        public Nullable<decimal> MeasureValueNumeric { get; set; }
        public Nullable<System.DateTime> DateTaken { get; set; }
        public Nullable<bool> IsPatientAdministered { get; set; }
        public Nullable<int> LOINCCodeID { get; set; }
        public string LOINCCode { get; set; }
        public string ShortDescription { get; set; }
        public Nullable<int> ProcedureCodeID { get; set; }
        public string ProcedureCode { get; set; }
        public string ProcedureName { get; set; }
        public string ProcedureShortDescription { get; set; }
        public Nullable<int> UserID { get; set; }
        public string UserLoginName { get; set; }
        public string NamePrefix { get; set; }
        public string FirstName { get; set; }
        public string MiddleName { get; set; }
        public string LastName { get; set; }
        public string NameSuffix { get; set; }
        public string Title { get; set; }
        public string PreferredName { get; set; }
        public string SSN { get; set; }
        public Nullable<System.DateTime> DateOfBirth { get; set; }
        public Nullable<int> PresentAge { get; set; }
        public string IsDeceased { get; set; }
        public Nullable<System.DateTime> DateDeceased { get; set; }
        public string Gender { get; set; }
        public string Race { get; set; }
        public string Ethnicity { get; set; }
        public string BloodType { get; set; }
        public string MaritalStatus { get; set; }
        public Nullable<byte> NoOfDependents { get; set; }
        public string EmploymentStatus { get; set; }
        public string ProfessionalType { get; set; }
        public string MedicalRecordNumber { get; set; }
        public string PCPName { get; set; }
        public string PCPNPI { get; set; }
        public Nullable<int> PCPInternalProviderID { get; set; }
        public Nullable<int> DefaultTaskCareProviderID { get; set; }
        public string StatusCode { get; set; }
        public Nullable<int> DataSourceID { get; set; }
        public string SourceName { get; set; }
        public Nullable<int> DataSourceFileID { get; set; }
        public string DataSourceFileName { get; set; }
        public string FileLocation { get; set; }
        public string RecordTag_FileID { get; set; }
        public int LabDataCreateByUserID { get; set; }
        public System.DateTime LabDataCreateDate { get; set; }
        public Nullable<int> LabDataLastModifiedByUserID { get; set; }
        public Nullable<System.DateTime> LabDataLastModifiedDate { get; set; }
    }
}
