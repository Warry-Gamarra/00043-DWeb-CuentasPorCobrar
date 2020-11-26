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
    public class USP_S_CuentaDeposito_Habilitadas
    {
        public int I_CtaDepositoID { get; set; }
        public string C_NumeroCuenta { get; set; }
        public string T_EntidadDesc { get; set; }

        public static List<USP_S_CuentaDeposito_Habilitadas> Execute(int I_TipoPeriodoID)
        {
            List<USP_S_CuentaDeposito_Habilitadas> lista;
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_S_CuentaDeposito_Habilitadas";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_TipoPeriodoID", dbType: DbType.Int32, value: I_TipoPeriodoID);

                    lista = _dbConnection.Query<USP_S_CuentaDeposito_Habilitadas>(s_command, parameters, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return lista;
        }
    }
}
