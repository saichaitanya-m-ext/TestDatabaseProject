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
    
    public partial class ufn_GetProgramRemaindersByTaskID_Result
    {
        public Nullable<int> TaskID { get; set; }
        public Nullable<int> CommunicationCount { get; set; }
        public Nullable<int> CommunicationTemplateID { get; set; }
        public Nullable<int> CommunicationAttemptDays { get; set; }
        public Nullable<int> NoOfDaysBeforeTaskClosedIncomplete { get; set; }
        public Nullable<int> TaskTypeCommunicationID { get; set; }
        public Nullable<int> NextCommunicationSequence { get; set; }
        public Nullable<int> CommunicationTypeID { get; set; }
        public Nullable<int> TotalFutureTasks { get; set; }
        public string RemainderState { get; set; }
        public Nullable<int> NextRemainderDays { get; set; }
        public string NextRemainderState { get; set; }
    }
}
