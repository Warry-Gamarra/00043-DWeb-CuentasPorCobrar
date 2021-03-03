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
    public class VW_DetalleObligaciones
    {
        public string C_CodAlu { get; set; }

        public string C_CodRc { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public string T_ConceptoDesc { get; set; }

        public string T_CatPagoDesc { get; set; }

        public decimal? I_Monto { get; set; }

        public bool B_Pagado { get; set; }

        public DateTime D_FecVencto { get; set; }

        public byte? I_Prioridad { get; set; }

        public static IEnumerable<VW_DetalleObligaciones> FindByAlumno(int anio, int periodo, string codAlu, string codRc)
        {
            IEnumerable<VW_DetalleObligaciones> result;

            try
            {
                string s_command = @"SELECT * FROM dbo.VW_DetalleObligaciones d
                    WHERE d.I_Anio = @I_Anio AND d.I_Periodo = @I_Periodo AND d.C_CodAlu = @C_CodAlu AND d.C_CodRc = @C_CodRc
                    ORDER BY d.I_Anio, d.I_Periodo, d.D_FecVencto, d.C_CodAlu, d.C_CodRc, d.I_Prioridad";

                var parameters = new { I_Anio = anio, I_Periodo = periodo, C_CodAlu = codAlu, C_CodRc = codRc };

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_DetalleObligaciones>(s_command, parameters, commandType: CommandType.Text);
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
