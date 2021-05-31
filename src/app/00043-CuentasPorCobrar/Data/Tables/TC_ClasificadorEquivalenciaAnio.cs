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
        public int I_ClasificadorID { get; set; }
        public string N_Anio { get; set; }
        public string C_ClasificConceptoCod { get; set; }
        public string T_ConceptoDesc { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }


        public List<TC_ClasificadorEquivalenciaAnio> Find(string anio)
        {
            List<TC_ClasificadorEquivalenciaAnio> result = new List<TC_ClasificadorEquivalenciaAnio>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT  CEA.I_ClasifEquivalenciaID, CEA.N_Anio, CEA.B_Habilitado, CE.I_ClasificadorID, CE.C_ClasificConceptoCod, C.T_ConceptoDesc
                                                 , CEA.D_FecCre, CEA.D_FecMod, CEA.I_UsuarioCre, CEA.I_UsuarioMod 
                                           FROM  TC_ClasificadorEquivalencia CE
												 INNER JOIN TC_Concepto C ON C.T_Clasificador = CE.C_ClasificConceptoCod
		                                         INNER JOIN TC_ClasificadorEquivalenciaAnio CEA ON CE.I_ClasifEquivalenciaID = CEA.I_ClasifEquivalenciaID
                                          WHERE	 N_Anio = @N_Anio AND CEA.B_Eliminado = 0;";

                    result = _dbConnection.Query<TC_ClasificadorEquivalenciaAnio>(s_command, new { N_Anio = anio }, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }


        public List<TC_ClasificadorEquivalenciaAnio> Find(int clasificadorId, string anio)
        {
            List<TC_ClasificadorEquivalenciaAnio> result = new List<TC_ClasificadorEquivalenciaAnio>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT  CE.I_ClasifEquivalenciaID, CEA.N_Anio, CEA.B_Habilitado, CE.I_ClasificadorID, CE.C_ClasificConceptoCod, C.T_ConceptoDesc
                                                 , CEA.D_FecCre, CEA.D_FecMod, CEA.I_UsuarioCre, CEA.I_UsuarioMod
                                           FROM  TC_ClasificadorEquivalencia CE
												 LEFT JOIN TC_Concepto C ON C.T_Clasificador = CE.C_ClasificConceptoCod
		                                         LEFT JOIN (SELECT * FROM TC_ClasificadorEquivalenciaAnio WHERE N_Anio = @N_Anio AND B_Eliminado = 0) CEA ON CE.I_ClasifEquivalenciaID = CEA.I_ClasifEquivalenciaID
                                          WHERE	 CE.I_ClasificadorID = @I_ClasificadorID";

                    result = _dbConnection.Query<TC_ClasificadorEquivalenciaAnio>(s_command, new { I_ClasificadorID = clasificadorId, N_Anio = anio }, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public List<TC_ClasificadorEquivalenciaAnio> Find(int clasificadorId)
        {
            List<TC_ClasificadorEquivalenciaAnio> result = new List<TC_ClasificadorEquivalenciaAnio>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT  CEA.I_ClasifEquivalenciaID, CEA.N_Anio, CEA.B_Habilitado, CE.I_ClasificadorID, CE.C_ClasificConceptoCod, C.T_ConceptoDesc
                                                 , CE.D_FecCre, CE.D_FecMod, CE.I_UsuarioCre, CE.I_UsuarioMod
                                           FROM  TC_ClasificadorEquivalencia CE
		                                         LEFT JOIN TC_ClasificadorEquivalenciaAnio CEA ON CE.I_ClasifEquivalenciaID = CEA.I_ClasifEquivalenciaID
												 INNER JOIN TC_Concepto C ON C.T_Clasificador = CE.C_ClasificConceptoCod
                                          WHERE	 CE.I_ClasificadorID = @I_ClasificadorID AND CE.B_Eliminado = 0;";

                    result = _dbConnection.Query<TC_ClasificadorEquivalenciaAnio>(s_command, new { I_ClasificadorID = clasificadorId }, commandType: CommandType.Text).ToList();
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
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecCre);
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
