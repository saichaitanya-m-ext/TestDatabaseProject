using System;

namespace MEDSEEK.Navigate.Framework.Microservices
{
	public class RpcMessageDescriptor : MessageDescriptor
	{
		public Type ReplyType { get; private set; }

		public RpcMessageDescriptor(Type handlerType, Type messageType, Type replyType)
			: base(handlerType, messageType)
		{
			ReplyType = replyType;
		}

        //public override string RequestQueueName
        //{
        //    get
        //    {
        //        return MessageType.Name + "RpcQueue";
        //    }
        //}

	}
}
