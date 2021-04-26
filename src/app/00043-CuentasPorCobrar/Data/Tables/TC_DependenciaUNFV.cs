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
    public class TC_DependenciaUNFV
    {
        public int? I_DependenciaID { get; set; }
        public string T_DepDesc { get; set; }
        public string C_DepCod { get; set; }
        public string C_DepCodPl { get; set; }
        public string T_DepAbrev { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int I_UsuarioCre { get; set; }
        public DateTime D_FecCre { get; set; }
        public int I_UsuarioMod { get; set; }
        public DateTime D_FecMod { get; set; }


        public List<TC_DependenciaUNFV> Find()
        {
            List<TC_DependenciaUNFV> result;

            try
            {
                string s_command = @"SELECT * FROM dbo.TC_DependenciaUNFV D WHERE B_Eliminado = 0";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_DependenciaUNFV>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public TC_DependenciaUNFV Find(int dependenciaID)
        {
            TC_DependenciaUNFV result;

            try
            {
                string s_command = @"SELECT * FROM dbo.TC_DependenciaUNFV D WHERE I_DependenciaID = @I_Dependencia AND B_Eliminado = 0";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.QuerySingleOrDefault<TC_DependenciaUNFV>(s_command, new { I_Dependencia  = dependenciaID }, commandType: CommandType.Text);
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
                    parameters.Add(name: "I_DependenciaID", dbType: DbType.Int32, value: this.I_DependenciaID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoDependencia", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_DependenciaID", dbType: DbType.Int32, value: this.I_DependenciaID);
                    parameters.Add(name: "C_DepCod", dbType: DbType.String, size: 20, value: this.C_DepCod);
                    parameters.Add(name: "C_DepCodPl", dbType: DbType.String, size: 20, value: this.C_DepCodPl);
                    parameters.Add(name: "T_DepDesc", dbType: DbType.String, size: 150, value: this.T_DepDesc);
                    parameters.Add(name: "T_DepAbrev", dbType: DbType.String, size: 10, value: this.T_DepAbrev);
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecCre);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarDependencia", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_DependenciaID", dbType: DbType.Int32, value: this.I_DependenciaID);
                    parameters.Add(name: "C_DepCod", dbType: DbType.String, size: 20, value: this.C_DepCod);
                    parameters.Add(name: "C_DepCodPl", dbType: DbType.String, size: 20, value: this.C_DepCodPl);
                    parameters.Add(name: "T_DepDesc", dbType: DbType.String, size: 150, value: this.T_DepDesc);
                    parameters.Add(name: "T_DepAbrev", dbType: DbType.String, size: 10, value: this.T_DepAbrev);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarDependencia", parameters, commandType: CommandType.StoredProcedure);

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
