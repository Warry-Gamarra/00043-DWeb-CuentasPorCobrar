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
    public class USP_S_PagosPorFacultadYFecha
    {
        public string C_CodFac { get; set; }
        public int I_ConceptoID { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public decimal I_MontoTotal { get; set; }

        public static IEnumerable<USP_S_PagosPorFacultadYFecha> Execute(string codFac, DateTime fechaInicio, DateTime fechaFin)
        {
            IEnumerable<USP_S_PagosPorFacultadYFecha> result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_PagosPorFacultadYFecha";

                parameters = new DynamicParameters();
                parameters.Add(name: "C_CodFac", dbType: DbType.String, value: codFac);
                parameters.Add(name: "D_FechaIni", dbType: DbType.Date, value: fechaInicio);
                parameters.Add(name: "D_FechaFin", dbType: DbType.Date, value: fechaFin);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_PagosPorFacultadYFecha>(s_command, parameters, commandType: CommandType.StoredProcedure);
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
