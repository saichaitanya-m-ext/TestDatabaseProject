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
    
    public partial class usp_PQRIQualityMeasure_SelectByMeasureID_Result
    {
        public int PQRIQualityMeasureID { get; set; }
        public int PQRIMeasureID { get; set; }
        public string PQRIQualityMeasureName { get; set; }
        public string Description { get; set; }
        public string StatusCode { get; set; }
        public Nullable<short> ReportingYear { get; set; }
        public Nullable<short> ReportingPeriod { get; set; }
        public string ReportingPeriodType { get; set; }
        public Nullable<short> PerformancePeriod { get; set; }
        public string PerformancePeriodType { get; set; }
        public bool IsBFFS { get; set; }
        public Nullable<int> DocumentLibraryID { get; set; }
        public Nullable<int> DocumentStartPage { get; set; }
        public string SubmissionMethod { get; set; }
        public string ReportingMethod { get; set; }
        public string Note { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public Nullable<int> MigratedPQRIQualityMeasureID { get; set; }
        public bool IsAllowEdit { get; set; }
    }
}
