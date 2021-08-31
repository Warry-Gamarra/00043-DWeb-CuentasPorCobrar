using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public static class StringExtensions
    {
        public static string SinCaracteresEspecialies(string texto)
        {
            return new String(
                    texto.Normalize(NormalizationForm.FormD)
                    .Where(c => CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
                    .ToArray()
                )
                .Normalize(NormalizationForm.FormC)
                .Replace('\'', ' ');
        }

        public static string Substring2(this string text, int startIndex, int length)
        {
            if (length > text.Length)
            {
                length = text.Length;
            }

            return text.Substring(startIndex, length);
        }

    }
}
