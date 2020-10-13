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
        public int I_CtaDepID { get; set; }
        public string C_NumeroCuenta { get; set; }
        public string T_EntidadDesc { get; set; }

        public static List<USP_S_CuentaDeposito_Habilitadas> Execute()
        {
            List<USP_S_CuentaDeposito_Habilitadas> lista;
            
            try
            {
                string s_command = @"USP_S_CuentaDeposito_Habilitada";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    lista = _dbConnection.Query<USP_S_CuentaDeposito_Habilitadas>(s_command, commandType: CommandType.StoredProcedure).ToList();
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
