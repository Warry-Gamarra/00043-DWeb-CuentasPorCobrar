using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public static class Crypto
    {
        public static string EncryptString(this string cadena)
        {
            byte[] encrypt = System.Text.Encoding.Unicode.GetBytes(cadena);
            cadena = Convert.ToBase64String(encrypt);
            return cadena;
        }


        public static string DecryptString(this string CryptoCadena)
        {
            byte[] decrypt = Convert.FromBase64String(CryptoCadena);
            CryptoCadena = System.Text.Encoding.Unicode.GetString(decrypt);
            return CryptoCadena;
        }
    }
}
