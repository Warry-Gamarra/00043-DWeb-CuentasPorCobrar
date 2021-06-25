using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public static class Constantes
    {
        public const int BANCO_COMERCIO_ID = 1;

        public const int BCP_ID = 2;
    }

    public static class FormatosDateTime
    {
        public const string BASIC_DATE = "dd/MM/yyyy";

        public const string BASIC_TIME = "HH:mm:ss";

        public const string BCO_COMERCIO_PAYMENT_DATE_FORMAT = "yyyyMMddHHmmss";

        public const string BCP_PAYMENT_DATE_FORMAT = "yyyyMMdd";
    }
}
