using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TC_CuotaPago
    {
        public int I_CuotaPagoID { get; set; }
        public string T_CuotaPagoDesc { get; set; }
        public bool B_Habilitado { get; set; }

        public static List<TC_CuotaPago> FindAll()
        {
            List<TC_CuotaPago> result;

            try
            {
                string s_command = @"select c.I_CuotaPagoID, c.T_CuotaPagoDesc, c.B_Habilitado from dbo.TC_CuotaPago c";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_CuotaPago>(s_command, commandType: CommandType.Text).ToList();
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
