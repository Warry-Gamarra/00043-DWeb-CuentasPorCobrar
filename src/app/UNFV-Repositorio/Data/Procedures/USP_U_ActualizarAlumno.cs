﻿using Dapper;
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

        public static ResponseData Execute(IDbConnection dbConnection, IDbTransaction dbTransaction, USP_U_ActualizarAlumno paramActualizarAlumno)
        {
            ResponseData result;
            DynamicParameters parameters;
            string command;

            try
            {
                command = "USP_U_ActualizarAlumno";

                parameters = new DynamicParameters();
                parameters.Add(name: "C_RcCod", dbType: DbType.String, size: 3, value: paramActualizarAlumno.C_RcCod);
                parameters.Add(name: "C_CodAlu", dbType: DbType.String, size: 20, value: paramActualizarAlumno.C_CodAlu);
                parameters.Add(name: "C_CodModIng", dbType: DbType.String, size: 2, value: paramActualizarAlumno.C_CodModIng);
                parameters.Add(name: "C_AnioIngreso", dbType: DbType.Int16, value: paramActualizarAlumno.C_AnioIngreso);
                parameters.Add(name: "I_IdPlan", dbType: DbType.Int32, value: paramActualizarAlumno.I_IdPlan);
                parameters.Add(name: "I_PersonaID", dbType: DbType.Int32, value: paramActualizarAlumno.I_PersonaID);
                parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: paramActualizarAlumno.B_Habilitado);
                parameters.Add(name: "B_Eliminado", dbType: DbType.Boolean, value: paramActualizarAlumno.B_Eliminado);
                parameters.Add(name: "D_FecMod", dbType: DbType.Date, value: paramActualizarAlumno.D_FecMod);
                parameters.Add(name: "I_UsuarioMod", dbType: DbType.Int32, value: paramActualizarAlumno.I_UsuarioMod);
                parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                dbConnection.Execute(command, parameters, dbTransaction, commandType: CommandType.StoredProcedure);

                result = new ResponseData();
                result.Value = parameters.Get<bool>("B_Result");
                result.Message = parameters.Get<string>("T_Message");   
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }
    }
}