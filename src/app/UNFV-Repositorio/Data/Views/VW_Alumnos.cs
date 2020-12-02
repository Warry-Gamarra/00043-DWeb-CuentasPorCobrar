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
    public class VW_Alumnos
    {
        public int I_PersonaID { get; set; }

        public string C_CodTipDoc { get; set; }

        public string T_TipDocDesc { get; set; }

        public string C_NumDNI { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public string T_Nombre { get; set; }

        public DateTime? D_FecNac { get; set; }

        public string C_Sexo { get; set; }

        public string C_CodAlu { get; set; }

        public string C_RcCod { get; set; }

        public string T_DenomProg { get; set; }

        public string C_CodModIng { get; set; }

        public string T_ModIngDesc { get; set; }

        public int? C_AnioIngreso { get; set; }

        public int? I_IdPlan { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public static IEnumerable<VW_Alumnos> GetAll()
        {
            IEnumerable<VW_Alumnos> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM dbo.VW_Alumnos WHERE B_Eliminado = 0";

                    result = _dbConnection.Query<VW_Alumnos>(command, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static VW_Alumnos GetByID(string codRc, string codAlu)
        {
            VW_Alumnos result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM dbo.VW_Alumnos WHERE B_Eliminado = 0 AND C_RcCod = @C_RcCod AND C_CodAlu = @C_CodAlu";

                    result = _dbConnection.QueryFirstOrDefault<VW_Alumnos>(command, new { C_RcCod = codRc, C_CodAlu = codAlu }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<VW_Alumnos> GetByDocIdent(string codTipDoc, string numDNI)
        {
            IEnumerable<VW_Alumnos> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM dbo.VW_Alumnos WHERE B_Eliminado = 0 AND C_CodTipDoc = @C_CodTipDoc AND C_NumDNI = @C_NumDNI";

                    result = _dbConnection.Query<VW_Alumnos>(command, new { C_CodTipDoc = codTipDoc, C_NumDNI = numDNI }, commandType: CommandType.Text);
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
