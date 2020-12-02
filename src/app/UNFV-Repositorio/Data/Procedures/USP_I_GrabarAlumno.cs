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
    public class USP_I_GrabarAlumno
    {
        public string C_RcCod { get; set; }
        public string C_CodAlu { get; set; }
        public string C_CodModIng { get; set; }
        public Int16 C_AnioIngreso { get; set; }
        public int I_IdPlan { get; set; }
        public int I_PersonaID { get; set; }
        public DateTime D_FecCre { get; set; }
        public int I_UsuarioCre { get; set; }

        public static ResponseData Execute(IDbConnection dbConnection, IDbTransaction dbTransaction, USP_I_GrabarAlumno paramGrabarAlumno)
        {
            ResponseData result;
            DynamicParameters parameters;
            string command;

            try
            {
                command = "USP_I_GrabarAlumno";

                parameters = new DynamicParameters();
                parameters.Add(name: "C_RcCod", dbType: DbType.String, size: 3, value: paramGrabarAlumno.C_RcCod);
                parameters.Add(name: "C_CodAlu", dbType: DbType.String, size: 20, value: paramGrabarAlumno.C_CodAlu);
                parameters.Add(name: "C_CodModIng", dbType: DbType.String, size: 2, value: paramGrabarAlumno.C_CodModIng);
                parameters.Add(name: "C_AnioIngreso", dbType: DbType.Int16, value: paramGrabarAlumno.C_AnioIngreso);
                parameters.Add(name: "I_IdPlan", dbType: DbType.Int32, value: paramGrabarAlumno.I_IdPlan);
                parameters.Add(name: "I_PersonaID", dbType: DbType.Int32, value: paramGrabarAlumno.I_PersonaID);
                parameters.Add(name: "D_FecCre", dbType: DbType.Date, value: paramGrabarAlumno.D_FecCre);
                parameters.Add(name: "I_UsuarioCre", dbType: DbType.Int32, value: paramGrabarAlumno.I_UsuarioCre);
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
