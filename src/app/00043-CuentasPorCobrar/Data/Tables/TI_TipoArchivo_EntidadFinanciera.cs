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
    public class TI_TipoArchivo_EntidadFinanciera
    {
        public int I_TipArchivoEntFinanID { get; set; }
        public int I_EntidadFinanID { get; set; }
        public int I_TipoArchivoID { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int I_UsuarioCre { get; set; }
        public DateTime D_FecCre { get; set; }
        public int I_UsuarioMod { get; set; }
        public DateTime D_FecMod { get; set; }

        public string T_TipoArchivDesc { get; set; }
        public bool B_ArchivoEntrada { get; set; }
        public string T_EntidadDesc { get; set; }


        public List<TI_TipoArchivo_EntidadFinanciera> Find()
        {
            List<TI_TipoArchivo_EntidadFinanciera> result = new List<TI_TipoArchivo_EntidadFinanciera>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT TA.T_TipoArchivDesc, TA.B_ArchivoEntrada, EF.T_EntidadDesc, TAEF.*
                                         FROM TI_TipoArchivo_EntidadFinanciera TAEF
	                                         INNER JOIN TC_TipoArchivo TA ON TA.I_TipoArchivoID = TAEF.I_TipoArchivoID
	                                         INNER JOIN TC_EntidadFinanciera EF ON EF.I_EntidadFinanID = TAEF.I_EntidadFinanID
                                         WHERE TAEF.B_Eliminado = 0;";

                    result = _dbConnection.Query<TI_TipoArchivo_EntidadFinanciera>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public List<TI_TipoArchivo_EntidadFinanciera> FindByEntityID(int entityId)
        {
            List<TI_TipoArchivo_EntidadFinanciera> result = new List<TI_TipoArchivo_EntidadFinanciera>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT TA.T_TipoArchivDesc, TA.B_ArchivoEntrada, EF.T_EntidadDesc, TAEF.*
                                         FROM TI_TipoArchivo_EntidadFinanciera TAEF
	                                         INNER JOIN TC_TipoArchivo TA ON TA.I_TipoArchivoID = TAEF.I_TipoArchivoID
	                                         INNER JOIN TC_EntidadFinanciera EF ON EF.I_EntidadFinanID = TAEF.I_EntidadFinanID
                                         WHERE TAEF.I_EntidadFinanID = @I_EntidadFinanID;";

                    result = _dbConnection.Query<TI_TipoArchivo_EntidadFinanciera>(s_command, new { I_EntidadFinanID = entityId }, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }


        public ResponseData HabilitarArchivosEntidadFinanciera()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Byte, value: this.I_EntidadFinanID);
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecCre);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: this.I_UsuarioCre);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarTipoArchivosEntidadFinanciera", parameters, commandType: CommandType.StoredProcedure);

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
