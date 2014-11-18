using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using Ecs.Api2.ServiceModel;
using ServiceStack.Text;

namespace Ecs.Api.Commander
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 2) {
                Console.WriteLine("Use {0} api_url command_args", Environment.CommandLine);
                Console.WriteLine();
                Console.WriteLine("Available commands:");
                DumpAvailableDTOs();
                Environment.Exit(1);
                return;
            }

            var key = System.Configuration.ConfigurationManager.AppSettings.Get("ecsApi.Key");
            var pwd = ConfigurationManager.AppSettings.Get("ecsApi.Secret");
            var url = args[0];
            var arg = args.Skip(1);

            var client = EcsApiClient.SetUp(url, key, pwd);

            Console.WriteLine("Calling {0}", url);
            Console.WriteLine();

            try {

                var stats = client.Post<IEnumerable<ResourceInfo>>(new NewResourceRequest { Resources = new ResourceInfo[] { new ResourceInfo(), new ResourceInfo() } });
                client.AllowAutoRedirect = true;
                Console.WriteLine(stats.Dump());
            } catch (Exception e) {
                Console.WriteLine("ERROR: {0}", e.Message);
            }
        }

        private static void DumpAvailableDTOs()
        {
        }
    }
}
