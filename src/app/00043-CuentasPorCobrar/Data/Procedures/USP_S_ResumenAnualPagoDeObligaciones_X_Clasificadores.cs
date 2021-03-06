﻿using Dapper;
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
    public class USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores
    {
        public string C_CodClasificador { get; set; }
        public string T_ClasificadorDesc { get; set; }
        public decimal Enero { get; set; }
        public decimal Febrero { get; set; }
        public decimal Marzo { get; set; }
        public decimal Abril { get; set; }
        public decimal Mayo { get; set; }
        public decimal Junio { get; set; }
        public decimal Julio { get; set; }
        public decimal Agosto { get; set; }
        public decimal Setiembre { get; set; }
        public decimal Octubre   { get; set; }
        public decimal Noviembre { get; set; }
        public decimal Diciembre { get; set; }

        public static IEnumerable<USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores> Execute(int anio, bool esPregrado)
        {
            IEnumerable<USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores> result;
            DynamicParameters parameters;
            string s_command;

            try
            {
                s_command = "USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores";

                parameters = new DynamicParameters();

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_Anio", dbType: DbType.Int32, value: anio);

                    parameters.Add(name: "B_EsPregrado", dbType: DbType.Int32, value: esPregrado);

                    result = _dbConnection.Query<USP_S_ResumenAnualPagoDeObligaciones_X_Clasificadores>(s_command, parameters, commandType: CommandType.StoredProcedure);
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
