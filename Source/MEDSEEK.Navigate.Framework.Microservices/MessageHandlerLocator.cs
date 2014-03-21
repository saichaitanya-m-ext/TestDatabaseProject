using System;
using System.Collections.Generic;
using System.Linq;
using Castle.Windsor;
using Medseek.Util.Ioc;

namespace MEDSEEK.Navigate.Framework.Microservices
{
	[Register(typeof(IMessageDescriptorRegistry), Name = "MessageDescriptorRegistry")]
	[Register(typeof(IMessageHandlerFactory), Name = "MessageHandlerFactory")]
	public class MessageHandlerLocator : IMessageDescriptorRegistry, IMessageHandlerFactory
	{
		private IWindsorContainer container;

		public MessageHandlerLocator(IWindsorContainer windsorContainer)
		{
			container = windsorContainer;
		}

		private List<Type> ListMessageHandlerTypes()
		{
			return container.Kernel.GetAssignableHandlers(typeof(IMessageHandler))
				.Select(h => h.ComponentModel.Implementation)
				.ToList();
		}

		private List<Type> ListRpcMessageHandlerTypes()
		{
			return container.Kernel.GetAssignableHandlers(typeof(IRpcMessageHandler))
				.Select(h => h.ComponentModel.Implementation)
				.ToList();
		}

		public IEnumerable<MessageDescriptor> ListMessageDescriptors()
		{
			List<MessageDescriptor> list = new List<MessageDescriptor>();
			ListMessageHandlerTypes()
				.ForEach(handlerType =>
				{
					var baseType = handlerType.BaseType;
					if (baseType.GenericTypeArguments.Length == 1)
					{
						var messageType = baseType.GenericTypeArguments[0];
						list.Add(new MessageDescriptor(handlerType, messageType));
					}
				});
			ListRpcMessageHandlerTypes()
				.ForEach(handlerType =>
				{
					var baseType = handlerType.BaseType;
					if (baseType.GenericTypeArguments.Length == 2)
					{
						var messageType = baseType.GenericTypeArguments[0];
						var replyType = baseType.GenericTypeArguments[1];
						list.Add(new RpcMessageDescriptor(handlerType, messageType, replyType));
					}
				});
			return list;
		}

		public IMessageHandler GetHandler(MessageDescriptor descriptor)
		{
			return container.Resolve(descriptor.HandlerType) as IMessageHandler;
		}

		public IRpcMessageHandler GetRpcHandler(RpcMessageDescriptor descriptor)
		{
			return container.Resolve(descriptor.HandlerType) as IRpcMessageHandler;
		}
	}
}
