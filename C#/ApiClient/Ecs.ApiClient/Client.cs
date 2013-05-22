using System;
using System.Collections.Specialized;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;

namespace Ecs.Api
{
    public class Client
    {
        ThreadLocal<WebClientWithMultivalueKeysAndGzipDecompression> _webClient = new ThreadLocal<WebClientWithMultivalueKeysAndGzipDecompression>(() => new WebClientWithMultivalueKeysAndGzipDecompression());
        string _user, _key, _url;

        public Client() { }

        public Client(string url, string user, string key)
        {
            _url = url;
            _user = user;
            _key = key;
        }

        public string PostSignedRequest(NameValueCollection payload, string operation)
        {
            return PostSignedRequest(payload, operation, _url, _user, _key);
        }

        public string PostSignedRequest(NameValueCollection payload, string operation, string url, string user, string key)
        {
            string apiUrl = FormatApiUrl(url, operation, user, key);
            try {
                if (apiUrl != null) {
                    System.Console.WriteLine("Posting to {0}", apiUrl);
                    string response = Encoding.UTF8.GetString(_webClient.Value.UploadValues(apiUrl, payload));
                    return response;
                } else {
                    throw new ApplicationException("Could not determine API url");
                }
            } catch (WebException wex) {
                var r = wex.Response as HttpWebResponse;
                if (r != null) {
                    throw new ApplicationException(string.Format("Request failed with status {0} {1}", (int)r.StatusCode, r.StatusDescription));
                } else {
                    throw;
                }
            }
        }

        #region Determine and sign ECS API url based on recipient domain
        private string FormatApiUrl(string url, string operation, string username, string password)
        {
            url = url.TrimEnd('/');
            if (!url.StartsWith("http")) {
                url = "http://" + url;
            }
            return string.Concat(url, "/__api/v1/?", SignRequest(operation, username, password));
        }

        private string SignRequest(string operation, string site, string password)
        {
            string date = DateTime.UtcNow.ToString("s");

            string sig = SHA1Hash(string.Concat(operation, site, password, date));
            return string.Concat(OPERATION, "=", operation, "&", SITE, "=", site, "&", REQUEST_TIME, "=", date, "&", SIGNATURE, "=", sig);
        }

        const string SIGNATURE = "signature";
        const string REQUEST_TIME = "request-time";
        const string SITE = "site-id";
        const string OPERATION = "operation";
        
        public static string SHA1Hash(string text)
        {
            var SHA1 = new SHA1CryptoServiceProvider();

            byte[] arrayData;
            byte[] arrayResult;
            string result = null;
            string temp = null;

            arrayData = Encoding.ASCII.GetBytes(text);
            arrayResult = SHA1.ComputeHash(arrayData);
            for (int i = 0; i < arrayResult.Length; i++) {
                temp = Convert.ToString(arrayResult[i], 16);
                if (temp.Length == 1)
                    temp = "0" + temp;
                result += temp;
            }
            return result;
        }
        #endregion
    }
}
