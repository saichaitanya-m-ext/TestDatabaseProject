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
    
    public partial class usp_TaskBundleQuestionnaireFrequency_InsertUpdate_Result
    {
        public int ErrorLogId { get; set; }
        public Nullable<int> UserId { get; set; }
        public Nullable<int> ErrorCodeId { get; set; }
        public string CurrentUser { get; set; }
        public string SystemUser { get; set; }
        public System.DateTime ErrorDate { get; set; }
        public Nullable<int> ErrorNumber { get; set; }
        public string ErrorMessage { get; set; }
        public Nullable<int> ErrorSeverity { get; set; }
        public Nullable<int> ErrorState { get; set; }
        public Nullable<int> ErrorLine { get; set; }
        public string ErrorProcedure { get; set; }
        public Nullable<int> TransactionCount { get; set; }
        public string ErrorPage { get; set; }
    }
}
