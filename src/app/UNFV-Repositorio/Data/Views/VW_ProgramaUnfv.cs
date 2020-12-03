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
    public class VW_ProgramaUnfv
    {
        public string C_CodProg { get; set; }

        public string C_RcCod { get; set; }

        public string C_CodEsp { get; set; }

        public string C_CodEsc { get; set; }

        public string C_CodFac { get; set; }

        public string T_EspDesc { get; set; }

        public string T_EscDesc { get; set; }

        public string T_FacDesc { get; set; }

        public string T_DenomProg { get; set; }

        public string T_Resolucion { get; set; }

        public string T_DenomGrado { get; set; }

        public string T_DenomTitulo { get; set; }

        public string C_CodRegimenEst { get; set; }

        public string C_CodModEst { get; set; }

        public bool B_SegundaEsp { get; set; }

        public string C_CodGrado { get; set; }

        public string C_Tipo { get; set; }

        public int? I_Duracion { get; set; }

        public bool? B_Anual { get; set; }

        public string N_Grupo { get; set; }

        public string N_Grado { get; set; }

        public int? I_IdAplica { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public static IEnumerable<VW_ProgramaUnfv> GetAll()
        {
            IEnumerable<VW_ProgramaUnfv> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM dbo.VW_ProgramaUnfv WHERE B_Eliminado = 0";

                    result = _dbConnection.Query<VW_ProgramaUnfv>(command, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static VW_ProgramaUnfv GetByID(string codProg)
        {
            VW_ProgramaUnfv result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM dbo.VW_ProgramaUnfv WHERE B_Eliminado = 0 AND C_CodProg = @C_CodProg";

                    result = _dbConnection.QueryFirstOrDefault<VW_ProgramaUnfv>(command, new { C_CodProg = codProg }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static VW_ProgramaUnfv GetByCodRc(string codRc)
        {
            VW_ProgramaUnfv result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM dbo.VW_ProgramaUnfv WHERE B_Eliminado = 0 AND C_RcCod = @C_RcCod";

                    result = _dbConnection.QueryFirstOrDefault<VW_ProgramaUnfv>(command, new { C_RcCod = codRc }, commandType: CommandType.Text);
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
