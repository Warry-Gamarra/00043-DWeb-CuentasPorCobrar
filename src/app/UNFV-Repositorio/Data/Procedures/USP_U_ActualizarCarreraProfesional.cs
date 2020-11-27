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
    public class USP_U_ActualizarCarreraProfesional
    {
        public string C_RcCod { get; set; }
        public string C_CodEsp { get; set; }
        public string C_CodEsc { get; set; }
        public string C_CodFac { get; set; }
        public char C_Tipo { get; set; }
        public Int16 C_AnioIngreso { get; set; }
        public Int16 I_Duracion { get; set; }
        public string B_Anual { get; set; }
        public char N_Grupo { get; set; }
        public char N_Grado { get; set; }
        public int I_IdAplica { get; set; }
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
                command = "USP_U_ActualizarCarreraProfesional";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters = new DynamicParameters();
                    parameters.Add(name: "C_RcCod", dbType: DbType.String, size: 3, value: this.C_RcCod);
                    parameters.Add(name: "C_CodEsp", dbType: DbType.String, size: 2, value: this.C_CodEsp);
                    parameters.Add(name: "C_CodEsc", dbType: DbType.String, size: 2, value: this.C_CodEsc);
                    parameters.Add(name: "C_CodFac", dbType: DbType.String, size: 2, value: this.C_CodFac);
                    parameters.Add(name: "C_Tipo", dbType: DbType.String, size: 1, value: this.C_Tipo);
                    parameters.Add(name: "C_AnioIngreso", dbType: DbType.Int16, value: this.C_AnioIngreso);
                    parameters.Add(name: "I_Duracion", dbType: DbType.Int16, value: this.I_Duracion);
                    parameters.Add(name: "B_Anual", dbType: DbType.Boolean, value: this.B_Anual);
                    parameters.Add(name: "N_Grupo", dbType: DbType.String, size: 1, value: this.N_Grupo);
                    parameters.Add(name: "N_Grado", dbType: DbType.String, size: 1, value: this.N_Grado);
                    parameters.Add(name: "I_IdAplica", dbType: DbType.Int32, value: this.I_IdAplica);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "B_Eliminado", dbType: DbType.Boolean, value: this.B_Eliminado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
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
