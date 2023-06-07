using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Views
{
    public class VW_PagoTasas
    {
        public int I_PagoBancoID { get; set; }

        public int I_TasaUnfvID { get; set; }

        public int I_EntidadFinanID { get; set; }

        public string T_EntidadDesc { get; set; }

        public int I_CtaDepositoID { get; set; }

        public string C_NumeroCuenta { get; set; }

        public string C_CodTasa { get; set; }

        public string T_ConceptoPagoDesc { get; set; }

        public string T_Clasificador { get; set; }

        public string C_CodClasificador { get; set; }

        public string T_ClasificadorDesc { get; set; }

        public decimal? M_Monto { get; set; }

        public string C_CodOperacion { get; set; }

        public string C_CodDepositante { get; set; }

        public string T_NomDepositante { get; set; }

        public DateTime D_FecPago { get; set; }

        public decimal I_MontoPagado { get; set; }

        public decimal I_InteresMoratorio { get; set; }

        public DateTime D_FecCre { get; set; }
        
        public DateTime? D_FecMod { get; set; }

        public string C_CodigoInterno { get; set; }

        public string T_Observacion { get; set; }

        public int? I_AnioConstancia { get; set; }

        public int? I_NroConstancia { get;set; }

        public static IEnumerable<VW_PagoTasas> GetAll(int? idEntidadFinanciera, int? idCtaDeposito, string codOperacion, DateTime? fechaInicio, DateTime? fechaFinal,
                string codDepositante, string nomDepositante, string codInterno)
        {
            string s_command, filters;
            IEnumerable<VW_PagoTasas> result;
            DynamicParameters parameters;
            
            try
            {
                s_command = "SELECT t.* FROM dbo.VW_PagoTasas t ";

                filters = "";

                parameters = new DynamicParameters();

                if (idEntidadFinanciera.HasValue)
                {
                    filters = "WHERE t.I_EntidadFinanID = @I_EntidadFinanID ";

                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidadFinanciera);
                }

                if (idCtaDeposito.HasValue)
                {
                    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "t.I_CtaDepositoID = @I_CtaDepositoID ";

                    parameters.Add(name: "I_CtaDepositoID", dbType: DbType.String, value: idCtaDeposito);
                }

                if (!String.IsNullOrWhiteSpace(codOperacion))
                {
                    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "t.C_CodOperacion = @C_CodOperacion ";

                    parameters.Add(name: "C_CodOperacion", dbType: DbType.String, value: codOperacion);
                }

                if (!String.IsNullOrWhiteSpace(codDepositante))
                {
                    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "t.C_CodDepositante LIKE '%' + @C_CodDepositante + '%' ";

                    parameters.Add(name: "C_CodDepositante", dbType: DbType.String, value: codDepositante);
                }

                if (!String.IsNullOrWhiteSpace(nomDepositante))
                {
                    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "t.T_NomDepositante LIKE '%' + @T_NomDepositante + '%' COLLATE Modern_Spanish_CI_AI ";

                    parameters.Add(name: "T_NomDepositante", dbType: DbType.String, value: nomDepositante);
                }

                if (fechaInicio.HasValue)
                {
                    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "DATEDIFF(DAY, t.D_FecPago, @D_FechaInicio) <= 0 ";

                    parameters.Add(name: "D_FechaInicio", dbType: DbType.DateTime, value: fechaInicio.Value);
                }

                if (fechaFinal.HasValue)
                {
                    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "DATEDIFF(DAY, t.D_FecPago, @D_FechaFin) >= 0";

                    parameters.Add(name: "D_FechaFin", dbType: DbType.DateTime, value: fechaFinal.Value);
                }

                if (!String.IsNullOrWhiteSpace(codInterno))
                {
                    filters = filters + (filters.Length == 0 ? "WHERE " : "AND ") + "t.C_CodigoInterno LIKE '%' + @C_CodigoInterno ";

                    parameters.Add(name: "C_CodigoInterno", dbType: DbType.String, value: codInterno);
                }

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_PagoTasas>(s_command + filters, parameters, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static VW_PagoTasas FindByID(int I_PagoBancoID)
        {
            string s_command;
            VW_PagoTasas result;
            DynamicParameters parameters;

            try
            {
                s_command = "SELECT t.* FROM dbo.VW_PagoTasas t WHERE t.I_PagoBancoID = @I_PagoBancoID";

                parameters = new DynamicParameters();

                parameters.Add(name: "I_PagoBancoID", dbType: DbType.Int32, value: I_PagoBancoID);
                
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.QueryFirstOrDefault<VW_PagoTasas>(s_command, parameters, commandType: CommandType.Text);
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
