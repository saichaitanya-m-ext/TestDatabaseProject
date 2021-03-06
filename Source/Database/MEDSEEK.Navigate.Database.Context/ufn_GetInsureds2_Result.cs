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
    
    public partial class ufn_GetInsureds2_Result
    {
        public int PatientID { get; set; }
        public int PatientInsuranceID { get; set; }
        public string InsurancePolicyStatus { get; set; }
        public string BenefitTypeName { get; set; }
        public bool IsPrimary { get; set; }
        public System.DateTime DateOfEligibility { get; set; }
        public System.DateTime CoverageEndsDate { get; set; }
        public string MemberID { get; set; }
        public string PolicyNumber { get; set; }
        public string GroupNumber { get; set; }
        public string DependentSequenceNo { get; set; }
        public Nullable<int> SequenceNo { get; set; }
        public Nullable<int> PolicyHolderPatientID { get; set; }
        public string SuperGroupCategory { get; set; }
        public string PCPName { get; set; }
        public Nullable<int> PCPInternalProviderID { get; set; }
        public string PCPNPI { get; set; }
        public string PCPSystem { get; set; }
        public Nullable<System.DateTime> PCPCareBeginDate { get; set; }
        public Nullable<System.DateTime> PCPCareEndDate { get; set; }
        public int InsuranceGroupID { get; set; }
        public string InsuranceGroupName { get; set; }
        public string InsuranceGroupStatus { get; set; }
        public Nullable<int> InsuranceGroupPlanID { get; set; }
        public string InsurancePlanName { get; set; }
        public string InsuranceProductType { get; set; }
        public string InsurancePlanType { get; set; }
        public string InsurancePlanStatus { get; set; }
    }
}
