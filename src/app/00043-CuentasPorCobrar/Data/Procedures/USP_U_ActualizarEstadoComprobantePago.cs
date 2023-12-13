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
    public class USP_U_ActualizarEstadoComprobantePago
    {
        public int I_NumeroSerie { get; set; }

        public int I_NumeroComprobante { get; set; }

        public string C_EstadoComprobanteCod { get; set; }

        public int UserID { get; set; }

        public ResponseData Execute()
        {
            ResponseData result;
            DynamicParameters parameters;

            try
            {
                string s_command = "USP_U_ActualizarEstadoComprobantePago";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "I_NumeroSerie", dbType: DbType.Int32, value: I_NumeroSerie);
                    parameters.Add(name: "I_NumeroComprobante", dbType: DbType.Int32, value: I_NumeroComprobante);
                    parameters.Add(name: "C_EstadoComprobanteCod", dbType: DbType.String, value: C_EstadoComprobanteCod);
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
