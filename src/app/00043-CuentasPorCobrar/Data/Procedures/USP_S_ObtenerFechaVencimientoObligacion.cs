using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_S_ObtenerFechaVencimientoObligacion
    {
        public static IEnumerable<DateTime> Execute(int I_ProcesoID)
        {
            IEnumerable<DateTime> result;

            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_S_ObtenerFechaVencimientoObligacion";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_ProcesoID", dbType: DbType.Int32, value: I_ProcesoID);

                    result = _dbConnection.Query<DateTime>(s_command, parameters, commandType: CommandType.StoredProcedure);
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
