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
    public class TC_Periodo
    {
        public int I_PeriodoID { get; set; }
        public int I_TipoPeriodoID { get; set; }
        public short? I_Anio { get; set; }
        public DateTime? D_FecVencto { get; set; }
        public byte? I_Prioridad { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }

        public static TC_Periodo FindByID(int I_PeriodoID)
        {
            TC_Periodo result;

            try
            {
                string s_command = @"select p.* from dbo.TC_Periodo p where p.I_PeriodoID = @I_PeriodoID";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_Periodo>(s_command, new { I_PeriodoID = I_PeriodoID }, commandType: CommandType.Text).FirstOrDefault();
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
