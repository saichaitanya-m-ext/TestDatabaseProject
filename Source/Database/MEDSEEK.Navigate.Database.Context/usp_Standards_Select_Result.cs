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
    
    public partial class usp_Standards_Select_Result
    {
        public int StandardsId { get; set; }
        public string StandardsName { get; set; }
        public Nullable<int> StandardOrganizationId { get; set; }
        public string StandardOrganizationName { get; set; }
        public string StatusCode { get; set; }
        public string CreatedBy { get; set; }
        public string CreatedDate { get; set; }
    }
}