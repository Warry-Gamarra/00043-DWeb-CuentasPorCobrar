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
    public class USP_U_AnularObligacionAlumno
    {
        public static ResponseData Execute(int obligacionAluID, int currentUserID)
        {
            ResponseData result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_U_AnularObligacionAlumno";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "I_ObligacionAluID", dbType: DbType.Int32, value: obligacionAluID);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserID);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.StoredProcedure);

                    result = new ResponseData();
                    result.Value = parameters.Get<bool>("B_Result");
                    result.Message = parameters.Get<string>("T_Message");
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
