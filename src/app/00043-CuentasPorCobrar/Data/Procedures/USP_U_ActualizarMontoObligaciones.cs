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
    public class USP_U_ActualizarMontoObligaciones
    {
        public static ResponseData Execute(int obligacionAluDetID, decimal monto, int tipoDocumento, string documento, int userID)
        {
            ResponseData result;
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_U_ActualizarMontoObligaciones";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "I_ObligacionAluDetID", dbType: DbType.Int32, value: obligacionAluDetID);
                    parameters.Add(name: "I_Monto", dbType: DbType.Decimal, value: monto);
                    parameters.Add(name: "I_TipoDocumento", dbType: DbType.Int32, value: tipoDocumento);
                    parameters.Add(name: "T_DescDocumento", dbType: DbType.String, value: documento);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: userID);
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
