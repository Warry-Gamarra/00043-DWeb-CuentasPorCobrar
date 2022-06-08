using Dapper;
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
    public class USP_S_ValidarCodOperacionObligacion
    {
        public string C_CodOperacion { get; set; }
        public string C_CodDepositante { get; set; }
        public int I_EntidadFinanID { get; set; }
        public DateTime? D_FecPago { get; set; }
        public int? I_ProcesoIDArchivo { get; set; }
        public DateTime? D_FecVenctoArchivo { get; set; }

        public static bool Execute(USP_S_ValidarCodOperacionObligacion spParam)
        {
            DynamicParameters parameters = new DynamicParameters();
            bool result;
            try
            {
                string s_command = @"USP_S_ValidarCodOperacionObligacion";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "C_CodOperacion", dbType: DbType.String, value: spParam.C_CodOperacion);
                    parameters.Add(name: "C_CodDepositante", dbType: DbType.String, value: spParam.C_CodDepositante);
                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int16, value: spParam.I_EntidadFinanID);
                    parameters.Add(name: "D_FecPago", dbType: DbType.DateTime, value: spParam.D_FecPago);
                    parameters.Add(name: "I_ProcesoIDArchivo", dbType: DbType.Int16, value: spParam.I_ProcesoIDArchivo);
                    parameters.Add(name: "D_FecVenctoArchivo", dbType: DbType.Date, value: spParam.D_FecVenctoArchivo);
                    parameters.Add(name: "B_Correct", dbType: DbType.Boolean, direction: ParameterDirection.Output);

                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.StoredProcedure);

                    result = parameters.Get<bool>("B_Correct");
                }
            }
            catch (Exception ex)
            {
                result = false;
            }

            return result;
        }
    }
}
