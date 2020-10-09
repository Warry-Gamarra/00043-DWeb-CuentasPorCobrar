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
    public class USP_S_CuentaDeposito
    {
        public int I_CtaDepID { get; set; }
        public string C_NumeroCuenta { get; set; }
        public string T_EntidadDesc { get; set; }

        public static List<USP_S_CuentaDeposito> Execute()
        {
            List<USP_S_CuentaDeposito> lista;
            string s_command;

            try
            {
                s_command = @"EXEC USP_S_CuentaDeposito;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    lista = new List<USP_S_CuentaDeposito>();

                    foreach (var item in _dbConnection.Query<USP_S_CuentaDeposito>(s_command, commandType: CommandType.StoredProcedure))
                    {
                        lista.Add(item);
                    }
                }
            }
            catch (Exception)
            {
                throw;
            }

            return lista;
        }
    }
}
