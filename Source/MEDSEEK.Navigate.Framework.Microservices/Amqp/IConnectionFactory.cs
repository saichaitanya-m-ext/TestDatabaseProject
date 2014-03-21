using RabbitMQ.Client;

namespace MEDSEEK.Navigate.Framework.Microservices.Amqp
{
    /// <summary>
    /// Interface for types that can provide instances of AMQP connection 
    /// components.
    /// </summary>
    public interface IConnectionFactory
    {
        /// <summary>
        /// Creates a connection to the AMQP endpoint.
        /// </summary>
        /// <returns>
        /// The connection to the AMQP endpoint.
        /// </returns>
        IConnection CreateConnection();
    }
}