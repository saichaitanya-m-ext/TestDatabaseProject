using System.Collections.Generic;
using System.Web.Security;
using MEDSEEK.Navigate.Framework.Microservices;

namespace MEDSEEK.Navigate.UserManagementService.Messages
{
    public class GetUsersReply : Reply
    {
        public List<MembershipUser> Users { get; set; }
    }
}