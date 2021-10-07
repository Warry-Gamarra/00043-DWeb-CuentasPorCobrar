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
    public class USP_IU_RelacionarPagoConObligacion
    {
        public static ResponseData Execute(int obligacionID, int pagoBancoID, int UserID)
        {
            ResponseData result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_IU_RelacionarPagoConObligacion";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "I_ObligacionAluID", dbType: DbType.Int32, value: obligacionID);
                    parameters.Add(name: "I_PagoBancoID", dbType: DbType.Int32, value: pagoBancoID);
                    parameters.Add(name: "UserID", dbType: DbType.Int32, value: UserID);
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
