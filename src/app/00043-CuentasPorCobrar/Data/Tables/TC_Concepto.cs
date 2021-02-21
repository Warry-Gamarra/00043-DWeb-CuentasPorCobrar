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
    public class TC_Concepto
    {
        public int I_ConceptoID { get; set; }
        public string T_ConceptoDesc { get; set; }
        public bool B_EsPagoMatricula { get; set; }
        public bool B_EsPagoExtmp { get; set; }
        public bool B_ConceptoAgrupa { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }


        public static List<TC_Concepto> Find()
        {
            List<TC_Concepto> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT c.* FROM TC_Concepto c WHERE c.B_Eliminado = 0";

                    result = _dbConnection.Query<TC_Concepto>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static TC_Concepto Find(int conceptoID)
        {
            TC_Concepto result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT c.* FROM TC_Concepto c WHERE I_ConceptoID = @I_ConceptoID AND c.B_Eliminado = 0";

                    result = _dbConnection.QuerySingleOrDefault<TC_Concepto>(s_command, new { I_ConceptoID  = conceptoID }, commandType: CommandType.Text);
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
                    parameters.Add(name: "I_ConceptoID", dbType: DbType.Int32, value: this.I_ConceptoID);
                    parameters.Add(name: "T_ConceptoDesc", dbType: DbType.String, size: 500, value: this.T_ConceptoDesc);
                    parameters.Add(name: "B_EsPagoMatricula", dbType: DbType.Boolean, value: this.B_EsPagoMatricula);
                    parameters.Add(name: "B_EsPagoExtmp", dbType: DbType.Boolean, value: this.B_EsPagoExtmp);
                    parameters.Add(name: "B_ConceptoAgrupa", dbType: DbType.Boolean, value: this.B_ConceptoAgrupa);
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecCre);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarConcepto", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_ConceptoID", dbType: DbType.Int32, value: this.I_ConceptoID);
                    parameters.Add(name: "T_ConceptoDesc", dbType: DbType.String, size: 250, value: this.T_ConceptoDesc);
                    parameters.Add(name: "B_EsPagoMatricula", dbType: DbType.Boolean, value: this.B_EsPagoMatricula);
                    parameters.Add(name: "B_EsPagoExtmp", dbType: DbType.Boolean, value: this.B_EsPagoExtmp);
                    parameters.Add(name: "B_ConceptoAgrupa", dbType: DbType.Boolean, value: this.B_ConceptoAgrupa);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarConcepto", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_ConceptoID", dbType: DbType.Byte, value: this.I_ConceptoID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoConcepto", parameters, commandType: CommandType.StoredProcedure);

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
