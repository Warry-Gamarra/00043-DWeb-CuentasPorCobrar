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
    public class TC_Especialidad
    {
        public string C_CodEsp { get; set; }

        public string C_CodEsc { get; set; }

        public string C_CodFac { get; set; }

        public string T_EspDesc { get; set; }

        public string T_EspAbrev { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public IEnumerable<TC_Especialidad> GetAll()
        {
            IEnumerable<TC_Especialidad> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TC_Especialidad WHERE B_Eliminado = 0";

                    result = _dbConnection.Query<TC_Especialidad>(command, commandType: CommandType.Text);
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
