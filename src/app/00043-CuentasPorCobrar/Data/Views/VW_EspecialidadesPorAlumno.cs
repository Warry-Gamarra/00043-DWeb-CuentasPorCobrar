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
    public class VW_EspecialidadesPorAlumno
    {
        public string C_CodAlu { get; set; }

        public string C_RcCod { get; set; }

        public string T_EspDesc { get; set; }

        public static IEnumerable<VW_EspecialidadesPorAlumno> FindByAlumno(string codAlu)
        {
            IEnumerable<VW_EspecialidadesPorAlumno> result;

            try
            {
                string s_command = @"SELECT * FROM dbo.VW_EspecialidadesPorAlumno WHERE C_CodAlu = @C_CodAlu";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_EspecialidadesPorAlumno>(s_command, new { C_CodAlu = codAlu }, commandType: CommandType.Text);
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
