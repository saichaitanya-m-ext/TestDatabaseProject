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
    
    public partial class usp_PQRIQualityMeasureGroup_Search_Result
    {
        public int PQRIQualityMeasureGroupID { get; set; }
        public string PQRIMeasureGroupID { get; set; }
        public string PQRIQualityMeasureName { get; set; }
        public string MeasureGrouptoMeasure { get; set; }
        public string Description { get; set; }
        public string StatusCode { get; set; }
        public Nullable<int> DocumentStartPage { get; set; }
        public Nullable<int> DocumentLibraryID { get; set; }
        public Nullable<int> MigratedPQRIQualityMeasureGroupID { get; set; }
        public bool IsAllowEdit { get; set; }
    }
}
