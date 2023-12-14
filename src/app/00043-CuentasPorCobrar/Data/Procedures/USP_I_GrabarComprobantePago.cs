using Dapper;
using Data.Connection;
using Data.Types;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_I_GrabarComprobantePago
    {
        public int I_TipoComprobanteID { get; set; }
        
        public int I_SerieID { get; set; }

        public bool B_EsGravado { get; set; }

        public int UserID { get; set; }

        public ResponseData Execute(DataTable dataTable)
        {
            ResponseData result;
            DynamicParameters parameters;

            try
            {
                string s_command = "USP_I_GrabarComprobantePago";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "PagoBancoIDs", value: dataTable.AsTableValuedParameter("dbo.type_Ids"));
                    parameters.Add(name: "I_TipoComprobanteID", dbType: DbType.Int32, value: I_TipoComprobanteID);
                    parameters.Add(name: "I_SerieID", dbType: DbType.Int32, value: I_SerieID);
                    parameters.Add(name: "B_EsGravado", dbType: DbType.Boolean, value: B_EsGravado);
                    parameters.Add(name: "UserID", dbType: DbType.Int32, value: UserID);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(s_command, param: parameters, commandType: CommandType.StoredProcedure);

                    result = new ResponseData()
                    {
                        Value = parameters.Get<bool>("B_Result"),
                        Message = parameters.Get<string>("T_Message")
                    };
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }
    }
}
