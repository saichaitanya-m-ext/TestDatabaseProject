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
    
    public partial class usp_DocumentDisease_Search_Result
    {
        public int LibraryID { get; set; }
        public int Id { get; set; }
        public string DocumentName { get; set; }
        public string DocumentDescription { get; set; }
        public Nullable<int> DocumentTypeId { get; set; }
        public string PhysicalFileName { get; set; }
        public string DocumentNum { get; set; }
        public string DocumentLocation { get; set; }
        public byte[] eDocument { get; set; }
        public string DocumentSourceCompany { get; set; }
        public int CreatedByUserId { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public Nullable<int> LastModifiedByUserId { get; set; }
        public Nullable<System.DateTime> LastModifiedDate { get; set; }
        public string StatusDescription { get; set; }
        public string DocumentTypeName { get; set; }
        public string WebSiteURLLink { get; set; }
    }
}
