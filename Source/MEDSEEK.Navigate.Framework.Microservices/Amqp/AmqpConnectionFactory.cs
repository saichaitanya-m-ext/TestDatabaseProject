using System;
using Medseek.Util.Ioc;
using RabbitMQ.Client;

namespace MEDSEEK.Navigate.Framework.Microservices.Amqp
{
    /// <summary>
    /// Provides instances of AMQP connection components by wrapping calls to 
    /// <see cref="ConnectionFactory" /> and returning wrapper types where 
    /// appropriate.
    /// </summary>
    [Register(typeof(IConnectionFactory), Lifestyle = Lifestyle.Transient)]
    public class AmqpConnectionFactory : IConnectionFactory
    {
        private readonly ConnectionFactory connectionFactory;

        /// <summary>
        /// Initializes a new instance of the <see cref="AmqpConnectionFactory"/> class.
        /// </summary>
        /// <param name="connectionFactory">
        /// The connection factory to use and wrap.
        /// </param>
        public AmqpConnectionFactory(ConnectionFactory connectionFactory)
        {
            if (connectionFactory == null)
                throw new ArgumentNullException("connectionFactory");

            this.connectionFactory = connectionFactory;
        }

        /// <summary>
        /// Creates a connection to the AMQP endpoint.
        /// </summary>
        /// <returns>
        /// The connection to the AMQP endpoint.
        /// </returns>
        public IConnection CreateConnection()
        {
            var value = connectionFactory.CreateConnection();
            return value;
        }
    }
}