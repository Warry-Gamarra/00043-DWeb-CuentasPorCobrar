using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_S_ReportePagoObligacionesPosgrado
    {
        public string T_EscDesc { get; set; }
        public string C_CodEsc { get; set; }
        public int I_ConceptoID { get; set; }
        public string C_CodClasificador { get; set; }
        public string T_ClasificadorDesc { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public int I_Cantidad { get; set; }
        public decimal I_MontoTotal { get; set; }

        public static readonly int General = 1;
        public static readonly int PorConcepto = 2;
        public static readonly int PorGradoYConcepto = 3;
        public static readonly int ConceptoPorGrado = 4;

        public static IEnumerable<USP_S_ReportePagoObligacionesPosgrado> ReporteGeneral(
            DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPosgrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPosgrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: General);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);
                parameters.Add(name: "I_CtaDeposito", dbType: DbType.Int32, value: ctaDeposito);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ReportePagoObligacionesPosgrado>(s_command, parameters, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<USP_S_ReportePagoObligacionesPosgrado> ReportePorConceptos(
            DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPosgrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPosgrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: PorConcepto);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);
                parameters.Add(name: "I_CtaDeposito", dbType: DbType.Int32, value: ctaDeposito);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ReportePagoObligacionesPosgrado>(s_command, parameters, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<USP_S_ReportePagoObligacionesPosgrado> ReportePorGradoYConcepto(
            DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPosgrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPosgrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: PorGradoYConcepto);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);
                parameters.Add(name: "I_CtaDeposito", dbType: DbType.Int32, value: ctaDeposito);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ReportePagoObligacionesPosgrado>(s_command, parameters, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<USP_S_ReportePagoObligacionesPosgrado> ReporteConceptosPorGrado(
            string codEsc, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPosgrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPosgrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: ConceptoPorGrado);
                parameters.Add(name: "C_CodEsc", dbType: DbType.String, value: codEsc);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);
                parameters.Add(name: "I_CtaDeposito", dbType: DbType.Int32, value: ctaDeposito);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ReportePagoObligacionesPosgrado>(s_command, parameters, commandType: CommandType.StoredProcedure);
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
