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
    
    public partial class usp_Recommendation_Select_Result
    {
        public int RecommendationId { get; set; }
        public string RecommendationName { get; set; }
        public string Description { get; set; }
        public Nullable<int> DefaultFrequencyOfTitrationDays { get; set; }
        public int SortOrder { get; set; }
        public int UserID { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public string StatusDescription { get; set; }
    }
}
