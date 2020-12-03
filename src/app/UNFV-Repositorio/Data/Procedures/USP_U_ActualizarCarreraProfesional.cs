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
        public string C_Tipo { get; set; }
        public int I_Duracion { get; set; }
        public bool B_Anual { get; set; }
        public string N_Grupo { get; set; }
        public string N_Grado { get; set; }
        public int? I_IdAplica { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public DateTime D_FecMod { get; set; }
        public int I_UsuarioMod { get; set; }

        public static ResponseData Execute(IDbConnection dbConnection, IDbTransaction dbTransaction, USP_U_ActualizarCarreraProfesional paramActualizarCarreraProfesional)
        {
            ResponseData result;
            DynamicParameters parameters;
            string command;

            try
            {
                command = "USP_U_ActualizarCarreraProfesional";

                parameters = new DynamicParameters();
                parameters.Add(name: "C_RcCod", dbType: DbType.String, size: 3, value: paramActualizarCarreraProfesional.C_RcCod);
                parameters.Add(name: "C_CodEsp", dbType: DbType.String, size: 2, value: paramActualizarCarreraProfesional.C_CodEsp);
                parameters.Add(name: "C_CodEsc", dbType: DbType.String, size: 2, value: paramActualizarCarreraProfesional.C_CodEsc);
                parameters.Add(name: "C_CodFac", dbType: DbType.String, size: 2, value: paramActualizarCarreraProfesional.C_CodFac);
                parameters.Add(name: "C_Tipo", dbType: DbType.String, size: 1, value: paramActualizarCarreraProfesional.C_Tipo);
                parameters.Add(name: "I_Duracion", dbType: DbType.Int32, value: paramActualizarCarreraProfesional.I_Duracion);
                parameters.Add(name: "B_Anual", dbType: DbType.Boolean, value: paramActualizarCarreraProfesional.B_Anual);
                parameters.Add(name: "N_Grupo", dbType: DbType.String, size: 1, value: paramActualizarCarreraProfesional.N_Grupo);
                parameters.Add(name: "N_Grado", dbType: DbType.String, size: 1, value: paramActualizarCarreraProfesional.N_Grado);
                parameters.Add(name: "I_IdAplica", dbType: DbType.Int32, value: paramActualizarCarreraProfesional.I_IdAplica);
                parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: paramActualizarCarreraProfesional.B_Habilitado);
                parameters.Add(name: "B_Eliminado", dbType: DbType.Boolean, value: paramActualizarCarreraProfesional.B_Eliminado);
                parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: paramActualizarCarreraProfesional.D_FecMod);
                parameters.Add(name: "I_UsuarioMod", dbType: DbType.Int32, value: paramActualizarCarreraProfesional.I_UsuarioMod);
                parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                dbConnection.Execute(command, parameters, dbTransaction, commandType: CommandType.StoredProcedure);

                result = new ResponseData()
                {
                    Value = parameters.Get<bool>("B_Result"),
                    Message = parameters.Get<string>("T_Message")
                };
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }
    }
}
