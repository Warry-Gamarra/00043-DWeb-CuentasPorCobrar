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
    public class USP_IU_GrabarMatricula
    {
        public int UserID { get; set; }
        public DateTime D_FecRegistro { get; set; }



        public ResponseData Execute(IEnumerable<DataMatriculaType> dataMatricula)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    //parameters.Add(name: "Tbl_Matricula", value: dataTable.AsTableValuedParameter("dbo.type_dataMatricula"));
                    parameters.Add(name: "Tbl_Matricula", value: dataMatricula.);
                    parameters.Add(name: "D_FecRegistro", dbType: DbType.DateTime, value: this.D_FecRegistro);

                    parameters.Add(name: "UserID", dbType: DbType.Int32, value: this.UserID);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_IU_GrabarMatricula", parameters, commandType: CommandType.StoredProcedure);

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
