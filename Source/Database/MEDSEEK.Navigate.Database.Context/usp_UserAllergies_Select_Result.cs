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
    
    public partial class usp_UserAllergies_Select_Result
    {
        public int UserAllergiesID { get; set; }
        public int UserID { get; set; }
        public Nullable<int> AllergiesID { get; set; }
        public string Reaction { get; set; }
        public string Severity { get; set; }
        public string Comments { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public Nullable<System.DateTime> UserAllergiesDate { get; set; }
        public string StatusDescription { get; set; }
        public Nullable<int> DataSourceID { get; set; }
        public string SourceName { get; set; }
        public string Name { get; set; }
    }
}
