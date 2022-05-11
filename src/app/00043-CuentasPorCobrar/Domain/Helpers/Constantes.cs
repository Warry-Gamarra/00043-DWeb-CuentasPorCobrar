using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public static class Bancos
    {
        public const int BANCO_COMERCIO_ID = 1;

        public const int BCP_ID = 2;
    }

    public static class FormatosDateTime
    {
        public const string BASIC_DATE = "dd/MM/yyyy";

        public const string BASIC_DATE2 = "dd-MM-yyyy";

        public const string BASIC_TIME = "HH:mm:ss";

        public const string BASIC_DATETIME = "dd/MM/yyyy HH:mm:ss";

        public const string PAYMENT_DATETIME_FORMAT = "yyyyMMddHHmmss";
    }

    public static class FormatosDecimal
    {
        public const string BASIC_DECIMAL = "#,0.00";
    }

    public static class ConstantesBCP
    {
        public const string CodExtorno = "E";
    }

    public static class EstadoObligacion
    {
        public static string ObtenerDescripcion(bool? pagado)
        {
            return pagado.HasValue ? (pagado.Value ? "Pagado" : "Pendiente") : "";
        }
    }

    public static class RoleNames
    {
        public const string ADMINISTRADOR = "Administrador";

        public const string CONSULTA = "Consulta";

        public const string CONTABILIDAD = "Contabilidad";

        public const string TESORERIA = "Tesorería";

        public const string DEPENDENCIA = "Dependencia";
    }

    public static class DependenciaEUPG
    {
        public const int ID = 14;
    }

}
