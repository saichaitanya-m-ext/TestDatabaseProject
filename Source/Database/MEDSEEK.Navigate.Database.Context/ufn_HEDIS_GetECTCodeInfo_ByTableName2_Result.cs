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
    
    public partial class ufn_HEDIS_GetECTCodeInfo_ByTableName2_Result
    {
        public int HEDIS_ECTCodeID { get; set; }
        public string ECTCode { get; set; }
        public string ECTCodeDescription { get; set; }
        public string ECTHedisDomainCode { get; set; }
        public string ECTHedisMeasureCode { get; set; }
        public string ECTHedisSubDomainCode { get; set; }
        public string ECTHedisClassCode { get; set; }
        public string ECTHedisTableName { get; set; }
        public string ECTHedisTableLetter { get; set; }
        public string ECTHedisCodeTypeCode { get; set; }
        public Nullable<bool> IsBillingValid { get; set; }
        public int VersionYear { get; set; }
    }
}
