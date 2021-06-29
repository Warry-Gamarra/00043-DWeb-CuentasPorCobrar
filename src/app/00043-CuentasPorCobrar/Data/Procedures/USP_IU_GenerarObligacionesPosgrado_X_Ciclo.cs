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
    public class USP_IU_GenerarObligacionesPosgrado_X_Ciclo
    {
        public int I_Anio { get; set; }
        public int I_Periodo { get; set; }
        public string C_CodEsc { get; set; }
        public string C_CodAlu { get; set; }
        public string C_CodRc { get; set; }
        public int I_UsuarioCre { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_IU_GenerarObligacionesPosgrado_X_Ciclo";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_Anio", dbType: DbType.Int32, value: this.I_Anio);
                    parameters.Add(name: "I_Periodo", dbType: DbType.Int16, value: this.I_Periodo);
                    parameters.Add(name: "C_CodEsc", dbType: DbType.String, value: this.C_CodEsc);
                    parameters.Add(name: "C_CodAlu", dbType: DbType.String, value: this.C_CodAlu);
                    parameters.Add(name: "C_CodRc", dbType: DbType.String, value: this.C_CodRc);
                    parameters.Add(name: "I_UsuarioCre", dbType: DbType.Int32, value: this.I_UsuarioCre);
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
