using System.Collections.Generic;

namespace MEDSEEK.Navigate.Framework.Microservices
{
	public interface IMessageDescriptorRegistry
	{
		IEnumerable<MessageDescriptor> ListMessageDescriptors();
	}
}
