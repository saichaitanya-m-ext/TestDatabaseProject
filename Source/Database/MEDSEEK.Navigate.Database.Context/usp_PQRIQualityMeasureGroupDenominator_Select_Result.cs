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
    
    public partial class usp_PQRIQualityMeasureGroupDenominator_Select_Result
    {
        public int PQRIQualityMeasureGroupDenominatorID { get; set; }
        public int PQRIQualityMeasureGroupID { get; set; }
        public string Operator1 { get; set; }
        public string ICDCodeList { get; set; }
        public string Operator2 { get; set; }
        public string CPTCodeList { get; set; }
        public string CriteriaSQL { get; set; }
        public string StatusCode { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public Nullable<short> AgeFrom { get; set; }
        public Nullable<short> AgeTo { get; set; }
        public string Gender { get; set; }
    }
}
