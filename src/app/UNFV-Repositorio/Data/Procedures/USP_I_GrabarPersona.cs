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
    public class USP_I_GrabarPersona
    {
        public string C_NumDNI { get; set; }
        public string C_CodTipDoc { get; set; }
        public string T_ApePaterno { get; set; }
        public string T_ApeMaterno { get; set; }
        public string T_Nombre { get; set; }
        public DateTime? D_FecNac { get; set; }
        public string C_Sexo { get; set; }
        public DateTime D_FecCre { get; set; }
        public int I_UsuarioCre { get; set; }

        public static ResponseData Execute(IDbConnection dbConnection, IDbTransaction dbTransaction, USP_I_GrabarPersona paramGrabarPersona)
        {
            ResponseData result;
            DynamicParameters parameters;
            string command;

            try
            {
                command = "USP_I_GrabarPersona";
                
                parameters = new DynamicParameters();
                parameters.Add(name: "C_NumDNI", dbType: DbType.String, size: 20, value: paramGrabarPersona.C_NumDNI);
                parameters.Add(name: "C_CodTipDoc", dbType: DbType.String, size: 5, value: paramGrabarPersona.C_CodTipDoc);
                parameters.Add(name: "T_ApePaterno", dbType: DbType.String, size: 50, value: paramGrabarPersona.T_ApePaterno);
                parameters.Add(name: "T_ApeMaterno", dbType: DbType.String, size: 50, value: paramGrabarPersona.T_ApeMaterno);
                parameters.Add(name: "T_Nombre", dbType: DbType.String, size: 50, value: paramGrabarPersona.T_Nombre);
                parameters.Add(name: "D_FecNac", dbType: DbType.Date, value: paramGrabarPersona.D_FecNac);
                parameters.Add(name: "C_Sexo", dbType: DbType.String, size: 1, value: paramGrabarPersona.C_Sexo);
                parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: paramGrabarPersona.D_FecCre);
                parameters.Add(name: "I_UsuarioCre", dbType: DbType.Int32, value: paramGrabarPersona.I_UsuarioCre);
                parameters.Add(name: "I_PersonaID", dbType: DbType.Int32, direction: ParameterDirection.Output);
                parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                dbConnection.Execute(command, parameters, dbTransaction, commandType: CommandType.StoredProcedure);

                result = new ResponseData
                {
                    CurrentID = parameters.Get<int>("I_PersonaID").ToString(),
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
