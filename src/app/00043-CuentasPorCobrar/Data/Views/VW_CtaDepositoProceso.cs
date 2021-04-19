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
    public class VW_CtaDepositoProceso
    {
        public int I_CtaDepoProID { get; set; }

        public int I_EntidadFinanID { get; set; }

        public string T_EntidadDesc { get; set; }

        public int I_CtaDepositoID { get; set; }

        public string C_NumeroCuenta { get; set; }

        public string T_DescCuenta { get; set; }

        public int I_ProcesoID { get; set; }

        public string T_ProcesoDesc { get; set; }

        public byte? I_Prioridad { get; set; }

        public short? I_Anio { get; set; }

        public int? I_Periodo { get; set; }

        public string C_Periodo { get; set; }

        public string T_PeriodoDesc { get; set; }

        public int? I_Nivel { get; set; }

        public string C_Nivel { get; set; }

        public bool B_Habilitado { get; set; }

        public static IEnumerable<VW_CtaDepositoProceso> GetCtaDepositoByProceso(int idProceso)
        {
            IEnumerable<VW_CtaDepositoProceso> result;

            try
            {
                string s_command = @"SELECT cta.* FROM dbo.VW_CtaDepositoProceso cta WHERE cta.I_ProcesoID = @I_ProcesoID";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_CtaDepositoProceso>(s_command, new { I_ProcesoID = idProceso }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<VW_CtaDepositoProceso> GetCtaDepositoByAnioPeriodo(int anio, int periodo)
        {
            IEnumerable<VW_CtaDepositoProceso> result;

            try
            {
                string s_command = @"SELECT cta.* FROM dbo.VW_CtaDepositoProceso cta WHERE cta.I_Anio = @I_Anio AND cta.I_Periodo = @I_Periodo";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_CtaDepositoProceso>(s_command, new { I_Anio = anio, I_Periodo = periodo }, commandType: CommandType.Text);
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
