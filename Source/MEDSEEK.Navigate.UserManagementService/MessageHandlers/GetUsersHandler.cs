using MEDSEEK.Navigate.Framework.Microservices;
using MEDSEEK.Navigate.UserManagementService.Messages;
using Medseek.Util.Ioc;
using System.Web.Security;
using System.Linq;

namespace MEDSEEK.Navigate.UserManagementService.MessageHandlers
{
    [Register]
    public class GetUsersHandler : RpcMessageHandler<GetUsersMessage, GetUsersReply>
    {
        public override GetUsersReply Handle(GetUsersMessage message)
        {
            return new GetUsersReply { Users = Membership.GetAllUsers().Cast<MembershipUser>().ToList() };
        }
    }
}
