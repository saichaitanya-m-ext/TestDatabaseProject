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
    
    public partial class usp_MetricnumeratorFrequency_Select_Result
    {
        public Nullable<long> Sno { get; set; }
        public int MetricID { get; set; }
        public string NumeratorName { get; set; }
        public int MetricnumeratorFrequencyId { get; set; }
        public string Frequency { get; set; }
        public string FromOperator { get; set; }
        public string FromFrequency { get; set; }
        public string ToOperator { get; set; }
        public string ToFrequency { get; set; }
        public string Label { get; set; }
    }
}
