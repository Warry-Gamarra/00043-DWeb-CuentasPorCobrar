using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TC_Usuario
    {
        public int UserId { get; set; }
        public string UserName { get; set; }
        public int? I_UsuarioCrea { get; set; }
        public int? I_DependenciaID { get; set; }
        public DateTime? D_FecActualiza { get; set; }
        public bool B_CambiaPassword { get; set; }
        public bool B_Habilitado { get; set; }


        public TC_Usuario Find(string username)
        {
            TC_Usuario result = new TC_Usuario();
            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT UserId, UserName, I_UsuarioCrea, B_CambiaPassword, B_Habilitado FROM TC_Usuarios WHERE UserName = @Username;";

                    result = _dbConnection.QuerySingleOrDefault<TC_Usuario>(s_command, new { UserName = username }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }


        public ResponseData ChangeState(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "UserId", dbType: DbType.Byte, value: this.UserId);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecActualiza", dbType: DbType.DateTime, value: this.D_FecActualiza);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoUsuario", parameters, commandType: CommandType.StoredProcedure);

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
