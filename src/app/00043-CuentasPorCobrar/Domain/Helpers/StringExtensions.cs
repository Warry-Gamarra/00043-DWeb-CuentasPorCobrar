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
    }
}
