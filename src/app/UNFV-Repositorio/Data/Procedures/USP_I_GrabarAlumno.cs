using Dapper;
using Data.Connection;
using Data.DTO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_I_GrabarAlumno
    {
        public bool B_Habilitado { get; set; }
        public int I_UsuarioCre { get; set; }

        public ResponseData Execute()
        {
            ResponseData result;
            DynamicParameters parameters;
            string command;

            try
            {
                command = "USP_I_GrabarAlumno";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "I_UsuarioCre", dbType: DbType.Int32, value: this.I_UsuarioCre);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(command, parameters, commandType: CommandType.StoredProcedure);

                    result = new ResponseData();
                    result.Value = parameters.Get<bool>("B_Result");
                    result.Message = parameters.Get<string>("T_Message");
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
