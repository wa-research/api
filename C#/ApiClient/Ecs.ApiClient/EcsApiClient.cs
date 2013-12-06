using System;
using ServiceStack.ServiceClient.Web;

namespace Ecs.Api
{
    public class EcsApiClient : JsonServiceClient
    {        const string ApiKeyHeader = "X-ECS-Api-Key";
        const string ApiRequestTimeHeader = "X-ECS-Api-RequestTime";
        const string ApiAuthorizationHeader = "Authorization";

        public EcsApiClient() : base() { }
        public EcsApiClient(string baseUri) : base(baseUri) { }
        
        public static EcsApiClient SetUp(string endpoint, string key, string pwd)
        {
            var client = new EcsApiClient(endpoint);

            client.LocalHttpWebRequestFilter += (req) => {
                string time = DateTime.UtcNow.ToString("s");
                string authorization_header = CalculateSignature(req, key, pwd, time);
                req.Headers.Add(ApiAuthorizationHeader, authorization_header);
                req.Headers.Add(ApiKeyHeader, key);
                req.Headers.Add(ApiRequestTimeHeader, time);
                req.Headers.Add("Path", req.RequestUri.AbsolutePath);
            };
            return client;
        }

        private static string CalculateSignature(System.Net.HttpWebRequest req, string key, string pwd, string time)
        {
            return SHA1Hash(req.RequestUri.AbsolutePath + key + pwd + time);
        }

        /// <summary>
        /// Gets the SHA1 hash.
        /// </summary>
        /// <param name="text">The text.</param>
        /// <returns></returns>
        public static string SHA1Hash(string text)
        {
            var SHA1 = new System.Security.Cryptography.SHA1CryptoServiceProvider();

            byte[] arrayData;
            byte[] arrayResult;
            string result = null;
            string temp = null;

            arrayData = System.Text.Encoding.ASCII.GetBytes(text);
            arrayResult = SHA1.ComputeHash(arrayData);
            for (int i = 0; i < arrayResult.Length; i++) {
                temp = Convert.ToString(arrayResult[i], 16);
                if (temp.Length == 1)
                    temp = "0" + temp;
                result += temp;
            }
            return result;
        }
    }
}