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
    public class TC_ClasificadorPresupuestal
    {
        public int I_ClasificadorID { get; set; }
        public string C_TipoTransCod { get; set; }
        public string C_GenericaCod { get; set; }
        public string C_SubGeneCod { get; set; }
        public string C_EspecificaCod { get; set; }
        public string T_ClasificadorDesc { get; set; }
        public string T_ClasificadorDetalle { get; set; }
        public string N_Anio { get; set; }
        public string T_ClasificadorUnfv { get; set; }
        public bool B_Habilitado { get; set; }
        public DateTime? D_FecCre { get; set; }
        public DateTime? D_FecMod { get; set; }


        public List<TC_ClasificadorPresupuestal> Find(string anio)
        {
            List<TC_ClasificadorPresupuestal> result = new List<TC_ClasificadorPresupuestal>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT  CP.I_ClasificadorID, CP.C_TipoTransCod, CP.C_GenericaCod, CP.C_SubGeneCod, CP.C_EspecificaCod, CP.T_ClasificadorDesc, CP.T_ClasificadorDetalle
		                                         , CP.D_FecCre, CP.D_FecMod, CEA.N_Anio, CEA.B_Habilitado, CEA.D_FecCre AS D_FecCreAnio, CEA.D_FecMod AS D_FecModAnio
                                           FROM  TC_ClasificadorPresupuestal CP
												 LEFT JOIN TC_ClasificadorEquivalencia CE ON CP.I_ClasificadorID = CE.I_ClasificadorID
		                                         LEFT JOIN (SELECT * FROM TC_ClasificadorEquivalenciaAnio WHERE N_Anio = @N_Anio AND B_Eliminado = 0) CEA ON CE.I_ClasifEquivalenciaID = CEA.I_ClasifEquivalenciaID
                                          WHERE	 CP.B_Eliminado = 0;";

                    result = _dbConnection.Query<TC_ClasificadorPresupuestal>(s_command, new { N_Anio = anio }, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public TC_ClasificadorPresupuestal Find(int clasificadorId)
        {
            TC_ClasificadorPresupuestal result = new TC_ClasificadorPresupuestal();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT  * FROM  TC_ClasificadorPresupuestal CP
                                          WHERE  CP.I_ClasificadorID = @I_ClasificadorID AND CP.B_Eliminado = 0;";

                    result = _dbConnection.QueryFirstOrDefault<TC_ClasificadorPresupuestal>(s_command, new { I_ClasificadorID = clasificadorId }, commandType: CommandType.Text);
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
                    parameters.Add(name: "C_TipoTransCod", dbType: DbType.String, size: 2, value: this.C_TipoTransCod);
                    parameters.Add(name: "C_GenericaCod", dbType: DbType.String, size: 2, value: this.C_GenericaCod);
                    parameters.Add(name: "C_SubGeneCod", dbType: DbType.String, size: 5, value: this.C_SubGeneCod);
                    parameters.Add(name: "C_EspecificaCod", dbType: DbType.String, size: 5, value: this.C_EspecificaCod);
                    parameters.Add(name: "T_ClasificadorDesc", dbType: DbType.String, size: 250, value: this.T_ClasificadorDesc);
                    parameters.Add(name: "T_ClasificadorDetalle", dbType: DbType.String, size: 4000, value: this.T_ClasificadorDetalle);
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
                    parameters.Add(name: "C_TipoTransCod", dbType: DbType.String, size: 2, value: this.C_TipoTransCod);
                    parameters.Add(name: "C_GenericaCod", dbType: DbType.String, size: 2, value: this.C_GenericaCod);
                    parameters.Add(name: "C_SubGeneCod", dbType: DbType.String, size: 5, value: this.C_SubGeneCod);
                    parameters.Add(name: "C_EspecificaCod", dbType: DbType.String, size: 5, value: this.C_EspecificaCod);
                    parameters.Add(name: "T_ClasificadorDesc", dbType: DbType.String, size: 250, value: this.T_ClasificadorDesc);
                    parameters.Add(name: "T_ClasificadorDetalle", dbType: DbType.String, size: 4000, value: this.T_ClasificadorDetalle);
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
