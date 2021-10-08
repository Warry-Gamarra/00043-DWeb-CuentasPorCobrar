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
    public class USP_S_RelacionarPagoConObligacion
    {
        public static ResponseData Execute(int UserID)
        {
            ResponseData result = null;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_S_RelacionarPagoConObligacion";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();

                    parameters.Add(name: "UserID", dbType: DbType.Int32, value: UserID);

                    result = _dbConnection.Query<ResponseData>(s_command, param: parameters, commandType: CommandType.StoredProcedure).FirstOrDefault();
                }
            }
            catch (Exception ex)
            {
                result = new ResponseData();
                result.Value = false;
                result.Message = ex.Message;
            }

            return result;
        }
    }
}
