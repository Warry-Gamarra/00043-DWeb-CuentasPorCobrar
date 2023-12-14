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
    public class USP_U_ActualizarEstadoSerieComprobante
    {
        public int I_SerieID { get; set; }

        public bool B_Habilitado { get; set; }

        public int UserID { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = "USP_U_ActualizarEstadoSerieComprobante";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_SerieID", dbType: DbType.Int32, value: this.I_SerieID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "UserID", dbType: DbType.Int32, value: this.UserID);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.StoredProcedure);

                    result.Value = parameters.Get<bool>("B_Result");
                    result.Message = parameters.Get<string>("T_Message");
                }
            }
            catch (Exception ex)
            {
                result.Value = false;
                result.Message = ex.Message;
            }

            return result;
        }
    }
}
