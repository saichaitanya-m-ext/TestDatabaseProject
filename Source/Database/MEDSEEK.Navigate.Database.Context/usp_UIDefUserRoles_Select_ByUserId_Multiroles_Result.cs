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
    
    public partial class usp_UIDefUserRoles_Select_ByUserId_Multiroles_Result
    {
        public Nullable<int> UIDefId { get; set; }
        public string MenuItemName { get; set; }
        public Nullable<int> PortalId { get; set; }
        public string PageURL { get; set; }
        public string PageDescription { get; set; }
        public Nullable<byte> MenuItemOrder { get; set; }
        public Nullable<byte> PageOrder { get; set; }
        public Nullable<bool> ReadYN { get; set; }
        public Nullable<bool> UpdateYN { get; set; }
        public Nullable<bool> InsertYN { get; set; }
        public Nullable<bool> DeleteYN { get; set; }
        public string PageObject { get; set; }
        public Nullable<bool> isDataAdminPage { get; set; }
        public Nullable<int> SecurityRoleId { get; set; }
    }
}
