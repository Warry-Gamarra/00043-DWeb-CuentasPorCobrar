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
    public class VW_MatriculaAlumno
    {
        public int I_MatAluID { get; set; }

        public string C_CodAlu { get; set; }

        public string C_RcCod { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public string N_Grado { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string C_CodFac { get; set; }

        public string C_EstMat { get; set; }

        public string C_Ciclo { get; set; }

        public bool? B_Ingresante { get; set; }

        public byte? I_CredDesaprob { get; set; }

        public bool B_Habilitado { get; set; }
        
        public string C_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public string T_DenomProg { get; set; }

        public string T_ModIngDesc { get; set; }

        public bool B_TieneMultaPorNoVotar { get; set; }

        public static IEnumerable<VW_MatriculaAlumno> GetPregrado(int anio, int periodo)
        {
            IEnumerable<VW_MatriculaAlumno> result;

            try
            {
                string s_command = @"SELECT m.* FROM dbo.VW_MatriculaAlumno m WHERE m.I_Anio = @I_Anio AND m.I_Periodo = @I_Periodo AND m.N_Grado = 1";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_MatriculaAlumno>(s_command, new { I_Anio = anio, I_Periodo = periodo }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<VW_MatriculaAlumno> GetPosgrado(int anio, int periodo)
        {
            IEnumerable<VW_MatriculaAlumno> result;

            try
            {
                string s_command = @"SELECT m.* FROM dbo.VW_MatriculaAlumno m WHERE m.I_Anio = @I_Anio AND m.I_Periodo = @I_Periodo AND m.N_Grado IN (2,3)";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_MatriculaAlumno>(s_command, new { I_Anio = anio, I_Periodo = periodo }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static VW_MatriculaAlumno GetMatricula(int anio, int periodo, string codAlu, string codRc)
        {
            VW_MatriculaAlumno result;

            try
            {
                string s_command = @"SELECT m.* FROM dbo.VW_MatriculaAlumno m WHERE m.I_Anio = @I_Anio AND m.I_Periodo = @I_Periodo AND m.C_CodAlu = @C_CodAlu AND m.C_RcCod = @C_RcCod";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.QueryFirstOrDefault<VW_MatriculaAlumno>(s_command, new { I_Anio = anio, I_Periodo = periodo, C_CodAlu = codAlu, C_RcCod = codRc }, commandType: CommandType.Text);
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
