
namespace MEDSEEK.Navigate.Framework.Microservices
{
	public abstract class MessageHandler<TMessage> : IMessageHandler
		where TMessage : Message
	{
		public void Handle(Message message)
		{
			Handle(message as TMessage);
		}

		public abstract void Handle(TMessage message);
	}
}
