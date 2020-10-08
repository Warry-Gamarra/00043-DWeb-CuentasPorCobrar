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
    public class TS_CorreoAplicacion 
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


        public List<TS_CorreoAplicacion> Find()
        {
            List<TS_CorreoAplicacion> result = new List<TS_CorreoAplicacion>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT I_CorreoID, T_DireccionCorreo, T_PasswordCorreo, T_Seguridad, T_HostName, I_Puerto, D_FecUpdate, B_Habilitado 
                                        FROM TS_CorreoAplicacion;";

                    result = _dbConnection.Query<TS_CorreoAplicacion>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public TS_CorreoAplicacion Find(int correoAplicacionId)
        {
            TS_CorreoAplicacion result = new TS_CorreoAplicacion();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT I_CorreoID, T_DireccionCorreo, T_PasswordCorreo, T_Seguridad, T_HostName, I_Puerto, D_FecUpdate, B_Habilitado 
                                        FROM TS_CorreoAplicacion WHERE I_CorreoID = @I_CorreoID;";

                    result = _dbConnection.QueryFirstOrDefault<TS_CorreoAplicacion>(s_command, new { I_CorreoID = correoAplicacionId }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public ResponseData Update(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CorreoID", dbType: DbType.Byte, value: this.I_CorreoID);
                    parameters.Add(name: "T_DireccionCorreo", dbType: DbType.String, size: 50, value: this.T_DireccionCorreo);
                    parameters.Add(name: "T_PasswordCorreo", dbType: DbType.String, size: 500, value: this.T_PasswordCorreo);
                    parameters.Add(name: "T_Seguridad", dbType: DbType.String, size: 50, value: this.T_Seguridad);
                    parameters.Add(name: "T_HostName", dbType: DbType.String, size: 500, value: this.T_HostName);
                    parameters.Add(name: "I_Puerto", dbType: DbType.Int16, value: this.I_Puerto);
                    parameters.Add(name: "D_FecUpdate", dbType: DbType.DateTime, value: this.D_FecUpdate);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

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

        public ResponseData ChangeState(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CorreoID", dbType: DbType.Byte, value: this.I_CorreoID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecUpdate", dbType: DbType.DateTime, value: this.D_FecUpdate);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

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

        public ResponseData Insert(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CorreoID", dbType: DbType.Byte, value: this.I_CorreoID);
                    parameters.Add(name: "T_DireccionCorreo", dbType: DbType.String, size: 50, value: this.T_DireccionCorreo);
                    parameters.Add(name: "T_PasswordCorreo", dbType: DbType.String, size: 500, value: this.T_PasswordCorreo);
                    parameters.Add(name: "T_Seguridad", dbType: DbType.String, size: 50, value: this.T_Seguridad);
                    parameters.Add(name: "T_HostName", dbType: DbType.String, size: 500, value: this.T_HostName);
                    parameters.Add(name: "I_Puerto", dbType: DbType.Int16, value: this.I_Puerto);
                    parameters.Add(name: "D_FecUpdate", dbType: DbType.DateTime, value: this.D_FecUpdate);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

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
