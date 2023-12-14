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
    public class USP_I_GrabarTipoComprobante
    {
        public string C_TipoComprobanteCod { get; set; }

        public string T_TipoComprobanteDesc { get; set; }

        public string T_Inicial { get; set; }

        public int UserID { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = "USP_I_GrabarTipoComprobante";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "C_TipoComprobanteCod", dbType: DbType.String, value: this.C_TipoComprobanteCod);
                    parameters.Add(name: "T_TipoComprobanteDesc", dbType: DbType.String, value: this.T_TipoComprobanteDesc);
                    parameters.Add(name: "T_Inicial", dbType: DbType.String, value: this.T_Inicial);
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
