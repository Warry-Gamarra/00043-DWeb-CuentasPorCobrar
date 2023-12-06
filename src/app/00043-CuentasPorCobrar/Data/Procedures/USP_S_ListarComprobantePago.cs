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
    public class USP_S_ListarComprobantePago
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

        public int? I_ComprobantePagoID { get; set; }

        public int? I_NumeroSerie { get; set; }

        public int? I_NumeroComprobante { get; set; }

        public DateTime? D_FechaEmision { get; set; }

        public bool? B_EsGravado { get; set; }

        public string T_TipoComprobanteDesc { get; set; }

        public string T_EstadoComprobanteDesc { get; set; }

        public static IEnumerable<USP_S_ListarComprobantePago> GetAll(int? tipoPago, int? idEntidadFinanciera, int? idCtaDeposito, string codOperacion, string codInterno, 
            string codDepositante, string nomDepositante, DateTime? fechaInicio, DateTime? fechaFinal)
        {
            string s_command;
            IEnumerable<USP_S_ListarComprobantePago> result;
            DynamicParameters parameters;

            try
            {
                s_command = "USP_S_ListarComprobantePago";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoPagoID", dbType: DbType.Int32, value: tipoPago);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidadFinanciera);
                parameters.Add(name: "I_CtaDepositoID", dbType: DbType.Int32, value: idCtaDeposito);
                parameters.Add(name: "C_CodOperacion", dbType: DbType.String, value: codOperacion);
                parameters.Add(name: "C_CodigoInterno", dbType: DbType.String, value: codInterno);
                parameters.Add(name: "C_CodDepositante", dbType: DbType.String, value: codDepositante);
                parameters.Add(name: "T_NomDepositante", dbType: DbType.String, value: nomDepositante);
                parameters.Add(name: "D_FechaInicio", dbType: DbType.DateTime, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.DateTime, value: fechaFinal);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ListarComprobantePago>(s_command, parameters, commandType: CommandType.StoredProcedure);
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
