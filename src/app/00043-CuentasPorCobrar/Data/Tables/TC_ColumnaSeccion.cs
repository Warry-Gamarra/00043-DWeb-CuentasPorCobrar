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
    public class TC_ColumnaSeccion
    {
        public int I_ColSecID { get; set; }
        public string T_ColSecDesc { get; set; }
        public int I_ColumnaInicio { get; set; }
        public int I_ColumnaFin { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int I_UsuarioCre { get; set; }
        public DateTime D_FecCre { get; set; }
        public int I_UsuarioMod { get; set; }
        public DateTime D_FecMod { get; set; }
        public int I_SecArchivoID { get; set; }
        public int? I_CampoPagoID { get; set; }

        public string T_SecArchivoDesc { get; set; }
        public int I_TipArchivoEntFinanID { get; set; }
        public string T_CampoPagoNom { get; set; }
        public string T_TablaPagoNom { get; set; }
        public string T_CampoInfoDesc { get; set; }


        public List<TC_ColumnaSeccion> Find()
        {
            List<TC_ColumnaSeccion> result = new List<TC_ColumnaSeccion>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT TAEF.I_TipArchivoEntFinanID, SA.T_SecArchivoDesc, CTP.T_CampoInfoDesc, CTP.T_CampoPagoNom, CTP.T_TablaPagoNom, CS.* 
                                         FROM TC_SeccionArchivo SA
	                                         INNER JOIN TC_ColumnaSeccion CS ON CS.I_SecArchivoID = SA.I_SecArchivoID
 	                                         INNER JOIN TI_TipoArchivo_EntidadFinanciera TAEF ON SA.I_TipArchivoEntFinanID = TAEF.I_TipArchivoEntFinanID
	                                         INNER JOIN TS_CampoTablaPago CTP ON CTP.I_CampoPagoID = CS.I_CampoPagoID
                                         WHERE CS.B_Eliminado = 0;";

                    result = _dbConnection.Query<TC_ColumnaSeccion>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }


        public List<TC_ColumnaSeccion> FindBySectionID(int sectionId)
        {
            List<TC_ColumnaSeccion> result = new List<TC_ColumnaSeccion>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT SA.T_SecArchivoDesc, CTP.T_CampoInfoDesc, CTP.T_CampoPagoNom, CTP.T_TablaPagoNom, CS.* 
                                         FROM TC_SeccionArchivo SA
	                                         INNER JOIN TC_ColumnaSeccion CS ON CS.I_SecArchivoID = SA.I_SecArchivoID
	                                         LEFT JOIN TS_CampoTablaPago CTP ON CTP.I_CampoPagoID = CS.I_CampoPagoID
                                         WHERE SA.I_SecArchivoID = @I_SecArchivoID;";

                    result = _dbConnection.Query<TC_ColumnaSeccion>(s_command, new { I_SecArchivoID = sectionId }, commandType: CommandType.Text).ToList();
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
                    parameters.Add(name: "I_CampoPagoID", dbType: DbType.Int32, value: this.I_CampoPagoID);
                    parameters.Add(name: "T_ColSecDesc", dbType: DbType.String, size: 50, value: this.T_ColSecDesc);
                    parameters.Add(name: "I_ColumnaInicio", dbType: DbType.Int16, value: this.I_ColumnaInicio);
                    parameters.Add(name: "I_ColumnaFin", dbType: DbType.Int16, value: this.I_ColumnaFin);
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecCre);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: this.I_UsuarioCre);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarColumnaSeccion", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_ColSecID", dbType: DbType.Int32, value: this.I_ColSecID);
                    parameters.Add(name: "I_CampoPagoID", dbType: DbType.Int32, value: this.I_CampoPagoID);
                    parameters.Add(name: "T_ColSecDesc", dbType: DbType.String, size: 50, value: this.T_ColSecDesc);
                    parameters.Add(name: "I_ColumnaInicio", dbType: DbType.Int16, value: this.I_ColumnaInicio);
                    parameters.Add(name: "I_ColumnaFin", dbType: DbType.Int16, value: this.I_ColumnaFin);
                    parameters.Add(name: "I_SecArchivoID", dbType: DbType.Int32, value: this.I_SecArchivoID);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: this.I_UsuarioCre);


                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarColumnaSeccion", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_ColSecID", dbType: DbType.Int32, value: this.I_ColSecID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecUpdate", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoColumnaSeccion", parameters, commandType: CommandType.StoredProcedure);

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
