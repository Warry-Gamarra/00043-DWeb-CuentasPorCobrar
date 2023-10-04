using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Views
{
    public class VW_CarreraProfesional
    {
        public string C_RcCod { get; set; }

        public string C_CodEsp { get; set; }

        public string C_CodEsc { get; set; }

        public string C_CodFac { get; set; }

        public string T_EspDesc { get; set; }

        public string T_EscDesc { get; set; }

        public string T_FacDesc { get; set; }

        public string T_CarProfDesc { get; set; }

        public string C_Tipo { get; set; }

        public int? I_Duracion { get; set; }

        public bool? B_Anual { get; set; }

        public string N_Grupo { get; set; }

        public string N_Grado { get; set; }

        public int? I_IdAplica { get; set; }

        public bool B_Habilitado { get; set; }

        public int? I_DependenciaID { get; set; }

        public static IEnumerable<VW_CarreraProfesional> GetAll()
        {
            IEnumerable<VW_CarreraProfesional> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM dbo.VW_CarreraProfesional WHERE B_Eliminado = 0 ORDER BY T_FacDesc, T_EscDesc, T_CarProfDesc";

                    result = _dbConnection.Query<VW_CarreraProfesional>(command, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static VW_CarreraProfesional GetByID(string codRc)
        {
            VW_CarreraProfesional result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM dbo.VW_CarreraProfesional WHERE B_Eliminado = 0 AND C_RcCod = @C_RcCod";

                    result = _dbConnection.QueryFirstOrDefault<VW_CarreraProfesional>(command, new { C_RcCod = codRc }, commandType: CommandType.Text);
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
