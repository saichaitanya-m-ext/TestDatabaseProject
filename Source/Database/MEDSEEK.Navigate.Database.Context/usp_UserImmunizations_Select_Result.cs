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
    
    public partial class usp_UserImmunizations_Select_Result
    {
        public int UserImmunizationID { get; set; }
        public int ImmunizationID { get; set; }
        public Nullable<int> UserID { get; set; }
        public Nullable<System.DateTime> ImmunizationDate { get; set; }
        public string IsPatientDeclined { get; set; }
        public string Comments { get; set; }
        public string ImmunizationType { get; set; }
        public string AdverseReactionComments { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public Nullable<System.DateTime> DueDate { get; set; }
        public string StatusDescription { get; set; }
        public bool IsPreventive { get; set; }
        public Nullable<int> DataSourceID { get; set; }
        public string SourceName { get; set; }
        public Nullable<int> ProgramID { get; set; }
        public Nullable<int> AssignedCareProviderId { get; set; }
    }
}