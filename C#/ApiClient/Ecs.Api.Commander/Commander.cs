using System;
using System.Configuration;
using Ecs.Api2.ServiceModel;
using ServiceStack.Text;

namespace Ecs.Api.Commander
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 2) {
                Console.WriteLine("Use {0} community_url command", Environment.CommandLine);
                Console.WriteLine();
                Console.WriteLine("Available commands:");
                DumpAvailableDTOs();
                Environment.Exit(1);
                return;
            }

            var key = System.Configuration.ConfigurationManager.AppSettings.Get("ecsApi.Key");
            var pwd = ConfigurationManager.AppSettings.Get("ecsApi.Secret");
            var url = args[0] + "/__api/v2/";

            var client = EcsApiClient.SetUp(url, key, pwd);

            Console.WriteLine("Calling {0}", url);
            Console.WriteLine();

            try {
                var stats = client.Get<CommunityCoreStats>(new CommunitySummaryRequest());
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
