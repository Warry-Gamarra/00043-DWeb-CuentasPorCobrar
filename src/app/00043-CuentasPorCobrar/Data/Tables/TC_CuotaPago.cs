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

        public static List<TC_CuotaPago> Find()
        {
            List<TC_CuotaPago> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT I_CuotaPagoID, T_CuotaPagoDesc, B_Habilitado FROM dbo.TC_CuotaPago";

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
