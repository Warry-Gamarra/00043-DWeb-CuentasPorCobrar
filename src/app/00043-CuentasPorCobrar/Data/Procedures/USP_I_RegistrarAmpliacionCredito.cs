using Dapper;
using Data.Connection;
using Data.Types;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_I_RegistrarAmpliacionCredito
    {
        public int I_ProcesoID { get; set; }

        public int I_MatAluID { get; set; }

        public DateTime D_FecVencto { get; set; }

        public int I_TipoDocumento { get; set; }

        public string T_DescDocumento { get; set; }

        public int UserID { get; set; }

        public ResponseData Execute(DataTable dataTable)
        {
            ResponseData response;
            DynamicParameters parameters;

            try
            {
                string s_command = "USP_I_RegistrarAmpliacionCredito";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "ConceptosObligacion", value: dataTable.AsTableValuedParameter("dbo.type_ConceptosObligacion"));
                    parameters.Add(name: "I_ProcesoID", dbType: DbType.Int32, value: I_ProcesoID);
                    parameters.Add(name: "I_MatAluID", dbType: DbType.Int32, value: I_MatAluID);
                    parameters.Add(name: "D_FecVencto", dbType: DbType.DateTime, value: D_FecVencto);
                    parameters.Add(name: "I_TipoDocumento", dbType: DbType.Int32, value: I_TipoDocumento);
                    parameters.Add(name: "T_DescDocumento", dbType: DbType.String, value: T_DescDocumento);
                    parameters.Add(name: "UserID", dbType: DbType.Int32, value: UserID);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    var result = _dbConnection.Execute(s_command, param: parameters, commandType: CommandType.StoredProcedure);

                    response = new ResponseData();
                    response.Value = parameters.Get<bool>("B_Result");
                    response.Message = parameters.Get<string>("T_Message");
                }
            }
            catch (Exception ex)
            {
                response = new ResponseData()
                {
                    Message = ex.Message
                };
            }

            return response;
        }
    }
}
