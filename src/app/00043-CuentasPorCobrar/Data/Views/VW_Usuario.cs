using Dapper;
using Data.Connection;
using Data.Tables;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Views
{
    public class VW_Usuario : TC_Usuario
    {
        public string N_NumDoc { get; set; }
        public int? I_DatosUsuarioID { get; set; }
        public string T_NomPersona { get; set; }
        public string T_CorreoUsuario { get; set; }
        public DateTime? D_FecAlta { get; set; }
        public int RoleId { get; set; }
        public string RoleName { get; set; }


        public List<VW_Usuario> Find()
        {
            List<VW_Usuario> result = new List<VW_Usuario>();
            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT U.UserId, U.UserName, U.I_UsuarioCrea, U.D_FecActualiza, U.B_CambiaPassword, U.B_Habilitado, DU.I_DatosUsuarioID, DU.N_NumDoc, 
                                                DU.T_NomPersona, DU.T_CorreoUsuario, UDU.D_FecAlta, UIR.RoleId, R.RoleName, U.I_DependenciaID
                                           FROM [dbo].[TC_Usuarios] U
                                                INNER JOIN [dbo].[webpages_UsersInRoles] UIR ON U.UserId = UIR.UserId
	                                            INNER JOIN [dbo].[webpages_Roles] R ON UIR.RoleId = R.RoleId
												LEFT JOIN [dbo].[TI_UsuarioDatosUsuario] UDU ON UDU.UserId = U.UserId AND UDU.B_Habilitado = 1
	                                            LEFT JOIN [dbo].[TC_DatosUsuario] DU ON DU.I_DatosUsuarioID = UDU.I_DatosUsuarioID AND DU.B_Habilitado = 1";

                    result = _dbConnection.Query<VW_Usuario>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public VW_Usuario Find(int userId)
        {
            VW_Usuario result = new VW_Usuario();
            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT U.UserId, U.UserName, U.I_UsuarioCrea, U.D_FecActualiza, U.B_CambiaPassword, U.B_Habilitado, DU.I_DatosUsuarioID, DU.N_NumDoc, 
                                                DU.T_NomPersona, DU.T_CorreoUsuario, UDU.D_FecAlta, UIR.RoleId, R.RoleName, U.I_DependenciaID
                                           FROM [dbo].[TC_Usuarios] U
                                                INNER JOIN [dbo].[webpages_UsersInRoles] UIR ON U.UserId = UIR.UserId
	                                            INNER JOIN [dbo].[webpages_Roles] R ON UIR.RoleId = R.RoleId
												LEFT JOIN [dbo].[TI_UsuarioDatosUsuario] UDU ON UDU.UserId = U.UserId AND UDU.B_Habilitado = 1
	                                            LEFT JOIN [dbo].[TC_DatosUsuario] DU ON DU.I_DatosUsuarioID = UDU.I_DatosUsuarioID AND DU.B_Habilitado = 1
                                          WHERE U.UserId = @UserId";

                    result = _dbConnection.QuerySingleOrDefault<VW_Usuario>(s_command, new { UserId = userId }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public ResponseData Update()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_DatosUsuarioID", dbType: DbType.Int32, value: this.I_DatosUsuarioID);
                    parameters.Add(name: "N_NumDoc", dbType: DbType.String, size: 50, value: this.N_NumDoc);
                    parameters.Add(name: "T_NomPersona", dbType: DbType.String, size: 500, value: this.T_NomPersona);
                    parameters.Add(name: "T_CorreoUsuario", dbType: DbType.String, size: 50, value: this.T_CorreoUsuario);
                    parameters.Add(name: "I_DependenciaID", dbType: DbType.Int32, value: this.I_DependenciaID);
                    parameters.Add(name: "D_FecRegistro", dbType: DbType.DateTime, size: 500, value: this.D_FecActualiza);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "UserId", dbType: DbType.Int32, value: this.UserId);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: this.I_UsuarioCrea);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_GrabarDatosUsuario", parameters, commandType: CommandType.StoredProcedure);

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

        public ResponseData Insert()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_DatosUsuarioID", dbType: DbType.Int16, value: this.I_DatosUsuarioID);
                    parameters.Add(name: "N_NumDoc", dbType: DbType.String, size: 50, value: this.N_NumDoc);
                    parameters.Add(name: "T_NomPersona", dbType: DbType.String, size: 500, value: this.T_NomPersona);
                    parameters.Add(name: "T_CorreoUsuario", dbType: DbType.String, size: 50, value: this.T_CorreoUsuario);
                    parameters.Add(name: "D_FecRegistro", dbType: DbType.DateTime, size: 500, value: this.D_FecActualiza);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "UserId", dbType: DbType.Int32, value: this.UserId);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: this.I_UsuarioCrea);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarDatosUsuario", parameters, commandType: CommandType.StoredProcedure);

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
