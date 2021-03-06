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
    public class USP_S_ConceptoPago
    {
        public int? I_ConcPagID { get; set; }
        public int I_ConceptoID { get; set; }
        public string T_CatPagoDesc { get; set; }
        public string T_ConceptoDesc { get; set; }
        public string T_ProcesoDesc { get; set; }
        public int I_Anio { get; set; }
        public int I_Periodo { get; set; }
        public decimal M_MontoMinimo { get; set; }
        public decimal M_Monto { get; set; }
        public bool B_Habilitado { get; set; }


        public static List<USP_S_ConceptoPago> Execute(int I_ProcesoID)
        {
            List<USP_S_ConceptoPago> result;
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_S_ConceptoPago";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_ProcesoID", dbType: DbType.Int32, value: I_ProcesoID);
                    result = _dbConnection.Query<USP_S_ConceptoPago>(s_command, parameters, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static List<USP_S_ConceptoPago> Execute(int? I_ProcesoID, bool B_Obligacion)
        {
            List<USP_S_ConceptoPago> result;
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_S_ConceptoPago";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_ProcesoID", dbType: DbType.Int32, value: I_ProcesoID);
                    parameters.Add(name: "B_Obligacion", dbType: DbType.Boolean, value: B_Obligacion);

                    result = _dbConnection.Query<USP_S_ConceptoPago>(s_command, parameters, commandType: CommandType.StoredProcedure).ToList();
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
