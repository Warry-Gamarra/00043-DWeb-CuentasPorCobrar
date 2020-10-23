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
    public class TC_DependenciaUNFV
    {
        public int I_DependenciaID { get; set; }
        public string T_DependDesc { get; set; }
        public int I_DepAgrupaID { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int I_UsuarioCre { get; set; }
        public DateTime D_FecCre { get; set; }
        public int I_UsuarioMod { get; set; }
        public DateTime D_FecMod { get; set; }

        public static List<TC_DependenciaUNFV> FindAll()
        {
            List<TC_DependenciaUNFV> result;

            try
            {
                string s_command = @"SELECT d.* FROM dbo.TC_DependenciaUNFV d";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_DependenciaUNFV>(s_command, commandType: CommandType.Text).ToList();
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
