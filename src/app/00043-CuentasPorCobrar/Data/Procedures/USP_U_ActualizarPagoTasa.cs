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
    public class USP_U_ActualizarPagoTasa
    {
        public int I_PagoBancoID { get; set; }
        public string C_CodDepositante { get; set; }
        public int I_TasaUnfvId { get; set; }
        public int I_CurrentUserID { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_U_ActualizarPagoTasa";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_PagoBancoID", dbType: DbType.Int32, value: this.I_PagoBancoID);
                    parameters.Add(name: "C_CodDepositante", dbType: DbType.String, value: this.C_CodDepositante);
                    parameters.Add(name: "I_TasaUnfvId", dbType: DbType.Int32, value: this.I_TasaUnfvId);
                    parameters.Add(name: "I_CurrentUserID", dbType: DbType.Int32, value: this.I_CurrentUserID);
                    
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
