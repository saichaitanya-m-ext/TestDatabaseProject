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
    
    public partial class usp_UserInsurance_Select_Result
    {
        public int UserInsuranceId { get; set; }
        public Nullable<int> InsuranceGroupPlanId { get; set; }
        public string PlanName { get; set; }
        public int InsuranceGroupId { get; set; }
        public string GroupName { get; set; }
        public int UserId { get; set; }
        public string IsPrimary { get; set; }
        public string PCPUserId { get; set; }
        public string PrimaryCareProvider { get; set; }
        public string PCPExternalProviderId { get; set; }
        public string PCPSystem { get; set; }
        public string EmployerGroupName { get; set; }
        public Nullable<int> EmployerGroupID { get; set; }
        public string GroupOrPolicyNumber { get; set; }
        public string SuperGroupCategory { get; set; }
        public string PharmacyBenefit { get; set; }
        public string MedicareSupplement { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public string StatusDescription { get; set; }
        public string StartDate { get; set; }
        public string EndDate { get; set; }
    }
}