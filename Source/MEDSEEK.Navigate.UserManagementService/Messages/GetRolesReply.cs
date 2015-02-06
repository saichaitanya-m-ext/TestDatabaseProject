using System.Collections.Generic;
using MEDSEEK.Navigate.Framework.Microservices;
using MEDSEEK.Navigate.UserManagementService.Models;

namespace MEDSEEK.Navigate.UserManagementService.Messages
{
    public class GetRolesReply : Reply
    {
        public List<Role> Roles { get; set; }
    }
}