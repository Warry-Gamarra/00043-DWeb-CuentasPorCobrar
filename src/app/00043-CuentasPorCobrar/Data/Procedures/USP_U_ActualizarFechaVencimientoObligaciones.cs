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
    public class USP_U_ActualizarFechaVencimientoObligaciones
    {
        public DateTime D_NewFecVencto { get; set; }
        public DateTime D_OldFecVencto { get; set; }
        public int I_ProcesoID { get; set; }
        public int I_UsuarioMod { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_U_ActualizarFechaVencimientoObligaciones";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "D_NewFecVencto", dbType: DbType.Date, value: this.D_NewFecVencto);
                    parameters.Add(name: "D_OldFecVencto", dbType: DbType.Date, value: this.D_OldFecVencto);
                    parameters.Add(name: "I_ProcesoID", dbType: DbType.Int32, value: this.I_ProcesoID);
                    parameters.Add(name: "I_UsuarioMod", dbType: DbType.Int32, value: this.I_UsuarioMod);

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
