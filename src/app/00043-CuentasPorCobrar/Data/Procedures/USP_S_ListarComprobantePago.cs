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

        public int? I_ComprobanteID { get; set; }

        public int? I_NumeroSerie { get; set; }

        public int? I_NumeroComprobante { get; set; }

        public DateTime? D_FechaEmision { get; set; }

        public bool? B_EsGravado { get; set; }

        public string C_TipoComprobanteCod { get; set; }

        public string T_TipoComprobanteDesc { get; set; }

        public string T_EstadoComprobanteDesc { get; set; }

        public static IEnumerable<USP_S_ListarComprobantePago> GetAll(int? I_TipoPagoID, int? I_EntidadFinanID, int? I_CtaDepositoID, string C_CodOperacion, 
            string C_CodigoInterno, string C_CodDepositante, string T_NomDepositante, DateTime? D_FechaInicio, DateTime? D_FechaFin, 
            int? I_TipoComprobanteID, bool? I_EstadoGeneracion, int? I_EstadoComprobanteID)
        {
            string s_command;
            IEnumerable<USP_S_ListarComprobantePago> result;
            DynamicParameters parameters;

            try
            {
                s_command = "USP_S_ListarComprobantePago";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoPagoID", dbType: DbType.Int32, value: I_TipoPagoID);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: I_EntidadFinanID);
                parameters.Add(name: "I_CtaDepositoID", dbType: DbType.Int32, value: I_CtaDepositoID);
                parameters.Add(name: "C_CodOperacion", dbType: DbType.String, value: C_CodOperacion);
                parameters.Add(name: "C_CodigoInterno", dbType: DbType.String, value: C_CodigoInterno);
                parameters.Add(name: "C_CodDepositante", dbType: DbType.String, value: C_CodDepositante);
                parameters.Add(name: "T_NomDepositante", dbType: DbType.String, value: T_NomDepositante);
                parameters.Add(name: "D_FechaInicio", dbType: DbType.DateTime, value: D_FechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.DateTime, value: D_FechaFin);
                parameters.Add(name: "I_TipoComprobanteID", dbType: DbType.Int32, value: I_TipoComprobanteID);
                parameters.Add(name: "I_EstadoGeneracion", dbType: DbType.Boolean, value: I_EstadoGeneracion);
                parameters.Add(name: "I_EstadoComprobanteID", dbType: DbType.Int32, value: I_EstadoComprobanteID);

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
