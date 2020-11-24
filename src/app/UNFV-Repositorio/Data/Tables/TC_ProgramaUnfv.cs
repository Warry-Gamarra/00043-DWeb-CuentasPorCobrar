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
    public class TC_ProgramaUnfv
    {
        public string C_CodProg { get; set; }

        public string C_RcCod { get; set; }

        public string T_DenomProg { get; set; }

        public string T_Resolucion { get; set; }

        public string T_DenomGrado { get; set; }

        public string T_DenomTitulo { get; set; }

        public string C_CodModEst { get; set; }

        public bool B_SegundaEsp { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public string C_CodRegimenEst { get; set; }

        public string C_CodGrado { get; set; }

        public static IEnumerable<TC_ProgramaUnfv> GetAll()
        {
            IEnumerable<TC_ProgramaUnfv> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TC_ProgramaUnfv WHERE B_Eliminado = 0";

                    result = _dbConnection.Query<TC_ProgramaUnfv>(command, commandType: CommandType.Text);
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
