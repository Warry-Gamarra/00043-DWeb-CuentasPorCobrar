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
    public class USP_S_Periodos
    {
        public int I_PeriodoID { get; set; }
        public string T_CuotaPagoDesc { get; set; }
        public int N_Anio { get; set; }
        public DateTime D_FecIni { get; set; }
        public DateTime D_FecFin { get; set; }

        public static List<USP_S_Periodos> Execute()
        {
            List<USP_S_Periodos> lista;
            string s_command;

            try
            {
                s_command = @"EXEC USP_S_Periodos;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    lista = new List<USP_S_Periodos>();

                    foreach (var item in _dbConnection.Query<USP_S_Periodos>(s_command, commandType: CommandType.StoredProcedure))
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
