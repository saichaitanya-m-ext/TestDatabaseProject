
namespace MEDSEEK.Navigate.Framework.Microservices
{
	public interface IMessageHandlerFactory
	{
		IMessageHandler GetHandler(MessageDescriptor descriptor);
		IRpcMessageHandler GetRpcHandler(RpcMessageDescriptor descriptor);
	}
}
