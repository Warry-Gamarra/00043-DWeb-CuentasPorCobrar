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
    public class TC_CategoriaPago
    {
        public int? I_CatPagoID { get; set; }
        public string T_CatPagoDesc { get; set; }
        public int I_Prioridad { get; set; }
        public int I_Nivel { get; set; }
        public string T_NivelDesc { get; set; }
        public int I_TipoAlumno { get; set; }
        public string T_TipoAluDesc { get; set; }
        public bool B_Obligacion { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }


        public static List<TC_CategoriaPago> FindAll()
        {
            List<TC_CategoriaPago> result;

            try
            {
                string s_command = @"SELECT t.* FROM dbo.TC_CategoriaPago t WHERE B_Eliminado = 0;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_CategoriaPago>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }


        public static TC_CategoriaPago FindByID(int I_CatPagoID)
        {
            TC_CategoriaPago result;

            try
            {
                string s_command = @"SELECT t.* FROM dbo.TC_CategoriaPago t WHERE t.I_CatPagoID = @I_CatPagoID";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_CategoriaPago>(s_command, new { I_CatPagoID = I_CatPagoID }, commandType: CommandType.Text).FirstOrDefault();
                }
            }
            catch (Exception ex)
            {
                throw ex;
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
                    parameters.Add(name: "I_CatPagoID", dbType: DbType.Int32, value: this.I_CatPagoID);
                    parameters.Add(name: "T_CatPagoDesc", dbType: DbType.String, size: 250, value: this.T_CatPagoDesc);
                    parameters.Add(name: "I_Nivel", dbType: DbType.Int32, value: this.I_Nivel);
                    parameters.Add(name: "I_TipoAlumno", dbType: DbType.Int32, value: this.I_TipoAlumno);
                    parameters.Add(name: "I_Prioridad", dbType: DbType.Int32, value: this.I_Prioridad);
                    parameters.Add(name: "B_Obligacion", dbType: DbType.Boolean, value: this.B_Obligacion);
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecCre);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarCategoriaPago", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_CatPagoID", dbType: DbType.Int32, value: this.I_CatPagoID);
                    parameters.Add(name: "T_CatPagoDesc", dbType: DbType.String, size: 500, value: this.T_CatPagoDesc);
                    parameters.Add(name: "I_Nivel", dbType: DbType.Int32, value: this.I_Nivel);
                    parameters.Add(name: "I_TipoAlumno", dbType: DbType.Int32, value: this.I_TipoAlumno);
                    parameters.Add(name: "I_Prioridad", dbType: DbType.Int32, value: this.I_Prioridad);
                    parameters.Add(name: "B_Obligacion", dbType: DbType.Boolean, value: this.B_Obligacion);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarCategoriaPago", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_CatPagoID", dbType: DbType.Byte, value: this.I_CatPagoID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoCategoriaPago", parameters, commandType: CommandType.StoredProcedure);

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
