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
        public int UserID { get; set; }
        private bool B_Result { get; }
        private string T_Message { get; }

        public GrabacionPagoObligacionesResponse Execute(DataTable dataTable, int UserID)
        {
            GrabacionPagoObligacionesResponse response = new GrabacionPagoObligacionesResponse();
            DynamicParameters parameters;

            try
            {
                string s_command = @"USP_I_GrabarPagoObligaciones";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "Tbl_Pagos", value: dataTable.AsTableValuedParameter("dbo.type_dataPago"));
                    parameters.Add(name: "D_FecRegistro", dbType: DbType.DateTime, value: DateTime.Now);
                    parameters.Add(name: "UserID", dbType: DbType.Int32, value: UserID);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    response.resultList = _dbConnection.Query<DataPagoObligacionesResult>(s_command, param: parameters, commandType: CommandType.StoredProcedure);

                    response.Success = parameters.Get<bool>("B_Result");
                    response.Message = parameters.Get<string>("T_Message");
                }
            }
            catch (Exception ex)
            {
                response.Success = false;
                response.Message = ex.Message;
            }

            return response;
        }
    }
}
