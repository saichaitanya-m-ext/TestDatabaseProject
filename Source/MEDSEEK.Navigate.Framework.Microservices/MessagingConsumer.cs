using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using Castle.Core;
using log4net;
using Medseek.Util.Ioc;
using Newtonsoft.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MEDSEEK.Navigate.Framework.Microservices.Amqp;

namespace MEDSEEK.Navigate.Framework.Microservices
{
	/// <summary>
	/// Manages consuming and handling messsages for a group of <see cref="MessageDescriptor"/>s.
	/// </summary>
	[Register]
	public class MessagingConsumer : IStartable, IDisposable
	{
		private static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
		private readonly Dictionary<EventingBasicConsumer, MessageDescriptor> descriptorMap = new Dictionary<EventingBasicConsumer, MessageDescriptor>();
		private readonly Lazy<IModel> channel;
		private readonly Lazy<IConnection> connection;
		private readonly IMessageDescriptorRegistry messageDescriptorRegistry;
		private readonly IMessageHandlerFactory messageHandlerFactory;
		private bool disposed;
		private bool started;
        private const string Exchange = "navigate";
        private const string Topic = "navigate.*";

		public MessagingConsumer(IConnectionFactory connectionFactory, IMessageDescriptorRegistry messageDescriptorRegistry, IMessageHandlerFactory messageHandlerFactory)
		{
			if (connectionFactory == null)
				throw new ArgumentNullException("connectionFactory");
			if (messageDescriptorRegistry == null)
				throw new ArgumentNullException("messageDescriptorRegistry");
			if (messageHandlerFactory == null)
				throw new ArgumentNullException("messageHandlerFactory");

			channel = new Lazy<IModel>(() => connection.Value.CreateModel());
			connection = new Lazy<IConnection>(connectionFactory.CreateConnection);
			this.messageDescriptorRegistry = messageDescriptorRegistry;
			this.messageHandlerFactory = messageHandlerFactory;
		}

		public void Start()
		{
			if (disposed)
				throw new ObjectDisposedException(GetType().Name);
			if (started)
				throw new InvalidOperationException();

			Log.DebugFormat("{0}", MethodBase.GetCurrentMethod().Name);
			started = true;

            channel.Value.ExchangeDeclare(Exchange, ExchangeType.Topic, true);

            foreach (var descriptor in messageDescriptorRegistry.ListMessageDescriptors())
            {
                var consumer = new EventingBasicConsumer();
                consumer.Received += OnReceivedLog;

                if (descriptor is RpcMessageDescriptor)
                    consumer.Received += OnReceivedForRpcHandler;
                else
                    consumer.Received += OnReceivedForHandler;

                var queueName = channel.Value.QueueDeclare();
                channel.Value.QueueBind(queueName, Exchange, descriptor.Topic);
                Console.Out.WriteLine("queueName = {0}", queueName.QueueName);

                descriptor.RequestQueueName = queueName.QueueName;

                if (!descriptorMap.ContainsKey(consumer))
                    descriptorMap[consumer] = descriptor;

                channel.Value.BasicConsume(descriptor.RequestQueueName, true, consumer);

                //channel.Value.ExchangeDeclare(descriptor.ExchangeName, ExchangeType.Fanout, true, false, null);
                //channel.Value.QueueDeclare(descriptor.RequestQueueName, false, false, false, null);
                //channel.Value.QueueBind(descriptor.RequestQueueName, descriptor.ExchangeName, string.Empty);
                //channel.Value.BasicConsume(descriptor.RequestQueueName, true, consumer);
            }

		
        }

		private void OnReceivedForRpcHandler(IBasicConsumer sender, BasicDeliverEventArgs args)
		{
		        Console.Out.WriteLine("OnReceivedForRpcHandler");
		        var descriptor = descriptorMap[(EventingBasicConsumer) sender];
		        var handler = messageHandlerFactory.GetRpcHandler(descriptor as RpcMessageDescriptor);
		        var bodyString = Encoding.Default.GetString(args.Body);
		        var message = JsonConvert.DeserializeObject(bodyString, descriptor.MessageType) as Message;
		        var reply = handler.Handle(message);
                if (!string.IsNullOrWhiteSpace(args.BasicProperties.ReplyTo))
                {
                    var replyString = JsonConvert.SerializeObject(reply);
                    var resultData = Encoding.Default.GetBytes(replyString);
                    var properties = channel.Value.CreateBasicProperties();
                    properties.CorrelationId = args.BasicProperties.CorrelationId;
                    channel.Value.BasicPublish(string.Empty, args.BasicProperties.ReplyTo, properties, resultData);
                }
		}

		private void OnReceivedForHandler(IBasicConsumer sender, BasicDeliverEventArgs args)
		{
            Console.Out.WriteLine("OnReceivedForHandler");
            var descriptor = descriptorMap[(EventingBasicConsumer)sender];
            var handler = messageHandlerFactory.GetHandler(descriptor);
            var bodyString = Encoding.Default.GetString(args.Body);
            var message = JsonConvert.DeserializeObject(bodyString, descriptor.MessageType) as Message;
            handler.Handle(message);
		}

		private void OnReceivedLog(IBasicConsumer sender, BasicDeliverEventArgs args)
		{
			Log.DebugFormat("Recevied {0} bytes; Exchange = {1}, RoutingKey = '{2}', ReplyTo = '{3}', CorrelationId = '{4}'.", args.Body.Length, args.Exchange, args.RoutingKey, args.BasicProperties.ReplyTo, args.BasicProperties.CorrelationId);
        }

		public void Stop()
		{
			if (disposed)
				throw new ObjectDisposedException(GetType().Name);
			if (!started)
				throw new InvalidOperationException();

			Log.DebugFormat("{0}", MethodBase.GetCurrentMethod().Name);
			started = false;

			foreach (var consumer in descriptorMap.Keys.ToArray())
			{
				channel.Value.BasicCancel(consumer.ConsumerTag);
				descriptorMap.Remove(consumer);
			}
		}

		public void Dispose()
		{
			if (!disposed)
			{
				disposed = true;
				if (channel.IsValueCreated)
					channel.Value.Dispose();
				if (connection.IsValueCreated)
					connection.Value.Dispose();
			}
		}
	}
}
