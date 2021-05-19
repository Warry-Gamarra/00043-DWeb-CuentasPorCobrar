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
    public class TC_ClasificadorEquivalenciaAnio
    {
        public int I_ClasifEquivalenciaID { get; set; }
        public string N_Anio { get; set; }
        public string C_ClasificConceptoCod { get; set; }
        public string C_ClasificConceptoDesc { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }


        public List<TC_ClasificadorPresupuestal> Find(string anio)
        {
            List<TC_ClasificadorPresupuestal> result = new List<TC_ClasificadorPresupuestal>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT  CP.I_ClasificadorID, CP.C_TipoTransCod, CP.C_GenericaCod, CP.C_SubGeneCod, CP.C_EspecificaCod, CP.T_ClasificadorDesc, CP.T_ClasificadorDetalle
		                                         , CP.D_FecCre, CP.D_FecMod, CA.N_Anio, CA.B_Habilitado, CA.D_FecCre AS D_FecCreAnio, CA.D_FecMod AS D_FecModAnio
                                           FROM  TC_ClasificadorPresupuestal CP
		                                         LEFT JOIN (SELECT * FROM TC_ClasificadorAnio WHERE N_Anio = @N_Anio AND B_Eliminado = 0) CA ON CP.I_ClasificadorID = CA.I_ClasificadorID
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
                    var s_command = @"SELECT  CP.I_ClasificadorID, C_TipoTransCod, C_GenericaCod, C_SubGeneCod, C_EspecificaCod, T_ClasificadorDesc, T_ClasificadorDetalle
		                                      , CA.N_Anio, CACC.C_ClasificConceptoCod, CP.D_FecCre, CP.D_FecMod
                                        FROM  TC_ClasificadorPresupuestal CP
		                                      LEFT JOIN TC_ClasificadorAnio CA ON CA.I_ClasificadorID = CP.I_ClasificadorID 
		                                      LEFT JOIN TC_ClasificAnioClasificConcepto CACC ON CACC.I_ClasificadorID = CP.I_ClasificadorID AND CACC.N_Anio = CA.N_Anio
                                       WHERE  CP.I_ClasificadorID = @I_ClasificadorID AND CACC.B_Eliminado = 0 AND CP.B_Eliminado = 0;";

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
                    parameters.Add(name: "I_ClasifEquivalenciaID", dbType: DbType.Int32, value: this.I_ClasifEquivalenciaID);
                    parameters.Add(name: "N_Anio", dbType: DbType.String, size: 4, value: this.N_Anio);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoClasificadorEquivlenciaAnio", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_ClasifEquivalenciaID", dbType: DbType.Int32, value: this.I_ClasifEquivalenciaID);
                    parameters.Add(name: "N_Anio", dbType: DbType.String, size: 4, value: this.N_Anio);
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarClasificadorEquivalenciaAnio", parameters, commandType: CommandType.StoredProcedure);

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
