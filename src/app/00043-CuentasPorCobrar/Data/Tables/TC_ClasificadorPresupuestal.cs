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
        public int N_CantEquiv { get; set; }
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
		                                         , CP.D_FecCre, CP.D_FecMod, ISNULL(CA.N_CantEquiv, 0) AS N_CantEquiv
                                           FROM  TC_ClasificadorPresupuestal CP
		                                         LEFT JOIN (SELECT CE.I_ClasificadorID, COUNT(CEA.I_ClasifEquivalenciaID) AS N_CantEquiv
					                                          FROM TC_ClasificadorEquivalencia CE
						                                           LEFT JOIN TC_ClasificadorEquivalenciaAnio CEA ON CE.I_ClasifEquivalenciaID = CEA.I_ClasifEquivalenciaID AND CEA.N_Anio = @N_Anio AND CEA.B_Habilitado = 1 
					                                         WHERE CE.B_Eliminado = 0 GROUP BY CE.I_ClasificadorID) CA ON CP.I_ClasificadorID = CA.I_ClasificadorID
                                          WHERE	CP.B_Eliminado = 0;";

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
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecCre);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarClasificadorPresupuestal", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarClasificadorPresupuestal", parameters, commandType: CommandType.StoredProcedure);

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
