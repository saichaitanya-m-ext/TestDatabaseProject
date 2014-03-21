
namespace MEDSEEK.Navigate.Framework.Microservices
{
	public interface IRpcMessageHandler
	{
		Reply Handle(Message message);
	}
}
