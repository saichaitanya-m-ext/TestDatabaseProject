using System;

namespace MEDSEEK.Navigate.Framework.Microservices
{
	public class MessageDescriptor
	{
        public Type HandlerType { get; private set; }
		public Type MessageType { get; private set; }

        public MessageDescriptor(Type handlerType, Type messageType)
		{
			HandlerType = handlerType;
			MessageType = messageType;
		}

        public virtual string RequestQueueName { get; set; }

        public string ExchangeName
		{
			get 
			{
				return MessageType.Name.Replace("Message", string.Empty) + "Exchange";
			}
		}

	    public string Topic
	    {
	        get { return String.Format("navigate.{0}", MessageType.Name.Replace("Message", String.Empty)); }
	    }
	}
}
