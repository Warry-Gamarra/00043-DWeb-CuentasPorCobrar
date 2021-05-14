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
    public class USP_S_PagosGeneralPorFecha
    {
        public int I_ConceptoID { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public decimal I_MontoTotal { get; set; }

        public static IEnumerable<USP_S_PagosGeneralPorFecha> Execute(DateTime fechaInicio, DateTime fechaFin)
        {
            IEnumerable<USP_S_PagosGeneralPorFecha> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_PagosGeneralPorFecha";

                parameters = new DynamicParameters();
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);


                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_PagosGeneralPorFecha>(s_command, parameters, commandType: CommandType.StoredProcedure);
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
