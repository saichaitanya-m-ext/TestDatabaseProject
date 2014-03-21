using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using log4net;
using Medseek.Util.Ioc.Castle;

namespace MEDSEEK.Navigate.Framework.Microservices
{
    public abstract class ApplicationEntryPoint
    {
        private readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);

        public void Run()
        {
            using (var process = Process.GetCurrentProcess())
                Log.InfoFormat("Started process; Pid = {0}, MainModule = {1}.", process.Id, Path.GetFileName(process.MainModule.FileName));

            using (var container = WindsorBootstrapper.GetContainer())
            {
                Console.WriteLine("Press Escape to exit or Spacebar to run client.");
                ConsoleKey key;
                while ((key = Console.ReadKey(true).Key) != ConsoleKey.Escape)
                    OnKey(key);
            }
        }

        protected abstract void OnKey(ConsoleKey key);
    }
}