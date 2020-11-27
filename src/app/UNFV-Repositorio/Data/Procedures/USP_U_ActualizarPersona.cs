using Dapper;
using Data.Connection;
using Data.DTO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_U_ActualizarPersona
    {
        public string I_PersonaID { get; set; }
        public string C_NumDNI { get; set; }
        public string C_CodTipDoc { get; set; }
        public string T_ApePaterno { get; set; }
        public string T_ApeMaterno { get; set; }
        public string T_Nombre { get; set; }
        public DateTime D_FecNac { get; set; }
        public string C_Sexo { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int I_UsuarioMod { get; set; }
        public DateTime D_FecMod { get; set; }

        public ResponseData Execute()
        {
            ResponseData result;
            DynamicParameters parameters;
            string command;

            try
            {
                command = "USP_U_ActualizarPersona";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "I_PersonaID", dbType: DbType.Int32, value: this.I_PersonaID);
                    parameters.Add(name: "C_NumDNI", dbType: DbType.String, size: 20, value: this.C_NumDNI);
                    parameters.Add(name: "C_CodTipDoc", dbType: DbType.String, size: 5, value: this.C_CodTipDoc);
                    parameters.Add(name: "T_ApePaterno", dbType: DbType.String, size: 50, value: this.T_ApePaterno);
                    parameters.Add(name: "T_ApeMaterno", dbType: DbType.String, size: 50, value: this.T_ApeMaterno);
                    parameters.Add(name: "T_Nombre", dbType: DbType.String, size: 50, value: this.T_Nombre);
                    parameters.Add(name: "D_FecNac", dbType: DbType.Date, value: this.D_FecNac);
                    parameters.Add(name: "C_Sexo", dbType: DbType.String, size: 1, value: this.C_Sexo);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "B_Eliminado", dbType: DbType.Boolean, value: this.B_Eliminado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "I_UsuarioMod", dbType: DbType.Int32, value: this.I_UsuarioMod);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(command, parameters, commandType: CommandType.StoredProcedure);

                    result = new ResponseData
                    {
                        Value = parameters.Get<bool>("B_Result"),
                        Message = parameters.Get<string>("T_Message")
                    };
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }
    }
}
