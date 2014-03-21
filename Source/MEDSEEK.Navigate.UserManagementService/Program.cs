using System;
//using Navigate_DataAccessPrototype;
using MEDSEEK.Navigate.Framework.Microservices;

namespace MEDSEEK.Navigate.UserManagementService
{
    class Program : ApplicationEntryPoint
    {
        static void Main(string[] args)
        {
            var program = new Program();
            program.Run();
        }

        protected override void OnKey(ConsoleKey key)
        {

        }
    }
}
