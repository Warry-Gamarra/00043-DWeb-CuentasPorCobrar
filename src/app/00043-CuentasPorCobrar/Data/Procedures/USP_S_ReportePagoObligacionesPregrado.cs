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
        public string T_ClasificadorDesc { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public int I_Cantidad { get; set; }
        public decimal I_MontoTotal { get; set; }

        public static readonly int General = 1;
        public static readonly int PorConcepto = 2;
        public static readonly int PorFacultadYConcepto = 3;
        public static readonly int ConceptoPorFacultad = 4;
        

        public static IEnumerable<USP_S_ReportePagoObligacionesPregrado> ReporteGeneral(
            DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPregrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPregrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: General);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);
                parameters.Add(name: "I_CtaDeposito", dbType: DbType.Int32, value: ctaDeposito);

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

        public static IEnumerable<USP_S_ReportePagoObligacionesPregrado> ReportePorConceptos(
            DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPregrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPregrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: PorConcepto);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);
                parameters.Add(name: "I_CtaDeposito", dbType: DbType.Int32, value: ctaDeposito);

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

        public static IEnumerable<USP_S_ReportePagoObligacionesPregrado> ReportePorFacultadYConcepto(
            DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPregrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPregrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: PorFacultadYConcepto);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);
                parameters.Add(name: "I_CtaDeposito", dbType: DbType.Int32, value: ctaDeposito);

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

        public static IEnumerable<USP_S_ReportePagoObligacionesPregrado> ReporteConceptosPorFacultad(
            string codFac, DateTime fechaInicio, DateTime fechaFin, int? idEntidanFinanc, int? ctaDeposito)
        {
            IEnumerable<USP_S_ReportePagoObligacionesPregrado> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_ReportePagoObligacionesPregrado";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_TipoReporte", dbType: DbType.Int32, value: ConceptoPorFacultad);
                parameters.Add(name: "C_CodFac", dbType: DbType.String, value: codFac);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);
                parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: idEntidanFinanc);
                parameters.Add(name: "I_CtaDeposito", dbType: DbType.Int32, value: ctaDeposito);

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
