using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_S_DocumentacionUsuarioRoles
    {
        public int I_RutaDocID { get; set; }
        public string T_DocDesc { get; set; }
        public string T_RutaDocumento { get; set; }
        public bool B_Habilitado { get; set; }
        public int RoleId { get; set; }
        public bool B_DocRolHabilitado { get; set; }


        public List<USP_S_DocumentacionUsuarioRoles> Execute()
        {
            List<USP_S_DocumentacionUsuarioRoles> result = new List<USP_S_DocumentacionUsuarioRoles>();

            using (var _dbConnection = new SqlConnection(Database.ConnectionString))
            {
                result = _dbConnection.Query<USP_S_DocumentacionUsuarioRoles>("USP_S_DocumentacionUsuarioRoles", commandType: CommandType.StoredProcedure).ToList();
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
                    parameters.Add(name: "I_RutaDocID", dbType: DbType.Byte, value: this.I_RutaDocID);
                    parameters.Add(name: "T_DocDesc", dbType: DbType.String, size: 50, value: this.T_DocDesc);
                    parameters.Add(name: "T_RutaDocumento", dbType: DbType.String, size: 500, value: this.T_RutaDocumento);
                    parameters.Add(name: "I_UserID", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_GrabarDocumentacionUsuario", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_RutaDocID", dbType: DbType.Byte, value: this.I_RutaDocID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "IdUser", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoArchivo", parameters, commandType: CommandType.StoredProcedure);

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
                    parameters.Add(name: "I_RutaDocID", dbType: DbType.Byte, value: this.I_RutaDocID);
                    parameters.Add(name: "T_DocDesc", dbType: DbType.String, size: 50, value: this.T_DocDesc);
                    parameters.Add(name: "T_RutaDocumento", dbType: DbType.String, size: 500, value: this.T_RutaDocumento);
                    parameters.Add(name: "I_UserID", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarDocumentacionUsuario", parameters, commandType: CommandType.StoredProcedure);

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
