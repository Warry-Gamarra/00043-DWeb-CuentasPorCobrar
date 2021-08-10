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
    public class USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia
    {
        public string C_CodDependencia { get; set; }
        public string T_Dependencia { get; set; }
        public decimal Enero { get; set; }
        public decimal Febrero { get; set; }
        public decimal Marzo { get; set; }
        public decimal Abril { get; set; }
        public decimal Mayo { get; set; }
        public decimal Junio { get; set; }
        public decimal Julio { get; set; }
        public decimal Agosto { get; set; }
        public decimal Setiembre { get; set; }
        public decimal Octubre { get; set; }
        public decimal Noviembre { get; set; }
        public decimal Diciembre { get; set; }

        public static IEnumerable<USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia> Execute(int anio, bool esPregrado, int? entidadFinanID, int? ctaDepositoID)
        {
            IEnumerable<USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia> result;
            DynamicParameters parameters;
            string s_command;

            try
            {
                s_command = "USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia";

                parameters = new DynamicParameters();

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_Anio", dbType: DbType.Int32, value: anio);

                    parameters.Add(name: "B_EsPregrado", dbType: DbType.Boolean, value: esPregrado);

                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: entidadFinanID);

                    parameters.Add(name: "I_CtaDepositoID", dbType: DbType.Int32, value: ctaDepositoID);

                    result = _dbConnection.Query<USP_S_ResumenAnualPagoDeObligaciones_X_Dependencia>(s_command, parameters, commandType: CommandType.StoredProcedure);
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
