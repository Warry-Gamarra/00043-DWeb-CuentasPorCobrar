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
    public class USP_I_GrabarCarreraProfesional
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
        public DateTime D_FecCre { get; set; }
        public int I_UsuarioCre { get; set; }

        public static ResponseData Execute(IDbConnection dbConnection, IDbTransaction dbTransaction, USP_I_GrabarCarreraProfesional paramGrabarCarreProfesional)
        {
            ResponseData result;
            DynamicParameters parameters;
            string command;

            try
            {
                command = "USP_I_GrabarCarreraProfesional";

                parameters = new DynamicParameters();
                parameters.Add(name: "C_RcCod", dbType: DbType.String, size: 3, value: paramGrabarCarreProfesional.C_RcCod);
                parameters.Add(name: "C_CodEsp", dbType: DbType.String, size: 2, value: paramGrabarCarreProfesional.C_CodEsp);
                parameters.Add(name: "C_CodEsc", dbType: DbType.String, size: 2, value: paramGrabarCarreProfesional.C_CodEsc);
                parameters.Add(name: "C_CodFac", dbType: DbType.String, size: 2, value: paramGrabarCarreProfesional.C_CodFac);
                parameters.Add(name: "C_Tipo", dbType: DbType.String, size: 1, value: paramGrabarCarreProfesional.C_Tipo);
                parameters.Add(name: "I_Duracion", dbType: DbType.Int32, value: paramGrabarCarreProfesional.I_Duracion);
                parameters.Add(name: "B_Anual", dbType: DbType.Boolean, value: paramGrabarCarreProfesional.B_Anual);
                parameters.Add(name: "N_Grupo", dbType: DbType.String, size: 1, value: paramGrabarCarreProfesional.N_Grupo);
                parameters.Add(name: "N_Grado", dbType: DbType.String, size: 1, value: paramGrabarCarreProfesional.N_Grado);
                parameters.Add(name: "I_IdAplica", dbType: DbType.Int32, value: paramGrabarCarreProfesional.I_IdAplica);
                parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: paramGrabarCarreProfesional.D_FecCre);
                parameters.Add(name: "I_UsuarioCre", dbType: DbType.Int32, value: paramGrabarCarreProfesional.I_UsuarioCre);
                parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                dbConnection.Execute(command, parameters, dbTransaction, commandType: CommandType.StoredProcedure);

                result = new ResponseData
                {
                    CurrentID = paramGrabarCarreProfesional.C_RcCod,
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
