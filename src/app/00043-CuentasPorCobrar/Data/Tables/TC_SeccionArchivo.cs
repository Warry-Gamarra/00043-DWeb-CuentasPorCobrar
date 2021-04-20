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
    public class TC_SeccionArchivo
    {
        public int I_SecArchivoID { get; set; }
        public string T_SecArchivoDesc { get; set; }
        public int I_FilaInicio { get; set; }
        public int I_FilaFin { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int I_UsuarioCre { get; set; }
        public DateTime D_FecCre { get; set; }
        public int I_UsuarioMod { get; set; }
        public DateTime D_FecMod { get; set; }
        public int I_TipArchivoEntFinanID { get; set; }

        public string T_TipoArchivDesc { get; set; }
        public bool B_ArchivoEntrada { get; set; }
        public string T_EntidadDesc { get; set; }
        public int I_EntidadFinanID { get; set; }
        public int I_TipoArchivoID { get; set; }



        public List<TC_SeccionArchivo> Find()
        {
            List<TC_SeccionArchivo> result = new List<TC_SeccionArchivo>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT TA.T_TipoArchivDesc, TA.B_ArchivoEntrada, EF.T_EntidadDesc, TAEF.I_EntidadFinanID, TAEF.I_TipoArchivoID, SA.*
                                         FROM TC_SeccionArchivo SA
 	                                          INNER JOIN TI_TipoArchivo_EntidadFinanciera TAEF ON SA.I_TipArchivoEntFinanID = TAEF.I_TipArchivoEntFinanID
 	                                          INNER JOIN TC_TipoArchivo TA ON TA.I_TipoArchivoID = TAEF.I_TipoArchivoID
 	                                          INNER JOIN TC_EntidadFinanciera EF ON EF.I_EntidadFinanID = TAEF.I_EntidadFinanID
                                         WHERE SA.B_Eliminado = 0;";

                    result = _dbConnection.Query<TC_SeccionArchivo>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public List<TC_SeccionArchivo> Find(int tipArchivoEntFinanID)
        {
            List<TC_SeccionArchivo> result = new List<TC_SeccionArchivo>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT TA.T_TipoArchivDesc, TA.B_ArchivoEntrada, EF.T_EntidadDesc, TAEF.I_EntidadFinanID, TAEF.I_TipoArchivoID, SA.*
                                         FROM TC_SeccionArchivo SA
 	                                          INNER JOIN TI_TipoArchivo_EntidadFinanciera TAEF ON SA.I_TipArchivoEntFinanID = TAEF.I_TipArchivoEntFinanID
 	                                          INNER JOIN TC_TipoArchivo TA ON TA.I_TipoArchivoID = TAEF.I_TipoArchivoID
 	                                          INNER JOIN TC_EntidadFinanciera EF ON EF.I_EntidadFinanID = TAEF.I_EntidadFinanID
                                         WHERE TAEF.I_TipArchivoEntFinanID = @I_TipArchivoEntFinanID;";
 
                    result = _dbConnection.Query<TC_SeccionArchivo>(s_command, new { I_TipArchivoEntFinanID = tipArchivoEntFinanID }, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
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
                    parameters.Add(name: "I_SecArchivoID", dbType: DbType.Int32, value: this.I_SecArchivoID);
                    parameters.Add(name: "T_SecArchivoDesc", dbType: DbType.String, size: 50, value: this.T_SecArchivoDesc);
                    parameters.Add(name: "I_FilaInicio", dbType: DbType.Int16, value: this.I_FilaInicio);
                    parameters.Add(name: "I_FilaFin", dbType: DbType.Int16, value: this.I_FilaFin);
                    parameters.Add(name: "I_TipArchivoEntFinanID", dbType: DbType.Int32, value: this.I_TipArchivoEntFinanID);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecCre);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: this.I_UsuarioCre);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarSeccionArchivo", parameters, commandType: CommandType.StoredProcedure);

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

        public ResponseData Update()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_SecArchivoID", dbType: DbType.Int32, value: this.I_SecArchivoID);
                    parameters.Add(name: "T_SecArchivoDesc", dbType: DbType.String, size: 50, value: this.T_SecArchivoDesc);
                    parameters.Add(name: "I_FilaInicio", dbType: DbType.Int16, value: this.I_FilaInicio);
                    parameters.Add(name: "I_FilaFin", dbType: DbType.Int16, value: this.I_FilaFin);
                    parameters.Add(name: "I_TipArchivoEntFinanID", dbType: DbType.Int32, value: this.I_TipArchivoEntFinanID);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: this.I_UsuarioCre);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarSeccionArchivo", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_SecArchivoID", dbType: DbType.Int32, value: this.I_SecArchivoID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecUpdate", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoSeccionArchivo", parameters, commandType: CommandType.StoredProcedure);

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
