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
    
    public partial class ufn_GetInsuredBenefits_Result
    {
        public int PatientID { get; set; }
        public string InsuranceProductType { get; set; }
        public string InsurancePlanType { get; set; }
        public string InsuranceBenefitType { get; set; }
        public System.DateTime DateOfEligibility { get; set; }
        public System.DateTime CoverageEndsDate { get; set; }
        public int PolicyHolderPatientID { get; set; }
    }
}
