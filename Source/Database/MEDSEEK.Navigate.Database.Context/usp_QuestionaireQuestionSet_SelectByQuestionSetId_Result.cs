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
    
    public partial class usp_QuestionaireQuestionSet_SelectByQuestionSetId_Result
    {
        public int QuestionSetId { get; set; }
        public string QuestionSetName { get; set; }
        public string Description { get; set; }
        public Nullable<int> SortOrder { get; set; }
        public Nullable<bool> IsShowPanel { get; set; }
        public Nullable<bool> IsShowQuestionSetName { get; set; }
        public int Createdbyuserid { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public string StatusCode { get; set; }
    }
}
