using System;
using System.Linq;
using System.Reflection;
using Castle.Core;
using Castle.Facilities.Startable;
using Castle.MicroKernel;
using Castle.MicroKernel.Registration;
using Castle.MicroKernel.SubSystems.Configuration;
using Castle.Windsor;
using log4net;
using Medseek.Util.Ioc;
using Medseek.Util.Ioc.Castle;
using RabbitMQ.Client;

namespace MEDSEEK.Navigate.Framework.Microservices
{
	/// <summary>
	/// Basic Microservice installer.
	/// Microservices can inherit from this to get basic installer functionality,
	/// and can override methods to perform custom installation.
	/// </summary>
	public class MicroserviceInstaller : IWindsorInstaller
	{
		protected static readonly ILog log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);

		/// <summary>
		/// Installs the MicroServices Application components.
		/// </summary>
		public void Install(IWindsorContainer container, IConfigurationStore store)
		{
			log.Debug("Installing Microservice Framework components.");

			if(GetType() == typeof(MicroserviceInstaller))
			{
				container.Kernel.ComponentRegistered += OnComponentRegistered;
				container.Kernel.ComponentModelCreated += OnComponentModelCreated;
				container.Kernel.HandlerRegistered += OnHandlerRegistered;
				container.Kernel.HandlersChanged += OnHandlersChanged;
			}
			InstallFacilities(container);
			InstallRegistrations(container);
			InstallCustomComponents(container);
		}

		protected virtual void InstallFacilities(IWindsorContainer container)
		{
			if (container.Kernel.GetFacilities().OfType<StartableFacility>().Count() == 0)
				container.AddFacility<StartableFacility>();
		}

		protected virtual void InstallRegistrations(IWindsorContainer container)
		{
			container
				.Register(
					Registrations
						.FromAssemblyContaining(GetType())
						.Select(TransformRegistrations)
						.ToArray());
		}

		protected virtual void InstallCustomComponents(IWindsorContainer container)
		{
                container
                    .Register(
                        Component
                            .For<ConnectionFactory>());
		}

		protected static IRegistration TransformRegistrations(Registration registration)
		{
			log.DebugFormat("{0}: Name = {1}, Implementation = {2}, AsFactory = {3}, Lifestyle = {4}, Services = {{ {5} }}", MethodBase.GetCurrentMethod().Name, registration.Name, registration.Implementation, registration.AsFactory, registration.Lifestyle, string.Join(", ", registration.Services));
			var componentRegistration = WindsorBootstrapper.ToRegistration(registration);
			return componentRegistration;
		}

		private static void OnComponentModelCreated(ComponentModel model)
		{
			log.DebugFormat("{0}: ComponentName = {1}, Lifestyle = {2}, Name = {3}, Implementation = {4}, Services = {5}", MethodBase.GetCurrentMethod().Name, model.ComponentName, model.LifestyleType, model.Name, model.Implementation, string.Join(", ", model.Services));
		}

		private static void OnComponentRegistered(string key, IHandler handler)
		{
			log.DebugFormat("{0}: Key = {1}, Handler = {2}", MethodBase.GetCurrentMethod().Name, key, handler);
		}

		private static void OnHandlerRegistered(IHandler handler, ref bool statechanged)
		{
			log.DebugFormat("{0}: CurrentState = {1}, ComponentName = {2}, Lifestyle = {3}, Name = {4}, Implementation = {5}, Services = {6}", MethodBase.GetCurrentMethod().Name, handler.CurrentState, handler.ComponentModel.ComponentName, handler.ComponentModel.LifestyleType, handler.ComponentModel.Name, handler.ComponentModel.Implementation, string.Join(", ", handler.ComponentModel.Services));
		}

		private static void OnHandlersChanged(ref bool statechanged)
		{
			log.DebugFormat("{0}: StateChanged = {1}", MethodBase.GetCurrentMethod().Name, statechanged);
		}
	}
}
