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
    public class TC_ProgramaUnfv
    {
        public string C_CodProg { get; set; }

        public string C_RcCod { get; set; }

        public string T_DenomProg { get; set; }

        public string T_Resolucion { get; set; }

        public string T_DenomGrado { get; set; }

        public string T_DenomTitulo { get; set; }

        public string C_CodModEst { get; set; }

        public bool B_SegundaEsp { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public string C_CodRegimenEst { get; set; }

        public string C_CodGrado { get; set; }
    }
}
