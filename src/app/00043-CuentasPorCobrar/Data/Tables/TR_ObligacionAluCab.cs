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
    public class TR_ObligacionAluCab
    {
        public int I_ObligacionAluID { get; set; }

        public int? I_ProcesoID { get; set; }

        public int? I_MatAluID { get; set; }

        public string C_Moneda { get; set; }

        public decimal? I_MontoOblig { get; set; }

        public DateTime? D_FecVencto { get; set; }

        public bool? B_Pagado { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public static TR_ObligacionAluCab FindByID(int I_ObligacionAluID)
        {
            TR_ObligacionAluCab result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT c.* FROM TR_ObligacionAluCab c WHERE c.B_Eliminado = 0 AND c.I_ObligacionAluID = @I_ObligacionAluID";

                    result = _dbConnection.QueryFirstOrDefault<TR_ObligacionAluCab>(s_command, new { I_ObligacionAluID = I_ObligacionAluID }, 
                        commandType: CommandType.Text);
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
