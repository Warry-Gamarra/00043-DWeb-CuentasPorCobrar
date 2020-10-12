using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public class RandomPassword
    {
        private static int DEFAULT_PASSWORD_LENGTH = 8;

        public static string PASSWORD_CHARS_ALPHA = "abcdefgijkmnopqrstwxyzABCDEFGHJKLMNPQRSTWXYZ";
        public static string PASSWORD_CHARS_NUMERIC = "23456789";
        public static string PASSWORD_CHARS_SPECIAL = "*$-+?_&=!%{}/";

        public static string PASSWORD_CHARS_ALPHANUMERIC = PASSWORD_CHARS_ALPHA + PASSWORD_CHARS_NUMERIC;
        public static string PASSWORD_CHARS_ALL = PASSWORD_CHARS_ALPHA + PASSWORD_CHARS_NUMERIC + PASSWORD_CHARS_SPECIAL;

        public static string Generate()
        {
            return GeneratePassword(DEFAULT_PASSWORD_LENGTH, PASSWORD_CHARS_ALL);
        }

        public static string Generate(int length)
        {
            return GeneratePassword(length, PASSWORD_CHARS_ALL);
        }

        public static string Generate(string passwordChars)
        {
            return GeneratePassword(DEFAULT_PASSWORD_LENGTH, passwordChars);
        }

        public static string Generate(int length, string passwordChars)
        {
            return GeneratePassword(length, passwordChars);
        }

        private static string GeneratePassword(int passwordLength, string passwordCharacters)
        {
            if (passwordLength <= 0)
                throw new ArgumentOutOfRangeException("password Length", passwordLength, "La longitud de la cadena debe ser mayor que 0");

            if (String.IsNullOrEmpty(passwordCharacters) || String.IsNullOrWhiteSpace(passwordCharacters))
                throw new ArgumentOutOfRangeException("password Characters", passwordCharacters, "No es una cadena válida");

            var password = new char[passwordLength];

            // Use a 4-byte array to fill it with random bytes and convert it then to an integer value.
            byte[] randombytes = new byte[4];

            RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
            rng.GetBytes(randombytes);

            int seed = BitConverter.ToInt32(randombytes, 0);
            Random random = new Random(seed);

            for (int i = 0; i < passwordLength; i++)
                password[i] = passwordCharacters[random.Next(passwordCharacters.Length)];

            return new string(password);

        }

    }
}
