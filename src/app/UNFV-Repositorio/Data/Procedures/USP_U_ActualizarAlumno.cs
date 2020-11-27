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
    public class USP_U_ActualizarAlumno
    {
        public string C_RcCod { get; set; }
        public string C_CodAlu { get; set; }
        public string C_CodModIng { get; set; }
        public Int16 C_AnioIngreso { get; set; }
        public int I_IdPlan { get; set; }
        public int I_PersonaID { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public DateTime D_FecMod { get; set; }
        public int I_UsuarioMod { get; set; }



        public ResponseData Execute()
        {
            ResponseData result;
            DynamicParameters parameters;
            string command;

            try
            {
                command = "USP_U_ActualizarAlumno";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "C_RcCod", dbType: DbType.String, size: 3, value: this.C_RcCod);
                    parameters.Add(name: "C_CodAlu", dbType: DbType.String, size: 20, value: this.C_CodAlu);
                    parameters.Add(name: "C_CodModIng", dbType: DbType.String, size: 5, value: this.C_CodModIng);
                    parameters.Add(name: "C_AnioIngreso", dbType: DbType.Int16, value: this.C_AnioIngreso);
                    parameters.Add(name: "I_IdPlan", dbType: DbType.Int32, value: this.I_IdPlan);
                    parameters.Add(name: "I_PersonaID", dbType: DbType.Int32, value: this.I_PersonaID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "B_Eliminado", dbType: DbType.Boolean, value: this.B_Eliminado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.Date, value: this.D_FecMod);
                    parameters.Add(name: "I_UsuarioMod", dbType: DbType.Int32, value: this.I_UsuarioMod);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(command, parameters, commandType: CommandType.StoredProcedure);

                    result = new ResponseData();
                    result.Value = parameters.Get<bool>("B_Result");
                    result.Message = parameters.Get<string>("T_Message");
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
