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
    
    public partial class usp_QuestionnaireFrequency_Select_Result
    {
        public int QuestionnaireFrequencyID { get; set; }
        public int FrequencyNumber { get; set; }
        public string Frequency { get; set; }
        public int QuestionaireId { get; set; }
        public string QuestionaireName { get; set; }
        public Nullable<int> CareTeamId { get; set; }
        public Nullable<int> PopulationDefinitionID { get; set; }
        public Nullable<int> ProgramId { get; set; }
        public Nullable<int> UserId { get; set; }
        public string StatusDescription { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public string Name { get; set; }
        public Nullable<bool> IsPreventive { get; set; }
    }
}
