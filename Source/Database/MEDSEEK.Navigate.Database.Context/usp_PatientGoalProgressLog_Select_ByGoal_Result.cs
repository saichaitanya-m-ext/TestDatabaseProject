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
    
    public partial class usp_PatientGoalProgressLog_Select_ByGoal_Result
    {
        public int PatientActivityId { get; set; }
        public string ActivityName { get; set; }
        public System.DateTime StartDate { get; set; }
        public Nullable<System.DateTime> GoalCompletedDate { get; set; }
        public string FollowUpDate { get; set; }
        public string FollowUpCompleteDate { get; set; }
        public string ProgressPercentage { get; set; }
    }
}