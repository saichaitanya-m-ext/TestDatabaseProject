namespace MEDSEEK.Navigate.Framework.Microservices
{
	public interface IMessageHandler
	{
		void Handle(Message message);               
	}
}