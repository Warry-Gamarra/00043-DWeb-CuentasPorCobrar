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
    public class TI_CarreraProfesional
    {
        public string C_RcCod { get; set; }

        public string C_CodEsp { get; set; }

        public string C_CodEsc { get; set; }

        public string C_CodFac { get; set; }

        public string C_Tipo { get; set; }

        public int? I_Duracion { get; set; }

        public bool? B_Anual { get; set; }

        public string N_Grupo { get; set; }

        public string N_Grado { get; set; }

        public int? I_IdAplica { get; set; }

        public int B_Habilitado { get; set; }

        public int B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public static IEnumerable<TI_CarreraProfesional> GetAll()
        {
            IEnumerable<TI_CarreraProfesional> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TI_CarreraProfesional WHERE B_Eliminado = 0";

                    result = _dbConnection.Query<TI_CarreraProfesional>(command, commandType: CommandType.Text);
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
