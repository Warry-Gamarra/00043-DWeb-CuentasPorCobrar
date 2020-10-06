using Dapper;
using Data.Adapters;
using Data.Connection;
using Domain.DTO;
using Domain.Entities;
using Domain.Repository;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TS_CorreoAplicacion : IMailApplicationSD
    {
        public int I_CorreoID { get; set; }
        public string T_DireccionCorreo { get; set; }
        public string T_PasswordCorreo { get; set; }
        public string T_Seguridad { get; set; }
        public string T_HostName { get; set; }
        public int I_Puerto { get; set; }
        public bool B_Habilitado { get; set; }
        public DateTime D_FecUpdate { get; set; }

        public TS_CorreoAplicacion() { }

        public List<MailApplication> Find()
        {
            List<MailApplication> result = new List<MailApplication>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT I_CorreoID, T_DireccionCorreo, T_PasswordCorreo, T_Seguridad, T_HostName, I_Puerto, D_FecUpdate, B_Habilitado 
                                        FROM TS_CorreoAplicacion;";

                    foreach (var item in _dbConnection.Query<TS_CorreoAplicacion>(s_command, commandType: CommandType.Text))
                    {
                        result.Add(new TS_CorreoAplicacionAdapter(item));
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public MailApplication Get(int mailAppId)
        {
            MailApplication result = new MailApplication();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT I_CorreoID, T_DireccionCorreo, T_PasswordCorreo, T_Seguridad, T_HostName, I_Puerto, D_FecUpdate, B_Habilitado 
                                        FROM TS_CorreoAplicacion WHERE I_CorreoID = @I_CorreoID;";

                    var correo = _dbConnection.QueryFirstOrDefault<TS_CorreoAplicacion>(s_command, new { I_CorreoID = mailAppId}, commandType: CommandType.Text);

                    if (correo != null)
                    {
                        result = new TS_CorreoAplicacionAdapter(correo);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public Response Update(int currentUserId)
        {
            Response result = new Response();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    //parameters.Add(name: "N_EmailAccountID", dbType: DbType.Byte, value: this.I_CorreoID);
                    //parameters.Add(name: "T_EmailAddress", dbType: DbType.String, size: 50, value: model.T_DireccionCorreo);
                    //parameters.Add(name: "T_EmailPassword", dbType: DbType.String, size: 500, value: model.T_PasswordCorreo);
                    //parameters.Add(name: "T_SecurityType", dbType: DbType.String, size: 50, value: model.T_Seguridad);
                    //parameters.Add(name: "T_HostName", dbType: DbType.String, size: 500, value: model.T_HostName);
                    //parameters.Add(name: "N_PortNumber", dbType: DbType.Int16, value: model.I_Puerto);
                    //parameters.Add(name: "I_ProgramaID", dbType: DbType.Byte, value: model.I_ProgramaID);
                    parameters.Add(name: "IdUser", dbType: DbType.Int32, value: currentUserId);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_GrabarCuentaCorreo", parameters, commandType: CommandType.StoredProcedure);

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

        public Response ChangeState( int currentUserId)
        {
            Response result = new Response();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    //parameters.Add(name: "N_EmailAccountID", dbType: DbType.Byte, value: IdAccount);
                    //parameters.Add(name: "B_AccountState", dbType: DbType.Boolean, value: !B_habilitado);
                    parameters.Add(name: "IdUser", dbType: DbType.Int32, value: currentUserId);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoCuentaCorreo", parameters, commandType: CommandType.StoredProcedure);

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

        public Response Insert(int currentUserId)
        {
            Response result = new Response();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    //parameters.Add(name: "N_EmailAccountID", dbType: DbType.Byte, value: model.I_CorreoID);
                    //parameters.Add(name: "T_EmailAddress", dbType: DbType.String, size: 50, value: model.T_DireccionCorreo);
                    //parameters.Add(name: "T_EmailPassword", dbType: DbType.String, size: 500, value: model.T_PasswordCorreo);
                    //parameters.Add(name: "T_SecurityType", dbType: DbType.String, size: 50, value: model.T_Seguridad);
                    //parameters.Add(name: "T_HostName", dbType: DbType.String, size: 500, value: model.T_HostName);
                    //parameters.Add(name: "N_PortNumber", dbType: DbType.Int16, value: model.I_Puerto);
                    //parameters.Add(name: "I_ProgramaID", dbType: DbType.Byte, value: model.I_ProgramaID);
                    parameters.Add(name: "IdUser", dbType: DbType.Int32, value: currentUserId);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarCuentaCorreo", parameters, commandType: CommandType.StoredProcedure);

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
