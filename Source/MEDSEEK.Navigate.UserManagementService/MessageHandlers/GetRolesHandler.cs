using System.Collections.Generic;
using MEDSEEK.Navigate.Framework.Microservices;
using MEDSEEK.Navigate.UserManagementService.Messages;
using MEDSEEK.Navigate.UserManagementService.Models;
using Medseek.Util.Ioc;
using MEDSEEK.Navigate.Database.Context;
using System.Linq;

namespace MEDSEEK.Navigate.UserManagementService.MessageHandlers
{
    [Register]
    public class GetRolesHandler : RpcMessageHandler<GetRolesMessage, GetRolesReply>
    {
        public override GetRolesReply Handle(GetRolesMessage message)
        {
            var roles = new NavigateEntities().aspnet_Roles_GetAllRoles("/CCM");
            var rolesList = roles.Select(role => new Role {RoleName = role}).ToList();
            return new GetRolesReply { Roles = rolesList };
        }
    }
}
