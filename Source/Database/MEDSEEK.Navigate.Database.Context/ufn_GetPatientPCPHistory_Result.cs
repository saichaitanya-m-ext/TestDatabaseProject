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
    
    public partial class ufn_GetPatientPCPHistory_Result
    {
        public int PCPHistoryID { get; set; }
        public string PCPName { get; set; }
        public int ProviderID { get; set; }
        public string NPINumber { get; set; }
        public string PCPSystem { get; set; }
        public System.DateTime CareBeginDate { get; set; }
        public System.DateTime CareEndDate { get; set; }
    }
}