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
    
    public partial class usp_LabMeasure_Select_ByPatientUserId_Result
    {
        public int LabMeasureId { get; set; }
        public int MeasureId { get; set; }
        public bool IsGoodControl { get; set; }
        public string TextValueForGoodControl { get; set; }
        public string GoodRange { get; set; }
        public string DerivedGoodValue { get; set; }
        public bool IsFairControl { get; set; }
        public string TextValueForFairControl { get; set; }
        public string FairRange { get; set; }
        public string DerivedFairValue { get; set; }
        public bool IsPoorControl { get; set; }
        public string TextValueForPoorControl { get; set; }
        public string PoorRange { get; set; }
        public string DerivedPoorValue { get; set; }
        public Nullable<int> MeasureUOMId { get; set; }
        public Nullable<int> ProgramId { get; set; }
        public Nullable<int> PatientUserID { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public string MeasureName { get; set; }
        public string ProgramName { get; set; }
        public string StatusDescription { get; set; }
        public string UOMText { get; set; }
        public string UOMDescription { get; set; }
        public Nullable<bool> IsTextValueForControls { get; set; }
    }
}
