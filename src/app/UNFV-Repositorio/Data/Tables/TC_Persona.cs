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
    public class TC_Persona
    {
        public int I_PersonaID { get; set; }

        public string C_NumDNI { get; set; }

        public string C_CodTipDoc { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public string T_Nombre { get; set; }

        public DateTime? D_FecNac { get; set; }

        public string C_Sexo { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public static TC_Persona GetByDocIdent(string numDNI, string codTipDoc)
        {
            TC_Persona result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TC_Persona WHERE B_Eliminado = 0 AND C_NumDNI = @C_NumDNI AND C_CodTipDoc = @C_CodTipDoc";

                    result = _dbConnection.QueryFirstOrDefault<TC_Persona>(command, new { C_NumDNI = numDNI, C_CodTipDoc  = codTipDoc }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static TC_Persona GetByID(int personaID)
        {
            TC_Persona result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TC_Persona WHERE B_Eliminado = 0 AND I_PersonaID = @I_PersonaID";

                    result = _dbConnection.QueryFirstOrDefault<TC_Persona>(command, new { I_PersonaID = personaID }, commandType: CommandType.Text);
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
