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
        public string T_Clasificador { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public int I_Cantidad { get; set; }
        public decimal I_MontoTotal { get; set; }

        public static readonly int AgrupaPorGrado = 1;
        public static readonly int AgrupaPorConcepto = 2;
        public static readonly int ConceptoPorGrado = 3;

        public static IEnumerable<USP_S_ReportePagoObligacionesPosgrado> PagosPorGrado(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPosgrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPosgrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: AgrupaPorGrado);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);

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

        public static IEnumerable<USP_S_ReportePagoObligacionesPosgrado> PagosPorConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPosgrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPosgrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: AgrupaPorConcepto);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);

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

        public static IEnumerable<USP_S_ReportePagoObligacionesPosgrado> ConceptosPorGrado(string codEsc, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
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
