using System;
using System.Collections.Specialized;
using System.Net;
using System.Text;

namespace Ecs.Api
{
    /// <summary>
    /// Extend WebClient to allow posting of multiple values for the same key
    /// </summary>
    /// <remarks>See http://msdn.microsoft.com/en-us/library/system.net.webclient.uploadvalues.aspx#3</remarks>
    public class WebClientWithMultivalueKeysAndGzipDecompression : WebClient
    {
        protected override WebRequest GetWebRequest(Uri address)
        {
            HttpWebRequest request = base.GetWebRequest(address) as HttpWebRequest;
            request.AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip;
            return request;
        }

        public new byte[] UploadValues(string address, NameValueCollection data)
        {
            return UploadValues(address, null, data);
        }

        public new byte[] UploadValues(Uri address, NameValueCollection data)
        {
            return UploadValues(address, null, data);
        }
        
        public new byte[] UploadValues(string address, string method, NameValueCollection data)
        {
            var buffer = InternalUploadValues(data);
            return UploadData(address, method, buffer);
        }
        
        public new byte[] UploadValues(Uri address, string method, NameValueCollection data)
        {
            var buffer = InternalUploadValues(data);
            return UploadData(address, method, buffer);
        }

        private byte[] InternalUploadValues(NameValueCollection data)
        {
            const string uploadValuesContentType = "application/x-www-form-urlencoded";
            if (Headers == null) Headers = new WebHeaderCollection();
            var contentType = Headers[HttpRequestHeader.ContentType];
            if ((contentType != null) &&
            (String.Compare(contentType, uploadValuesContentType, StringComparison.OrdinalIgnoreCase) != 0)) {
                throw new WebException("ContentType");
            }
            Headers[HttpRequestHeader.ContentType] = uploadValuesContentType;
            var delimiter = string.Empty;
            var sb = new StringBuilder();
            foreach (var name in data.AllKeys) {
                var values = data.GetValues(name);
                if (values == null) continue; // Won't happen, because existing keys always have value(s).
                foreach (var value in values) {
                    sb.Append(string.Format("{0}{1}={2}",
                    delimiter,
                    UrlEncode(name),
                    UrlEncode(value)));
                    delimiter = "&";
                }
            }
            return Encoding.ASCII.GetBytes(sb.ToString());
        }

        #region Async upload
        public new void UploadValuesAsync(Uri address, NameValueCollection data)
        {
            UploadValuesAsync(address, null, data, null);
        }
        public new void UploadValuesAsync(Uri address, string method, NameValueCollection data)
        {
            UploadValuesAsync(address, method, data, null);
        }
        public new void UploadValuesAsync(Uri address, string method, NameValueCollection data, object userToken)
        {
            var buffer = InternalUploadValues(data);
            // REMINDER: Hook UploadDataCompleted instead of UploadValuesCompleted.
            UploadDataAsync(address, method, buffer, userToken);
        }
        #endregion

        #region Urlencode
        private static string UrlEncode(string str)
        {
            if (str == null) {
                return null;
            }
            return Encoding.ASCII.GetString(UrlEncodeToBytes(str, Encoding.UTF8));
        }

        private static byte[] UrlEncodeToBytes(string str, Encoding e)
        {
            if (str == null) {
                return null;
            }
            byte[] bytes = e.GetBytes(str);
            return UrlEncodeBytesToBytesInternal(bytes, 0, bytes.Length, false);
        }

        private static byte[] UrlEncodeBytesToBytesInternal(byte[] bytes, int offset, int count, bool alwaysCreateReturnValue)
        {
            int num = 0;
            int num2 = 0;
            for (int i = 0; i < count; i++) {
                char c = (char)bytes[offset + i];
                if (c == ' ') {
                    num++;
                } else {
                    if (!IsSafe(c)) {
                        num2++;
                    }
                }
            }
            if (!alwaysCreateReturnValue && num == 0 && num2 == 0) {
                return bytes;
            }
            byte[] array = new byte[count + num2 * 2];
            int num3 = 0;
            for (int j = 0; j < count; j++) {
                byte b = bytes[offset + j];
                char c2 = (char)b;
                if (IsSafe(c2)) {
                    array[num3++] = b;
                } else {
                    if (c2 == ' ') {
                        array[num3++] = 43;
                    } else {
                        array[num3++] = 37;
                        array[num3++] = (byte)IntToHex((int)((int)b >> 4 & 15));
                        array[num3++] = (byte)IntToHex((int)(b & 15));
                    }
                }
            }
            return array;
        }

        private static bool IsSafe(char ch)
        {
            if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9')) {
                return true;
            }
            if (ch != '!') {
                switch (ch) {
                    case '\'':
                    case '(':
                    case ')':
                    case '*':
                    case '-':
                    case '.': {
                            return true;
                        }
                    case '+':
                    case ',': {
                            break;
                        }
                    default: {
                            if (ch == '_') {
                                return true;
                            }
                            break;
                        }
                }
                return false;
            }
            return true;
        }

        private static char IntToHex(int n)
        {
            if (n <= 9) {
                return (char)(n + 48);
            }
            return (char)(n - 10 + 97);
        }
        #endregion
    }
}
