using Dapper;
using Data.Connection;
using Data.Views;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_S_ObtenerComprobantePago
    {
        public int I_PagoBancoID { get; set; }

        public int I_EntidadFinanID { get; set; }

        public string T_EntidadDesc { get; set; }

        public string C_NumeroCuenta { get; set; }

        public string C_CodOperacion { get; set; }

        public string C_CodigoInterno { get; set; }

        public string C_CodDepositante { get; set; }

        public string T_NomDepositante { get; set; }

        public DateTime D_FecPago { get; set; }

        public decimal I_MontoPago { get; set; }

        public decimal I_InteresMora { get; set; }

        public string T_Condicion { get; set; }

        public int I_TipoPagoID { get; set; }

        public int? I_ComprobanteID { get; set; }

        public int? I_NumeroSerie { get; set; }

        public int? I_NumeroComprobante { get; set; }

        public DateTime? D_FechaEmision { get; set; }

        public bool? B_EsGravado { get; set; }

        public string C_TipoComprobanteCod { get;set; }

        public string T_TipoComprobanteDesc { get; set; }

        public string T_EstadoComprobanteDesc { get; set; }

        public static IEnumerable<USP_S_ObtenerComprobantePago> GetAll(int pagoBancoID)
        {
            string s_command;
            IEnumerable<USP_S_ObtenerComprobantePago> result;
            DynamicParameters parameters;

            try
            {
                s_command = "USP_S_ObtenerComprobantePago";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_PagoBancoID", dbType: DbType.Int32, value: pagoBancoID);
                
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ObtenerComprobantePago>(s_command, parameters, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }
    }
}
