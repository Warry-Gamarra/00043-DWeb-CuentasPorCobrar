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
    public class TC_ClasificadorIngreso
    {
        public int I_ClasificadorID { get; set; }
        public string T_ClasificadorDesc { get; set; }
        public string T_ClasificadorCod { get; set; }
        public string N_Anio { get; set; }
        public string T_ClasificadorUnfv { get; set; }
        public bool B_Habilitado { get; set; }
        public DateTime? D_FecCre { get; set; }
        public DateTime? D_FecMod { get; set; }


        public List<TC_ClasificadorIngreso> Find()
        {
            List<TC_ClasificadorIngreso> result = new List<TC_ClasificadorIngreso>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT I_ClasificadorID, T_ClasificadorDesc, T_ClasificadorCod, T_ClasificadorUnfv, B_Habilitado, D_FecCre, D_FecMod 
                                        FROM TC_ClasificadorIngreso WHERE B_Eliminado = 0;";

                    result = _dbConnection.Query<TC_ClasificadorIngreso>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public TC_ClasificadorIngreso Find(int clasificadorId)
        {
            TC_ClasificadorIngreso result = new TC_ClasificadorIngreso();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT I_ClasificadorID, T_ClasificadorDesc, T_ClasificadorCod, T_ClasificadorUnfv, B_Habilitado, D_FecCre, D_FecMod 
                                        FROM TC_ClasificadorIngreso WHERE I_ClasificadorID = @I_ClasificadorID AND B_Eliminado = 0;;";

                    result = _dbConnection.QueryFirstOrDefault<TC_ClasificadorIngreso>(s_command, new { I_ClasificadorID = clasificadorId }, commandType: CommandType.Text);
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
                    parameters.Add(name: "I_ClasificadorID", dbType: DbType.Int32, value: this.I_ClasificadorID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoClasificadorIngreso", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_ClasificadorID", dbType: DbType.Int32, value: this.I_ClasificadorID);
                    parameters.Add(name: "T_ClasificadorDesc", dbType: DbType.String, size: 250, value: this.T_ClasificadorDesc);
                    parameters.Add(name: "T_ClasificadorCod", dbType: DbType.String, size: 50, value: this.T_ClasificadorCod);
                    parameters.Add(name: "T_ClasificadorUnfv", dbType: DbType.String, size: 50, value: this.T_ClasificadorUnfv);
                    parameters.Add(name: "N_Anio", dbType: DbType.String, size: 4, value: this.N_Anio);
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarClasificadorIngreso", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_ClasificadorID", dbType: DbType.Int32, value: this.I_ClasificadorID);
                    parameters.Add(name: "T_ClasificadorDesc", dbType: DbType.String, size: 250, value: this.T_ClasificadorDesc);
                    parameters.Add(name: "T_ClasificadorCod", dbType: DbType.String, size: 50, value: this.T_ClasificadorCod);
                    parameters.Add(name: "T_ClasificadorUnfv", dbType: DbType.String, size: 50, value: this.T_ClasificadorUnfv);
                    parameters.Add(name: "N_Anio", dbType: DbType.String, size: 4, value: this.N_Anio);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarClasificadorIngreso", parameters, commandType: CommandType.StoredProcedure);

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
