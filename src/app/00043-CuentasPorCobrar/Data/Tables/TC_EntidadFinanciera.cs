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
    public class TC_EntidadFinanciera
    {
        public int I_EntidadFinanID { get; set; }
        public string T_EntidadDesc { get; set; }
        public bool B_Habilitado { get; set; }
        public bool? B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }


        public List<TC_EntidadFinanciera> Find()
        {
            List<TC_EntidadFinanciera> result = new List<TC_EntidadFinanciera>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT I_EntidadFinanID, T_EntidadDesc, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_UsuarioMod, D_FecMod 
                                        FROM TC_EntidadFinanciera WHERE B_Eliminado = 0;";

                    result = _dbConnection.Query<TC_EntidadFinanciera>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public TC_EntidadFinanciera Find(int entidadFinanId)
        {
            TC_EntidadFinanciera result = new TC_EntidadFinanciera();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT I_EntidadFinanID, T_EntidadDesc, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre, I_UsuarioMod, D_FecMod
                                        FROM TC_EntidadFinanciera WHERE I_EntidadFinanID = @I_EntidadFinanID;";

                    result = _dbConnection.QueryFirstOrDefault<TC_EntidadFinanciera>(s_command, new { I_EntidadFinanID = entidadFinanId }, commandType: CommandType.Text);
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
                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Byte, value: this.I_EntidadFinanID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoEntidadFinanciera", parameters, commandType: CommandType.StoredProcedure);

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

        public ResponseData Insert(bool enableFiles, int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Byte, value: this.I_EntidadFinanID);
                    parameters.Add(name: "T_EntidadDesc", dbType: DbType.String, size: 250, value: this.T_EntidadDesc);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "B_Archivos", dbType: DbType.Boolean, value: enableFiles);
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecCre);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarEntidadFinanciera", parameters, commandType: CommandType.StoredProcedure);

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

        public ResponseData Update(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Byte, value: this.I_EntidadFinanID);
                    parameters.Add(name: "T_EntidadDesc", dbType: DbType.String, size: 250, value: this.T_EntidadDesc);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEntidadFinanciera", parameters, commandType: CommandType.StoredProcedure);

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
