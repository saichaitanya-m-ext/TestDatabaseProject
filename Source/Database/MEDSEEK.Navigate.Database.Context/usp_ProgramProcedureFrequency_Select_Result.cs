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
    
    public partial class usp_ProgramProcedureFrequency_Select_Result
    {
        public int ProgramId { get; set; }
        public int ProcedureId { get; set; }
        public string ProcedureCodeandName { get; set; }
        public string FrequencyCondition { get; set; }
        public string Frequency { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public string StatusDescription { get; set; }
        public Nullable<bool> NeverSchedule { get; set; }
        public string ExclusionReason { get; set; }
        public Nullable<int> LabTestId { get; set; }
        public string LabTestName { get; set; }
        public Nullable<System.DateTime> EffectiveStartDate { get; set; }
        public string Name { get; set; }
        public Nullable<bool> IsPreventive { get; set; }
    }
}