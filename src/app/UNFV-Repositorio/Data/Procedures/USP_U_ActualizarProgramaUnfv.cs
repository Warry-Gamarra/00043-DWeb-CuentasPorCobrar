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
    public class USP_U_ActualizarProgramaUnfv
    {
        public string C_CodProg { get; set; }
        public string C_RcCod { get; set; }
        public string T_DenomProg { get; set; }
        public string T_Resolucion { get; set; }
        public string C_CodGrado { get; set; }
        public string T_DenomGrado { get; set; }
        public string T_DenomTitulo { get; set; }
        public string C_CodRegimenEst { get; set; }
        public string C_CodModEst { get; set; }
        public bool B_SegundaEsp { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public DateTime D_FecMod { get; set; }
        public int I_UsuarioMod { get; set; }

        public static ResponseData Execute(IDbConnection dbConnection, IDbTransaction dbTransaction, USP_U_ActualizarProgramaUnfv paramActualizarProgramaUnfv)
        {
            ResponseData result;
            DynamicParameters parameters;
            string command;

            try
            {
                command = "USP_U_ActualizarProgramaUnfv";

                parameters = new DynamicParameters();
                parameters.Add(name: "C_CodProg", dbType: DbType.String, size: 10, value: paramActualizarProgramaUnfv.C_CodProg);
                parameters.Add(name: "C_RcCod", dbType: DbType.String, size: 3, value: paramActualizarProgramaUnfv.C_RcCod);
                parameters.Add(name: "T_DenomProg", dbType: DbType.String, size: 250, value: paramActualizarProgramaUnfv.T_DenomProg);
                parameters.Add(name: "T_Resolucion", dbType: DbType.String, size: 250, value: paramActualizarProgramaUnfv.T_Resolucion);
                parameters.Add(name: "C_CodGrado", dbType: DbType.String, size: 5, value: paramActualizarProgramaUnfv.C_CodGrado);
                parameters.Add(name: "T_DenomGrado", dbType: DbType.String, size: 250, value: paramActualizarProgramaUnfv.T_DenomGrado);
                parameters.Add(name: "T_DenomTitulo", dbType: DbType.String, size: 500, value: paramActualizarProgramaUnfv.T_DenomTitulo);
                parameters.Add(name: "C_CodRegimenEst", dbType: DbType.String, size: 5, value: paramActualizarProgramaUnfv.C_CodRegimenEst);
                parameters.Add(name: "C_CodModEst", dbType: DbType.String, size: 5, value: paramActualizarProgramaUnfv.C_CodModEst);
                parameters.Add(name: "B_SegundaEsp", dbType: DbType.Boolean, value: paramActualizarProgramaUnfv.B_SegundaEsp);
                parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: paramActualizarProgramaUnfv.B_Habilitado);
                parameters.Add(name: "B_Eliminado", dbType: DbType.Boolean, value: paramActualizarProgramaUnfv.B_Eliminado);
                parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: paramActualizarProgramaUnfv.D_FecMod);
                parameters.Add(name: "I_UsuarioMod", dbType: DbType.Int32, value: paramActualizarProgramaUnfv.I_UsuarioMod);
                parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                dbConnection.Execute(command, parameters, dbTransaction, commandType: CommandType.StoredProcedure);

                result = new ResponseData
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
