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
    public class USP_S_ReportePagoObligacionesPregrado
    {
        public string T_FacDesc { get; set; }
        public string C_CodFac { get; set; }
        public int I_ConceptoID { get; set; }
        public string C_CodClasificador { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public int I_Cantidad { get; set; }
        public decimal I_MontoTotal { get; set; }

        public static readonly int AgrupaPorFacultad = 1;
        public static readonly int AgrupaPorConcepto = 2;
        public static readonly int ConceptoPorUnaFacultad = 3;

        public static IEnumerable<USP_S_ReportePagoObligacionesPregrado> PagosPorFacultad(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPregrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPregrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: AgrupaPorFacultad);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ReportePagoObligacionesPregrado>(s_command, parameters, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<USP_S_ReportePagoObligacionesPregrado> PagosPorConcepto(DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPregrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPregrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: AgrupaPorConcepto);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ReportePagoObligacionesPregrado>(s_command, parameters, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<USP_S_ReportePagoObligacionesPregrado> ConceptosPorUnaFacultad(string codFac, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPregrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPregrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: ConceptoPorUnaFacultad);
                parameters.Add(name: "C_CodFac", dbType: DbType.String, value: codFac);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ReportePagoObligacionesPregrado>(s_command, parameters, commandType: CommandType.StoredProcedure);
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
