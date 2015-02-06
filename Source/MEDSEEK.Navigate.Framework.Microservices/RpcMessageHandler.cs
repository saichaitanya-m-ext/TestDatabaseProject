
namespace MEDSEEK.Navigate.Framework.Microservices
{
	public abstract class RpcMessageHandler<TMessage, TReply> : IRpcMessageHandler
		where TMessage : Message
		where TReply : Reply
	{
		public Reply Handle(Message message)
		{
			return Handle(message as TMessage);
		}

		public abstract TReply Handle(TMessage message);
	}
}
