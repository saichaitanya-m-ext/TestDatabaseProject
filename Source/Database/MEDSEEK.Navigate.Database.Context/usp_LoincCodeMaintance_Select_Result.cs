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
    
    public partial class usp_LoincCodeMaintance_Select_Result
    {
        public int LoincCodeId { get; set; }
        public string LoincCode { get; set; }
        public string ShortDescription { get; set; }
        public string LongDescription { get; set; }
        public string Component { get; set; }
        public string Property { get; set; }
        public string TimeAspect { get; set; }
        public string System { get; set; }
        public string ScaleType { get; set; }
        public string MethodType { get; set; }
        public string Class { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public string Status { get; set; }
        public string MappedProcedureName { get; set; }
        public string MappedMeasureName { get; set; }
        public string AssociatedProcedureName { get; set; }
    }
}
