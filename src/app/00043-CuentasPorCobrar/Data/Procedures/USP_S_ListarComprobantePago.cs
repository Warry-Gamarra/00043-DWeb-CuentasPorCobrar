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
                s_command = "EXEC USP_S_ListarComprobantePago";

                parameters = new DynamicParameters();

                //if (idEntidadFinanciera.HasValue)
                //{
                //    filters = "WHERE t.I_EntidadFinanID = @I_EntidadFinanID ";

                //    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidadFinanciera);
                //}

                //if (idCtaDeposito.HasValue)
                //{
                //    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "t.I_CtaDepositoID = @I_CtaDepositoID ";

                //    parameters.Add(name: "I_CtaDepositoID", dbType: DbType.String, value: idCtaDeposito);
                //}

                //if (!String.IsNullOrWhiteSpace(codOperacion))
                //{
                //    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "t.C_CodOperacion = @C_CodOperacion ";

                //    parameters.Add(name: "C_CodOperacion", dbType: DbType.String, value: codOperacion);
                //}

                //if (!String.IsNullOrWhiteSpace(codDepositante))
                //{
                //    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "t.C_CodDepositante LIKE '%' + @C_CodDepositante + '%' ";

                //    parameters.Add(name: "C_CodDepositante", dbType: DbType.String, value: codDepositante);
                //}

                //if (!String.IsNullOrWhiteSpace(nomDepositante))
                //{
                //    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "t.T_NomDepositante LIKE '%' + @T_NomDepositante + '%' COLLATE Modern_Spanish_CI_AI ";

                //    parameters.Add(name: "T_NomDepositante", dbType: DbType.String, value: nomDepositante);
                //}

                //if (fechaInicio.HasValue)
                //{
                //    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "DATEDIFF(DAY, t.D_FecPago, @D_FechaInicio) <= 0 ";

                //    parameters.Add(name: "D_FechaInicio", dbType: DbType.DateTime, value: fechaInicio.Value);
                //}

                //if (fechaFinal.HasValue)
                //{
                //    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "DATEDIFF(DAY, t.D_FecPago, @D_FechaFin) >= 0";

                //    parameters.Add(name: "D_FechaFin", dbType: DbType.DateTime, value: fechaFinal.Value);
                //}

                //if (!String.IsNullOrWhiteSpace(codInterno))
                //{
                //    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "t.C_CodigoInterno LIKE '%' + @C_CodigoInterno ";

                //    parameters.Add(name: "C_CodigoInterno", dbType: DbType.String, value: codInterno);
                //}

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ListarComprobantePago>(s_command, parameters, commandType: CommandType.Text);
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
