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
    
    public partial class usp_CareTeam_Select_Result
    {
        public int CareTeamId { get; set; }
        public string CareTeamName { get; set; }
        public string Description { get; set; }
        public Nullable<int> DiseaseId { get; set; }
        public string Name { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public string StatusDescription { get; set; }
        public Nullable<bool> IsCareTeamManager { get; set; }
    }
}