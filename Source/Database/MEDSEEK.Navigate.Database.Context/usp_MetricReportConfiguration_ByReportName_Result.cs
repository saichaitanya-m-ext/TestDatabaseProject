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
    
    public partial class usp_MetricReportConfiguration_ByReportName_Result
    {
        public int ID { get; set; }
        public Nullable<int> DrID { get; set; }
        public string DrName { get; set; }
        public string DefinitionType { get; set; }
        public Nullable<int> ParentID { get; set; }
        public Nullable<int> StandardID { get; set; }
    }
}