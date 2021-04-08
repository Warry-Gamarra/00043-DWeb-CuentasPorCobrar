using Dapper;
using Data.Connection;
using Data.Types;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_I_GrabarPagoObligaciones
    { 
        public DateTime D_FecRegistro { get; set; }
        public int UserID { get; set; }
        private bool B_Result { get; }
        private string T_Message { get; }

        public ResponseData Execute(DataTable dataTable)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_I_GrabarPagoObligaciones";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "Tbl_Pagos", value: dataTable.AsTableValuedParameter("dbo.type_dataPago"));
                    parameters.Add(name: "D_FecRegistro", dbType: DbType.DateTime, value: this.D_FecRegistro);
                    parameters.Add(name: "UserID", dbType: DbType.Int32, value: this.UserID);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(s_command, param: parameters, commandType: CommandType.StoredProcedure);

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
